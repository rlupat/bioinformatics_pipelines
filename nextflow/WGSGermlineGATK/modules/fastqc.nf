nextflow.enable.dsl=2

process FASTQC {
    debug true
    container "quay.io/biocontainers/fastqc@sha256:810db4a1676d79883cc5f29ce31b4db0b6ebed36007fae5fdd1e78a5304639d8"
    publishDir "${params.outdir}/fastqc"
    cpus "${params.fastqc.cpus}"
    memory "${params.fastqc.memory}"

    input:
    path reads

    output:
    path "${reads[0].simpleName + "_fastqc.zip"}", emit: out_R1
    path "${reads[0].simpleName + "_fastqc/fastqc_data.txt"}", emit: out_R1_datafile
    path "${reads[0].simpleName + "_fastqc.html"}", emit: out_R1_html
    path "${reads[0].simpleName + "_fastqc"}", emit: out_R1_directory
    path "${reads[1].simpleName + "_fastqc.zip"}", emit: out_R2
    path "${reads[1].simpleName + "_fastqc/fastqc_data.txt"}", emit: out_R2_datafile
    path "${reads[1].simpleName + "_fastqc.html"}", emit: out_R2_html
    path "${reads[1].simpleName + "_fastqc"}", emit: out_R2_directory

    script:
    """
    fastqc \
    --outdir . \
    --threads 1 \
    --extract \
    ${reads[0]} \
    ${reads[1]} \
    """

}
