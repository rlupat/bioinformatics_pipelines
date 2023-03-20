nextflow.enable.dsl=2

def get_primary_files(var) {
    def primary_files = []
    var.eachWithIndex {item, index -> 
        if (index % 2 == 0) {
            primary_files.add(item)
        }
    }
    return primary_files
}

process MERGE_SAM_FILES {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/alignment_tumor/merge_and_markdups/mergesamfiles"
    cpus "${params.alignment_tumor.merge_and_markdups.merge_sam_files.cpus}"
    memory "${params.alignment_tumor.merge_and_markdups.merge_sam_files.memory}"

    input:
    path indexed_bam_array_flat
    val sample_name

    output:
    tuple path("${sample_name + ".merged.bam"}"), path("${sample_name + ".merged.bai"}"), emit: out

    script:
    def compression_level = null
    def create_index = params.alignment_tumor.merge_and_markdups.create_index == false ? "" : "--CREATE_INDEX"
    def indexed_bam_array_flat = get_primary_files(indexed_bam_array_flat)
    def bams = indexed_bam_array_flat.collect{ "-I " + it }.join(' ')
    def java_options = null
    def max_records_in_ram = params.alignment_tumor.merge_and_markdups.max_records_in_ram ? "--MAX_RECORDS_IN_RAM ${params.alignment_tumor.merge_and_markdups.max_records_in_ram}" : ""
    def use_threading = params.alignment_tumor.merge_and_markdups.merge_sam_files_use_threading == false ? "" : "--USE_THREADING"
    def validation_stringency = params.alignment_tumor.merge_and_markdups.merge_sam_files_validation_stringency ? "--VALIDATION_STRINGENCY ${params.alignment_tumor.merge_and_markdups.merge_sam_files_validation_stringency}" : ""
    """
    gatk MergeSamFiles \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${use_threading} \
    ${bams} \
    -O ${sample_name}.merged.bam \
    ${max_records_in_ram} \
    ${validation_stringency} \
    ${create_index} \
    --TMP_DIR /tmp/ \
    """

}
