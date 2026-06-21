# ============================================================
# Application Definition
# ============================================================
company     = "mycompany"
app_name    = "demo-vm"
app_domain  = "example.com"
environment = "dev"

# ============================================================
# GCP Settings (update with your values)
# ============================================================
gcp_project = "your-gcp-project-id"
gcp_region  = "europe-west4"
gcp_zone    = "europe-west4-b"

# Path to key OR leave empty to use ADC (gcloud auth application-default login)
gcp_auth_file = ""

# ============================================================
# Network
# ============================================================
network-subnet-cidr = "10.10.10.0/24"

# ============================================================
# Linux VM
# ============================================================
linux_instance_type = "e2-micro"
