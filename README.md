The goal of this project is to demonstrate how meaningful size databases can be built on command for test/QA type work using Docker and AWS/EC2.

We will build the IMDB database from scratch.  The input files are roughly 1.5GB.  We'll go through the following process:

* We will create an initial Oracle database container
* Locally, we put the schema into the database using Liquibase (note: we could easily target other database engines by making appropriate changes in liquibase.properties)
* That container is then committed and pushed to a DockerHub repository.
* We then use Teraform to create a substanial EC2 instance.  This is necessary, as it would take many hours to put all of the data into the database.
* We provision the EC2 instance, including the prebaked Docker container for the database.
* We then run the PopulateDatabase program, which does all of the heavy lifting as far as massaging the data into it needed form.  NOTE!  ONE THING THAT WE DEMONSTRATE HERE IS HOW TO AVOID A NON-DETERMINISM BASED ON DATES.  This is a large point of discussion within the CoP right now.  Here, we offset all dates (YEARS) by 5 years, making everything 5 years older than it really is now. 
* Next, we commit and push the Docker container again.  This time, it will be "fat" with all the data baked into it.
* Finally, we can pull the completed IMBD from the DockerHub repository.
* Note that any time we need a fresh copy of the database and it's data, it's merely a DockerHub pull away!

Nuts.  GitHub has a policy where they will not allow files greater than 100MB.  So, you'll have to put your own files from IMDB in the data directory.  See https://datasets.imdbws.com.

The processing was done on an r5.2xlarge instance.  It has 8 vCPUs, 38 ECUs, 64 GB memory, EBS storage (I configured 32GB), and costs $0.504 per hour.  Total processing time was roughly x.y hours (which includes all of the data transmission time from test machine to DockerHub for the bare schema, loading of data into the EC2 instance, and trasmission back to DockerHub once again for the fully data loaded container), which equates to less than a cup of coffee ($.$$).  Also, bear in mind that this was done on a network whose transmission speed never exceeded MB/s due to relatively modest network hardware.

Taking care of the propriety non Maven Repository ojdbc jar
https://geraldonit.com/2018/03/19/manually-installing-a-maven-artifact-in-your-local-repository/

