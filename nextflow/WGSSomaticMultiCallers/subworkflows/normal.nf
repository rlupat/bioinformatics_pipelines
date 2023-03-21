nextflow.enable.dsl=2

include { SAMTOOLS_MPILEUP } from '../modules/samtools_mpileup'

workflow NORMAL {

    take:
    ch_bam
    ch_reference
    ch_vcf

    main:
    SAMTOOLS_MPILEUP(
        ch_bam,
        ch_reference,
        ch_vcf
    )

    emit:
    out = SAMTOOLS_MPILEUP.out.out

}
