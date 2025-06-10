#!/bin/bash
## activate nf-core conda environment
source $HOME/miniforge_x86_64/bin/activate nf-core
## specify params
outdir=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/SarcAtlas/APS033_nanoquant_test/results
pipelinedir=$HOME/VSCodeProjects/shahcompbio-nanoquant
samplesheet=${pipelinedir}/assets/msk_samplesheet.csv
ref_genome=/Users/preskaa/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/code/ref_genomes/hg38p14/GRCh38.primary_assembly.genome.fa
gtf=/Users/preskaa/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/SarcAtlas/APS033_nanoquant_test/ONT-transcript-assembly_43453_test.gtf
mkdir -p ${outdir}
cd ${outdir}

nextflow run ${pipelinedir}/main.nf \
    -profile arm,docker,test \
    -work-dir ${outdir}/work \
    --outdir ${outdir} \
    --input ${samplesheet} \
    --gtf ${gtf} \
    --fasta ${ref_genome} \
    -resume