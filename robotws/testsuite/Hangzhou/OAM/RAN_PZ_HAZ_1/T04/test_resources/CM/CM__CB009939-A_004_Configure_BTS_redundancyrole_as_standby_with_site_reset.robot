*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CM__CB009939-A_004
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_SSH_USER_NAME}    ute
${REMOTE_SSH_PASSWD}    uteUTE!
${REMOTE_ALIAS_NAME}    remote_alias
${MRBTS_ID_1}     37376
${MRBTS_ID_2}     37377

*** Keywords ***
CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Create Redundancy On BTS2 And Check
    Step 3: Create Standby Redundency With Site Reset On BTS1 And Check
    Step 4: Update Redundancy On BTS2 From Active To Standby With Site Reset And Check
    Step 5: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Set Up 2rd Admin
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    #Check BTS2 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Set Up 2rd Admin
    Remote BTS Setup    ${REMOTE_HOST_IP}    ${REMOTE_SSH_USER_NAME}    ${REMOTE_SSH_PASSWD}    ${REMOTE_ALIAS_NAME}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS_NAME}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4738}
    ${CASE_UNEXPECTED_ALARMS}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set Test Variable    ${CASE_UNEXPECTED_ALARMS}

Step ${index}: Create Redundancy On BTS2 And Check
    Log To Console    Step ${index}: Create Redundancy On BTS2 And Check
    #coam.Perform Commissioning    ${MRBTS_ID_2}    ${BTS2_scf_active}
    #...    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS_NAME}
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic}    ${REMOTE_ALIAS}
    Sleep    90s
    ${full_scf_bts2}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    alias=${REMOTE_ALIAS}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf_bts2}
    L_XML.Set Element Text    ${scf_xml}    active
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1"]/p[@name="redundancyRole"]
    #L_XML.Set Element Text    ${scf_xml}    false
    #...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1"]/p[@name="validatePlanAgainstDetectedHW"]
    L_XML.Save Xml    ${scf_xml}    ${BTSFiles}/scf_bts2_active.xml
    coam.Perform Commissioning    ${MRBTS_ID_2}    ${BTSFiles}/scf_bts2_active.xml
    ...    skip_parameter_relation_errors=${TRUE}    connection=${REMOTE_ALIAS}      timeout=600s
    Sleep    420s

    #Check BTS2
    coam.assert_every    RMOD    ${RMOD_expected_states}    timeout=900    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=empty]    alias=${REMOTE_ALIAS_NAME}
    #Check BTS1
    Check SBTS Redundancy States    empty    active    ${MRBTS_ID_1}
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Step ${index}: Create Standby Redundency With Site Reset On BTS1 And Check
    Log To Console    Step ${index}: Create Standby Redundency With Site Reset On BTS1 And Check
    ${FEATCADM_1}    ute_admin_infomodel.query_infomodel    get object //FEATCADM_A-1
    ${val}    Set Variable If    '${FEATCADM_1.actMplaneFronthaulFirewall}'=='True'    false    true
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_1}    ${MRBTS_ID_1}    standby    create
    Add Parameter Cause Site Reset To Delta    ${MRBTS_ID_1}    ${delta_id}    ${val}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    timeout=600
    ute_admin_infomodel.wait_for_infomodel_response_after_reset    timeout_for_reset=120    timeout_for_response=600
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    #Check BTS1 is standby
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    5x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS2 is active
    Wait Until Keyword Succeeds    5x    30s
    ...    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=120    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    5x    60s    Admin Check Active Alarms TAF
    ...    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

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

Step ${index}: Update Redundancy On BTS2 From Active To Standby With Site Reset And Check
    Log To Console    Step ${index}: Update Redundancy On BTS2 From Active To Standby With Site Reset And Check
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID_2}    ${MRBTS_ID_1}    standby    update
    ${FEATCADM_2}    ute_admin_infomodel.query_infomodel    get object //FEATCADM_A-1    alias=${REMOTE_ALIAS_NAME}
    Log    ${FEATCADM_2.actMplaneFronthaulFirewall}
    ${val2}    Set Variable If    '${FEATCADM_2.actMplaneFronthaulFirewall}'=='True'    false    true
    coam.append_managed_object_to_delta    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    update    delta_id=${delta_id}
    coam.append_parameter_update_to_delta
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    ${val2}    delta_id=${delta_id}
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    Log    ${delta_json}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.wait_for_infomodel_response_after_reset    timeout_for_reset=120    timeout_for_response=600    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    Log    Check BTS2
	Wait Until Keyword Succeeds    10x    60s
    ...    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    5x    60s
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    Log    Check BTS1
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=600
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    5x    60s    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${need_full_commission}    Remove Redundancy And Check
    Set Test Variable    ${NEED_COMMISSION}    ${need_full_commission}

Remove Redundancy And Check
    ${need_full_commission}    Set Variable    ${False}
    Wait Until Keyword Succeeds    5x    60s    Delete REDUNDANCY    ${MRBTS_ID_1}
    Wait Until Keyword Succeeds    5x    60s    Delete REDUNDANCY    ${MRBTS_ID_2}    ${REMOTE_ALIAS_NAME}
    ${fault_str}    Set Variable    faultId=1900
    ${is_1900_raised_BTS1}    Run Keyword And Return Status    coam.assert_alarm_active    ${fault_str}    timeout=240s
    ${is_1900_raised_BTS2}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    ${fault_str}    timeout=240s    connection=${REMOTE_ALIAS_NAME}
    Return From Keyword If    ${is_1900_raised_BTS1} or ${is_1900_raised_BTS2}    ${True}    #For PR767417, just do full commission if F1900 raised.
    #Check BTS2 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
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
    ${BTS1_scf_modified}    Set ValidatePlanAgainstDetectedHW Value SCF      ${BTS1_scf_initial}      false
    ${BTS2_scf_modified}    Set ValidatePlanAgainstDetectedHW Value SCF      ${BTS2_scf_initial}      false
    Run Keyword If    ${NEED_COMMISSION}    Wait Until Keyword Succeeds    5x    120 sec    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_modified}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_modified}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS_NAME}