nextflow.enable.dsl=2

include { CALCULATE_PERFORMANCESUMMARY_GENOMEFILE } from './modules/calculate_performancesummary_genomefile'
include { PERFORMANCE_SUMMARY } from './subworkflows/performance_summary'
include { GENERATE_GATK_INTERVALS } from './modules/generate_gatk_intervals'
include { BQSR } from './subworkflows/bqsr'
include { VC_GATK } from './subworkflows/vc_gatk'
include { VC_GATK_MERGE } from './modules/vc_gatk_merge'
include { VC_GATK_SORT_COMBINED } from './modules/vc_gatk_sort_combined'
include { VC_GATK_UNCOMPRESS } from './modules/vc_gatk_uncompress'
include { VC_GATK_ADDBAMSTATS } from './subworkflows/vc_gatk_addbamstats'

ch_gatk_intervals   = Channel.fromPath( params.gatk_intervals ).toList().ifEmpty( null )
ch_adapter_file     = Channel.fromPath( params.adapter_file )
ch_bam              = Channel.fromPath( params.bam ).toList()
ch_contaminant_file = Channel.fromPath( params.contaminant_file )
ch_known_indels     = Channel.fromPath( params.known_indels ).toList()
ch_mills_indels     = Channel.fromPath( params.mills_indels ).toList()
ch_reference        = Channel.fromPath( params.reference ).toList()
ch_snps_1000gp      = Channel.fromPath( params.snps_1000gp ).toList()
ch_snps_dbsnp       = Channel.fromPath( params.snps_dbsnp ).toList()


workflow  {

    CALCULATE_PERFORMANCESUMMARY_GENOMEFILE(
        params.calculate_performancesummary_genomefile.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    PERFORMANCE_SUMMARY(
        ch_bam,
        CALCULATE_PERFORMANCESUMMARY_GENOMEFILE.out.out,
        params.sample_name
    )

    GENERATE_GATK_INTERVALS(
        params.generate_gatk_intervals.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    BQSR(
        ch_bam,
        ch_known_indels,
        ch_mills_indels,
        ch_reference,
        ch_snps_1000gp,
        ch_snps_dbsnp,
        [ch_gatk_intervals, GENERATE_GATK_INTERVALS.out.out_regions].find{ it != null }.flatten()
    )

    VC_GATK(
        BQSR.out.out,
        ch_reference,
        ch_snps_dbsnp,
        [ch_gatk_intervals, GENERATE_GATK_INTERVALS.out.out_regions].find{ it != null }.flatten()
    )

    VC_GATK_MERGE(
        VC_GATK.out.out.toList()
    )

    VC_GATK_SORT_COMBINED(
        VC_GATK_MERGE.out.out
    )

    VC_GATK_UNCOMPRESS(
        VC_GATK_SORT_COMBINED.out.out
    )

    VC_GATK_ADDBAMSTATS(
        ch_bam,
        ch_reference,
        VC_GATK_UNCOMPRESS.out.out
    )


}
