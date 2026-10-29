*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CM__CB009939-D_008
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_HOST_USER_NAME}    ute
${REMOTE_HOST_PASSWD}    uteUTE!
${REMOTE_ALIAS}    remote_alias

${BTS2_Mplane_IP}    10.56.201.205
${AutoSwitchoverTimer}    30


*** Keywords ***
CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  Check automatic switchover can be executed successfully when peer BTS is update to standby role.
    ...    Case Precondition
    ...    Full Commissioning On BTS2 From Standby To Active And Check
    ...    Randomly Lock One BBMOD And Check Automatic Switchover Not Triggered
    ...    Update Redundancy On BTS2 From Active To Standby And Check
    ...    Check Automatic Switchover Triggered
    ...    Remove Redundancy And Check
    ...  Pass criteria: CELLs of standby BTS should be offline, CELLs of active BTS should be onair,
	...    Check SO success after bts-2 role update to standby when bts are Active-Active.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.07.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Full Commissioning On BTS2 From Standby To Active And Check
    Step 3: Randomly Lock One BBMOD And Check Automatic Switchover Not Triggered
    Step 4: Update Redundancy On BTS2 From Active To Standby And Check
    Step 5: Check Automatic Switchover Triggered
    Step 6: Remove Redundancy And Check

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
    ...    actAutomaticSwitchover=false    automaticSwitchoverTimer=${AutoSwitchoverTimer}    minCellAvailability=100
    ${parameters_dic2}    Create Dictionary
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby   peerBtsIpAddress=${MPLANE_IP}
    ...    actAutomaticSwitchover=false    automaticSwitchoverTimer=${AutoSwitchoverTimer}    minCellAvailability=100
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_4}    Create Dictionary    faultId=${7300}
    ${redundancy_alarm_5}    Create Dictionary    faultId=${6327}
    ${redundancy_alarm_6}    Create Dictionary    faultId=${7319}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4737_4738_4739}
    ${ALARMS_4738_4739}    Create List    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4738_4739}
    ${ALARMS_4737}    Create List    ${redundancy_alarm_1}
    Set test Variable    ${ALARMS_4737}
    ${ALARMS_7300_6327_7319}    Create List    ${redundancy_alarm_4}    ${redundancy_alarm_5}    ${redundancy_alarm_6}
    Set test Variable    ${ALARMS_7300_6327_7319}
    Set Test Variable   ${lte_disabled_state}    administrativeState=unlocked, operationalState=disabled, blockingState=Unblocked
    Set Test Variable   ${nr_disabled_state}    administrativeState=Unlocked, operationalState=disabled, blockingState=Unblocked
    Set Test Variable   ${lte_failed_state}    administrativeState=unlocked, operationalState=disabled, availabilityStatus=failed
    Set Test Variable   ${nr_failed_state}    administrativeState=Unlocked, operationalState=disabled, availabilityStatus=failed
    Sleep    60s

Step ${index}: Full Commissioning On BTS2 From Standby To Active And Check
    Log To Console    Step ${index}: Full Commissioning On BTS2 From Standby To Active And Check
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
    #afte set Active-Active, then set actAutomaticSwitchover to true.
    #because full plan to set Active with true will have fault4782 on SBTS-37376, it is normal check with Anca.
    ${parameters_dic1}    Create Dictionary      actAutomaticSwitchover=true
    ${parameters_dic2}    Create Dictionary      actAutomaticSwitchover=true
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic1}

    Log To Console    Check BTS2
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    45 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    expected_patterns=@{ALARMS_4737}    unexpected_patterns=@{ALARMS_4738_4739}
    ...    ignored_patterns=@{ALARMS_7300_6327_7319}
    Wait Until Keyword Succeeds    10x    60 sec
    ...    Check BTS Interfaces    alias=${REMOTE_ALIAS}    x2ToGnbLinkStatus=unavailable    ngLinkStatus=Inactive
    Log To Console    Check BTS1
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Wait Until Keyword Succeeds    10x    45 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4737}
    ...    unexpected_patterns=@{ALARMS_4738_4739}    ignored_patterns=@{ALARMS_7300_6327_7319}
    Wait Until Keyword Succeeds    10x    45 sec    Check BTS Interfaces    x2ToGnbLinkStatus=unavailable      x2LinkStatus_5g=unavailable
    Log To Console    Check not trigger automatic switchover
    Sleep    ${${AutoSwitchoverTimer}+60}s
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}    alias=${REMOTE_ALIAS}
    coam.assert_alarm_active    faultId=4737    timeout=120s
    coam.assert_alarm_active    faultId=4737    timeout=120s    alias=${REMOTE_ALIAS}
    Log To Console    should not have 4782
    ${alarm_existed}    Run Keyword And Return Status    coam.assert_alarm_active    faultId=4782    timeout=20s
    Should Not Be True    ${alarm_existed}

