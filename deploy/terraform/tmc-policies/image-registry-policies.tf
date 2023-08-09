/*
Workspace scoped Tanzu Mission Control image policy with block-latest-tag input recipe.
This policy is applied to a workspace with the block-latest-tag configuration option.
The defined scope and input blocks can be updated to change the policy's scope and recipe, respectively.
*/
resource "tanzu-mission-control_image_policy" "workspace_scoped_block-latest-tag_image_policy" {
  name = "block-latest-tf"

  scope {
    workspace {
      workspace = "tf-workspace"
    }
  }

  spec {
    input {
      block_latest_tag {
        audit = false
      }
    }

    namespace_selector {
      match_expressions {
        key      = "component"
        operator = "In"
        values = [
          "api-server",
          "agent-gateway"
        ]
      }
      match_expressions {
        key      = "not-a-component"
        operator = "DoesNotExist"
        values   = []
      }
    }
  }
}

resource "tanzu-mission-control_image_policy" "workspace_scoped_allowed_registries" {
  name = "allowed-registries-tf"

  scope {
    workspace {
      workspace = "tf-workspace"
    }
  }

  spec {
    input {
      custom {
        audit = false
        rules {
            hostname = "host"
            tag {}
        }
        rules {
            hostname = "public.ecr.aws"
            imagename = "v6x6b8s5/vmwareallspark/*"
        }
      }
    }

    namespace_selector {
      match_expressions {
        key      = "component"
        operator = "In"
        values = [
          "api-server",
          "agent-gateway"
        ]
      }
      match_expressions {
        key      = "not-a-component"
        operator = "DoesNotExist"
        values   = []
      }
    }
  }
}