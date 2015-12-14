#!/bin/bash
if [ $# -lt 3 ]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <out-lfn> [filename] [fast] [nfiles] [unmerged-path]"
  exit 1
fi


function checkfile {

fullentries=`$unmergepath/getEntries.exe $1 | grep -v ": 0 " | grep -v ": 1 "`
bad=`for i in $fullentries ; do echo $i | grep -v : ; done  | sort | uniq | wc -l`

if [ $bad -gt 1 ]
then
  echo removing $1
  echo  $fullentries
  echo "############################" >> badfiles.txt
  echo $1 >> badfiles.txt
  echo  $fullentries >> badfiles.txt
  rm $1
fi

}






export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/yjlee/lib

# if we're given the LFN instead of a text file list create the txtfile list and ask to rerun
if [ ! -f $1 ]
then
  /afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select ls $1 | awk -v inputpath=${1} '{print '"inputpath"'"/"$1}' > ${4}tmppath.txt
  echo Made ${4}tmppath.txt from lfn, rerun with it, looks like 
  head -n2 ${4}tmppath.txt
  exit 1
fi
# if we're not given a unmerged-path , set a default
if [ -z "$7" ]
then
  unmergepath="/data/$USER/forests/unmerged_$(date +"%m_%d_%Y__%H_%M_%S")"
else
  unmergepath=$7
fi
# if we're not given a unmerged-path , set a default
if [ -z "$4" ]
then
  filename="merged_$(date +"%m_%d_%Y__%H_%M_%S").root"
else
  filename=$4
fi

mkdir -p $unmergepath/
mkdir -p $2/
/afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select mkdir -p $3

count=0
cp getEntries.exe $unmergepath/
# stage all the files locally, delete any that have inconsistent entries
for i in `cat $1`
do
  echo cmsStage $i $unmergepath/HiForest_${count}.root
  cmsStage $i $unmergepath/HiForest_${count}.root
  wait
  checkfile $unmergepath/HiForest_${count}.root &
  count=$((count+1))
done

wait

# delete empty (<1MB) forests which usually break the merging
cd $unmergepath
find . -type f -size -1048576c | xargs rm
cd -


rm $unmergepath/getEntries.exe

# merge the files, using hadd if fast otherwise with mergescript
if [ $5 -ne 1 ] 
then
  ./mergeForest.exe "$unmergepath/*.root" $2/$filename
else
  hadd -f $2/$filename $unmergepath/*.root
fi

# stage out the files
cmsStage -f $2/$filename $3/$filename

# email that jobs are done
echo $2/$filename > mymail
echo $3/$filename >> mymail
echo mail -s "merged files are done" $USER.mit.edu < mymail
rm mymail

