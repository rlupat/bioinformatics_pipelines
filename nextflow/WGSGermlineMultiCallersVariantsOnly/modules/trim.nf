nextflow.enable.dsl=2

process TRIM {
    debug true
    container "michaelfranklin/pmacutil:0.0.5"
    publishDir "${params.outdir}/vc_vardict/trim"
    cpus "${params.vc_vardict.trim.cpus}"
    memory "${params.vc_vardict.trim.memory}"

    input:
    path vcf, stageAs: 'vcf.vcf'

    output:
    path "generated.trimmed.vcf", emit: out

    script:
    """
    trimIUPAC.py \
    ${vcf} \
    generated.trimmed.vcf \
    """

}
