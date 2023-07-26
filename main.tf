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
   uri                  = "https://api.us.onelogin.com/"
   write_returns_object = true
   oauth_client_credentials {
      oauth_client_id = var.ol_client_id
      oauth_client_secret = var.ol_client_secret
      oauth_token_endpoint = "https://api.us.onelogin.com/auth/oauth2/v2/token"
  }
}

provider "onelogin" {
  # Configuration options
client_id = var.ol_client_id
client_secret = var.ol_client_secret
}

########## VARS ###########

variable "ol_client_id" {
  type = string
  description = "Client ID for API Credential created in target OneLogin env"
}

variable "ol_client_secret" {
  type = string
  description = "Client Secret for API Credential created in target OneLogin env"
}

variable "user1_username" {
  type = string
  default = "john.smith"
}

variable "user1_email" {
  type = string
  default = "john.smith@johnsmithmail.com"
}

variable "user2_username" {
  type = string
  default = "joan.smith"
}

variable "user2_email" {
  type = string
  default = "joan.smith@joansmithmail.com"
}

############ USERS ################

#### Users via generic REST Provider

## example of how to create a new user in your OneLogin environment using the V2 Users endpoint
resource "restapi_object" "oneloginuser1" {
  path = "/api/2/users"
  data = "{ \"email\": \"${var.user2_email}\", \"username\": \"${var.user2_username}\", \"firstname\": \"Davennnnnn\", \"lastname\": \"Boe\"}"
}

#### Users via OneLogin Provider

# create some standard user for testing
resource onelogin_users username {
  username = var.user1_username
  email    = var.user1_email
  firstname = "tim"
  lastname = "test"
  status = 1
  state = 1
  custom_attributes = {food = "pizza"}
}
