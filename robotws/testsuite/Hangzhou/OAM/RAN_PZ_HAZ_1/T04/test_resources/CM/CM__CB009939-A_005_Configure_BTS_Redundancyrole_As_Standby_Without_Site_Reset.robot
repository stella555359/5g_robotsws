*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_SSH_USER_NAME}    ute
${REMOTE_SSH_PASSWD}    uteUTE!
${REMOTE_ALIAS_NAME}    remote_alias
${MRBTS_ID_1}     37376
${MRBTS_ID_2}     37377

*** Keywords ***
CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Create Standby Redundency Without Site Reset On BTS1 And Check
    Step 3: Create Standby Redundency Without Site Reset On BTS2 And Check
    Step 4: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Set Up 2rd Admin
    #Check BTS2 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Set Up 2rd Admin
    Remote BTS Setup    ${REMOTE_HOST_IP}    ${REMOTE_SSH_USER_NAME}    ${REMOTE_SSH_PASSWD}    ${REMOTE_ALIAS_NAME}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS_NAME}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4738}
    ${CASE_UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set Test Variable    ${CASE_UNEXPECTED_ALARMS}
    ${CASE_EXPECTED_ALARMS}    Create List    ${redundancy_alarm_1}
    Set Test Variable    ${CASE_EXPECTED_ALARMS}

Step ${index}: Create Standby Redundency Without Site Reset On BTS1 And Check
    Log To Console    Step ${index}: Create Standby Redundency Without Site Reset On BTS1 And Check
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${val}    Generate Random String
    ${val}    Set Variable    CB009939_A_005_${val}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_1}    ${MRBTS_ID_1}    standby    create
    Add Parameter Not Cause Site Reset To Delta    ${MRBTS_ID_1}    ${delta_id}    ${val}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}
    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState]    timeout=120
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    #Check BTS1
    Check SBTS Redundancy States    standby    empty    ${MRBTS_ID_1}    timeout=600
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    expected_patterns=${CASE_EXPECTED_ALARMS}
    #Check BTS2
    Check SBTS Redundancy States    empty    standby    ${MRBTS_ID_1}    timeout=120    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    Wait Until Keyword Succeeds    10x    60s    Check BTS Interfaces

Create Delta For Oper REDUNDANCY
    [Arguments]    ${MRBTS_ID}    ${redundancyGroupId}    ${redundancyRole}    ${operation}=create
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/REDUNDANCY-1
    ${time}    Get Time    epoch
    ${delta_id}    Set Variable    ${MRBTS_ID}_${time}
    coam.create_delta    delta_id=${delta_id}
    coam.append_managed_object_to_delta    ${dist_name}    ${operation}    ${delta_id}
    Return From Keyword If    '${operation}'=='delete'    ${delta_id}
    coam.append_parameter_update_to_delta    ${dist_name}    redundancyGroupId    ${redundancyGroupId}    ${delta_id}
    coam.append_parameter_update_to_delta    ${dist_name}    redundancyRole    ${redundancyRole}    ${delta_id}
    [Return]    ${delta_id}

Add Parameter Not Cause Site Reset To Delta
    [Arguments]    ${mrbts_id}    ${delta_id}    ${val_btsName}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}    update    delta_id=${delta_id}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}    btsName    ${val_btsName}    delta_id=${delta_id}

Step ${index}: Create Standby Redundency Without Site Reset On BTS2 And Check
    Log To Console    Step ${index}: Create Standby Redundency Without Site Reset On BTS2 And Check
    ${val}    Generate Random String
    ${val}    Set Variable    CB009939_A_005_${val}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_2}    ${MRBTS_ID_1}    standby    create
    Add Parameter Not Cause Site Reset To Delta    ${MRBTS_ID_2}    ${delta_id}    ${val}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState]    timeout=120    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    Wait Until Keyword Succeeds    10x    60s    Check BTS Interfaces    alias=${REMOTE_ALIAS_NAME}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${need_full_commission}    Remove Redundancy And Check
    Set Test Variable    ${NEED_COMMISSION}    ${need_full_commission}

Remove Redundancy And Check
    ${need_full_commission}    Set Variable    ${False}
    Delete REDUNDANCY    ${MRBTS_ID_2}    ${REMOTE_ALIAS_NAME}
    Delete REDUNDANCY    ${MRBTS_ID_1}
    ${fault_str}    Set Variable    faultId=1900
    ${is_1900_raised_BTS1}    Run Keyword And Return Status    coam.assert_alarm_active    ${fault_str}    timeout=240s
    ${is_1900_raised_BTS2}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    ${fault_str}    timeout=240s    connection=${REMOTE_ALIAS_NAME}
    Return From Keyword If    ${is_1900_raised_BTS1} or ${is_1900_raised_BTS2}    ${True}    #For PR767417, just do full commission if F1900 raised.
    #Check BTS2 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    [Return]    ${need_full_commission}

Delete REDUNDANCY
    [Arguments]    ${MRBTS_ID}    ${alias}=default
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID}    ${EMPTY}    ${EMPTY}    delete
    Add Parameter Not Cause Site Reset To Delta    ${MRBTS_ID}    ${delta_id}    SBTS_${MRBTS_ID}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}

Case Special Teardown
    Log    Case Special Teardown    console=${True}
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS_NAME}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    ${REMOTE_ALIAS_NAME}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS_NAME}