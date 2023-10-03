#!/bin/bash

########################## Retrieve and Send ###########################
storage_user="some_user"
from_storage="/path/on/storage"
to_cluster="/path/on/cluster"
from_cluster="/path/on/cluster"
to_storage="/path/on/hpc"

########################################################################

submissions=("script1.sh variabe" "script2.sh")

init_jid=$(sbatch shared_to_hpc.sh $storage_user $from_storage $to_cluster | awk '{print $4}')

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
sbatch --dependency=afterany:$dependency hpc_to_shared.sh $from_cluster $to_storage

