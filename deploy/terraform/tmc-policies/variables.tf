variable "endpoint" {
  description = "The Tanzu Mission Control service endpoint hostname"
  type        = string
}

variable "vmw_cloud_api_token" {
  description = "The VMware Cloud Services API Token"
  type        = string
  default     = ""
}