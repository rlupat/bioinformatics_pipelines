nextflow.enable.dsl=2

include { FASTQC } from './modules/fastqc'
include { GETFASTQC_ADAPTERS } from './modules/getfastqc_adapters'
include { ALIGN_AND_SORT } from './subworkflows/align_and_sort'
include { MERGE_AND_MARKDUPS } from './subworkflows/merge_and_markdups'

ch_adapter_file     = Channel.fromPath( params.adapter_file )
ch_contaminant_file = Channel.fromPath( params.contaminant_file )
ch_known_indels     = Channel.fromPath( params.known_indels ).toList()
ch_mills_indels     = Channel.fromPath( params.mills_indels ).toList()
ch_reference        = Channel.fromPath( params.reference ).toList()
ch_snps_1000gp      = Channel.fromPath( params.snps_1000gp ).toList()
ch_snps_dbsnp       = Channel.fromPath( params.snps_dbsnp ).toList()
ch_fastqs           = Channel.of( params.fastqs ).toList()


workflow  {

    FASTQC(
        ch_fastqs.flatten().collate( 2 )
    )

    GETFASTQC_ADAPTERS(
        params.getfastqc_adapters.code_file,
        ch_adapter_file,
        ch_contaminant_file,
        FASTQC.out.out_R1_datafile,
        FASTQC.out.out_R2_datafile
    )

    ALIGN_AND_SORT(
        ch_fastqs.flatten().collate( 2 ),
        ch_reference,
        params.sample_name,
        params.align_and_sort_sortsam_tmp_dir,
        GETFASTQC_ADAPTERS.out.out_R1_sequences.filter{ it != '' }.map{ it -> it.split(', ') }.ifEmpty( null ),
        GETFASTQC_ADAPTERS.out.out_R2_sequences.filter{ it != '' }.map{ it -> it.split(', ') }.ifEmpty( null )
    )

    MERGE_AND_MARKDUPS(
        ALIGN_AND_SORT.out.out.flatten().toList(),
        params.sample_name
    )


}
