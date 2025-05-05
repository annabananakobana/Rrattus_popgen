nextflow.enable.dsl = 2

/*
 * pipeline input parameters
 */

params.outdir = "/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/results"
params.genome_index = "/nesi/nobackup/uoo03627/qt_rat_sequencing/reference_sequences/GCF_011064425.1_Rrattus_CSIRO_v1/GCF_011064425.1_Rrattus_CSIRO_v1_genomic_autosomesonly.fna.gz"

process FASTQC {
    module 'FastQC/0.12.1'
    cpus 6
    time '12h'
    memory '16 GB'
    queue 'large'	
    tag "FASTQC on $sample_id"
    publishDir "$params.outdir/", mode:'copy'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    path "01_fastqc/${sample_id}"

    script:
    """
    mkdir -p 01_fastqc
    mkdir -p 01_fastqc/${sample_id}
    fastqc -o 01_fastqc/${sample_id} -f fastq -q ${fastq_1} ${fastq_2}
    """
}

process TRIMMING {
    module 'TrimGalore/0.6.10-gimkl-2022a-Python-3.11.3-Perl-5.34.1'
    cpus 16
    time '24h'
    memory '20 GB'
    queue 'milan'
    tag "TRIMMING on $sample_id"
    publishDir "$params.outdir/", mode:'copy'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    path "02_trimming/${sample_id}"
    val(sample_id)

    script:
    """
    mkdir -p  02_trimming
    mkdir -p 02_trimming/${sample_id}
    trim_galore -q 20 -j 16 --fastqc -o 02_trimming/${sample_id}/ --paired \
    ${fastq_1} ${fastq_2}
    """
}

process MAPPING {
    module 'BWA/0.7.17-GCC-11.3.0'
    module 'SAMtools/1.16.1-GCC-11.3.0'
    cpus 32
    time '72h'
    memory '75 GB'
    queue 'milan'
    tag "MAPPING on $sample_id"

    input:
    path "02_trimming/${sample_id}"
    val(sample_id)
   
    output:
    path "03_mapped/${sample_id}"
    val(sample_id)

    script:
    """
    mkdir -p 03_mapped
    mkdir -p 03_mapped/${sample_id}
    bwa mem -M -t 16 -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILM\\tLB:${sample_id}" \
    "$params.genome_index" "02_trimming/${sample_id}/${sample_id}_R1_val_1.fq.gz" \
    "02_trimming/${sample_id}/${sample_id}_R2_val_2.fq.gz" > \
    03_mapped/${sample_id}/${sample_id}.sam
    samtools view -F 4 -Sb 03_mapped/${sample_id}/${sample_id}.sam | 
    samtools sort -o 03_mapped/${sample_id}/${sample_id}.bam
    samtools index -c 03_mapped/${sample_id}/${sample_id}.bam
    """
    
}

process DEDUPLICATION {
    module 'GATK/4.4.0.0-gimkl-2022a'
    module 'SAMtools/1.16.1-GCC-11.3.0'
    cpus 24
    time '24h'
    memory '120 GB'
    queue 'milan'
    tag "DEDUPLICATION on $sample_id"
    publishDir "$params.outdir/", mode:'copy'

    input:
    path "03_mapped/${sample_id}"
    val(sample_id)

    output:
    path "05_deduplicated/${sample_id}"
    val(sample_id)

    script:
    """
    mkdir -p 05_deduplicated
    mkdir -p 05_deduplicated/${sample_id}
    gatk --java-options -Xmx96g MarkDuplicates \
    -I "03_mapped/${sample_id}/${sample_id}.bam" \
    -O "05_deduplicated/${sample_id}/${sample_id}_dedup.bam" \
    -M "05_deduplicated/${sample_id}/${sample_id}_metrics.txt" \
    --MAX_RECORDS_IN_RAM 5000 -MAX_SEQS 5000 \
    --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
    --VALIDATION_STRINGENCY SILENT \
    -MAX_FILE_HANDLES 1000
    samtools index -c "05_deduplicated/${sample_id}/${sample_id}_dedup.bam"
    """

}

process GROUPING {
    module 'SAMtools/1.16.1-GCC-11.3.0'
    cpus 12
    time '24h'
    memory '30 GB'
    queue 'milan'
    tag "GROUPING on $sample_id"

    input:
    path "05_deduplicated/${sample_id}"
    val(sample_id)

    output:
    path "06_grouped/${sample_id}"
    val(sample_id)

    script:
    """
    mkdir -p 06_grouped
    mkdir -p 06_grouped/${sample_id}
    samtools addreplacerg -w -r 'ID:${sample_id}' -r 'LB:${sample_id}' -r 'SM:${sample_id}' -o "06_grouped/${sample_id}/${sample_id}_grouped.bam" "05_deduplicated/${sample_id}/${sample_id}_dedup.bam"
    samtools index -c "06_grouped/${sample_id}/${sample_id}_grouped.bam"
    """

}

process HAPLOTYPECALLER {
    module 'GATK/4.4.0.0-gimkl-2022a'
    cpus 24
    time '7d'
    memory '100 GB'
    queue 'milan'
    tag "HAPLOTYPECALLER on $sample_id"
    publishDir "$params.outdir/", mode:'copy'

    input:
    path "06_grouped/${sample_id}"
    val(sample_id)

    output:
    path "07_haplotypecaller2/${sample_id}"
    val(sample_id)

    script:
    """
    mkdir -p 07_haplotypecaller2
    mkdir -p 07_haplotypecaller2/${sample_id}
    gatk --java-options "-Xmx90g" HaplotypeCaller \
   -R "$params.genome_index" \
   -I "06_grouped/${sample_id}/${sample_id}_grouped.bam" \
   -O "07_haplotypecaller2/${sample_id}/${sample_id}_grouped.vcf.gz" \
   -ERC GVCF \
   --create-output-variant-index true \
   --read-index "06_grouped/${sample_id}/${sample_id}_grouped.bam.csi"
    """

}

workflow {
    Channel
        .fromPath("/nesi/nobackup/uoo03627/qt_rat_sequencing/RRATTUS_ALL_SI/sample_file_list3.csv")
        .splitCsv(header: true)
        .map {row -> tuple(row.sample_id,row.fastq_1,row.fastq_2)}
        .set { sample_run_ch }

    fastqc_ch = FASTQC( sample_run_ch )
    trimming_ch = TRIMMING( sample_run_ch )
    mapping_ch = MAPPING( trimming_ch )
    deduplication_ch = DEDUPLICATION( mapping_ch )
    grouping_ch = GROUPING( deduplication_ch )
    haplotypecaller_ch = HAPLOTYPECALLER( grouping_ch )
    
}
