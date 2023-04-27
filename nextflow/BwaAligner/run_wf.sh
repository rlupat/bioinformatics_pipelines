#!/bin/bash

export PATH=$PATH:/scratch/users/rlupat/nextflow_testing/bin
module load java/jdk-17.0.6
module load singularity/3.7.3
module load python/3.8.1
export NXF_SINGULARITY_CACHEDIR="/config/binaries/singularity/containers_devel/janis/"

nextflow run main.nf -profile test_pmac
