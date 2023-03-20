nextflow.enable.dsl=2

process BWAMEM {
    debug true
    container "michaelfranklin/bwasamtools@sha256:4371795deb0cbe3d60b90bdbab4eb387b3f654c1e1c975f5d7748ef7bcd57532"
    publishDir "${params.outdir}/bwamem"
    cpus "${params.bwamem.cpus}"
    memory "${params.bwamem.memory}"

    input:
    tuple path(fasta), path(amb), path(ann), path(bwt), path(dict), path(fai), path(pac), path(sa)
    path reads

    output:
    path "${params.sample_name + ".bam"}", emit: out

    script:
    def mark_shorter_splits = params.bwamem_mark_shorter_splits == false ? "" : "-M"
    def reads = reads.join(' ')
    """
    bwa \
    mem \
    ${mark_shorter_splits} \
    -R "@RG\\tID:${params.sample_name}\\tSM:${params.sample_name}\\tLB:${params.sample_name}\\tPL:${"ILLUMINA"}" \
    -t 16 \
    ${fasta} \
    ${reads} \
    | \
    samtools \
    view \
    -o ${params.sample_name}.bam \
    --threads 16 \
    -T ${fasta} \
    -h \
    -b \
    """

}
