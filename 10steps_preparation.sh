#$ -S /bin/sh
#$ -V
#$ -q all.q@pdis17
#$ -j y
#$ -o preparation.o
#$ -cwd
#$ -N preparation

if [ ! -d step01_initial_minimization_of_mobile_molecules ]; then
    mkdir step01_initial_minimization_of_mobile_molecules
fi

if [ ! -f step01_initial_minimization_of_mobile_molecules/initial_minimization_of_mobile_molecules.gro ]; then
    cd step01_initial_minimization_of_mobile_molecules

    cp -r ../input/topol_restraint_LARGE.top .

    echo "not name \"H*\"" > heavy_atom.txt

    for mol in `grep LARGE ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d select   -f ../input/${mol}.pdb -s ../input/${mol}.pdb -sf heavy_atom.txt -on ${mol}-H.ndx
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;5.0*418.4" | bc)
    done

    gmx_mpi_d grompp \
    	-f  ../input/step01_initial_minimization_of_mobile_molecules.mdp \
    	-p  topol_restraint_LARGE.top \
    	-c  ../input/initial.gro \
    	-r  ../input/initial.gro \
    	-o  initial_minimization_of_mobile_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm initial_minimization_of_mobile_molecules

    cd ..
fi

if [ ! -d step02_initial_relaxzation_of_mobile_molecules ]; then
    mkdir step02_initial_relaxzation_of_mobile_molecules
fi

if [ ! -f step02_initial_relaxzation_of_mobile_molecules/initial_relaxzation_of_mobile_molecules.gro ]; then
    cd step02_initial_relaxzation_of_mobile_molecules
    
    gmx_mpi_d grompp \
    	-f  ../input/step02_initial_relaxzation_of_mobile_molecules.mdp \
    	-p  ../step01_initial_minimization_of_mobile_molecules/topol_restraint_LARGE.top \
    	-c  ../step01_initial_minimization_of_mobile_molecules/initial_minimization_of_mobile_molecules.gro \
    	-r  ../input/initial.gro \
    	-o  initial_relaxzation_of_mobile_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm initial_relaxzation_of_mobile_molecules

    cd ..
fi

if [ ! -d step03_initial_minimization_of_large_molecules ]; then
    mkdir step03_initial_minimization_of_large_molecules
fi

if [ ! -f step03_initial_minimization_of_large_molecules/initial_minimization_of_large_molecules.gro ]; then
    cd step03_initial_minimization_of_large_molecules

    cp -r ../input/topol_restraint_LARGE.top  .

    for mol in `grep LARGE ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ../step01_initial_minimization_of_mobile_molecules/${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;2.0*418.4" | bc)
    done
    
    gmx_mpi_d grompp \
    	-f  ../input/step03_initial_minimization_of_large_molecules.mdp \
    	-p  topol_restraint_LARGE.top \
    	-c  ../step02_initial_relaxzation_of_mobile_molecules/initial_relaxzation_of_mobile_molecules.gro \
    	-r  ../input/initial.gro \
    	-o  initial_minimization_of_large_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm initial_minimization_of_large_molecules

    cd ..
fi

if [ ! -d step04_continued_minimization_of_large_molecules ]; then
    mkdir step04_continued_minimization_of_large_molecules
fi

if [ ! -f step04_continued_minimization_of_large_molecules/continued_minimization_of_large_molecules.gro ]; then
    cd step04_continued_minimization_of_large_molecules

    cp -r ../input/topol_restraint_LARGE.top  .
    
    for mol in `grep LARGE ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ../step01_initial_minimization_of_mobile_molecules/${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;0.1*418.4" | bc)
    done
    
    gmx_mpi_d grompp \
    	-f  ../input/step04_continued_minimization_of_large_molecules.mdp \
    	-p  topol_restraint_LARGE.top \
    	-c  ../step03_initial_minimization_of_large_molecules/initial_minimization_of_large_molecules.gro \
    	-r  ../input/initial.gro \
    	-o  continued_minimization_of_large_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm continued_minimization_of_large_molecules

    cd ..
fi

if [ ! -d step05_final_minimization_of_system ]; then
    mkdir step05_final_minimization_of_system
fi

if [ ! -f step05_final_minimization_of_system/final_minimization_of_system.gro ]; then
    cd step05_final_minimization_of_system

    gmx_mpi_d grompp \
    	-f  ../input/step05_final_minimization_of_system.mdp \
    	-p  ../input/topol.top \
    	-c  ../step04_continued_minimization_of_large_molecules/continued_minimization_of_large_molecules.gro \
    	-r  ../input/initial.gro \
    	-o  final_minimization_of_system.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm final_minimization_of_system

    cd ..
fi

if [ ! -d step06_initial_relaxzation_of_large_molecules ]; then
    mkdir step06_initial_relaxzation_of_large_molecules
fi

if [ ! -f step06_initial_relaxzation_of_large_molecules/initial_relaxzation_of_large_molecules.gro ]; then
    cd step06_initial_relaxzation_of_large_molecules

    for mol in `grep LARGE ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ../step01_initial_minimization_of_mobile_molecules/${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;1.0*418.4" | bc)
    done

    gmx_mpi_d grompp \
    	-f  ../input/step06_initial_relaxzation_of_large_molecules.mdp \
    	-p  ../input/topol.top \
    	-c  ../step05_final_minimization_of_system/final_minimization_of_system.gro \
    	-r  ../step05_final_minimization_of_system/final_minimization_of_system.gro \
    	-o  initial_relaxzation_of_large_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm initial_relaxzation_of_large_molecules

    cd ..
fi

if [ ! -d step07_continued_relaxzation_of_large_molecules ]; then
    mkdir step07_continued_relaxzation_of_large_molecules
fi

if [ ! -f step07_continued_relaxzation_of_large_molecules/continued_relaxzation_of_large_molecules.gro ]; then
    cd step07_continued_relaxzation_of_large_molecules

    cp -r ../input/topol_restraint_LARGE.top  .

    for mol in `grep LARGE ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ../step01_initial_minimization_of_mobile_molecules/${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;0.5*418.4" | bc)
    done

    gmx_mpi_d grompp \
    	-f  ../input/step07_continued_relaxzation_of_large_molecules.mdp \
    	-p  topol_restraint_LARGE.top \
    	-c  ../step06_initial_relaxzation_of_large_molecules/initial_relaxzation_of_large_molecules.gro \
    	-r  ../step05_final_minimization_of_system/final_minimization_of_system.gro \
    	-o  continued_relaxzation_of_large_molecules.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm continued_relaxzation_of_large_molecules
    
    cd ..
fi

if [ ! -d step08_relaxzation_of_non-backbone_atoms ]; then
    mkdir step08_relaxzation_of_non-backbone_atoms
fi

if [ ! -f step08_relaxzation_of_non-backbone_atoms/relaxzation_of_non-backbone_atoms.gro ]; then
    cd step08_relaxzation_of_non-backbone_atoms

    cp -r ../input/topol_restraint_backbone.top  .

    echo "group \"backbone\" and not name \"H*\"" > back_bone_heavy_atom.txt
    echo "not name \"H*\"" > heavy_atom.txt

    for mol in `grep PROTEIN ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d select -f ../input/${mol}.pdb -s ../input/${mol}.pdb -sf back_bone_heavy_atom.txt -on ${mol}-backbone-H.ndx
    done
	
    for mol in `grep PROTEIN ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ${mol}-backbone-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;0.5*418.4" | bc)
    done

    for mol in `grep LIPID ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d select -f ../input/${mol}.pdb -s ../input/${mol}.pdb -sf heavy_atom.txt -on ${mol}-H.ndx
    done

    for mol in `grep LIPID ../input/system.txt | awk '{print \$1}'`; do
	gmx_mpi_d genrestr -f ../input/${mol}.pdb -n ${mol}-H.ndx -o ${mol}_restraint.itp -fc $(echo "scale=2.0;0.5*418.4" | bc)
    done

    gmx_mpi_d grompp \
    	-f  ../input/step08_relaxzation_of_non-backbone_atoms.mdp \
    	-p  topol_restraint_backbone.top \
    	-c  ../step07_continued_relaxzation_of_large_molecules/continued_relaxzation_of_large_molecules.gro \
    	-r  ../step05_final_minimization_of_system/final_minimization_of_system.gro \
    	-o  relaxzation_of_non-backbone_atoms.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm relaxzation_of_non-backbone_atoms
    
    cd ..
fi

if [ ! -d step09_unrestrained_relaxzation ]; then
    mkdir step09_unrestrained_relaxzation
fi

if [ ! -f step09_unrestrained_relaxzation/unrestrained_relaxzation.gro ]; then
    cd step09_unrestrained_relaxzation

    gmx_mpi_d grompp \
    	-f  ../input/step09_unrestrained_relaxzation.mdp \
    	-p  ../input/topol.top \
	-c  ../step08_relaxzation_of_non-backbone_atoms/relaxzation_of_non-backbone_atoms.gro \
    	-o  unrestrained_relaxzation.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm unrestrained_relaxzation

    cd ..
fi

if [ ! -d step10_final_density_stabilization ]; then
    mkdir step10_final_density_stabilization
fi

if [ ! -f step10_final_density_stabilization/final_density_stabilization_dt2fs.gro ]; then
    cd step10_final_density_stabilization

    gmx_mpi_d grompp \
    	-f  ../input/step10-1_final_density_stabilization.mdp \
    	-p  ../input/topol.top \
    	-c  ../step09_unrestrained_relaxzation/unrestrained_relaxzation.gro \
    	-o  final_density_stabilization_dt2fs.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm final_density_stabilization_dt2fs
    
    cd ..
fi

if [ ! -f step10_final_density_stabilization/final_density_stabilization_dt3fs.gro ]; then
    cd step10_final_density_stabilization

    gmx_mpi_d grompp \
    	-f  ../input/step10-2_final_density_stabilization.mdp \
    	-p  ../input/topol.top \
    	-c  final_density_stabilization_dt2fs.gro \
    	-o  final_density_stabilization_dt3fs.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm final_density_stabilization_dt3fs

    cd ..
fi

if [ ! -f step10_final_density_stabilization/final_density_stabilization.gro ]; then
    cd step10_final_density_stabilization

    gmx_mpi_d grompp -maxwarn 1 \
    	-f  ../input/step10-3_final_density_stabilization.mdp \
    	-p  ../input/topol.top \
    	-c  final_density_stabilization_dt3fs.gro \
    	-o  final_density_stabilization.tpr

    mpirun  -np 32 \
    	gmx_mpi_d mdrun -deffnm final_density_stabilization

    cd ..
fi
