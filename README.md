## Nanopore pipeline for DPIRD - Snakemake edition

The pipeline requires [Snakemake](https://bitbucket.org/snakemake/snakemake/) to run.
Tests have been done with Nextflow version `5.5.2`.
The setup assumes running on Zeus at Pawsey Supercomputing Centre and uses containerised software.


### Pipeline

Basecalling\* -> Chopping -> De-novo assembling -> Blasting\+ -> Aligning\#

\* Optional
\+ Either with Blast or Diamond
\# Requires additional input in a subsequent run


### IMPORTANT NOTE

The pipeline is still in beta test.


### Requirements

Software:
* Guppy
* Pomoxis
* Blast or Diamond

Reference data:
* Database for Blast or Diamond


### Additional resources

The `extra` directory contains example Slurm scripts, `job1.sh`, `job2.sh` and `job1_diamond.sh` to run on Zeus.

