nextflow.enable.dsl=2

process ANNOTATE {
    debug true
    container "biocontainers/bcftools:v1.5_cv2"
    publishDir "${params.outdir}/vc_vardict/annotate"
    cpus "${params.vc_vardict.annotate.cpus}"
    memory "${params.vc_vardict.annotate.memory}"

    input:
    path vcf, stageAs: 'vcf.vcf'
    path header_lines, stageAs: 'header_lines'

    output:
    path "generated.vcf", emit: out

    script:
    def header_lines = header_lines ? "--header-lines ${header_lines}" : ""
    """
    bcftools annotate \
    ${header_lines} \
    --output generated.vcf \
    ${vcf} \
    """

}
