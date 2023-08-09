resource "tanzu-mission-control_cluster_group" "create_vsphere_dev_cluster_group" {
  name = "vsphere-lab-dev-group-tf"
  meta {
    description = "Terraform managed cluster group"
    labels = {
      "env" : "dev",
      "using" : "terraform"
      "hosted-by" : "vSphere"
      "region" : "Washington"
    }
  }
}


resource "tanzu-mission-control_cluster_group" "create_eks_dev_cluster_group" {
  name = "eks-dev-group-tf"
  meta {
    description = "Terraform managed cluster group"
    labels = {
      "env" : "dev",
      "using" : "terraform"
      "hosted-by" : "AWS"
      "region" : "us-west-2"
    }
  }
}


# Create Tanzu Mission Control Tanzu Kubernetes Grid Service workload cluster entry
resource "tanzu-mission-control_cluster" "create_tkgs_workload" {
  management_cluster_name = "w4-hs3-nimbus-tanzutmm"
  provisioner_name        = "w4-hs3-dev"
  name                    = "dev-vspheretanzu-tf"

  meta {
    labels = { 
      "env" : "dev",
      "using" : "terraform",
      "hosted-by" : "vSphere",
      "region" : "Washington"
      }
  }

  spec {
    cluster_group = "vsphere-lab-dev-group-tf"
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
        version = "v1.21.6+vmware.1-tkg.1.b3d708a"
      }

      topology {
        control_plane {
          class         = "best-effort-large"
          storage_class = "vsan-default-storage-policy"
          # storage class is either `vsan-default-storage-policy` or `gc-storage-profile`
          high_availability = false
          volumes {
            capacity          = 40
            mount_path        = "/var/lib/etcd"
            name              = "etcd-0"
            pvc_storage_class = "vsan-default-storage-policy"
          }
        }
        node_pools {
          spec {
            worker_node_count = "3"
            cloud_label = {
              "key1" : "val1"
            }
            node_label = {
              "key2" : "val2"
            }

            tkg_service_vsphere {
              class         = "best-effort-large"
              storage_class = "vsan-default-storage-policy"
              # storage class is either `vsan-default-storage-policy` or `gc-storage-profile`
              volumes {
                capacity          = 40
                mount_path        = "/var/lib/containerd"
                name              = "containerd-0"
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

