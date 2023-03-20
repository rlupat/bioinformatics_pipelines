nextflow.enable.dsl=2

process RMDUPBAMFLAGSTAT {
    debug true
    container "quay.io/biocontainers/samtools@sha256:3883c91317e7b6b62e31c82e2cef3cc1f3a9862633a13f850a944e828dd165ec"
    publishDir "${params.outdir}/performance_summary/rmdupbamflagstat"

    input:
    path bam, stageAs: 'bam.bam'

    output:
    path "generated", emit: out

    script:
    """
    samtools flagstat \
    ${bam} \
    > generated \
    """

}
