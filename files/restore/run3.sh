#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

./node_modules/.bin/grunt clean
./node_modules/.bin/grunt aws_s3
./node_modules/.bin/grunt exec:unzip_wordpress
./node_modules/.bin/grunt copy:wordpress
./node_modules/.bin/grunt exec:unzip_db
#./node_modules/.bin/grunt exec:mysql_create_db
#./node_modules/.bin/grunt exec:mysql_grant_user
./node_modules/.bin/grunt exec:mysql_restore
./node_modules/.bin/grunt exec:replace_domain
