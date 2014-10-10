mergeforests
============
This code will automatically merge any forest that contains the hiEvtAnalyzer/HiTree . To use just check out and provide the pmerge.sh a text file containing the list of files to be merged, an output directory, and how many files should be merged per job.

One time setup:
```bash
git clone git@github.com:velicanu/mergeforests.git
```

Afterwhich run the ./pmerge.sh script and condor_submit the pmerge.condor file from the most recently created directory. An example shown below:
```bash
./pmerge.sh HIMinBiasUPC-HIRun2011-14Mar2014-v2_tag_HI_MatchEqR_DatabaseJEC.txt /mnt/hadoop/cms/store/user/velicanu/HIMinBiasUPC-HIRun2011-14Mar2014-v2_tag_HI_MatchEqR_DatabaseJEC_merged 500
condor_submit mergejob_10_10_2014__11_45_15/pmerge.condor
```

This works for both Data and MC.
