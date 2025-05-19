#!/bin/bash
chunk=$1
seed=$2
num=$3
target_dir="/eos/cms/store/group/phys_smp/ec/shuangyu/AngularCluster13TeV6HepMC_0_spinoff_600_800_730_950/Chunk${chunk}"

echo "Begin hepmc"
echo "singularity run" 
echo "Chunk"${chunk} 
echo "random seed: "${seed}
echo "output: root://eoscms.cern.ch/"${target_dir}

Herwig --version
echo $PWD
Herwig run --seed=${seed} $4 -N $3
mv *.hepmc FlatQCD-TuneCH3-AngularCluster13TeV6HepMC-S${seed}.hepmc

ls
echo "End hepmc"


