
# SSM Patch Baseline
resource "aws_ssm_patch_baseline" "al2_kernel_live_patch" {
  name             = "AL2-KernelLivePatching-Baseline"
  operating_system = "AMAZON_LINUX_2"
  description      = "Baseline for AL2 Kernel Live Patching"

  approval_rule {
    approve_after_days = 0
    patch_filter {
      key    = "PRODUCT"
      values = ["*"]
    }
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix"]
    }
    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}

# Patch group
resource "aws_ssm_patch_group" "kernel_live_patch" {
  baseline_id = aws_ssm_patch_baseline.al2_kernel_live_patch.id
  patch_group = "AL2-KernelLivePatch"
}

# Maintenance Window
resource "aws_ssm_maintenance_window" "kernel_live_patch" {
  name                = "KernelLivePatch-Window"
  schedule            = var.maintenance_schedule
  duration            = "2"
  cutoff             = "1"
  allow_unassociated_targets = true
}

# Maintenance Window Target
resource "aws_ssm_maintenance_window_target" "kernel_live_patch" {
  window_id = aws_ssm_maintenance_window.kernel_live_patch.id
  name      = "AL2-KernelLivePatch-Targets"
  resource_type  = "INSTANCE"
  
  targets {
    key    = "tag:Patch Group"
    values = ["AL2-KernelLivePatch"]
  }
}

# IAM Role for Maintenance Window
resource "aws_iam_role" "maintenance_window_role" {
  name = "ssm-maintenance-window-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "maintenance_window_policy" {
  role       = aws_iam_role.maintenance_window_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# Maintenance Window Task
resource "aws_ssm_maintenance_window_task" "kernel_live_patch" {
  window_id        = aws_ssm_maintenance_window.kernel_live_patch.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  service_role_arn = aws_iam_role.maintenance_window_role.arn
  priority         = 1
  max_concurrency  = "100%"
  max_errors       = "10%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.kernel_live_patch.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["NoReboot"]
      }
    }
  }
}

# SSM Document for Kernel Live Patch Setup
resource "aws_ssm_document" "enable_kernel_live_patch" {
  name            = "Enable-KernelLivePatch-AL2"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Enable Kernel Live Patching on Amazon Linux 2'
parameters: {}
mainSteps:
  - action: aws:runShellScript
    name: EnableKernelLivePatch
    inputs:
      runCommand:
        - sudo yum install -y kpatch-runtime
        - sudo yum install -y yum-plugin-kernel-livepatch
        - sudo systemctl enable kpatch.service
        - sudo systemctl start kpatch.service
        - sudo amazon-linux-extras enable kernel-livepatch
        - sudo yum install -y kernel-livepatch
DOC
}
