#!/bin/sh
#
# Submit a Gaussian 09 job to the grid
#
# $1      -- name of input file
# $2      -- wall time (hours)
# 
# Number of processors will be read from the Gaussian input file
# Memory per processor is 1.8 Gb per node
#
# Additional specification in the input line is possible only after supplying walltime in hours
#
# First check if the queue exists
#

#
# check for the input file
#

if [ $# -ne 5 ]
then
   echo "Usage: $0 jobname ncores mem(gb)  wallclocktime (h) queue"
   exit 1
fi

f=$1
ncores=$2
mem=$3
walltime=$4
queue=$5

# Start creating the input file
cat <<END >>$f.job
#!/bin/bash
#PBS -N $f
#PBS -l select=1:ncpus=$ncores:mem=$mem
#PBS -l walltime=$walltime
#PBS -r n
#PBS -q $queue

export OMP_NUM_THREADS=$ncores
ulimit -s unlimited

cd \$PBS_O_WORKDIR

/home/kpg600/bin/MCLF/Chargemol_08_22_2019/sourcecode_08_22_2019/Chargemol_08_22_2019_linux_parallel
#Chargemol_09_26_2017_linux_parallel

END

# Now submit it.
qsub $f.job
#rm -f $f.job

exit 0

