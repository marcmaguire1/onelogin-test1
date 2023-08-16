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

variable "ol_smart_hook_env_var1" {
  type = string
  description = "Name of the Smart Hooks Env Var for the New user first time login policy- used in pre-auth smart hook"
  default = "test"
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
  data = "{ \"name\": \"${var.ol_smart_hook_env_var1}\", \"value\": \"${var.ol_policy_id_new_user}\"}"
}

############ Smart Hook ################

#### create smart hook via generic REST Provider

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  data = "{ \"type\": \"pre-authentication\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":1, \"options\":{\"location_enabled\":true, \"risk_enabled\":true, \"mfa_device_info_enabled\":true}, \"env_vars\":[\"${var.ol_smart_hook_env_var1}\"], \"packages\": {\"axios\": \"0.21.1\"} , \"function\":\"ZXhwb3J0cy5oYW5kbGVyID0gYXN5bmMgKGNvbnRleHQpID0+IHsKICBjb25zb2xlLmxvZygiQ29udGV4dDogIiwgY29udGV4dCk7CiAgbGV0IHVzZXIgPSBjb250ZXh0LnVzZXI7CiAgY29uc3QgZ29vZ2xlX3BvbF9pZCA9IDM1MTQzNzsKICBjb25zdCB3b3JrZm9yY2VfcG9sX2lkID0gMzUyNDU0OwogIGNvbnN0IE5FV19VU0VSX1BPTElDWV9JRCA9IDM0MTc5MzsKICBjb25zdCBub3B3X3Bhc3NrZXlzX2lkID0gMzQ3ODM4OwogIGNvbnN0IG5vcHdfZW1haWxfaWQgPSAzNDgwMjg7CiAgY29uc3Qgbm9wd19iMmJvcmdhID0gMzYwNTgwOwogIGNvbnN0IG5vcHdfYjJib3JnYiA9IDM2MDU4MTsKCmlmIChjb250ZXh0LnVzZXIubGFzdF9sb2dpbl9zdWNjZXNzKSB7CiAgICAgIGNvbnNvbGUubG9nKCJleGlzdGluZyB1c2VycyBmdXJ0aGVyIHByb2Nlc3NpbmciKTsgICAKaWYgKGNvbnRleHQubWZhX2RldmljZXMubGVuZ3RoID09PSAwKSB7CiAgICAgICAgY29uc29sZS5sb2coIk5vdCBhIEdvb2dsZSBpRFAgVXNlciBkZXRlY3RlZC4gTm90IENoYW5naW5nIHBvbGljeSBpZHMgYXQgYWxsIik7ICAgICAgICAKICAgIH0KCmVsc2UgaWYgKGNvbnRleHQubWZhX2RldmljZXNbMF0uYXV0aF9mYWN0b3JfbmFtZSA9PSAnT25lTG9naW4gQXV0aG4nKSB7CiAgIGNvbnNvbGUubG9nKCIgVGhpcyBpcyBhIFBhc3NrZXlzIHVzZXIuIENoYW5naW5nIFBvbGljeSIpOyAKICAgdXNlci5wb2xpY3lfaWQgPSBub3B3X3Bhc3NrZXlzX2lkOwogIH0KCmVsc2UgaWYgKGNvbnRleHQubWZhX2RldmljZXNbMF0uYXV0aF9mYWN0b3JfbmFtZSA9PSAnT25lTG9naW4gRW1haWwnKSB7CiAgIGNvbnNvbGUubG9nKCIgVGhpcyBpcyBhIEVtYWlsIE1GQSB1c2VyLiBDaGFuZ2luZyBQb2xpY3kiKTsgCiAgIHVzZXIucG9saWN5X2lkID0gbm9wd19lbWFpbF9pZDsKICB9CgplbHNlIGlmIChjb250ZXh0Lm1mYV9kZXZpY2VzWzBdLmF1dGhfZmFjdG9yX25hbWUgPT0gJ1RydXN0ZWQgSWRQIFRydXN0ZWQgSWRQJyAmJiBjb250ZXh0Lm1mYV9kZXZpY2VzWzBdLnVzZXJfZGlzcGxheV9uYW1lID09ICdHb29nbGUnKSB7CiAgIGNvbnNvbGUubG9nKCIgVGhpcyBpcyBhIHR5cGUgR29vZ2xlIFRpRFAgVXNlci4gQ2hhbmdlIFBvbGljeSIpOyAKICAgdXNlci5wb2xpY3lfaWQgPSBnb29nbGVfcG9sX2lkOwogIH0KCiBlbHNlIGlmIChjb250ZXh0Lm1mYV9kZXZpY2VzWzBdLmF1dGhfZmFjdG9yX25hbWUgPT0gJ1RydXN0ZWQgSWRQIFRydXN0ZWQgSWRQJyAmJiBjb250ZXh0Lm1mYV9kZXZpY2VzWzBdLnVzZXJfZGlzcGxheV9uYW1lID09ICdBRE1JTi1XT1JLRk9SQ0UnKSB7CiAgIGNvbnNvbGUubG9nKCIgVGhpcyBpcyBhIHR5cGUgV29ya2ZvcmNlIFRpRFAgVXNlci4gQ2hhbmdlIFBvbGljeSIpOyAKICAgdXNlci5wb2xpY3lfaWQgPSB3b3JrZm9yY2VfcG9sX2lkOwogIH0KCmVsc2Uge2NvbnNvbGUubG9nKCJOb3QgYSBHb29nbGUgaURQIFVzZXIgZGV0ZWN0ZWQuIE5vdCBDaGFuZ2luZyBwb2xpY3kgaWRzIGF0IGFsbCAyMjIiKTt9Cn0KCmVsc2UgaWYgKGNvbnRleHQudXNlci5wb2xpY3lfaWQgPT0gIjM1NTQ3MiIpIHsKICAgICAgY29uc29sZS5sb2coIk5ldyBwYXNzd29yZGxlc3MgVXNlciBkZXRlY3RlZC4gQ2hhbmdpbmcgcG9saWN5IGlkIHRvIG5ldyB1c2VyIHBvbGljeSIpOyAgIAogICAgICB1c2VyLnBvbGljeV9pZCA9IG5vcHdfZW1haWxfaWQ7CiAgICB9CgplbHNlIHsKCQljb25zb2xlLmxvZygiTmV3IFVzZXIgcGFzc3dvcmQgYmFzZWQgdXNlciBkZXRlY3RlZC4gQ2hhbmdpbmcgcG9saWN5IGlkIHRvIG5ldyB1c2VyIHBvbGljeSIpOwogICAgICAgICAgICAgICAgdXNlci5wb2xpY3lfaWQgPSBORVdfVVNFUl9QT0xJQ1lfSUQ7Cgl9CgogIHJldHVybiB7CiAgICBzdWNjZXNzOiB0cnVlLAogICAgdXNlcjogdXNlcgogIH0KfQ==\"}"
}

