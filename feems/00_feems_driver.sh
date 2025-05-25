#!/bin/bash -e
#SBATCH --account=uoo03627
#SBATCH --job-name=feems_spatialplot
#SBATCH --time=06:00:00
#SBATCH --mem=16GB
#SBATCH --cpus-per-task=4
#SBATCH --output=%x_%A.out
#SBATCH --error=%x_%A.err

#load modules
#module load Python

eval "$(/opt/nesi/CS400_centos7_bdw/Miniconda3/23.10.0-1/bin/conda shell.bash hook)"
conda activate /scale_wlg_nobackup/filesets/nobackup/uoo03627/qt_rat_sequencing/feems/feems_env

# check py version is 3.8.*
python --version

python feems_plots.py

conda deactivate

