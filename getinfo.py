"""
    ht_2016_data.py
    ~~~~~~~~~~~~~~~~~~~~~
    QCDAnalysis of QCD-HT 2016 ultra-legacy DATA, with JEC applied.
    :run: cmsRun test/ht_2016_data.py
    :author: Yulei Ye
    :email: yulei.ye@cern.ch
"""

import FWCore.ParameterSet.Config as cms
from QCDAnalysis.AnalysisStep.jetsCleaner_cfi import *
import QCDAnalysis.AnalysisStep.helper as helper
import argparse

######## define input parameter ########
def parse_arguments():
    parser = argparse.ArgumentParser(description='QCD Analysis Configuration')
    parser.add_argument('-n', '--nevent', type=int, default=-1,
                       help='Number of events to analyze (-1 for all)')
    parser.add_argument('-y', '--year', type=int, default=2022,
                       help='Year for JEC/JER configuration (e.g. 2022)')
    parser.add_argument('--is_mc', type=lambda x: (str(x).lower() == 'true'), default=True,
                       help='Is Monte-Carlo simulation (True/False)')
    parser.add_argument('--is_ul', type=lambda x: (str(x).lower() == 'true'), default=True,
                       help='Ultra Legacy flag (True/False)')
    parser.add_argument('-d', '--dataset', type=str,
                       default='/QCD_Pt-15to7000_TuneCH3_Flat_13TeV_herwig7/RunIISummer20UL18MiniAODv2-106X_upgrade2018_realistic_v16_L1v1-v2/MINIAODSIM',
                       help='Dataset name')
    parser.add_argument('-i', '--input', type=str,
                       default='root://xrootd-cms.infn.it//store/data/Run2016G/JetHT/MINIAOD/UL2016_MiniAODv2-v2/270000/9A63680F-CC9F-D345-94D3-D8ED6111F031.root',
                       help='Input root file path')
    parser.add_argument('-o', '--output', type=str,
                       default='Jet_Infos.root',
                       help='Output root file name')
    return parser.parse_args()
args = parse_arguments()

######## user defined variables ########
nevent = args.nevent
year = args.year
is_mc = args.is_mc
is_ul = args.is_ul
dataset_name = args.dataset
inroot = args.input
outroot = args.output
print(year)
print(is_mc)
print(is_ul)
print(dataset_name)
########################################

######## standard qcd analysis process ########
from QCDAnalysis.AnalysisStep.process_cfi import get_process, get_args
dataset = helper.get_dataset(dataset_name)
process = get_process(nevent, inroot, outroot, dataset)
###############################################

