
if [ $# -ne 4 ]
then
   echo "Usage: $0 ion functional basisset queue"
   exit 1
fi

wd=$PWD

ion=$1
functional=$2
basisset=$3
queue=$4

f=`echo $1 | awk -F. '{print $1}'`
#ncpus=$2
#mem=$3
#walltime=$4



cd $ion
if [ -f DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.wfx ] && [ ! -f AIMAll_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.wfx ] ||  ! grep -q 'AIMQB Job Completed' AIMAll_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6*AIMALL.out && ! grep -q 'IsoDensity' AIMAll_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.sum 
then
	mkdir AIMAll_"$functional"_"$basisset"
	cd AIMAll_"$functional"_"$basisset"
	cp ../DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.wfx .
	echo "Running AIMALL analysis"
	if [ $queue == 'headnode' ]
	then
		echo "Running on headnode"
		export OMP_NUM_THREADS=1
        	/home/ajp/AIMAll/aimqb.ish -nogui "$ion"_"$functional"_"$basisset"_DDEC6.wfx > "$ion"_"$functional"_"$basisset"_DDEC6.AIMALL.out
	else
		qaimall "$ion"_"$functional"_"$basisset"_DDEC6.wfx 1 1gb 72:00:00
	fi
elif [ -f AIMAll_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.sum ]
then
	cd AIMAll_"$functional"_"$basisset"
	echo 0.002 IsoDensity Surface
	awk '/0.002 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' "$ion"_"$functional"_"$basisset"_DDEC6.sum > tmpanalysis.dat
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
		echo $ion $atom $percentSA"%"
	done
	echo "$ion Total Surface Area =$Total_num1"
	grep Total tmpanalysis.dat | awk '{print $3}'
	
	echo 0.001 IsoDensity Surface
	rm tmpanalysis.dat
	awk '/0.001 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' "$ion"_"$functional"_"$basisset"_DDEC6.sum > tmpanalysis.dat
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
                echo $ion $atom $percentSA"%"
        done
        echo "$ion Total Surface Area =$Total_num2"
        grep Total tmpanalysis.dat | awk '{print $3}'

	echo 0.0004 IsoDensity Surface
	rm tmpanalysis.dat
        awk '/0.0004 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' "$ion"_"$functional"_"$basisset"_DDEC6.sum > tmpanalysis.dat
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
                echo $ion $atom $percentSA"%"
        done
        echo "$ion Total Surface Area =$Total_num3"
	grep Total tmpanalysis.dat | awk '{print $3}'

	echo "$ion =$Total_num1 =$Total_num2 =$Total_num3"

fi


