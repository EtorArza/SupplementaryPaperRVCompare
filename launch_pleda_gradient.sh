# Edit the number of parallel executions. 
N=8


# compile
rm "data/pleda_gradient/results" -r
mkdir "data/pleda_gradient/results"

rootDir=`pwd`
cd "data/pleda_gradient/gradient/"
make
cd $rootDir
cd "data/pleda_gradient/PLEDA/"
make
cd $rootDir


echo "compiled"

open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}
run_with_lock(){
    local x
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    printf '%.3d' $? >&3
    )&
}


run_one(){
    ins=$1
    s=$2
    ./data/pleda_gradient/gradient/gradientSearch ${ins}
    ./data/pleda_gradient/PLEDA/PlackettLuceEDA -i ${ins} -s ${s} 
    sleep ${s}
}




open_sem $N
for ins in `ls -d "data/pleda_gradient/instances/"*`
do
    for s in {2..402}
    do
    echo "$ins - $s"
    run_with_lock run_one ${ins} ${s}
    done
done






