#!/usr/bin/env bash

# First, add the GPG key for the official Docker repository to the system:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources:
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Next, update the package database with the Docker packages from the newly added repo:
sudo apt-get update

# Finally, install Docker:
sudo apt-get install -y docker-ce

# AUTHENTICATE - FIX  THIS!!!
sudo docker login -u howarddeiner -p hjd001

# Bring in the schema provisioned oracle image
sudo docker run -d -p 1521:1521 -p 8080:8080 -e ORACLE_ALLOW_REMOTE=true --name IMDB howarddeiner/imdb:schema

# Install java
sudo apt-get install -y default-jdk

echo Run the database load
java -cp target/testDatabaseAsCode-1.0.jar com.deinersoft.PopulateDatabase

echo Commit and push the Docker Oracle container with data loaded as a Docker image
sudo -S <<< "password"  docker commit -a howarddeiner -m "IMDB Schema" IMDB howarddeiner/imdb:dataloaded
sudo -S <<< "password"  docker push howarddeiner/imdb:dataloaded