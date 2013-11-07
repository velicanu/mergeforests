// mergeForest.C
// Authors Alex Barbieri and Dragos Velicanu
// Merge small HiForests into one large HiForest by combining trees.

#include <TChain.h>
#include <TFile.h>
#include <TString.h>
#include <iostream>

void mergeForest(TString fname = "/mnt/hadoop/cms/store/user/richard/pA_jet20Skim_forest_53x_2013-08-15-0155_unmerged/*.root",
		 TString outfile="pA_jet20Skim_forest_53x_2013-08-15-0155.root",
		 bool failOnError = true)
{
  // First, find on of the files within 'fname' and use it to make a
  // list of trees. Unfortunately we have to know in advance at least
  // one of the tree names. hiEvtAnalyzer/HiTree is a safe choice for
  // HiForests. We also assume that every TTree is inside a
  // TDirectoryFile which is in the top level of the root file.
  TChain *dummyChain = new TChain("hiEvtAnalyzer/HiTree");
  dummyChain->Add(fname);
  TFile *testFile = dummyChain->GetFile();
  TList *topKeyList = testFile->GetListOfKeys();

  std::vector<TString> trees;
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
      if(strcmp(tree->ClassName(), "TTree") != 0 && strcmp(tree->ClassName(), "TNtuple") != 0) continue;

      trees.push_back(treeName);
      dir.push_back(dFile->GetName());
    }
  }

  testFile->Close();
  delete dummyChain;

  // Now use the list of tree names to make a new root file, filling
  // it with the trees from 'fname'.
  const int Ntrees = trees.size();
  TChain* ch[Ntrees];

  Long64_t nentries = 0;
  for(int i = 0; i < Ntrees; ++i){
    ch[i] = new TChain(trees[i]);
    ch[i]->Add(fname);
    std::cout << "Tree loaded : " << trees[i] << std::endl;
    std::cout << "Entries : " << ch[i]->GetEntries() << std::endl;

    // If the number of entries in this tree is different from other
    // trees there is a problem. Quit and inform the user without
    // producing output.
    if(failOnError)
    {
      if(strcmp(trees[i],"HiForest/HiForestVersion") == 0) continue;
      if(i == 0) nentries = ch[i]->GetEntries();
      else if (nentries != ch[i]->GetEntries())
      {
	std::cout << "ERROR: number of entries in this tree does not match." << std::endl;
	std::cout << "Exiting. Please check input." << std::endl;
	return;
      }
    }
    else
    {
      std::cout << "WARN: error checking disabled" << std::endl;
    }
  }

  TFile* file = new TFile(outfile, "RECREATE");

  for(int i = 0; i < Ntrees; ++i)
  {
    file->cd();
    std::cout << trees[i] << std::endl;
    if (i==0)
    {
      file->mkdir(dir[i])->cd();
    }
    else
    {
      if ( dir[i] != dir[i-1] )
  	file->mkdir(dir[i])->cd();
      else
  	file->cd(dir[i]);
    }
    ch[i]->Merge(file,0,"keep");
    delete ch[i];
  }
  //file->Write();
  file->Close();

  std::cout << "Done. Output: " << outfile << std::endl;
}

int main(int argc, char *argv[])
{
  if((argc != 3) && (argc != 4))
  {
    std::cout << "Usage: mergeForest <input_collection> <output_file>" << std::endl;
    return 1;
  }
  
  if(argc == 3)
    mergeForest(argv[1], argv[2]);
  else if (argc == 4)
    mergeForest(argv[1], argv[2], argv[3]);
  return 0;
}
