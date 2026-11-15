# shahcompbio/nanoquant: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.1 - 2026-06-10

### `Added`

- Support for BAM/CRAM input files via `samtools fastq` conversion ([#cram](https://github.com/shahcompbio/nanoquant/tree/cram))
- New `bam` column in samplesheet schema accepting `.bam` and `.cram` files
- Mixed input support: combine FASTQ, FASTQ directory, and BAM/CRAM inputs in a single samplesheet
- nf-core `samtools/fastq` module for BAM/CRAM to FASTQ conversion
- Updated usage documentation with rationale for BAM/CRAM to FASTQ workflow
- nf-test for BAM input workflow

### `Fixed`

### `Dependencies`

- `samtools` 1.23.1 (via nf-core module)

### `Deprecated`

## v1.0.0dev - [date]

Initial release of shahcompbio/nanoquant, created with the [nf-core](https://nf-co.re/) template.

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`
