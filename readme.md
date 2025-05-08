## Implementazione di un cluster K3s su Azure con Terraform e Docker
Si vuole implementare un'infrastruttura su Azure utilizzando Terraform che consiste in un cluster K3s ad alta disponibilità con 3 nodi. Su questo cluster verrà deployato un progetto Docker fornito e disponibile al seguente indirizzo

https://github.com/MrMagicalSoftware/docker-k8s/blob/main/esercitazione-docker-file.md


## *CREAZIONE RISORSE AZURE*

Per cominciare, dobbiamo accedere al nostro account Azure tramite la riga di comando, questo comando aprirà una finestra del browser dove dovremo inserire le nostre credenziali Azure. Una volta effettuato l'accesso, torneremo automaticamente sulla riga di comando.
```
az login
```
![image](https://github.com/user-attachments/assets/1e9b26ec-9b90-4692-984e-b1ef48317fb1)

Se abbiamo più sottoscrizioni, dobbiamo selezionare quella corretta. Per farlo, eseguiamo:
```
az account set --subscription "b7b99826-3835-4054-891a-696b78a0d1ba"
```


Per organizzare al meglio il nostro lavoro, creiamo una cartella dove verranno salvati tutti i file relativi a questa esercitazione. Andiamo quindi nella cartella del nostro progetto con:
```
cd C:\Users\tufan\esercitazione_finale
```
Ora dobbiamo inizializzare Terraform per prepararlo alla creazione delle risorse, questo scarica i plugin necessari per il provider Azure e imposta l'ambiente di lavoro. Eseguiamo il comando:
```
terraform init
```
Prima di creare le risorse, possiamo vedere cosa verrà creato da Terraform con il comando
```
terraform plan
```
Per accedere alla VM che Terraform creerà, dobbiamo generare una chiave SSH, accettiamo il percorso predefinito per la chiave, premendo 2 volte invio. Eseguiamo il comando:

```
ssh-keygen -t rsa -b 4096
```

Finalmente, possiamo applicare le configurazioni di Terraform per creare tutte le risorse su Azure. Eseguiamo:

```
terraform apply
```

Abbiamo concluso con la creazione delle risorse azure.



## *Configurazione del cluster K3s:*

Dopo che Terraform ha creato la nostra infrastruttura, possiamo accedere alla VM appena creata usando il comando SSH, dove 51.145.165.106 è l'indirizzo IP pubblico della VM che ci fornirà Terraform.

```
ssh raffaeleuser@51.145.165.106
```
![image](https://github.com/user-attachments/assets/f43a393b-f31d-4fff-92d3-477ed24a5bf0)

Ora dobbiamo installare Docker sulla nostra VM per poter containerizzare l'applicazione. Eseguiamo il comando: 
```
curl -fsSL https://get.docker.com | sudo bash
```
Dopo aver installato Docker, aggiungiamo l'utente corrente al gruppo Docker, in modo da poter usare i comandi Docker senza dover usare sudo ogni volta:
```
sudo usermod -aG docker $USER
newgrp docker
```

Per installare K3s (una versione leggera di Kubernetes), eseguiamo:
```
curl -sfL https://get.k3s.io | sh -
```
Questo comando installerà K3s e lo avvierà automaticamente,dovremmo vedere un nodo "Ready" che rappresenta il nostro master K3s. Verifichiamo che K3s sia in esecuzione con:

```
sudo kubectl get nodes
```
![image](https://github.com/user-attachments/assets/2403fa35-0c10-47d4-afb2-af0873b560f2)

Creiamo una nuova cartella per il nostro progetto Docker. La chiamiamo hello-docker
```
mkdir hello-docker
```
mi sposto in hello docker
```
cd hello-docker
```
![image](https://github.com/user-attachments/assets/b683954f-c8fa-46ec-a592-3256327a5ad6)

All'interno della cartella, creiamo un file app.js che contiene il codice per la nostra applicazione Node.js. Eseguiamo:
```
nano app.js
```
![image](https://github.com/user-attachments/assets/3d87746b-1398-4c50-975f-60ddea56beb0)

Creiamo un file package.json per definire le dipendenze del progetto. Eseguiamo:
```
nano package.json
```
![image](https://github.com/user-attachments/assets/ee543f50-5007-4f10-89e5-9c1e85065728)

Installiamo le dipendenze, le librerie necessarie per il progetto, con il comando:
```
sudo apt install npm e poi npm install
```
Ora creiamo il Dockerfile per containerizzare l'applicazione. Eseguiamo:
```
nano Dockerfile
```
![image](https://github.com/user-attachments/assets/8301da6f-f0ec-47f4-8ac9-3b96b982efb6)

Adesso possiamo costruire l'immagine Docker per l'applicazione:
```
sudo docker build -t hello-docker .
```
cVerifichiamo che l'immagine sia stata creata con:
```
sudo docker images
```
![image](https://github.com/user-attachments/assets/0c5f4914-f403-4fbb-a2c4-87adb3ab056a)


## *Deployment dell'applicazione:*

Creiamo un file YAML per definire il deployment dell'applicazione su K3s. Eseguiamo:

```
nano deployment.yaml
```
![image](https://github.com/user-attachments/assets/a27def56-81d3-494c-9af9-380cc3be6aaf)

stesso per i servizi
```
nano service.yaml
```

![image](https://github.com/user-attachments/assets/b82fab4e-bbaf-4206-bbac-cb90cd56f510)

Applichiamo i file YAML a K3s per creare il deployment e il servizio:
```
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml
```
Verifica lo stato dei pod e del servizio con:
```
sudo kubectl get pods
```

![image](https://github.com/user-attachments/assets/77a0e0f3-447c-42b0-9afc-c32a9371ab9f)

Ora, per verificare che tutto funzioni correttamente, apriamo un browser e accediamo all'applicazione utilizzando l'IP pubblico della nostra VM e la porta 30080:
```
http://51.145.165.106:30080/
```
![image](https://github.com/user-attachments/assets/d1dfbf7d-3a95-4318-bd94-651cd694a246)

Alberatura finale del progetto

![image](https://github.com/user-attachments/assets/3eb46e26-4765-4820-9f2b-71f4b042c28f)


Abbiamo configurato un cluster K3s su Azure, installato Docker e Kubernetes (K3s), creato un'applicazione Node.js, containerizzato l'applicazione con Docker, e infine distribuito l'applicazione nel cluster Kubernetes. Ora l'app è accessibile pubblicamente tramite il servizio NodePort su Azure.




## PARTE 2 ESERCITAZIONE CON SCRIPT SH

Abbiamo automatizzato la creazione e configurazione di una VM su Azure tramite un file Terraform (main.tf), includendo un provisioning script per installare Docker e Kubernetes (K3s) automaticamente sulla macchina virtuale appena creata. 

Aggiunta del Provisioning Script:

Abbiamo inserito uno script di provisioning (setup.sh) utilizzando i provisioner di Terraform.

Lo script di provisioning esegue i seguenti passaggi:

Aggiornamento della VM e installazione dei pacchetti necessari,i nstallazione di Docker, la sua configurazione e l'avvio del servizio.

Installazione di K3s, configurazione e avvio di Kubernetes sulla macchina.

Creazione di un'applicazione Node.js (hello-docker), inclusi i file necessari come app.js, package.json, e la creazione del Dockerfile.

Costruzione dell'immagine Docker e il suo utilizzo in Kubernetes.

Creazione dei file YAML per il deployment e il servizio Kubernetes, utilizzando kubectl per applicarli.

Esecuzione automatica:

Abbiamo utilizzato i provisioner di Terraform:

file: per copiare lo script dalla macchina locale alla VM.

remote-exec: per eseguire lo script sulla VM.

Lo script, una volta eseguito, automatizza l'installazione di tutte le risorse necessarie sulla VM, garantendo che l'applicazione Node.js venga deployata su un cluster Kubernetes con Docker installato.
![image](https://github.com/user-attachments/assets/1f66141a-5609-4b4f-8dbb-b585e6a87486)


Come funziona:
Una volta che la configurazione di Terraform è stata eseguita con il comando terraform apply, la macchina virtuale viene creata.

Durante la creazione, lo script di provisioning viene copiato sulla VM e successivamente eseguito automaticamente.

Questo processo garantisce che Docker e Kubernetes siano configurati correttamente, che l'applicazione Node.js sia creata e che tutto venga eseguito senza intervento manuale.

![image](https://github.com/user-attachments/assets/367160f4-c8a6-4536-9149-f5d0a74b5795)


Risultato Finale:
Il risultato finale è un'infrastruttura completamente automatizzata, dove la creazione della VM, l'installazione di Docker e Kubernetes, la creazione dell'applicazione Node.js e il suo deployment su Kubernetes vengono eseguiti automaticamente, senza la necessità di interventi manuali.


