#!/usr/bin/env bash

source /usr/local/bin/unhinged-vars.sh

# ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23
SSH_CMD="-i ~/.ssh/aws-development.pem ubuntu@34.236.35.23"
PRODUCTION_DOMAIN=${PWD##*/}
DEV_DOMAIN=`echo ${PRODUCTION_DOMAIN} | sed -E 's,(\.[^\.]*$),.dev.unhingedweb.com,'`
PRODUCTION_FLATTENED=`echo ${PRODUCTION_DOMAIN} | sed -E 's,[^a-zA-Z0-9],,g'`
DEV_FLATTENED=`echo ${DEV_DOMAIN} | sed -E 's,[^a-zA-Z0-9],,g'`

echo "DOMAINS:"
echo "  production: $PRODUCTION_DOMAIN"
echo "  prod flat:  $PRODUCTION_FLATTENED"
echo "  dev:        $DEV_DOMAIN"
echo "  dev flat:   $DEV_FLATTENED"
echo ""

DEFAULT_WEB_FOLDER="/var/www"
SITES_BASE="/data/Sites"
PROJECT_WEB_BASE="web"
PROJECT_SQL_BASE="sql"

DEFAULT_WEB="$DEFAULT_WEB_FOLDER/$DEV_FLATTENED"
PROJECT_BASE="$SITES_BASE/$PRODUCTION_DOMAIN"
WEB_FOLDER="$PROJECT_BASE/$PROJECT_WEB_BASE"
SQL_FOLDER="$PROJECT_BASE/$PROJECT_SQL_BASE"

echo "FOLDERS:"
echo "  default: $DEFAULT_WEB"
echo "  project: $PROJECT_BASE"
echo "  web:     $WEB_FOLDER"
echo "  sql:     $SQL_FOLDER"
echo ""

echo "sudo virtualhost create $DEV_DOMAIN"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "sudo virtualhost create $DEV_DOMAIN"



#file system mods

echo "rm -R $DEFAULT_WEB"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "sudo rm -R $DEFAULT_WEB"

echo "mkdir -p $WEB_FOLDER"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "mkdir -p $WEB_FOLDER && chmod 774 -R $WEB_FOLDER"

echo "mkdir -p $SQL_FOLDER"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "mkdir -p $SQL_FOLDER"

echo "ln -s $WEB_FOLDER/ $DEFAULT_WEB"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "ln -s $WEB_FOLDER/ $DEFAULT_WEB"





# uploading files

echo "rsync ... web/ ubuntu@dev.unhingedweb.com:$WEB_FOLDER"
rsync -az --exclude='.git' web/ ubuntu@dev.unhingedweb.com:$WEB_FOLDER





#uploading database backup
DB_FILE=`ls -t sql/*.sql | head -1`
if [ ! -z "$DB_FILE" ]
then
  DB_FILE=$(basename $DB_FILE)
  echo "scp ... 'sql/$DB_FILE' ubuntu@34.236.35.23:'$SQL_FOLDER/$DB_FILE'"
  scp -i ~/.ssh/aws-development.pem "sql/$DB_FILE" ubuntu@34.236.35.23:"$SQL_FOLDER/$DB_FILE"
fi

# creating database
echo "/home/ubuntu/create_database.sh $PRODUCTION_DOMAIN $DB_FILE"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "create-database.sh $PRODUCTION_DOMAIN $DB_FILE"



echo "sudo service apache2 reload"
ssh -i ~/.ssh/aws-development.pem ubuntu@34.236.35.23 "sudo service apache2 reload"
