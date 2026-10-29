*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CM__CB009939-A_007
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_SSH_USER_NAME}    ute
${REMOTE_SSH_PASSWD}    uteUTE!
${REMOTE_ALIAS_NAME}    remote_alias
${MRBTS_ID_1}     37376
${MRBTS_ID_2}     37377

*** Keywords ***
CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Create Active Redundency With Site Reset On BTS1 And Check
    Step 3: Create Active Redundency With Foreign Cells On ${MRBTS_ID_2} And Check
    Step 4: Update Redundancy On BTS1 From Active To Standby And Check
    Step 5: Update Redundancy On BTS2 From Standby To Active With Site Reset And Check
    Step 6: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Set Up 2rd Admin
    Log Variables
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_2}    ${MRBTS_ID_1}    standby    create
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState]    timeout=120    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2 is Standby
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    standby    empty    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    #Check BTS1
    Check SBTS Redundancy States    empty    standby    ${MRBTS_ID_1}

Set Up 2rd Admin
    Remote BTS Setup    ${REMOTE_HOST_IP}    ${REMOTE_SSH_USER_NAME}    ${REMOTE_SSH_PASSWD}    ${REMOTE_ALIAS_NAME}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS_NAME}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4738}
    ${CASE_UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set Test Variable    ${CASE_UNEXPECTED_ALARMS}
    ${CASE_EXPECTED_ALARMs}    Create List    ${redundancy_alarm_1}
    Set Test Variable    ${CASE_EXPECTED_ALARMs}

Step ${index}: Create Active Redundency With Site Reset On BTS1 And Check
    Log To Console    Step ${index}: Create Active Redundency With Site Reset On BTS1 And Check
    ${FEATCADM_1}    ute_admin_infomodel.query_infomodel    get object //FEATCADM_A-1
    ${val}    Set Variable If    '${FEATCADM_1.actMplaneFronthaulFirewall}'=='True'    false    true
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_1}    ${MRBTS_ID_1}    active    create
    Add Parameter Cause Site Reset To Delta    ${MRBTS_ID_1}    ${delta_id}    ${val}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    timeout=600
    ute_admin_infomodel.wait_for_infomodel_response_after_reset    timeout_for_reset=120    timeout_for_response=600
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=standby]
    #Check BTS2 is Standby
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF
    ...    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    Wait Until Keyword Succeeds    5x    60s    Check BTS Interfaces

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

Add Parameter Cause Site Reset To Delta
    [Arguments]    ${mrbts_id}    ${delta_id}    ${val_actMplaneFronthaulFirewall}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    update    delta_id=${delta_id}
    coam.append_parameter_update_to_delta
    ...    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    ${val_actMplaneFronthaulFirewall}    delta_id=${delta_id}

Step ${index}: Create Active Redundency With Foreign Cells On ${MRBTS_ID} And Check
    Log To Console    Step ${index}: Create Active Redundency With Foreign Cells On ${MRBTS_ID} And Check
    ${FEATCADM_1}    ute_admin_infomodel.query_infomodel    get object //FEATCADM_A-1
    ${val}    Set Variable If    '${FEATCADM_1.actMplaneFronthaulFirewall}'=='True'    false    true
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID}    ${MRBTS_ID_1}    active    update
    Add Parameter Cause Site Reset To Delta    ${MRBTS_ID}    ${delta_id}    ${val}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${alias}    Set Variable If    '${MRBTS_ID}'=='${MRBTS_ID_2}'    ${REMOTE_ALIAS_NAME}    default
    ${msg}    Run Keyword And Expect Error    *    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}
    Should Contain    ${msg}    AdminApiProcedureFailureException    ignore_case=True
    Should Contain    ${msg}    Cells are detected on peer BTS or Redundancy_Info is Active/Forced Active    ignore_case=True
    ${fault_4738}    Create Dictionary    faultId=${4738}
    ${tmp_fault}    Create List    ${fault_4738}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    alias=${alias}    expected_patterns=${tmp_fault}

Step ${index}: Update Redundancy On BTS1 From Active To Standby And Check
    Log To Console    Step ${index}: Update Redundancy On BTS1 From Active To Standby And Check
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_1}    ${MRBTS_ID_1}    standby    update
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}
    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState]    timeout=120
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    #Check BTS2
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF
    ...    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=600
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Step ${index}: Update Redundancy On BTS2 From Standby To Active With Site Reset And Check
    Log To Console    Step ${index}: Update Redundancy On BTS2 From Standby To Active With Site Reset And Check
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_2}    ${MRBTS_ID_1}    active    update
    ${FEATCADM_2}    ute_admin_infomodel.query_infomodel    get object //FEATCADM_A-1    alias=${REMOTE_ALIAS_NAME}
    Log    ${FEATCADM_2.actMplaneFronthaulFirewall}
    ${val2}    Set Variable If    '${FEATCADM_2.actMplaneFronthaulFirewall}'=='True'    false    true
    coam.append_managed_object_to_delta    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    update    delta_id=${delta_id}
    coam.append_parameter_update_to_delta
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    ${val2}    delta_id=${delta_id}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    Log    ${delta_json}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS_NAME}
    ${is_reset_catch}    Run Keyword And Return Status    ute_admin_infomodel.wait_for_infomodel_response_after_reset
    ...    timeout_for_reset=120    timeout_for_response=600    alias=${REMOTE_ALIAS_NAME}
    Should Be True    ${is_reset_catch}    SBTS has not reset.
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=900    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    Wait Until Keyword Succeeds    5x    60s    Check BTS Interfaces    alias=${REMOTE_ALIAS_NAME}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${need_full_commission}    Remove Redundancy And Check
    Set Test Variable    ${NEED_COMMISSION}    ${need_full_commission}

Remove Redundancy And Check
    ${need_full_commission}    Set Variable    ${False}
    Delete REDUNDANCY    ${MRBTS_ID_2}    ${REMOTE_ALIAS_NAME}
    Delete REDUNDANCY    ${MRBTS_ID_1}
    ${fault_str}    Set Variable    faultId=1900
    ${is_1900_raised_BTS1}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    ${fault_str}    timeout=240s
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

Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    Log To Console    Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_2}    ${MRBTS_ID_1}    standby    update
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    Log    ${delta_json}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState]    timeout=120    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    #Check BTS2
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    3x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    3x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}