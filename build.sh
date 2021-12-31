#!/bin/bash

set -e
source cfg/project.sh

mkdir -p build

echo "Synthesis..."
yosys -q -s "scripts/synth.s"

# echo "Render netlist"
# netlistsvg build/top.json build/top.svg

echo "Place & route..."
nextpnr-ecp5 \
  --quiet \
  --json build/top.json \
  --textcfg build/out.config \
  --um5g-85k --package CABGA381 \
  --lpf cfg/ecp5evn.lpf \
  --top "${TOP}" \
  --freq "${TARGET_FREQ}" \
  --placed-svg "build/placed.svg" \
  --routed-svg "build/routed.svg" \
  --report "build/routing-report.json"

echo "fmax: $(jq '.fmax[].achieved' build/routing-report.json) MHz"

echo "Create bit stream..."
ecppack  \
  --svf build/top.svf \
  build/out.config \
  build/top.bit

echo "Done."