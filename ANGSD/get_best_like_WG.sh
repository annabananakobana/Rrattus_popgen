#!/bin/bash

output_file="best_likelihood_results_WGtest.txt"

# Output header
echo -e "Filename\tK_Value\tBest_Like" > "$output_file"

# Loop through matching files
for file in genoLike_12Feb_ngsAdmix_WG_K*_seed*.log; do
    # Extract K value from filename
    K_value=$(echo "$file" | grep -oP 'K\d+' | grep -oP '\d+')
    
    # Extract best likelihood value
    best_like=$(grep -m1 "best like=" "$file" | awk -F'=' '{print $2}' | tr -d ' ')
    
    echo -e "$file\t$K_value\t$best_like" >> "$output_file"
done
