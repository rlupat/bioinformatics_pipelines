nextflow.enable.dsl=2

process VC_GATK_SORT_COMBINED {
    debug true
    container "biocontainers/bcftools@sha256:ab5e68068ff56baf59b79f995b5425edba9f61cc86a5476357db87ec2670899d"
    publishDir "${params.outdir}/vc_gatk_sort_combined"
    cpus "${params.vc_gatk_sort_combined.cpus}"
    memory "${params.vc_gatk_sort_combined.memory}"

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
