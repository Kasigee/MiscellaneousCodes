ion=$1
functional=m062x
wd=$PWD

basis_set=aug-cc-pvdz

if [[ $ion =~ 'I' ]] || [[ $ion =~ 'iodobenzene' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'Te' ]] || [[ $ion =~ 'Po' ]] || [[ $ion =~ 'Sb' ]] || [[ $ion =~ 'Bi' ]] ||  [[ $ion =~ 'Xe' ]] || [[ $ion =~ 'Rn' ]] ||  [[ $ion =~ In ]] || [[ $ion =~ Tl ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-pp ]]
then
basis_set="$basis_set"-pp
elif [[ $ion = 'K' ]] && [[ ! $ion =~ 'Kr' ]] || [[ $ion =~ 'Rb' ]] || [[ $ion =~ 'Cs' ]]|| [[ $ion =~ 'Sr' ]] || [[ $ion =~ 'Ba' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-x2c ]]
then
basis_set="$basis_set"-x2c
fi

if [[ $ion =~ 'SbCl5' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-pp ]]
then
basis_set="$basis_set"-pp
fi




C6_disp1=`grep -A 1 'The total screened C6 dispersion coefficient for the entire non-periodic system (in atomic units) is:' $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/dispersion_polarization_output.txt | tail -n 1 | awk '{print $1}'`
natom=`head -n1 $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C8_dispersion_coefficients.xyz | awk '{print $1}'`
natom2=`expr $natom + 2`
C8_disp1=`tail -n"$natom2" $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C8_dispersion_coefficients.xyz  | head -n"$natom" | awk '{print $6}' | awk '{s+=$1}END{print s}'`
C10_disp1=`tail -n"$natom2" $wd/$ion/DDEC6_"$functional"_"$basis_set"/MCLF/MCLF_C10_dispersion_coefficients_and_QDO_parameters.xyz  | head -n"$natom" | awk '{print $6}' | awk '{s+=$1}END{print s}'`

echo "$ion $C6_disp1 $C8_disp1 $C10_disp1"
