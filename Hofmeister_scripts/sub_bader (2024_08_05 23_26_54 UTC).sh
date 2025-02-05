
wd=$PWD
for i in `ls -d */ | awk -F/ '{print $1}'`
do
cd $wd/$i
echo "Creating "$i"_m062x_mkcharge.fchk file"
formchk "$i"_m062x_mkcharge.chk
echo "Making "$i".cube file"
cubegen 1 Density=SCF "$i"_m062x_mkcharge.fchk "$i".cube
echo "Bader Charge analysis step"
../bader $i.cube
done

