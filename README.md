# yambo-gcc_openmpi_fabric_mkl
Docker container for Yambo code compiled with gcc@9.3 openmpi@4.0.2+fabric mkl@2020

In this Docker container the OS Ubuntu v20.04 is used as starting point for the installation of the Yambo code compiled with gcc@9.3. 
As parallelization strategies are enabled OpenMP and MPI (openmpi@4.0.2, with fabric needed to run on a HPC cluster).
The library used are: IOTK, HDF5, NetCFD, Intel MKL, PETSc, SLEPc, FFTW, LibXC.

## How to use it in a x86_64 personal computer

In order to run the container in a personal computer first pull the container:

```
docker pull nicspalla/yambo-gcc_openmpi_fabric_mkl
```

Then generate the environment file that you will need later:

```
docker run -ti --user $(id -u):$(id -g) nicspalla/yambo-gcc_openmpi_fabric_mkl cat /opt/spack/env.txt > env.txt
```

Now you are able run Yambo with the container:

```
docker run -ti --user $(id -u):$(id -g) \
   --mount type=bind,source="$(pwd)",target=/tmpdir \
   -e OMP_NUM_THREADS=2  --env-file env.txt \
   nicspalla/yambo-gcc_openmpi_fabric_mkl \
   yambo -F yambo.in -J yambo.out
```

Otherwise (suggested!), copy and paste the code below in a file, i.e called drun.sh:

```
#!/bin/bash

threads=1
mpirun_wrapper=""
container="nicspalla/yambo-gcc_openmpi_fabric_mkl"
environment="--env-file env.txt"

while [[ $1 == -* ]]; do
    case $1 in
        -t | --threads ) threads=$2
                         shift 2
                         ;;
        -c | --container) container=$2
                          shift 2
                          ;;
        -np | --nprocess ) mpirun_wrapper="mpirun --use-hwthread-cpus -np $2"
                           shift 2
                           ;;
	--env-file ) environment="--env-file $2"
		     shift 2
		     ;;
        * ) echo "Error: \"$1\" unrecognized argument."
            exit 1
    esac
done

docker run -ti --user $(id -u):$(id -g) \
    --mount type=bind,source="$(pwd)",target=/tmpdir \
    -e OMP_NUM_THREADS=${threads} ${environment} \
    ${container} ${mpirun_wrapper} $@
```

then give the file execute privileges:

```
chmod +x drun.sh
```

Move (or copy) this file in the directory where you want to use Yambo and use it as prefix of your Yambo calculation:

```
./drun.sh yambo -F yambo.in -J yambo.out
```

This script gives you the possibility to choose the container's name with the option `-c`, to set the environment variable `OMP_NUM_THREADS` with the option `-t` and the number of MPI tasks with the option `-np`. Here an example:

```
./drun.sh -c nicspalla/yambo-gcc_openmpi_fabric_mkl -t 2 -np 4 yambo -F yambo.in -J yambo.out
```

If the yambo container is working correctly you should obtain:

```
./drun.sh yambo
yambo: cannot access CORE database (SAVE/*db1 and/or SAVE/*wf)
```

```
./drun.sh yambo -h
```

should provide in output the help for yambo usage.

## How to use it in a x86_64 cluster

In order to run the container in a cluster we suggest to use Singularity:

First pull the container:

```
singularity pull docker://nicspalla/yambo-gcc_openmpi_fabric_mkl
```

Then generate the environment file that you will need later:

```
singularity run yambo-gcc_openmpi_fabric_mkl_latest.sif cat /opt/spack/env.txt > env.txt
```

Then run Yambo into the container:

```
export SINGULARITYENV_OMP_NUM_THREADS=${OMP_NUM_THREADS}
mpirun singularity run --env-file env.txt -B${PWD}:/tmpdir --pwd /tmpdir yambo-gcc_openmpi_fabric_mkl_latest.sif yambo -F yambo.in -J yambo.out
```

## Example of a Slurm jobscript:

```
#!/bin/bash
#SBATCH --nodes=2
#SBATCH --tasks-per-node=18
#SBATCH --ntasks-per-socket=9
#SBATCH --cpus-per-task=2
#SBATCH --mem=118000
#SBATCH --time=0:30:00
#SBATCH --account=<account_name>
#SBATCH --partition=<partition_name>

module purge
module load singularity/3.6.1
module load autoload openmpi/4.0.1--gnu--7.3.0
        
export SINGULARITYENV_OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK 
container_name="yambo-gcc_openmpi_fabric_mkl_latest.sif"
container_prefix="singularity run --env-file env.txt -B${PWD}:/tmpdir,/scratch_local --pwd /tmpdir ${container_name}"

mpirun -np ${SLURM_NTASKS} ${container_prefix} yambo -F yambo.in -J yambo.out
```
