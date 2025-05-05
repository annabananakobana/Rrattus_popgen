#!/bin/bash
#SBATCH --job-name=rename_fq
#SBATCH --cpus-per-task=2
#SBATCH --account=uoo03627
#SBATCH --mem=2GB
#SBATCH --qos=debug
#SBATCH --time=00:15:00
#SBATCH --output=rename_fq_%A_%a.out
#SBATCH --error=rename_fq_%A_%a.err

# mapping file
name_map="fq2_rename.txt"

while read -r old_name new_name; do
    if [[ -e "$old_name" ]]; then
        mv "$old_name" "$new_name"
        echo "Renamed $old_name to $new_name"
    else
        echo "File $old_name not found, skipping"
    fi
done < "$name_map"

