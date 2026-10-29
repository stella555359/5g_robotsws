*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96    #10.56.111.63
${REMOTE_SSH_USER_NAME}    ute
${REMOTE_SSH_PASSWD}    uteUTE!    #RAN_pz_HAZ1_SG11
${REMOTE_ALIAS_NAME}    remote_alias

*** Keywords ***
CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Setup remote alias for remote control PC and save original SCF files
    ...    Create Redundancy On BTS1 And Check
    ...    Create Redundancy On BTS2 And Check
    ...    Remove Redundancy And Check
    ...    Pass criteria: LNCELs of standby BTS should be offline, LNCELs of active BTS should be onair,
    ...    fault 4739 should be raised and cleared as expected. LNCELs should be onair after Redundancy removed.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.01.2023 - Commit to GIT

    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    PHASE-CRT    API    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Create Redundancy On BTS1 And Check
    Step 3: Create Redundancy On BTS2 And Check
    Step 4: Remove Redundancy And Check

Case Special Teardown
    Log    Case Special Teardown    console=${True}
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS_NAME}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    ${REMOTE_ALIAS_NAME}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS_NAME}
    Common Test Teardown
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS_NAME}

Set Up 2rd Admin
    ${file_limit}    Get Variable Value    ${MAX_UDP_SIZE}    0
    coam.Setup Admin    admin_api_log_dir=${BTS Files}    bts_host=${SMOD1['TRS_IP']}    bts_port=443    use_ssl=TRUE
    ...    alias=${REMOTE_ALIAS_NAME}    update_interval=1000    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_SSH_USER_NAME}    remote_host_password =${REMOTE_SSH_PASSWD}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS_NAME}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_SSH_USER_NAME}    remote_host_password =${REMOTE_SSH_PASSWD}
    taf_syslog.start_syslog    alias=${REMOTE_ALIAS_NAME}    log_dir=${Temp Logs Dir}    log_name=REMOTE_SMOD_UDP_1
    ...    ip=${SMOD1["UDP_IP"]}    host_ip=${REMOTE_HOST_IP}    ports=@{UDP ports}    file_limit=${file_limit}
    ...    ssh_username=${REMOTE_SSH_USER_NAME}    ssh_password=${REMOTE_SSH_PASSWD}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS_NAME}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}

Set Case Variables
    ${bts_obj}    coam.Get Parameters For All    BTS
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_1}    ${bts_id}
    ${bts_obj}    coam.Get Parameters For All    BTS    alias=${REMOTE_ALIAS_NAME}
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_2}    ${bts_id}

Oper REDUNDANCY
    [Arguments]    ${MRBTS_ID}    ${operation}    ${redundancyGroupId}    ${redundancyRole}    ${alias}=default
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/REDUNDANCY-1
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID}_${time}
    Run Keyword If    '${operation}'=='create'    Run Keywords
    ...    coam.append_managed_object_to_delta    ${dist_name}    create    ${MRBTS_ID}_${time}
    ...    AND    coam.append_parameter_update_to_delta    ${dist_name}    redundancyGroupId    ${redundancyGroupId}    ${MRBTS_ID}_${time}
    ...    AND    coam.append_parameter_update_to_delta    ${dist_name}    redundancyRole    ${redundancyRole}    ${MRBTS_ID}_${time}
    ...    ELSE IF    '${operation}'=='update'    Run Keywords
    ...    coam.append_managed_object_to_delta    ${dist_name}    update    ${MRBTS_ID}_${time}
    ...    AND    coam.append_parameter_update_to_delta    ${dist_name}    redundancyGroupId    ${redundancyGroupId}    ${MRBTS_ID}_${time}
    ...    AND    coam.append_parameter_update_to_delta    ${dist_name}    redundancyRole    ${redundancyRole}    ${MRBTS_ID}_${time}
    ...    ELSE IF    '${operation}'=='delete'
    ...    coam.append_managed_object_to_delta    ${dist_name}    delete    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}

Remove Redundancy And Check
    Oper REDUNDANCY    ${MRBTS_ID_1}    delete    ${MRBTS_ID_1}    standby
    Oper REDUNDANCY    ${MRBTS_ID_2}    delete    ${MRBTS_ID_1}    active    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    none //REDUNDANCY_A-*    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=empty]    alias=${REMOTE_ALIAS_NAME}
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60    connection=${REMOTE_ALIAS_NAME}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4738}
    ${UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${UNEXPECTED_ALARMS}
    #Check BTS1
    ute_admin_infomodel.query_infomodel    none //REDUNDANCY_A-*
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=empty]
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60    connection=default
    Admin Check Active Alarms TAF    unexpected_patterns=${UNEXPECTED_ALARMS}

Step ${index}: Create Redundancy On BTS1 And Check
    Log To Console    Step ${index}: Create Redundancy On BTS1 And Check
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    Oper REDUNDANCY    ${MRBTS_ID_1}    create    ${MRBTS_ID_1}    standby
    #Check BTS1
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=standby,redundancyGroupId=${MRBTS_ID_1}]
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=empty]
    coam.assert_every    LNCEL    ${cells_LTE_offline_state}    timeout=60    connection=default
    ${redundancy_alarm}    Create Dictionary    faultId=${4739}
    ${EXPECTED_ALARMS}    Create List    ${redundancy_alarm}
    Admin Check Active Alarms TAF    expected_patterns=${EXPECTED_ALARMS}
    #Check BTS2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=standby]    alias=${REMOTE_ALIAS_NAME}
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60    connection=${REMOTE_ALIAS_NAME}
    ${redundancy_alarm}    Create Dictionary    faultId=${4739}
    ${UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${UNEXPECTED_ALARMS}

Step ${index}: Create Redundancy On BTS2 And Check
    Log To Console    Step ${index}: Create Redundancy On BTS2 And Check
    Oper REDUNDANCY    ${MRBTS_ID_2}    create    ${MRBTS_ID_1}    active    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=standby]    alias=${REMOTE_ALIAS_NAME}
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60    connection=${REMOTE_ALIAS_NAME}
    ${redundancy_alarm}    Create Dictionary    faultId=${4739}
    ${UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${UNEXPECTED_ALARMS}
    #Check BTS1
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=standby,redundancyGroupId=${MRBTS_ID_1}]
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=active]
    coam.assert_every    LNCEL    ${cells_LTE_offline_state}    timeout=60    connection=default
    Admin Check Active Alarms TAF    unexpected_patterns=${UNEXPECTED_ALARMS}

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Set Up 2rd Admin
    Set Case Variables

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    Remove Redundancy And Check
    Set Test Variable    ${NEED_COMMISSION}    ${False}