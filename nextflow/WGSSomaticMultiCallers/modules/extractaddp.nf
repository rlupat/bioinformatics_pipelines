nextflow.enable.dsl=2

process EXTRACTADDP {
    debug true
    container "michaelfranklin/pmacutil:0.1.1"
    publishDir "${params.outdir}/vc_strelka/extractaddp"
    memory "${params.vc_strelka.extractaddp.memory}"

    input:
    path vcf, stageAs: 'vcf.vcf'

    output:
    path "generated.vcf", emit: out

    script:
    """
    extract_strelka_somatic_DP_AF.py \
    -i ${vcf} \
    -o generated.vcf \
    """

}
