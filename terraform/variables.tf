variable "kubernetes_version" {
  default = "1.20"
}

variable "env_prefix" {
  description = "A prefix for the environment name."
  type        = string
  default     = "dev"
}