
echo structure 0.002 0.001 0.0004
for i in `ls -d Li*`
do
echo $i $(./aimall_analysis.sh $i m062x aug-cc-pvdz | grep Total | awk '{print $5}')
#i2=`echo $i | awk -F'Li' '{print $2}'`
#echo $i2 $(./aimall_analysis.sh $i2 m062x aug-cc-pvdz | grep Total | awk '{print $5}')
done

for i in `ls -d Li* | awk -F'Li' '{print $2}'`
do
echo $i $(./aimall_analysis.sh $i m062x aug-cc-pvdz | grep Total | awk '{print $5}')
done

