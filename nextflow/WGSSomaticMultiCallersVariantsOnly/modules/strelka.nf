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

process STRELKA {
    debug true
    container "michaelfranklin/strelka:2.9.10"
    publishDir "${params.outdir}/vc_strelka/strelka"
    cpus "${params.vc_strelka.strelka.cpus}"
    memory "${params.vc_strelka.strelka.memory}"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(fai)
    tuple path(bam), path(bai)
    tuple path(bed_gz), path(tbi)
    path compressed_indexed_vcf_array_flat

    output:
    path "${"generated" + "/runWorkflow.py.config.pickle"}", emit: configPickle
    path "${"generated" + "/runWorkflow.py"}", emit: script
    path "${"generated" + "/results/stats/runStats.tsv"}", emit: stats
    tuple path("${"generated" + "/results/variants/somatic.indels.vcf.gz"}"), path("${"generated" + "/results/variants/somatic.indels.vcf.gz.tbi"}"), emit: indels
    tuple path("${"generated" + "/results/variants/somatic.snvs.vcf.gz"}"), path("${"generated" + "/results/variants/somatic.snvs.vcf.gz.tbi"}"), emit: snvs

    script:
    def call_regions = bed_gz ? "--callRegions=${bed_gz}" : ""
    def compressed_indexed_vcf_array_flat = get_primary_files(compressed_indexed_vcf_array_flat)
    def indel_candidates = compressed_indexed_vcf_array_flat ? compressed_indexed_vcf_array_flat.collect{ "--indelCandidates=" + it }.join(' ') : ""
    def config = params.vc_strelka.strelka_config ? "--config=${params.vc_strelka.strelka_config}" : ""
    def exome = params.vc_strelka.is_exome == false ? "" : "--exome"
    """
    configureStrelkaSomaticWorkflow.py \
    ${call_regions} \
    ${config} \
    ${indel_candidates} \
    --normalBam=${bam} \
    --referenceFasta=${fasta} \
    --tumourBam=${bam} \
    ${exome} \
    --runDir=generated \
    ;${"generated"}/runWorkflow.py \
    --mode local \
    --jobs 4 \
    --memGb 4 \
    """

}
