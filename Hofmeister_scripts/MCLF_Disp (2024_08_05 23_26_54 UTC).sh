#!/bin/bash

if [ $# -ne 7 ]
then
 echo "Usage: $0 ion functional basis_set charge multiplicity n_proc mem(gb)"
 exit
fi

wd=$PWD
ion=$1
functional=$2
basis_set=$3
charge=$4
multiplicity=$5
n_proc=$6
mem=$7
#cd $ion
#n_atom=`head -n1 $ion.xyz | tr '\r' ' '`

if [[ $ion =~ 'I' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'iodobenzene' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'Te' ]] || [[ $ion =~ 'Po' ]] || [[ $ion =~ 'Sb' ]] || [[ $ion =~ 'Bi' ]] ||  [[ $ion =~ 'Xe' ]] || [[ $ion =~ 'Rn' ]] ||  [[ $ion =~ In ]] || [[ $ion =~ Tl ]] || [[ $ion =~ Ag ]] || [[ $ion =~ Cd ]] || [[ $ion =~ Hg ]] || [[ $ion =~ Pb ]]   && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-pp ]]
then
basis_set="$basis_set"-pp
fi
if [[ $ion = 'K' ]] && [[ ! $ion =~ 'Kr' ]] || [[ $ion =~ 'Rb' ]] || [[ $ion =~ 'Cs' ]]|| [[ $ion =~ 'Sr' ]] || [[ $ion =~ 'Ba' ]] || [[ $ion =~ 'Ca' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-x2c ]]
then
basis_set="$basis_set"-x2c
fi

if [[ $ion =~ 'SbCl5' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-pp ]]
then
basis_set="$basis_set"-pp
fi

#echo "basis set starts DDEC6 analysis as $basis_set"

if [ ! -f DDEC6_"$functional"_"$basis_set"/DDEC_weighted_Rfourth_moments.xyz ]
then
/drives/d/RCG/hofmeister/anion_files/DDEC6_analysis_basis.sh $ion $functional $basis_set $charge $multiplicity $n_proc $mem
fi

#echo "basis set finishes DDEC6 analysis as $basis_set"


if [ ! -f $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C8_dispersion_coefficients.xyz ]
then
echo "Starting MCLF calc for $ion $functional $basis_set"
cd $ion/DDEC6_"$functional"_"$basis_set"
natom=`head -n1 $ion.xyz | tr '\r' ' '`
mkdir -p MCLF
cd  MCLF
cp ../DDEC_weighted_Rfourth_moments.xyz .
cp ../DDEC_atomic_Rfourth_moments.xyz .
cp ../DDEC_atom_volumes.xyz .
cp ../DDEC6_even_tempered_net_atomic_charges.xyz .
cp ../DDEC_atomic_Rcubed_moments.xyz .
cp ~/bin/MCLF/MCLF_program_08_20_2019/MCLF_program_08_20_2019/calculation_parameters.txt .
~/bin/MCLF/MCLF_program_08_20_2019/MCLF_program_08_20_2019/MCLF_program_08_20_2019_parallel
#C6_disp=`grep -A $natom 'Nonperiodic system' $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_unscreened_C6_dispersion_coefficients.xyz | tail -n $natom | awk '{print $1, $5}'`
#echo "C6 disp coefficient = $C6_disp"
fi
C6_disp1=`grep -A 1 'The total screened C6 dispersion coefficient for the entire non-periodic system (in atomic units) is:' $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/dispersion_polarization_output.txt | tail -n 1 | awk '{print $1}'`
natom=`head -n1 $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C8_dispersion_coefficients.xyz | awk '{print $1}'`
natom2=`expr $natom + 2`
C8_disp1=`tail -n"$natom2" $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C8_dispersion_coefficients.xyz  | head -n"$natom" | awk '{print $6}' | awk '{s+=$1}END{print s}'`
C10_disp1=`tail -n"$natom2" $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C10_dispersion_coefficients_and_QDO_parameters.xyz  | head -n"$natom" | awk '{print $6}' | awk '{s+=$1}END{print s}'`

echo "C6 disp coefficient = $C6_disp1"
echo "C8 disp coefficient = $C8_disp1"
echo "C10 disp coefficient = $C10_disp1"
echo "$C6_disp1 $C8_disp1 $C10_disp1"

if [ ! -f $wd/$ion/DDEC6_"$functional"_"$basis_set"/TSSCS/TSSCS_C8_dispersion_coefficients.xyz ]
then
echo "Starting TSSCS calc"
cd ..
mkdir -p TSSCS
cd TSSCS
cp ../DDEC_atomic_Rcubed_moments.xyz .
cp ~/bin/MCLF/TSSCS_program_08_22_2019/TSSCS_program_08_22_2019/calculation_parameters.txt .
~/bin/MCLF/TSSCS_program_08_22_2019/TSSCS_program_08_22_2019/TSSCS_program_08_22_2019_parallel
fi
C6_disp2=`grep -A 1 'The total screened C6 dispersion coefficient for the entire non-periodic system (in atomic units) is:' $wd/$ion/DDEC6_"$functional"_"$basis_set"/TSSCS/dispersion_polarization_output.txt | tail -n 1 | awk '{print $1}'`
echo "C6 disp coefficient = $C6_disp2"

