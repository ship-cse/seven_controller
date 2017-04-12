@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xsim sim_bcdmode_behav -key {Behavioral:sim_1:Functional:sim_bcdmode} -tclbatch sim_bcdmode.tcl -view C:/vivado/cmpe420/seven_controller/sim_bcdmode_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
