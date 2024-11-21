#!/bin/bash

# Shared area
SHARED="/shared/path"       # Update with your shared directory path
PROJECT_DIR="project/path"  # Update with your project directory relative to shared area
RESULTS_SUBDIR="results"    # Subdirectory for results relative to PROJECT_DIR

# Worker node
WORKING_DIR="/tmp/path"     # Update with your working directory
WORKING_RESULTS="results"   # Subdirectory for results relative to WORKING_DIR  

# Submit transfer job
transfer_in_job=$(sbatch --parsable transfer-files ${SHARED}/${PROJECT_DIR} ${WORKING_DIR} | cut -d ";" -f 1)
echo "Submitted transfer-in job: $transfer_in_job"

# Submit the main computation job (after transfer-in)
main_job=$(sbatch --parsable --dependency=afterok:${transfer_in_job} compute-job.sh | cut -d ";" -f 1)
echo "Submitted main computation job: $main_job"

# Submit transfer results job (after computation)
transfer_out_job=$(sbatch --parsable --dependency=afterok:${main_job} transfer-files ${WORKING_DIR}/${WORKING_RESULTS} ${SHARED}/${PROJECT_DIR}/${RESULTS_SUBDIR}/ | cut -d ";" -f 1)
echo "Submitted transfer-out job: $transfer_out_job"
