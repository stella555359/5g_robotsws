*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../resources/cbrs_common_keywords.robot
Variables    ../TestData/9154-B_variables.py

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8

*** Variables ***
${CB009154-B_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB009154-B_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB009154-B_json_path}/enable_actcbrs.json
${attach_cell1}    ${CB009154-B_json_path}/attach_cell1.json
${attach_cell2}    ${CB009154-B_json_path}/attach_cell2.json
#${conf_path}    ${CURDIR}/conf
#${CB009154_B_13_conf}    ${conf_path}/CB009154_B_13.conf
*** Keywords ***
Case Preparation
    ${SCF_CB009154-B}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154-B_
	set suite variable    ${SCF_CB009154-B}
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009154-B}
    Connect to eNB via ssl
    ${SCF_CB009154-B_4G}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154-B_4G_
    COAM Commission with scf file    scf_file_path=${SCF_CB009154-B_4G}    connection=enblte    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB009154-B_4G}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_1815}     Create Dictionary     faultId=${1815}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_1815}
    set suite variable  ${ALLOWED_HISTORY_FAULT}
    Enblte close down

CB009154 CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    CBRS Test Setup
    CBRS 4G Test Setup    enable_delta_file=${enable_delta_file}

CB009154 CBRS Test Teardown
    [Arguments]    ${disable_delta_file}=${disable_actcbrs}
    CBRS 4G Test Teardown    disable_delta_file=${disable_delta_file}
    CBRS Test Teardown

CB009154-B_18_gNB_data_transfer_conducted_peak_throughput_NR2x20MHz+LTE1x10MHz
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    CBRS make 2cc call    tput_expect=${tput_define}    attach_1=${attach_cell1}    attach_2=${attach_cell2}
    ...    target_avg=0.95    min_percent=0.85

CB009154-B_12_online_add_NR_cell_under_RFS
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009154-B_1CC_
    COAM Commission with scf file    scf_file_path=${SCF_new}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Activate feature CBRS By Coam
    Sleep    60s
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Online Cell addition    file_path=${SCF_CB009154-B}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Verify all lte cells should be onair    connection=enblte
    Selenium Login And Disable Screen Lock
    Online Change NR CBRS Flag    actNrCbrs=false
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Verify all lte cells should be onair    connection=enblte
    ${register_status}  run keyword and return status  wait until keyword succeeds    2min    30s    Check Register Status By Coam
    Should be True    ${register_status} == False
    Check GrantOperationState Status Success    Status=Idle
    [Teardown]    Selenium Logout And Close Browser

CB009154-B_13_online_delete_NR_cell_under_RFS
    Connect to eNB via ssl
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009154-B}  
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3600}
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=enblte
    Sleep    30s
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3550_3600}
    Sleep    30s
    start SAS server
    Change NR CBRS Flag By Coam    actNrCbrs=true
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Verify all lte cells should be disabled
    ${stamp_case_start}    Get Timestamp For Current Time
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=enblte
    ${status}  run keyword and return status  wait until keyword succeeds    5min    30s    Verify lte cell should be onair
    Run Keyword If    '${status}' == 'True'    Verify lte cell should be disabled    cell_index=${1}
    ...    ELSE    Verify lte cell should be onair    cell_index=${1}
    Wait Until Keyword Succeeds    5min    5s    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}    connection=enblte
    Online Cell deletion
    Sleep    60s
    Wait until keyword succeeds    3min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte

CB009154-B_17_gNB_side_CBRS_activated_deactivatied
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Selenium Login And Disable Screen Lock
    Online Change NR CBRS Flag    actNrCbrs=false
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Verify all lte cells should be onair    connection=enblte
    ${register_status}  run keyword and return status  wait until keyword succeeds    2min    30s    Check Register Status By Coam
    Should be True    ${register_status} == False
    Check GrantOperationState Status Success    Status=Idle
    Check Deregister Success Message by cbsdid    cbsdid=${nrcbsdid}
    Check NO Deregister Message by cbsdid    cbsdid=${ltecbsdid}
    Sleep    10s
    Online Change NR CBRS Flag    actNrCbrs=true
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Verify all lte cells should be onair    connection=enblte
    [Teardown]    Selenium Logout And Close Browser

CB009154-B_16_eNB_side_CBRS_activated_deactivatied
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=enblte
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=enblte
    verify all cells should be onair
    ${GrantOperationState_LTE}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantOperationState
    Should be True    '${GrantOperationState_LTE}' == 'Idle'
    Check Deregister Success Message by cbsdid    cbsdid=${ltecbsdid}
    Check NO Deregister Message by cbsdid    cbsdid=${nrcbsdid}
    Sleep    10s
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=enblte
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    verify all cells should be onair
