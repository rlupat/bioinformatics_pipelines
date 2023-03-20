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

process VC_GRIDSS {
    debug true
    container "gridss/gridss:2.6.2"
    publishDir "${params.outdir}/vc_gridss"
    cpus "${params.vc_gridss.cpus}"
    memory "${params.vc_gridss.memory}"

    input:
    path indexed_bam_array_flat
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path blacklist, stageAs: 'blacklist.bed'

    output:
    path "generated.svs.vcf", emit: out
    path "generated.assembled.bam", emit: assembly

    script:
    def blacklist = blacklist ? "--blacklist ${blacklist}" : ""
    def indexed_bam_array_flat = get_primary_files(indexed_bam_array_flat)
    def bams = indexed_bam_array_flat.join(' ')
    """
    /opt/gridss/gridss.sh \
    --threads 8 \
    --workingdir ./TMP \
    --reference ${fasta} \
    --output generated.svs.vcf \
    --assembly generated.assembled.bam \
    ${blacklist} \
    ${bams} \
    """

}
