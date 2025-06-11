#!/bin/bash
## activate nf-core conda environment
source $HOME/miniforge3/bin/activate env_nf
## specify params
outdir=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/SarcAtlas/APS033_nanoquant_test/results
pipelinedir=$HOME/VSCodeProjects/nanoquant
samplesheet=${pipelinedir}/assets/samplesheet.csv
ref_genome=/Users/asherpreskasteinberg/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/code/ref_genomes/hg38p14/GRCh38.primary_assembly.genome.fa
gtf=/Users/asherpreskasteinberg/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/SarcAtlas/APS033_nanoquant_test/ONT-transcript-assembly_43453_test.gtf
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