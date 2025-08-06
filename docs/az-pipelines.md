# Azure Pipeleines

## Install Azure Market Place Plugins in Azure DevOps

- Create project in Azure DevOps
- Install [Terraform by Microsoft Devlabs](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks) plugin in your respective Azure DevOps Organization
  - Another [Terraform task addon](https://marketplace.visualstudio.com/items?itemName=JasonBJohnson.azure-pipelines-tasks-terraform)
- Create local runner
  - **Project Settings** > Agent Pools > Default > Agents: Add new

Use pool in pipeline as

```yaml
pool:
  name: Default
```

## Create Azure RM Service Connection for Terraform Commands

Create Azure RM Service Connection for Terraform Commands

- **Project Settings** >  Pipelines -> Service Connections ->Create Service Connection
- Choose a Service Connection type: Azure Resource Manager > Next
- Authentication Method: Service Princiapl (automatic)
  - Scope Level: Subscription
  - Subscription: Pay-As-You-Go
  - Resource Group: **LEAVE EMPTY**
  - Service Connection Name: terraform-aks-azurerm-svc-con
  - Description: Azure RM Service Connection for provisioning AKSCluster using Terraform on Azure DevOps
  - Security: Grant access permissions to all pipelines (check it- leave to default)
  - Click on SAVE

## VERY IMPORTANT FIX: Provide Permission to create Azure AD Groups

Provide permission for Service connection created in previous

- Go to **Project Settings** -> Pipelines -> Service Connections
- Open **terraform-aks-azurerm-svc-con**
- Click on **Manage App registration**, new tab will be opened
- Click on **View API Permissions**
- Click on **Add Permission**
- Select an API: Microsoft Graph
- Click on **Application Permissions**
- Check **Directory.ReadWrite.All** and click on **Add Permission**
- Click on **Grant Admin consent for Default Directory**

## Create SSH Public Key for Linux VMs

- Create this out of your git repository
- **Important Note:**  We should not have these files in our git repos for security Reasons

```bash
# Create Folder
mkdir $HOME/ssh-keys-teerraform-aks-devops

# Create SSH Keys
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C "azureuser@myserver" \
    -f ~/aks-terraform-devops-ssh-key-ubuntu

Note: We will have passphrase as : empty when asked

# List Files
ls -lrt $HOME/ssh-keys-teerraform-aks-devops
Private File: aks-terraform-devops-ssh-key-ububtu
Public File: aks-terraform-devops-ssh-key-ububtu.pub
```

Upload file to Azure DevOps as Secure File

- Go to Pipelines > Library
- Secure File > Upload file named **aks-terraform-devops-ssh-key-ububtu.pub**
- Open the file and click on **Pipeline permissions > Clikc .. on right > Open Access > Open Access**
- Click on **SAVE**

Add `subscription_id` also:

- Create variable group: azure_portal
- Add secure variable `subscription_id` and value of it

## Create Azure Pipeline to Provision AKS Cluster

- Go to Pipelines -> Pipelines -> Create Pipeline
- Select a Repository
- Provide your github password
- Click on **Approve and Install** on Github
- Select Pipeline: Starter Pipeline
- Design your Pipeline > Commit (it will add pipeline file to you r github repo and run)
- Grant pemrission to pipeline to run first time
