#!/bin/sh

if [ ! -f TOP02 ]; then
    mkdir TOP02
fi

cd TOP02

gmx pdb2gmx \
    -f ../PDB01/PDZ3_holo.pdb \
    -ff amber03 \
    -water tip3p \
    -ignh -heavyh -vsite hydrogens \
    -o PDZ3_holo.gro \
    -p PDZ3_holo.top

gmx pdb2gmx \
    -f ../PDB01/PDZ3_apo.pdb \
    -ff amber03 \
    -water tip3p \
    -ignh -heavyh -vsite hydrogens \
    -o PDZ3_apo.gro \
    -p PDZ3_apo.top

