###########################
## GCP Linux VM - Output ##
###########################

output "vm_name" {
  description = "Name of the created VM instance"
  value       = google_compute_instance.vm_instance_public.name
}

output "vm_external_ip" {
  description = "External (public) IP address of the VM"
  value       = google_compute_instance.vm_instance_public.network_interface[0].access_config[0].nat_ip
}

output "vm_internal_ip" {
  description = "Internal (private) IP address of the VM"
  value       = google_compute_instance.vm_instance_public.network_interface[0].network_ip
}

output "ssh_command" {
  description = "Example command to SSH into the instance"
  value       = "gcloud compute ssh ${google_compute_instance.vm_instance_public.name} --zone=${google_compute_instance.vm_instance_public.zone} --project=${var.gcp_project}"
}
