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

process GETPILEUPSUMMARIES {
    debug true
    container "broadinstitute/gatk:4.1.8.1"
    publishDir "${params.outdir}/vc_gatk/getpileupsummaries"
    cpus "${params.vc_gatk.getpileupsummaries.cpus}"
    memory "${params.vc_gatk.getpileupsummaries.memory}"

    input:
    path indexed_bam_array_flat
    tuple path(vcf_gz), path(tbi)
    path intervals, stageAs: 'intervals.bed'

    output:
    path "generated.txt", emit: out

    script:
    def compression_level = null
    def indexed_bam_array_flat = get_primary_files(indexed_bam_array_flat)
    def bam = indexed_bam_array_flat.collect{ "-I " + it }.join(' ')
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    def sample_name = null
    """
    gatk GetPileupSummaries \
    --java-options "-Xmx${64 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${intervals} \
    ${bam} \
    -V ${vcf_gz} \
    -O generated.txt \
    """

}
