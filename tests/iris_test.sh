#!/bin/bash
#SBATCH --partition=componc_cpu
#SBATCH --account=shahs3
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --mem=8GB
#SBATCH --job-name=nanoquant
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=preskaa@mskcc.org
#SBATCH --output=slurm%j_nanoquant.out

## activate nf-core conda environment
source /home/preskaa/miniforge3/bin/activate nf-core
module load java/20.0.1
## specify params
outdir=/data1/shahs3/users/preskaa/SarcAtlas/data/APS033_ont_transcript_assembly/nanoquant_test
results_dir=${outdir}/results
pipelinedir=$HOME/nanoquant
samplesheet=${pipelinedir}/iris_samplesheet.csv
fasta=/data1/shahs3/isabl_data_lake/assemblies/GRCh38-P14/GRCh38.primary_assembly.genome.fa
gtf=/data1/shahs3/isabl_data_lake/assemblies/GRCh38-P14/gencode.v45.primary_assembly.annotation.gtf

mkdir -p ${results_dir}
cd ${outdir}

nextflow run shahcompbio/nanoquant -r latest \
    -profile singularity \
    -work-dir ${outdir}/work \
    --outdir ${outdir} \
    --input ${samplesheet} \
    --gtf ${gtf} \
    --fasta ${ref_genome} \
   -resume