nextflow.enable.dsl=2

process TABIXVCF {
    debug true
    container "biodckrdev/htslib@sha256:331b6646700cc4b12871395caa1ef89f137e1b77f7173e73581e7f8f7fafa636"
    publishDir "${params.outdir}/vc_vardict/tabixvcf"

    input:
    path inp, stageAs: 'inp.gz'

    output:
    tuple path(inp), path("${inp}.tbi"), emit: out

    script:
    """
    tabix \
    --preset vcf \
    ${inp} \
    """

}
