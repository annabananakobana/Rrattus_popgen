#!/bin/bash
#SBATCH --account=uoo03627
#SBATCH --job-name=merge_fwd_rvs
#SBATCH --time=00:15:00
#SBATCH --mem=4GB
#SBATCH --cpus-per-task=4
#SBATCH --qos=debug
#SBATCH --output=merge_fwd_rvs_%A.out
#SBATCH --error=merge_fwd_rvs_%A.err

# Input files containing the list of FASTQ files for merging
file_list="all_fastq_files.txt"

# Temporary files for forward and reverse strand file lists
forward_list="forward_files.txt"
reverse_list="reverse_files.txt"

# Clear temporary files if they exist
> "$forward_list"
> "$reverse_list"

# Populate forward and reverse lists by strand (R1 or R2)
while read -r file; do
    if [[ "$file" == *_R1_*.fastq.gz ]]; then
        echo "$file" >> "$forward_list"
    elif [[ "$file" == *_R2_*.fastq.gz ]]; then
        echo "$file" >> "$reverse_list"
    fi
done < "$file_list"

# Sort the temporary files (optional but ensures consistent order)
sort -o "$forward_list" "$forward_list"
sort -o "$reverse_list" "$reverse_list"

# Extract unique sample names and process merging
for sample in $(awk -F'_' '{print $1}' "$file_list" | sort | uniq); do
    # Create output filenames
    output_fwd="${sample}_merged_R1.fastq.gz"
    output_rvs="${sample}_merged_R2.fastq.gz"

    # Collect matching files for forward and reverse reads
    fwd_files=$(grep "^${sample}_" "$forward_list")
    rvs_files=$(grep "^${sample}_" "$reverse_list")

    # Merge forward reads
    if [ -n "$fwd_files" ]; then
        echo "Merging forward reads for sample: $sample"
        cat $fwd_files > "$output_fwd"
        echo "Forward reads merged into $output_fwd"
    else
        echo "No forward reads found for sample: $sample"
    fi

    # Merge reverse reads
    if [ -n "$rvs_files" ]; then
        echo "Merging reverse reads for sample: $sample"
        cat $rvs_files > "$output_rvs"
        echo "Reverse reads merged into $output_rvs"
    else
        echo "No reverse reads found for sample: $sample"
    fi
done

# Cleanup temporary files
rm -f "$forward_list" "$reverse_list"

