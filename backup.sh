#!/bin/sh
# todo : maybe add `cd $ROOT` at the begining of this script to secure cron tab execution
# cron are run with pwd = /root or user ~
# ROOT="/FULLPATH/OF/THIS/SCRIPT/DIRECTORY"
# cd $ROOT

# Date of the day
TODAY=`date +%Y-%m-%d`
# Folder to save (sites are here)
# todo : maybe move to .env ?
DIRTOBCK="/var/www/html/owncloud/DrWhat/files/Marvel"
# backups destination folder
DIRBCK="/var/archives"
# logs folder
DIRLOG="./log"
# Nom du fichier de sauvegarde
BCK_NAME="backup-$TODAY.tar.gz"
# Chemin complet
BCK="${DIRBCK}/${BCK_NAME}"
# Log file for current script
LOG="${DIRLOG}/${TODAY}_log.log"
# Sensitive vars : FTP_SERVER FTP_LOGIN and FTP_PASS
source .env

echo "$(date +%F_%T) : == Starting $0 =="                 >> $LOG
echo "My Process ID is `$$`"                              >> $LOG

if [ ! -d $DIRBCK ]; then
  echo "Establishment of the backup directory"            >> $LOG
  mkdir -p $DIRBCK
fi
if [ ! -d $DIRLOG ]; then
  echo "Establishment of the log directory"               >> $LOG
  mkdir -p $DIRLOG
fi
echo "Establishment of the backup"                        >> $LOG
tar -cvzf $BCK $DIRTOBCK

echo "Connect to FTP server and send data"                >> $LOG
ftp -n $FTP_SERVER <<END
        user $FTP_LOGIN $FTP_PASS
        put $BCK $DIRUPLOAD/
        quit
END

echo "Remove local backup"                                >> $LOG
rm $BCK

echo "$(date +%F_%T) : == End =="                         >> $LOG
