#!/bin/bash
if [ $# -lt 3 ]
then
  echo "Usage: ./pmerge.sh <input-list> <out-dir> <out-lfn> [filename] [fast] [nfiles] [unmerged-path]"
  exit 1
fi

# if we're given the LFN instead of a text file list create the txtfile list and ask to rerun
if [ ! -f $1 ]
then
  eos ls $1 | awk -v inputpath=$1 '{print "'$inputpath'"$1}' > tmppath.txt
  echo Made tmppath.txt from lfn, rerun with it, looks like 
  head -n2 tmpptath.txt
  exit 1
fi
# if we're not given a unmerged-path , set a default
if [ -z "$7" ]
then
  unmergepath="/data/velicanu/forests/unmerged_$(date +"%m_%d_%Y__%H_%M_%S")"
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


# stage all the files locally
for i in `cat $1`
do
  cmsStage $i $unmergepath
done

# merge the files, using hadd if fast otherwise with mergescript
if [ $5 -ne 1 ] 
then

else
  hadd -f $2/$filename $unmergepath/*.root
fi

# stage out the files
cmsStage -f $2/$filename $3/$filename

# email that jobs are done
echo $2/$filename > mymail
echo $3/$filename >> mymail
maili -s "merged files are done" velicanu@mit.edu < mymail
rm mymail

