FilterDataGenerator.exe input_coefs.txt input_signal.txt
rd /s /q simulation_temp
md simulation_temp
copy output*.txt simulation_temp
cd simulation_temp
vsim -novopt -do ../modelsim_script.tcl
cd ..
