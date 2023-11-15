#!/bin/bash
#SBATCH --job-name=data_staging
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --output=data_staging_%j.out

# - SBATCH directives are effective only when submitted with 'sbatch'; ignored in direct shell execution.
SCRIPT_NAME=$(basename "$0")
# Function to display usage information
show_usage() {
    echo "Usage: $SCRIPT_NAME SOURCE DESTINATION"
    echo -e "Example: $SCRIPT_NAME /path/to/source /path/to/destination/\n"
    exit 1
}
# Check not on a login node 
if [ -z "$SLURM_NODELIST" ]; then 
	echo "Error: This script should not be run on a login node." 
	exit 1 
fi

# Check if the number of arguments is not equal to 2
if [ $# -ne 2 ]; then
    echo -e "Error: Two arguments are required.\n"
    show_usage
fi

SOURCE=$1
DESTINATION=$2

if [[ $DESTINATION == /shared* ]]; then
    # can't apply linux permission to ACL permissions
    OPTIONS="--no-perms"
fi

# Function to check if a login node is available
check_login_node() {
    local login_node=$1
    ssh -q $login_node exit
    return $?
}

# Define login nodes
login_node1=stanage-login1.shef.ac.uk
login_node2=stanage-login2.shef.ac.uk

# Create an array of login nodes
login_nodes=($login_node1 $login_node2)

# Shuffle the array (balancing the load)
shuffled_nodes=($(shuf -e "${login_nodes[@]}"))

# Loop through the shuffled nodes and check their availability
for node in "${shuffled_nodes[@]}"; do
    if check_login_node "$node"; then
        login_node="$node"
        break
    fi
done

# SSH to the selected login node
retries=0
max_retries=3
retry_delay=10
complete=0

while [ $retries -lt $max_retries ] && [ $complete -eq 0 ]; do
    ssh $login_node "
        rsync -avp ${OPTIONS} '${SOURCE}' '${DESTINATION}' 2>&1
        exit_status=\$?

        if [ \$exit_status -eq 0 ]; then
            echo 'Rsync operation completed successfully.'
            exit 0
        else
            echo 'Rsync operation failed. Retrying in $retry_delay seconds...'
            sleep $retry_delay
            exit 1
        fi
    "

    if [ $? -eq 0 ]; then
        complete=1  
    else
        ((retries++))
        if [ $retries -eq $max_retries ]; then
            echo \"ERROR: Rsync operation failed after $max_retries retries.\"
            exit 1
        fi
    fi
done
