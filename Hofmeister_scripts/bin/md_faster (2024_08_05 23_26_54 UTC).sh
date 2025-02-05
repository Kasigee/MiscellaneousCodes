#!/bin/bash
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

NPROC=1

#declare number of runs
nrun=$2

# Start creating the input file

cat <<END >$1.job
#!/bin/bash
#PBS -N $1
#PBS -l select=1:ncpus=$NPROC:mem=2GB
#PBS -l walltime=$3
#PBS -k eo
#PBS -q xeon5q

PATH="\$PATH:/home/ajp/bin/" ; export PATH
dir="\$TMPDIR" ; export dir
export OMP_NUM_THREADS=$NPROC 
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
#   cp \$run_dir/plumed.dat  \$dir
   sed -i 's/\/apps\/dftbplus\/slako\/3ob\/3ob-3-1\//\/home\/ajp\/slako\/3ob-3-1\//g' dftb_in.hsd
   sed -i 's/\/apps\/dftbplus\/slako\/3ob\/3ob-3-1\//\/home\/ajp\/slako\/3ob-3-1\//g' \$dir/dftb_in.hsd
   sed -i 's/\/apps\/dftbplus\/slako\/3ob\/3ob-3-1\//\/home\/ajp\/slako\/3ob-3-1\//g' \$run_dir/dftb_in.hsd
   sed -i 's/QR/DivideAndConquer/g' dftb_in.hsd
   sed -i 's/QR/DivideAndConquer/g' \$dir/dftb_in.hsd
   sed -i 's/QR/DivideAndConquer/g' \$run_dir/dftb_in.hsd
   sed -i 's/threebody = Yes/threebody = No/g' \$run_dir/dftb_in.hsd
   sed -i 's/hhrepulsion = Yes/hhrepulsion = No/g' \$run_dir/dftb_in.hsd

sed -i 's/  HCorrection = H5 {/ HCorrection = Damping { \n Exponent = 4.05000000000000/g' \$run_dir/dftb_in.hsd
sed -i 's/Exponent = = 4.05000000000000/ Exponent = 4.05000000000000/g' \$run_dir/dftb_in.hsd
sed -i 's/Exponent = = 4.05000000000000/ Exponent = 4.05000000000000/g' \$dir/dftb_in.hsd
sed -i 's/Exponent = = 4.05000000000000/ Exponent = 4.05000000000000/g' dftb_in.hsd
   if [ -f \$run_dir/VELOC.DAT ] 
   then
     cp  \$run_dir/VELOC.DAT  \$dir
   fi


#
# run DFTB MD - use DFTB+
#
finish=\`grep -i "Molecular dynamics completed" \$run_dir/run.out\`
#exists=\`ls \$run_dir/run.out | wc -l\`
#if [ -z "\$finish" ] || [ "\$exists" -lt 1 ]
if [ -z "\$finish" ]
    then

   date >> \$dir/run.out
   /cm/software/apps/dftbplus/19.1/bin/dftb+ >> \$dir/run.out
   date >> \$dir/run.out
   mv \$dir/* \$run_dir/.
fi
#
# make sure current run finished properly
#

#    finish=\`grep -i "Molecular dynamics completed" \$run_dir/run.out\`
#    finisi=\`grep -i "Molecular dynamics completed" \$dir/run.out\`
#  if [ -z "\$finish" ] && [ -z "\$finisi" ]
#  then
#   cd \$dir
#   rm \$dir/run.out
#   date >> \$dir/run.out
#   echo "This dftb run is in run_dir \$run_dir and dir \$dir. Current directory is \$PWD. PBS work directory is \$PBS_O_WORKDIR" >> \$dir/run.out 
#   /cm/software/apps/dftbplus/19.1/bin/dftb+ >> \$dir/run.out
#   date >> \$dir/run.out
#   cd ..
#     echo "This job is running on host \`hostname\`"
#     echo "current directory: \$run_dir"
#     echo "something is wrong. exiting..."
#     mv \$dir/* \$run_dir
#     exit 1
#    fi

##
## clean up files
##
#   mv \$dir/* \$run_dir
##
## advance - shoot bn
##
   cd \$PBS_O_WORKDIR
   echo \$dir/* \$run_dir
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
rm -f $1.job

exit 0

 
