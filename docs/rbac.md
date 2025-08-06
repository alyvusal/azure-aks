# RBAC

- We can use Azure AD Users and Groups to Manage AKS Clusters
- We can create Admin Users in Azure AD and Associate to Azure AD Group named `k8sadmins` and those users can access Azure AKS Cluster using kubectl.
- [Three important limitations](https://docs.microsoft.com/en-us/azure/aks/managed-aad#limitations) we need to remember before making any changes to our existing AKS Clusters
- **Important Note-1:** AKS-managed Azure AD integration can't be disabled
- **Important Note-2:** non-RBAC enabled clusters aren't supported for AKS-managed Azure AD integration
- **Important Note-3:** Changing the Azure AD tenant associated with AKS-managed Azure AD integration isn't supported

Create user and add to

## Enable AKS Cluster with AKS-managed Azure Active Directory feature

- Go to All Services -> Kubernetes Services -> devops-dev-aks -> Settings -> Security configuration
- **Authentication and Authorization:** Select rbac type
- **Admin Azure AD groups:** devops-dev-aks-administrators
- Click on **SAVE**

Don't use `--admin`:

`devicecode` is not working well, see [limitations](https://azure.github.io/kubelogin/known-issues.html).
User [`interactive`](https://azure.github.io/kubelogin/concepts/login-modes/interactive.html) or `azurecli`

```bash
# get devicecode loing method
az aks get-credentials --resource-group aks-main-rg --name $(terraform output -raw aks_cluster_name) --overwrite-existing

# change it ti azurecli or interactive
kubelogin remove-tokens
kubelogin convert-kubeconfig -l interactive
# or
kubelogin convert-kubeconfig -l azurecli

# https://learn.microsoft.com/en-us/azure/aks/kubelogin-authentication
kubectl whoami
kubectl get nodes

# to use k8s native admin
az aks get-credentials --resource-group aks-main-rg --name $(terraform output -raw aks_cluster_name) --overwrite-existing --admin
```
