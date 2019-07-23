## Nanopore pipeline for DPIRD - Snakemake edition

The pipeline requires [Snakemake](https://bitbucket.org/snakemake/snakemake/) to run.
Tests have been done with Snakemake version `5.5.2`.
The setup assumes running on Zeus at Pawsey Supercomputing Centre and uses containerised software.


### Pipeline

Basecalling\* -> Chopping -> De-novo assembling -> Blasting\+ -> Aligning\#

\* Optional  
\+ Either with Blast or Diamond  
\# Requires additional input in a subsequent run


### Basic usage

Local copies of `Snakefile`, `config.yaml` and `cluster.json` are required. The following examples are for non-cluster runs; find cluster scripts for Zeus under the directory `extra/`.

```
snakemake -j 1 --use-singularity
```

The flag `-j` specifies the number of available compute cores, `1` in this example. The flag `--use-singularity` enables the use of containerised software through Singularity. The name of the directory containing the read files from a single experiment is specified in `config.yaml`, under `inputs: read_dirs:`. Multiple input directories can be specified at once as a dashed list. All output files will start with the corresponding input directory name as a `$prefix_`.

After blasting and identifying reference sequences of interest, alignment can be performed against them, by listing the sequence IDs in `config.yaml` under `inputs: seqids:`, and adding the target `run_align` in the command line:

```
snakemake -j 1 --use-singularity run_align
```


### Pipeline variants

The expected default input is one or multiple directory/ies containing raw read files from experiment(s). By default, Blast is used for blasting.

1. To feed instead a single (or multiple) already basecalled FASTQ file(s) as input, provide a list of experiment prefixes in `config.yaml`, under `inputs: read_dirs:`, and then ensure in your running directory you have the input files named as `$prefix_basecalled.fastq`.
2. To use Diamond for blasting, use the command line target `run_upstream_diamond`.


### Optional parameters

* Change *evalue* for blasting: in `config.yaml`, edit `params: evalue: '0.1'`.
* Change minimum length threshold for assembled contigs to be considered for blasting: in `config.yaml`, edit `params: min_len_contig: '1000'`.


### Requirements

Software:
* Guppy
* Pomoxis
* Blast or Diamond

Reference data:
* Database for Blast or Diamond


### Additional resources

The `extra` directory contains example Slurm scripts, `job1.sh`, `job2.sh` and `job1_diamond.sh` to run on Zeus.

