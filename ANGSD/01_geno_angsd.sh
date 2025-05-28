#!/bin/bash -l
#SBATCH --job-name=geno_angst
#SBATCH --output=geno_angst_%j.out
#SBATCH --error=geno_angst_%j.err
#SBATCH --time=3-00:00:00
#SBATCH --mem=200G
#SBATCH --cpus-per-task=32
#SBATCH --partition=bigmem

module load angsd/0.935-GCC-9.2.0

workdir="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_grouped"
outdir="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_angsd"
# ls ${workdir}/*.bam > ${workdir}/bam.filelist
BAM_LIST="${workdir}/bam.filelist"
REF="/nesi/nobackup/uoo03627/qt_rat_sequencing/reference_sequences/GCF_011064425.1_Rrattus_CSIRO_v1/GCF_011064425.1_Rrattus_CSIRO_v1_genomic_autosomesonly.fna.gz"

# genotype likelihoods using angst
# use GL 1 since thats the SAMtools model and is widely used
# -doGlf 2 = BEAGLE output format that is compatible with NGS tools
# -doMajorMinor 1: Infer major and minor alleles based on allele frequencies.
# -postCutoff 0.85 = reduce this threshold to capture more results from the low coverage seq, 
# at the expense of slight increase in genotype uncertainty (false positve rate)
# rm     -setMaxDepthInd 100 since it wasnt working
# -minInd 40 = must be data for at least 50% of individuals


angsd \
    -bam ${BAM_LIST} \
    -ref ${REF} \
    -out "${outdir}/genoLike_12Feb" \
    -nThreads 64 \
    -GL 1 \
    -doGlf 2 \
    -doMaf 2 -doMajorMinor 1 \
    -minMapQ 30 \
    -minQ 20 \
    -SNP_pval 1e-6 \
    -doGeno 2 \
    -doPost 1 -postCutoff 0.90 \
    -minInd 40 \
    -doCounts 1 \
    -setMaxDepthInd 100