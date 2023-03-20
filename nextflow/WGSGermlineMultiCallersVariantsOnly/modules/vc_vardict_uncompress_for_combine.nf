nextflow.enable.dsl=2

process VC_VARDICT_UNCOMPRESS_FOR_COMBINE {
    debug true
    container "ubuntu@sha256:1d7b639619bdca2d008eca2d5293e3c43ff84cbee597ff76de3b7a7de3e84956"
    publishDir "${params.outdir}/vc_vardict_uncompress_for_combine"

    input:
    path file, stageAs: 'file.gz'

    output:
    path file.simpleName, emit: out

    script:
    def force = params.vc_vardict_uncompress_for_combine_force == false ? "" : "-f"
    """
    gunzip \
    ${force} \
    -d \
    ${file} \
    """

}
