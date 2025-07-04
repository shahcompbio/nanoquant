// run kallisto on transcript-compatible count matrices
process KALLISTO_TCCQUANT {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "kallisto", mode: 'copy', overwrite: true

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/kallisto:0.51.1--ha4fb952_1'
        : 'biocontainers/kallisto:0.51.1--ha4fb952_1'}"

    input:
    tuple val(meta), path("output.mtx"), path("output.ec.txt"), path("flens.txt")
    tuple val(meta1), path("transcripts.idx")
    // kallisto index
    tuple val(meta2), path("tr2g.tsv")

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("${meta.id}/abundance.h5"), emit: h5
    tuple val(meta), path("${meta.id}/abundance.tsv"), emit: transcript_abundance
    tuple val(meta), path("${meta.id}/abundance.gene.tsv"), emit: gene_abundance
    tuple val(meta), path("${meta.id}"), emit: results
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    kallisto quant-tcc\\
        -t ${task.cpus} \\
        --long -P ONT \\
        output.mtx \\
        -i transcripts.idx \\
        -f flens.txt \\
        -e output.ec.txt \\
        -g tr2g.tsv \\
        -o ${meta.id} \\
        -b 100 --matrix-to-files
    # Rename files to desired names
    cd ${meta.id}
    mv abundance_1.h5 abundance.h5
    mv abundance_1.tsv abundance.tsv
    mv abundance.gene_1.tsv abundance.gene.tsv
    cd ..
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kallisto: \$(echo \$(kallisto 2>&1) | sed 's/^kallisto //; s/Usage.*\$//')
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
