nextflow.enable.dsl=2

include { FASTQC } from '../modules/fastqc'
include { GETFASTQC_ADAPTERS } from '../modules/getfastqc_adapters'
include { ALIGN_AND_SORT } from './align_and_sort'
include { MERGE_AND_MARKDUPS } from './merge_and_markdups'

workflow ALIGNMENT_TUMOR {

    take:
    ch_adapter_file
    ch_contaminant_file
    ch_fastqs
    ch_known_indels
    ch_mills_indels
    ch_reference
    ch_sample_name
    ch_snps_1000gp
    ch_snps_dbsnp

    main:
    FASTQC(
        ch_fastqs.flatten().collate( 2 )
    )

    GETFASTQC_ADAPTERS(
        params.alignment_tumor.getfastqc_adapters.code_file,
        ch_adapter_file,
        ch_contaminant_file,
        FASTQC.out.out_R1_datafile,
        FASTQC.out.out_R2_datafile
    )

    ALIGN_AND_SORT(
        ch_fastqs.flatten().collate( 2 ),
        ch_reference,
        ch_sample_name,
        params.alignment_tumor.align_and_sort_sortsam_tmp_dir,
        GETFASTQC_ADAPTERS.out.out_R1_sequences.filter{ it != '' }.map{ it -> it.split(', ') }.ifEmpty( null ),
        GETFASTQC_ADAPTERS.out.out_R2_sequences.filter{ it != '' }.map{ it -> it.split(', ') }.ifEmpty( null )
    )

    MERGE_AND_MARKDUPS(
        ALIGN_AND_SORT.out.out.flatten().toList(),
        ch_sample_name
    )

    emit:
    out_fastqc_R1_reports = FASTQC.out.out_R1
    out_fastqc_R2_reports = FASTQC.out.out_R2
    out_bam = MERGE_AND_MARKDUPS.out.out

}
