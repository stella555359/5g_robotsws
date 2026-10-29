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
${AutoSwitchoverTimer}    60
${minCellAvailability1}    80
${minCellAvailability2}    10


*** Keywords ***
CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  Check automatic switchover can be executed successfully when priorityLteCellsList or priorityNrCellsList condition is met.
    ...    Case Precondition
    ...    Automatic Switchover Triggered When priorityLteCellsList Met On SBTS1
    ...    Automatic Switchover Not Triggered When priorityNrCellsList Not Met On SBTS2
    ...    Automatic Switchover Triggered When priorityNrCellsList Met On SBTS2
    ...    Remove Redundancy And Check
    ...  Pass criteria: CELLs of standby BTS should be offline, CELLs of active BTS should be onair,
	...    Check SO success when priorityLteCellsList or priorityNrCellsList condition is met.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.07.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Automatic Switchover Triggered When priorityLteCellsList Met On SBTS1
    Step 3: Automatic Switchover Not Triggered When priorityNrCellsList Not Met On SBTS2
    Step 4: Automatic Switchover Triggered When priorityNrCellsList Met On SBTS2
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
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active    peerBtsIpAddress=${BTS2_Mplane_IP}
    ${parameters_dic2}    Create Dictionary
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby   peerBtsIpAddress=${MPLANE_IP}
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_4}    Create Dictionary    faultId=${7516}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    ${ALARMS_7516}    Create List    ${redundancy_alarm_4}
    Set test Variable    ${ALARMS_4737_4738_4739}
    Set test Variable    ${ALARMS_7516}
    Set Test Variable   ${lte_disabled_state}    administrativeState=unlocked, operationalState=disabled, blockingState=Unblocked
    Set Test Variable   ${nr_disabled_state}    administrativeState=Unlocked, operationalState=disabled, blockingState=Unblocked
    Sleep    60s

Step ${index}: Automatic Switchover Triggered When priorityLteCellsList Met On SBTS1
    Log To Console    Step ${index}: Automatic Switchover Triggered When priorityLteCellsList Met On SBTS1
    ${bbmods_cell_mapping}    Get Relationship Between BBMODs And Cells
    ${bbmods_internal}    Get Dictionary Keys    ${bbmods_cell_mapping}
    FOR    ${item}    IN    @{bbmods_internal}
        ${cells_lte}    Set Variable    ${bbmods_cell_mapping["${item}"]["LTE"]}
        Run Keyword If    ${cells_lte.__len__()}==0    remove values from list    ${bbmods_internal}    ${item}
    END
    log    ${bbmods_internal}
    ${bbmod_internal}    Evaluate    random.choice(${bbmods_internal})    modules=random, sys
    ${cells_lte}    Set Variable    ${bbmods_cell_mapping["${bbmod_internal}"]["LTE"]}
    ${cells_lte_id}    Create List
    FOR    ${item}    IN    @{cells_lte}
        ${id}    Fetch From Right    ${item}    -
        Append To List    ${cells_lte_id}    ${id}
    END
    log    ${cells_lte_id}

    ${btsInfo}    coam.Get Bts Info
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

    ${parameters_dic1}    Create Dictionary
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=${AutoSwitchoverTimer}    priorityLteCellsList=${cells_lte_id}
    ${parameters_dic2}    Create Dictionary
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=${AutoSwitchoverTimer}    priorityLteCellsList=${cells_lte_id}
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic1}

    Wait Until Keyword Succeeds    10x    30 sec    coam.lock    dist_name=${bbmod_config_selected}    timeout=60
    coam.assert    BBMOD    ${bbmod_internal_selected}    ${BBMOD_locked_state}    timeout=100

    Log To Console    Check Automatic Switchover Triggered
    Sleep    ${${AutoSwitchoverTimer}+60}s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${lte_disabled_state}
    ...    expected_NR_states=${nr_disabled_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec    coam.unlock    dist_name=${bbmod_config_selected}    timeout=300
    coam.assert    BBMOD    ${bbmod_internal_selected}    ${BBMOD_expected_state}    timeout=100
    Sleep    120s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}

