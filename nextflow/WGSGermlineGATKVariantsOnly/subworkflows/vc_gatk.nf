nextflow.enable.dsl=2

include { SPLIT_BAM } from '../modules/split_bam'
include { HAPLOTYPE_CALLER } from '../modules/haplotype_caller'
include { UNCOMPRESSVCF } from '../modules/uncompressvcf'
include { SPLITNORMALISEVCF } from '../modules/splitnormalisevcf'

workflow VC_GATK {

    take:
    ch_bam
    ch_reference
    ch_snps_dbsnp
    ch_intervals

    main:
    SPLIT_BAM(
        ch_bam,
        ch_intervals
    )

    HAPLOTYPE_CALLER(
        SPLIT_BAM.out.out,
        ch_reference,
        ch_snps_dbsnp,
        ch_intervals
    )

    UNCOMPRESSVCF(
        HAPLOTYPE_CALLER.out.out.map{ tuple -> tuple[0] }
    )

    SPLITNORMALISEVCF(
        ch_reference,
        UNCOMPRESSVCF.out.out
    )

    emit:
    variants = HAPLOTYPE_CALLER.out.out
    out_bam = HAPLOTYPE_CALLER.out.bam
    out = SPLITNORMALISEVCF.out.out

}
