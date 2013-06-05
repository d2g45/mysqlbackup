#! /bin/sh

# Monthly MYSQL Backup

# date suffix to append to file
filename=$(date --date="yesterday" +%Y.%m)

# save directory
savePath="/path/to/directory/"

# email data
email="your@email.here"
subject="Monthly Database Backups ${suffix}"


# db credentials
result=""

while read line
do
	database=$(echo $line | cut -d: -f1)
	domain=$(echo $line | cut -d: -f2)

	# set current path
	cpath=$savePath$domain

	# create directory if it does not exist
	if [ ! -d "$cpath" ]; then
		mkdir -p $cpath;
	fi

	# sql file
	TARFILE=${cpath}/$filename.tar.gz

	tar -cvzf $TARFILE ${cpath}/$filename.*.sql.gz
	if [ -s error ]
	then
		result="$resultWARNING: An error occured while attempting to backup $domain \n\tError:\n\t $error\n"
		#rm -f error
	else
		result="$result$domain's MYSQL backups for the month of $suffix has been archived [$TARFILE].\n"
	fi

	rm -rf ${cpath}/${filename}.*.sql.gz
done < info.txt

echo -e $result >> monthly.txt
mail -s "$subject" $email < monthly.txt

rm -f message.txt