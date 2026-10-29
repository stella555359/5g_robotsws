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
${MRBTS2_MPLANE_IP}    10.56.201.205

*** Keywords ***
CM__CB009939-D_006_Trigger_Successful_Automatic_Switchover_When_Mix_Conditions_Are_Set
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  Check automatic switchover can be executed successfully when priorityLteCellsList or priorityNrCellsList or minCellAvailability
    ...  condition is met. This case bbmods and cells are fixed, need update if SBTS change.
    ...    Case Precondition
    ...    Trigger AS with priorityLteCellsList and priorityNrCellsList
    ...    Increase minCellAvailability
    ...    Trigger AS with priorityLteCellsList and minCellAvailability
    ...    Trigger AS with priorityNrCellsList and minCellAvailability
    ...    Trigger AS with priorityNrCellsList and priorityLteCellsList and minCellAvailability
    ...    Remove Redundancy And Check
    ...  Pass criteria: CELLs of standby BTS should be offline, CELLs of active BTS should be onair,
	...    Check SO success when priorityLteCellsList or priorityNrCellsList or minCellAvailability condition is met.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.08.2024 - New Case
    Set Tags    CA-CM    AUTHOR-bin.liu@nokia-sbell.com    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    step 2: Trigger AS with priorityLteCellsList and priorityNrCellsList
    Step 3: Increase minCellAvailability
    step 4: Trigger AS with priorityLteCellsList and minCellAvailability
    step 5: Trigger AS with priorityNrCellsList and minCellAvailability
    step 6: Trigger AS with priorityNrCellsList and priorityLteCellsList and minCellAvailability
    Step 7: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    Log To Console    Set ${MRBTS_ID_1} as standby, ${MRBTS_ID_2} as active.
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
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
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    Set Test Variable    ${automaticSwitchoverTimer}    30
    ${time_gap_for_AS}    Evaluate    ${automaticSwitchoverTimer}+10
    Set Test Variable    ${time_gap_for_AS}
    Set Test Variable    ${cell_disable_state}    operationalState=disabled,blockingState=Unblocked,energySavingState=notEnergySaving
    ${priorityLteCellsList}    Create List    2    3
    ${priorityNrCellsList}    Create List    0
    Set Test Variable    ${priorityLteCellsList}
    Set Test Variable    ${priorityNrCellsList}
    ${parameters_dic_1}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby    actAutomaticSwitchover=true
    ...    minCellAvailability=40    priorityLteCellsList=${priorityLteCellsList}    priorityNrCellsList=${priorityNrCellsList}
    ...    peerBtsIpAddress=${MRBTS2_MPLANE_IP}    automaticSwitchoverTimer=${automaticSwitchoverTimer}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic_1}
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=600
    coam.assert_every    RMOD    ${RMOD_expected_states}    timeout=900
    Comment    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState: *-> Activated]    timeout=1200
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    ${parameters_dic_2}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active    actAutomaticSwitchover=true
    ...    minCellAvailability=40    priorityLteCellsList=${priorityLteCellsList}
    ...    priorityNrCellsList=${priorityNrCellsList}    peerBtsIpAddress=${MPLANE_IP}    automaticSwitchoverTimer=${automaticSwitchoverTimer}
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic_2}    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}

