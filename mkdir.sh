#!/bin/bash
eos mkdir $1
for i in {0..$2}; do
  eos mkdir $1/Chunk$i
done
