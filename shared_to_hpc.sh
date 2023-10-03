#!/bin/bash

user=$1
remote_path=$2
local_path=$3

# Perform the rsync and check if it was successful
rsync -avz --progress "${user}@shared_storage:${remote_path}" "${local_path}"
if [[ "$?" -ne 0 ]]; then
    echo "Error: Failed to copy data from shared storage."
    exit 1
else
    echo "Data successfully copied from shared storage."
fi
