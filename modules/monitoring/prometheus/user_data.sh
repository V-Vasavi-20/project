#!/bin/bash

set -e

LOG_FILE="/var/log/monitoring-bootstrap.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "Starting Monitoring Server Bootstrap"
echo "=========================================="

# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

dnf update -y


# --------------------------------------------------
# 2. Install required packages
# --------------------------------------------------
# IMPORTANT:
# Do NOT install "curl" on Amazon Linux 2023.
# curl-minimal is already installed and installing
# the full curl package causes a package conflict.

dnf install -y \
  docker \
  jq \
  openssl


# --------------------------------------------------
# 3. Enable and start Docker
# --------------------------------------------------

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

docker --version


# --------------------------------------------------
# 4. Install Docker Compose CLI plugin
# --------------------------------------------------

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
  https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version


# --------------------------------------------------
# 5. Create monitoring directories
# --------------------------------------------------

mkdir -p /opt/monitoring/prometheus

mkdir -p /opt/monitoring/grafana/provisioning/datasources
mkdir -p /opt/monitoring/grafana/provisioning/dashboards
mkdir -p /opt/monitoring/grafana/provisioning/plugins
mkdir -p /opt/monitoring/grafana/provisioning/alerting

mkdir -p /opt/monitoring/grafana/dashboards

mkdir -p /opt/monitoring/secrets


# --------------------------------------------------
# 6. Prometheus configuration
# --------------------------------------------------

cat > /opt/monitoring/prometheus/prometheus.yml <<'EOF'

global:
  scrape_interval: 30s
  evaluation_interval: 30s

scrape_configs:

  # Prometheus itself
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "prometheus:9090"

  # Monitoring EC2 Node Exporter
  - job_name: "monitoring-node"
    static_configs:
      - targets:
          - "node-exporter:9100"

EOF


# --------------------------------------------------
# 7. Grafana Prometheus datasource
# --------------------------------------------------

cat > /opt/monitoring/grafana/provisioning/datasources/prometheus.yml <<'EOF'

apiVersion: 1

datasources:

  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

EOF


# --------------------------------------------------
# 8. Generate Grafana admin password
# --------------------------------------------------

GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 32 | \
  tr -dc 'A-Za-z0-9' | \
  head -c 24)


# --------------------------------------------------
# 9. Store password securely
# --------------------------------------------------

install -d -m 700 /opt/monitoring/secrets

printf '%s\n' "$GRAFANA_ADMIN_PASSWORD" \
  > /opt/monitoring/secrets/grafana-admin-password

chmod 600 /opt/monitoring/secrets/grafana-admin-password


# --------------------------------------------------
# 10. Create Docker Compose environment file
# --------------------------------------------------

cat > /opt/monitoring/.env <<EOF

GRAFANA_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}

EOF

chmod 600 /opt/monitoring/.env


# --------------------------------------------------
# 11. Docker Compose
# --------------------------------------------------

cat > /opt/monitoring/docker-compose.yml <<'EOF'

services:

  # -----------------------------------------------
  # Prometheus
  # -----------------------------------------------

  prometheus:

    image: prom/prometheus:v3.5.0

    container_name: prometheus

    restart: unless-stopped

    ports:
      - "127.0.0.1:9090:9090"

    volumes:
      - /opt/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus

    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=15d"


  # -----------------------------------------------
  # Grafana
  # -----------------------------------------------

  grafana:

    image: grafana/grafana:12.1.1

    container_name: grafana

    restart: unless-stopped

    ports:
      - "3000:3000"

    environment:

      GF_SECURITY_ADMIN_USER: admin

      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_ADMIN_PASSWORD}

      GF_USERS_ALLOW_SIGN_UP: "false"

      GF_AUTH_ANONYMOUS_ENABLED: "false"

    volumes:

      - grafana-data:/var/lib/grafana

      - /opt/monitoring/grafana/provisioning:/etc/grafana/provisioning:ro

      - /opt/monitoring/grafana/dashboards:/var/lib/grafana/dashboards:ro

    depends_on:
      - prometheus


  # -----------------------------------------------
  # Node Exporter
  # -----------------------------------------------

  node-exporter:

    image: prom/node-exporter:v1.9.1

    container_name: node-exporter

    restart: unless-stopped

    ports:
      - "9100:9100"

    command:
      - "--path.rootfs=/host"

    volumes:
      - "/:/host:ro,rslave"


# -------------------------------------------------
# Persistent volumes
# -------------------------------------------------

volumes:

  prometheus-data:

  grafana-data:

EOF


# --------------------------------------------------
# 12. Set permissions
# --------------------------------------------------

chmod 755 /opt/monitoring
chmod 644 /opt/monitoring/prometheus/prometheus.yml
chmod 644 /opt/monitoring/docker-compose.yml

chmod 755 /opt/monitoring/grafana
chmod 755 /opt/monitoring/grafana/provisioning
chmod 755 /opt/monitoring/grafana/provisioning/datasources
chmod 755 /opt/monitoring/grafana/provisioning/dashboards


# --------------------------------------------------
# 13. Start monitoring stack
# --------------------------------------------------

cd /opt/monitoring

docker compose pull

docker compose up -d


# --------------------------------------------------
# 14. Wait for containers
# --------------------------------------------------

echo "Waiting for monitoring containers..."

sleep 20


# --------------------------------------------------
# 15. Show container status
# --------------------------------------------------

docker ps


# --------------------------------------------------
# 16. Verify Prometheus
# --------------------------------------------------

echo "Checking Prometheus..."

for i in {1..30}; do

    if curl -fs http://127.0.0.1:9090/-/ready > /dev/null 2>&1; then

        echo "Prometheus is ready."

        break

    fi

    echo "Waiting for Prometheus..."

    sleep 2

done


# --------------------------------------------------
# 17. Verify Grafana
# --------------------------------------------------

echo "Checking Grafana..."

for i in {1..30}; do

    if curl -fs http://127.0.0.1:3000/api/health > /dev/null 2>&1; then

        echo "Grafana is ready."

        break

    fi

    echo "Waiting for Grafana..."

    sleep 2

done


# --------------------------------------------------
# 18. Verify Node Exporter
# --------------------------------------------------

echo "Checking Node Exporter..."

if curl -fs http://127.0.0.1:9100/metrics > /dev/null 2>&1; then

    echo "Node Exporter is ready."

else

    echo "WARNING: Node Exporter health check failed."

fi


# --------------------------------------------------
# 19. Display final status
# --------------------------------------------------

echo "=========================================="
echo "Monitoring Bootstrap Completed"
echo "=========================================="

docker ps

echo ""
echo "Grafana health:"
curl -s http://127.0.0.1:3000/api/health || true

echo ""
echo "Prometheus readiness:"
curl -s http://127.0.0.1:9090/-/ready || true

echo ""
echo "Monitoring bootstrap completed successfully."
