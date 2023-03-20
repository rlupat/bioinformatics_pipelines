nextflow.enable.dsl=2

process FILTERMUTECT2CALLS {
    debug true
    container "broadinstitute/gatk:4.1.8.1"
    publishDir "${params.outdir}/vc_gatk/filtermutect2calls"
    cpus "${params.vc_gatk.filtermutect2calls.cpus}"
    memory "${params.vc_gatk.filtermutect2calls.memory}"

    input:
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    tuple path(vcf_gz), path(tbi)
    path contamination_table, stageAs: 'contamination_table'
    path read_orientation_model, stageAs: 'read_orientation_model'
    path segmentation_file, stageAs: 'segmentation_file'
    path stats_file, stageAs: 'stats_file'

    output:
    tuple path("${vcf_gz.simpleName + ".vcf.gz"}"), path("${vcf_gz.simpleName + ".vcf.gz.tbi"}"), emit: out

    script:
    def compression_level = null
    def contamination_table = contamination_table ? "--contamination-table ${contamination_table}" : ""
    def java_options = null
    def read_orientation_model = read_orientation_model ? "--orientation-bias-artifact-priors ${read_orientation_model}" : ""
    def segmentation_file = segmentation_file ? "--tumor-segmentation ${segmentation_file}" : ""
    def stats_file = stats_file ? "--stats ${stats_file}" : ""
    """
    gatk FilterMutectCalls \
    --java-options "-Xmx${16 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${contamination_table} \
    ${read_orientation_model} \
    ${stats_file} \
    ${segmentation_file} \
    -R ${fasta} \
    -V ${vcf_gz} \
    -O ${vcf_gz.simpleName}.vcf.gz \
    """

}
