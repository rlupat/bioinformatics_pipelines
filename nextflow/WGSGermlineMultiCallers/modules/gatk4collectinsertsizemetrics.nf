nextflow.enable.dsl=2

process GATK4COLLECTINSERTSIZEMETRICS {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/performance_summary/gatk4collectinsertsizemetrics"
    cpus "${params.performance_summary.gatk4collectinsertsizemetrics.cpus}"
    memory "${params.performance_summary.gatk4collectinsertsizemetrics.memory}"

    input:
    tuple path(bam), path(bai)

    output:
    path "${bam.simpleName + ".metrics.txt"}", emit: out
    path "${bam.simpleName + ".histogram.pdf"}", emit: outHistogram

    script:
    def compression_level = null
    def java_options = null
    """
    gatk CollectInsertSizeMetrics \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    -H ${bam.simpleName}.histogram.pdf \
    -O ${bam.simpleName}.metrics.txt \
    -I ${bam} \
    """

}
