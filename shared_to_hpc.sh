#!/bin/bash

storage_user=$1
from_storage=$2
to_cluster=$3
flag_file="flag_file"

# Perform the rsync operation
rsync -avz --progress "${storage_user}@shared_storage:${from_storage}" "${to_cluster}"

# Check if rsync was successful
if [[ "$?" -eq 0 ]]; then
    echo "Data successfully copied from shared storage to HPC."
    echo "SUCCESS" > "${flag_file}"
else
    echo "Error: Failed to copy data from shared storage to HPC."
    echo "FAILURE" > "${flag_file}"
    exit 1
fi
