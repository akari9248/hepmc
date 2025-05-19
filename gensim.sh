#!/bin/bash

set -e
echo "gen-sim cmsenv: $1"
echo "filein: $5"
echo "randomnum: $6"
# TODO: check that you have exactly 3 arguments
cd $1
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd -
echo "Begin gensim"
cmsRun gensim.py inputFiles="file:$5" outputFile="file:gensim-S$6.root"
echo "End gensim"

echo "hlt & reco cmsenv: $2"
cd $2
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd -
echo "Begin hlt"
cmsRun hlt.py inputFiles="file:gensim-S$6.root" outputFile="file:hlt-S$6.root"
echo "End hlt"
echo "Begin reco"
cmsRun reco.py inputFiles="file:hlt-S$6.root" outputFile="file:reco-S$6.root"
echo "End reco"

echo "pat cmsenv: $3"
cd $3
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd -
echo "Begin pat"
cmsRun pat.py inputFiles="file:reco-S$6.root" outputFile="file:pat-S$6.root"
echo "End pat"

echo "jetsinfo cmsenv: $4"
cd $4
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd -
echo "Begin jetsinfo"
cmsRun getinfo.py -i "file:pat-S$6.root" -o "file:jetsinfo-S$6.root" -d "/QCD_Pt-15to7000_TuneCH3_Flat_13p6TeV_herwig7/Run3Summer22EEMiniAODv4-130X_mcRun3_2022_realistic_postEE_v6-v2/MINIAODSIM"
echo "End jetsinfo"
