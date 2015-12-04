// mergeForest.C
// Authors Alex Barbieri and Dragos Velicanu
// Merge small HiForests into one large HiForest by combining trees.

#include <TChain.h>
#include <TFile.h>
#include <TString.h>
#include <iostream>

int getEntries(TString fname = "", int onetree = 0)
{
  TFile *testFile = TFile::Open(fname);
  TList *topKeyList = testFile->GetListOfKeys();

  std::vector<TString> trees;
  std::vector<TTree*> treePointers;
  std::vector<TString> dir;

  for(int i = 0; i < topKeyList->GetEntries(); ++i)
  {
    TDirectoryFile *dFile = (TDirectoryFile*)testFile->Get(topKeyList->At(i)->GetName());
    if(strcmp(dFile->ClassName(), "TDirectoryFile") != 0) continue;
    
    TList *bottomKeyList = dFile->GetListOfKeys();

    for(int j = 0; j < bottomKeyList->GetEntries(); ++j)
    {
      TString treeName = dFile->GetName();
      treeName += "/";
      treeName += bottomKeyList->At(j)->GetName();

      TTree* tree = (TTree*)testFile->Get(treeName);
      treePointers.push_back(tree);
      if(strcmp(tree->ClassName(), "TTree") != 0 && strcmp(tree->ClassName(), "TNtuple") != 0) continue;

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
    std::cout<<trees[i]<<": "<<treePointers[i]->GetEntries()<<std::endl;
  }
  testFile->Close();
  return 1;
}

int main(int argc, char *argv[])
{
  if((argc != 2) && (argc != 3))
  {
    std::cout << "Usage: mergeForest <input_collection> <output_file>" << std::endl;
    return 1;
  }
  
  if(argc == 2)
    getEntries(argv[1]);
  else if (argc == 3)
    getEntries(argv[1], std::atoi(argv[2]));
  return 0;
}
