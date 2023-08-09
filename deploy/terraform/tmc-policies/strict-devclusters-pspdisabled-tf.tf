resource "tanzu-mission-control_security_policy" "strict-vsphere-devclusters-pspdisabled-tf" {
  name = "strict-vsphere-devclusters-pspdisabled-tf"

  /*  scope {
    organization {
      organization = "df467a16-b93a-4360-be75-ffe53d400e41"
    }
  }
*/
  scope {
    cluster_group {
      cluster_group = "vsphere-lab-dev-group-tf"
    }
  }
  spec {
    input {
      strict {
        audit              = true
        disable_native_psp = true
      }
    }
    namespace_selector {
      match_expressions {
        key      = "component"
        operator = "DoesNotExist"
        values   = []
      }
    }
  }
}

resource "tanzu-mission-control_security_policy" "strict-eks-devclusters-pspdisabled-tf" {
  name = "strict-eks-devclusters-pspdisabled-tf"

  /*  scope {
    organization {
      organization = "df467a16-b93a-4360-be75-ffe53d400e41"
    }
  }
*/
  scope {
    cluster_group {
      cluster_group = "eks-dev-group-tf"
    }
  }
  spec {
    input {
      strict {
        audit              = true
        disable_native_psp = true
      }
    }
    namespace_selector {
      match_expressions {
        key      = "component"
        operator = "DoesNotExist"
        values   = []
      }
    }
  }
}