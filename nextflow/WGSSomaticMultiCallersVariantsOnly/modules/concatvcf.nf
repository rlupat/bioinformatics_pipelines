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

process CONCATVCF {
    debug true
    container "biocontainers/vcftools:v0.1.16-1-deb_cv1"
    publishDir "${params.outdir}/vc_strelka/concatvcf"

    input:
    path compressed_indexed_vcf_array_flat
    path compressed_indexed_vcf_array_flat

    output:
    path "generated.strelka.vcf", emit: out

    script:
    def compressed_indexed_vcf_array_flat = get_primary_files(compressed_indexed_vcf_array_flat)
    def content_vcfs = compressed_indexed_vcf_array_flat.join(' ')
    def compressed_indexed_vcf_array_flat = get_primary_files(compressed_indexed_vcf_array_flat)
    def header_vcfs = compressed_indexed_vcf_array_flat.join(' ')
    """
    vcf-merge \
    ${header_vcfs} \
    | grep '^##' > header.vcf; \
    vcf-concat \
    ${content_vcfs} \
    | grep -v '^##' > content.vcf; cat header.vcf content.vcf \
    > generated.strelka.vcf \
    """

}
