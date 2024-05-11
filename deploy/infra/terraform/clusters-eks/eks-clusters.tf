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

variable "arn_control" {
    type = string
}

variable "arn_worker" {
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
      version = "1.3.0"
    }
  }
}

provider "tanzu-mission-control" {
  endpoint              = var.endpoint
  vmw_cloud_api_token   = var.vmw_cloud_api_token
}

# Create a Tanzu Mission Control AWS EKS cluster entry
resource "tanzu-mission-control_ekscluster" "tf_eks_cluster" {
  credential_name = "rogerssc-eks-31"          // Required
  region          = "us-east-2"         // Required
  count           = length(var.cluster_names)
  name            = var.cluster_names[count.index]

  ready_wait_timeout = "30m" // Wait time for cluster operations to finish (default: 30m).

  meta {
    description = "eks test cluster"
    labels      = { "source" : "terraform" }
  }

  spec {
    cluster_group = "rogerssc-demo-clusters" // Default: default
    #proxy          = "<proxy>"              // Proxy if used

    config {
      role_arn = var.arn_control

      kubernetes_version = "1.26" // Required
      tags               = { "tagkey" : "tagvalue" }

      kubernetes_network_config {
        service_cidr = "10.100.0.0/16" // Forces new
      }

      logging {
        api_server         = false
        audit              = true
        authenticator      = true
        controller_manager = false
        scheduler          = true
      }

      vpc { // Required
        enable_private_access = false
        enable_public_access  = true
        public_access_cidrs = [
          "0.0.0.0/0",
        ]
        # security_groups = [ // Forces new
        #   "",
        # ]
        subnet_ids = [ // Forces new
          "subnet-04a5c86b5cec5c560",
          "subnet-0f87bd9f0f4c624be",
          "subnet-08203dada18acd320",
          "subnet-0d5a812cd39f854b2",
        ]
      }
    }

    nodepool {
      info {
        name        = "np-01"
        description = "tf nodepool description"
      }

      spec {
        role_arn       = var.arn_worker

        ami_type       = "AL2_x86_64"
        # capacity_type  = "ON_DEMAND"
        # root_disk_size = 120 // Default: 20GiB
        tags           = { "nptag" : "nptagvalue9" }
        node_labels    = { "nplabelkey" : "nplabelvalue" }

        subnet_ids = [ // Forces new
          "subnet-04a5c86b5cec5c560",
          "subnet-0f87bd9f0f4c624be",
          "subnet-08203dada18acd320",
          "subnet-0d5a812cd39f854b2",
        ]

        scaling_config {
          desired_size = 3
          max_size     = 3
          min_size     = 3
        }

        update_config {
          max_unavailable_nodes = "1"
        }

        instance_types = [
          "m4.xlarge"
        ]

      }
    }
  }
}