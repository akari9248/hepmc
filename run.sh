#!/usr/bin/bash

chunknum=1000
events=1000
baseoutput="/eos/cms/store/group/phys_smp/ec/shuangyu"
ptmin=600
ptmax=800
spin="on"
output="cms"

for arg in "$@"; do
    key="${arg%%=*}"
    value="${arg#*=}"
    case "$key" in
        chunknum|events|baseoutput|ptmin|ptmax|spin|output)
            declare "$key=$value"
            ;;
        *)
            echo "unknown: $key"
            exit 1
            ;;
    esac
done

echo "  chunknum  = $chunknum"
echo "  events    = $events"
echo "  baseoutput= $baseoutput"
echo "  ptmin     = $ptmin"
echo "  ptmax     = $ptmax"
echo "  spin      = $spin"
echo "  cms       = $output"

########## update grid #########
voms-proxy-init -voms cms -rfc -out x509up

########## common setting #########
samplename="Run3Summer22EE_13TeV6_0_spin${spin}_${ptmin}_${ptmax}_730_950"
outputDir="${baseoutput}/${samplename}"
ext=1
while [ -d "$outputDir" ]; do
  outputDir="${baseoutput}/${samplename}_ext$ext"
  ext=$((ext + 1))
done

outputenv=""
if [[ "${output}" == "cms" ]]; then
   outputenv="root://eoscms.cern.ch/"
elif [[ "${output}" == "private" ]]; then
   outputenv="root://eosuser.cern.ch/"
fi

workDir=${PWD}
configname="FlatQCD-TuneCH3-AngularCluster13TeV6HepMC_spin${spin}_${ptmin}_${ptmax}"
herwiginfile="${configname}.in"
condor_hepmc_file="${workDir}/condor_hepmc.jdl"
condor_gensim_file="${workDir}/condor_gensim.jdl"
daginfile="${workDir}/workflow.dag"

########## sourece update file #########
source update_file_line.sh

########## herwig in file setting #########
cd herwigconfig
cp FlatQCD-TuneCH3-AngularCluster13TeV6HepMC.in ${herwiginfile}
# ptmin
update_file_line "${herwiginfile}" 98 "set /Herwig/Cuts/JetKtCut:MinKT ${ptmin}.*GeV"
# ptmax
update_file_line "${herwiginfile}" 100 "set /Herwig/Cuts/JetKtCut:MaxKT ${ptmax}.*GeV"
# events num
update_file_line "${herwiginfile}" 149 "set /Herwig/Analysis/HepMC:PrintEvent ${events}"
# spin on / off
if [[ "${spin}" == "on" ]]; then
    update_file_line "${herwiginfile}" 113 "set /Herwig/EventHandlers/EventHandler:CascadeHandler:SpinCorrelations Yes"
elif [[ "${spin}" == "off" ]]; then
    update_file_line "${herwiginfile}" 113 "set /Herwig/EventHandlers/EventHandler:CascadeHandler:SpinCorrelations No"    
fi
# save name
update_file_line "${herwiginfile}" 155 "saverun ${configname} EventGenerator"
# compile 
echo "compile herwig in file"
singularity run /afs/cern.ch/user/s/shuangyu/herwig730.sif Herwig read $herwiginfile
cd ..

########## get random num ##########
bash random.sh ${chunknum} ${outputDir} ${events}

########## condor setting ##########
update_file_line "$condor_hepmc_file" 13 "output_destination = ${outputenv}${outputDir}/Chunk\$(Process)"
update_file_line "$condor_hepmc_file" 12 "Transfer_Input_Files = herwigconfig/${configname}.run"
update_file_line "$condor_hepmc_file" 5 "arguments = \$(Process) \$(randomnum) \$(eventsnum) ${configname}.run"
update_file_line "$condor_gensim_file" 9 "output_destination = ${outputenv}${outputDir}/Chunk\$(Process)"

########## create output folder  ##########
if ! eos ls "$outputDir" &> /dev/null; then
    echo "Directory does not exist, creating: $outputDir"
    if ! eos mkdir -p "$outputDir"; then
        echo "[ERROR] Failed to create directory. Check permissions or storage quota."
        exit 1
    fi
else
    echo "Directory already exists: $outputDir"
fi

# existing_chunks=$(eos ls "$outputDir" | grep -E '^Chunk[0-9]+$' | wc -l)
# echo "Existing Chunk directories: $existing_chunks"
# start_index=$existing_chunks
# echo "Starting to create new chunks from index $start_index"

for ((i=0; i<chunknum; i++)); do
    # chunk_index=$((start_index + i))
    if ! eos ls "$outputDir/Chunk${i}" &> /dev/null; then
	    if (( i % 50 == 0 )); then
            echo "Directory creating: $outputDir/Chunk${i}"
        fi
        if ! eos mkdir -p "$outputDir/Chunk${i}"; then
	   echo "[ERROR] Failed to create directory. Check permissions or storage quota."
           exit 1
        fi
    # else
        # echo "Directory already exists: $outputDir/Chunk${i}"
    fi

    logDir="$outputDir/Chunk${i}/log"
    if ! eos mkdir -p "$logDir"; then
        echo "[ERROR] Failed to create log directory: $logDir"
	exit 1
    fi
done

########## run workflow.dag ##########
# mkdir -p ${samplename}
# cd ${samplename}
cp dag/workflow.dag workflow_spin${spin}_${ptmin}_${ptmax}.dag
rm  workflow_spin${spin}_${ptmin}_${ptmax}.dag.*
echo "running condor_submit_dag workflow_spin${spin}_${ptmin}_${ptmax}.dag"
condor_submit_dag workflow_spin${spin}_${ptmin}_${ptmax}.dag
