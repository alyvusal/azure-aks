# Azure Virtual Nodes

- **Important Note:** Virtual nodes require AKS clusters with [Azure CNI networking](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)

```bash
az aks nodepool list --cluster-name devops-dev-aks --resource-group aks-main-rg --output table
```

- [Limitations](https://learn.microsoft.com/en-us/azure/aks/virtual-nodes#limitations)
