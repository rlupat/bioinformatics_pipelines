nextflow.enable.dsl=2

include { MANTA } from '../modules/manta'
include { STRELKA } from '../modules/strelka'
include { CONCATVCF } from '../modules/concatvcf'
include { SORTVCF } from '../modules/sortvcf'
include { SPLITNORMALISEVCF } from '../modules/splitnormalisevcf'
include { EXTRACTADDP } from '../modules/extractaddp'
include { FILTERPASS } from '../modules/filterpass'

workflow VC_STRELKA {

    take:
    ch_normal_bam
    ch_reference
    ch_tumor_bam
    ch_intervals
    ch_manta_config

    main:
    MANTA(
        ch_normal_bam,
        ch_reference.map{ tuple -> [tuple[0], tuple[5]] },
        ch_intervals,
        ch_tumor_bam,
        ch_manta_config
    )

    STRELKA(
        ch_normal_bam,
        ch_reference.map{ tuple -> [tuple[0], tuple[5]] },
        ch_tumor_bam,
        ch_intervals,
        MANTA.out.candidateSmallIndels.flatten().toList()
    )

    CONCATVCF(
        STRELKA.out.snvs.flatten().toList(),
        STRELKA.out.snvs.flatten().toList()
    )

    SORTVCF(
        CONCATVCF.out.out
    )

    SPLITNORMALISEVCF(
        ch_reference,
        SORTVCF.out.out
    )

    EXTRACTADDP(
        SPLITNORMALISEVCF.out.out
    )

    FILTERPASS(
        EXTRACTADDP.out.out
    )

    emit:
    tumor_sv = MANTA.out.somaticSV
    normal_sv = MANTA.out.diploidSV
    variants = SORTVCF.out.out
    out = FILTERPASS.out.out

}
