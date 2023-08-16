terraform {
  required_providers {
    restapi = {
      source = "Mastercard/restapi"
      version = "1.18.0"
    }
    onelogin = {
      source  = "onelogin/onelogin"
      version = "0.2.0"
    }
  }
} 

provider "restapi" {
  # Configuration options
   uri                  = "https://${var.ol_subdomain}.onelogin.com/"
   write_returns_object = true
   oauth_client_credentials {
      oauth_client_id = var.ol_client_id
      oauth_client_secret = var.ol_client_secret
      oauth_token_endpoint = "https://${var.ol_subdomain}.onelogin.com/auth/oauth2/v2/token"
  }
}

provider "onelogin" {
  # Configuration options
client_id = var.ol_client_id
client_secret = var.ol_client_secret
}

########## Terraform VARS ###########

variable "ol_subdomain" {
  type = string
  description = "Subdomain name for target OneLogin env"
}

variable "ol_client_id" {
  type = string
  description = "Client ID for API Credential created in target OneLogin env"
}

variable "ol_client_secret" {
  type = string
  description = "Client Secret for API Credential created in target OneLogin env"
}

variable "ol_policy_id_new_user" {
  type = string
  description = "User Security Policy ID for New user first time login- used in pre-auth smart hook"
  default = "1234"
}

############ Smart Hook env vars ################

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"pol_id_new_user\", \"value\": \"${var.ol_policy_id_new_user}\"}"
}

############ Smart Hook ################

#### create smart hook via generic REST Provider

## example of how to create a new user in your OneLogin environment using the V2 Users endpoint
