# Edit the number of parallel executions. 

if [ $# -ne 1 ]
  then
    echo "usage: 
    bash launch_pleda_gradient.sh <n_parallel_cores>
    To launch with 4 parallel processes, 
    bash launch_pleda_gradient.sh 4
    "
    exit 1
fi

N=$1
N=$((N - 1))

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
    echo "done $ins - seed = $s"
}




open_sem $N
for ins in `ls -d "data/pleda_gradient/instances/"*`
do
    for s in {2..1002}
    do
    echo "computing $ins - seed = $s"
    sleep 1
    run_with_lock run_one ${ins} ${s} > "/dev/null"
    done
done






