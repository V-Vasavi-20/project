#!/bin/bash

set -e

LOG_FILE="/var/log/jenkins-bootstrap.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "Jenkins Bootstrap Started"
echo "=========================================="

# ============================================================
# SYSTEM UPDATE
# ============================================================

dnf update -y


# ============================================================
# INSTALL REQUIRED PACKAGES
# ============================================================

dnf install -y \
  java-21-amazon-corretto \
  git \
  docker \
  unzip \
  wget \
  rsync \
  util-linux
# ============================================================
# INSTALL KUBECTL
# ============================================================

KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

kubectl version --client

# ============================================================
# INSTALL HELM
# ============================================================

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  | bash

helm version

# ============================================================
# JAVA CHECK
# ============================================================

java -version


# ============================================================
# DOCKER
# ============================================================

systemctl enable docker
systemctl start docker


# ============================================================
# JENKINS REPOSITORY
# ============================================================

curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key \
  -o /etc/pki/rpm-gpg/jenkins.io.key

rpm --import /etc/pki/rpm-gpg/jenkins.io.key


cat > /etc/yum.repos.d/jenkins.repo <<'EOF'
[jenkins]
name=Jenkins
baseurl=https://pkg.jenkins.io/redhat-stable/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/jenkins.io.key
EOF


# ============================================================
# INSTALL JENKINS
# ============================================================

dnf install -y jenkins


# ============================================================
# STOP JENKINS BEFORE MOUNTING DATA VOLUME
# ============================================================

systemctl stop jenkins || true


# ============================================================
# FIND PERSISTENT DATA DISK
# ============================================================

DATA_DEVICE="/dev/sdf"

echo "Checking persistent data disk..."

if [ ! -b "$DATA_DEVICE" ]; then
    echo "Waiting for persistent EBS volume..."

    for i in {1..30}; do
        if [ -b "$DATA_DEVICE" ]; then
            break
        fi

        sleep 5
    done
fi


if [ ! -b "$DATA_DEVICE" ]; then
    echo "ERROR: Persistent EBS volume $DATA_DEVICE not found"
    exit 1
fi


# ============================================================
# FORMAT DATA DISK ONLY IF IT HAS NO FILESYSTEM
# ============================================================

if ! blkid "$DATA_DEVICE" >/dev/null 2>&1; then

    echo "No filesystem found on $DATA_DEVICE"

    mkfs.ext4 "$DATA_DEVICE"

else

    echo "Filesystem already exists on $DATA_DEVICE"

fi


# ============================================================
# CREATE JENKINS DATA DIRECTORY
# ============================================================

mkdir -p /var/lib/jenkins


# ============================================================
# BACKUP EXISTING JENKINS DIRECTORY
# ============================================================

if [ -n "$(ls -A /var/lib/jenkins 2>/dev/null)" ]; then

    mkdir -p /var/lib/jenkins-bootstrap

    rsync -a \
      /var/lib/jenkins/ \
      /var/lib/jenkins-bootstrap/

fi


# ============================================================
# MOUNT PERSISTENT EBS
# ============================================================

mountpoint -q /var/lib/jenkins || \
mount "$DATA_DEVICE" /var/lib/jenkins


# ============================================================
# PERSIST MOUNT AFTER REBOOT
# ============================================================

if ! grep -q "$DATA_DEVICE" /etc/fstab; then

    echo "$DATA_DEVICE /var/lib/jenkins ext4 defaults,nofail 0 2" \
      >> /etc/fstab

fi


# ============================================================
# RESTORE EXISTING JENKINS DATA IF AVAILABLE
# ============================================================

if [ -d "/var/lib/jenkins-bootstrap" ]; then

    if [ -z "$(ls -A /var/lib/jenkins 2>/dev/null)" ]; then

        rsync -a \
          /var/lib/jenkins-bootstrap/ \
          /var/lib/jenkins/

    fi

fi


# ============================================================
# JENKINS DIRECTORY PERMISSIONS
# ============================================================

chown -R jenkins:jenkins /var/lib/jenkins

chmod 750 /var/lib/jenkins


# ============================================================
# ADD JENKINS USER TO DOCKER GROUP
# ============================================================

usermod -aG docker jenkins


# ============================================================
# ENABLE AND START JENKINS
# ============================================================

systemctl daemon-reload

systemctl enable jenkins

systemctl start jenkins


# ============================================================
# WAIT FOR JENKINS
# ============================================================

echo "Waiting for Jenkins to start..."

for i in {1..30}; do

    if systemctl is-active --quiet jenkins; then
        echo "Jenkins started successfully"
        break
    fi

    sleep 5

done


# ============================================================
# STATUS
# ============================================================

echo "=========================================="
echo "Jenkins Bootstrap Completed"
echo "=========================================="

systemctl status jenkins --no-pager || true

echo "Jenkins data mount:"

df -h /var/lib/jenkins || true

echo "Docker status:"

systemctl status docker --no-pager || true
