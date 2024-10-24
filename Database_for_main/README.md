# Bioinformatics Data Insertion Pipeline

This project sets up a bioinformatics pipeline that processes run data from the Cromwell outputs directory, including VCF files and MultiQC reports, and inserts this information into a MySQL database running inside a Docker container. The script monitors the cromwell-outputs directory for new runs and automatically adds details to the database.

## Table of Contents

1.	Project Structure
2.	Setup Instructions
3.	Database Schema
4.	Running the Pipeline
5.	Troubleshooting

## Project Structure

The folder structure for this project should look like this:
	
	.
	├── Data_insertion.py                  # Python script that monitors the cromwell-outputs directory
	├── README.md                          # This README file
	├── cromwell-outputs/                  # Directory monitored for new runs
	    └── runnumber_1234/                # Example run directory
	       ├── dir_multiqc/
	       │   └── multiqc_report.html    # Pre-processing MultiQC report
	       ├── post_multiqc_dir/
	       │   └── multiqc_report.html    # Post-processing MultiQC report
	       └── vcf_output/
	           └── sample1.vcf            # VCF files with variants

## Setup Instructions

### Prerequisites

1.	Docker: pull the docker image:

		docker pull mysql:latest

2.	MySQL in Docker: Set up a MySQL database inside Docker using the following command:

		docker run --name db-container \
		-v /path/to/mysql_data:/var/lib/mysql \
		-v /path/to/cromwell-outputs:/cromwell-outputs \
		-e MYSQL_ROOT_PASSWORD=my-secret-pw \
		-p 3306:3306 -d mysql:latest


3.	Python Requirements: You need Python 3.x installed. Install the mysql-connector-python package:

		pip install mysql-connector-python


## Setting Up the MySQL Database

1.	Access the MySQL container:

		docker exec -it db-container mysql -u root -p


2.	Create the Database: paste the SQL code in database.sql file into the container step by step (in database.sql file, steps are seperated by ;)


## Running the Pipeline

1.	Open a new terminal. Ensure the Docker container is running:

		docker ps

If the container is stopped, start it with:

		docker start db-container


2.	Run the Python script to monitor the cromwell-outputs directory for new runs: 
   (IMPORTANT NOTE: YOU WILL NEED TO OPEN Data_insertion.py and CHANGE THE CROMWELL_OUTPUTS_DIR)

		python Data_insertion.py


3.	Add new run folders to the cromwell-outputs directory. Each folder should follow this structure:
		
		runnumber_1234/
		├── dir_multiqc/
		│   └── multiqc_report.html
		├── post_multiqc_dir/
		│   └── multiqc_report.html
		└── vcf_output/
		    └── sample1.vcf


4.	Verify the data is inserted into the MySQL database:
		
		docker exec -it db-container mysql -u root -p
		USE bioinformatics_db;
		SELECT * FROM runs;



## Database Schema

The MySQL database contains the following tables:

•	runs: Tracks each run folder and its metadata.
•	pre_multiqc_reports: Stores paths to pre-processing MultiQC reports.
•	post_multiqc_reports: Stores paths to post-processing MultiQC reports.
•	vcf_files: Stores the VCF file for each sample.
•	vcf_variants: Stores details of individual variants from the annotated VCF files.

## Troubleshooting

1.	Docker Container Issues:
	•	If you receive a container name conflict error, list all containers (running and stopped) using:

		docker ps -a


	•	Then remove any stopped container with:

		docker rm <container_id>


2.	Database Connection Issues:
	•	Ensure that the db_config['host'] in your Python script points to the correct IP address for the Docker container. You can get the container’s IP by running:

		docker inspect db-container | grep IPAddress


	3.	Monitoring Logs:
	•	If the Python script isn’t working as expected, add print() statements in key parts of the script to output logs for debugging.


