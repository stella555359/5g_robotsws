*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_HOST_USER_NAME}    ute
${REMOTE_HOST_PASSWD}    uteUTE!
${REMOTE_ALIAS}    remote_alias

${BTS2_Mplane_IP}    10.56.201.205
${AutoSwitchoverTimer}    30


*** Keywords ***
CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  Check automatic switchover can be executed successfully after BTS-1 role update to active.
    ...    Case Precondition
    ...    Randomly Lock One BBMOD
    ...    Update Redundancy On BTS1 From Standby To Active And Check
    ...    Check Automatic Switchover Triggered
    ...    Remove Redundancy And Check
    ...  Pass criteria: CELLs of standby BTS should be offline, CELLs of active BTS should be onair,
	...    Check SO success after bts-1 role update to active when bts are Standby-Standby.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.07.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Randomly Lock One BBMOD
    Step 3: Update Redundancy On BTS1 From Standby To Active And Check
    Step 4: Check Automatic Switchover Triggered
    Step 5: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Remote BTS Setup   ${REMOTE_HOST_IP}    ${REMOTE_HOST_USER_NAME}    ${REMOTE_HOST_PASSWD}    ${REMOTE_ALIAS}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${bts_obj}    coam.Get parameters for all    BTS
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_1}    ${bts_id}
    ${bts_obj}    coam.Get parameters for all    BTS    alias=${REMOTE_ALIAS}
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_2}    ${bts_id}
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${parameters_dic1}    Create Dictionary
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby    peerBtsIpAddress=${BTS2_Mplane_IP}
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=${AutoSwitchoverTimer}    minCellAvailability=100
    ${parameters_dic2}    Create Dictionary
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby   peerBtsIpAddress=${MPLANE_IP}
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=${AutoSwitchoverTimer}    minCellAvailability=100
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_4}    Create Dictionary    faultId=${7300}
    ${redundancy_alarm_5}    Create Dictionary    faultId=${6327}
    ${redundancy_alarm_6}    Create Dictionary    faultId=${7319}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    ${ALARMS_7300_6327_7319}    Create List    ${redundancy_alarm_4}    ${redundancy_alarm_5}    ${redundancy_alarm_6}
    Set test Variable    ${ALARMS_4737_4738_4739}
    Set test Variable    ${ALARMS_7300_6327_7319}
    Set Test Variable   ${lte_disabled_state}    administrativeState=unlocked, operationalState=disabled, blockingState=Unblocked
    Set Test Variable   ${nr_disabled_state}    administrativeState=Unlocked, operationalState=disabled, blockingState=Unblocked

Step ${index}: Randomly Lock One BBMOD
    Log To Console    Step ${index}: Randomly Lock One BBMOD
    ${BBMOD_TO_OPER_CONFIG}    ${BBMOD_TO_OPER_INTERNAL}    ${expect_disabled_cell_dic}    Randomly Select One BBMOD And Get Related Cells
    ${online_LNCEL_ids}    coam.Get ids for all    LNCEL
    ${online_NRCEL_ids}    coam.Get ids for all    NRCEL
    Set Test Variable     ${online_LNCEL_ids}
    Set Test Variable     ${online_NRCEL_ids}
    Set Test Variable     ${BBMOD_TO_OPER_CONFIG}
    Set Test Variable     ${BBMOD_TO_OPER_INTERNAL}
    Set Test Variable     ${expect_disabled_cell_dic}
    ${have_5Gcell}    Set Variable If    "${expect_disabled_cell_dic["5G"].__len__()}">"${0}"   ${True}    ${False}
    Set Test Variable    ${have_5Gcell}
    Wait Until Keyword Succeeds    10x    30 sec    coam.lock    dist_name=${BBMOD_TO_OPER_CONFIG}    timeout=60
    coam.assert    BBMOD    ${BBMOD_TO_OPER_INTERNAL}    ${BBMOD_locked_state}    timeout=100    connection=default
    Log To Console    Check not trigger automatic switchover
    Sleep    ${${AutoSwitchoverTimer}+60}s
    ${alarm_existed}    Run Keyword And Return Status    coam.assert_alarm_active    faultId=4782    timeout=120s
    Should Not Be True    ${alarm_existed}
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${lte_disabled_state}
    ...    expected_NR_states=${nr_disabled_state}
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}

