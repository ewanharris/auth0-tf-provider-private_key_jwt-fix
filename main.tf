terraform {
  required_providers {
    auth0 = {
      source = "auth0/auth0"
    }
  }
}

provider "auth0" {}

resource "auth0_client" "my_client" {
  name     = "Credential Rotation Demo"
  app_type = "non_interactive"

  jwt_configuration {
    alg = "RS256"
  }
}


# Step 1: Update the client with a single credential (Key A).

resource "auth0_client_credentials" "my_client" {
  client_id             = auth0_client.my_client.id
  authentication_method = "private_key_jwt"

  private_key_jwt {
    credentials {
      name                   = "Key A"
      credential_type        = "public_key"
      algorithm              = "RS256"
      parse_expiry_from_cert = true
      pem                    = file("certs/a.pem")
    }
  }
}


# Step 2: Add Key B alongside Key A.

# Expected plan: update in-place. Key A is unchanged, Key B is added.
# No credentials are deleted.

# resource "auth0_client_credentials" "my_client" {
#   client_id             = auth0_client.my_client.id
#   authentication_method = "private_key_jwt"

#   private_key_jwt {
#     credentials {
#       name                   = "Key A"
#       credential_type        = "public_key"
#       algorithm              = "RS256"
#       parse_expiry_from_cert = true
#       pem                    = file("certs/a.pem")
#     }

#     credentials {
#       name                   = "Key B"
#       credential_type        = "public_key"
#       algorithm              = "RS256"
#       parse_expiry_from_cert = true
#       pem                    = file("certs/b.pem")
#     }
#   }
# }

# Step 3: Rotate Key A out, replace with Key C. Key B is untouched.
#
# Expected plan: update in-place.
#   - Credential 0: Key A deleted, Key C created (new ID, new key_id)
#   - Credential 1: Key B unchanged (same ID, same key_id)
#
# Services authenticating with Key B experience zero downtime.

# resource "auth0_client_credentials" "my_client" {
#   client_id             = auth0_client.my_client.id
#   authentication_method = "private_key_jwt"

#   private_key_jwt {
#     credentials {
#       name                   = "Key C"
#       credential_type        = "public_key"
#       algorithm              = "RS256"
#       parse_expiry_from_cert = true
#       pem                    = file("certs/c.pem")
#     }

#     credentials {
#       name                   = "Key B"
#       credential_type        = "public_key"
#       algorithm              = "RS256"
#       parse_expiry_from_cert = true
#       pem                    = file("certs/b.pem")
#     }
#   }
# }
