#!/bin/bash

# Forcer un environnement propre
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root  # ou l’utilisateur qui a installé ollama

# Exécuter ollama ps et supprimer les couleurs ANSI
/usr/local/bin/ollama ps | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'


#chmod +x /usr/local/bin/ollama-wrapper.sh
#sudo -u www-data /usr/local/bin/ollama-wrapper.sh
