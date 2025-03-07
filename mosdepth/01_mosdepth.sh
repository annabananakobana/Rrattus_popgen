#!/bin/bash -e
#SBATCH --account=user
#SBATCH --job-name=mosdepth
#SBATCH --array=01-79
#SBATCH --time=00:30:00
#SBATCH --mem=3GB
#SBATCH --cpus-per-task=4
#SBATCH --output=mosdepth_%A_%a.out
#SBATCH --error=mosdepth_%A_%a.err

#load modules
module load mosdepth # version 0.3.4

# set variables
INPUT_DIR="user/results/05_deduplicated"
REFERENCE_GENOME=/user/reference_sequences/GCF_011064425.1_Rrattus_CSIRO_v1/GCF_011064425.1_Rrattus_CSIRO_v1_genomic.fna.gz
OUTPUT_DIR="/user/results/05_mosdepth/deduplicated"

# sample id, make sure you are including the prceding 0 in the numbers leading up to 10.
SAMPLE_ID=$(printf "%02d" $SLURM_ARRAY_TASK_ID)

mosdepth \
    --threads 8 \
    --by 100 \
    -F 1796 \
    --no-per-base \
    --fast-mode \
    "${OUTPUT_DIR}/${SAMPLE_ID}" \
    "${INPUT_DIR}/${SAMPLE_ID}/${SAMPLE_ID}_dedup.bam"
