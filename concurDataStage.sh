#!/bin/bash

########################## Retrieve and Send ###########################
from_storage="path/on/storage"
to_storage="path/on/hpc"
########################################################################

submissions=("script1.sh variabe" "script2.sh")

init_jid=$(sbatch shared_to_hpc.sh $from_storage | awk '{print $4}')

for sub in "${submissions[@]}"; do
  jid=$(sbatch --dependency=afterok:$init_jid "$sub" | awk '{print $4}')
  job_ids+=($jid)
done

# Construct the dependency string for the final job
dependency=""
for jid in "${job_ids[@]}"; do
  dependency+="$jid:"
done
dependency=${dependency%:}  # Remove the trailing colon

# Send data back once all jobs complete
sbatch --dependency=afterany:$dependency hpc_to_cluster.sh $to_storage
