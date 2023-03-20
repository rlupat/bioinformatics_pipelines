nextflow.enable.dsl=2

process MARK_DUPLICATES {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/merge_and_markdups/markduplicates"
    cpus "${params.merge_and_markdups.mark_duplicates.cpus}"
    memory "${params.merge_and_markdups.mark_duplicates.memory}"

    input:
    path bam
    val output_prefix

    output:
    tuple path("${[output_prefix, "generated"].find{ it != null } + ".markduped.bam"}"), path("${[output_prefix, "generated"].find{ it != null } + ".markduped.bai"}"), emit: out
    path "${[output_prefix, "generated"].find{ it != null } + ".metrics.txt"}", emit: metrics

    script:
    def bam = bam.join(' ')
    def compression_level = null
    def create_index = params.merge_and_markdups.create_index == false ? "" : "--CREATE_INDEX"
    def java_options = null
    def max_records_in_ram = params.merge_and_markdups.max_records_in_ram ? "--MAX_RECORDS_IN_RAM ${params.merge_and_markdups.max_records_in_ram}" : ""
    """
    gatk MarkDuplicates \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    -I ${bam} \
    -M ${[output_prefix, "generated"].find{ it != null }}.metrics.txt \
    -O ${[output_prefix, "generated"].find{ it != null }}.markduped.bam \
    ${max_records_in_ram} \
    ${create_index} \
    --TMP_DIR tmp/ \
    """

}
