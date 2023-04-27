nextflow.enable.dsl=2

include { CUTADAPT } from './modules/cutadapt'
include { BWAMEM } from './modules/bwamem'
include { SORTSAM } from './modules/sortsam'

ch_reference = Channel.fromPath( params.reference ).toList()
ch_fastq     = Channel.fromPath( params.fastq ).toList()


workflow  {

    CUTADAPT(
        ch_fastq
    )

    BWAMEM(
        ch_reference,
        CUTADAPT.out.out
    )

    SORTSAM(
        BWAMEM.out.out
    )


}
