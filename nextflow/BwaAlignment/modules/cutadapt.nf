nextflow.enable.dsl=2

process CUTADAPT {
    debug true
    container "quay.io/biocontainers/cutadapt@sha256:2141194ef375c35a34ded3d5cd5457150d6f8f797432edadee32ab238a4036d2"
    publishDir "${params.outdir}/align_and_sort/cutadapt"
    cpus "${params.align_and_sort.cutadapt.cpus}"
    memory "${params.align_and_sort.cutadapt.memory}"

    input:
    path fastq
    val output_prefix
    val adapter
    val adapter_second_read

    output:
    tuple path("${output_prefix + "-R1.fastq.gz"}"), path("${output_prefix + "-R2.fastq.gz"}"), emit: out

    script:
    def adapter = adapter ? "-a " + adapter.join(' ') : ""
    def adapter_second_read = adapter_second_read ? "-A " + adapter_second_read.join(' ') : ""
    def fastq = fastq.join(' ')
    def front = params.align_and_sort.five_prime_adapter_read1 ? "--front " + params.align_and_sort.five_prime_adapter_read1.join(' ') : ""
    def front_adapter_second_read = params.align_and_sort.five_prime_adapter_read2 ? "-G " + params.align_and_sort.five_prime_adapter_read2.join(' ') : ""
    def minimum_length = params.align_and_sort.cutadapt_minimum_length ? "--minimum-length ${params.align_and_sort.cutadapt_minimum_length}" : ""
    def quality_cutoff = params.align_and_sort.cutadapt_quality_cutoff ? "--quality-cutoff ${params.align_and_sort.cutadapt_quality_cutoff}" : ""
    """
    cutadapt \
    ${front} \
    ${minimum_length} \
    ${quality_cutoff} \
    ${adapter_second_read} \
    ${front_adapter_second_read} \
    ${adapter} \
    -o ${output_prefix}-R1.fastq.gz \
    -p ${output_prefix}-R2.fastq.gz \
    ${fastq} \
    """

}
