#!/bin/sh

# Date of the day
DATE=`date +%Y-%m-%d`
# File name
NAME="backup-$DATE.tar.gz"
# Log file for current script
DIRLOG="./log"
LOG="${DIRLOG}/${DATE}_log.log"
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
tar -cvzf backup-$DATE_FORMAT.tar.gz $DIRTOBCK > $DIRBCK

echo "Connect to FTP server and send data"                >> $LOG
ftp -n $FTP_SERVER <<END
        user $FTP_LOGIN $FTP_PASS
        put $NAME $DIRUPLOAD/$NAME
        quit
END

echo "Remove local backup"                                >> $LOG
rm $DIRBCK/$NAME

echo "$(date +%F_%T) : == End =="                         >> $LOG
