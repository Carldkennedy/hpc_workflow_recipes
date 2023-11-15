# HPC Workflow Recipes

## file-tranfers

The purpose of this script is to enable transfer of directories/files to/from shared areas whilst on a worker node, within an interactive session or batch job.

### Setup

Move file-transfers to ~/bin, make executable and add to .bashrc

```shell
mkdir -p ${HOME}/bin/
mv transfer-files ${HOME}/bin/transfer-files 
chmod +x ${HOME}/bin/transfer-files
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
source ~/.bashrc 
```
> NOTE: This script does not remove files once they are synced. 
  
Recommend assigning directories to variables. For example, create a **setup.sh** script:
```shell
#!/bin/bash
shared='/shared/path/to/directory/'
working_dir='/mnt/parscartch/users/${USER}/'
```
These variables are used in the examples below.

### Interactive usage

Usage:
```shell
transfer-files SOURCE DESTINATION
```

Example:
```shell
transfer-files ${shared}/some/path/ ${working_dir}/some/path/
```

### Batch jobs
Can also be submitted to the SLURM scheduler as a job submission (ex. useful for sbatch dependencies):

Default resource requests are 4G of memory and 10 minutes. 

Usage:
```shell
sbatch transfer-files SOURCE DESTINATION
```
Examples:
```shell
sbatch transfer-files ${shared}/some/path/ ${working_dir}/some/path/
```

```shell
sbatch --time=00:20:00 transfer-files ${shared}/some/path/ ${working_dir}/some/path/
```

> Caution: We need to be careful with trailing slashes

Trailing Slash in Source Directory: copies the contents of the source directory, but not the directory itself, into the destination.

If you want to copy the source directory itself into the destination, without merging its contents, you should omit the trailing slash: rsync source destination.

Trailing Slash in Destination Directory: copies the source into that directory, preserving its name.

If you don't want the source directory to be included in the destination, use a destination path without a trailing slash: rsync source/ destination

```mermaid
sequenceDiagram
    participant User
    participant Script
    participant SLURM
    participant Login Node
    participant Rsync

    User->>Script: Run script with SOURCE and DESTINATION arguments
    alt Check if on worker node
        Script->>SLURM: Check if on a worker node
        alt Not on worker node
            Script-->>User: Error: This script should not be run on a login node.
        else
            SLURM-->>Script: SLURM_NODELIST defined
        end
    else
        alt Invalid argument count
            Script-->>User: Error: Two arguments are required.
            Script-->>User: Usage: $SCRIPT_NAME SOURCE DESTINATION
        else
            alt Determine OPTIONS
                Script->>Script: Determine OPTIONS based on DESTINATION
                alt OPTIONS determined
                    Script-->>User: Using --no-perms due to DESTINATION
                else
                    Script-->>User: No additional OPTIONS
                end
            end
            Script->>Script: Define login nodes
            Script->>Script: Create shuffled list of login nodes
            loop Check login node availability
                Script->>Script: Select a login node
                Script->>Login Node: SSH to selected login node
                alt SSH successful
                    Login Node->>Login Node: Perform rsync operation
                    alt Rsync successful
                        Login Node-->>Script: Rsync operation completed successfully.
                        exit
                    else
                        Login Node-->>Script: Rsync operation failed. Retry in $retry_delay seconds...
                        Login Node-->>Script: Sleep for $retry_delay seconds
                        Script->>Script: Retry rsync operation
                    end
                else
                    Script->>Script: Retry with another login node
                end
            end
        end
    end
    alt Max retries reached
        Script-->>User: ERROR: Rsync operation failed after $max_retries retries.
    else
        Script-->>User: Data transfer completed successfully
    end
```