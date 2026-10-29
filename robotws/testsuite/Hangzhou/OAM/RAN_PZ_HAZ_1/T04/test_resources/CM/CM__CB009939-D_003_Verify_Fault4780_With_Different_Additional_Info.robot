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
${Wrong_BTS1_IP}    10.56.201.20
${Wrong_BTS2_IP}    10.56.201.21

*** Keywords ***
CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Verify fault4780 and its additional info when BTS detects a mismatch between its own baseband redundancy configuration
    ...    and corresponding settings in the peer BTS.
    ...    Case Precondition
    ...    Update actAutomaticSwitchover Mismatch And automaticSwitchoverTimer Same With Alarm
    ...    Remove actAutomaticSwitchover On Active BTS With Alarm
    ...    Update actAutomaticSwitchover Same And automaticSwitchoverTimer Mismatch With Alarm
    ...    Remove automaticSwitchoverTimer On Standby BTS With Alarm
    ...    Update actAutomaticSwitchover Mismatch And automaticSwitchoverTimer Mismatch With Alarm
    ...    Delete actAutomaticSwitchover And automaticSwitchoverTimer On Active BTS With Alarm
    ...    Update peerBtsIpAddress To Wrong IP In Both BTSs With Alarm
    ...    Update peerBtsIpAddress To Correct IP In Both BTSs With Alarm
    ...    Restart Two BTSs
    ...    Remove Redundancy And Check
    ...    Pass criteria: CELL of standby BTS should be offline, CELLs of active BTS should be onair,
	...    fault 4780 with different supplAlarmInfo in different scenario.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.07.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Update actAutomaticSwitchover Mismatch And automaticSwitchoverTimer Same With Alarm
    Step 3: Remove actAutomaticSwitchover On Active BTS With Alarm
    Step 4: Update actAutomaticSwitchover Same And automaticSwitchoverTimer Mismatch With Alarm
    Step 5: Remove automaticSwitchoverTimer On Standby BTS With Alarm
    Step 6: Update actAutomaticSwitchover Mismatch And automaticSwitchoverTimer Mismatch With Alarm
    Step 7: Delete actAutomaticSwitchover And automaticSwitchoverTimer On Active BTS With Alarm
    Step 8: Update peerBtsIpAddress To Wrong IP In Both BTSs With Alarm
    Step 9: Update peerBtsIpAddress To Correct IP In Both BTSs With Alarm
    Step 10: Restart Two BTSs
    Step 11: Remove Redundancy And Check

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
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=30    minCellAvailability=100
    ${parameters_dic2}    Create Dictionary
    ...    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby   peerBtsIpAddress=${MPLANE_IP}
    ...    actAutomaticSwitchover=true    automaticSwitchoverTimer=30    minCellAvailability=100
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=300
    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=300
    coam.assert_every    LNCEL    ${cells_LTE_offline_state}    timeout=300    connection=${REMOTE_ALIAS}
    coam.assert_every    NRCEL    ${cells_NR_offline_state}    timeout=300    connection=${REMOTE_ALIAS}
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=60s
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=60s    connection=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4737_4738_4739}

Step ${index}: Update ${parameter1} ${condition1} And ${parameter2} ${condition2} With Alarm
    Log To Console    Step ${index}: Update ${parameter1} ${condition1} And ${parameter2} ${condition2} With Alarm
    ${parm1_value1}    Set Variable    false
    ${parm1_value2}    Set Variable If    "${condition1}"=="Mismatch"    true    false
    ${parm2_value1}    Set Variable    30
    ${parm2_value2}    Set Variable If    "${condition2}"=="Mismatch"    300    30
    ${param_dic1}    Create Dictionary    ${parameter1}=${parm1_value1}    ${parameter2}=${parm2_value1}
    ${param_dic2}    Create Dictionary    ${parameter1}=${parm1_value2}    ${parameter2}=${parm2_value2}
    Config Redundancy    ${MRBTS_ID_1}    update    ${param_dic1}
    Config Redundancy    ${MRBTS_ID_2}    update    ${param_dic2}    ${REMOTE_ALIAS}
    ${fault_message}    Run Keyword If    "${condition1}"=="Mismatch" and "${condition2}"=="Same"    Set Variable    actAutomaticSwitchover mismatch
    ...    ELSE IF    "${condition1}"=="Same" and "${condition2}"=="Mismatch"    Set Variable    automaticSwitchoverTimer mismatch
    ...    ELSE IF    "${condition1}"=="Mismatch" and "${condition2}"=="Mismatch"
    ...    Set Variable    actAutomaticSwitchover and automaticSwitchoverTimer mismatch
    ${alarms_list}    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="${fault_message}"    timeout=300s


