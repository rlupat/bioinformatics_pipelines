nextflow.enable.dsl=2

process LEARNORIENTATIONMODEL {
    debug true
    container "broadinstitute/gatk:4.1.8.1"
    publishDir "${params.outdir}/vc_gatk/learnorientationmodel"
    cpus "${params.vc_gatk.learnorientationmodel.cpus}"
    memory "${params.vc_gatk.learnorientationmodel.memory}"

    input:
    path f1r2_counts_files

    output:
    path "generated.tar.gz", emit: out

    script:
    def compression_level = null
    def f1r2_counts_files = f1r2_counts_files.collect{ "-I " + it }.join(' ')
    def java_options = null
    """
    gatk LearnReadOrientationModel \
    --java-options "-Xmx${32 * 3 / 4}G ${compression_level ? "-Dsamjdk.compress_level=" + compression_level : ""} ${[java_options, []].find{ it != null }.join(" ")}" \
    ${f1r2_counts_files} \
    --num-em-iterations 30 \
    -O generated.tar.gz \
    """

}
