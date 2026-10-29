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
${NonMplane_BTS2_IP}    10.56.201.204
${NonBTS2_IP}    10.106.253.8    #SBTS1905 mplane
${BTS2_Mplane_IP}    10.56.201.205
${Wrong_BTS1_IP}    10.56.201.20

*** Keywords ***
CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Setup OAM-to-OAM connection between active and standby BTS via delta plan and full plan.
    ...    Check DoPR of new introduced parameter peerBtsIpAddress.
    ...    Case Precondition
    ...    Update Redundancy On BTS1 With NonMplane_BTS2_IP With Alarm
    ...    Remove peerBtsIpAddress On BTS1
    ...    Update Redundancy On BTS1 With NonBTS2_IP With Alarm
    ...    Remove peerBtsIpAddress On BTS1
    ...    Update Redundancy On BTS1 With BTS2_Mplane_IP With Alarm
    ...    Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    ...    Full Commissioning On BTS2 With Wrong BTS1 MplaneIp With Alarm
    ...    Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    ...    Remove Redundancy And Check
    ...  Pass criteria: CELL of standby BTS should be offline, CELLs of active BTS should be onair,
    ...    fault 4780 raised in different scenario.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.07.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Update Redundancy On BTS1 With NonMplane_BTS2_IP With Alarm
    Step 3: Remove peerBtsIpAddress On BTS1
    Step 4: Update Redundancy On BTS1 With NonBTS2_IP With Alarm
    Step 5: Remove peerBtsIpAddress On BTS1
    Step 6: Update Redundancy On BTS1 With BTS2_Mplane_IP With Alarm
    Step 7: Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    Step 8: Full Commissioning On BTS2 With Wrong BTS1 MplaneIp With Alarm
    Step 9: Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    Step 10: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    #Set Up 2rd Admin
    Remote BTS Setup    ${REMOTE_HOST_IP}    ${REMOTE_HOST_USER_NAME}    ${REMOTE_HOST_PASSWD}    ${REMOTE_ALIAS}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${bts_obj}    coam.Get parameters for all    BTS
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_1}    ${bts_id}
    ${bts_obj}    coam.Get parameters for all    BTS    alias=${REMOTE_ALIAS}
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_2}    ${bts_id}
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${parameters_dic1}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    ${parameters_dic2}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=300
    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=300
    coam.assert_every    LNCEL    ${cells_LTE_offline_state}    timeout=300    connection=${REMOTE_ALIAS}
    coam.assert_every    NRCEL    ${cells_NR_offline_state}    timeout=300    connection=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4737_4738_4739}

Step ${index}: Update Redundancy On BTS1 With ${Value} With Alarm
    Log To Console    Step ${index}: Update Redundancy On BTS1 With ${Value} With Alarm
    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${${Value}}
    #Fault4780 will be raised in BTS-1 side after 30s
    ${alarm_existed}    Run Keyword If    "${Value}"=="BTS2_Mplane_IP"    Run Keyword And Return Status
    ...    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=30s
    Run Keyword If    "${Value}"=="BTS2_Mplane_IP"    Should Not Be True    ${alarm_existed}
    ${alarms_list}    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=300s

Step ${index}: Remove peerBtsIpAddress On BTS1
    Log To Console    Step ${index}: Remove peerBtsIpAddress On BTS1
    coam.Perform Parameter Recommissioning    MRBTS-${MRBTS_ID_1}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    delete    value
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=300s

Step ${index}: Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    Log To Console    Step ${index}: Update Redundancy On BTS2 With BTS1_Mplane_IP Without Alarm
    coam.Perform Parameter Recommissioning
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1    peerBtsIpAddress    update    ${MPLANE_IP}    connection=${REMOTE_ALIAS}
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=300s
    ${alarms_list}    coam.assert_alarm_inactive    faultId=4780    timeout=300s    connection=${REMOTE_ALIAS}
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Check BTS Interfaces
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    5x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Full Commissioning On BTS2 With Wrong BTS1 MplaneIp With Alarm
    Log To Console    Step ${index}: Full Commissioning On BTS2 With Wrong BTS1 MplaneIp With Alarm
    ${full_scf_bts2}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS}    folder_path=${BTSFiles}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf_bts2}
    L_XML.Set Element Text    ${scf_xml}    ${Wrong_BTS1_IP}
    ...    xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/REDUNDANCY-1"]/p[@name="peerBtsIpAddress"]
    L_XML.Save Xml    ${scf_xml}    ${BTSFiles}/scf_bts2_wrong_bts1IP.xml
    coam.Perform Commissioning    ${MRBTS_ID_2}    ${BTSFiles}/scf_bts2_wrong_bts1IP.xml    skip_parameter_relation_errors=${TRUE}
    ...    timeout=600s    connection=${REMOTE_ALIAS}
    #need For BTS-1, fault4780 will be raised in BTS-1 side after about 2min30s.  150s cannot pass
    #For BTS-2, it will restart, after startup, fault4780 will be raised in BTS-2 side immediately.
    ${alarm_existed}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=720s
    Should Not Be True    ${alarm_existed}
    ${alarms_list}    coam.assert_alarm_active    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=300s
    ${alarms_list}    coam.assert_alarm_active
    ...    faultId=4780, supplAlarmInfo="SCTP path failure or peerBtsIpAddress mismatch"    timeout=300s    connection=${REMOTE_ALIAS}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    #Remove Redundancy And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
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