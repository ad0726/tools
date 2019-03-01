#!/bin/sh

# Date du jour
DATE=`date +%Y-%m-%d`
# Dossier à sauvergarder (dossier dans lequel les sites sont placés)
DIRTOBCK="/var/www/html/owncloud/DrWhat/files/Marvel"
# Dossier de sauvegarde temporaire des sites
DIRBCK="/var/archives"
# Nom du fichier
NAME="backup-$DATE.tar.gz"
# Destination
DIRUPLOAD="/owncloud/DrWhat"
# Log file for current script
DIRLOG="./log"
LOG="${DIRLOG}/${DATE}_log.log"
# Sensitive vars : FTP_SERVER FTP_LOGIN and FTP_PASS
source .env

echo "$(date +%F_%T) : == Starting $0 =="               >> $LOG
echo "my Process ID is `$$`"                            >> $LOG
echo "Création du répertoire de sauvegarde"             >> $LOG
if [ ! -d $DIRBCK ]; then
  mkdir -p $DIRBCK
fi
echo "Création du répertoire de log"                    >> $LOG
if [ ! -d $DIRLOG ]; then
  mkdir -p $DIRLOG
fi
echo "Création de l'archive des sites"                  >> $LOG
tar -cvzf backup-$DATE_FORMAT.tar.gz $DIRTOBCK > $DIRBCK

echo "Connexion au serveur FTP et envoi des données"    >> $LOG
ftp -n $FTP_SERVER <<END
        user $FTP_LOGIN $FTP_PASS
        put $NAME $DIRUPLOAD/$NAME
        quit
END

echo "Suppression de l'archive de sauvegarde"           >> $LOG
rm $DIRBCK/$NAME

echo "$(date +%F_%T) : == End =="                       >> $LOG
