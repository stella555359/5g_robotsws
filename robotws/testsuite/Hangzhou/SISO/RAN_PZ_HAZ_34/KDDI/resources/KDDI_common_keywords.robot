*** Settings ***
Documentation    This is for KDDI common keywords
...              Author: lanwen.cai
...              Squard: HZ SG8

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007835_B/resources/comm_keyword.robot

*** Variables ***

*** Keywords ***
Set PA vaule to KDDI
    ${PA_195}    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=HBTE
    ${PA_202}    attenuator.setup_attenuator    attenuator=${tl.attenuators[1]}    alias=HBTE
    FOR  ${index}    IN RANGE    1    17
        attenuator.set_attenuation   port=${index}    value=${127}    attenuator_device=${PA_195}
    END
    FOR  ${index}    IN RANGE    1    17
        attenuator.set_attenuation   port=${index}    value=${127}    attenuator_device=${PA_202}
    END
    attenuator.set_attenuation    port=${5}    value=${5}    attenuator_device=${PA_195}
    attenuator.set_attenuation    port=${6}    value=${5}    attenuator_device=${PA_195}
    attenuator.set_attenuation    port=${8}    value=${0}    attenuator_device=${PA_195}
    attenuator.set_attenuation    port=${1}    value=${0}    attenuator_device=${PA_202}
    attenuator.set_attenuation    port=${2}    value=${0}    attenuator_device=${PA_202}
    attenuator.set_attenuation    port=${3}    value=${0}    attenuator_device=${PA_202}
    attenuator.set_attenuation    port=${4}    value=${0}    attenuator_device=${PA_202}

KDDI_power_reset
    Perform Site Power Off    model=FACOM
    sleep    20s
    ${status}    Run keyword and return status     COAM Navigate to login page via webUI
    Should not be true    ${status}
    Perform Site Power On    model=FACOM
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    Selenium Login And Disable Screen Lock
    [Teardown]   Selenium Logout And Close Browser

KDDI_Cell_lock_and_unlock
    [Documentation]    *****************
    ...    - [TEST PURPOSE] To verify cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}  with_peak=${with_peak}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}

KDDI_CellGroups_lock_and_unlock
    [Documentation]    *****************
    ...    - [TEST PURPOSE] To verify cellgroups lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}  with_peak=${with_peak}
    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}

Each_RF_module_lock_unlock
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of locking and unlocking.
    ...    ******************
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
    END
    sleep    ${X2_link_shutdown_time}min
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300
    connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be unLocked  ru_index=${ru_index}
    END
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    5min    20sec    Expect Fault Should Absent    faultId=7300
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

KDDI_Snapshot_capture_via_WEBUI
    [Documentation]  Author: lanwen.cai
    ...              Description: Snapshot logs will be stored under the indicate download_dir
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${temp_dir_for_save_snapshot}    Set variable    /tmp/snapshot_ta
    Create directory    ${temp_dir_for_save_snapshot}
    COAM Navigate to login page via webUI    download_dir=${temp_dir_for_save_snapshot}    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.snapshot_collection_settings    coverage=All log files    save_location=Local
    ${temp_snapshot_file_path}    selenium_coam.collect_snapshot
    sleep   5s
    wait until keyword succeeds    15min    30s    Should Contain    ${temp_snapshot_file_path}    Snapshot_MRBTS
    [Teardown]   Selenium Logout And Close Browser

pcmd log analysis sa
    [Arguments]    ${filename}=${OUTPUT_DIR}/pcmd.pcap
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduRx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduRx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUeSched >${OUTPUT_DIR}/1.pmdl
    ${timeOfUeSched}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.timeOfUePduTx >${OUTPUT_DIR}/1.pmdl
    ${timeOfUePduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBad1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfBadPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfBadLastMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOfMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOf1stMacPduTx >${OUTPUT_DIR}/1.pmdl
    ${numOf1stMacPduTx}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduRxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduRxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfRlcPduTxBytes >${OUTPUT_DIR}/1.pmdl
    ${sumOfRlcPduTxBytes}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.sumOfWbCqi >${OUTPUT_DIR}/1.pmdl
    ${sumOfWbCqi}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    OperatingSystem.Run    /usr/bin/tshark -r ${filename} -Y "nsetapx.TraceMessage" -T fields -e nsetapx.numOfWbCqiSamples >${OUTPUT_DIR}/1.pmdl
    ${numOfWbCqiSamples}    OperatingSystem.Run    cat ${OUTPUT_DIR}/1.pmdl |awk '/./ {print}'
    run keyword and continue on failure    Should not be empty    ${timeOfUePduRx}
    run keyword and continue on failure    Should not be empty    ${timeOfUeSched}
    run keyword and continue on failure    Should not be empty    ${timeOfUePduTx}
    run keyword and continue on failure    Should not be empty    ${numOfBadPduTx}
    run keyword and continue on failure    Should not be empty    ${numOfMacPduTx}
    run keyword and continue on failure    Should not be empty    ${numOf1stMacPduTx}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduRxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfRlcPduTxBytes}
    run keyword and continue on failure    Should not be empty    ${sumOfWbCqi}
    run keyword and continue on failure    Should not be empty    ${numOfWbCqiSamples}

