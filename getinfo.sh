#!/bin/bash

set -e
echo "filein: $2"
echo "randomnum: $3"
# TODO: check that you have exactly 3 arguments

echo "jetsinfo cmsenv: $1"
cd $1
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd -
echo "Begin jetsinfo"
cmsRun getinfo.py -i "file:$2" -o "file:jetsinfo-S$3.root" -d "/QCD_Pt-15to7000_TuneCH3_Flat_13p6TeV_herwig7/Run3Summer22EEMiniAODv4-130X_mcRun3_2022_realistic_postEE_v6-v2/MINIAODSIM"
echo "End jetsinfo"
