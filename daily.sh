#! /bin/sh

# Daily MYSQL Backup

# date suffix to append to file
suffix=$(date +%Y.%m.%d)

# save directory, don't forget trailing slash
savePath="/path/to/directory/"

# email data
email="your@email.here"
subject="Database Backups ${suffix}"


# db credentials
username="username"
password="password"

result=""

while read line
do
	database=$(echo $line | cut -d: -f1)
	domain=$(echo $line | cut -d: -f2)

	# set current path
	cpath=$savePath$domain
	hostname=$domain

	# create directory if it does not exist
	if [ ! -d "$cpath" ]; then
		mkdir -p $cpath;
	fi

	# sql file
	SQLFILE=${cpath}/$suffix.sql.gz

	# retrieve mysql dump
	mysqldump -c -h $hostname -u $username -p$password $database 2>error | gzip > $SQLFILE
	if [ -s error ]
	then
		result="$resultWARNING: An error occured while attempting to backup $database \n\tError:\n\t $error\n"
		#rm -f error
	else
		result="$result$database was backed up successfully to $SQLFILE.\n"
	fi
done < info.txt

echo -e $result >> message.txt
mail -s "$subject" $email < message.txt

rm -f message.txt