variable "endpoint" {
    type = string
}

variable "vmw_cloud_api_token" {
    type = string
}

variable "management_cluster_name" {
    type = string
}

variable "provisioner_name" {
    type = string
}

variable "cluster_names" {
  description = "K8S Cluster Names"
  type        = list(string)
}

terraform {
  required_providers {
    tanzu-mission-control = {
      source = "vmware/tanzu-mission-control"
      version = "1.1.7"
    }
  }
}

provider "tanzu-mission-control" {
  endpoint              = var.endpoint
  vmw_cloud_api_token   = var.vmw_cloud_api_token
}

resource "tanzu-mission-control_integration" "create_tsm-integration" {
  count = length(var.cluster_names)
  management_cluster_name = var.management_cluster_name
  provisioner_name        = var.provisioner_name
  cluster_name            = format("eks.rogerssc-eks-10.us-east-2.%s",var.cluster_names[count.index])
  integration_name        = "tanzu-service-mesh"

  spec {
    configurations = jsonencode({
      enableNamespaceExclusions = true
      namespaceExclusions = [
        {
          match = "tanzu"
          type  = "START_WITH"
        }
      ]
    })
  }
}