nextflow.enable.dsl=2

process ADDBAMSTATS {
    debug true
    container "michaelfranklin/pmacutil@sha256:806f1bdcce8aa35baed9a64066878f77315fbd74b98c2bfc64cb5193dcf639c6"
    publishDir "${params.outdir}/addbamstats/addbamstats"

    input:
    path input_vcf, stageAs: 'input_vcf.vcf'
    path normal_mpileup, stageAs: 'normal_mpileup'
    path tumor_mpileup, stageAs: 'tumor_mpileup'
    val normalid
    val tumorid

    output:
    path "generated.addbamstats.vcf", emit: out

    script:
    def normal_mpileup = normal_mpileup ? "--normal_mpileup ${normal_mpileup}" : ""
    def normalid = normalid ? "--normal_id ${normalid}" : ""
    def tumor_mpileup = tumor_mpileup ? "--tumor_mpileup ${tumor_mpileup}" : ""
    def tumorid = tumorid ? "--tumor_id ${tumorid}" : ""
    """
    add_bam_stats.py \
    ${normal_mpileup} \
    ${tumor_mpileup} \
    -i ${input_vcf} \
    ${normalid} \
    ${tumorid} \
    --type ${params.addbamstats.addbamstats_type} \
    -o generated.addbamstats.vcf \
    """

}
