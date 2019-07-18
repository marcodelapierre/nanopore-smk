#!/bin/bash -l

#SBATCH --job-name=Snakemake-master-nanopore
#SBATCH --account=pawsey0001
#SBATCH --partition=workq
#SBATCH --time=1-00:00:00
#SBATCH --no-requeue
#SBATCH --export=none

module load snakemake

snakemake \
  --shadow-prefix $MYSCRATCH/smk_work \
  -j 96 --cluster-config cluster.json \
  --cluster "sbatch -A {cluster.account} -p {cluster.partition} -n {cluster.n} --mem={cluster.mem} -t {cluster.time}" \
  --use-singularity --singularity-prefix $MYGROUP/.smk_singularity \
  run_upstream_diamond
