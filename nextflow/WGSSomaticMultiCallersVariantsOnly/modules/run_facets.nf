nextflow.enable.dsl=2

process RUN_FACETS {
    debug true
    container "stevekm/facets-suite:2.0.8"
    publishDir "${params.outdir}/vc_facets/run_facets"
    memory "${params.vc_facets.run_facets.memory}"

    input:
    path counts_file, stageAs: 'counts_file'
    val cval
    val everything
    val genome
    val normal_depth
    val output_prefix
    val purity_cval

    output:
    path "${output_prefix + ".txt"}", emit: out_summary
    path "${output_prefix + "_purity.png"}", emit: out_purity_png
    path "${output_prefix + "_purity.seg"}", emit: out_purity_seg
    path "${output_prefix + "_purity.rds"}", emit: out_purity_rds
    path "${output_prefix + "_hisens.png"}", emit: out_hisens_png
    path "${output_prefix + "_hisens.seg"}", emit: out_hisens_seg
    path "${output_prefix + "_hisens.rds"}", emit: out_hisens_rds
    path "${output_prefix + ".arm_level.txt"}", optional: true, emit: out_arm_level
    path "${output_prefix + ".gene_level.txt"}", optional: true, emit: out_gene_level
    path "${output_prefix + ".qc.txt"}", optional: true, emit: out_qc

    script:
    def cval = cval ? "--cval ${cval}" : ""
    def directory = params.vc_facets.run_facets_directory ? params.vc_facets.run_facets_directory : .
    def everything = everything == false ? "" : "--everything"
    def genome = genome ? "--genome ${genome}" : ""
    def normal_depth = normal_depth ? "--normal-depth ${normal_depth}" : ""
    def purity_cval = purity_cval ? "--purity-cval ${purity_cval}" : ""
    """
    run-facets-wrapper.R \
    --counts-file ${counts_file} \
    ${cval} \
    --directory ${directory} \
    ${genome} \
    ${normal_depth} \
    ${purity_cval} \
    --sample-id ${output_prefix} \
    ${everything} \
    --facets-lib-path /usr/local/lib/R/site-library \
    """

}
