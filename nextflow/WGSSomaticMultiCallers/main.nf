nextflow.enable.dsl=2

include { ALIGNMENT_NORMAL } from './subworkflows/alignment_normal'
include { ALIGNMENT_TUMOR } from './subworkflows/alignment_tumor'
include { CALCULATE_PERFORMANCESUMMARY_GENOMEFILE } from './modules/calculate_performancesummary_genomefile'
include { PERFORMANCE_SUMMARY_NORMAL } from './subworkflows/performance_summary_normal'
include { PERFORMANCE_SUMMARY_TUMOR } from './subworkflows/performance_summary_tumor'
include { VC_GRIDSS } from './modules/vc_gridss'
include { VC_FACETS } from './subworkflows/vc_facets'
include { GENERATE_GATK_INTERVALS } from './modules/generate_gatk_intervals'
include { BQSR_NORMAL } from './subworkflows/bqsr_normal'
include { BQSR_TUMOR } from './subworkflows/bqsr_tumor'
include { VC_GATK } from './subworkflows/vc_gatk'
include { VC_GATK_MERGE } from './modules/vc_gatk_merge'
include { VC_GATK_SORT_COMBINED } from './modules/vc_gatk_sort_combined'
include { VC_GATK_UNCOMPRESSVCF } from './modules/vc_gatk_uncompressvcf'
include { GENERATE_VARDICT_HEADERLINES } from './modules/generate_vardict_headerlines'
include { VC_VARDICT } from './subworkflows/vc_vardict'
include { VC_VARDICT_MERGE } from './modules/vc_vardict_merge'
include { VC_VARDICT_SORT_COMBINED } from './modules/vc_vardict_sort_combined'
include { VC_VARDICT_UNCOMPRESS_FOR_COMBINE } from './modules/vc_vardict_uncompress_for_combine'
include { GENERATE_MANTA_CONFIG } from './modules/generate_manta_config'
include { VC_STRELKA } from './subworkflows/vc_strelka'
include { VC_STRELKA_COMPRESS } from './modules/vc_strelka_compress'
include { CIRCOS_PLOT } from './modules/circos_plot'
include { COMBINE_VARIANTS } from './modules/combine_variants'
include { COMBINED_COMPRESS } from './modules/combined_compress'
include { COMBINED_SORT } from './modules/combined_sort'
include { COMBINED_UNCOMPRESS } from './modules/combined_uncompress'
include { COMBINED_ADDBAMSTATS } from './subworkflows/combined_addbamstats'

ch_gatk_intervals    = Channel.fromPath( params.gatk_intervals ).toList().ifEmpty( null )
ch_panel_of_normals  = Channel.fromPath( params.panel_of_normals ).toList().ifEmpty( null )
ch_cval              = Channel.of( params.cval ).ifEmpty( null )
ch_everything        = Channel.of( params.everything ).ifEmpty( null )
ch_filter            = Channel.of( params.filter ).ifEmpty( null )
ch_max_depth         = Channel.of( params.max_depth ).ifEmpty( null )
ch_min_mapping_qual  = Channel.of( params.min_mapping_qual ).ifEmpty( null )
ch_normal_depth      = Channel.of( params.normal_depth ).ifEmpty( null )
ch_pseudo_snps       = Channel.of( params.pseudo_snps ).ifEmpty( null )
ch_purity_cval       = Channel.of( params.purity_cval ).ifEmpty( null )
ch_adapter_file      = Channel.fromPath( params.adapter_file )
ch_contaminant_file  = Channel.fromPath( params.contaminant_file )
ch_gnomad            = Channel.fromPath( params.gnomad ).toList()
ch_gridss_blacklist  = Channel.fromPath( params.gridss_blacklist )
ch_known_indels      = Channel.fromPath( params.known_indels ).toList()
ch_mills_indels      = Channel.fromPath( params.mills_indels ).toList()
ch_reference         = Channel.fromPath( params.reference ).toList()
ch_snps_1000gp       = Channel.fromPath( params.snps_1000gp ).toList()
ch_snps_dbsnp        = Channel.fromPath( params.snps_dbsnp ).toList()
ch_strelka_intervals = Channel.fromPath( params.strelka_intervals ).toList()
ch_vardict_intervals = Channel.fromPath( params.vardict_intervals ).toList()
ch_genome            = Channel.of( params.genome )
ch_normal_inputs     = Channel.of( params.normal_inputs ).toList()
ch_normal_name       = Channel.of( params.normal_name )
ch_tumor_inputs      = Channel.of( params.tumor_inputs ).toList()


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

    VC_GRIDSS(
        ALIGNMENT_NORMAL.out.out_bam.flatten().toList(),
        ch_reference,
        ch_gridss_blacklist
    )

    VC_FACETS(
        ALIGNMENT_NORMAL.out.out_bam,
        ch_normal_name,
        ch_snps_dbsnp.map{ tuple -> tuple[0] },
        ALIGNMENT_TUMOR.out.out_bam,
        params.tumor_name,
        ch_cval,
        ch_everything,
        ch_genome,
        ch_max_depth,
        ch_normal_depth,
        ch_pseudo_snps,
        ch_purity_cval
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

    GENERATE_VARDICT_HEADERLINES(
        params.generate_vardict_headerlines.code_file,
        ch_reference.map{ tuple -> [tuple[0], tuple[4]] }
    )

    VC_VARDICT(
        GENERATE_VARDICT_HEADERLINES.out.out,
        ch_vardict_intervals.flatten(),
        ALIGNMENT_NORMAL.out.out_bam,
        ch_normal_name,
        ch_reference,
        ALIGNMENT_TUMOR.out.out_bam,
        params.tumor_name,
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

    GENERATE_MANTA_CONFIG(
        params.generate_manta_config.code_file
    )

    VC_STRELKA(
        ALIGNMENT_NORMAL.out.out_bam,
        ch_reference,
        ALIGNMENT_TUMOR.out.out_bam,
        ch_strelka_intervals,
        GENERATE_MANTA_CONFIG.out.out
    )

    VC_STRELKA_COMPRESS(
        VC_STRELKA.out.out
    )

    CIRCOS_PLOT(
        VC_FACETS.out.out_hisens_rds,
        assert V != null.map{ tuple -> tuple[0] },
        ch_genome,
        ch_normal_name
    )

    COMBINE_VARIANTS(
        VC_GATK_UNCOMPRESSVCF.out.out.toList(),
        ch_normal_name
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
        ALIGNMENT_NORMAL.out.out_bam,
        ch_normal_name,
        ch_reference,
        ALIGNMENT_TUMOR.out.out_bam,
        params.tumor_name,
        COMBINED_UNCOMPRESS.out.out
    )


}
