nextflow.enable.dsl=2

include { CALCULATE_PERFORMANCESUMMARY_GENOMEFILE } from './modules/calculate_performancesummary_genomefile'
include { PERFORMANCE_SUMMARY } from './subworkflows/performance_summary'
include { VC_GRIDSS } from './modules/vc_gridss'
include { GENERATE_GATK_INTERVALS } from './modules/generate_gatk_intervals'
include { BQSR } from './subworkflows/bqsr'
include { VC_GATK } from './subworkflows/vc_gatk'
include { VC_GATK_MERGE } from './modules/vc_gatk_merge'
include { VC_GATK_SORT_COMBINED } from './modules/vc_gatk_sort_combined'
include { VC_GATK_UNCOMPRESS } from './modules/vc_gatk_uncompress'
include { GENERATE_MANTA_CONFIG } from './modules/generate_manta_config'
include { VC_STRELKA } from './subworkflows/vc_strelka'
include { VC_STRELKA_COMPRESS } from './modules/vc_strelka_compress'
include { GENERATE_VARDICT_HEADERLINES } from './modules/generate_vardict_headerlines'
include { VC_VARDICT } from './subworkflows/vc_vardict'
include { VC_VARDICT_MERGE } from './modules/vc_vardict_merge'
include { VC_VARDICT_SORT_COMBINED } from './modules/vc_vardict_sort_combined'
include { VC_VARDICT_UNCOMPRESS_FOR_COMBINE } from './modules/vc_vardict_uncompress_for_combine'
include { COMBINE_VARIANTS } from './modules/combine_variants'
include { COMBINED_COMPRESS } from './modules/combined_compress'
include { COMBINED_SORT } from './modules/combined_sort'
include { COMBINED_UNCOMPRESS } from './modules/combined_uncompress'
include { COMBINED_ADDBAMSTATS } from './subworkflows/combined_addbamstats'

ch_gatk_intervals    = Channel.fromPath( params.gatk_intervals ).toList().ifEmpty( null )
ch_filter            = Channel.of( params.filter ).ifEmpty( null )
ch_min_mapping_qual  = Channel.of( params.min_mapping_qual ).ifEmpty( null )
ch_adapter_file      = Channel.fromPath( params.adapter_file )
ch_bam               = Channel.fromPath( params.bam ).toList()
ch_contaminant_file  = Channel.fromPath( params.contaminant_file )
ch_gridss_blacklist  = Channel.fromPath( params.gridss_blacklist )
ch_known_indels      = Channel.fromPath( params.known_indels ).toList()
ch_mills_indels      = Channel.fromPath( params.mills_indels ).toList()
ch_reference         = Channel.fromPath( params.reference ).toList()
ch_snps_1000gp       = Channel.fromPath( params.snps_1000gp ).toList()
ch_snps_dbsnp        = Channel.fromPath( params.snps_dbsnp ).toList()
ch_strelka_intervals = Channel.fromPath( params.strelka_intervals ).toList()
ch_vardict_intervals = Channel.fromPath( params.vardict_intervals ).toList()


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

    VC_GRIDSS(
        ch_bam.flatten().toList(),
        ch_reference,
        ch_gridss_blacklist
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

    GENERATE_MANTA_CONFIG(
        params.generate_manta_config.code_file
    )

    VC_STRELKA(
        ch_bam,
        ch_reference,
        ch_strelka_intervals,
        GENERATE_MANTA_CONFIG.out.out
    )

    VC_STRELKA_COMPRESS(
        VC_STRELKA.out.out
    )

    GENERATE_VARDICT_HEADERLINES(
        params.generate_vardict_headerlines.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    VC_VARDICT(
        ch_bam,
        GENERATE_VARDICT_HEADERLINES.out.out,
        ch_vardict_intervals.flatten(),
        ch_reference,
        params.sample_name,
        params.allele_freq_threshold,
        ch_filter,
        ch_min_mapping_qual
    )

    VC_VARDICT_MERGE(
        VC_VARDICT.out.out.toList()
    )

    VC_VARDICT_SORT_COMBINED(
        VC_VARDICT_MERGE.out.out
    )

    VC_VARDICT_UNCOMPRESS_FOR_COMBINE(
        VC_VARDICT_SORT_COMBINED.out.out
    )

    COMBINE_VARIANTS(
        VC_GATK_UNCOMPRESS.out.out.toList()
    )

    COMBINED_COMPRESS(
        COMBINE_VARIANTS.out.out
    )

    COMBINED_SORT(
        COMBINED_COMPRESS.out.out
    )

    COMBINED_UNCOMPRESS(
        COMBINED_SORT.out.out
    )

    COMBINED_ADDBAMSTATS(
        ch_bam,
        ch_reference,
        COMBINED_UNCOMPRESS.out.out
    )


}
