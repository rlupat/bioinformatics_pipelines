nextflow.enable.dsl=2

process SORTSAM {
    debug true
    container "broadinstitute/gatk@sha256:c0f45677e9af6bba65e7234c33a7447f615febd1217e80ea2231fab69bb350a0"
    publishDir "${params.outdir}/sortsam"
    cpus "${params.sortsam.cpus}"
    memory "${params.sortsam.memory}"

    input:
    path bam, stageAs: 'bam.bam'

    output:
    tuple path("${bam.simpleName + ".sorted.bam"}"), path("${bam.simpleName + ".sorted.bai"}"), emit: out

    script:
    def compression_level = null
    def create_index = params.sortsam_create_index == false ? "" : "--CREATE_INDEX"
    def java_options = null
    def max_records_in_ram = params.sortsam_max_records_in_ram ? "--MAX_RECORDS_IN_RAM ${params.sortsam_max_records_in_ram}" : ""
    def tmp_dir = params.sortsam_tmp_dir ? params.sortsam_tmp_dir : /tmp/
    def validation_stringency = params.sortsam_validation_stringency ? "--VALIDATION_STRINGENCY ${params.sortsam_validation_stringency}" : ""
    """
    gatk SortSam \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    -I ${bam} \
    -SO ${params.sortsam_sort_order} \
    -O ${bam.simpleName}.sorted.bam \
    ${max_records_in_ram} \
    --TMP_DIR ${tmp_dir} \
    ${validation_stringency} \
    ${create_index} \
    """

}
