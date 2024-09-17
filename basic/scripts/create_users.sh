#!/bin/bash

# Nome del container Docker di Nextcloud
NEXTCLOUD_CONTAINER_NAME="cloud_exam-app-1"

# Password predefinita per tutti gli utenti
DEFAULT_PASSWORD='test_password1234!'

# Quota di spazio disco per ogni utente (es. 1G, 500M, ...)
USER_QUOTA="3G"

# Gruppo per l'utente (es. "admin" per amministratori, "users" per utenti normali)
USER_GROUP="users"

for i in {0..69}
do
    # Costruisce lo username
    USERNAME="locust_user${i}"

    # Esegue il comando occ all'interno del container Docker per creare l'utente
    docker exec -e OC_PASS="$DEFAULT_PASSWORD" --user www-data $NEXTCLOUD_CONTAINER_NAME /var/www/html/occ user:add --password-from-env --group="$USER_GROUP" "$USERNAME"
    
    # Imposta la quota per l'utente appena creato
    docker exec --user www-data $NEXTCLOUD_CONTAINER_NAME /var/www/html/occ user:setting "$USERNAME" files quota "$USER_QUOTA"

    echo "Creato utente $USERNAME con quota $USER_QUOTA e nel gruppo $USER_GROUP"
done

echo "Processo di creazione degli utenti completato."
