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
- **A GCP project with billing enabled** (required to activate Compute Engine API)
- Compute Engine API enabled in your project (Terraform can enable it after billing is linked)

## Set Variables (Recommended)

Set these variables **once** so you can copy and paste all commands without manually replacing values.

```bash
# === UPDATE THESE VALUES ===
PROJECT_ID="my-project-123456"
REGION="europe-west4"
ZONE="europe-west4-b"
```

**How to find your Project ID:**

```bash
gcloud projects list
gcloud config get-value project
```

After setting the variables, use the **same values** in your `terraform.tfvars`:

```hcl
gcp_project = "my-project-123456"
gcp_region  = "europe-west4"
gcp_zone    = "europe-west4-b"
```

## Authentication (Service Account)

Use the `$PROJECT_ID` variable you defined above.

1. Create a service account for Terraform:

```bash
gcloud iam service-accounts create terraform \
  --display-name "Terraform" \
  --project $PROJECT_ID
```

2. Grant necessary roles (least privilege recommended):

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

> If you want Terraform (via the service account key) to be able to automatically enable the required APIs, also add:
>
> ```bash
> gcloud projects add-iam-policy-binding $PROJECT_ID \
>   --member="serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
>   --role="roles/serviceusage.serviceUsageAdmin"
> ```
>
> For everyday local development, prefer `gcloud auth application-default login` and set `gcp_auth_file = ""`.

3. Create and download a JSON key:

```bash
gcloud iam service-accounts keys create ../auth/terraform-key.json \
  --iam-account=terraform@${PROJECT_ID}.iam.gserviceaccount.com
```

4. **Enable required APIs** (run this **after** linking a billing account):

```bash
# Enable foundational + required APIs
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  --project $PROJECT_ID

# Verify
gcloud services list --enabled --project $PROJECT_ID \
  --filter="config.name~cloudresourcemanager|serviceusage|compute|iam"
```

> **Alternative (recommended for local dev)**: Run `gcloud auth application-default login` and leave `gcp_auth_file = ""` (or remove the line). The provider supports both service account keys and Application Default Credentials (ADC).

> **Important**: If you get a billing error when enabling APIs, go to the [Google Cloud Console Billing](https://console.cloud.google.com/billing), select your project (`$PROJECT_ID`) and link a billing account. Even free tier usage requires a billing account attached.

## Quick Start

1. **Clone and enter the directory**

2. **Copy example variables**

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. **Edit `terraform.tfvars`** and set your values (use the same `PROJECT_ID` you defined above):
   - `gcp_project = "my-project-123456"` (use the same value as `$PROJECT_ID`)
   - `gcp_auth_file` (path to your JSON key or leave `""` for ADC)
   - `gcp_region` / `gcp_zone`
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
gcloud compute ssh <vm-name> --zone=$ZONE --project=$PROJECT_ID
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

| File                       | Purpose                              |
| -------------------------- | ------------------------------------ |
| `provider-main.tf`         | Terraform + Google provider config   |
| `provider-variables.tf`    | GCP auth / project / region vars     |
| `apis.tf`                  | Declares required GCP APIs (compute) |
| `app-variables.tf`         | Common naming variables              |
| `network-main.tf`          | VPC + Subnet                         |
| `network-variables.tf`     | Subnet CIDR                          |
| `network-firewall.tf`      | Firewall rules (HTTP/SSH)            |
| `linux-vm-main.tf`         | VM + startup script (Nginx)          |
| `linux-vm-variables.tf`    | Machine type                         |
| `linux-vm-output.tf`       | VM name, IPs, SSH command            |
| `debian-versions.tf`       | Debian 13 (Trixie) image family      |
| `terraform.tfvars.example` | Safe example to copy                 |

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

## Troubleshooting

### "Compute Engine API has not been used..." or "Cloud Resource Manager API has not been used..." (Error 403 SERVICE_DISABLED)

This happens when required GCP APIs are disabled. The two most common cases:

1. **Billing is not linked** to the project (still the #1 cause).
   - Go to https://console.cloud.google.com/billing
   - Select your project (`$PROJECT_ID`) and link a billing account.

2. **Foundational APIs not enabled**.
   Cloud Resource Manager and Service Usage are required for Terraform to manage other APIs.

   ```bash
   gcloud services enable \
     cloudresourcemanager.googleapis.com \
     serviceusage.googleapis.com \
     compute.googleapis.com \
     iam.googleapis.com \
     --project $PROJECT_ID
   ```

   Wait 30-60 seconds and retry Terraform.

3. You are using the **numeric project number** instead of the Project ID in `gcp_project`.

4. Using a service account key without enough permissions.
   - Prefer `gcloud auth application-default login` + `gcp_auth_file = ""` for local work.

After enabling, run:

```bash
terraform init
terraform apply     # or terraform destroy
```

#### Problem destroying (`terraform destroy`) because of disabled APIs

If Terraform can't even read the `google_project_service` resources during destroy:

1. Enable the bootstrap APIs:

   ```bash
   gcloud services enable \
     cloudresourcemanager.googleapis.com \
     serviceusage.googleapis.com \
     --project $PROJECT_ID
   ```

2. If it's still stuck, temporarily remove the service resources from state (safe because we use `disable_on_destroy = false`):

   ```bash
   terraform state rm 'google_project_service.bootstrap' || true
   terraform state rm 'google_project_service.required' || true
   terraform destroy
   ```

   You can re-add the API resources on a future apply if needed.

### Other common issues

- `Invalid value for "credentials"`: the path in `gcp_auth_file` is wrong or the file was deleted.
- Permission errors on the service account: re-run the `gcloud projects add-iam-policy-binding` commands from the Authentication section.
- Region/zone not available for the machine type: try `europe-west4` or `us-central1`.

## References

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Compute Engine VM images](https://cloud.google.com/compute/docs/images)
