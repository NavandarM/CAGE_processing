# Snakemake pipeline for Bowtie alignment, sorting, and indexing: CAGE data

# Config
BOWTIE_INDEX = "PathToBowtieIndex"
n_threads = 20
SAMPLES = ["SRR9201", "SRR9202", "SRR920"]
alignment_env = 'env.yaml'

##Wf
rule all:
    input:
        expand("{sample}.sort.bam.bai", sample=SAMPLES)

rule bowtie_align:
    input:
        fq = "{sample}.fastq.gz"
    output:
        bam = "{sample}.bam"
    threads: n_threads
    conda: alignment_env
    shell:
        """
        bowtie -v 2 -m 1 --best --strata -S \
            {BOWTIE_INDEX} -q {input.fq} | \
            samtools view -bS -q 20 -o {output.bam} -
        """

rule sort_bam:
    input:
        bam = "{sample}.bam"
    output:
        sorted_bam = "{sample}.sort.bam"
    threads: n_threads
    conda: alignment_env
    shell:
        """
        samtools sort -@ {threads} -o {output.sorted_bam} -O BAM {input.bam}
        """

rule index_bam:
    input:
        sorted_bam = "{sample}.sort.bam"
    output:
        bai = "{sample}.sort.bam.bai"
    threads: n_threads
    conda: alignment_env
    shell:
        """
        samtools index -@ {threads} {input.sorted_bam}
        """

