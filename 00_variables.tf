variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1" 
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "default_tags" {
  description = "Default tags to use"
  type        = map(string)
  default = {
    CostCenter = "AWSCB"
    CreatedBy  = "OpenTofu"
  }
}

variable "maintenance_schedule" {
  description = "Maintenance Schedule"
  type = string
  default = "cron(0 4 ? * * *)"
}
