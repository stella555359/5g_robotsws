*** Settings ***
Documentation
...    This is the common resource file for VRF_HAZ1 all teams.
...    In this file, we import the basic level libraries and define the basic level global variables for all teams.

Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             String
Library             Telnet

############# Module ######################
Resource          ./Module/Module.robot
Resource          ./CERTA_Module/CERTA_Module.robot
############# SISO+OAM Resources ##########
Resource          ./SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Resource          ./SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ./SISO_OAM/siso_resources/test_fv.robot
