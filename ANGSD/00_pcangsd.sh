#!/bin/bash -e
#SBATCH --account=uoo03627
#SBATCH --job-name=pcangsd
#SBATCH --time=1-00:00:00
#SBATCH --mem=72GB
#SBATCH --cpus-per-task=10
#SBATCH --output=pcangsd_%A.out
#SBATCH --error=pcangsd_%A.err

PCANGSD="/nesi/nobackup/uoo03627/Software/pcangsd"
INPUT="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_angsd/genoLike_12Feb.beagle.gz"
OUTPUT="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_angsd/pcangsd/pcangsd_18Feb"

pcangsd --beagle $INPUT --eig 2 --threads 20 --out $OUTPUT --selection --admix