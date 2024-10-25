-- Create the database: 
CREATE DATABASE bioinformatics_db;
USE bioinformatics_db;

-- Create the runs Table:
CREATE TABLE runs (
    run_id INT PRIMARY KEY,
    run_folder_name VARCHAR(255),
    run_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create the pre-multiqc report table: 
CREATE TABLE pre_multiqc_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT,
    report_path VARCHAR(255),
    FOREIGN KEY (run_id) REFERENCES runs(run_id)
);

-- Create the post_multiqc_reports Table:
CREATE TABLE post_multiqc_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT,
    report_path VARCHAR(255),
    FOREIGN KEY (run_id) REFERENCES runs(run_id)
);

-- Create the vcf_files Table:
CREATE TABLE vcf_files (
    vcf_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT,
    sample_name VARCHAR(255),
    vcf_path VARCHAR(255),
    FOREIGN KEY (run_id) REFERENCES runs(run_id)
);

-- Create the vcf_variants Table:
CREATE TABLE vcf_variants (
    variant_id INT AUTO_INCREMENT PRIMARY KEY,
    vcf_id INT,
    chromosome VARCHAR(255),
    position VARCHAR(255),
    allele VARCHAR(255),
    gene VARCHAR(255),
    feature VARCHAR(255),
    feature_type VARCHAR(255),
    consequence VARCHAR(255),
    cDNA_position VARCHAR(255),
    CDS_position VARCHAR(255),
    protein_position VARCHAR(255),
    amino_acids VARCHAR(255)
    codons VARCHAR(255),
    existing_variation VARCHAR(255),
    FOREIGN KEY (vcf_id) REFERENCES vcf_files(vcf_id)
);
