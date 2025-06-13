// run workflow to perform pseudo-alignment with kallisto for quantification
include { KALLISTO_BUS      } from '../../../modules/local/kallisto/bus/main'
include { BUSTOOLS_SORT     } from '../../../modules/local/bustools/sort/main'
include { BUSTOOLS_COUNT    } from '../../../modules/local/bustools/count/main'
include { KALLISTO_TCCQUANT } from '../../../modules/local/kallisto/tccquant/main'
workflow KALLISTO_QUANT {
    take:
    ch_fastq // channel: [ val(meta), [ fastq ] ]
    idx      // channel: [ val(meta), gtf]
    tr2g     // channel: [ val(meta), tr2g]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow
    KALLISTO_BUS(ch_fastq, idx)
    ch_versions = ch_versions.mix(KALLISTO_BUS.out.versions)
    BUSTOOLS_SORT(KALLISTO_BUS.out.bus)
    ch_versions = ch_versions.mix(BUSTOOLS_SORT.out.versions)
    input_count_ch = BUSTOOLS_SORT.out.bus
        .join(KALLISTO_BUS.out.transcripts)
        .join(KALLISTO_BUS.out.ec_matrix)
    BUSTOOLS_COUNT(input_count_ch, tr2g)
    ch_versions = ch_versions.mix(BUSTOOLS_COUNT.out.versions)
    input_quant_ch = BUSTOOLS_COUNT.out.count_mtx
        .join(BUSTOOLS_COUNT.out.count_ec)
        .join(KALLISTO_BUS.out.flens)
    KALLISTO_TCCQUANT(input_quant_ch, idx, tr2g)
    ch_versions = ch_versions.mix(KALLISTO_TCCQUANT.out.versions)

    emit:
    versions       = ch_versions // channel: [ versions.yml ]
    pseudo_results = KALLISTO_TCCQUANT.out.results // channel [val(meta), dir(results) ] 
}
