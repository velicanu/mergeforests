mergeforests
============
This code will automatically merge any forest that contains the hiEvtAnalyzer/HiTree . To use just check out and provide the pmerge.sh a text file containing the list of files to be merged, an output directory, and how many files should be merged per job.

One time setup:
```bash
git clone git@github.com:velicanu/mergeforests.git
```

Afterwhich it is reccomended to run the ./pmerge.sh script and condor_submit the pmerge.condor file from the most recently created directory, this will send the merging job to a condor worker node to not slow down the current machine. An example shown below:
```bash
# ./pmerge.sh <input-list> <out-dir> <files-per-job> 
./pmerge.sh HIMinBiasUPC-HIRun2011-14Mar2014-v2_tag_HI_MatchEqR_DatabaseJEC.txt /mnt/hadoop/cms/store/user/velicanu/HIMinBiasUPC-HIRun2011-14Mar2014-v2_tag_HI_MatchEqR_DatabaseJEC_merged 500
condor_submit mergejob_10_10_2014__11_45_15/pmerge.condor
```

To run merge.sh interactively:
```bash
# ./merge.sh <condor-iteration> <input-list> <output-dir> <files-per-job>
./merge.sh 0 HIHighPt_HIRun2011_HLT_HISinglePhoton20_HISinglePhoton30_FOREST_753p1_v0.txt /mnt/hadoop/cms/store/user/velicanu/HIHighPt/HIHighPt_HIRun2011_HLT_HISinglePhoton20_HISinglePhoton30_FOREST_753p1_v0/151019_172910/merged/ 5
```

To run mergeForest.exe interactively: 
```bash
# ./mergeForest.exe <file-pattern> <output-file>
./mergeForest.exe 'mergedTmp/*.root' outputfile.root
```

This works for both Data and MC.
