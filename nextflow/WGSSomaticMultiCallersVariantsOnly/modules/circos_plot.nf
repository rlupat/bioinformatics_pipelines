nextflow.enable.dsl=2

process CIRCOS_PLOT {
    debug true
    container "rlupat/pmacutil:latest"
    publishDir "${params.outdir}/circos_plot"
    cpus "${params.circos_plot.cpus}"
    memory "${params.circos_plot.memory}"

    input:
    path facets_file, stageAs: 'facets_file'
    path sv_file, stageAs: 'sv_file.vcf.gz'
    val genome
    val normal_name

    output:
    path "${"."}/${params.tumor_name}--${normal_name}.pdf", emit: out

    script:
    """
    Rscript /app/circos_plot/circos_plot_facets_manta.R \
    ${params.tumor_name} \
    ${normal_name} \
    ${facets_file} \
    ${sv_file} \
    . \
    ${genome} \
    """

}