Step ${index}: Randomly Lock One BBMOD And Check Automatic Switchover Not Triggered
    Log To Console    Step ${index}: Randomly Lock One BBMOD And Check Automatic Switchover Not Triggered
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
    Sleep    60s
    Log To Console    Check not trigger automatic switchover
    Sleep    ${${AutoSwitchoverTimer}+60}s
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}
    Check SBTS Redundancy States    active    active    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${lte_failed_state}
    ...    expected_NR_states=${nr_failed_state}    alias=${REMOTE_ALIAS}
    Log To Console    should not have 4782
    ${alarm_existed}    Run Keyword And Return Status    coam.assert_alarm_active    faultId=4782    timeout=20s
    Should Not Be True    ${alarm_existed}
    coam.assert_alarm_active    faultId=4737    timeout=120s
    coam.assert_alarm_active    faultId=4737    timeout=120s    alias=${REMOTE_ALIAS}

Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    Log To Console    Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic}    alias=${REMOTE_ALIAS}
    #Because after update bts2 to Standby, Check BTS1(A) BTS2(S) are not complete,SO already triggered,so delete the checking before SO.
    return from keyword
    Log To Console    Check BTS1
    Wait Until Keyword Succeeds    10x    30 sec
    ...    ute_admin_infomodel.query_infomodel    //REDUNDANCY_A-1 is [redundancyRole=active,redundancyGroupId=${MRBTS_ID_1}]
    Wait Until Keyword Succeeds    10x    30 sec    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=standby]
    Wait Until Keyword Succeeds    20x    30 sec    Check All Cells Status As Expected
    Wait Until Keyword Succeeds    20x    30 sec    Admin Check Active Alarms TAF
    ...    unexpected_patterns=@{ALARMS_4737_4738_4739}    ignored_patterns=@{ALARMS_7300_6327_7319}
    #Check BTS Interfaces    x2ToGnbLinkStatus=unavailable
    Log To Console    Check BTS2
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    #Wait Until Keyword Succeeds    20x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Check Automatic Switchover Triggered
    Log To Console    Step ${index}: Check Automatic Switchover Triggered
    Sleep    ${${AutoSwitchoverTimer}+60}s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=1200s    expected_LTE_states=${lte_disabled_state}
    ...    expected_NR_states=${nr_disabled_state}
    Wait Until Keyword Succeeds    20x    30 sec    Admin Check Active Alarms TAF
    ...    unexpected_patterns=@{ALARMS_4737_4738_4739}    ignored_patterns=@{ALARMS_7300_6327_7319}
    ${5G_Status}    Set Variable If    ${have_5Gcell}    unavailable    available
    Wait Until Keyword Succeeds    20x    30 sec    Check BTS Interfaces    x2ToGnbLinkStatus=${5G_Status}    x2LinkStatus_5g=${5G_Status}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    20x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20x    30 sec    coam.unlock    dist_name=${BBMOD_TO_OPER_CONFIG}    timeout=300
    coam.assert    BBMOD    ${BBMOD_TO_OPER_INTERNAL}    ${BBMOD_expected_state}    timeout=100    connection=default

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Sleep    15s
    #For bad CNN PR767417, reset site if F1900 raised.
    ${fault_str}    Set Variable    faultId=1900
    ${is_1900_raised_BTS1}    Run Keyword And Return Status    coam.assert_alarm_active    ${fault_str}    timeout=240s
    ${is_1900_raised_BTS2}    Run Keyword And Return Status    coam.assert_alarm_active    ${fault_str}    timeout=240s    connection=${REMOTE_ALIAS}
    Run Keyword If    ${is_1900_raised_BTS1}    Run Keywords    coam.reset_site    AND    Sleep    240s
    Run Keyword If    ${is_1900_raised_BTS2}    Run Keywords    coam.reset_site    connection=${REMOTE_ALIAS}    AND    Sleep    240s
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=1200s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600s    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
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
        coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=20s    connection=${alias}
    END

Check Online Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=45s    connection=${alias}
    END