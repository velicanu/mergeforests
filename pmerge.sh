if [[ -z "$1" ]]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <files-per-job>"
  exit 1
fi
if [[ -z "$2" ]]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <files-per-job>"
  exit 1
fi
if [[ -z "$3" ]]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <files-per-job>"
  exit 1
fi

now="mergejob_$(date +"%m_%d_%Y__%H_%M_%S")"
mkdir $now
len=`wc -l $1 | awk '{print $1}'`
filesperjob=$3
njobs=$((len/filesperjob+1))
echo $njobs
cp merge.sh $now
cp $1 $now

# function rootcompile()
# {
   # local NAME=$1
   # g++ $NAME $(root-config --cflags --libs) -Werror -Wall -O2 -o "${NAME/%.C/}.exe"
# }
cp hiForestMerging/mergeForest.C .
NAME="mergeForest.C"
g++ $NAME $(root-config --cflags --libs) -Werror -Wall -O2 -o "${NAME/%.C/}.exe"
# rootcompile hiForestMerging/mergeForest.C
cp mergeForest.exe $now
cat pmerge.condor | sed "s@log_flag@$now@g" | sed "s@dir_flag@$PWD/$now@g" | sed "s@arg1@$1@g" | sed "s@arg2@$2@g" | sed "s@arg3@$3@g" | sed "s@njobs@$njobs@g" > $now/pmerge.condor

echo condor_submit $now/pmerge.condor
# cat $1 | head -n 23 | awk -v outdir=$2 -v nfiles=$3 'BEGIN{i=0;c=0;print "mkdir -p mergedTmp/"c}{i++}{if (i>nfiles) {print "root -b -q \"hiForestMerging/mergeForest.C+(\\\"mergedTmp/"c"/*.root\\\",\\\"mergedTmp/"c".root\\\")\"";print "mv mergedTmp/"c".root "outdir" ";c++;i=0;print "mkdir -p mergedTmp/"c}} {print "ln -s "$1,"mergedTmp/"c"/"}{sub(".*/","",$1)}'

