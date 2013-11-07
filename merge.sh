start=$((($1+1)*$4))
mkdir mergedTmp
cat $2 | head -n $start | tail -n $4 | awk -v filename=$1 -v outdir=$3 -v nfiles=$4 '{print "ln -s "$1" mergedTmp/"}' | bash
# echo | awk -v filename=$1 -v outdir=$3 -v nfiles=$4 '{print "root -b -q \"mergeForest.C+(\\\"mergedTmp/*.root\\\",\\\""filename".root\\\")\""}' | bash
echo | awk -v filename=$1 -v outdir=$3 -v nfiles=$4 '{print "./mergeForest.exe \"mergedTmp/*.root\" \""filename".root\""}' | bash
mv $1.root $3
