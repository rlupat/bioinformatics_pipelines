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

process MUTECT2 {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/vc_gatk/mutect2"
    cpus "${params.vc_gatk.mutect2.cpus}"
    memory "${params.vc_gatk.mutect2.memory}"

    input:
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path indexed_bam_array_flat
    tuple path(vcf_gz), path(tbi)
    path indexed_bam_array_flat
    tuple path(vcf_gz), path(tbi)
    path intervals, stageAs: 'intervals.bed'
    val normal_sample
    val output_prefix

    output:
    tuple path("${output_prefix + ".vcf.gz"}"), path("${output_prefix + ".vcf.gz.tbi"}"), emit: out
    path "${output_prefix + ".vcf.gz" + ".stats"}", emit: stats
    path "generated.tar.gz", emit: f1f2r_out
    tuple path(params.vc_gatk.output_bam_name), path("${params.vc_gatk.output_bam_name}.bai"), optional: true, emit: bam

    script:
    def compression_level = null
    def germline_resource = vcf_gz ? "--germline-resource ${vcf_gz}" : ""
    def indexed_bam_array_flat = get_primary_files(indexed_bam_array_flat)
    def normal_bams = indexed_bam_array_flat ? "-I " + indexed_bam_array_flat.join(' ') : ""
    def indexed_bam_array_flat = get_primary_files(indexed_bam_array_flat)
    def tumor_bams = indexed_bam_array_flat.collect{ "-I " + it }.join(' ')
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    def normal_sample = normal_sample ? "--normal-sample ${normal_sample}" : ""
    def output_bam_name = params.vc_gatk.output_bam_name ? "-bamout ${params.vc_gatk.output_bam_name}" : ""
    def panel_of_normals = vcf_gz ? "--panel-of-normals ${vcf_gz}" : ""
    """
    gatk Mutect2 \
    --java-options "-Xmx${16 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${germline_resource} \
    ${intervals} \
    ${panel_of_normals} \
    --reference ${fasta} \
    ${tumor_bams} \
    ${normal_bams} \
    ${normal_sample} \
    ${output_bam_name} \
    --f1r2-tar-gz generated.tar.gz \
    --native-pair-hmm-threads 4 \
    -O ${output_prefix}.vcf.gz \
    """

}
