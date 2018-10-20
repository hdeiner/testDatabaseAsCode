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
