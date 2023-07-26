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
   uri                  = https://api.us.onelogin.com/
   write_returns_object = true
   oauth_client_credentials {
      oauth_client_id = var.client_id
      oauth_client_secret = var.client_secret
      oauth_token_endpoint = https://api.us.onelogin.com/auth/oauth2/v2/token
  }
}

provider "onelogin" {
  # Configuration options
client_id = var.client_id
client_secret = var.client_secret
}
