#!/bin/bash -l
#SBATCH --job-name=nf_pipeline
#SBATCH --output=nf_pipeline_%j.out
#SBATCH --error=nf_pipeline_%j.err
#SBATCH --time=7-00:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --partition=milan

# Create and move to working directory for job

# load nextflow
module load Nextflow/24.04.4

# Copy files over to working directory
BASE_DIR=/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI

# ensure gatk and picard know where to write temp files
export _JAVA_OPTIONS=-Djava.io.tmpdir=/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/nf_temp

nextflow -log ${BASE_DIR}/00_nextflow_pipeline_${SLURM_JOB_ID}.log \
run 00_variant_calling_pipeline.nf -resume \
-with-report $BASE_DIR/00_nextflow_pipeline_${SLURM_JOB_ID}_report.html -with-dag $BASE_DIR/00_nextflow_pipeline_${SLURM_JOB_ID}_flowchart.png
