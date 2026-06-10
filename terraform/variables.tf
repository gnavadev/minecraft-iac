variable "aws_region" {
  description = "AWS region (Learner Lab supports us-east-1 / us-west-2)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "minecraft"
}

variable "minecraft_port" {
  description = "TCP port the Minecraft server listens on"
  type        = number
  default     = 25565
}

variable "task_cpu" {
  description = "Fargate task CPU units (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 3072
}