Step ${index}: Automatic Switchover Not Triggered When priorityNrCellsList Not Met On SBTS2
    Log To Console    Step ${index}: Automatic Switchover Not Triggered When priorityNrCellsList Not Met On SBTS2
    ${nrcells_id}    Create List
    ${nrcells_list}    Fetch ID Mapping From Admin For Cells    NRBTS    alias=${REMOTE_ALIAS}
    ${ltecells_list}    Fetch ID Mapping From Admin For Cells    LTE    alias=${REMOTE_ALIAS}
    FOR    ${item}    IN    @{nrcells_list}
        ${id}    Fetch From Right    ${item["configuration"]}    -
        Append To List    ${nrcells_id}    ${id}
    END
    ${disabled_cell}    Evaluate    random.choice(${nrcells_list})    modules=random, sys
    ${disabled_cellId}    Fetch From Right    ${disabled_cell["configuration"]}    -
    Remove Values From List    ${nrcells_list}    ${disabled_cell}
    Remove Values From List    ${nrcells_id}    ${disabled_cellId}
    ${parameters_dic1}    Create Dictionary    priorityLteCellsList=empty    priorityNrCellsList=${nrcells_id}
    ${parameters_dic2}    Create Dictionary    priorityLteCellsList=empty    priorityNrCellsList=${nrcells_id}
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic1}
    ${currentValue}    Get CM Parameter Value From SCF    ${BTS2_scf_initial}    ${disabled_cell["configuration"]}    gscnOrSsPbchArfcn
    coam.Perform Parameter Recommissioning    ${disabled_cell["configuration"]}
    ...    gscnOrSsPbchArfcn    update    ${${currentValue}+500}    connection=${REMOTE_ALIAS}
    Log To Console    Check Automatic Switchover Not Triggered
    Sleep    1200s   #need wait 20 mins as gscnOrSsPbchArfcn is service affect parameter, then check not trigger Automatic Switchover
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}      #have 7300 7319 6327
    Check BTS Interfaces
    Log To Console    Check BTS2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.query_infomodel
    ...    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    timeout=90    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=standby]    timeout=90    alias=${REMOTE_ALIAS}

    coam.Assert   NRCEL    ${disabled_cell["internal"]}    ${nr_disabled_state}    timeout=20s    connection=${REMOTE_ALIAS}
    FOR    ${cell}    IN    @{nrcells_list}
        coam.Assert   NRCEL    ${cell["internal"]}    ${cells_NR_expected_state}    timeout=20s    connection=${REMOTE_ALIAS}
    END
    FOR    ${cell}    IN    @{ltecells_list}
        coam.Assert   LNCEL    ${cell["internal"]}    ${cells_LTE_expected_state}    timeout=20s    connection=${REMOTE_ALIAS}
    END
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}     expected_patterns=@{ALARMS_7516}
    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    coam.Perform Parameter Recommissioning    ${disabled_cell["configuration"]}
    ...    gscnOrSsPbchArfcn    update    ${currentValue}    connection=${REMOTE_ALIAS}
    coam.rat_reset    NR    timeout=300s    connection=${REMOTE_ALIAS}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}

