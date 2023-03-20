nextflow.enable.dsl=2

process ADDBAMSTATS {
    debug true
    container "michaelfranklin/pmacutil@sha256:806f1bdcce8aa35baed9a64066878f77315fbd74b98c2bfc64cb5193dcf639c6"
    publishDir "${params.outdir}/vc_gatk_addbamstats/addbamstats"

    input:
    path input_vcf, stageAs: 'input_vcf.vcf'
    path mpileup, stageAs: 'mpileup'

    output:
    path "generated.addbamstats.vcf", emit: out

    script:
    def mpileup = mpileup ? "--mpileup ${mpileup}" : ""
    """
    add_bam_stats.py \
    ${mpileup} \
    -i ${input_vcf} \
    --type ${params.vc_gatk_addbamstats.addbamstats_type} \
    -o generated.addbamstats.vcf \
    """

}
