# Private Key JWT Credential Rotation Demo

Demonstrates zero-downtime credential rotation for `auth0_client_credentials` using `private_key_jwt`.

## Prerequisites

Set your Auth0 credentials and run `terraform init`:

```bash
export AUTH0_DOMAIN="your-tenant.auth0.com"
export AUTH0_CLIENT_ID="your-client-id"
export AUTH0_CLIENT_SECRET="your-client-secret"
```

## Steps

Each step is commented out in the `main.tf` file. So follow the below to comment/uncomment each step in turn to demonstrate the issue.

### Step 2: Create client client with Key A

Uncomment line 25 to 38

```bash
terraform plan
terraform apply
```

Creates a client with a single `private_key_jwt` credential using Key A.

### Step 2: Add Key B alongside Key A

Comment out lines 25 to 38
Uncomment line 46 to 67

```bash
terraform plan
terraform apply
```

**Expected plan output:** `auth0_client_credentials.my_client will be updated in-place`

Key A is unchanged. Key B is added. No credentials are deleted.

### Step 3: Rotate Key A out, replace with Key C

Comment out lines 46 to 67
Uncomment line 77 to 98

```bash
terraform plan
terraform apply
```

**Expected plan output:** `auth0_client_credentials.my_client will be updated in-place`

Key A is deleted and replaced with Key C (new credential ID). Key B is completely untouched -- same credential ID, same key ID. Any service authenticating with Key B experiences zero downtime during this operation.

## Before the fix

Prior to this fix, Steps 3 and 4 would both show:

```
auth0_client_credentials.my_client must be replaced
```

This meant Terraform would delete ALL credentials and recreate them from scratch, causing service disruption even for credentials that didn't change.

## Cleanup

```bash
terraform destroy
rm credentials.tf
```
