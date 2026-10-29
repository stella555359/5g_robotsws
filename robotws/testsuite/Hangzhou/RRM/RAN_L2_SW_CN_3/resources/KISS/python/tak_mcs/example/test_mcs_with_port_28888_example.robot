*** Settings ***
Resource     ../../../robot/common_resource.robot

Suite Setup         MCS Setup step
Suite Teardown      MCS Teardown

*** Variables ***
${host_ip}        10.106.168.43
${device_ip}      192.168.0.241
${mcs_port}       28888
${username}       Sg11-tester    
${password}       Nokia123!
${prompt}         >
${msg}            Please select right calibration file name from 'Mcs Get Calibration File Name' and set it to 'MCS Set Frequency'

*** Test Cases ***
Test Get Calibratio File Name Example
    ${Calibr_files}=     Mcs Get Calibration File Name
	Log    Please select one Calibration File name, and set it to MCS using "MCS Set Frequency"    WARN
	
	
Test MCS Set Phase Example
    ${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency       3500_1_ALL     
    ${phase}=     Create Dictionary     A1B1=5.625        A1B2=11.25
    MCS Set Phase      phase=${phase}

Test MCS Set Phase By Port Example	
    ${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL 
    MCS Set Phase By Port	     port=1,2    angle_h=0    angle_v=30
	
Test MCS Set Phase from CSV Example
    ${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency       3500_1_ALL 
    MCS Set Phase       phase=phase.csv

Test MCS Set Attenuation Example	
	${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL
	${att}=    Create Dictionary      A1B1=1            A1B2=10
    MCS Set Attenuation        ${att}

Test MCS Set Attenuation By Port Example	
	${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL
	${att}=    Create Dictionary      A1B1=1            A1B2=10
    MCS Set Attenuation By Port       port=1,2    att_odd=10      att_even=90
	
Test MCS Set Attenuation from CSV Example	
	${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL
	Mcs Set Attenuation    att.csv

Test MCS Set Channel Phase And Attenuation Example
    ${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL
	${phase_att}=    Create Dictionary      A1B1=1,5.6            A1B2=4,11.25
    MCS Set Channel Phase And Attenuation       att_phase=${phase_att}

Test MCS Set Channel Phase And Attenuation from CSV Example
    ${usage_info}=    Mcs Get Resource Usage Info
	Mcs Apply Channel For Resource    1,2,3,4
    Run Keyword And Expect Error     ${msg}     MCS Set Frequency      3500_1_ALL
    MCS Set Channel Phase And Attenuation       att_phase=phase_att.csv
	
*** Keywords ***
MCS Setup step
    MCS Setup       host_ip=${host_ip}      device_ip=${device_ip}    mcs_port=${mcs_port}
    ...    username=${username}       password=${password}     prompt=${prompt}


