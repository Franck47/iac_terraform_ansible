#!/bin/bash
name=$1

cp envFile envFile_bkup

password=`openssl rand -base64 12`
root_password=`openssl rand -base64 12`

echo "# DB engine config user & password" >> envFile
echo "DB_NAME=${name}_db" >> envFile
echo "DB_USERNAME=${name}_dbu" >> envFile
echo "DB_PASSWORD=${password}" >> envFile
echo "DB_ROOT_PASSWORD=${root_password}" >> envFile

echo ""
tail -n 5 envFile

echo ""
mv -v envFile ../.env
mv envFile_bkup envFile