/*
 Cluster group scoped Tanzu Mission Control IAM policy.
 This resource is applied on a cluster group to provision the role bindings on the associated cluster group.
 The defined scope block can be updated to change the access policy's scope.
 */

variable "svc_acct_names" {
  description = "Service Account Names"
  type        = list(string)
  default     = ["system:serviceaccount:avi-system:ako-sa", "system:serviceaccount:service-bindings:controller", "system:serviceaccount:flux-system:default", "system:serviceaccount:tanzu-system-logging:fluent-bit-sa", "system:serviceaccount:services-toolkit:services-toolkit-controller-manager"]
}

variable "group_iam_roles" {
  description = "Service Account Names"
  type        = map
  default     = {
    "sso:platform-ops@vsphere.local" = "clustergroup.admin"
    "sso:platform-auditors@vsphere.local" = "clustergroup.view"
    "sso:lob-1-ops@vsphere.local" = "cluster.edit"
 }
}

resource "tanzu-mission-control_iam_policy" "vsphere_lab_dev_group_cluster_group_scoped_iam" {
  count = length(var.svc_acct_names)
  scope {
    cluster_group {
      name = "vsphere-lab-dev-group-tf"
    }
  }

  
  role_bindings {
    role = "use-privilege-psp"
    subjects {
      name = var.svc_acct_names[count.index]
      kind = "USER"
    }
  }
 
}

resource "tanzu-mission-control_iam_policy" "eks_dev_group_cluster_group_scoped_iam" {
  count = length(var.svc_acct_names)
  scope {
    cluster_group {
      name = "eks-dev-group-tf"
    }
  }

  role_bindings {
    role = "use-privilege-psp"
    subjects {
      name = var.svc_acct_names[count.index]
      kind = "USER"
    }
  }

}

resource "tanzu-mission-control_iam_policy" "vsphere_lab_dev_group_cluster_group_scoped_iam_groups" {
  for_each = var.group_iam_roles
  scope {
    cluster_group {
      name = "vsphere-lab-dev-group-tf"
    }
  }

  
  role_bindings {
    role = "${each.value}"
    subjects {
      name = "${each.key}"
      kind = "GROUP"
    }
  }

}

resource "tanzu-mission-control_iam_policy" "eks_dev_group_cluster_group_scoped_iam_groups" {
  for_each = var.group_iam_roles
  scope {
    cluster_group {
      name = "eks-dev-group-tf"
    }
  }

  
  role_bindings {
    role = "${each.value}"
    subjects {
      name = "${each.key}"
      kind = "GROUP"
    }
  }

}