// merge quantifification from kallisto across multiple samples
// based off of this subworkflow: https://github.com/nf-core/modules/blob/master/subworkflows/nf-core/quantify_pseudo_alignment/main.nf

include { CUSTOM_TX2GENE                                                     } from '../../../modules/nf-core/custom/tx2gene/main'
include { TXIMETA_TXIMPORT                                                   } from '../../../modules/nf-core/tximeta/tximport/main'
include { SUMMARIZEDEXPERIMENT_SUMMARIZEDEXPERIMENT as SE_GENE_UNIFIED       } from '../../../modules/nf-core/summarizedexperiment/summarizedexperiment/main'
include { SUMMARIZEDEXPERIMENT_SUMMARIZEDEXPERIMENT as SE_TRANSCRIPT_UNIFIED } from '../../../modules/nf-core/summarizedexperiment/summarizedexperiment'

workflow MERGE_QUANT {
    take:
    ch_pseudo_results   // channel: [ val(meta), [ kallisto results ] ]
    gtf                 // channel: [gtf]
    gtf_id_attribute    //     val: GTF gene ID attribute
    gtf_extra_attribute //     val: GTF alternative gene attribute (e.g. gene_name)
    samplesheet         // channel: [ val(meta), /path/to/samplesheet ]

    main:

    ch_versions = Channel.empty()
    // Make a transcript/gene mapping from a GTF and cross-reference with transcript quantifications
    CUSTOM_TX2GENE(
        tuple([:], gtf),
        ch_pseudo_results.collect { it[1] }.map { [[:], it] },
        "kallisto",
        gtf_id_attribute,
        gtf_extra_attribute,
    )
    ch_versions = ch_versions.mix(CUSTOM_TX2GENE.out.versions)
    // Import transcript-level abundances and estimated counts for gene-level analysis packages
    TXIMETA_TXIMPORT(
        ch_pseudo_results.collect { it[1] }.map { [['id': 'all_samples'], it] },
        CUSTOM_TX2GENE.out.tx2gene,
        "kallisto",
    )
    ch_versions = ch_versions.mix(TXIMETA_TXIMPORT.out.versions)

    ch_gene_unified = TXIMETA_TXIMPORT.out.counts_gene
        .join(TXIMETA_TXIMPORT.out.counts_gene_length_scaled)
        .join(TXIMETA_TXIMPORT.out.counts_gene_scaled)
        .join(TXIMETA_TXIMPORT.out.lengths_gene)
        .join(TXIMETA_TXIMPORT.out.tpm_gene)
        .map { tuple(it[0], it.tail()) }

    ch_gene_unified.view()

    SE_GENE_UNIFIED(
        ch_gene_unified,
        CUSTOM_TX2GENE.out.tx2gene,
        samplesheet,
    )
    ch_versions = ch_versions.mix(SE_GENE_UNIFIED.out.versions)
    ch_transcript_unified = TXIMETA_TXIMPORT.out.counts_transcript
        .join(TXIMETA_TXIMPORT.out.lengths_transcript)
        .join(TXIMETA_TXIMPORT.out.tpm_transcript)
        .map { tuple(it[0], it.tail()) }

    SE_TRANSCRIPT_UNIFIED(
        ch_transcript_unified,
        CUSTOM_TX2GENE.out.tx2gene,
        samplesheet,
    )
    ch_versions = ch_versions.mix(SE_TRANSCRIPT_UNIFIED.out.versions)

    emit:
    versions = ch_versions // channel: [ versions.yml ]
}
