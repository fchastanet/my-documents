---
title: Saml2Aws Setup
description: Guide to setting up and using Saml2Aws for AWS access
weight: 40
---

Configure saml2aws accounts

```bash
saml2aws configure \
  --idp-account='<account_alias>' \
  --idp-provider='AzureAD' \
  --mfa='Auto' \
  --profile='<profile>' \
  --url='https://account.activedirectory.windowsazure.com' \
  --username='<username>@microsoft.com' \
  --app-id='<app_id>' \
  --skip-prompt
```

- `<app_id>` is a unique identifier for the application we want credentials for (in this case an AWS environment).
- `<account_alias>` serves as a name to identify the saml2aws configuration (see your ~/.saml2aws file
- `<profile>` serves as the name of the aws cli profile that will be created when you log in.

This will automatically identify your tenant ID based on the AppID and will create a configuration based on the provided
information. Configuration will be created in ~/.saml2aws

## 1. Use saml2aws login command to configure the AWS CLI profile

Run saml2aws login to add or refresh your profile for the aws cli.

```bash
saml2aws login -a ${account_alias}
```

Follow the prompts to enter your SSO credentials and complete the multi-factor authentication step.

Note: if you are part of multiple roles you can use --role flag to configure the required role.

Above steps have been taken from below GitHub Repo. They have been tried in MacOS, Windows, Linux and Windows WSL
<https://github.com/Versent/saml2aws>

## 2. Kubernetes connection

Adding a newly created Technology Convergence EKS cluster to your ~/.kube/config:

Add EKS Cluster to ~/.kube/config

```bash
aws eks update-kubeconfig --name $clusterName --region us-east-1
```

## 3. Common issues

### 3.1. Error - error authenticating to IdP: unable to locate IDP oidc form submit URL

This is very likely because you changed your account password. Reenter your password when prompted at saml2aws login

### 3.2. Error - error authenticating to IdP: unable to locate SAMLRequest URL

This is very likely because you do not have access to this AWS account.

Multifactor authentication asks for a number, but the terminal doesn't provide a number.

**Solution 1:** We've found that going to your
[Microsoft account security info](https://mysignins.microsoft.com/security-info) and deleting and re-adding the sign-in
method seems to fix the issue. You should then be able to just enter a Time-based one-time password from your Microsoft
Authenticator app.

**Solution 2:** You can change the MFA option for your saml2aws config either with PhoneAppOTP, PhoneAppNotification, or
OneWaySMS. Something like this in your ~/.saml2aws file

```text
name          = tc-dev
app_id         = 83cffb56-1d1b-400c-ad47-345c58e378dc
url           = https://account.activedirectory.windowsazure.com
username        = <>@microsoft.com
provider        = AzureAD
mfa           = OneWaySMS
skip_verify       = false
timeout         = 0
aws_urn         = urn:amazon:webservices
aws_session_duration  = 3600
aws_profile       = dev
resource_id       =
subdomain        =
role_arn        =
region         =
http_attempts_count   =
http_retry_delay    =
credentials_file    =
saml_cache       = false
saml_cache_file     =
target_url       =
disable_remember_device = false
disable_sessions    = false
prompter        =
```

for more reference, follow this page
<https://github.com/Versent/saml2aws/blob/master/doc/provider/aad/README.md#configure>
