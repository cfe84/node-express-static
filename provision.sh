#!/bin/bash

read -p "Your alias > " ALIAS

NAME="training-containers-$ALIAS"
RESOURCE_GROUP="$NAME"
AKS_NAME="$NAME"
ACR_NAME=`echo $NAME | sed 's/-//g'`
IDENTIFIERURI="http://$NAME/"
LOCATION="canadacentral"

echo "1. Creating resource group"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --query "properties.provisioningState"

echo "2. Create container registry"
az acr create --name $ACR_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --sku Basic \
    --query "properties.provisioningState"

echo "3. Creating AKS cluster (this is gonna take some time)"
az aks create --name $AKS_NAME\
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --node-count 1 \
    --query "properties.provisioningState"

echo "4. Granting AKS permissions to ACR"
CLIENT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "servicePrincipalProfile.clientId" --output tsv)
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "id" --output tsv)
az role assignment create \
    --assignee $CLIENT_ID \
    --role acrpull \
    --scope $ACR_ID \
    --query "principalId"

echo "5. Getting k8s credentials"
az aks get-credentials -g $RESOURCE_GROUP -n $AKS_NAME

echo ". Creating cleanup script. Run ./cleanup.sh when you're done."
echo "#!/bin/bash

echo 'Deleting resource group $RESOURCE_GROUP'
az group delete -g $RESOURCE_GROUP --yes
echo 'Deleting service principal $CLIENT_ID'
az ad sp delete --id $CLIENT_ID
" > cleanup.sh