nextflow.enable.dsl=2

process CUTADAPT {
    debug true
    container "quay.io/biocontainers/cutadapt@sha256:2141194ef375c35a34ded3d5cd5457150d6f8f797432edadee32ab238a4036d2"
    publishDir "${params.outdir}/cutadapt"
    cpus "${params.cutadapt.cpus}"
    memory "${params.cutadapt.memory}"

    input:
    path fastq

    output:
    tuple path("${params.sample_name + "-R1.fastq.gz"}"), path("${params.sample_name + "-R2.fastq.gz"}"), emit: out

    script:
    def adapter = params.three_prime_adapter_read1 ? "-a " + params.three_prime_adapter_read1.join(' ') : ""
    def adapter_second_read = params.three_prime_adapter_read2 ? "-A " + params.three_prime_adapter_read2.join(' ') : ""
    def fastq = fastq.join(' ')
    def front = params.five_prime_adapter_read1 ? "--front " + params.five_prime_adapter_read1.join(' ') : ""
    def front_adapter_second_read = params.five_prime_adapter_read2 ? "-G " + params.five_prime_adapter_read2.join(' ') : ""
    def minimum_length = params.cutadapt_minimum_length ? "--minimum-length ${params.cutadapt_minimum_length}" : ""
    def quality_cutoff = params.cutadapt_quality_cutoff ? "--quality-cutoff ${params.cutadapt_quality_cutoff}" : ""
    """
    cutadapt \
    ${front} \
    ${minimum_length} \
    ${quality_cutoff} \
    ${adapter_second_read} \
    ${front_adapter_second_read} \
    ${adapter} \
    -o ${params.sample_name}-R1.fastq.gz \
    -p ${params.sample_name}-R2.fastq.gz \
    ${fastq} \
    """

}
