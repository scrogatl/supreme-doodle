resource "rafay_eks_cluster" "ekscluster-basic" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "eks-cluster-1"
      project = "terraform"
    }
    spec {
      type              = "eks"
      blueprint         = "default"
      blueprint_version = "Latest"
      cloud_provider    = "aws-eks-role"
      cni_provider      = "aws-cni"
      proxy_config      = {}
    }
  }
  cluster_config {
    apiversion = "rafay.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata {
      name    = "eks-cluster-1"
      region  = "us-west-2"
      version = "1.22"
    }
    iam {
      with_oidc = true
      service_accounts {
        metadata {
          name      = "test-irsa"
          namespace = "yaml1"
        }
        attach_policy = <<EOF
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "ec2:Describe*",
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": "ec2:AttachVolume",
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": "ec2:DetachVolume",
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": ["elasticloadbalancing:*"],
              "Resource": ["*"]
            } 
          ]
        }
        EOF
      }
    }


    vpc {
      cidr = "192.168.0.0/16"
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
      nat {
        gateway = "Single"
      }
    }
    node_groups {
      name       = "ng-1"
      ami_family = "AmazonLinux2"
      iam {
        iam_node_group_with_addon_policies {
          image_builder = true
          auto_scaler   = true
        }
      }
      instance_type      = "m5.xlarge"
      desired_capacity   = 1
      min_size           = 1
      max_size           = 2
      max_pods_per_node  = 50
      version            = "1.22"
      volume_size        = 80
      volume_type        = "gp3"
      private_networking = true
      labels = {
        app       = "infra"
        dedicated = "true"
      }
    }
  }
}

resource "rafay_eks_cluster" "ekscluster-advanced" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "eks-cluster-2"
      project = "terraform"
    }
    spec {
      type              = "eks"
      blueprint         = "default"
      blueprint_version = "1.21.0"
      cloud_provider    = "eks-role"
      cni_provider      = "aws-cni"
      proxy_config      = {}
      system_components_placement {
        node_selector = {
          app       = "infra"
          dedicated = "true"
        }
        tolerations {
          effect   = "NoExecute"
          key      = "app"
          operator = "Equal"
          value    = "infra"
        }
        tolerations {
          effect   = "NoSchedule"
          key      = "dedicated"
          operator = "Equal"
          value    = true
        }
        daemonset_override {
          node_selection_enabled = false
          tolerations {
            key      = "app1dedicated"
            value    = true
            effect   = "NoSchedule"
            operator = "Equal"
          }
        }
      }
    }
  }
  cluster_config {
    apiversion = "rafay.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata {
      name    = "eks-cluster-2"
      region  = "us-west-2"
      version = "1.21"
    }
    vpc {
      subnets {
        private {
          name = "private-01"
          id   = "private-subnet-id-0"
        }
        private {
          name = "private-02"
          id   = "private-subnet-id-0"
        }
        public {
          name = "public-01"
          id   = "public-subnet-id-0"
        }
        public {
          name = "public-02"
          id   = "public-subnet-id-0"
        }
      }
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
    }
    managed_nodegroups {
      name       = "managed-ng-1"
      ami_family = "AmazonLinux2"
      iam {
        instance_role_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/role_name"
      }
      instance_type     = "m5.xlarge"
      desired_capacity  = 1
      min_size          = 1
      max_size          = 2
      max_pods_per_node = 50
      labels = {
        app       = "infra"
        dedicated = "true"
      }
      taints {
        key    = "app"
        value  = "infra"
        effect = "NoExecute"
      }
      taints {
        key    = "dedicated"
        value  = true
        effect = "NoSchedule"
      }
      security_groups {
        attach_ids = ["sg-id-1", "sg-id-2"]
      }
      subnets            = ["subnet-id-1", "subnet-id-2"]
      version            = "1.21"
      volume_size        = 80
      volume_type        = "gp3"
      volume_iops        = 3000
      volume_throughput  = 125
      private_networking = true
    }
  }
}

