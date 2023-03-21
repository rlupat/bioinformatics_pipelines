nextflow.enable.dsl=2

process UNCOMPRESSVCF {
    debug true
    container "ubuntu@sha256:1d7b639619bdca2d008eca2d5293e3c43ff84cbee597ff76de3b7a7de3e84956"
    publishDir "${params.outdir}/vc_gatk/uncompressvcf"

    input:
    path file, stageAs: 'file.gz'

    output:
    path file.simpleName, emit: out

    script:
    def force = params.vc_gatk.uncompressvcf_force == false ? "" : "-f"
    """
    gunzip \
    ${force} \
    -d \
    ${file} \
    """

}
