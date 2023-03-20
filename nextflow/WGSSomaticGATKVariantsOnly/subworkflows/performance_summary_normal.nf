nextflow.enable.dsl=2

include { GATK4COLLECTINSERTSIZEMETRICS } from '../modules/gatk4collectinsertsizemetrics'
include { BAMFLAGSTAT } from '../modules/bamflagstat'
include { SAMTOOLSVIEW } from '../modules/samtoolsview'
include { RMDUPBAMFLAGSTAT } from '../modules/rmdupbamflagstat'
include { BEDTOOLSGENOMECOVERAGEBED } from '../modules/bedtoolsgenomecoveragebed'
include { PERFORMANCESUMMARY } from '../modules/performancesummary'

workflow PERFORMANCE_SUMMARY_NORMAL {

    take:
    ch_bam
    ch_genome_file
    ch_sample_name

    main:
    GATK4COLLECTINSERTSIZEMETRICS(
        ch_bam
    )

    BAMFLAGSTAT(
        ch_bam.map{ tuple -> tuple[0] }
    )

    SAMTOOLSVIEW(
        ch_bam.map{ tuple -> tuple[0] }
    )

    RMDUPBAMFLAGSTAT(
        SAMTOOLSVIEW.out.out
    )

    BEDTOOLSGENOMECOVERAGEBED(
        ch_genome_file,
        SAMTOOLSVIEW.out.out
    )

    PERFORMANCESUMMARY(
        GATK4COLLECTINSERTSIZEMETRICS.out.out,
        BEDTOOLSGENOMECOVERAGEBED.out.out,
        BAMFLAGSTAT.out.out,
        RMDUPBAMFLAGSTAT.out.out,
        ch_sample_name
    )

    emit:
    performanceSummaryOut = PERFORMANCESUMMARY.out.out

}
