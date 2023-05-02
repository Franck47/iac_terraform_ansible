#!/bin/sh
pass =`sed -n 's/^DB_ROOT_PASSWORD=\(.*\)/\1/p' < /home/fondamental/data/.env`
mysql -u root -p$pass  << eof
CREATE DATABASE $1_staging;
CREATE DATABASE $1_release;
GRANT ALL PRIVILEGES ON $1_db.* TO '$1_dbu'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON $1_staging.* TO '$1_dbu'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON $1_release.* TO '$1_dbu'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
eof
