#!/bin/sh
#
# Submit a DFTB+ job to a batch queue on RCG grid
#
# $1      -- name of input file
# $2      -- wall time (hours)
# 
# First check if the queue exists
#

if [ $# -ne 3 ]
then
 echo "Usage: $0 jobname nrun walltime (hours)"
 exit 1
fi

# Declare number of processors

NPROC=8

#declare number of runs
nrun=$2

# Start creating the input file

cat <<END >$1.job
#!/bin/bash
#PBS -P dt3
#PBS -N $1
#PBS -l ncpus=$NPROC
#PBS -l mem=2GB
#PBS -l walltime=$3
#PBS -k eo

dir="\$TMPDIR" ; export dir
OMP_NUM_THREADS=$NPROC ; export OMP_NUM_THREADS
ulimit -s unlimited
module purge
module load dftbplus/19.1

if [ ! -d \$dir ] 
then
  mkdir \$dir
fi

#
# specify irun, iend
#

irun=1
iend=$nrun
#
# main loop of algorithm
#
 while [ "\$irun" -le "\$iend" ]
 do
#
# initialize variables
#
   run_dir=\$PBS_O_WORKDIR/run\${irun}
   jrun=\`expr \$irun + 1\`
   cd \$dir
   cp \$run_dir/geom.gen  \$dir
   cp \$run_dir/dftb_in.hsd  \$dir
   if [ -f \$run_dir/VELOC.DAT ] 
   then
     cp  \$run_dir/VELOC.DAT  \$dir
   fi
#
# run DFTB MD - use DFTB+
#

   date >> \$run_dir/run.out
   /apps/dftbplus/19.1/bin/dftb+ >> \$run_dir/run.out
   date >> \$run_dir/run.out
#
# make sure current run finished properly
#
    finish=\`grep -i "Molecular dynamics completed" \$run_dir/run.out\`
    if [ -z "\$finish" ] 
    then
#   date >> \$run_dir/run.out
#   /apps/dftbplus/19.1/bin/dftb+ >> \$run_dir/run.out
#   date >> \$run_dir/run.out
     echo "This job is running on host \`hostname\`"
     echo "current directory: \$run_dir"
     echo "something is wrong. exiting..."
     mv \$dir/* \$run_dir
     exit 1
    fi
#
# clean up files
#
   mv \$dir/* \$run_dir
#
# advance - shoot bn
#
   cd \$PBS_O_WORKDIR
   echo "advance from run\${irun} run\${jrun}"
   ~/bin/dftb+cp run\${irun} run\${jrun}
   irun=\`expr \$irun + 1\`
done

echo 'end' >> \$PBS_O_WORKDIR/run.log
date >> \$PBS_O_WORKDIR/run.log
echo '   '

rm -fr \$dir
END

#now submit

qsub $1.job
#rm -f $1.job

exit 0

 
