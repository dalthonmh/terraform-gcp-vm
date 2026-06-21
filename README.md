# Terraform GCP Debian 13 VM

Deploy a simple Debian 13 (Trixie) virtual machine on Google Cloud Platform using Terraform.

The configuration creates:
- A custom VPC + subnet
- Firewall rules (HTTP, HTTPS, SSH)
- A Debian 13 VM with Nginx installed via startup script
- Public IP + basic outputs

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.6
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install)
- A GCP project with billing enabled
- Compute Engine API enabled in your project

## Authentication (Service Account)

1. Create a service account for Terraform:

```bash
gcloud iam service-accounts create terraform \
  --display-name "Terraform" \
  --project YOUR_PROJECT_ID
```

2. Grant necessary roles (least privilege recommended):

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

3. Create and download a JSON key:

```bash
gcloud iam service-accounts keys create ../auth/terraform-key.json \
  --iam-account=terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

4. Enable required APIs:

```bash
gcloud services enable compute.googleapis.com --project YOUR_PROJECT_ID
```

> Alternative (recommended for local dev): Run `gcloud auth application-default login` and leave `gcp_auth_file = ""` (or remove the line). The provider now supports both methods.

## Quick Start

1. **Clone and enter the directory**

2. **Copy example variables**

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. **Edit `terraform.tfvars`** and set your values:
   - `gcp_project`
   - `gcp_auth_file` (path to your JSON key)
   - Region / zone
   - Any other customizations

4. **Initialize Terraform**

```bash
terraform init
```

5. **Review the execution plan**

```bash
terraform plan
```

6. **Deploy**

```bash
terraform apply
```

Type `yes` when prompted.

7. **Access your VM**

After apply succeeds, Terraform will print the outputs:

- `vm_external_ip` → Open in browser: `http://<IP>` (Nginx welcome page)
- `ssh_command` → Or use:

```bash
gcloud compute ssh <vm-name> --zone=<zone> --project=<project>
```

## Useful Commands

```bash
# Show outputs again
terraform output

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Destroy everything (cleanup)
terraform destroy
```

## File Structure

| File                        | Purpose                              |
|-----------------------------|--------------------------------------|
| `provider-main.tf`          | Terraform + Google provider config   |
| `provider-variables.tf`     | GCP auth / project / region vars     |
| `app-variables.tf`          | Common naming variables              |
| `network-main.tf`           | VPC + Subnet                         |
| `network-variables.tf`      | Subnet CIDR                          |
| `network-firewall.tf`       | Firewall rules (HTTP/SSH)            |
| `linux-vm-main.tf`          | VM + startup script (Nginx)          |
| `linux-vm-variables.tf`     | Machine type                         |
| `linux-vm-output.tf`        | VM name, IPs, SSH command            |
| `debian-versions.tf`        | Debian 13 (Trixie) image family      |
| `terraform.tfvars.example`  | Safe example to copy                 |

## Improvements Made

- Updated to **Terraform ~> 1.6** and **Google provider ~> 7.0**
- Uses **Debian 13 (Trixie)** by default (`debian-cloud/debian-13`)
- Replaced deprecated `f1-micro` → `e2-micro`
- Removed deprecated `template_file` data source
- Added resource labels and `deletion_protection`
- Cleaner outputs and documentation
- Added `terraform.tfvars.example` + improved `.gitignore`

## Cost & Security Notes

- `e2-micro` in supported regions can be free tier eligible.
- Firewall rules open SSH and HTTP to `0.0.0.0/0` — restrict in production.
- Never commit real service account keys.

## References

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Compute Engine VM images](https://cloud.google.com/compute/docs/images)

