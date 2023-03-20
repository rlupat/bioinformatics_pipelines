nextflow.enable.dsl=2

process VC_GATK_MERGE {
    debug true
    container "biocontainers/bcftools@sha256:ab5e68068ff56baf59b79f995b5425edba9f61cc86a5476357db87ec2670899d"
    publishDir "${params.outdir}/vc_gatk_merge"

    input:
    path vcf

    output:
    path "generated.vcf.gz", emit: out

    script:
    def vcf = vcf.join(' ')
    """
    bcftools concat \
    -O z \
    -o generated.vcf.gz \
    ${vcf} \
    """

}