step ${index}: Trigger AS with priorityLteCellsList and priorityNrCellsList
    Log To Console    step ${index}: Trigger AS with priorityLteCellsList and priorityNrCellsList
    Log To Console    Lock BBMODs on ${MRBTS_ID_2}, ${MRBTS_ID_1} switch to active, ${MRBTS_ID_2} switch to standby
    ${bbmod_id_list}    Create List    1    2
    Set BBMODs Administrator State    ${MRBTS_ID_2}    ${bbmod_id_list}    Locked    alias=${REMOTE_ALIAS_NAME}
    ${disable_cell_list}    Create List    LNCEL_R-0    LNCEL_R-1    LNCEL_R-2    LNCEL_R-3    NRCELL_R-0    NRCELL_R-1    NRCELL_R-2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    FOR    ${cell}    IN    @{disable_cell_list}
    ute_admin_infomodel.query_infomodel    //${cell} is [${cell_disable_state}]    timeout=10s    alias=${REMOTE_ALIAS_NAME}
    END
    Sleep    ${${automaticSwitchoverTimer}+60}s
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //PLAN_VALIDATE_IND-*    timeout=${time_gap_for_AS}
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=900
    Comment    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState: *-> Activated]
    Comment    ...    timeout=1800    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    timeout=900
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Set BBMODs Administrator State    ${MRBTS_ID_2}    ${bbmod_id_list}    Unlocked    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS_NAME}
    Sleep    3 min

Step ${index}: Increase minCellAvailability
    Log To Console    Step ${index}: Increase minCellAvailability
    ${parameters_dic}    Create Dictionary    minCellAvailability=60
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic}    alias=${REMOTE_ALIAS_NAME}
    Sleep    5 min


Set BBMODs Administrator State
    [Arguments]    ${MRBTS_ID}    ${list_BBMOD_id}    ${state}    ${alias}=default
    ${time}    Get Time    epoch
    ${delta_id}    Set Variable    ${MRBTS_ID}_${time}
    coam.create_delta    delta_id=${delta_id}
    FOR    ${id}    IN    @{list_BBMOD_id}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${id}
    coam.append_managed_object_to_delta    ${dist_name}    update    ${delta_id}
    coam.append_parameter_update_to_delta    ${dist_name}    administrativeState    ${state}    ${delta_id}
    END
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}

step ${index}: Trigger AS with priorityLteCellsList and minCellAvailability
    Log To Console    step ${index}: Trigger AS with priorityLteCellsList and minCellAvailability
    Log To Console    Lock BBMODs on ${MRBTS_ID_1}, ${MRBTS_ID_1} switch to standby, ${MRBTS_ID_2} switch to active
    ${bbmod_id_list}    Create List    2
    Set BBMODs Administrator State    ${MRBTS_ID_1}    ${bbmod_id_list}    Locked
    ${disable_cell_list}    Create List    LNCEL_R-1    LNCEL_R-2    LNCEL_R-3    LNCEL_R-0
    FOR    ${cell}    IN    @{disable_cell_list}
    ute_admin_infomodel.query_infomodel    //${cell} is [${cell_disable_state}]    timeout=10s
    END
    Sleep    ${${automaticSwitchoverTimer}+60}s
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //PLAN_VALIDATE_IND-*    timeout=${time_gap_for_AS}
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=900
    Comment    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState: *-> Activated]    timeout=1800
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=standby,redundancyGroupId=${MRBTS_ID_1}]    timeout=900
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    10x    30 sec    Set BBMODs Administrator State    ${MRBTS_ID_1}    ${bbmod_id_list}    Unlocked
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Sleep    3 min

step ${index}: Trigger AS with priorityNrCellsList and minCellAvailability
    Log To Console    step ${index}: Trigger AS with priorityNrCellsList and minCellAvailability
    Log To Console    Lock BBMODs on ${MRBTS_ID_2}, ${MRBTS_ID_1} switch to active, ${MRBTS_ID_2} switch to standby
    ${bbmod_id_list}    Create List    1
    Set BBMODs Administrator State    ${MRBTS_ID_2}    ${bbmod_id_list}    Locked    alias=${REMOTE_ALIAS_NAME}
    ${disable_cell_list}    Create List    NRCELL_R-0    NRCELL_R-1      NRCELL_R-2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS_NAME}
    FOR    ${cell}    IN    @{disable_cell_list}
    ute_admin_infomodel.query_infomodel    //${cell} is [${cell_disable_state}]    timeout=10s    alias=${REMOTE_ALIAS_NAME}
    END
    Sleep    ${${automaticSwitchoverTimer}+60}s
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //PLAN_VALIDATE_IND-*    timeout=${time_gap_for_AS}
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=900
    Comment    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState: *-> Activated]
    Comment    ...    timeout=1800    alias=${REMOTE_ALIAS_NAME}
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    timeout=900
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Set BBMODs Administrator State    ${MRBTS_ID_2}    ${bbmod_id_list}    Unlocked    alias=${REMOTE_ALIAS_NAME}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Sleep    3 min

