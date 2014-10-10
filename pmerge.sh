if [ $# -ne 3 ]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <files-per-job>"
  exit 1
fi

mkdir -p $2
now="mergejob_$(date +"%m_%d_%Y__%H_%M_%S")"
mkdir $now
len=`wc -l $1 | awk '{print $1}'`
filesperjob=$3
njobs=$((len/filesperjob+1))

cp merge.sh $now
cp $1 $now

# function rootcompile()
# {
   # local NAME=$1
   # g++ $NAME $(root-config --cflags --libs) -Werror -Wall -O2 -o "${NAME/%.C/}.exe"
# }
NAME="mergeForest.C"
g++ $NAME $(root-config --cflags --libs) -Werror -Wall -O2 -o "${NAME/%.C/}.exe"
cp mergeForest.exe $now
cat pmerge.condor | sed "s@log_flag@$now@g" | sed "s@user_flag@$USER@g" | sed "s@dir_flag@$PWD/$now@g" | sed "s@arg1@$1@g" | sed "s@arg2@$2@g" | sed "s@arg3@$3@g" | sed "s@njobs@$njobs@g" > $now/pmerge.condor

cat $now/pmerge.condor
echo condor_submit $now/pmerge.condor

