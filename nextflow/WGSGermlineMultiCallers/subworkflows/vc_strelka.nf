nextflow.enable.dsl=2

include { MANTA } from '../modules/manta'
include { STRELKA } from '../modules/strelka'
include { SPLITNORMALISEVCF } from '../modules/splitnormalisevcf'
include { FILTERPASS } from '../modules/filterpass'

workflow VC_STRELKA {

    take:
    ch_bam
    ch_reference
    ch_intervals
    ch_manta_config

    main:
    MANTA(
        ch_bam,
        ch_reference.map{ tuple -> [tuple[0], tuple[5]] },
        ch_intervals,
        ch_manta_config
    )

    STRELKA(
        ch_bam,
        ch_reference,
        ch_intervals
    )

    SPLITNORMALISEVCF(
        ch_reference,
        STRELKA.out.variants.map{ tuple -> tuple[0] }
    )

    FILTERPASS(
        SPLITNORMALISEVCF.out.out
    )

    emit:
    sv = MANTA.out.diploidSV
    variants = STRELKA.out.variants
    out = FILTERPASS.out.out

}