step ${index}: Trigger AS with priorityNrCellsList and priorityLteCellsList and minCellAvailability
    Log To Console    step ${index}: Trigger AS with priorityNrCellsList and priorityLteCellsList and minCellAvailability
    Log To Console    Lock BBMODs on ${MRBTS_ID_1}, ${MRBTS_ID_1} switch to standby, ${MRBTS_ID_2} switch to active
    ${bbmod_id_list}    Create List    1    2
    Set BBMODs Administrator State    ${MRBTS_ID_1}    ${bbmod_id_list}    Locked
    ${disable_cell_list}    Create List    LNCEL_R-0    LNCEL_R-1    LNCEL_R-2    LNCEL_R-3    NRCELL_R-0    NRCELL_R-1      NRCELL_R-2
    ...    NRCELL_R-0    NRCELL_R-2
    FOR    ${cell}    IN    @{disable_cell_list}
    ute_admin_infomodel.query_infomodel    //${cell} is [${cell_disable_state}]    timeout=10s
    END
    Sleep    ${${automaticSwitchoverTimer}+60}s
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //PLAN_VALIDATE_IND-*    timeout=${time_gap_for_AS}
    Comment    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=900
    Comment    ute_admin_infomodel.wait_for_infomodel_event    change //NRBTS_M-* [stateInfo.workingState: *-> Activated]    timeout=1800
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=standby,redundancyGroupId=${MRBTS_ID_1}]    timeout=900
    ute_admin_infomodel.query_infomodel    //NRBTS_M-* is [stateInfo.workingState=Activated]    timeout=1200
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    alias=${REMOTE_ALIAS_NAME}
    Wait Until Keyword Succeeds    10x    30 sec    Set BBMODs Administrator State    ${MRBTS_ID_1}    ${bbmod_id_list}    Unlocked
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    timeout=600
    Sleep    3 min


Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    Remove Redundancy And Check
    Set Test Variable    ${NEED_COMMISSION}    ${False}

Remove Redundancy And Check
    Delete REDUNDANCY    ${MRBTS_ID_2}    ${REMOTE_ALIAS_NAME}
    Delete REDUNDANCY    ${MRBTS_ID_1}
    Sleep    600s
    #Check BTS2 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600    alias=${REMOTE_ALIAS_NAME}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS_NAME}    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}
    #Check BTS1 not redundant
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600
    Admin Check Active Alarms TAF    unexpected_patterns=${CASE_UNEXPECTED_ALARMS}

Delete REDUNDANCY
    [Arguments]    ${MRBTS_ID}    ${alias}=default
    ${delta_id}    Create Delta For Oper REDUNDANCY    ${MRBTS_ID}    ${EMPTY}    ${EMPTY}    delete
    ${delta_json}    coam.get_delta    delta_id=${delta_id}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}

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

Case Special Teardown
    Log    Case Special Teardown    console=${True}
    return from keyword
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS_NAME}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    alias=${REMOTE_ALIAS_NAME}
    Comment    Run Keyword If    ${NEED_COMMISSION}    Perform Commissioning    ${MRBTS_ID_1}    ${BTS1_scf_initial}
    ...    skip_parameter_relation_errors=true    timeout=600
    Comment    Run Keyword If    ${NEED_COMMISSION}    Perform Commissioning    ${MRBTS_ID_2}    ${BTS2_scf_initial}
    ...    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS_NAME}
    Comment    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Comment    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    Comment    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=1200    connection=${REMOTE_ALIAS_NAME}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS_NAME}

