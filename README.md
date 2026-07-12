# Terraform GCP Debian 13 VM

Spins up a Debian 13 VM on Google Cloud: a custom VPC, firewall rules (SSH + HTTP), and Nginx installed automatically.

## Requirements

- [Terraform](https://www.terraform.io/downloads) ≥ 1.6
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- A GCP project with **billing enabled**

## 1. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at least:

```hcl
gcp_project = "my-project-123456"   # Project ID, not the numeric project number
gcp_region  = "us-central1"
gcp_zone    = "us-central1-a"
```

Not sure of your Project ID? Run `gcloud projects list`.

## 2. Authenticate

```bash
gcloud auth application-default login
```

Leave `gcp_auth_file = ""` in `terraform.tfvars` (default). Terraform will use your `gcloud` login automatically.

## 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

Terraform enables the required GCP APIs for you — no manual `gcloud services enable` needed.

## 4. Use it

```bash
terraform output vm_external_ip   # open in a browser to see the Nginx welcome page
terraform output -raw ssh_command # ready-made SSH command
```

## 5. Tear down

```bash
terraform destroy
```

## Troubleshooting

**403 / API disabled errors** — usually means billing isn't linked yet. Link it at [console.cloud.google.com/billing](https://console.cloud.google.com/billing), then re-run `terraform apply`.

**"project not found"** — you probably used the project _number_ instead of the project _ID_. Check with `gcloud projects list`.

## Notes

- `e2-micro` (the default) is free-tier eligible in most regions.
- Firewall rules allow `0.0.0.0/0` for demo simplicity — restrict this before using in production.
- Never commit `terraform.tfvars` or service account keys.
