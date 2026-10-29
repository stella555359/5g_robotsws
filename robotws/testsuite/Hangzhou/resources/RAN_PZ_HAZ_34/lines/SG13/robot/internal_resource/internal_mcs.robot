*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com

*** Variables ***
${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time



*** Keywords ***

Obtain MCS Info
    @{mcs_related_ip}    get_mcs_related_ip    ${MCS_CONFIG_FILE}
    ${MCS_PC_IP}    Set Variable    ${mcs_related_ip[0]}
    ${MCS_IP}    Set Variable    ${mcs_related_ip[1]}
    ${MCS_DB_PATH}    Set Variable    ${mcs_related_ip[2]}
    ${MCS_PC_USERNAME}    Set Variable    ${mcs_related_ip[3]}
    ${MCS_PC_PWD}    Set Variable    ${mcs_related_ip[4]}
    Set Suite variable    ${MCS_PC_IP}
    Set Suite variable    ${MCS_IP}
    Set Suite variable    ${MCS_DB_PATH}
    Set Suite variable    ${MCS_PC_USERNAME}
    Set Suite variable    ${MCS_PC_PWD}

Set attenuation
    [Arguments]    ${att_csv}    ${frequency}=2600
    Obtain MCS Info
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    db_path=${MCS_DB_PATH}    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    MCS Set Frequency    frequency=${frequency}
    MCS Set Attenuation    ${att_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    MCS Teardown

Set phase
    [Arguments]    ${phase_csv}    ${frequency}=2600
    Obtain MCS Info
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    db_path=${MCS_DB_PATH}    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    MCS Set Frequency    frequency=${frequency}
    Mcs Set Phase    ${phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    MCS Teardown

Set Mcs Channel Phase And Attenuation
    [Arguments]    ${att_csv}    ${phase_csv}    ${frequency}=2600
    Obtain MCS Info
    ${name_ext}    Set Variable    .csv
    ${att_csv}    Catenate    SEPARATOR=    ${att_csv}    ${name_ext}
    ${phase_csv}=    Catenate    SEPARATOR=    ${phase_csv}    ${name_ext}
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    db_path=${MCS_DB_PATH}    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    MCS Set Frequency    frequency=${frequency}
    Mcs Set Attenuation    att=${att_csv}
    Mcs Set Phase    phase=${phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown

Set Mcs Channel Phase And Attenuation same time
    [Arguments]    ${att_phase_csv}      ${frequency}=2600    ${is_set_freq}=False
    Obtain MCS Info
    ${name_ext}    Set Variable    .csv
    ${att_csv}    Catenate    SEPARATOR=    ${att_csv}    ${name_ext}
    ${phase_csv}=    Catenate    SEPARATOR=    ${phase_csv}    ${name_ext}
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    Run Keyword If  ${is_set_freq}    MCS Set Frequency    frequency=${frequency}
    Mcs Set Channel Phase And Attenuation   att_phase=${att_phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown

Set attenuation into GAP
    Set mcs attenuation    ${CONFIG_DIR_PATH}/qualcomm_config/189-att10.csv    ${HOST1_IP}    ${DEVICE1_IP}    ${DB1_PATH}
    Set mcs attenuation    ${CONFIG_DIR_PATH}/qualcomm_config/188-att10.csv    ${HOST2_IP}    ${DEVICE2_IP}    ${DB2_PATH}


Set Mcs3 Channel Phase And Attenuation
    [Arguments]    ${att_name}    ${phase_name}    ${frequency}=3550_1_ALL    ${is_set_freq}=False
    Obtain MCS Info
    ${name_ext}    Set Variable    .csv
    ${att_csv}    Catenate    SEPARATOR=    ${att_name}    ${name_ext}
    ${phase_csv}=    Catenate    SEPARATOR=    ${phase_name}    ${name_ext}
	copy_file    ${att_name}    ${att_csv}
    copy_file    ${phase_name}    ${phase_csv}
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    ...    mcs_port=28888
    ${version}    MCS Query Idn
    log    ${version}
    ${file_name}    Mcs Get Calibration File Name
    log    ${file_name}
    MCS Apply Channel For Resource    1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16
    Run Keyword If  ${is_set_freq}    MCS Set Frequency    frequency=${frequency}
    Mcs Set Attenuation    att=${att_csv}
    Mcs Set Phase    phase=${phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown

Set Mcs3 Phase And Attenuation by CSV
    [Arguments]    ${att_csv}    ${phase_csv}    ${frequency}=2600_1_ALL    ${is_set_freq}=False
    Obtain MCS Info
    MCS Setup    host_ip=${MCS_PC_IP}    device_ip=${MCS_IP}    mcs_port=28888    username=${MCS_PC_USERNAME}    password=${MCS_PC_PWD}
    MCS Get Calibration File Name
    Mcs Apply Channel For Resource    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
    Run Keyword If  ${is_set_freq}    MCS Set Frequency    frequency=${frequency}
    Mcs Set Attenuation    att=${att_csv}
    Mcs Set Phase    phase=${phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown
