fq2_rename.txt is the renaming convention used too standardise naming between the 3 sequencing datasets. 
rename_fq_final.sh is the script used for renaming files. 

Genotyping using nf didnt work due to memory reqs and timeouts, hence we used 00_genotypeGVCFs.sh to deploy a scattergenotyping approach to speed up results. 
