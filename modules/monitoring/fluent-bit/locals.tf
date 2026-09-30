############################################
# Fluent Bit Locals
############################################

locals {

  name_prefix = "${var.project_name}-${var.environment}-fluent-bit"

  common_tags = merge(
    var.common_tags,
    {
      Component = "FluentBit"
      ManagedBy = "Terraform"
    }
  )

}
