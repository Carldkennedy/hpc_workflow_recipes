# HPC Workflow Recipes

This repositry contains a collection of workflow recipes

## ConcurDataStage

- Transfers data from shared storage to hpc
- Submits any number of sbatch jobs with no dependencies (concurrent)
- Once all jobs completed:
    - Transfers data from hpc to shared storage
