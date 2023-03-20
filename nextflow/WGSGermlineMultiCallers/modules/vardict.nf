nextflow.enable.dsl=2

process VARDICT {
    debug true
    container "michaelfranklin/vardict:1.6.0"
    publishDir "${params.outdir}/vc_vardict/vardict"
    cpus "${params.vc_vardict.vardict.cpus}"
    memory "${params.vc_vardict.vardict.memory}"

    input:
    tuple path(bam), path(bai)
    tuple path(fasta), path(fai)
    path intervals, stageAs: 'intervals.bed'
    val sample_name
    val var2vcf_allele_freq_threshold
    val var2vcf_sample_name
    val allele_freq_threshold
    val filter
    val min_mapping_qual

    output:
    path "generated.vardict.vcf", emit: out

    script:
    def allele_freq_threshold = allele_freq_threshold ? "-f ${allele_freq_threshold}" : ""
    def chrom_column = params.vc_vardict.vardict_chrom_column ? "-c ${params.vc_vardict.vardict_chrom_column}" : ""
    def filter = filter ? "-F ${filter}" : ""
    def gene_end_col = params.vc_vardict.vardict_gene_end_col ? "-E ${params.vc_vardict.vardict_gene_end_col}" : ""
    def min_mapping_qual = min_mapping_qual ? "-Q ${min_mapping_qual}" : ""
    def reg_start_col = params.vc_vardict.vardict_reg_start_col ? "-S ${params.vc_vardict.vardict_reg_start_col}" : ""
    def threads = params.vc_vardict.vardict_threads ? params.vc_vardict.vardict_threads : 4
    def vcf_format = params.vc_vardict.vardict_vcf_format == false ? "" : "-v"
    """
    VarDict \
    -G ${fasta} \
    -b ${bam} \
    ${gene_end_col} \
    ${filter} \
    -N ${sample_name} \
    ${min_mapping_qual} \
    ${reg_start_col} \
    ${chrom_column} \
    ${allele_freq_threshold} \
    -th ${threads} \
    ${vcf_format} \
    ${intervals} \
    | teststrandbias.R | \
    var2vcf_valid.pl \
    -N ${var2vcf_sample_name} \
    -f ${var2vcf_allele_freq_threshold} \
    > generated.vardict.vcf \
    """

}