update_parameter_dllaIniMcs_via_WEBUI
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    ...                Description: Set parameter dllaIniMcs(class C, not impact cell reset) for changing,validation and activation
    [Arguments]   ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-401
    ...    ${filter_param}=Initial MCS for DL transmission
    ...    ${new_value}=${2}    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    start login WEBUI
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Close Start Up View    timeout=60
    ${parameter_pre}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ${parameter_pre_int}    convert to integer    ${parameter_pre}
    Log to console    Update dllaIniMcs value from ${parameter_pre} to ${new_value}
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}     new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep   5s
    ${parameter_now}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    Should be equal as strings    ${parameter_now}    ${new_value}    msg=paramter updated failed
    Log to console    modify the parameter to orgin vaule ${parameter_pre}  in teardown
    [Teardown]    run keywords
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${parameter_pre_int}
    ...    AND    selenium_coam.validate_plan    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND   sleep    5s    AND
    ...    COAM selenium logout

update_parameter_ulDMRS_via_api
    [Arguments]    ${new_value}=No additional DMRS
    log to console    \n***Modify ulDMRSAdditionalPosition via API***
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-401
    ...    parameter=ulDMRSAdditionalPosition    value=${new_value}
    append to list  ${modify_params}  ${item}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_params}    timeout=15min
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Return]  ${modify_params}

KDDI_update_ulDMRS_with_L3call
    update_parameter_ulDMRS_via_api    new_value=One additional DMRS
#    KDDI check multi cell L3call
    [Teardown]    update_parameter_ulDMRS_via_api    new_value=No additional DMRS

Configuration_backup_via_WEBUI
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    ...                Description: Backup commission file via WebU
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Close Start Up View    timeout=60
    log to console    Backup commission file via WebUI
    ${commission_file}   selenium_coam.backup_bts_site_configuration
    sleep    2s
    Should Contain    ${commission_file}    xml
    [Teardown]  Selenium Logout And Close Browser

KDDI check multi cell L3call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Start multicell traffic
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${protocol}=udp
    ...    ${target_avg_percent}=0.5
    ...    ${min_percent}=0.2
    ...    ${duration}=${120}
    ...    ${pcmd}=${False}
    log to console    \n***Start UE attach and start traffic***
    run keyword if    ${pcmd}==${True}    start collect pcmd logs    cmd=br1
    KDDI UE attach and start traffic    ue_index=${0}    dl_tp=700M     ul_tp=50M
    KDDI UE attach and start traffic    ue_index=${1}    dl_tp=1500M    ul_tp=100M
#    KDDI UE attach and start traffic    ue_index=${2}    dl_tp=200M     ul_tp=50M
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    Stop and download pcmd log
    run keyword and continue on failure    run keyword if    ${pcmd}==${True}    pcmd log analysis sa
    log to console    \n***Start Collect Throughput***
    ${tput_log}    huawei.Collect Tput    duration=${duration}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[301]['nrCellIdentity']}
    ${cell_id2}    Convert To String    ${cell_mapping[401]['nrCellIdentity']}
    ${cell_id3}    Convert To String    ${cell_mapping[701]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id2}    Create List    ${cell_id2}
    ${cell_id3}    Create List    ${cell_id3}
    log to console    \n***Start Check cell301(40M) Throughput***
    samsung.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=15
    ...     dltarget_throughput=510    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    \n***Start Check cell401(100M) Throughput***
    huawei.Check Bi Tput
    ...    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=80
    ...     dltarget_throughput=1425    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
#    log to console    \n***Start Check cell701(FDD) Throughput***
#    qct_dx50.Check Bi Tput
#    ...    log=${tput_log}    cells=${cell_id3}    ultarget_throughput=36
#    ...     dltarget_throughput=92    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    KDDI Stop UE L3 Call

