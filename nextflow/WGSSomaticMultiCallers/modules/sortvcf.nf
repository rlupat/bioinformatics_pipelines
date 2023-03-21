nextflow.enable.dsl=2

process SORTVCF {
    debug true
    container "biocontainers/bcftools@sha256:ab5e68068ff56baf59b79f995b5425edba9f61cc86a5476357db87ec2670899d"
    publishDir "${params.outdir}/vc_strelka/sortvcf"
    cpus "${params.vc_strelka.sortvcf.cpus}"
    memory "${params.vc_strelka.sortvcf.memory}"

    input:
    path vcf

    output:
    path "generated.sorted.vcf.gz", emit: out

    script:
    """
    bcftools sort \
    --output-file generated.sorted.vcf.gz \
    --output-type z \
    ${vcf} \
    """

}
