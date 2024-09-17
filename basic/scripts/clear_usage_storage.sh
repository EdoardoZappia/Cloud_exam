#!/bin/bash

# Nome del container Docker di Nextcloud
NEXTCLOUD_CONTAINER_NAME="cloud_exam-app-1"

# Contenuto del file Readme.md
README_CONTENT="Benvenuto nel tuo spazio Nextcloud!"

for i in {0..69}
do
    # Costruisce lo username
    USERNAME="locust_user${i}"

    # Esegue il comando occ all'interno del container Docker per rimuovere i file dello storage dell'utente
    docker exec --user www-data $NEXTCLOUD_CONTAINER_NAME sh -c "rm -rf /var/www/html/data/$USERNAME/files/*"

    # Esegue il comando occ per ripulire eventuali dati residui nella cache dei file
    docker exec --user www-data $NEXTCLOUD_CONTAINER_NAME /var/www/html/occ files:scan --path="$USERNAME/files"

    # Ricrea il file Readme.md nella directory dell'utente
    echo "$README_CONTENT" | docker exec -i --user www-data $NEXTCLOUD_CONTAINER_NAME tee /var/www/html/data/$USERNAME/files/Readme.md > /dev/null

    # Imposta i permessi corretti per la directory e il file
    docker exec --user root $NEXTCLOUD_CONTAINER_NAME chown -R www-data:www-data /var/www/html/data/$USERNAME/files

    echo "Storage dell'utente $USERNAME ripulito e aggiunto Readme.md."
done

echo "Processo di pulizia degli storage degli utenti completato."
