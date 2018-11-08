#!/usr/bin/env bash

echo Stop current IMDB Docker container
sudo -S <<< "password" docker stop IMDB

echo Remove current IMDB Docker container
sudo -S <<< "password" docker rm IMDB

echo Create a fresh Docker IMDB container
echo Starting oracle/database:11.2.0.2-xe in Docker container
sudo -S <<< "password" docker run -d -p 1521:1521 -p 8081:8080 -e ORACLE_ALLOW_REMOTE=true -e ORACLE_PWD=oracle -v /u01/app/oracle/oradata --shm-size=4G --name IMDB oracle/database:11.2.0.2-xe

echo Pause a minute to allow Oracle to start up
sleep 60

echo Install Schema
liquibase --changeLogFile=src/main/db/IMDB-schema.xml update

echo Commit and push the Docker Oracle container with just schema as a Docker image
sudo -S <<< "password"  docker commit -a howarddeiner -m "IMDB Schema" IMDB howarddeiner/imdb:schema
sudo -S <<< "password"  docker push howarddeiner/imdb:schema

echo Create the database loader that will run in an EC2
mvn clean compile package