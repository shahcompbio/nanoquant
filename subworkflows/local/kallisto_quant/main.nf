// run workflow to perform pseudo-alignment with kallisto for quantification
include { GFFREAD } from '../../../modules/nf-core/gffread/main'

workflow KALLISTO_QUANT {
    take:
    ch_fastq   // channel: [ val(meta), [ fastq ] ]
    gtf        // channel: [ gtf]
    ref_genome // channel: [ fasta ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow
    GFFREAD(tuple([id: "transcriptome"], gtf), ref_genome)
    ch_versions = ch_versions.mix(GFFREAD.out.versions)

    emit:
    tx_fasta = GFFREAD.out.gffread_fasta // channel: [ val(meta), transcript_fasta ]
    versions = ch_versions // channel: [ versions.yml ]
}
