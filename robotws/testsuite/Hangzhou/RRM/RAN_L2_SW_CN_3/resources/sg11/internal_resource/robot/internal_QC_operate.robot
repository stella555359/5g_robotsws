*** Settings ***
Library     ${CURDIR}/../python/qc_env_obtain.py

*** Keywords ***

Obtain MCS Info
    @{mcs_related_ip}    get_mcs_related_info    ${CONFIG_FILE}
    ${MCS_HOST_IP}    Set Variable    ${mcs_related_ip[0]}
    ${DEVICE_IP}    Set Variable    ${mcs_related_ip[1]}
    ${DB_PATH}    Set Variable    ${mcs_related_ip[2]}
    ${mcs_pc_user}    Set Variable    ${mcs_related_ip[3]}
    ${mcs_pc_pwd}    Set Variable    ${mcs_related_ip[4]}
    Set Suite variable    ${MCS_HOST_IP}
    Set Suite variable    ${DEVICE_IP}
    Set Suite variable    ${DB_PATH}
    Set Suite variable    ${mcs_pc_user}
    Set Suite variable    ${mcs_pc_pwd}


Set Mcs3 Phase And Attenuation by CSV
    [Arguments]    ${att_csv}    ${phase_csv}    ${frequency}=2600_1_ALL
    Obtain MCS Info
    MCS Setup    host_ip=${mcs_host_ip}    device_ip=${device_ip}    mcs_port=28888    username=${mcs_pc_user}    password=${mcs_pc_pwd}
    MCS Get Calibration File Name
    Mcs Apply Channel For Resource    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
    MCS Set Frequency    frequency=${frequency}
    Mcs Set Attenuation    att=${att_csv}
    Mcs Set Phase    phase=${phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown

Attach Mutli QC UEs
    [Arguments]    ${UE1}=none    ${UE2}=none    ${UE3}=none    ${UE4}=none    ${UE5}=none    ${UE6}=none    ${UE7}=none    ${UE8}=none
    @{QCUE_list}    create list    ${UE1}    ${UE2}    ${UE3}    ${UE4}    ${UE5}    ${UE6}    ${UE7}    ${UE8}
    FOR    ${index}    IN     @{QCUE_list}
        Run Keyword If    '${index}'!='none'    Qualcomm detach ue    ${index}
        Run Keyword If    '${index}'!='none'    Qualcomm attach ue    ${index}
    END


Send Dl Data By iperfPc
    [Arguments]    ${port}    ${device_id}    ${extra_cmd}    ${iperfpc_ip}    ${iperfpc_username}=ute    ${iperfpc_pwd}=%EjvHVvvkQD6
    ${ue_ip}=    Qualcomm Get Ip With Adb    ${device_id}
    Qualcomm Start Iperf Client On Pc    ${port}    ${ue_ip}    ${extra_cmd}    ${iperfpc_ip}    ${iperfpc_username}    ${iperfpc_pwd}

get tput from PM counter
    [Arguments]    ${log_dir}    ${counter_id}    ${cell}=1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+180
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=${counter_id}
    ...   cell_id=${cell}
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    [Return]    ${DL_throughput}

Detach UEs
    [Arguments]    ${UE1}=none    ${UE2}=none    ${UE3}=none    ${UE4}=none    ${UE5}=none    ${UE6}=none    ${UE7}=none    ${UE8}=none
    @{QCUE_list}    create list    ${UE1}    ${UE2}    ${UE3}    ${UE4}    ${UE5}    ${UE6}    ${UE7}    ${UE8}
    FOR    ${index}    IN     @{QCUE_list}
        Run Keyword If    '${index}'!='none'    Qualcomm detach ue    ${index}
    END