Step ${index}: Update Redundancy On BTS1 From Standby To Active And Check
    Log To Console    Step ${index}: Update Redundancy On BTS1 From Standby To Active And Check
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic}
    Log To Console    Check BTS1
    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    timeout=60
    ##Wait Until Keyword Succeeds    20x    30 sec    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-1 is [redundancyRole=standby]    timeout=60
    Wait Until Keyword Succeeds    15x    30 sec    Check All Cells Status As Expected
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF
    ...    unexpected_patterns=@{ALARMS_4737_4738_4739}    ignored_patterns=@{ALARMS_7300_6327_7319}
    ${5G_Status}    Set Variable If    ${have_5Gcell}    unavailable    available
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces       x2ToGnbLinkStatus=${5G_Status}    x2LinkStatus_5g=${5G_Status}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Check Automatic Switchover Triggered
    Log To Console    Step ${index}: Check Automatic Switchover Triggered
    Sleep    ${${AutoSwitchoverTimer}+60}s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${lte_disabled_state}
    ...    expected_NR_states=${nr_disabled_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}        ignored_patterns=@{ALARMS_7300_6327_7319}
    ${5G_Status}    Set Variable If    ${have_5Gcell}    unavailable    available
    Wait Until Keyword Succeeds    20x    30 sec    Check BTS Interfaces    x2ToGnbLinkStatus=${5G_Status}    x2LinkStatus_5g=${5G_Status}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    20x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20x    30 sec    coam.unlock    dist_name=${BBMOD_TO_OPER_CONFIG}    timeout=300
    coam.assert    BBMOD    ${BBMOD_TO_OPER_INTERNAL}    ${BBMOD_expected_state}    timeout=100    connection=default
    Sleep    120s


Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Set Test Variable    ${NEED_COMMISSION}    ${False}

Case Special Teardown
    Log To Console    Case Special Teardown
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    alias=${REMOTE_ALIAS}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS}


Randomly Select One BBMOD And Get Related Cells
    [Arguments]     ${alias}=default
    ${bbmods_cell_mapping}    Get Relationship Between BBMODs And Cells    ${alias}
    ${bbmods_internal}    Get Dictionary Keys    ${bbmods_cell_mapping}
    FOR    ${item}    IN    @{bbmods_internal}
        ${cells_lte}    Set Variable    ${bbmods_cell_mapping["${item}"]["LTE"]}
        ${cells_nr}    Set Variable    ${bbmods_cell_mapping["${item}"]["5G"]}
        Run Keyword If    ${cells_lte.__len__()}==0 and ${cells_nr.__len__()}==0    remove values from list    ${bbmods_internal}    ${item}
    END
    log    ${bbmods_internal}
    ${bbmod_internal}    Evaluate    random.choice(${bbmods_internal})    modules=random, sys
    ${btsInfo}    coam.Get Bts Info    connection=${alias}
    ${bbmod_list}     Set Variable    ${btsInfo['basebandModules']}
    ${bbmod_config_selected}    Set Variable
    ${bbmod_internal_selected}    Set Variable
    FOR    ${item}    IN    @{bbmod_list}
        ${bbmod_config_selected}    Set Variable If    "${item["id"]["internal"]}"=="${bbmod_internal}"
        ...    ${item["id"]["configuration"]}    ${bbmod_config_selected}
        ${bbmod_internal_selected}    Set Variable If    "${item["id"]["internal"]}"=="${bbmod_internal}"
        ...    ${item["id"]["internal"]}    ${bbmod_internal_selected}
        Exit For Loop If    "${item["id"]["internal"]}"=="${bbmod_internal}"
    END
    ${expect_disabled_cell_dic}    Set Variable    ${bbmods_cell_mapping['${bbmod_internal_selected}']}
    [Return]    ${bbmod_config_selected}    ${bbmod_internal_selected}    ${expect_disabled_cell_dic}

Check All Cells Status As Expected
    [Arguments]     ${alias}=default
    Log To Console    Check All Cells Status As Expected
    ${disabled_lncel_list}    Set Variable    ${expect_disabled_cell_dic['LTE']}
    ${disabled_nrcel_list}    Set Variable    ${expect_disabled_cell_dic['5G']}
    ${cell_disabled_status}    Set Variable    blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}
    Check BBMOD Related Cell Status As Expected    LNCEL    ${disabled_lncel_list}    ${cell_disabled_status}    alias=${alias}
    Check BBMOD Related Cell Status As Expected    NRCEL    ${disabled_nrcel_list}    ${cell_disabled_status}    alias=${alias}
    Check Online Cell Status As Expected    LNCEL    ${online_LNCEL_ids}    ${cells_LTE_expected_state}    alias=${alias}
    Check Online Cell Status As Expected    NRCEL    ${online_NRCEL_ids}    ${cells_NR_expected_state}    alias=${alias}

Check BBMOD Related Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    FOR    ${cell_id}    IN    @{cell_id_list}
        Remove Values From List    ${online_${tech_cell}_ids}    ${cell_id}
        coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=60s    connection=${alias}
    END

Check Online Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=20s    connection=${alias}
    END


