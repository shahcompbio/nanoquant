// create gene map for bus_count rule
process BUSPARSE_TR2G {
    tag "${meta.id}"
    label 'process_single'
    publishDir "${params.outdir}", mode: 'copy', overwrite: true

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "quay.io/biocontainers/bioconductor-busparse:1.16.0--r43hf17093f_0"

    input:
    tuple val(meta), path("transcripts.gtf")

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*/tr2g.tsv"), emit: gene_map
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
#!/usr/bin/env Rscript
library(BUSpaRse)
tr2g_tg <- tr2g_gtf('transcripts.gtf',
                    get_transcriptome = FALSE,
                    save_filtered_gtf = FALSE,
                    out_path = 'tr2g')

# Get package version and write to versions.yml
busparse_version <- as.character(packageVersion('BUSpaRse'))
cat(paste0('\\\"${task.process}\\\":\\n    busparse: ', busparse_version, '\\n'), file = 'versions.yml')
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busparse: \$(busparse --version)
    END_VERSIONS
    """
}
