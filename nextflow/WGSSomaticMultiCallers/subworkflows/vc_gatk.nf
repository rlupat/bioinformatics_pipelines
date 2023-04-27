nextflow.enable.dsl=2

include { NORMAL_SPLIT_BAM } from './normal_split_bam'
include { TUMOR_SPLIT_BAM } from './tumor_split_bam'
include { MUTECT2 } from '../modules/mutect2'
include { LEARNORIENTATIONMODEL } from '../modules/learnorientationmodel'
include { GETPILEUPSUMMARIES } from '../modules/getpileupsummaries'
include { CALCULATECONTAMINATION } from '../modules/calculatecontamination'
include { FILTERMUTECT2CALLS } from '../modules/filtermutect2calls'
include { UNCOMPRESSVCF } from '../modules/uncompressvcf'
include { SPLITNORMALISEVCF } from '../modules/splitnormalisevcf'
include { FILTERPASS } from '../modules/filterpass'

workflow VC_GATK {

    take:
    ch_gnomad
    ch_normal_bam
    ch_reference
    ch_tumor_bam
    ch_intervals
    ch_normal_name
    ch_panel_of_normals

    main:
    NORMAL_SPLIT_BAM(
        ch_normal_bam,
        ch_intervals
    )

    TUMOR_SPLIT_BAM(
        ch_tumor_bam,
        ch_intervals
    )

    MUTECT2(
        ch_reference,
        TUMOR_SPLIT_BAM.out.out.flatten().toList(),
        ch_gnomad,
        NORMAL_SPLIT_BAM.out.out.flatten().toList(),
        ch_intervals,
        ch_normal_name,
        ch_normal_name
    )

    LEARNORIENTATIONMODEL(
        MUTECT2.out.f1f2r_out.toList()
    )

    GETPILEUPSUMMARIES(
        TUMOR_SPLIT_BAM.out.out.flatten().toList(),
        ch_gnomad,
        ch_intervals
    )

    CALCULATECONTAMINATION(
        GETPILEUPSUMMARIES.out.out
    )

    FILTERMUTECT2CALLS(
        ch_reference,
        MUTECT2.out.out,
        CALCULATECONTAMINATION.out.contOut,
        LEARNORIENTATIONMODEL.out.out,
        CALCULATECONTAMINATION.out.segOut,
        MUTECT2.out.stats
    )

    UNCOMPRESSVCF(
        FILTERMUTECT2CALLS.out.out.map{ tuple -> tuple[0] }
    )

    SPLITNORMALISEVCF(
        ch_reference,
        UNCOMPRESSVCF.out.out
    )

    FILTERPASS(
        SPLITNORMALISEVCF.out.out
    )

    emit:
    variants = FILTERMUTECT2CALLS.out.out
    out_bam = MUTECT2.out.bam
    out = FILTERPASS.out.out

}
