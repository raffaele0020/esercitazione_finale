#login su azure

az login

#impostiamo il nostro account mettendo la sottoscrizione

az account set --subscription "b7b99826-3835-4054-891a-696b78a0d1ba"

#settiamo il path dove andranno tutti i file dell'esercitazione finale

cd C:\Users\tufan\esercitazione_finale

#inizializziamo terraform

terraform init

#vediamo quali risorse verranno create

terraform plan

#creazione della chiave pubblica

ssh-keygen -t rsa -b 4096

terraform apply

#Abbiamo concluso con la creazione delle risorse azure.





#login alla vm da ps

ssh raffaeleuser@51.145.165.106

#installazione di docker 

curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker


#installazione di k3s come server 

curl -sfL https://get.k3s.io | sh -

#controllo quindi lo stato del nodo

sudo kubectl get nodes

#creo hello-docker

mkdir hello-docker

#mi sposto in hello docker

cd hello-docker

#con nano app.js lo creo

nano app.js

#stesso per package.json

nano package.json

#installo le dipendenze

sudo apt install npm e poi npm install

#creazione del dockerfile

nano Dockerfile

#costruzione dell'immagine docker

sudo docker build -t hello-docker .

#controllo che sia stata creata

sudo docker images

#creo i file yaml per il deployment

nano deployment.yaml

#stesso per i servizi

nano service.yaml

#li applico entrambi con comando admin

sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml

#verifico i pods

sudo kubectl get pods

#vado sul browser del mio pc tramite ip pubblico e porta e verifico l'helloworld

http://51.145.165.106:30080/
