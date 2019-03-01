#!/bin/sh

# Date du jour
DATE=`date +%Y-%m-%d`
# Hote FTP
FTP_SERVER=""
# Login FTP
FTP_LOGIN=""
# Pass FTP
FTP_PASS=""
# Dossier à sauvergarder (dossier dans lequel les sites sont placés)
DIRTOBCK="/var/www/html/owncloud/DrWhat/files/Marvel"
# Dossier de sauvegarde temporaire des sites
DIRBCK="/var/archives"
# Nom du fichier
NAME="backup-$DATE.tar.gz"
# Destination
DIRUPLOAD="/owncloud/DrWhat"

# Création du répertoire de sauvegarde
if [ ! -d $DIRBCK ]; then
  mkdir -p $DIRBCK
fi

# echo "Création de l'archive des sites"
tar -cvzf backup-$DATE_FORMAT.tar.gz $DIRTOBCK > $DIRBCK

# echo "Connexion au serveur FTP et envoi des données"
ftp -n $FTP_SERVER <<END
        user $FTP_LOGIN $FTP_PASS
        put $NAME $DIRUPLOAD/$NAME
        quit
END

# echo "Suppression de l'archive de sauvegarde"
rm $DIRBCK/$NAME