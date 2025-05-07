## Implementazione di un cluster K3s su Azure con Terraform e Docker
Si vuole implementare un'infrastruttura su Azure utilizzando Terraform che consiste in un cluster K3s ad alta disponibilità con 3 nodi. Su questo cluster verrà deployato un progetto Docker fornito e disponibile al seguente indirizzo

https://github.com/MrMagicalSoftware/docker-k8s/blob/main/esercitazione-docker-file.md


## *CREAZIONE RISORSE AZURE*

login su azure
```
az login
```
![image](https://github.com/user-attachments/assets/1e9b26ec-9b90-4692-984e-b1ef48317fb1)

impostiamo il nostro account mettendo la sottoscrizione
```
az account set --subscription "b7b99826-3835-4054-891a-696b78a0d1ba"
```


settiamo il path dove andranno tutti i file dell'esercitazione finale
```
cd C:\Users\tufan\esercitazione_finale
```
inizializziamo terraform
```
terraform init
```
vediamo quali risorse verranno create
```
terraform plan
```
#creazione della chiave pubblica
```
ssh-keygen -t rsa -b 4096
```
terraform apply

Abbiamo concluso con la creazione delle risorse azure.



## *Configurazione del cluster K3s:*

login alla vm da ps
```
ssh raffaeleuser@51.145.165.106
```
![image](https://github.com/user-attachments/assets/f43a393b-f31d-4fff-92d3-477ed24a5bf0)

installazione di docker 
```
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker
```

installazione di k3s come server 
```
curl -sfL https://get.k3s.io | sh -
```
controllo quindi lo stato del nodo
```
sudo kubectl get nodes
```
![image](https://github.com/user-attachments/assets/2403fa35-0c10-47d4-afb2-af0873b560f2)

#creo hello-docker
```
mkdir hello-docker
```
mi sposto in hello docker
```
cd hello-docker
```
![image](https://github.com/user-attachments/assets/b683954f-c8fa-46ec-a592-3256327a5ad6)

con nano app.js lo creo
```
nano app.js
```
![image](https://github.com/user-attachments/assets/3d87746b-1398-4c50-975f-60ddea56beb0)

stesso per package.json
```
nano package.json
```
![image](https://github.com/user-attachments/assets/ee543f50-5007-4f10-89e5-9c1e85065728)

installo le dipendenze
```
sudo apt install npm e poi npm install
```
creazione del dockerfile
```
nano Dockerfile
```
![image](https://github.com/user-attachments/assets/8301da6f-f0ec-47f4-8ac9-3b96b982efb6)

costruzione dell'immagine docker
```
sudo docker build -t hello-docker .
```
controllo che sia stata creata
```
sudo docker images
```
![image](https://github.com/user-attachments/assets/0c5f4914-f403-4fbb-a2c4-87adb3ab056a)


## *Deployment dell'applicazione:*

creo i file yaml per il deployment
```
nano deployment.yaml
```
![image](https://github.com/user-attachments/assets/a27def56-81d3-494c-9af9-380cc3be6aaf)

stesso per i servizi
```
nano service.yaml
```

![image](https://github.com/user-attachments/assets/b82fab4e-bbaf-4206-bbac-cb90cd56f510)

li applico entrambi con comando admin
```
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml
```
verifico i pods
```
sudo kubectl get pods
```

![image](https://github.com/user-attachments/assets/77a0e0f3-447c-42b0-9afc-c32a9371ab9f)

vado sul browser del mio pc tramite ip pubblico e porta e verifico l'helloworld
```
http://51.145.165.106:30080/
```
![image](https://github.com/user-attachments/assets/d1dfbf7d-3a95-4318-bd94-651cd694a246)

Alberatura finale del progetto

![image](https://github.com/user-attachments/assets/3eb46e26-4765-4820-9f2b-71f4b042c28f)

