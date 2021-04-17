# yambo-gcc_openmpi_fabric_mkl
Docker container for Yambo code compiled with gcc@9.3 openmpi@4.0.2+fabric mkl@2020

In this Docker container the OS Ubuntu v20.04 is used as starting point for the installation of the Yambo code compiled with gcc@9.3. 
As parallelization strategies are enabled OpenMP and MPI (openmpi@4.0.2, with fabric needed to run on a HPC cluster).
The library used are: IOTK, HDF5, NetCFD, Intel MKL, PETSc, SLEPc, FFTW, LibXC.

## How to use it in a x86_64 cluster

In order to run the container in a cluster we suggest to use Singularity:

First pull the container:

```
singularity pull docker://nicspalla/yambo-gcc_openmpi_fabric_mkl:latest
```

Then run Yambo into the container:

```
export SINGULARITYENV_OMP_NUM_THREADS=${OMP_NUM_THREADS}
mpirun singularity run -B${PWD}:/tmpdir --pwd /tmpdir yambo-gcc_openmpi_fabric_mkl_latest.sif yambo -F yambo.in -J yambo.out
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
container_prefix="singularity run -B${PWD}:/tmpdir,/scratch_local --pwd /tmpdir ${container_name}"

mpirun -np ${SLURM_NTASKS} ${container_prefix} yambo -F yambo.in -J yambo.out
```
