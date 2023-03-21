nextflow.enable.dsl=2

include { SPLIT_BAM } from '../modules/split_bam'

workflow NORMAL_SPLIT_BAM {

    take:
    ch_bam
    ch_intervals

    main:
    SPLIT_BAM(
        ch_bam,
        ch_intervals
    )

    emit:
    out = SPLIT_BAM.out.out

}
