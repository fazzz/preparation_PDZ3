#!/bin/sh

# The constituion of ions are determined by SLTCAP server.

if [ ! -d WAT03 ]; then
    printf "There is no WART03 DO solvWAT03"
    exit
fi

cd WAT03

cat <<EOF > ion.mdp
; Run Parameters
define=-DFLEXIBLE
integrator=steep
nsteps=5000

; Energy minimization parameters
emtol=100.0
emstep=0.01

; Bond Parameters
constraints=none

; Neiborserching
cutoff-scheme=verlet
nstlist=1
ns_type=grid
rlist=1.2

; VdW
vdw-modifier=Potential-switch
rvdw=1.2
rvdw-switch=1.0
DispCorr=No

; Electrostatic
coulombtype=pme
rcoulomb=1.2

; Periodic Boundary conditions
pbc=xyz

; PME parameters
pme_order=4
ewald_rtol=1.0e-5
fourier-nx=96
fourier-ny=96
fourier-nz=96
EOF

#################################################

gmx grompp \
    -maxwarn 1 \
    -f ion.mdp \
    -c PDZ3_holo.gro \
    -p PDZ3_holo.top \
    -o ion.tpr
    
gmx genion \
    -s ion.tpr \
    -o PDZ3_holo.gro \
    -p PDZ3_holo.top \
    -pname NA -np 23 \
    -nname CL -nn 23

#################################################

gmx grompp \
    -maxwarn 1 \
    -f ion.mdp \
    -c PDZ3_apo.gro \
    -p PDZ3_apo.top \
    -o ion.tpr

gmx genion \
    -s ion.tpr \
    -o PDZ3_apo.gro \
    -p PDZ3_apo.top \
    -pname NA -np 22 \
    -nname CL -nn 21











