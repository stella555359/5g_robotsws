*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4    SBTS23R1
...   CLOUD_5G_I_BLLL_AP_LOO
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot



*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${SCFC_NAME}      SCFC_7922_case3.xml
#${AIRPHONE_NAME}    IPHY_AEHC_4CELL.xml
#${WTS_NAME}       WTS_7922_4cell.cfg
${SCFC_NAME}      SCFC_CB007922_CASE58_AP_LOO.xml
${AIRPHONE_NAME}    IPHY_AEQE_CASE07_AP_LO.xml
${WTS_NAME}       WTS_70851_CASE07_AP_LO.cfg
@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
${UE_ID}    11
${PCELL_THRESHOLD}    460000
${SCELL_THRESHOLD}    430000

${DL_PORT}    5005
${UL_PORT}    5002
${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
${SEND_DATA_CMD}    -u -t 8000 -i 1 -p 5001 -P 1 -f m -b 1400.00M -l 1400B -T 64
${ATT}    ${CONFIG_DIR_PATH}/qualcomm_config/att_25db_beaset6_uldl_beam1_layer2.csv
${PHASE}    ${CONFIG_DIR_PATH}/qualcomm_config/phase_25db_beaset6_uldl_beam1_layer2.csv
${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time
${json_path}    /home/ute/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB007922/create_20220510165347782745_delta.json

*** Test Cases ***
CB007922_case58_D_12_interL2RT_Reset_of_BB_unit_hosting_Scell_SA
#following is for qualcomm
    # Prepare for sa env
    # Qualcomm prepare gnb onair
    # Attach ue with name and make call stable    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}
    # ${scell_bbmod}    Judger scell bbmod
    # Start capture only gnb syslog in 'after_onair' file
    # ${tput_file}    Attach qualcomm ue and download qualcomm log    ue1_name    ${DL_PORT}    ${DL_LOG}    ${SEND_DATA_CMD}    first
    # ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput_file}
    # run keyword and continue on failure    should_be_true    ${pcell_tput} > 1060000
    # run keyword and continue on failure    should_be_true    ${scell_tput} > 840000
    # Reset scell BBMOD    2
    # ${tput1_file}    Download qualcomm ue log
    # ${pcell_tput}    ${scell_tput}    ${pcell_bler}    ${scell_bler}    Get ue throughput and bler    ${tput1_file}
    # run keyword and continue on failure    should_be_true    ${pcell_tput} == 0
    # run keyword and continue on failure    should_be_true    ${scell_tput} == 0
    # Stop capture only gnb syslog in 'after_onair' file

    Prepare gnb onair
    Start capture gnb and ap syslog in 'after_onair' file
    Attach ue and check throughput    ${UE_ID}    ${SCELL_THRESHOLD}    ${PCELL_THRESHOLD}
    Airphone NSA Detach    ${UE_ID}
    'Locked' ABIL card
    Wait '60s' for stabible
    'Unlocked' ABIL card
    Attach ue and check throughput    ${UE_ID}    ${SCELL_THRESHOLD}    ${PCELL_THRESHOLD}
    Stop capture gnb and ap syslog in 'after_onair' file



*** Keywords ***
Attach ue and check throughput
    [Arguments]    ${ue_id}    ${s}    ${p}
#    NSA attach ue '${ue_id}' with 'TDD_NSA_AP_band41' cap and 'TDD_NSA_AP_band41_eutra' eutra cap to 5g cell
    Airphone NSA Attach    ${ue_id}
    NSA send ue '${ue_id}' mutiple trf '6' for each '175M' DL data
    Wait reach threshold    Check NSA ue '${ue_id}' 'pcell' dl throught should '> ${p}'
    Wait reach threshold    Check NSA ue '${ue_id}' 'scell' dl throught should '> ${s}'

Wait reach threshold
    [Arguments]    ${check_point}
    Wait Until Keyword Succeeds    200s    10s    ${check_point}

'${ope}' ABIL card
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1   administrativeState    ${ope}    online
    TAF_ADMIN.teardown admin    connection=online
    Wait '30s' for stabible

Get ue throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${UE1_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${UE1_pcell_tput}    ${UE1_scell_tput}    ${UE1_pcell_bler}    ${UE1_scell_bler}

Download qualcomm ue log
    ${log_path}    Get qualcomm log    ${UE1_ID}    C:\\tmp\\Qualcomm\\
    Download qualcomm log    ${log_path}.hdf    ${EXPORT_GRID}    reset_BBMOD_raw.txt
    ${throughput_file}    set variable    reset_BBMOD_raw.txt
    [Return]    ${throughput_file}

Judger scell bbmod
    ${scell_bbmod}    Run Keyword If    ${pcell_id} == 411    Set variable    1
    ...    ELSE    Set variable    2
    [Return]    ${scell_bbmod}

Reset scell BBMOD
    [Arguments]     ${s}
    log to console    reset scell bbmod
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=parameter
    ${bts}    TAF_ADMIN.get_parameters_for_all    BTS    timeout=200s    connection=parameter
    ${g}    Setvariable    ${bts[0].btsId}
    ${par}     Evaluate
    ...    {'dist_name':'MRBTS-${g}/MNL-1/CMD-1/HWRESETREQ-1','parameter':'targetHwResetUDN','value':'MRBTS-${g}/EQM-1/APEQM-1/CABINET-1/BBMOD-${s}'}
    ${parameter}    Evaluate    [${par}]
    ${delta_file}    Create Update Parameters Delta    ${parameter}    operation=create
    ${json_path}    get_from_dictionary    ${delta_file}    updated
    Online recommissioning with delta json file    ${json_path}
    TAF_ADMIN.teardown admin    connection=parameter
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair

Prepare for sa env
    Set attenuation    ${ATT}
    Set phase    ${PHASE}
    Set ue to SA    ${UE1_ID}
