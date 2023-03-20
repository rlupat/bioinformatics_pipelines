nextflow.enable.dsl=2

include { ALIGNMENT_NORMAL } from './subworkflows/alignment_normal'
include { ALIGNMENT_TUMOR } from './subworkflows/alignment_tumor'
include { CALCULATE_PERFORMANCESUMMARY_GENOMEFILE } from './modules/calculate_performancesummary_genomefile'
include { PERFORMANCE_SUMMARY_NORMAL } from './subworkflows/performance_summary_normal'
include { PERFORMANCE_SUMMARY_TUMOR } from './subworkflows/performance_summary_tumor'
include { GENERATE_GATK_INTERVALS } from './modules/generate_gatk_intervals'
include { BQSR_NORMAL } from './subworkflows/bqsr_normal'
include { BQSR_TUMOR } from './subworkflows/bqsr_tumor'
include { VC_GATK } from './subworkflows/vc_gatk'
include { VC_GATK_MERGE } from './modules/vc_gatk_merge'
include { VC_GATK_SORT_COMBINED } from './modules/vc_gatk_sort_combined'
include { VC_GATK_UNCOMPRESSVCF } from './modules/vc_gatk_uncompressvcf'
include { ADDBAMSTATS } from './subworkflows/addbamstats'

ch_gatk_intervals   = Channel.fromPath( params.gatk_intervals ).toList().ifEmpty( null )
ch_panel_of_normals = Channel.fromPath( params.panel_of_normals ).toList().ifEmpty( null )
ch_filter           = Channel.of( params.filter ).ifEmpty( null )
ch_min_mapping_qual = Channel.of( params.min_mapping_qual ).ifEmpty( null )
ch_adapter_file     = Channel.fromPath( params.adapter_file )
ch_contaminant_file = Channel.fromPath( params.contaminant_file )
ch_gnomad           = Channel.fromPath( params.gnomad ).toList()
ch_known_indels     = Channel.fromPath( params.known_indels ).toList()
ch_mills_indels     = Channel.fromPath( params.mills_indels ).toList()
ch_reference        = Channel.fromPath( params.reference ).toList()
ch_snps_1000gp      = Channel.fromPath( params.snps_1000gp ).toList()
ch_snps_dbsnp       = Channel.fromPath( params.snps_dbsnp ).toList()
ch_normal_inputs    = Channel.of( params.normal_inputs ).toList()
ch_normal_name      = Channel.of( params.normal_name )
ch_tumor_inputs     = Channel.of( params.tumor_inputs ).toList()


workflow  {

    ALIGNMENT_NORMAL(
        ch_adapter_file,
        ch_contaminant_file,
        ch_normal_inputs.flatten().toList(),
        ch_known_indels,
        ch_mills_indels,
        ch_reference,
        ch_normal_name,
        ch_snps_1000gp,
        ch_snps_dbsnp
    )

    ALIGNMENT_TUMOR(
        ch_adapter_file,
        ch_contaminant_file,
        ch_tumor_inputs.flatten().toList(),
        ch_known_indels,
        ch_mills_indels,
        ch_reference,
        params.tumor_name,
        ch_snps_1000gp,
        ch_snps_dbsnp
    )

    CALCULATE_PERFORMANCESUMMARY_GENOMEFILE(
        params.calculate_performancesummary_genomefile.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    PERFORMANCE_SUMMARY_NORMAL(
        ALIGNMENT_NORMAL.out.out_bam,
        CALCULATE_PERFORMANCESUMMARY_GENOMEFILE.out.out,
        ch_normal_name
    )

    PERFORMANCE_SUMMARY_TUMOR(
        ALIGNMENT_TUMOR.out.out_bam,
        CALCULATE_PERFORMANCESUMMARY_GENOMEFILE.out.out,
        params.tumor_name
    )

    GENERATE_GATK_INTERVALS(
        params.generate_gatk_intervals.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    BQSR_NORMAL(
        ALIGNMENT_NORMAL.out.out_bam,
        ch_known_indels,
        ch_mills_indels,
        ch_reference,
        ch_snps_1000gp,
        ch_snps_dbsnp,
        [ch_gatk_intervals, GENERATE_GATK_INTERVALS.out.out_regions].find{ it != null }.flatten()
    )

    BQSR_TUMOR(
        ALIGNMENT_TUMOR.out.out_bam,
        ch_known_indels,
        ch_mills_indels,
        ch_reference,
        ch_snps_1000gp,
        ch_snps_dbsnp,
        [ch_gatk_intervals, GENERATE_GATK_INTERVALS.out.out_regions].find{ it != null }.flatten()
    )

    VC_GATK(
        ch_gnomad,
        BQSR_NORMAL.out.out,
        ch_reference,
        BQSR_TUMOR.out.out,
        [ch_gatk_intervals, GENERATE_GATK_INTERVALS.out.out_regions].find{ it != null }.flatten(),
        ch_normal_name,
        ch_panel_of_normals
    )

    VC_GATK_MERGE(
        VC_GATK.out.out.toList()
    )

    VC_GATK_SORT_COMBINED(
        VC_GATK_MERGE.out.out
    )

    VC_GATK_UNCOMPRESSVCF(
        VC_GATK_SORT_COMBINED.out.out
    )

    ADDBAMSTATS(
        ALIGNMENT_NORMAL.out.out_bam,
        ch_normal_name,
        ch_reference,
        ALIGNMENT_TUMOR.out.out_bam,
        params.tumor_name,
        VC_GATK_UNCOMPRESSVCF.out.out
    )


}
