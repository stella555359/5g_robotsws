*** Settings ***
Resource     ../../../robot/common_resource.robot
Suite Setup         MCS Setup step
Suite Teardown      MCS Teardown

*** Variables ***
${host_ip}        10.106.168.43
${device_ip}      192.168.0.241
${mcs_port}       18888
${db_path}        C:\\CSN30018040037_2600_1_ALL.db
${username}       Sg11-tester    
${password}       Nokia123!
${prompt}         >

*** Test Cases ***
Test MCS Read IDN and HW Version Example
    ${idn}=    MCS query idn
    ${hw_version}=     MCS Query HW Version
    ${calbd_freq}=     MCS Query Calibrated Frequency

Test MCS Set Frequency and Query Frequency Example
    MCS Set Frequency       frequency=2600
    MCS Query In Use Frequency

Test MCS Set phase Example
    MCS Set Frequency       frequency=2600
    ${phase}=     Create Dictionary     A1B1=5.625        A1B2=11.25
    MCS Set Phase      phase=${phase}

Test MCS Set phase By Port Example
    MCS Set Frequency       frequency=2600
    Mcs Set Phase By Port    port=1    angle_h=-20    angle_v=30
	
Test MCS Set phase with csv Example
    MCS Set Frequency       frequency=2600
    MCS Set Phase      phase=phase.csv

Test MCS Set Attenuation Example
    MCS Set Frequency       frequency=2600
    ${att}=    Create Dictionary      A1B1=1            A1B2=10
    MCS Set Attenuation        ${att}

Test MCS Set Attenuation By Port Example
    MCS Set Frequency       frequency=2600
    Mcs Set Attenuation By Port     port=1    att_odd=10    att_even=90

Test MCS Set Attenuation with csv Example
    MCS Set Frequency       frequency=2600
    MCS Set Attenuation        att=att.csv

Test MCS Set Channel Phase And Attenuation Example
    MCS Set Frequency       frequency=2600
    ${phase_att}=    Create Dictionary      A1B1=1,5.6            A1B2=4,11.25
    MCS Set Channel Phase And Attenuation       att_phase=${phase_att}

Test MCS Query Channel Phase And Attenuation Example
    MCS Set Frequency       frequency=2600
    ${channel_info}=    MCS Query Channel Phase And Attenuation       channel=A1B1  
    Log        ${channel_info}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation       channel=ALL 
    Log       ${all_channel_info}

Test MCS Query Error Info Example
    MCS Read Error Info


*** Keywords ***
MCS Setup step
    MCS Setup       host_ip=${host_ip}      device_ip=${device_ip}    db_path=${db_path}
    ...    mcs_port=${mcs_port}    username=${username}       password=${password}     prompt=${prompt}