resource "rafay_eks_cluster" "ekscluster-custom-cni" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "eks-cluster-3"
      project = "terraform"
    }
    spec {
      type              = "eks"
      blueprint         = "default"
      blueprint_version = "1.21.0"
      cloud_provider    = "eks-role"
      cni_provider      = "aws-cni"
      cni_params {
        custom_cni_crd_spec {
          name = "us-west-2a"
          cni_spec {
            security_groups = ["sg-xxxxxx", "sg-yyyyyy"]
            subnet          = "subnet-zzz"
          }
          cni_spec {
            security_groups = ["sg-cccccc", "sg-dddddd"]
            subnet          = "subnet-kkk"
          }
        }
        custom_cni_crd_spec {
          name = "us-west-2b"
          cni_spec {
            security_groups = ["sg-aaaaaa", "sg-xxxxxx"]
            subnet          = "subnet-qqq"
          }
          cni_spec {
            security_groups = ["sg-cccccc", "sg-dddddd"]
            subnet          = "subnet-www"
          }
        }
      }
      proxy_config = {}
    }
  }
  cluster_config {
    apiversion = "rafay.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata {
      name    = "eks-cluster-1"
      region  = "us-west-2"
      version = "1.21"
    }
    vpc {
      cidr = "192.168.0.0/16"
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
      nat {
        gateway = "Single"
      }
    }
    node_groups {
      name       = "ng-1"
      ami_family = "AmazonLinux2"
      iam {
        iam_node_group_with_addon_policies {
          image_builder = true
          auto_scaler   = true
        }
      }
      instance_type      = "m5.xlarge"
      desired_capacity   = 1
      min_size           = 1
      max_size           = 2
      max_pods_per_node  = 50
      version            = "1.21"
      volume_size        = 80
      volume_type        = "gp3"
      private_networking = true
    }
  }
}

resource "rafay_eks_cluster" "ekscluster-basic-im" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "eks-cluster-4"
      project = "terraform"
    }
    spec {
      type              = "eks"
      blueprint         = "default"
      blueprint_version = "Latest"
      cloud_provider    = "eks-role"
      cni_provider      = "aws-cni"
      proxy_config      = {}
    }
  }
  cluster_config {

    kind = "ClusterConfig"
    metadata {
      name    = "eks-cluster-4"
      region  = "us-west-2"
      version = "1.22"
    }

    vpc {
      cidr = "192.168.0.0/16"
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
      nat {
        gateway = "Single"
      }
    }
    identity_mappings {
      arns {
        arn      = "arn:aws:iam::<AWS_ACCOUNT_ID>:user/<USERNAME>"
        group    = ["groupname"]
        username = "user"
      }
    }
    node_groups {
      name       = "ng-1"
      ami_family = "AmazonLinux2"
      iam {
        iam_node_group_with_addon_policies {
          image_builder = true
          auto_scaler   = true
        }
      }
      instance_type      = "t3.xlarge"
      desired_capacity   = 1
      min_size           = 1
      max_size           = 2
      max_pods_per_node  = 50
      version            = "1.22"
      volume_size        = 80
      volume_type        = "gp3"
      private_networking = true
    }
  }
}


resource "rafay_eks_cluster" "ekscluster-basic-with-ipv6" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "ekscluster-basic-with-ipv6"
      project = "defaultproject"
    }
    spec {
      type           = "eks"
      blueprint      = "minimal"
      cloud_provider = "aws"
      cni_provider   = "aws-cni"
      proxy_config   = {}
    }
  }
  cluster_config {
    apiversion = "rafay.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata {
      name    = "ekscluster-basic-with-ipv6"
      region  = "us-west-2"
      version = "1.26"
    }
    kubernetes_network_config {
      ip_family = "IPv6"
    }
    iam {
      with_oidc = true
    }

    vpc {
      cluster_endpoints {
        private_access = true
        public_access  = true
      }
    }
    managed_nodegroups {
      name             = "ng1"
      instance_type    = "t3.medium"
      desired_capacity = 3
      min_size         = 0
      max_size         = 4
      volume_size      = 80
      volume_type      = "gp3"
      version          = "1.26"
    }
    managed_nodegroups {
      name             = "ng2"
      instance_type    = "t3.medium"
      desired_capacity = 2
      min_size         = 0
      max_size         = 3
      volume_size      = 80
      volume_type      = "gp3"
      version          = "1.26"
    }

    addons {
      name    = "vpc-cni"
      version = "latest"
    }
    addons {
      name    = "kube-proxy"
      version = "latest"
    }
    addons {
      name    = "coredns"
      version = "latest"
    }
  }
}
