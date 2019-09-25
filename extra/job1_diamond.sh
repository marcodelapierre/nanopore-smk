#!/bin/bash -l

#SBATCH --job-name=Snakemake-master-nanopore
#SBATCH --account=pawsey0001
#SBATCH --partition=longq
#SBATCH --time=4-00:00:00
#SBATCH --no-requeue
#SBATCH --export=none

module load singularity/3.3.0
module load snakemake

snakemake \
  --profile profiles/zeus \
  run_upstream_diamond
