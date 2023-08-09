variable "endpoint" {
    type = string
    sensitive = true
}

variable "vmw_cloud_api_token" {
    type = string
    sensitive = true
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
      version = "1.1.4"
    }
  }
}

provider "tanzu-mission-control" {
  endpoint              = var.endpoint
  vmw_cloud_api_token   = var.vmw_cloud_api_token
}

# Create Tanzu Mission Control Tanzu Kubernetes Grid Service workload cluster entry
resource "tanzu-mission-control_cluster" "create_tkgs_workload" {
  count = length(var.cluster_names)
  management_cluster_name = var.management_cluster_name
  provisioner_name        = var.provisioner_name
  name                    = var.cluster_names[count.index]

  meta {
    labels = { "env" : "tko-tsm-demo",
               "source" : "terraform" }
  }

  spec {
    cluster_group = "rogerssc-demo-clusters"
    tkg_service_vsphere {
      settings {
        network {
          pods {
            cidr_blocks = [
              "172.20.0.0/16", # pods cidr block by default has the value `172.20.0.0/16`
            ]
          }
          services {
            cidr_blocks = [
              "10.96.0.0/16", # services cidr block by default has the value `10.96.0.0/16`
            ]
          }
        }
        storage {
          classes = [
            "vsan-default-storage-policy",
          ]
          default_class = "vsan-default-storage-policy"
        }
      }

      distribution {
        version = "v1.23.8+vmware.3-tkg.1.ubuntu"
      }

      topology {
        control_plane {
          class         = "guaranteed-2xlarge"
          storage_class = "vsan-default-storage-policy"
          high_availability = false
          volumes {
            capacity          = 4
            mount_path        = "/var/lib/etcd"
            name              = "etcd-0"
            pvc_storage_class = "vsan-default-storage-policy"
          }
        }
        node_pools {
          spec {
            worker_node_count = "4"
            cloud_label = {
              "key1" : "val1"
            }
            node_label = {
              "key2" : "val2"
            }

            tkg_service_vsphere {
              class         = "guaranteed-2xlarge"
              storage_class = "vsan-default-storage-policy"
              # storage class is either `wcpglobal-storage-profile` or `gc-storage-profile`
              volumes {
                capacity          = 3
                mount_path        = "/var/lib/etcd"
                name              = "etcd-0"
                pvc_storage_class = "vsan-default-storage-policy"
              }
            }
          }
          info {
            name        = "default-nodepool" # default node pool name `default-nodepool`
            description = "tkgs workload nodepool"
          }
        }
      }
    }
  }
}

# Create Tanzu Mission Control namespace with attached set as default value.
resource "tanzu-mission-control_namespace" "create_namespace" {
  count = length(var.cluster_names)
  management_cluster_name = var.management_cluster_name
  provisioner_name        = var.provisioner_name
  cluster_name            = var.cluster_names[count.index]
  name                    = "tko-demo" # Required

  meta {
    description = "Create namespace through terraform"
    labels      = { "key" : "value" }
  }

  spec {
    workspace_name = "default" # Default: 
  }
}
    