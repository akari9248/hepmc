#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: Please specify number of random values"
    echo "Usage: $0 <number>"
    exit 1
fi

n=$1
dir=$2
eventsnum=$3
> random_numbers.txt
> inhepmc.txt
> inpat.txt

for ((i=0; i<n; i++)); do
    r=$(shuf -i 1-900000000 -n 1)
    hepmcfile="FlatQCD-TuneCH3-AngularCluster13TeV6HepMC-S$r.hepmc"
    gensimfile="gensim-S$r"
    hltfile="hlt-S$r"
    recofile="reco-S$r"
    miniaodfile="pat-S$r.root"

    echo $r $eventsnum >> random_numbers.txt
    # echo "${dir}/Chunk${i}/FlatQCD-TuneCH3-AngularCluster13TeV6HepMC-S$r.hepmc ${dir}/Chunk${i}/gensim-S$r.root" >> inhepmc.txt
    echo "${dir}/Chunk${i}/${hepmcfile} $r" >> inhepmc.txt
    echo "${dir}/Chunk${i}/${miniaodfile} $r" >> inpat.txt
    # echo "${dir}/Chunk${i}/Fla hlt-S$r" >> inhepmc.txt
done
