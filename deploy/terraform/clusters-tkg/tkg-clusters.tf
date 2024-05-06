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
      version = "1.4.4"
    }
  }
}

locals {
  tkgs_cluster_variables = {
    "controlPlaneCertificateRotation" : {
      "activate" : false,
      "daysBefore" : 30
    },
    "defaultStorageClass" : "vsan-default-storage-policy",
    "defaultVolumeSnapshotClass" : "volumesnapshotclass-delete",
    "nodePoolLabels" : [

    ],
    "nodePoolVolumes" : [
      {
        "capacity" : {
          "storage" : "60G"
        },
        "mountPath" : "/var/lib/containerd",
        "name" : "containerd",
        "storageClass" : "vsan-default-storage-policy"
      },
      {
        "capacity" : {
          "storage" : "20G"
        },
        "mountPath" : "/var/lib/kubelet",
        "name" : "kubelet",
        "storageClass" : "vsan-default-storage-policy"
      }
    ],
    "ntp" : "172.16.20.10",
    "storageClass" : "vsan-default-storage-policy",
    "storageClasses" : [
      "vsan-default-storage-policy"
    ],
    "vmClass" : "best-effort-large"
  }

  tkgs_nodepool_a_overrides = {
    "nodePoolLabels" : [
      {
        "key" : "sample-worker-label",
        "value" : "value"
      }
    ],
    "storageClass" : "vsan-default-storage-policy",
    "vmClass" : "guaranteed-2xlarge"
  }
}

provider "tanzu-mission-control" {
  endpoint              = var.endpoint
  vmw_cloud_api_token   = var.vmw_cloud_api_token
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "tkgs_cluster" {
  count = length(var.cluster_names)
  management_cluster_name = var.management_cluster_name
  provisioner_name        = var.provisioner_name
  name                    = var.cluster_names[count.index]

  spec {
    cluster_group_name = "gartner-cm-mq-2024-datacenter"

    topology {
      version           = "v1.26.5+vmware.2-fips.1-tkg.1"
      cluster_class     = "tanzukubernetescluster"
      cluster_variables = jsonencode(local.tkgs_cluster_variables)

      control_plane {
        replicas = 1

        os_image {
          name    = "photon"
          version = "3"
          arch    = "amd64"
        }
      }

      nodepool {
        name        = "md-0"
        description = "simple small md"

        spec {
          worker_class = "node-pool"
          replicas     = 3
          overrides    = jsonencode(local.tkgs_nodepool_a_overrides)

          os_image {
            name    = "photon"
            version = "3"
            arch    = "amd64"
          }
        }
      }

      network {
        pod_cidr_blocks = [
          "100.96.0.0/11",
        ]
        service_cidr_blocks = [
          "100.64.0.0/13",
        ]
        service_domain = "cluster.local"
      }
    }
  }

  timeout_policy {
    timeout             = 60
    wait_for_kubeconfig = true
    fail_on_timeout     = true
  }
}