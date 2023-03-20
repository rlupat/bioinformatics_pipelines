nextflow.enable.dsl=2

process APPLY_BQSR {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/bqsr/apply_bqsr"
    cpus "${params.bqsr.apply_bqsr.cpus}"
    memory "${params.bqsr.apply_bqsr.memory}"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path intervals, stageAs: 'intervals.bed'
    path recal_file, stageAs: 'recal_file.tsv'

    output:
    tuple path("${bam.simpleName + ".recalibrated.bam"}"), path("${bam.simpleName + ".recalibrated.bai"}"), emit: out

    script:
    def compression_level = null
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    def recal_file = recal_file ? "--bqsr-recal-file ${recal_file}" : ""
    """
    gatk ApplyBQSR \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${recal_file} \
    ${intervals} \
    -R ${fasta} \
    -O ${bam.simpleName}.recalibrated.bam \
    -I ${bam} \
    --tmp-dir /tmp/ \
    """

}
