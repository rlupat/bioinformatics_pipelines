nextflow.enable.dsl=2

include { TUMOR } from './tumor'
include { NORMAL } from './normal'
include { ADDBAMSTATS } from '../modules/addbamstats'

workflow ADDBAMSTATS {

    take:
    ch_normal_bam
    ch_normal_id
    ch_reference
    ch_tumor_bam
    ch_tumor_id
    ch_vcf

    main:
    TUMOR(
        ch_tumor_bam,
        ch_reference,
        ch_vcf
    )

    NORMAL(
        ch_normal_bam,
        ch_reference,
        ch_vcf
    )

    ADDBAMSTATS(
        ch_vcf,
        NORMAL.out.out,
        TUMOR.out.out,
        ch_normal_id,
        ch_tumor_id
    )

    emit:
    out = ADDBAMSTATS.out.out

}
