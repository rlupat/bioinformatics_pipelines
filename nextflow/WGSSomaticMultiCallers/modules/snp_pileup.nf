nextflow.enable.dsl=2

process SNP_PILEUP {
    debug true
    container "stevekm/facets-suite:2.0.8"
    publishDir "${params.outdir}/vc_facets/snp_pileup"

    input:
    tuple path(bam), path(bai)
    tuple path(bam), path(bai)
    path vcf_file, stageAs: 'vcf_file'
    val max_depth
    val output_prefix
    val pseudo_snps

    output:
    path "${output_prefix + ".snp_pileup.gz"}", emit: out

    script:
    def max_depth = max_depth ? "--max-depth ${max_depth}" : ""
    def pseudo_snps = pseudo_snps ? "--pseudo-snps ${pseudo_snps}" : ""
    """
    snp-pileup-wrapper.R \
    --normal-bam ${bam} \
    --tumor-bam ${bam} \
    --vcf-file ${vcf_file} \
    ${max_depth} \
    --output-prefix ${output_prefix} \
    ${pseudo_snps} \
    """

}