Step ${index}: Remove ${parameter} On ${role} BTS With Alarm
    Log To Console    Step ${index}: Remove ${parameter} On ${role} BTS With Alarm
    Run Keyword If    "${parameter}"=="automaticSwitchoverTimer"
    ...    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1    actAutomaticSwitchover    update    false
    Run Keyword If    "${parameter}"=="automaticSwitchoverTimer"
    ...    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1
    ...    actAutomaticSwitchover    update    false    connection=${REMOTE_ALIAS}
    ${alias}    Set Variable If    "${role}"=="Active"    default    ${REMOTE_ALIAS}
    ${MRBTS_ID}    Set Variable If    "${role}"=="Active"    ${MRBTS_ID_1}    ${MRBTS_ID_2}
    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/REDUNDANCY-1    ${parameter}    delete    value    connection=${alias}
    ${alarms_list}    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="${parameter} mismatch"    timeout=300s

Step ${index}: Delete ${parameter1} And ${parameter2} On ${role} BTS With Alarm
    Log To Console    Step ${index}: Delete ${parameter1} And ${parameter2} On ${role} BTS With Alarm
    ${alias}    Set Variable If    "${role}"=="Active"    default    ${REMOTE_ALIAS}
    ${MRBTS_ID}    Set Variable If    "${role}"=="Active"    ${MRBTS_ID_1}    ${MRBTS_ID_2}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/REDUNDANCY-1
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID}_${time}
    coam.append_managed_object_to_delta    ${dist_name}    update    ${MRBTS_ID}_${time}
    coam.append_parameter_delete_to_delta    ${dist_name}    ${parameter1}    ${MRBTS_ID}_${time}
    coam.append_parameter_delete_to_delta    ${dist_name}    ${parameter2}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}
    ${alarms_list}    coam.assert_alarm_active
    ...    faultId=4780, supplAlarmInfo="actAutomaticSwitchover and automaticSwitchoverTimer mismatch"    timeout=300s

Step ${index}: Update peerBtsIpAddress To Wrong IP In Both BTSs With Alarm
    Log To Console    Step ${index}: Update peerBtsIpAddress To Wrong IP In Both BTSs With Alarm
    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${Wrong_BTS2_IP}
    coam.Perform Parameter Recommissioning
    ...      MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${Wrong_BTS1_IP}    connection=${REMOTE_ALIAS}
    ${alarms_list}    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=300s
    ${alarms_list}    coam.assert_alarm_active
    ...      faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=300s    connection=${REMOTE_ALIAS}

Step ${index}: Update peerBtsIpAddress To Correct IP In Both BTSs With Alarm
    Log To Console    Step ${index}: Update peerBtsIpAddress To Correct IP In Both BTSs With Alarm
    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${BTS2_Mplane_IP}
    coam.Perform Parameter Recommissioning
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${MPLANE_IP}    connection=${REMOTE_ALIAS}
    ${alarms_list}    coam.assert_alarm_active
    ...    faultId=4780, supplAlarmInfo="actAutomaticSwitchover and automaticSwitchoverTimer mismatch"    timeout=300s
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=300s    connection=${REMOTE_ALIAS}

Step ${index}: Restart Two BTSs
    Log To Console    Step ${index}: Restart Two BTSs
    coam.reset_site
    coam.reset_site    connection=${REMOTE_ALIAS}
    Sleep    300s
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    ${alarms_list}    coam.assert_alarm_active
    ...    faultId=4780, supplAlarmInfo="actAutomaticSwitchover and automaticSwitchoverTimer mismatch"    timeout=300s
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=300s    connection=${REMOTE_ALIAS}


Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    #Remove Redundancy And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=180     expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    20x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS2
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=180    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20x    30 sec
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
