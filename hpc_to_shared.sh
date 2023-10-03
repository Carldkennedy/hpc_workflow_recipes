#!/bin/bash

user=$1
local_path=$2
remote_path=$3

# Perform the rsync and check if it was successful
rsync -avz --progress "${local_path}" "${user}@shared_storage:${remote_path}"
if [[ "$?" -ne 0 ]]; then
    echo "Error: Failed to copy data to shared storage."
    exit 1
else
    echo "Data successfully copied to shared storage."
fi