Step ${index}: Automatic Switchover Triggered When priorityNrCellsList Met On SBTS2
    Log To Console    Step ${index}: Automatic Switchover Triggered When priorityNrCellsList Met On SBTS2
    ${nrcells_id}    Create List
    ${nrcells_list}    Fetch ID Mapping From Admin For Cells    NRBTS    alias=${REMOTE_ALIAS}
    ${ltecells_list}    Fetch ID Mapping From Admin For Cells    LTE    alias=${REMOTE_ALIAS}
    ${onair_nrcells_list}    Copy List    ${nrcells_list}
    FOR    ${item}    IN    @{nrcells_list}
        ${id}    Fetch From Right    ${item["configuration"]}    -
        Append To List    ${nrcells_id}    ${id}
    END
    ${disabled_cell1}    Evaluate    random.choice(${nrcells_list})    modules=random, sys
    ${disabled_cellId1}    Fetch From Right    ${disabled_cell1["configuration"]}    -
    Remove Values From List    ${nrcells_list}    ${disabled_cell1}
    Remove Values From List    ${nrcells_id}    ${disabled_cellId1}
    ${disabled_cell2}    Evaluate    random.choice(${nrcells_list})    modules=random, sys
    ${disabled_cellId2}    Fetch From Right    ${disabled_cell1["configuration"]}    -
    Remove Values From List    ${onair_nrcells_list}    ${disabled_cell1}    ${disabled_cell2}
    ${parameters_dic1}    Create Dictionary    priorityLteCellsList=empty    priorityNrCellsList=${nrcells_id}
    ${parameters_dic2}    Create Dictionary    priorityLteCellsList=empty    priorityNrCellsList=${nrcells_id}
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic1}
    ${currentValue1}    Get CM Parameter Value From SCF    ${BTS2_scf_initial}    ${disabled_cell1["configuration"]}    gscnOrSsPbchArfcn
    ${currentValue2}    Get CM Parameter Value From SCF    ${BTS2_scf_initial}    ${disabled_cell2["configuration"]}    gscnOrSsPbchArfcn
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_2}_${time}
    coam.append_managed_object_to_delta    ${disabled_cell1["configuration"]}    update    ${MRBTS_ID_2}_${time}
    coam.append_parameter_update_to_delta
    ...    ${disabled_cell1["configuration"]}    gscnOrSsPbchArfcn    ${${currentValue1}+500}    ${MRBTS_ID_2}_${time}
    coam.append_managed_object_to_delta    ${disabled_cell2["configuration"]}    update    ${MRBTS_ID_2}_${time}
    coam.append_parameter_update_to_delta
    ...    ${disabled_cell2["configuration"]}    gscnOrSsPbchArfcn    ${${currentValue2}+500}    ${MRBTS_ID_2}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_2}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS}
    Log To Console    Check Automatic Switchover Triggered
    #need wait 20 mins as gscnOrSsPbchArfcn is service affect parameter,then check trigger Automatic Switchover
    Sleep    1100s
    #Automatic Switchover not trigger in 20 mins
    ute_admin_infomodel.query_infomodel
    ...    //REDUNDANCY_A-1 is [redundancyRole=standby,redundancyGroupId=${MRBTS_ID_1}]    timeout=90
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=active]    timeout=90
    ute_admin_infomodel.query_infomodel
    ...    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]    timeout=90    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=standby]    timeout=90    alias=${REMOTE_ALIAS}

    Sleep    ${${AutoSwitchoverTimer}+60}s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${lte_disabled_state}
    ...    expected_NR_states=${nr_disabled_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF
    ...    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}    expected_patterns=@{ALARMS_7516}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_2}_${time}
    coam.append_managed_object_to_delta    ${disabled_cell1["configuration"]}    update    ${MRBTS_ID_2}_${time}
    coam.append_parameter_update_to_delta    ${disabled_cell1["configuration"]}    gscnOrSsPbchArfcn    ${currentValue1}    ${MRBTS_ID_2}_${time}
    coam.append_managed_object_to_delta    ${disabled_cell2["configuration"]}    update    ${MRBTS_ID_2}_${time}
    coam.append_parameter_update_to_delta    ${disabled_cell2["configuration"]}    gscnOrSsPbchArfcn    ${currentValue2}    ${MRBTS_ID_2}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_2}_${time}
    Wait Until Keyword Succeeds    10x    30 sec    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS}
    Sleep    60s

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
        Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=20s    connection=${alias}
    END

Check Online Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=20s    connection=${alias}
    END

