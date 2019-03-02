#!/bin/sh

# Import some vars from env
source .env
# Date of the day
TODAY=`date +%Y-%m-%d`
# Backup file name
BCK_NAME="backup-$TODAY.tar.gz"
# Backup complet path
BCK="${DIRBCK}/${BCK_NAME}"
# Log file for current script
LOG="${DIRLOG}/${TODAY}_log.log"

echo "$(date +%F_%T) : == Starting $0 =="                 >> $LOG
echo "My Process ID is `$$`"                              >> $LOG

cd $DIR_SCRIPT

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

cd -
