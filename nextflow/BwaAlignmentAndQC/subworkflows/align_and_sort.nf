nextflow.enable.dsl=2

include { CUTADAPT } from '../modules/cutadapt'
include { BWAMEM } from '../modules/bwamem'
include { SORTSAM } from '../modules/sortsam'

workflow ALIGN_AND_SORT {

    take:
    ch_fastq
    ch_reference
    ch_sample_name
    ch_sortsam_tmp_dir
    ch_three_prime_adapter_read1
    ch_three_prime_adapter_read2

    main:
    CUTADAPT(
        ch_fastq,
        ch_sample_name,
        ch_three_prime_adapter_read1,
        ch_three_prime_adapter_read2
    )

    BWAMEM(
        ch_reference,
        CUTADAPT.out.out,
        ch_sample_name
    )

    SORTSAM(
        BWAMEM.out.out,
        ch_sortsam_tmp_dir
    )

    emit:
    out = SORTSAM.out.out

}
