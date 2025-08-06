# Ingress + Static ip

Create static ip in same node groups resource group and deploy ingress

```bash
az network public-ip create --resource-group aks-nrg --name myAKSPublicIPForIngress --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv

STATIC_IP="x.x.x.x"

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="$STATIC_IP"
```
