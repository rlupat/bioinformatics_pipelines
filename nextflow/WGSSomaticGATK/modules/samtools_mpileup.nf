nextflow.enable.dsl=2

process SAMTOOLS_MPILEUP {
    debug true
    container "quay.io/biocontainers/samtools@sha256:3883c91317e7b6b62e31c82e2cef3cc1f3a9862633a13f850a944e828dd165ec"
    publishDir "${params.outdir}/addbamstats/normal/samtools_mpileup"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path positions, stageAs: 'positions'

    output:
    path "generated.txt", emit: out

    script:
    def count_orphans = params.addbamstats.normal.samtools_mpileup_count_orphans == false ? "" : "--count-orphans"
    def max_depth = params.addbamstats.normal.samtools_mpileup_max_depth ? "--max-depth ${params.addbamstats.normal.samtools_mpileup_max_depth}" : ""
    def minbq = params.addbamstats.normal.samtools_mpileup_minbq ? "--min-BQ ${params.addbamstats.normal.samtools_mpileup_minbq}" : ""
    def nobaq = params.addbamstats.normal.samtools_mpileup_nobaq == false ? "" : "--no-BAQ"
    def positions = positions ? "--positions ${positions}" : ""
    def reference = fasta ? "--reference ${fasta}" : ""
    """
    samtools mpileup \
    ${positions} \
    ${reference} \
    ${max_depth} \
    ${minbq} \
    ${count_orphans} \
    ${nobaq} \
    --output generated.txt \
    ${bam} \
    """

}
