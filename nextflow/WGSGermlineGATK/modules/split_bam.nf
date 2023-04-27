nextflow.enable.dsl=2

process SPLIT_BAM {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/vc_gatk/split_bam"
    memory "${params.vc_gatk.split_bam.memory}"

    input:
    tuple path(bam), path(bai)
    path intervals, stageAs: 'intervals.bed'

    output:
    tuple path("${params.vc_gatk.split_bam_output_filename + "/" + bam.name}"), path("${params.vc_gatk.split_bam_output_filename + "/" + bai.name}"), emit: out

    script:
    def compression_level = null
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    def output_filename = params.vc_gatk.split_bam_output_filename ? params.vc_gatk.split_bam_output_filename : "."
    """
    mkdir -p '${params.vc_gatk.split_bam_output_filename}'; \
    gatk SplitReads \
    --java-options "-Xmx${4 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${intervals} \
    --output ${output_filename} \
    --input ${bam} \
    """

}
