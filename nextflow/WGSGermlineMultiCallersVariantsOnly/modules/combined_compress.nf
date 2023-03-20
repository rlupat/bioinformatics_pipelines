nextflow.enable.dsl=2

process COMBINED_COMPRESS {
    debug true
    container "biodckrdev/htslib@sha256:331b6646700cc4b12871395caa1ef89f137e1b77f7173e73581e7f8f7fafa636"
    publishDir "${params.outdir}/combined_compress"

    input:
    path file, stageAs: 'file'

    output:
    path "${file.name + ".gz"}", emit: out

    script:
    """
    bgzip \
    --stdout \
    ${file} \
    > \
    ${file.name}.gz \
    """

}
