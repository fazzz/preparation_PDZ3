#!/bin/sh

if [ ! -f WAT03 ]; then
    mkdir WAT03
fi

cd WAT03

gmx editconf \
    -f ../TOP02/PDZ3_holo.gro \
    -c -bt cubic \
    -d 1 \
    -o PDZ3_holo_box.gro

cp ../TOP02/PDZ3_holo.top PDZ3_holo.top
cp ../TOP02/*.itp .

gmx solvate \
    -cp PDZ3_holo_box.gro \
    -cs spc216.gro \
    -p  PDZ3_holo.top \
    -o  PDZ3_holo.gro

gmx editconf \
    -f ../TOP02/PDZ3_apo.gro \
    -c -bt cubic \
    -d 1 \
    -o PDZ3_apo_box.gro

cp ../TOP02/PDZ3_apo.top PDZ3_apo.top

gmx solvate \
    -cp PDZ3_apo_box.gro \
    -cs spc216.gro \
    -p  PDZ3_apo.top \
    -o  PDZ3_apo.gro




