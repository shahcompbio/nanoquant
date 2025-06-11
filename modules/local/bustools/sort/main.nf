//sort kallisto bus file
process BUSTOOLS_SORT {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "kallisto/${meta.id}", mode: 'copy', overwrite: true

    conda "${moduleDir}/environment.yml"
    container "quay.io/biocontainers/bustools:0.43.2--he1fd2f9_1"

    input:
    tuple val(meta), path("input.bus")

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("sorted.bus"), emit: bus
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bustools \\
        sort \\
        -t ${task.cpus} \\
        input.bus \\
        -o sorted.bus
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bustools: \$(echo \$(bustools 2>&1) | sed 's/^bustools //; s/Usage.*\$//')
    END_VERSIONS
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
        bustools: \$(bustools --version)
    END_VERSIONS
    """
}
