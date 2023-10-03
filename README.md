# HPC Workflow Recipes

This repositry contains a collection of workflow recipes

## ConcurDataStage

- Transfers data from shared storage to hpc
- Submits any number of sbatch jobs with no dependencies (i.e concurrent)
- Once all jobs completed:
    - Transfers data from hpc to shared storage

## Suggested recipes to add

### SeqDataStage

- Transfers data from shared storage to hpc
- Submits any number of sbatch jobs with each dependant on the previous job (i.e sequential)
- Once all jobs completed:
    - Transfers data from hpc to shared storage
