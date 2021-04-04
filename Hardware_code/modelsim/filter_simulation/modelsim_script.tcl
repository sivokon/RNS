vlib work
set p1 +define+SIMULATION

# dirs where to search for files
set d0 +incdir+../../../src
set d1 +incdir+../../../src/*
set d2 +incdir+../
# files to compile
set f0 ../../../src/*.sv
set f1 ../../../src/*/*.sv
set f2 ../testbench.sv

vlog $p1  $d0 $d1 $d2   $f0 $f1 $f2
vsim work.testbench
add wave -radix decimal -recursive *
run -all
wave zoom full