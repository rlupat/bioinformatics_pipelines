nextflow.enable.dsl=2

include { VARDICT } from '../modules/vardict'
include { ANNOTATE } from '../modules/annotate'
include { COMPRESSVCF } from '../modules/compressvcf'
include { TABIXVCF } from '../modules/tabixvcf'
include { SPLITNORMALISEVCF } from '../modules/splitnormalisevcf'
include { TRIM } from '../modules/trim'
include { FILTERPASS } from '../modules/filterpass'

workflow VC_VARDICT {

    take:
    ch_bam
    ch_header_lines
    ch_intervals
    ch_reference
    ch_sample_name
    ch_allele_freq_threshold
    ch_filter
    ch_min_mapping_qual

    main:
    VARDICT(
        ch_bam,
        ch_reference.map{ tuple -> [tuple[0], tuple[5]] },
        ch_intervals,
        ch_sample_name,
        ch_allele_freq_threshold,
        ch_sample_name,
        ch_allele_freq_threshold,
        ch_filter,
        ch_min_mapping_qual
    )

    ANNOTATE(
        VARDICT.out.out,
        ch_header_lines
    )

    COMPRESSVCF(
        ANNOTATE.out.out
    )

    TABIXVCF(
        COMPRESSVCF.out.out
    )

    SPLITNORMALISEVCF(
        ch_reference,
        ANNOTATE.out.out
    )

    TRIM(
        SPLITNORMALISEVCF.out.out
    )

    FILTERPASS(
        TRIM.out.out
    )

    emit:
    variants = TABIXVCF.out.out
    out = FILTERPASS.out.out

}
