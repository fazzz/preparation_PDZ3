#$ -S /bin/sh

gmx_d energy \
    -f step10_final_density_stabilization/final_density_stabilization.edr \
    -s step10_final_density_stabilization/final_density_stabilization.tpr \
    -o step10_final_density_stabilization/density.xvg

awk '($1 !~ /^(\#|\@)/) {printf("%8.3f %8.3f\n", $1, $2/100)}' \
      step10_final_density_stabilization/density.xvg \
    > step10_final_density_stabilization/density.txt

n=$( wc -l step10_final_density_stabilization/density.txt | awk '{print $1}' )
n_1p=`expr ${n} / 100`
n_half=`expr ${n} / 2`

DI=$( head -${n_1p} step10_final_density_stabilization/density.txt | awk 'BEGIN{ave=0.0;}{ave=ave+$2;}END{ave=ave/NR;print ave}' )
DF=$( tail -${n_half} step10_final_density_stabilization/density.txt | awk 'BEGIN{ave=0.0;}{ave=ave+$2;}END{ave=ave/NR;print ave}' )

half=$( head -${n_half} step10_final_density_stabilization/density.txt | tail -1 | awk '{print $1}' )
finl=$( tail -1 step10_final_density_stabilization/density.txt | awk '{print $1}' )

cat <<EOF > density_stability.gp
#!/home/yamamori/opt/bin/gnuplot

set terminal postscript enhanced background rgb 'white' color size 12cm , 12cm  "Times" 14
set output "density.eps"

set encoding iso_8859_1
set tics out

set tics font "Times-Roman,10"
set xlabel font "Times-Roman,14"
set ylabel font "Times-Roman,14"
set label font "Times-Roman,14"
set key font "Times-Roman,10"

set xlabel "Time (ps)"
set ylabel "System Density (g/cm^{3})"

D(x) = DI + ((DF-DI) * (1.0 - exp(-1.0 * k * x)))
DI = ${DI}
DF = ${DF}
k  = 0.0001

fit D(x) "step10_final_density_stabilization/density.txt" u 1:2 via DI, DF, k

f(x) = a * x + b
a = 0.00001
b = ${DF}

fit [${half}:${finl}] f(x) "step10_final_density_stabilization/density.txt" u 1:2 via a, b

set yrange [9.4:10.2]

set format y "%4.2f"
plot "step10_final_density_stabilization/density.txt" u 1:2 w p ps 0.5 pt 7 lc rgb "black" notitle, \
     D(x) w l lt 1 lw 2.0 lc rgb "red" title "D_{I} + ((D_{F}-D_{I}) * (1.0- exp(-k t)))"

quit
EOF

chmod +x density_stability.gp
./density_stability.gp
