variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "alert_email" {
  type        = string
  default     = "harshlk11101@gmail.com"
  description = "The email to send the alerts"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "The environment "
}