KDDI UE attach and start traffic
    [Arguments]  ${ue_index}=${0}    ${dl_tp}=300M    ${ul_tp}=100M    ${traffic_duration}=${2400}    ${protocol}=udp
    ...     ${iperf_type}=via_command
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    log to console    \n***Start UE attach***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    20s
    Connect to Common Unit Master    alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
        ...    alias=ASIK MASTER    connection=GNB_OAM
    log to console    \n***Start traffic***
    ${iperf_type}     Run keyword if    '${ue_type}'=='huawei'     Set Variable    via_app
    ...    ELSE    Set Variable     via_command
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}    iperf_type=${iperf_type}

KDDI Stop UE L3 Call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Stop multi UE L3 Call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    log to console    \n***Stop UE L3 Call***
    run keyword and ignore error  huawei.Stop traffic   direction=dl    ue_index=${0}
    run keyword and ignore error  huawei.Stop traffic   direction=ul    ue_index=${0}
    run keyword and ignore error  huawei.Stop traffic   direction=dl    ue_index=${1}
    run keyword and ignore error  huawei.Stop traffic   direction=ul    ue_index=${1}
#    run keyword and ignore error  qct_dx50.Stop traffic   direction=dl    ue_index=${2}    iperf_port=default
#    run keyword and ignore error  qct_dx50.Stop traffic   direction=ul    ue_index=${2}    iperf_port=default
    ${status}  ${5Grach_ed}  run keyword and ignore error   huawei.UE Detach   ue_index=${0}
    ${status}  ${5Grach_ed}  run keyword and ignore error   huawei.UE Detach   ue_index=${1}
#    ${status}  ${5Grach_ed}  run keyword and ignore error   qct_dx50.UE Detach   ue_index=${2}

Perform SW rollback
    [Arguments]  ${connection}=GNB_OAM
    coam.rollback_software    connection=${connection}
    sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

4G reset via webUI
    COAM Navigate to login page via webUI    url=https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=Nemuadmin    password=nemuuser
    selenium_coam.reset_site
    Wait until enb cell on air status
    [Teardown]   Selenium Logout And Close Browser

Update 4G X2 via api
    log to console    \n***login ENB***
    wait until keyword succeeds    5min    20 sec    Connect to eNB via ssl    connection=enblte
    ${lock_params}  create list
    ${unlock_params}  create list
    ${lock_item}  create dictionary  dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-4
    ...    parameter=administrativeState    value=locked
    append to list  ${lock_params}  ${lock_item}
    log to console    \n***lock X2 via API***
    COAM Update several parameters via rest api    parameters_to_update_via_api=${lock_params}    timeout=3min    connection=enblte
    sleep    30s
    ${unlock_item}  create dictionary  dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-4
    ...    parameter=administrativeState    value=unlocked
    append to list  ${unlock_params}   ${unlock_item}
    log to console    \n***unlock X2 via API***
    COAM Update several parameters via rest api    parameters_to_update_via_api=${unlock_params}    timeout=3min    connection=enblte
    [Teardown]    Enblte close down

Baseband_module_lock_unlock_by_coam
    [Documentation]   Author:lanwen.cai@nokia-sbell.com
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify lock unlock bbmod by coam.
    ...    ******************
    ${bbmod_index_list}  Get All BBmod Index
    Get X2 link shutdown waiting time
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.lock_baseband    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}    timeout=600s
        ...    connection=GNB_OAM
        sleep    5s
        Wait Until Keyword Succeeds    5min    10s    bbmod Should Be Locked    bbmod_index=${bbmod_index}
    END
    sleep    ${X2_link_shutdown_time}min
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=7300
    log to console    start unlock bbmod
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.unlock_baseband    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}    timeout=600s
        ...    connection=GNB_OAM
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be unLocked    bbmod_index=${bbmod_index}
    END
    run keyword if    '${gNb_CuType}'=='NSA'
    ...    Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=7300
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run Keyword And Ignore Error    unlock Baseband module by coam    bbmod_index_list=${bbmod_index_list}

unlock Baseband module by coam
    [Arguments]  ${bbmod_index_list}
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.unlock_baseband    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}    timeout=600s
        ...    connection==GNB_OAM
        Wait Until Keyword Succeeds    5min    10s    bbmod Should Be unLocked    bbmod_index=${bbmod_index}
    END