Docker Oracle image was from the Oracle GitHub project (https://github.com/oracle/docker-images/blob/master/OracleDatabase/SingleInstance/README.md) locally in
```bash
~/oracle-docker-images/OracleDatabase/SingleInstance/dockerfiles
```

using 
```bash
sudo ./buildDockerImage.sh -v 11.2.0.2 -x
```

First, there is a local build of the Oracle database and it's schema.  This is pushed to DockerHub.
``bash
howarddeiner@ubuntu:~/IdeaProjects/testDatabaseAsCode$ ./buildDockerDatabase.sh 
Stop current IMDB Docker container
[sudo] password for howarddeiner: IMDB
Remove current IMDB Docker container
IMDB
Create a fresh Docker IMDB container
Starting oracle/database:11.2.0.2-xe in Docker container
9e31505c38a253d4c5c13be9ad045bf25a69303c2520efcc2e22fc6c69664ad6
Pause a minute to allow Oracle to start up
Install Schema
Starting Liquibase at Thu, 08 Nov 2018 12:51:05 EST (version 3.6.1 built at 2018-04-11 08:41:04)
Liquibase: Update has been successful.
Commit and push the Docker Oracle container with jusr schema as a Docker image
sha256:9ccb3b6f8e3b3929e7d5d0f6c06dbb469eaad4da27d9a68320982fcc0952447d
The push refers to repository [docker.io/howarddeiner/imdb]
52478a84c984: Pushed 
29da1cbb2eba: Pushed 
88e9a644bf76: Pushed 
bcaa84a0d085: Mounted from library/oraclelinux 
schema: digest: sha256:4e34dcba41de7ab807cc83a255655d4fe42ef06ea644afc9838d76e38a1d9432 size: 1168
Create the database loader that will run in an EC2
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building testDatabaseAsCode 1.0
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ testDatabaseAsCode ---
[INFO] Deleting /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ testDatabaseAsCode ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 0 resource
[INFO] 
[INFO] --- maven-compiler-plugin:3.5.1:compile (default-compile) @ testDatabaseAsCode ---
[INFO] Changes detected - recompiling the module!
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[INFO] Compiling 9 source files to /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/classes
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ testDatabaseAsCode ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 0 resource
[INFO] 
[INFO] --- maven-compiler-plugin:3.5.1:compile (default-compile) @ testDatabaseAsCode ---
[INFO] Nothing to compile - all classes are up to date
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:testResources (default-testResources) @ testDatabaseAsCode ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /home/howarddeiner/IdeaProjects/testDatabaseAsCode/src/test/resources
[INFO] 
[INFO] --- maven-compiler-plugin:3.5.1:testCompile (default-testCompile) @ testDatabaseAsCode ---
[INFO] Nothing to compile - all classes are up to date
[INFO] 
[INFO] --- maven-surefire-plugin:2.17:test (default-test) @ testDatabaseAsCode ---
[INFO] No tests to run.
[INFO] 
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ testDatabaseAsCode ---
[INFO] Building jar: /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/testDatabaseAsCode-1.0.jar
[INFO] 
[INFO] --- maven-dependency-plugin:3.1.1:copy-dependencies (copy-dependencies) @ testDatabaseAsCode ---
[INFO] Copying univocity-parsers-2.7.6.jar to /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/lib/univocity-parsers-2.7.6.jar
[INFO] Copying ojdbc-12.2.0.1.jar to /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/lib/ojdbc-12.2.0.1.jar
[INFO] 
[INFO] --- maven-resources-plugin:3.1.0:copy-resources (copy-resources) @ testDatabaseAsCode ---
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[WARNING] Please take a look into the FAQ: https://maven.apache.org/general.html#encoding-warning
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 1 resource
[INFO] 
[INFO] --- maven-shade-plugin:3.2.0:shade (default) @ testDatabaseAsCode ---
[INFO] Including com.univocity:univocity-parsers:jar:2.7.6 in the shaded jar.
[INFO] Including com.oracle:ojdbc:jar:12.2.0.1 in the shaded jar.
[INFO] Replacing original artifact with shaded artifact.
[INFO] Replacing /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/testDatabaseAsCode-1.0.jar with /home/howarddeiner/IdeaProjects/testDatabaseAsCode/target/testDatabaseAsCode-1.0-shaded.jar
[INFO] Dependency-reduced POM written at: /home/howarddeiner/IdeaProjects/testDatabaseAsCode/dependency-reduced-pom.xml
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 4.404 s
[INFO] Finished at: 2018-11-08T13:15:37-05:00
[INFO] Final Memory: 32M/604M
[INFO] ------------------------------------------------------------------------
````

Then, we Terraform the load environment, where the database is brought in from DockerHub, the files are processed, and a new image is pushed to DockerHub.
```bash
howarddeiner@ubuntu:~/IdeaProjects/testDatabaseAsCode$ cd terraform/
howarddeiner@ubuntu:~/IdeaProjects/testDatabaseAsCode/terraform$ terraform apply -auto-approve
[zillions of lines not shown]

[on the terraformed machine]
ubuntu@ip-172-31-94-68:~/data$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
howarddeiner/imdb   dataloaded          017d2ffc024b        10 minutes ago      1.7GB
howarddeiner/imdb   schema              9ccb3b6f8e3b        2 hours ago         1.42GB
```

Checking DockerHub at https://hub.docker.com/r/howarddeiner/imdb/tags/, we see that we have two images ready to go.  One with, and one without data.
```bash
PUBLIC REPOSITORY
howarddeiner/imdb
Last pushed: an hour ago

Repo Info  Tags  Collaborators  Webhooks  Settings

Tag Name    Compressed Size  Last Updated
dataloaded  1 GB             an hour ago
schema      889 MB           2 hours ago
```

We can then pull that image and do our work.

``bash
howarddeiner@ubuntu:~/IdeaProjects/testDatabaseAsCode/terraform$ sudo -S <<< "password" docker run -d -p 1521:1521 -p 8081:8080 -e ORACLE_ALLOW_REMOTE=true -e ORACLE_PWD=oracle -v /u01/app/oracle/oradata --shm-size=4G --name IMDB howarddeiner/imdb:dataloaded
b49e8588b3dabdc96112194b05b25c95fb0a7067b2b9f76795001330ef203788

howarddeiner@ubuntu:~/IdeaProjects/testDatabaseAsCode$ sqlplus system/oracle@localhost:1521/xe

SQL*Plus: Release 11.2.0.1.0 Production on Thu Nov 8 15:09:14 2018

Copyright (c) 1982, 2009, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

SQL> select count(*) from title where primaryTitle like '%Fight%';

  COUNT(*)
----------
       230

``


Some statistics:

```bash
local performance
ROWS_IN_A_COMMIT = 10000
data/name.basics.tsv - 0% complete - elapsed time = 0:35 - remaining time = 531:02
data/name.basics.tsv - 1% complete - elapsed time = 4:46 - remaining time = 467:39
data/name.basics.tsv - 2% complete - elapsed time = 9:20 - remaining time = 452:59
```
```bash
ROWS_IN_A_COMMIT = 75000
data/name.basics.tsv - 0% complete - elapsed time = 3:58 - remaining time = 467:45
data/name.basics.tsv - 1% complete - elapsed time = 7:51 - remaining time = 458:23
data/name.basics.tsv - 2% complete - elapsed time = 11:36 - remaining time = 448:07
```

```bash
ROWS_IN_A_COMMIT = 75000 / DATABASE REMOVED  NOTICE THE 50000% PERFORMANCE PENALTY OF ORACLE!!!
data/name.basics.tsv - 0% complete - elapsed time = 0:00 - remaining time = 1:49
data/name.basics.tsv - 1% complete - elapsed time = 0:01 - remaining time = 1:06
data/name.basics.tsv - 2% complete - elapsed time = 0:01 - remaining time = 0:56
```

```bash
r5.2xlarge	8	38	64 GiB	EBS Only	$0.504 per Hour
ROWS_IN_A_COMMIT = 10000
data/name.basics.tsv - 0% complete - elapsed time = 0:26 - remaining time = 391:09
data/name.basics.tsv - 1% complete - elapsed time = 3:08 - remaining time = 307:43
data/name.basics.tsv - 2% complete - elapsed time = 6:11 - remaining time = 300:33
```

```bash
r5d.4xlarge	16	71	128 GiB	2 x 300 NVMe SSD	$1.152 per Hour
ROWS_IN_A_COMMIT = 10000
data/name.basics.tsv - 0% complete - elapsed time = 0:24 - remaining time = 365:54
data/name.basics.tsv - 1% complete - elapsed time = 2:49 - remaining time = 277:06
data/name.basics.tsv - 2% complete - elapsed time = 5:31 - remaining time = 268:00
```

```bash
c5d.9xlarge	36	141	72 GiB	1 x 900 NVMe SSD	$1.728 per Hour
ROWS_IN_A_COMMIT = 10000
data/name.basics.tsv - 0% complete - elapsed time = 0:20 - remaining time = 301:25
data/name.basics.tsv - 1% complete - elapsed time = 2:23 - remaining time = 234:21
data/name.basics.tsv - 2% complete - elapsed time = 4:44 - remaining time = 229:48
```

```bash
DEMO_MODE LOCAL RESULTS
ROWS_IN_A_COMMIT = 10000
data/name.basics.tsv - 11% complete - elapsed time = 0:41 - remaining time = 5:26
data/name.basics.tsv - 22% complete - elapsed time = 1:08 - remaining time = 3:55
data/name.basics.tsv - 33% complete - elapsed time = 1:37 - remaining time = 3:12
data/name.basics.tsv - 44% complete - elapsed time = 2:07 - remaining time = 2:36
data/name.basics.tsv - 56% complete - elapsed time = 2:38 - remaining time = 2:04
data/name.basics.tsv - 67% complete - elapsed time = 3:08 - remaining time = 1:31
data/name.basics.tsv - 78% complete - elapsed time = 3:37 - remaining time = 0:59
data/name.basics.tsv - 89% complete - elapsed time = 4:06 - remaining time = 0:27
data/name.basics.tsv - 100% complete - elapsed time = 4:33 - remaining time = 0:00
data/title.akas.tsv - 27% complete - elapsed time = 0:06 - remaining time = 0:17
data/title.akas.tsv - 54% complete - elapsed time = 0:12 - remaining time = 0:10
data/title.akas.tsv - 81% complete - elapsed time = 0:18 - remaining time = 0:04
data/title.akas.tsv - 100% complete - elapsed time = 0:22 - remaining time = 0:00
data/title.basics.tsv - 18% complete - elapsed time = 0:15 - remaining time = 1:05
data/title.basics.tsv - 37% complete - elapsed time = 0:30 - remaining time = 0:51
data/title.basics.tsv - 56% complete - elapsed time = 0:48 - remaining time = 0:37
data/title.basics.tsv - 74% complete - elapsed time = 1:06 - remaining time = 0:22
data/title.basics.tsv - 93% complete - elapsed time = 1:22 - remaining time = 0:05
data/title.basics.tsv - 100% complete - elapsed time = 1:28 - remaining time = 0:00
data/title.crew.tsv - 18% complete - elapsed time = 0:11 - remaining time = 0:50
data/title.crew.tsv - 37% complete - elapsed time = 0:28 - remaining time = 0:46
data/title.crew.tsv - 56% complete - elapsed time = 0:45 - remaining time = 0:35
data/title.crew.tsv - 74% complete - elapsed time = 1:03 - remaining time = 0:21
data/title.crew.tsv - 93% complete - elapsed time = 1:29 - remaining time = 0:06
data/title.crew.tsv - 100% complete - elapsed time = 1:38 - remaining time = 0:00
data/title.episode.tsv - 27% complete - elapsed time = 0:06 - remaining time = 0:17
data/title.episode.tsv - 55% complete - elapsed time = 0:11 - remaining time = 0:09
data/title.episode.tsv - 82% complete - elapsed time = 0:17 - remaining time = 0:03
data/title.episode.tsv - 100% complete - elapsed time = 0:20 - remaining time = 0:00
data/title.principals.tsv - 3% complete - elapsed time = 0:05 - remaining time = 2:39
data/title.principals.tsv - 6% complete - elapsed time = 0:10 - remaining time = 2:34
data/title.principals.tsv - 9% complete - elapsed time = 0:16 - remaining time = 2:32
data/title.principals.tsv - 13% complete - elapsed time = 0:22 - remaining time = 2:29
data/title.principals.tsv - 16% complete - elapsed time = 0:28 - remaining time = 2:26
data/title.principals.tsv - 19% complete - elapsed time = 0:34 - remaining time = 2:21
data/title.principals.tsv - 23% complete - elapsed time = 0:40 - remaining time = 2:14
data/title.principals.tsv - 26% complete - elapsed time = 0:46 - remaining time = 2:10
data/title.principals.tsv - 29% complete - elapsed time = 0:51 - remaining time = 2:02
data/title.principals.tsv - 32% complete - elapsed time = 0:56 - remaining time = 1:55
data/title.principals.tsv - 36% complete - elapsed time = 1:01 - remaining time = 1:49
data/title.principals.tsv - 39% complete - elapsed time = 1:08 - remaining time = 1:44
data/title.principals.tsv - 42% complete - elapsed time = 1:13 - remaining time = 1:38
data/title.principals.tsv - 46% complete - elapsed time = 1:19 - remaining time = 1:33
data/title.principals.tsv - 49% complete - elapsed time = 1:25 - remaining time = 1:27
data/title.principals.tsv - 52% complete - elapsed time = 1:31 - remaining time = 1:22
data/title.principals.tsv - 55% complete - elapsed time = 1:37 - remaining time = 1:17
data/title.principals.tsv - 59% complete - elapsed time = 1:43 - remaining time = 1:11
data/title.principals.tsv - 62% complete - elapsed time = 1:49 - remaining time = 1:05
data/title.principals.tsv - 65% complete - elapsed time = 1:56 - remaining time = 1:00
data/title.principals.tsv - 69% complete - elapsed time = 2:03 - remaining time = 0:54
data/title.principals.tsv - 72% complete - elapsed time = 2:09 - remaining time = 0:49
data/title.principals.tsv - 75% complete - elapsed time = 2:15 - remaining time = 0:43
data/title.principals.tsv - 79% complete - elapsed time = 2:22 - remaining time = 0:37
data/title.principals.tsv - 82% complete - elapsed time = 2:29 - remaining time = 0:32
data/title.principals.tsv - 85% complete - elapsed time = 2:35 - remaining time = 0:26
data/title.principals.tsv - 88% complete - elapsed time = 2:40 - remaining time = 0:20
data/title.principals.tsv - 92% complete - elapsed time = 2:46 - remaining time = 0:14
data/title.principals.tsv - 95% complete - elapsed time = 2:52 - remaining time = 0:08
data/title.principals.tsv - 98% complete - elapsed time = 2:59 - remaining time = 0:02
data/title.principals.tsv - 100% complete - elapsed time = 3:01 - remaining time = 0:00
data/title.ratings.tsv - 100% complete - elapsed time = 0:04 - remaining time = 0:00
```
