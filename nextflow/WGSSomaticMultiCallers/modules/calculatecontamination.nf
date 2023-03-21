nextflow.enable.dsl=2

process CALCULATECONTAMINATION {
    debug true
    container "broadinstitute/gatk:4.1.8.1"
    publishDir "${params.outdir}/vc_gatk/calculatecontamination"
    cpus "${params.vc_gatk.calculatecontamination.cpus}"
    memory "${params.vc_gatk.calculatecontamination.memory}"

    input:
    path pileup_table, stageAs: 'pileup_table'

    output:
    path "${pileup_table.simpleName + ".mutect2_contamination"}", emit: contOut
    path "${pileup_table.simpleName + ".mutect2_segments"}", emit: segOut

    script:
    def compression_level = null
    def java_options = null
    """
    gatk CalculateContamination \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    -I ${pileup_table} \
    --tumor-segmentation ${pileup_table.simpleName}.mutect2_segments \
    -O ${pileup_table.simpleName}.mutect2_contamination \
    """

}
