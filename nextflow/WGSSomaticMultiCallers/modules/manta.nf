nextflow.enable.dsl=2

process MANTA {
    debug true
    container "michaelfranklin/manta:1.5.0"
    publishDir "${params.outdir}/vc_strelka/manta"
    cpus "${params.vc_strelka.manta.cpus}"
    memory "${params.vc_strelka.manta.memory}"

    input:
    tuple path(normal_bam), path(normal_bai)
    tuple path(fasta), path(fai)
    tuple path(bed_gz), path(tbi)
    tuple path(tumour_bam), path(tumour_bai)
    path config, stageAs: 'config'

    output:
    path "${"generated" + "/runWorkflow.py"}", emit: python
    path "${"generated" + "/runWorkflow.py.config.pickle"}", emit: pickle
    tuple path("${"generated" + "/results/variants/candidateSV.vcf.gz"}"), path("${"generated" + "/results/variants/candidateSV.vcf.gz.tbi"}"), emit: candidateSV
    tuple path("${"generated" + "/results/variants/candidateSmallIndels.vcf.gz"}"), path("${"generated" + "/results/variants/candidateSmallIndels.vcf.gz.tbi"}"), emit: candidateSmallIndels
    tuple path("${"generated" + "/results/variants/diploidSV.vcf.gz"}"), path("${"generated" + "/results/variants/diploidSV.vcf.gz.tbi"}"), emit: diploidSV
    path "${"generated" + "/results/stats/alignmentStatsSummary.txt"}", emit: alignmentStatsSummary
    path "${"generated" + "/results/stats/svCandidateGenerationStats.tsv"}", emit: svCandidateGenerationStats
    path "${"generated" + "/results/stats/svLocusGraphStats.tsv"}", emit: svLocusGraphStats
    tuple path("${"generated" + "/results/variants/somaticSV.vcf.gz"}"), path("${"generated" + "/results/variants/somaticSV.vcf.gz.tbi"}"), optional: true, emit: somaticSV
    tuple path("${"generated" + "/results/variants/tumorSV.vcf.gz"}"), path("${"generated" + "/results/variants/tumorSV.vcf.gz.tbi"}"), optional: true, emit: tumorSV

    script:
    def call_regions = bed_gz ? "--callRegions ${bed_gz}" : ""
    def config = config ? "--config ${config}" : ""
    def exome = params.vc_strelka.is_exome == false ? "" : "--exome"
    def tumor_bam = tumour_bam ? "--tumorBam ${tumour_bam}" : ""
    """
    configManta.py \
    --bam ${normal_bam} \
    ${call_regions} \
    ${config} \
    --referenceFasta ${fasta} \
    ${tumor_bam} \
    ${exome} \
    --runDir generated \
    ;${"generated"}/runWorkflow.py \
    --mode local \
    --memGb 4 \
    -j 4 \
    """

}
