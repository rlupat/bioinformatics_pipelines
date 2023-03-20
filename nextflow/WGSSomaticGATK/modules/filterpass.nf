nextflow.enable.dsl=2

process FILTERPASS {
    debug true
    container "biocontainers/vcftools:v0.1.16-1-deb_cv1"
    publishDir "${params.outdir}/vc_gatk/filterpass"

    input:
    path vcf, stageAs: 'vcf.vcf'

    output:
    path "${vcf.simpleName + ".recode.vcf"}", emit: out

    script:
    def recode = params.vc_gatk.filterpass_recode == false ? "" : "--recode"
    def recode_infoall = params.vc_gatk.filterpass_recode_infoall == false ? "" : "--recode-INFO-all"
    def remove_filetered_all = params.vc_gatk.filterpass_remove_filetered_all == false ? "" : "--remove-filtered-all"
    """
    vcftools \
    --vcf ${vcf} \
    --out ${vcf.simpleName} \
    ${recode} \
    ${recode_infoall} \
    ${remove_filetered_all} \
    """

}
