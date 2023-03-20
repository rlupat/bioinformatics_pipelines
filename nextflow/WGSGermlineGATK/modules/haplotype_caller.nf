nextflow.enable.dsl=2

process HAPLOTYPE_CALLER {
    debug true
    container "broadinstitute/gatk@sha256:e37193b61536cf21a2e1bcbdb71eac3d50dcb4917f4d7362b09f8d07e7c2ae50"
    publishDir "${params.outdir}/vc_gatk/haplotype_caller"
    cpus "${params.vc_gatk.haplotype_caller.cpus}"
    memory "${params.vc_gatk.haplotype_caller.memory}"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    tuple path(vcf_gz), path(tbi)
    path intervals, stageAs: 'intervals.bed'

    output:
    tuple path("${bam.simpleName + ".vcf.gz"}"), path("${bam.simpleName + ".vcf.gz.tbi"}"), emit: out
    tuple path("${bam.simpleName + ".bam"}"), path("${bam.simpleName + ".bai"}"), emit: bam

    script:
    def compression_level = null
    def dbsnp = vcf_gz ? "--dbsnp ${vcf_gz}" : ""
    def intervals = intervals ? "--intervals ${intervals}" : ""
    def java_options = null
    def pair_hmm_implementation = params.vc_gatk.haplotype_caller_pair_hmm_implementation ? "--pair-hmm-implementation ${params.vc_gatk.haplotype_caller_pair_hmm_implementation}" : ""
    """
    gatk HaplotypeCaller \
    --java-options "-Xmx${8 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    --input ${bam} \
    ${intervals} \
    ${pair_hmm_implementation} \
    --reference ${fasta} \
    ${dbsnp} \
    --output ${bam.simpleName}.vcf.gz \
    -bamout ${bam.simpleName}.bam \
    """

}
