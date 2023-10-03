#!/bin/bash

########################## Edit as required #############################
storage_user="some_user"
from_storage="/path/on/storage"
to_cluster="/path/on/cluster"
from_cluster="/path/on/cluster"
to_storage="/path/on/storage"
flag_file="/path/to/flag_file"
submissions=("script1.sh" "script2.sh variable")
########################################################################

# Submit the initial job and get the Job ID - edit resource request if required
init_jid=$(sbatch --time=01:00:00 --mem=5G shared_to_hpc.sh $storage_user $from_storage $to_cluster | awk '{print $4}')

# Wait for the flag file to be written by shared_to_hpc.sh
while [[ ! -e $flag_file ]]; do
  sleep 60  # wait for 60 seconds before checking again
done

# Check whether the transfer was successful
if grep -q "SUCCESS" $flag_file; then
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

  # Send data back once all jobs complete - edit resource request if required
  sbatch --dependency=afterany:$dependency --time=01:00:00 --mem=5G hpc_to_shared.sh $from_cluster $to_storage
else
  echo "Data transfer failed. Not submitting dependent jobs."
  exit 1
fi
