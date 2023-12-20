#!/bin/sh

if [ ! -d PDB01 ]; then
    mkdir PDB01
fi

cd PDB01


if [ ! -f 1be9.pdb ]; then
    wget http://files.rcsb.org/download/1be9.pdb.gz
    gunzip 1be9.pdb.gz
fi

cat <<EOF > cut.awk
#!/usr/bin/gawk -f

BEGIN{
    FIELDWIDTHS = "6 5 1 4 1 3 1 1 4 1 3 8 8 8 6 6 6 4"
}

(\$1~/ATOM/ && \$8~/A/ && (\$9 >= 306 && \$9 <= 415)) || (\$1~/ATOM/ && \$8~/B/) || (\$1 ~/TER/){
    print \$0
}
EOF

gawk -f cut.awk 1be9.pdb > 1be9_f306t415.pdb

#REMARK 470 MISSING ATOM                                                         
#REMARK 470   M RES CSSEQI  ATOMS                                                
#REMARK 470     PHE A 301    CG   CD1  CD2  CE1  CE2  CZ                         
#REMARK 470     ASP A 332    CG   OD1  OD2                                       
#REMARK 470     LYS B   5    CG   CD   CE   NZ                                   

cat <<EOF > seq_holo.txt
dipreprrivihrgstglgfniiggeDgegifisfilaggpadlsgelrkgdqilsvngvdlrnasheqaaialknagqtvtiiaqykpeeysrfeansrvnssgrivtn
Kqtsv
EOF

~/opt/bin/Scwrl4 -s seq_holo.txt -i 1be9_f306t415.pdb -o PDZ3_holo.pdb

if [ ! -f 1bfe.pdb ]; then
    wget http://files.rcsb.org/download/1bfe.pdb.gz
    gunzip 1bfe.pdb.gz
fi

gawk -f cut.awk 1bfe.pdb > 1bfe_f306t415.pdb

#REMARK 470 MISSING ATOM                                                         
#REMARK 470     ASP A 306    CG   OD1  OD2                                       
#REMARK 470     ASP A 332    CG   OD1  OD2                                       

cat <<EOF > seq_apo.txt
DipreprrivihrgstglgfniiggeDgegifisfilaggpadlsgelrkgdqilsvngvdlrnasheqaaialknagqtvtiiaqykpeeysrfeansrvnssgrivtn
EOF

~/opt/bin/Scwrl4 -s seq_apo.txt -i 1bfe_f306t415.pdb -o PDZ3_apo.pdb

