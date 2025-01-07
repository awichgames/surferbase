#!/bin/bash

apt update
dpkg --configure -a
apt install -y wget nano screen

systemctl start docker
systemctl enable docker

pkill -f tor
screen -ls | grep -oP '\d+\.\w+' | while read session_id; do
    screen -X -S "$session_id" quit
done

sleep 2

sed -i 's/\r$//' /home/runner/start.sh
chmod +x /home/runner/start.sh
screen -dmS tor_proxies bash -c '/home/runner/start.sh 15; exec bash'

pkill -f tor
screen -ls | grep -oP '\d+\.\w+' | while read session_id; do
    screen -X -S "$session_id" quit
done

screen -dmS tor_proxies bash -c '/home/runner/start.sh 15; exec bash'

max_attempts=3
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "Tentative de démarrage $attempt/$max_attempts..."
    docker start 9hits

    if docker ps --format '{{.Names}}' | grep -q '^9hits$'; then
        echo "Le conteneur 9hits a été démarré avec succès."
        break
    else
        echo "Échec du démarrage du conteneur 9hits. Réessai dans 5 secondes..."
        sleep 5
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Échec du démarrage du conteneur 9hits après $max_attempts tentatives."
fi
