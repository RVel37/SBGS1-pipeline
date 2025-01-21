import os
import time
import mysql.connector
import logging

# Configure logging to capture SQL queries and errors
logging.basicConfig(level=logging.DEBUG)

# MySQL connection details for Docker container
db_config = {
    'user': 'root',
    'password': 'my-secret-pw',
    'host': 'localhost',  
    'port': 3306,
    'database': 'bioinformatics_db'
}

# Path to the cromwell-outputs directory (need to get changed depending on where the script is running)
CROMWELL_OUTPUTS_DIR = "/Users/miladebrahimian/Documents/competencies/diagnostic_sequencing/tasks/WDL/database_for_main/cromwell-outputs"

# Function to insert VCF variants into the database (with the new fields)
def insert_variants_to_db(vcf_id, vcf_file_path, batch_size=100):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    insert_count = 0

    print(f"Opening VCF file: {vcf_file_path}")

    try:
        with open(vcf_file_path, 'r') as vcf_file:
            for line in vcf_file:
                if not line.startswith('#'):
                    try:
                        # Split the line into columns
                        columns = line.strip().split('\t')

                        # Basic check to ensure there are enough columns
                        if len(columns) < 2:  # Adjust if necessary
                            print(f"Skipping malformed line (less than expected columns): {line}")
                            continue

                        # Extract the relevant fields from the VCF file
                        location = columns[1]
                        allele = columns[2]
                        gene = columns[3]
                        feature = columns[4]
                        feature_type = columns[5]
                        consequence = columns[6]
                        cDNA_position = columns[7]
                        CDS_position = columns[8]
                        protein_position = columns[9]
                        amino_acids = columns[10]
                        codons = columns[11]
                        existing_variation = columns[12]

                        # You can further split the "Location" field to get chromosome and position
                        chrom_pos = location.split(':')
                        if len(chrom_pos) == 2:
                            chrom = chrom_pos[0]  # Chromosome part
                            pos = chrom_pos[1]    # Position part
                        else:
                            print(f"Invalid Location format: {location}")
                            continue

                        # Print the values for debugging
                        print(f"Chromosome: {chrom} (type: {type(chrom)})")
                        print(f"Position: {pos} (type: {type(pos)})")

                        print(f"Inserting variant: Chromosome: {chrom}, Position: {pos}")

                        # Insert the variant into the database
                        cursor.execute("""
                            INSERT INTO vcf_variants (
                                vcf_id, chromosome, position, allele, gene, feature, feature_type,
                                consequence, cDNA_position, CDS_position, protein_position, 
                                amino_acids, codons, existing_variation
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, (vcf_id, chrom, pos, allele, gene, feature, feature_type, consequence, 
                              cDNA_position, CDS_position, protein_position, amino_acids, codons, 
                              existing_variation))

                        # Commit after each insertion
                        conn.commit()

                        print(f"Successfully inserted variant: Chromosome: {chrom}, Position: {pos}")
                        insert_count += 1

                    except mysql.connector.Error as err:
                        print(f"MySQL Error while inserting variant for line {line}: {err}")
                    except Exception as e:
                        print(f"General Error while processing line {line}: {e}")

    except Exception as e:
        print(f"Error processing VCF file {vcf_file_path}: {e}")

    finally:
        cursor.close()
        conn.close()
        print(f"Closed connection for VCF file {vcf_file_path}.")


# Function to insert new runs into the database
def insert_run_to_db(run_id, run_folder):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Check if the run_id already exists in the database
        print(f"Checking if run_id {run_id} already exists...")
        cursor.execute("SELECT COUNT(*) FROM runs WHERE run_id = %s", (run_id,))
        exists = cursor.fetchone()[0]

        # If the run_id does not exist, insert it into the runs table
        if exists == 0:
            print(f"Inserting run_id: {run_id} into the database...")
            cursor.execute("INSERT INTO runs (run_id, run_folder_name) VALUES (%s, %s)", (run_id, run_folder))
            conn.commit()  # Commit after inserting into the runs table

            # Insert pre and post MultiQC report paths
            print(f"Inserting pre and post MultiQC reports for run_id {run_id}...")
            pre_report = os.path.join(run_folder, 'dir_multiqc', 'multiqc_report.html')
            post_report = os.path.join(run_folder, 'post_multiqc_dir', 'multiqc_report.html')

            cursor.execute("INSERT INTO pre_multiqc_reports (run_id, report_path) VALUES (%s, %s)", (run_id, pre_report))
            cursor.execute("INSERT INTO post_multiqc_reports (run_id, report_path) VALUES (%s, %s)", (run_id, post_report))
            conn.commit()  # Commit after inserting reports

            # Insert VCF files information
            print(f"Inserting VCF files for run_id {run_id}...")
            vcf_files_dir = os.path.join(run_folder, 'vcf_output')
            if os.path.exists(vcf_files_dir):
                vcf_files = os.listdir(vcf_files_dir)
            
                print(vcf_files)  # For debugging

                if not vcf_files:
                    print(f"No VCF files found in {vcf_files_dir}")

                for vcf_file in vcf_files:
                    print(vcf_file)  # For debugging
                    sample_name = vcf_file.split('.')[0]
                    vcf_path = os.path.join(vcf_files_dir, vcf_file)

                    # Ensure the file exists and is a valid VCF file
                    if os.path.isfile(vcf_path):
                        print(f"Processing VCF file: {vcf_file} (sample: {sample_name})")
                        cursor.execute("INSERT INTO vcf_files (run_id, sample_name, vcf_path) VALUES (%s, %s, %s)", (run_id, sample_name, vcf_path))
                        vcf_id = cursor.lastrowid  # Get the auto-incremented vcf_id
                        conn.commit()  # Commit after inserting VCF file

                        # Parse and insert VCF variants into the database
                        print(f"Inserting variants for VCF file: {vcf_file} (sample: {sample_name})...")
                        insert_variants_to_db(vcf_id, vcf_path)
                    else:
                        print(f"VCF file {vcf_file} does not exist or is not a valid file.")
            else:
                print(f"No VCF files found for run_id {run_id} in {vcf_files_dir}")

        else:
            print(f"run_id: {run_id} already exists in the database.")

    except Exception as e:
        print(f"Error processing run_id {run_id}: {e}")

    finally:
        cursor.close()
        conn.close()


# Periodically check for new subdirectories in the cromwell-outputs directory
def check_for_new_runs():
    while True:
        # Loop through each subdirectory in the cromwell-outputs directory
        for dir in os.listdir(CROMWELL_OUTPUTS_DIR):
            if dir.startswith('runnumber_'):
                run_folder_name = dir
                run_id = dir.split('_')[1]  # Extract the run_id number

                # Full path to the run folder
                run_folder = os.path.join(CROMWELL_OUTPUTS_DIR, run_folder_name)

                print(f"Processing run folder: {run_folder_name} (run_id: {run_id})")

                # Insert the run info into the database if not already present
                insert_run_to_db(run_id, run_folder)

        # Sleep for a certain period before checking again (e.g., every 5 minutes)
        time.sleep(300)


if __name__ == "__main__":
    check_for_new_runs()
