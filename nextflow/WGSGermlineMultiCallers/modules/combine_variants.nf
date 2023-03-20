nextflow.enable.dsl=2

process COMBINE_VARIANTS {
    debug true
    container "michaelfranklin/pmacutil:0.0.8"
    publishDir "${params.outdir}/combine_variants"
    memory "${params.combine_variants.memory}"

    input:
    path vcfs

    output:
    path "generated.combined.vcf", emit: out

    script:
    def columns = params.combine_variants_columns ? "--columns " + params.combine_variants_columns.join(',') : ""
    def vcfs = vcfs.collect{ "-i " + it }.join(' ')
    """
    combine_vcf.py \
    ${vcfs} \
    ${columns} \
    --type ${params.combine_variants_type} \
    -o generated.combined.vcf \
    """

}
