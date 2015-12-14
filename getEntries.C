// mergeForest.C
// Authors Alex Barbieri and Dragos Velicanu
// Merge small HiForests into one large HiForest by combining trees.

#include <TChain.h>
#include <TFile.h>
#include <TString.h>
#include <iostream>

int getEntries(TString fname = "", int onetree = 0)
{
  TFile *_file0 = TFile::Open(fname);
  TList *topKeyList = _file0->GetListOfKeys();

  std::vector<TString> trees;
  std::vector<TString> dir;
  std::vector<Long64_t> nentries;

  for(int i = 0; i < topKeyList->GetEntries(); ++i)
  {
    TDirectoryFile *dFile = (TDirectoryFile*)_file0->Get(topKeyList->At(i)->GetName());
    if(strcmp(dFile->ClassName(), "TDirectoryFile") != 0) continue;
    
    TList *bottomKeyList = dFile->GetListOfKeys();

    for(int j = 0; j < bottomKeyList->GetEntries(); ++j)
    {
      TString treeName = dFile->GetName();
      treeName += "/";
      treeName += bottomKeyList->At(j)->GetName();

      TTree* tree = (TTree*)_file0->Get(treeName);
      if(strcmp(tree->ClassName(), "TTree") != 0 && strcmp(tree->ClassName(), "TNtuple") != 0) continue;
      nentries.push_back(tree->GetEntries());

      trees.push_back(treeName);
      dir.push_back(dFile->GetName());
      if(onetree == 1) break;
    }
    if(onetree == 1) break;
  }


  // Now use the list of tree names to make a new root file, filling
  // it with the trees from 'fname'.
  const int Ntrees = trees.size();
  for(int i = 0; i < Ntrees; ++i){
    std::cout<<trees[i]<<": "<<nentries[i]<<" "<<std::endl;
  }
  _file0->Close();
  return 1;
}

int main(int argc, char *argv[])
{
  if((argc != 2) && (argc != 3))
  {
    std::cout << "Usage: getEntries.exe <inputFile> [do_only_first_tree]" << std::endl;
    return 1;
  }
  
  if(argc == 2)
    getEntries(argv[1]);
  else if (argc == 3)
    getEntries(argv[1], std::atoi(argv[2]));
  return 0;
}
