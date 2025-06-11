// generate bus file
process KALLISTO_BUS {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "kallisto/${meta.id}", mode: 'copy', overwrite: true

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/kallisto:0.51.1--ha4fb952_1'
        : 'biocontainers/kallisto:0.51.1--ha4fb952_1'}"

    input:
    tuple val(meta), path(fastq)
    tuple val(meta2), path(idx)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.bus"), emit: bus
    tuple val(meta), path("transcripts.txt"), emit: transcripts
    tuple val(meta), path("matrix.ec"), emit: ec_matrix
    tuple val(meta), path("flens.txt"), emit: flens
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    kallisto bus --long --threshold 0.8 -x 'bulk' -i ${idx} -o ./ \
    ${fastq} -t ${task.cpus}
    KALLISTO_VERSION=\$(kallisto version 2>&1 | head -n1 | sed 's/.*version //' | sed 's/ .*//')
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kallisto: "\${KALLISTO_VERSION}"
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
        kallisto: \$(kallisto --version)
    END_VERSIONS
    """
}
