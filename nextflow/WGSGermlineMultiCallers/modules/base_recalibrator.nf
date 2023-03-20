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

process BASE_RECALIBRATOR {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/bqsr/base_recalibrator"
    cpus "${params.bqsr.base_recalibrator.cpus}"
    memory "${params.bqsr.base_recalibrator.memory}"

    input:
    tuple path(bam), path(bai)
    path compressed_indexed_vcf_array_flat
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path intervals, stageAs: 'intervals.bed'

    output:
    path "${bam.simpleName + ".table"}", emit: out

    script:
    def compressed_indexed_vcf_array_flat = get_primary_files(compressed_indexed_vcf_array_flat)
    def known_sites = compressed_indexed_vcf_array_flat.collect{ "--known-sites " + it }.join(' ')
    def compression_level = null
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    """
    gatk BaseRecalibrator \
    --java-options "-Xmx${16 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${intervals} \
    --tmp-dir /tmp/ \
    -R ${fasta} \
    -I ${bam} \
    -O ${bam.simpleName}.table \
    ${known_sites} \
    """

}
