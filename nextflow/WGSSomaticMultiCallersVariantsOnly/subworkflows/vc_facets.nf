nextflow.enable.dsl=2

include { SNP_PILEUP } from '../modules/snp_pileup'
include { RUN_FACETS } from '../modules/run_facets'

workflow VC_FACETS {

    take:
    ch_normal_bam
    ch_normal_name
    ch_snps_dbsnp
    ch_tumor_bam
    ch_tumor_name
    ch_cval
    ch_everything
    ch_genome
    ch_max_depth
    ch_normal_depth
    ch_pseudo_snps
    ch_purity_cval

    main:
    SNP_PILEUP(
        ch_normal_bam,
        ch_tumor_bam,
        ch_snps_dbsnp,
        ch_max_depth,
        ch_tumor_name.first() + "--" + ch_normal_name.first(),
        ch_pseudo_snps
    )

    RUN_FACETS(
        SNP_PILEUP.out.out,
        ch_cval,
        ch_everything,
        ch_genome,
        ch_normal_depth,
        ch_tumor_name.first() + "--" + ch_normal_name.first(),
        ch_purity_cval
    )

    emit:
    out_summary = RUN_FACETS.out.out_summary
    out_purity_png = RUN_FACETS.out.out_purity_png
    out_purity_seg = RUN_FACETS.out.out_purity_seg
    out_purity_rds = RUN_FACETS.out.out_purity_rds
    out_hisens_png = RUN_FACETS.out.out_hisens_png
    out_hisens_seg = RUN_FACETS.out.out_hisens_seg
    out_hisens_rds = RUN_FACETS.out.out_hisens_rds
    out_arm_level = RUN_FACETS.out.out_arm_level
    out_gene_level = RUN_FACETS.out.out_gene_level
    out_qc = RUN_FACETS.out.out_qc

}
