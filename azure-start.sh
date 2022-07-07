#!/bin/sh
# TODO : changer rg-group1 par variable GROUP (a faire aussi sur vmMaster)
GROUP=rg-group1
az group create -l westeurope -n ${GROUP}
az network public-ip create -g ${GROUP} -n ${GROUP}Ip --dns-name ${GROUP}ip --allocation-method Static
az network vnet create --name ${GROUP}VirtualNetwork --resource-group ${GROUP} --address-prefixes 10.0.0.0/16 --subnet-name ${GROUP}Subnet --subnet-prefixes 10.0.0.0/24
# VM Creation
size=Standard_D2s_v3
echo "vmMaster"
az vm create -n vmMaster -g ${GROUP} --size $size --image UbuntuLTS --vnet-name ${GROUP}VirtualNetwork --subnet ${GROUP}Subnet --public-ip-address ${GROUP}Ip --admin-username ${GROUP} --admin-password GRETA2022 --ssh-key-values @~/.ssh/id_rsa.pub
echo "Mise à jour des paquets Ubuntu"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "sudo apt update && sudo apt upgrade -y"
echo "Installation des paquets utiles"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "sudo apt install -y docker.io mongodb-clients python3-pip"
echo "Installation de la librairie pymongo"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "pip3 install pymongo"
echo "Installation de Lazydocker"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash"
echo "Suppression de sudo pour exéctuer commande Docker"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "sudo usermod -aG docker $USER"
echo "Redémarrage du terminal"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "newgrp docker"
echo "Création du conteneur Docker mongo pour la base de données"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "docker run --name mongo -d mongo:latest"
echo "Téléchargement du json"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "wget 'https://dataia2021.s3.eu-west-3.amazonaws.com/MOOC.forum-2022-06.json.gz?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEHYaCWV1LXdlc3QtMyJGMEQCIHpp2ybwdWPae4fs4EgKR8VKEh3pqvBK5c91LY5iiH3DAiBYX9mc%2Fm22hhewM%2FHkW3a1wdlqnY0Btt%2BXW4lcrSgxySqeAgif%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAQaDDk0MjkxMTU4MDc3NiIMrkFRjELNGTzevhABKvIB5ddPDA59T7MEhpFn2DalqOKnXl0k1o31sD8O0rd7vom%2BYg3J5h74x1rDhclwkXNQ%2BiZHmdheWzYDqA1UHUccsuIrGXfTM%2Fv85jI1THvoRklrWZY%2F5LPfEJ9jHJnDIVswEggdJIAP%2FZoHHXmMN7JAQQxnh6c%2FTdHXJMoTDjvxu4i%2FQFpdjFsrSotvdllRr6KACkmAH1di8YATy00tvLvLHI4uRDm%2FcJCtb7ftOwm5A8Idp%2Fpc0A3%2FtG9slUgLpsSlW7VDaYUjB1surgsCXTVTx%2FDMQnV8EDBduzQAJrx2n6KM6JXM%2BL6T3mx7ZlVPESlPmEow3KyPlgY64AFztN6bL40IF6Ufwbizw7GnwOXmIxJMgGkXSRW%2FP19K8AAssqWmOvGdMKsAxZpZw8vUcBRYyPRqoenuqrLihwveMifDYqryX0IffmvhtQlNTyAWmIenTAoEGBkpVCWSLqa4iw8%2BBf%2Bc3GutfEEaVePmDR5dDnVr7GJVBUMfvg6%2FZgwikciiHrr0H4Wgwec27VEyJh4iB2kT6kGP7HF21CY%2BDF4QZ3OAq6YA5LWw0wNn5%2BMA%2BOBMpNGG%2FvkGhnZX4ph5H6ut72%2FZz6WAyVrrxYYowyBlVDbMgmjr7U80TNIOHw%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220705T101305Z&X-Amz-SignedHeaders=host&X-Amz-Expires=28800&X-Amz-Credential=ASIA5XCPI5JUNTXQMK44%2F20220705%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Signature=fc4f8eec59d2a8cccf591515f4c4e659d090cd7523759ecf652472edb78688f4'"
echo "Renommage du fichier json"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "mv 'https://dataia2021.s3.eu-west-3.amazonaws.com/MOOC.forum-2022-06.json.gz?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEHYaCWV1LXdlc3QtMyJGMEQCIHpp2ybwdWPae4fs4EgKR8VKEh3pqvBK5c91LY5iiH3DAiBYX9mc%2Fm22hhewM%2FHkW3a1wdlqnY0Btt%2BXW4lcrSgxySqeAgif%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAQaDDk0MjkxMTU4MDc3NiIMrkFRjELNGTzevhABKvIB5ddPDA59T7MEhpFn2DalqOKnXl0k1o31sD8O0rd7vom%2BYg3J5h74x1rDhclwkXNQ%2BiZHmdheWzYDqA1UHUccsuIrGXfTM%2Fv85jI1THvoRklrWZY%2F5LPfEJ9jHJnDIVswEggdJIAP%2FZoHHXmMN7JAQQxnh6c%2FTdHXJMoTDjvxu4i%2FQFpdjFsrSotvdllRr6KACkmAH1di8YATy00tvLvLHI4uRDm%2FcJCtb7ftOwm5A8Idp%2Fpc0A3%2FtG9slUgLpsSlW7VDaYUjB1surgsCXTVTx%2FDMQnV8EDBduzQAJrx2n6KM6JXM%2BL6T3mx7ZlVPESlPmEow3KyPlgY64AFztN6bL40IF6Ufwbizw7GnwOXmIxJMgGkXSRW%2FP19K8AAssqWmOvGdMKsAxZpZw8vUcBRYyPRqoenuqrLihwveMifDYqryX0IffmvhtQlNTyAWmIenTAoEGBkpVCWSLqa4iw8%2BBf%2Bc3GutfEEaVePmDR5dDnVr7GJVBUMfvg6%2FZgwikciiHrr0H4Wgwec27VEyJh4iB2kT6kGP7HF21CY%2BDF4QZ3OAq6YA5LWw0wNn5%2BMA%2BOBMpNGG%2FvkGhnZX4ph5H6ut72%2FZz6WAyVrrxYYowyBlVDbMgmjr7U80TNIOHw%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220705T101305Z&X-Amz-SignedHeaders=host&X-Amz-Expires=28800&X-Amz-Credential=ASIA5XCPI5JUNTXQMK44%2F20220705%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Signature=fc4f8eec59d2a8cccf591515f4c4e659d090cd7523759ecf652472edb78688f4' 'MOOC.forum-2022-06.json.gz'" 
echo "Décompression du fichier"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "gunzip MOOC.forum-2022-06.json.gz"
echo "Create mongo database"
az vm run-command invoke -g rg-group1 -n vmMaster --command-id RunShellScript --scripts "python3 https://github.com/dataIA-2021/team1_AzureDockerMongo/blob/main/create-mongodb.py"

