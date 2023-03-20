nextflow.enable.dsl=2

process PERFORMANCESUMMARY {
    debug true
    container "michaelfranklin/pmacutil@sha256:806f1bdcce8aa35baed9a64066878f77315fbd74b98c2bfc64cb5193dcf639c6"
    publishDir "${params.outdir}/performance_summary/performancesummary"

    input:
    path collect_insert_size_metrics, stageAs: 'collect_insert_size_metrics'
    path coverage, stageAs: 'coverage'
    path flagstat, stageAs: 'flagstat'
    path rmdup_flagstat, stageAs: 'rmdup_flagstat'
    val output_prefix

    output:
    path "${output_prefix + ".csv"}", emit: out

    script:
    def genome = params.performance_summary.performancesummary_genome == false ? "" : "--genome"
    def rmdup_flagstat = rmdup_flagstat ? "--rmdup_flagstat ${rmdup_flagstat}" : ""
    """
    performance_summary.py \
    --collect_insert_metrics ${collect_insert_size_metrics} \
    --coverage ${coverage} \
    --flagstat ${flagstat} \
    ${rmdup_flagstat} \
    -o ${output_prefix} \
    ${genome} \
    """

}
