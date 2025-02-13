output "maintenance_window_id" {
  description = "ID of the created maintenance window"
  value       = aws_ssm_maintenance_window.kernel_live_patch.id
}

output "patch_baseline_id" {
  description = "ID of the created patch baseline"
  value       = aws_ssm_patch_baseline.al2_kernel_live_patch.id
}

output "ssm_document_name" {
  description = "Name of the SSM document for kernel live patch setup"
  value       = aws_ssm_document.enable_kernel_live_patch.name
}
