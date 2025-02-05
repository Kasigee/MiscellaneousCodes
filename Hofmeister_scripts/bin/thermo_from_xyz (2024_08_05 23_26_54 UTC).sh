#!/bin/bash


if [ $# -ne 5 ]
then
	echo "Usage:$0 filename.xyz charge temp(K) Pressure(atm) Rot.Sym."
 exit 1
fi

module load dftbplus

file=$1
prefix=`echo $file | awk -F'.' '{print $1}'`
natoms=`head -n1 $file | awk '{print $1}'`
charge=$2
Temp=$3
Pressure=$4
RotSym=$5

if [ ! -f $prefix.2.xyz ]
then
	echo "quick_dftb_opt.sh.OLD220217"
	quick_dftb_opt.sh.OLD220217 $file $charge 1 1gb 1:00:00 headnode > prefix.2.out
fi

if ! grep -q 'converged' "$prefix"_opt.out
then
cp opt.xyz $prefix.2.xyz

tail -n$natoms $prefix.2.xyz | awk '{print $1,$2,$3,$4}' > coords.tmp

cat <<END > "$prefix"_opt.com
%nproc=1
%mem=1gb
#sp hf/3-21g

$prefix.com, Wed Jun 8

$charge 1
END
cat coords.tmp >> "$prefix"_opt.com
rm coords.tmp
cat <<END >> "$prefix"_opt.com



END

module load gaussian
#if ! grep -q 'converged' "$prefix"_opt.out
#then
 g16 < "$prefix"_opt.com > "$prefix"_opt.out
fi

RotX=`grep 'Rotational constants ' "$prefix"_opt.out | awk '{print $4}'`
RotY=`grep 'Rotational constants ' "$prefix"_opt.out | awk '{print $5}'`
RotZ=`grep 'Rotational constants ' "$prefix"_opt.out | awk '{print $6}'`
echo $RotX $RotY $RotZ

IX=`echo "1804.741650/$RotX" | bc -l`
IY=`echo "1804.741650/$RotY" | bc -l`
IZ=`echo "1804.741650/$RotZ" | bc -l`
echo $IX $IY $IZ

if [ $natoms == '1' ] && [ $Temp == '300' ]
then
	IX=0.197131
	IY=0.197131
	IZ=0.197131
fi


out-xyz "$prefix"_opt.out

if ! grep -q 'Second derivatives completed' "$prefix"_dftb_freq.out
then
	quick_dftb_freq_make.sh.PBC "$prefix"_opt.xyz $charge 1 1gb 1:00:00 headnode > "$prefix"_dftb_freq.out
fi

#if [ ! -f modes.out ]
#then
cat <<END > modes_in.hsd
# Needs the equilibrium geometry, at which the Hessian had been calculated
Geometry = XyzFormat {
   <<< "$prefix"_opt.xyz
}

DisplayModes = {
  PlotModes = 1:-1 # Take the top 10 modes
  Animate = Yes      # make xyz files showing the atoms moving
}

# You need to specify the SK-files, as the mass of the elements is needed
SlaterKosterFiles = Type2FileNames {
  Prefix = "/home/ajp/slako/3ob-3-1/"
  Separator = "-"
  Suffix = ".skf"
}

# Include the Hessian, which was calculated by DFTB+
Hessian = {
  <<< "hessian.out"
}

# This file uses the 3rd input format of the modes code
InputVersion = 3
END

modes > modes.out
#fi

rm freq.tmp
#count=0
if [ $natoms -ne 0 ]
then
#for i in `tail -n1 modes.out`
#do
	grep [0-10000] modes.out | awk '$2>100{print$2}'
#	grep ' '$i' ' modes.out | head -n1
	grep [0-10000] modes.out | awk '$2>100{print$2}' >> freq.tmp
#	count=`expr $count + 1`
#done
fi
count=`wc -l freq.tmp | awk '{print $1}'`
count=`expr $count - 1`
echo $count
#cat freq.tmp | tr '\n' ' '

mass=`calculate_MW_xyz.sh "$prefix"_opt.xyz | head -n2 | tail -n1 | awk '{print $6}'`

echo "$Temp $Pressure #temperature (k), pressure (atm)" > thermochem.in
echo "1 #electronic degeneracy" >> thermochem.in
echo "$mass $IX $IY $IZ $RotSym #mass, moments of inertia (x,y,z), rotational symmetry no." >> thermochem.in
echo $count $(cat freq.tmp | tail -n+2 | tr '\n' ' ')  >> thermochem.in

cat thermochem.in

~/Alisters-one-code-wonders-master/thermochem  < thermochem.in > thermochem.out
cat thermochem.out
GFEcorr=`grep 'Thermal correction to Gibbs Free Energy=' thermochem.out | awk '{print $7}'`
TE=`grep 'Total energy:' detailed.out | awk '{print $3}'`
GFE=`echo "$GFEcorr + $TE" | bc -l`
echo $GFE > GFE.dat
echo "Sum of electronic and thermal Free Energies($TE + $GFEcorr) = $GFE"
