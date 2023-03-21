nextflow.enable.dsl=2

include { BASE_RECALIBRATOR } from '../modules/base_recalibrator'
include { APPLY_BQSR } from '../modules/apply_bqsr'

workflow BQSR_TUMOR {

    take:
    ch_bam
    ch_known_indels
    ch_mills_indels
    ch_reference
    ch_snps_1000gp
    ch_snps_dbsnp
    ch_intervals

    main:
    BASE_RECALIBRATOR(
        ch_bam,
        ch_snps_dbsnp.flatten().toList(),
        ch_reference,
        ch_intervals
    )

    APPLY_BQSR(
        ch_bam,
        ch_reference,
        ch_intervals,
        BASE_RECALIBRATOR.out.out
    )

    emit:
    out = APPLY_BQSR.out.out

}
