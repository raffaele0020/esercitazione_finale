#!/bin/bash

# Impostazione per debug del script
set -e
exec > >(tee -i /tmp/setup_log.txt)
exec 2>&1

echo "=== Inizio setup $(date) ==="

# Creazione directory di lavoro
echo "=== Creazione directory di lavoro ==="
mkdir -p ~/provisioning/hello-docker
cd ~/provisioning/hello-docker

# Aggiorna il sistema e installa i pacchetti necessari
echo "=== Aggiornamento del sistema e installazione pacchetti essenziali ==="
sudo apt-get update -y
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release apt-transport-https nodejs npm

# Configurazione della chiave GPG di Docker
echo "=== Configurazione Docker ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Aggiungi il repository Docker
echo "=== Aggiunta repository Docker ==="
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Aggiornamento dei pacchetti e installazione di Docker
echo "=== Installazione Docker ==="
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Avvia e abilita il servizio Docker
echo "=== Avvio servizio Docker ==="
sudo systemctl enable --now docker

# Aggiungi l'utente corrente al gruppo docker
echo "=== Configurazione permessi Docker ==="
sudo usermod -aG docker $USER

# Installazione di K3s per la gestione del cluster Kubernetes
echo "=== Installazione K3s ==="
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Attendi che K3s sia avviato
echo "=== Attesa avvio K3s ==="
sleep 30

# Verifica la configurazione di kubectl
echo "=== Verifica configurazione kubectl ==="
sudo ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

# Impostazione dei permessi per il file kubeconfig
echo "=== Configurazione permessi kubeconfig ==="
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# Creazione del file `app.js` (Applicazione Node.js)
echo "=== Creazione app.js ==="
cat <<EOF > app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello, World! Applicazione Node.js su K3s');
});

app.listen(port, '0.0.0.0', () => {
    console.log(\`App listening at http://0.0.0.0:\${port}\`);
});
EOF

# Creazione del file `package.json` (Gestione delle dipendenze)
echo "=== Creazione package.json ==="
cat <<EOF > package.json
{
  "name": "hello-docker",
  "version": "1.0.0",
  "description": "A simple Dockerized Node.js app",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF

# Installazione delle dipendenze per Node.js
echo "=== Installazione dipendenze Node.js ==="
npm install

# Creazione del Dockerfile
echo "=== Creazione Dockerfile ==="
cat <<EOF > Dockerfile
FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./ 
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

# Avvio registry locale Docker
echo "=== Configurazione registry locale Docker ==="
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Costruzione dell'immagine Docker
echo "=== Build immagine Docker ==="
sudo docker build -t hello-docker:latest .

# Tag e push dell'immagine nel registry locale
echo "=== Push immagine nel registry locale ==="
sudo docker tag hello-docker:latest localhost:5000/hello-docker:latest
sudo docker push localhost:5000/hello-docker:latest

# Verifica che l'immagine sia stata creata e pubblicata
echo "=== Verifica immagini Docker ==="
sudo docker images

# Creazione del file YAML per il Deployment dei pod
echo "=== Creazione file deployment.yaml ==="
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  labels:
    app: nodejs_app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs_app
  template:
    metadata:
      labels:
        app: nodejs_app
    spec:
      containers:
      - name: nodejs-app
        image: localhost:5000/hello-docker:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
EOF

# Creazione del file YAML per il servizio
echo "=== Creazione file service.yaml ==="
cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app-service
spec:
  selector:
    app: nodejs_app
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30080
  type: NodePort
EOF

# Applicazione dei file YAML su Kubernetes
echo "=== Applicazione configurazioni Kubernetes ==="
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Verifica dei pod
echo "=== Verifica stato dei pod ==="
kubectl get pods --watch &
WATCH_PID=$!

# Attendi massimo 2 minuti che i pod siano in stato Running
WAIT_TIME=0
MAX_WAIT=120
while [ $WAIT_TIME -lt $MAX_WAIT ]; do
  RUNNING_PODS=$(kubectl get pods -l app=nodejs_app -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | wc -w)
  if [ "$RUNNING_PODS" -eq 3 ]; then
    echo "=== Tutti i pod sono in esecuzione ==="
    break
  fi
  sleep 5
  WAIT_TIME=$((WAIT_TIME + 5))
done

# Termina il processo watch
kill $WATCH_PID 2>/dev/null || true

# Mostra il servizio esposto
echo "=== Dettagli servizio Kubernetes ==="
kubectl get service nodejs-app-service

echo "=== Verifica accesso all'applicazione ==="
curl -s http://localhost:30080 || echo "Errore nell'accesso all'applicazione"

echo "=== Setup completato $(date) ==="
echo "=== Accedi all'applicazione: http://$(curl -s ifconfig.me):30080 ==="