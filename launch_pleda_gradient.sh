

rm "data/pleda_gradient/results" -r
mkdir "data/pleda_gradient/results"

rootDir=`pwd`
cd "data/pleda_gradient/gradient/"
make
cd $rootDir
cd "data/pleda_gradient/PLEDA/"
make
cd $rootDir
for ins in `ls -d "data/pleda_gradient/instances/"*`
do
    for s in {2..82}
    do
    echo "$ins - $s"
    ./data/pleda_gradient/gradient/gradientSearch ${ins}
    ./data/pleda_gradient/PLEDA/PlackettLuceEDA -i ${ins} -s ${s} 
    done
done






