
if [ $# -ne 4 ]
then
   echo "Usage: $0 molecule1 molecule2 functional basisset"
   exit 1
fi
module load gaussian

wd=$PWD

molecule1=$1
molecule2=$2
functional=$3
basisset=$4
if ! compgen -G  ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz* > /dev/null
then
	echo no ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz*
	exit 0
else
LowestE=$(grep -a -m1 'Total SAPT2+3' ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz* | awk '{print $8}' | N=1 awk -v N=$N 'NR == 1 { min = max = $N } { if ($N > max) max = $N; else if ($N < min) min = $N } END     { print  min }'  | awk -F'-' '{print $2}')
LowestESAPT=$(grep -a $LowestE ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz* | awk -F':' '{print $1}')
LowestESAPT_num=$(echo $LowestESAPT | awk -F'_' '{print $NF}' | awk -F. '{print $1}')
LowestEGeom="~/hofmeister/ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_"$LowestESAPT_num".out"
LowestEPrefix=$( echo $LowestEGeom | awk -F'.out' '{print $1}' | awk -F'/' '{print $NF}')
echo $LowestEPrefix
fi
#exit 0

cd ~/hofmeister/ion_int/$molecule1/$molecule2
##Fix after here

echo $LowestEPrefix.sum 
if [ -f $LowestEPrefix.sum ]
then
	#cd AIMAll_"$functional"_"$basisset"
	echo 0.002 IsoDensity Surface
	awk '/0.002 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' $LowestEPrefix.sum > tmpanalysis.dat
	Total=`grep Total tmpanalysis.dat | awk '{print $2}'`
	Total_num1=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/\1*10^\2\3/g' <<<"$Total"`
	head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $1}' > atomlist.dat
	areas=`head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $2}'`
	count=0
	for i in $areas
	do
		count=`expr $count + 1`
		i_num=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$i"`
		percentSA=`echo "scale=4; "$i_num" / "$Total_num1" *100" | bc -l`
		atom=`head -n $count atomlist.dat | tail -n1`
		echo "$molecule1""$molecul2" $atom $percentSA"%"
	done
	echo "$molecule1""$molecule2" Total Surface Area =$Total_num1
	grep Total tmpanalysis.dat | awk '{print $3}'
	
	echo 0.001 IsoDensity Surface
	rm tmpanalysis.dat
	awk '/0.001 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' $LowestEPrefix.sum > tmpanalysis.dat
        Total=`grep Total tmpanalysis.dat | awk '{print $2}'`
        Total_num2=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/\1*10^\2\3/g' <<<"$Total"`
        head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $1}' > atomlist.dat
        areas=`head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $2}'`
        count=0
        for i in $areas
        do
                count=`expr $count + 1`
                i_num=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/\1*10^\2\3/g' <<<"$i"`
                percentSA=`echo "scale=4; "$i_num" / "$Total_num2" *100" | bc -l`
                atom=`head -n $count atomlist.dat | tail -n1`
                echo "$molecule1""$molecule2" $atom $percentSA"%"
        done
        echo "$molecule1""$molecule2" Total Surface Area =$Total_num2
        grep Total tmpanalysis.dat | awk '{print $3}'

	echo 0.0004 IsoDensity Surface
	rm tmpanalysis.dat
        awk '/0.0004 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' $LowestEPrefix.sum > tmpanalysis.dat
        Total=`grep Total tmpanalysis.dat | awk '{print $2}'`
        Total_num3=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/\1*10^\2\3/g' <<<"$Total"`
        head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $1}' > atomlist.dat
        areas=`head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $2}'`
        count=0
        for i in $areas
        do
                count=`expr $count + 1`
                i_num=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$i"`
                percentSA=`echo "scale=4; "$i_num" / "$Total_num3" *100" | bc -l`
                atom=`head -n $count atomlist.dat | tail -n1`
                echo "$molecule1""$molecule2" $atom $percentSA"%"
        done
        echo "$molecule1""$molecule2" Total Surface Area =$Total_num3
	grep Total tmpanalysis.dat | awk '{print $3}'
	
	echo $molecule1 $molecule1 $molecule2 "$molecule1""$molecule2" =$Total_num1 =$Total_num2 =$Total_num3
elif [ ! -f "$LowestEPrefix".fchk ] ||  ! grep -q 'AIMQB Job Completed' $LowestEPrefix.AIMALL.out && ! grep -q 'AIMQB Job Completed' $LowestEPrefix.fchk.AIMALL.out
then
	#echo exiting to avoid duplicate data
        #exit 0
#       mkdir AIMAll_"$functional"_"$basisset"
#       cd AIMAll_"$functional"_"$basisset"
#       cp ../DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.wfx .
        formchk "$LowestEPrefix".chk
        echo "Running AIMALL analysis"
#       qued=`qstat -u | grep xeon5pa | grep '1  16' | grep
#       qaimall "$LowestEPrefix".fchk 16 64gb 72:00:00
        qaimall "$LowestEPrefix".fchk 1 64gb 300:00:00
#	export OMP_NUM_THREADS=1
#        /home/ajp/AIMAll/aimqb.ish -nogui "$LowestEPrefix".fchk > $LowestEPrefix.AIMALL.out
fi


