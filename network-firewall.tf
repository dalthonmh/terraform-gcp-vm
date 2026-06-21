###################################
## Network Firewall Rules - Main ##
###################################

# Allow HTTP (port 80) - for the Nginx web server
resource "google_compute_firewall" "allow-http" {
  name        = "${var.app_name}-${var.environment}-fw-allow-http"
  description = "Allow HTTP traffic from anywhere (demo purposes)"
  network     = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

# Allow HTTPS (port 443)
resource "google_compute_firewall" "allow-https" {
  name        = "${var.app_name}-${var.environment}-fw-allow-https"
  description = "Allow HTTPS traffic from anywhere"
  network     = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}

# Allow SSH (port 22)
# WARNING: For production, restrict source_ranges to your IP or use IAP / bastion
resource "google_compute_firewall" "allow-ssh" {
  name        = "${var.app_name}-${var.environment}-fw-allow-ssh"
  description = "Allow SSH access (consider restricting source IP in production)"
  network     = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# RDP rule removed - not needed for Linux Debian VM
# If you need Windows instances in future, create a separate rule with restricted sources.
