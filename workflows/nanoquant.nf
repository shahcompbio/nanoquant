/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { GFFREAD                } from '../modules/nf-core/gffread/main'
include { KALLISTO_INDEX         } from '../modules/nf-core/kallisto/index/main'
include { BUSPARSE_TR2G          } from '../modules/local/busparse/tr2g/main'
include { CAT_LRFASTQ            } from '../modules/local/cat/lrfastq/main'
include { KALLISTO_QUANT         } from '../subworkflows/local/kallisto_quant/main'
include { CUSTOM_TX2GENE         } from '../modules/nf-core/custom/tx2gene/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { MERGE_QUANT            } from '../subworkflows/local/merge_quant'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_nanoquant_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NANOQUANT {
    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    //
    // MODULE: Run FastQC
    //
    // ch_samplesheet.view()
    // extract cdna 
    GFFREAD(tuple([id: "cdna"], params.gtf), params.fasta)
    ch_versions = ch_versions.mix(GFFREAD.out.versions)
    // index
    KALLISTO_INDEX(GFFREAD.out.gffread_fasta)
    ch_versions = ch_versions.mix(KALLISTO_INDEX.out.versions)
    // map transcripts to gene
    BUSPARSE_TR2G(tuple([id: "tr2g"], params.gtf))
    ch_versions = ch_versions.mix(BUSPARSE_TR2G.out.versions)
    ch_samplesheet
        .branch { meta, fastqs ->
            merged: meta.single_end == true
            unmerged: meta.single_end != true
        }
        .set { ch_fastq }
    // ch_fastq.merged.view { meta, _fastq -> "${meta.id} is merged" }
    // ch_fastq.unmerged.view { meta, _fastq -> "${meta.id} is unmerged" }
    // merge unmerged fastqs
    CAT_LRFASTQ(ch_fastq.unmerged)
    ch_versions = ch_versions.mix(CAT_LRFASTQ.out.versions)
    ch_merged_fastq = ch_fastq.merged.mix(CAT_LRFASTQ.out.fastq)
    // ch_merged_fastq.view()
    KALLISTO_QUANT(
        ch_merged_fastq,
        KALLISTO_INDEX.out.index,
        BUSPARSE_TR2G.out.gene_map,
    )
    ch_versions = ch_versions.mix(KALLISTO_QUANT.out.versions)
    // merge results across samples if necessary
    if (params.merge_samples) {
        ch_pseudo_results = KALLISTO_QUANT.out.pseudo_results
        MERGE_QUANT(
            ch_pseudo_results,
            params.gtf,
            params.gtf_id_attribute,
            params.gtf_extra_attribute,
            [[:], params.input],
        )
        ch_versions = ch_versions.mix(MERGE_QUANT.out.versions)
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nanoquant_software_' + 'mqc_' + 'versions.yml',
            sort: true,
            newLine: true,
        )
        .set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config = Channel.fromPath(
        "${projectDir}/assets/multiqc_config.yml",
        checkIfExists: true
    )
    ch_multiqc_custom_config = params.multiqc_config
        ? Channel.fromPath(params.multiqc_config, checkIfExists: true)
        : Channel.empty()
    ch_multiqc_logo = params.multiqc_logo
        ? Channel.fromPath(params.multiqc_logo, checkIfExists: true)
        : Channel.empty()

    summary_params = paramsSummaryMap(
        workflow,
        parameters_schema: "nextflow_schema.json"
    )
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml')
    )
    ch_multiqc_custom_methods_description = params.multiqc_methods_description
        ? file(params.multiqc_methods_description, checkIfExists: true)
        : file("${projectDir}/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description)
    )

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true,
        )
    )

    MULTIQC(
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        [],
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions // channel: [ path(versions.yml) ]
}
