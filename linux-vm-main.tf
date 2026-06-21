#########################
## GCP Linux VM - Main ##
#########################

# Random suffix for unique resource names
resource "random_id" "instance_id" {
  byte_length = 4
}

locals {
  vm_name = "${lower(var.company)}-${lower(var.app_name)}-${var.environment}-vm${random_id.instance_id.hex}"
}

# Create VM
resource "google_compute_instance" "vm_instance_public" {
  name         = local.vm_name
  machine_type = var.linux_instance_type
  zone         = var.gcp_zone
  hostname     = "${var.app_name}-vm${random_id.instance_id.hex}.${var.app_domain}"
  tags         = ["ssh", "http"]

  labels = {
    environment = var.environment
    app         = var.app_name
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = var.debian_13_sku
    }
  }

  # Startup script installs Nginx and creates a simple welcome page (works on Debian)
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -yq nginx
    systemctl enable nginx
    systemctl start nginx

    # Custom index page (values injected by Terraform where known at apply time)
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Terraform GCP VM</title>
      <style>
        body { font-family: system-ui, sans-serif; max-width: 700px; margin: 40px auto; padding: 20px; }
        .info { background: #f0f0f0; padding: 16px; border-radius: 8px; }
      </style>
    </head>
    <body>
      <h1>🚀 Hello from Terraform on GCP!</h1>
      <p>This VM was provisioned with Terraform.</p>
      <div class="info">
        <p><strong>Environment:</strong> ${var.environment}</p>
        <p>Check Terraform outputs for the exact instance name and IP.</p>
      </div>
    </body>
    </html>
    HTML
  EOT

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {}
  }

  # Prevent accidental deletion in production (set to true if needed)
  deletion_protection = false

  # Allow Terraform to stop/start for updates if required
  allow_stopping_for_update = true
}
