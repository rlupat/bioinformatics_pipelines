nextflow.enable.dsl=2

include { SAMTOOLSMPILEUP } from '../modules/samtoolsmpileup'
include { ADDBAMSTATS } from '../modules/addbamstats'

workflow COMBINED_ADDBAMSTATS {

    take:
    ch_bam
    ch_reference
    ch_vcf

    main:
    SAMTOOLSMPILEUP(
        ch_bam,
        ch_reference,
        ch_vcf
    )

    ADDBAMSTATS(
        ch_vcf,
        SAMTOOLSMPILEUP.out.out
    )

    emit:
    out = ADDBAMSTATS.out.out

}
