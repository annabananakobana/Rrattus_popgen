#!/bin/bash -e

#SBATCH --cpus-per-task  8
#SBATCH --job-name       ngsadmix_WG
#SBATCH --mem            150G
#SBATCH --time           48:00:00
#SBATCH --account        uoo03627
#SBATCH --output         ngsadmix_WG_%j.out
#SBATCH --error          ngsadmix_WG_%j.err
#SBATCH --hint           nomultithread
#SBATCH --partition      milan

module purge
module load angsd/0.935-GCC-9.2.0

# Define variables
BEAGLE_FILE="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_angsd/genoLike_12Feb.beagle.gz"
OUT_PREFIX="/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results/06_angsd/genoLike_12Feb_ngsAdmix_WG"
THREADS=${SLURM_CPUS_PER_TASK}
MIN_MAF=0.1                  # Minimum MAF
MIS_TOL=0.8                  # Tolerance for high-quality genotypes
SEEDS=(14041 82680 21349)    # Seeds for reproducibility
SEEDS2=(82680 21349)
MAX_ITER=2000                # Maximum number of EM iterations
NGSadmix="/nesi/nobackup/uoo03627/Software/NGSadmix"

# this script has be modified to continue
for K in 5; do
    echo "Running ngsAdmix for K=${K}"

    # Loop through seeds
    for SEED in "${SEEDS2[@]}"; do
        echo "Using seed=${SEED}"

        # Run ngsAdmix
        $NGSadmix -likes $BEAGLE_FILE \
                 -K $K \
                 -outfiles "${OUT_PREFIX}_K${K}_seed${SEED}" \
                 -seed $SEED \
                 -minMaf $MIN_MAF \
                 -misTol $MIS_TOL \
                 -P $THREADS \
                 -maxiter $MAX_ITER
    done
done




: << 'DISABLE'
# Loop through K values, did 2:3 in a prev run
# doing K5 without the first seed since it completed in last run (ngsadmix_WG_53113395.err)
for K in 5 7; do
    echo "Running ngsAdmix for K=${K}"

    # Loop through seeds
    for SEED in "${SEEDS2[@]}"; do
        echo "Using seed=${SEED}"

        # Run ngsAdmix
        $NGSadmix -likes $BEAGLE_FILE \
                 -K $K \
                 -outfiles "${OUT_PREFIX}_K${K}_seed${SEED}" \
                 -seed $SEED \
                 -minMaf $MIN_MAF \
                 -misTol $MIS_TOL \
                 -P $THREADS \
                 -maxiter $MAX_ITER
    done
done


for K in {6..8}; do
    echo "Running ngsAdmix for K=${K}"

    # Loop through seeds
    for SEED in "${SEEDS[@]}"; do
        echo "Using seed=${SEED}"

        # Run ngsAdmix
        $NGSadmix -likes $BEAGLE_FILE \
                 -K $K \
                 -outfiles "${OUT_PREFIX}_K${K}_seed${SEED}" \
                 -seed $SEED \
                 -minMaf $MIN_MAF \
                 -misTol $MIS_TOL \
                 -P $THREADS \
                 -maxiter $MAX_ITER
    done
done
DISABLE