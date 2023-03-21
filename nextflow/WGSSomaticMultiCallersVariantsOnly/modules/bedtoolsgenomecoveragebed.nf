nextflow.enable.dsl=2

process BEDTOOLSGENOMECOVERAGEBED {
    debug true
    container "quay.io/biocontainers/bedtools@sha256:02e198f8f61329f9eafd1b9fc55828a31020b383403adec22079592b7d868006"
    publishDir "${params.outdir}/performance_summary_tumor/bedtoolsgenomecoveragebed"
    memory "${params.performance_summary_tumor.bedtoolsgenomecoveragebed.memory}"

    input:
    path genome, stageAs: 'genome'
    path input_bam, stageAs: 'input_bam.bam'

    output:
    path "generated", emit: out

    script:
    def genome = genome ? "-g ${genome}" : ""
    def input_bam = input_bam ? "-ibam ${input_bam}" : ""
    """
    genomeCoverageBed \
    ${genome} \
    ${input_bam} \
    > generated \
    """

}
