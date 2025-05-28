#!/bin/bash -e
#SBATCH --account=uoo03627
#SBATCH --job-name=genotypeGVCF
#SBATCH --time=5-00:00:00
#SBATCH --mem=200GB
#SBATCH --cpus-per-task=32
#SBATCH --array=1-27
#SBATCH --output=genotypeGVCF_%A_%a.out
#SBATCH --error=genotypeGVCF_%A_%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=anna.clark@postgrad.otago.ac.nz
#SBATCH --partition=milan

#load mods
module load GATK

# set args
REFERENCE_GENOME="/nesi/nobackup/uoo03627/qt_rat_sequencing/reference_sequences/GCF_011064425.1_Rrattus_CSIRO_v1/GCF_011064425.1_Rrattus_CSIRO_v1_genomic_autosomesonly.fna.gz"
OUTPUT="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/09_genotyped_GATK/multisample_allvariants_gatk"
INPUT="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/08_combine/multisample.g.vcf.gz"
INTERVAL_FILE="/nesi/nobackup/uoo03627/qt_rat_sequencing/reference_sequences/GCF_011064425.1_Rrattus_CSIRO_v1/interval_scattergenotyping.list"

# match a line number with array job
INTERVAL=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$INTERVAL_FILE")

echo "Processing: $INTERVAL"

gatk --java-options "-Xmx180g -XX:ParallelGCThreads=64" GenotypeGVCFs \
    -R $REFERENCE_GENOME \
    -L $INTERVAL \
    -V $INPUT \
    -O "${OUTPUT}_${INTERVAL}.vcf.gz"
