#!/bin/bash 

echo -------Variable------------- 
echo Create a resource group
echo "Name of resource groupe?" 
read rg 
echo "Location of resource groupe?" 
read lrg 
echo 
echo Create virtual machines
echo first VM name ?
read myVM1
echo first image name ?
read ubuntu1
echo first admin username?
read azureuser1
echo password firs admin username ?
read Azertyuiop1234
echo
echo second VM name ?
read myVM2
echo second image name ?
read ubuntu2
echo second admin username ?
read azureuser2
echo password second admin username ?
read Azertyuiop123
echo 
echo "Name of your db server?"
read dbname
echo “your admin user name?”
read bduser
echo MariaDB admin-password -exemple : Azertyuiop123@
read password

echo ------------Creer un groupe de ressources-------------------- 

az group create --name $rg --location $lrg
  
echo -------------Creez un réseau virtuel---------------------- 
az network vnet create \
    --resource-group $rg \
    --location $lrg \
    --name myVNet \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name myBackendSubnet \
    --subnet-prefixes 10.1.0.0/24

echo ----------------Creer une adresse IP publique-----------
az network public-ip create \
    --resource-group $rg \
    --name myPublicIP \
    --sku Standard \
    --zone 1 2 3

echo --------------Creer un équilibrage de charge------------- 
az network lb create \
    --resource-group $rg \
    --name myLoadBalancer \
    --sku Standard \
    --public-ip-address myPublicIP \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool

echo -------------Creer la sonde d-integrite------------------- 
az network lb probe create \
    --resource-group $rg \
    --lb-name myLoadBalancer \
    --name myHealthProbe \
    --protocol tcp \
    --port 80

echo -----------Creer la regle d-equilibreur de charge------------------- 
az network lb rule create \
    --resource-group $rg \
    --lb-name myLoadBalancer \
    --name myHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool \
    --probe-name myHealthProbe \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true

echo Creer un groupe de securite reseau-------------- 
az network nsg create \
    --resource-group $rg \
    --name myNSG

echo Creer une regle de groupe de securite reseau---------------- 
az network nsg rule create \
    --resource-group $rg \
    --nsg-name myNSG \
    --name myNSGRuleHTTP \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200

echo -----------Creer un hote bastion------------- 
echo ---------Creer une adresse IP publique------------------ 
az network public-ip create \
    --resource-group $rg \
    --name myBastionIP \
    --sku Standard \
    --zone 1 2 3

echo --------Creer un sous-reseau bastion----------- 
az network vnet subnet create \
    --resource-group $rg \
    --name AzureBastionSubnet \
    --vnet-name myVNet \
    --address-prefixes 10.1.1.0/27

echo -----------Creer un hote bastion-------------- 
az network bastion create \
    --resource-group $rg \
    --name myBastionHost \
    --public-ip-address myBastionIP \
    --vnet-name myVNet \
    --location $lrg

echo --------Creer des serveurs principaux------------- 
########Créer des interfaces réseau pour les machines virtuelles####### 
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic create \
        --resource-group $rg \
        --name $vmnic \
        --vnet-name myVNet \
        --subnet myBackendSubnet \
        --network-security-group myNSG
  done

echo ---------Creer des machines virtuelles avec mot de passe plus de 12caractere ---------------
echo Le mot de passe doit comporter 3 des éléments suivants : 1 minuscule, 1 majuscule, 1 chiffre et 1 caractère spécial.
echo La valeur doit comprendre entre 12 et 72 caractères.
az vm create \
    --resource-group $rg \
    --name $myVM1 \
    --nics myNicVM1 \
    --image $ubuntu1 \
    --admin-username $azureuser1 \
    --admin-password $Azertyuiop1234 \
    --zone 1 \
    --no-wait

az vm create \
    --resource-group $rg \
    --name $myVM2 \
    --nics myNicVM2 \
    --image $ubuntu2 \
    --admin-username $azureuser2 \
    --admin-password $Azertyuiop123 \
    --zone 3 \
    --no-wait

echo -------Ajouter des machines virtuelles au pool de back-ends de l-equilibreur de charge------ 
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic ip-config address-pool add \
     --address-pool myBackEndPool \
     --ip-config-name ipconfig1 \
     --nic-name $vmnic \
     --resource-group $rg \
     --lb-name myLoadBalancer
  done

########Créer une passerelle NAT################ 
echo ----------Créer une adresse IP publique------------ 
az network public-ip create \
    --resource-group $rg \
    --name myNATgatewayIP \
    --sku Standard \
    --zone 1 2 3

echo ---------------Creer une ressource de passerelle NAT------------ 
az network nat gateway create \
    --resource-group $rg \
    --name myNATgateway \
    --public-ip-addresses myNATgatewayIP \
    --idle-timeout 10

echo -------------Associer une passerelle NAT au sous-reseau----------------- 
az network vnet subnet update \
    --resource-group $rg \
    --vnet-name myVNet \
    --name myBackendSubnet \
    --nat-gateway myNATgateway

###Création de la base de données Maria dB###------------------------- 
echo ------create a maria db databes---------------------------------------------- 

az mariadb server create --name $dbname --admin-password $password --admin-user $bduser --location $lrg --resource-group $rg --backup-retention 10 --geo-redundant-backup Enabled --infrastructure-encryption Disabled --ssl-enforcement Disabled --storage-size 5120 --tags "key=value" --version 10.3
echo “create firewall rules”--------------------------------------------------------------------------------  
az mariadb server firewall-rule create --resource-group $rg --server $dbname --name AllowMyIP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 
az mariadb server update --resource-group $rg --name $dbname --ssl-enforcement Disabled 
echo “création du monitoring” ------------------------------------------------------------------------------- 