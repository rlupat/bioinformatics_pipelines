nextflow.enable.dsl=2

process SPLITNORMALISEVCF {
    debug true
    container "heuermh/vt@sha256:296aa90b60f6f5da5a80319494c4032f69d2ede77d0804291cb5d0d9d6fcfb72"
    publishDir "${params.outdir}/vc_vardict/splitnormalisevcf"
    cpus "${params.vc_vardict.splitnormalisevcf.cpus}"
    memory "${params.vc_vardict.splitnormalisevcf.memory}"

    input:
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path vcf

    output:
    path "${vcf.simpleName + ".norm.vcf"}", emit: out

    script:
    """
    vt decompose -s  \
    ${vcf} \
    | vt normalize -n -q -  \
    -r ${fasta} \
    -o ${vcf.simpleName}.norm.vcf \
    """

}
