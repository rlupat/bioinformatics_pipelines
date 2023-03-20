nextflow.enable.dsl=2

process STRELKA {
    debug true
    container "michaelfranklin/strelka:2.9.10"
    publishDir "${params.outdir}/vc_strelka/strelka"
    cpus "${params.vc_strelka.strelka.cpus}"
    memory "${params.vc_strelka.strelka.memory}"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    tuple path(bed_gz), path(tbi)

    output:
    path "${"strelka_dir" + "/runWorkflow.py.config.pickle"}", emit: configPickle
    path "${"strelka_dir" + "/runWorkflow.py"}", emit: script
    path "${"strelka_dir" + "/results/stats/runStats.tsv"}", emit: stats
    tuple path("${"strelka_dir" + "/results/variants/variants.vcf.gz"}"), path("${"strelka_dir" + "/results/variants/variants.vcf.gz.tbi"}"), emit: variants
    tuple path("${"strelka_dir" + "/results/variants/genome.vcf.gz"}"), path("${"strelka_dir" + "/results/variants/genome.vcf.gz.tbi"}"), emit: genome

    script:
    def call_regions = bed_gz ? "--callRegions=${bed_gz}" : ""
    def config = params.vc_strelka.strelka_config ? "--config ${params.vc_strelka.strelka_config}" : ""
    def exome = params.vc_strelka.is_exome == false ? "" : "--exome"
    """
    configureStrelkaGermlineWorkflow.py \
    --bam ${bam} \
    ${call_regions} \
    ${config} \
    --referenceFasta ${fasta} \
    ${exome} \
    --runDir strelka_dir \
    ;${"strelka_dir"}/runWorkflow.py \
    --mode local \
    --jobs 4 \
    --memGb 4 \
    """

}
