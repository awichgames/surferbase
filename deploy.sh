#!/bin/bash

apt update
dpkg --configure -a
apt install -y wget nano screen

sed -i 's/\r$//' /home/runner/start.sh
chmod +x /home/runner/start.sh
screen -dmS tor_proxies bash -c '/home/runner/start.sh 15; exec bash'

echo "Le conteneur 9hits existe déjà. Démarrage du conteneur..."
docker start 9hits
