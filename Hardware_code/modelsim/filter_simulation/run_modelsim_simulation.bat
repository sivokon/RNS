filter_input_data_generator.exe input_signal.txt signal.txt signal_rns.txt
filter_input_data_generator.exe input_coefs.txt coefs.txt coefs_rns.txt
rd /s /q simulation_temp
md simulation_temp
copy coefs.txt simulation_temp
copy coefs_rns.txt simulation_temp
copy signal.txt simulation_temp
copy signal_rns.txt simulation_temp
cd simulation_temp
vsim -novopt -do ../modelsim_script.tcl
cd ..
