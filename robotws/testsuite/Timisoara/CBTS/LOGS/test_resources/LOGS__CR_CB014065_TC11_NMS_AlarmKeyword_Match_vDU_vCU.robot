*** Settings ***
Documentation
...    Tests for CB013203 snapshot with SDL
Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Library     taf.hw.pdu     WITH NAME   pdu
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library  taf.gnb.oam.coam.cu.interface    WITH NAME  vcu
Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot
Resource    ../resources/unpacking.robot
Resource  ../resources/AIC_NetAct.robot
Resource    ../resources/ssh_utils.robot
Variables  ../resources/python/My_NetAct.py

#Suite Setup       Suite Precondition

*** Variables ***

${NA_OMC_PASS}   Medsql!_1893
${NA_OMC_LOGIN}    omc
#${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
#${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
#@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
#${RELEASE_VERSION}    26R2


*** Keywords ***
TC__LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU
    [Documentation]
    ...  CB014065 test

    Step 0: Precondition
    Step 1: Update vDU snapshot object
    Step 2: Update vDU fault snapshot trigger list with FID 10
    Step 3: Trigger FID 10
    Step 4: Check vDU Snapshot on NMS
    Step 5: Return state vDU and clear alarm
    Step 6: Update vCU snapshot object
    Step 7: Update vCU fault snapshot trigger list with FID 7107
    Step 8: Trigger FID 7107
    Step 9: Check vCU Snapshot on NMS

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
    Log    \nStep 0: Precondition    console=${True}
    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}
    Set Test Variable    ${logs_dir}    ${TEST_RESULTS_DIR}
#    Set Test Variable  ${vdu_id}    ${VDU_MRBTS_ID}
#    Set Test Variable  ${vcu_id}    ${VCU_MRBTS_ID}

    ${vdu_data}  vdu.Get Vdu State Data
    Set Test Variable  ${VDU_SW}  ${vdu_data}[software_version]
    ${snapshot_name_vdu}  Set Variable  *Snapshot_MRBTS-${VDU_MRBTS_ID}_*_${VDU_SW}_*
    Set Test Variable    ${snapshot_name_vdu}
    ${vcu_data}  vcu.Get cu State
    Set Test Variable   ${VCU_SW}  ${vcu_data}[software_version]
    Set Test Variable   ${VCU_name}  ${vcu_data}[bts_name]
    Set Test Variable       ${snapshot_name_vcu}    *Snapshot_MRBTS-${VCU_MRBTS_ID}_${VCU_name}_${VCU_SW}_*
    Set Test Variable   ${na_node_ip}    ${netact['sn_node']}
	${software_version}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    log to console    sw version is: ${software_version}
    ${release}     Fetch From Right  ${software_version}  CNF
    log to console    versiune de netact:${release}VCU
    Setup NetAct    ${netact}
    Integrate NE To NetAct
    ...    mrbts_addr=${VDU_OAM_IP}    dist_name=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}   release_version=${release}VDU  mr=MRC-COMMON/MR-CLOUD
    Integrate NE To NetAct
    ...    mrbts_addr=${VCU_OAM_IP}    dist_name=PLMN-PLMN/MRBTS-${VCU_MRBTS_ID}   release_version=${release}VCU  mr=MRC-COMMON/MR-CLOUD


Step 1: Update vDU snapshot object
    Log    \nStep 1: Update vDU snapshot object    console=${True}
    Delete faultSnapshotTriggers
    Update maxNumSnapByFaultTrigPerDay
    Update diagSnapDestination

Step 2: Update vDU fault snapshot trigger list with FID 10
    Log    \nStep 2: Update vDU fault snapshot trigger list with FID 10    console=${True}
    Configure Snapshot Trigger For Fault 10 on vDU

Step 3: Trigger FID 10
    Log    \nStep 3: Trigger FID 10    console=${True}
    RMOD power off
    log to console    check cell status should be disabled for du...
    Wait until keyword succeeds   5x    10s   Check Active Alarm VDU    7116    10

Step 4: Check vDU Snapshot on NMS
    Log    \nStep 4: Check vDU Snapshot on NMS    console=${True}
    Set Test Variable    ${j}    0
    Wait Until Keyword Succeeds    10x    60s      Check Snapshot on NMS    snapshot_name=${snapshot_name_vdu}
    Copy snapshot and cleanup    snapshot_name=${snapshot_name_vdu}

Step 5: Return state vDU and clear alarm
    Log    \nStep 5: Return state vDU and clear alarm    console=${True}
    RMOD power on
    log to console    Wait alarm cleared
    sleep    2min
    Wait alarm clear    7166    10

Step 6: Update vCU snapshot object
    Log    \nStep 6: Update vCU snapshot object    console=${True}
    vCU Delete faultSnapshotTriggers
    vCU Update maxNumSnapByFaultTrigPerDay
    vCU Update diagSnapDestination

Step 7: Update vCU fault snapshot trigger list with FID 7107
    Log    \nStep 7: Update vCU fault snapshot trigger list with FID 7107    console=${True}
    Update vCU fault snapshot trigger list with FID 7107

Step 8: Trigger FID 7107
    Log    \nStep 8: Trigger FID 7107   console=${True}
    Trigger FID 7107

Step 9: Check vCU Snapshot on NMS
    Log    \nStep 9: Check vCU Snapshot on NMS    console=${True}
    Set Test Variable    ${j}    0
    Wait Until Keyword Succeeds    15x    60s      Check Snapshot on NMS    snapshot_name=${snapshot_name_vcu}
    Copy snapshot and cleanup    snapshot_name=${snapshot_name_vdu}

Trigger FID 7107
    ${X2linkID}  vcu.Get x2 links info
#    Log to console    ${X2linkID}[created]
#    ${lenght}=    BuiltIn.Get Length     ${X2linkID}[created]
    ${x2_link_id}=    Get From Dictionary    ${X2linkID}[created][0]    id
    ${x2_link_id_list}=    Create List    ${x2_link_id}
    vcu.lock x2 links    ${x2_link_id_list}
    Sleep   5s
    Wait until keyword succeeds   7x    10s   Check Active Alarm VCU    7114    7107
    vcu.unlock x2 links    ${x2_link_id_list}
    Sleep   300s
    Wait alarm clear    7114    7107


Check Snapshot on NMS
    [Documentation]    Check if snapshot is on netact
    [Arguments]      ${snapshot_name}
#    Log  \nStep 3: Check if snapshot is on netact  console=${True}
    ${j}  evaluate  ${j} + 1
    Set Test Variable  ${j}
    Log to console    iteratia:${j}
#    Log to console      ${netact['sn_node']}
#    Sleep  800s
#    ${na_node_ip}  Set Variable   ${netact['sn_node']}
#    ${NA_OMC_PASS}  Set Variable  Medsql!_1893
#    ${NA_OMC_LOGIN}  Set Variable  omc
    ${cmd}  Set Variable  find /d/oss/global/diagsnap/ne3sws -maxdepth 1 -name ${snapshot_name} -cmin -15 2>/dev/null
#    ${cmd_rm}    Set Variable    rm -rf /d/oss/global/diagsnap/ne3sws/${snapshot_name}
    ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
#    ${dir_content}  ssh_utils.Run Command    ls
    ${snapshot_name_with_path}  ssh_utils.Run Command  ${cmd}
    ${snapshot_name_with_path}  Convert To String  ${snapshot_name_with_path}
    log to console    snap:${snapshot_name_with_path}

    ${snap_dest_on_netact}    Fetch from left   ${snapshot_name_with_path}  \r\n
    Set Test Variable    ${snap_dest_on_netact}
    Run Keyword If  '${snap_dest_on_netact}' == '${EMPTY}'
    ...   Fail   Snapshot NOT found on NetAct    console=${True}
    ...   ELSE    Log    Snapshot found on NetAct  console=${True}
#    ${isEmpty}  Get length  ${snap_dest_on_netact}
#    Run Keyword If  ${isEmpty}==0
##    ...   verdicts.Set Test Failed  Snapshot NOT found on NetAct.  ${TRUE}
#    ...   Fail   Snapshot NOT found on NetAct    console=${True}
#    ...   ELSE    Log    Snapshot found on NetAct  console=${True}
#    Copy snapshot and cleanup

Copy snapshot and cleanup
    [Arguments]      ${snapshot_name}
#      Set Test Variable  ${snap_dest_on_netact}    ${snapshot_name_with_path.replace("\r\n", " ")}
    ${cmd_rm}    Set Variable    rm -rf /d/oss/global/diagsnap/ne3sws/${snapshot_name}
    Run  sshpass -p '${NA_OMC_PASS}' scp ${NA_OMC_LOGIN}@${na_node_ip}:${snap_dest_on_netact} "${TEST_RESULTS_DIR}"
    Sleep  30s
    ${download_snapshot_name}  Fetch From Right  ${snap_dest_on_netact}  /
    ${download_snapshot_name}  Set Variable  ${download_snapshot_name.rstrip()}
    ${path_to_snapshot_from_NetAct}  Set Variable  ${TEST_RESULTS_DIR}/${download_snapshot_name}
    OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/${download_snapshot_name}
    ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
    ssh_utils.Run Command  ${cmd_rm}
    Log  Snapshot "${download_snapshot_name}" was found on NetAct and downloaded to local disk  console=${true}
    Set Test Variable  ${path_to_snapshot_from_NetAct}


RMOD power on
    Log To Console    RMOD power on
    pdu.setup_pdu    model=EPC    host=10.255.1.72    alias=Gude    version=8220-1
    pdu.power_off    4   pdu_device=Gude
    pdu.teardown_pdu    pdu_device=Gude


RMOD power off
    Log To Console    RMOD power off
    pdu.setup_pdu    model=EPC    host=10.255.1.72    alias=Gude    version=8220-1
    pdu.power_on    4   pdu_device=Gude
    pdu.teardown_pdu    pdu_device=Gude


Delete faultSnapshotTriggers
    ${parameter1}  Create Dictionary      parameterName=actDefaultFaultSnapTriggers    operation=update    value=false
    ${parameter_change_list1}  Create List  ${parameter1}
    ${parameter_changed_param1}   Create Dictionary    distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list1}

    ${parameter2}  Create Dictionary      parameterName=faultSnapshotTriggers    operation=delete
    ${parameter_change_list2}  Create List  ${parameter2}
    ${parameter_changed_param2}   Create Dictionary    distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list2}

    ${changed_parameter_list}  Create List        ${parameter_changed_param1}  ${parameter_changed_param2}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vdu.Perform Delta Recommissioning  ${changed_parameters_string}


vCU Delete faultSnapshotTriggers
    ${parameter1}  Create Dictionary      parameterName=actDefaultFaultSnapTriggers    operation=update    value=false
    ${parameter_change_list1}  Create List  ${parameter1}
    ${parameter_changed_param1}   Create Dictionary    distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list1}

    ${parameter2}  Create Dictionary      parameterName=faultSnapshotTriggers    operation=delete
    ${parameter_change_list2}  Create List  ${parameter2}
    ${parameter_changed_param2}   Create Dictionary    distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list2}

    ${changed_parameter_list}  Create List        ${parameter_changed_param1}    ${parameter_changed_param2}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}



Update maxNumSnapByFaultTrigPerDay

    ${parameter3}  Create Dictionary      parameterName=maxNumSnapByFaultTrigPerDay    operation=update    value=20
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vdu.Perform Delta Recommissioning  ${changed_parameters_string}

vCU Update maxNumSnapByFaultTrigPerDay

    ${parameter3}  Create Dictionary      parameterName=maxNumSnapByFaultTrigPerDay    operation=update    value=20
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}

Update diagSnapDestination

    ${parameter3}  Create Dictionary      parameterName=diagSnapDestination    operation=update    value=nms
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vdu.Perform Delta Recommissioning  ${changed_parameters_string}

vCU Update diagSnapDestination
    ${parameter3}  Create Dictionary      parameterName=diagSnapDestination    operation=update    value=nms
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}

Configure Snapshot Trigger For Fault 10 on vDU
    [Documentation]    Description:    This keyword configures snapshot trigger for fault 7104 with
    ...                                triggerType=onAlarmSend on vDU.
    Log    Configuring snapshot trigger for fault 10    console=${True}
    ${complex_param_dict}=    Create Dictionary    faultNumber=10
    ...                                            triggerType=onAlarmSend
    ...                                            alarmFaultKeywords=RU power loss
    ...                                            snapshotCoverageLevel=Full
    ${complex_param_list}=    Create List          ${complex_param_dict}

    ${param_dict}=            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                            value=${complex_param_list}
    ...                                            operation=create
    ${param_list}=            Create List          ${param_dict}

    ${change_dict}=           Create Dictionary    distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            operation=create
    ...                                            parameters=${param_list}
    ${delta}=                 Create List          ${change_dict}
    ${delta_json}=            Evaluate             json.dumps(${delta})    json
    vdu.Perform Delta Recommissioning    delta_file=${delta_json}


Update vCU fault snapshot trigger list with FID 7107
    [Documentation]    Description:    This keyword configures snapshot trigger for fault 7107 with
    ...                                triggerType=onAlarmSend on vCU.
    Log    Configuring snapshot trigger for fault 7107    console=${True}
    ${complex_param_dict}=    Create Dictionary    faultNumber=7107
    ...                                            triggerType=onAlarmSend
    ...                                            alarmFaultKeywords=link-status-change
    ...                                            snapshotCoverageLevel=Full
    ${complex_param_list}=    Create List          ${complex_param_dict}

    ${param_dict}=            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                            value=${complex_param_list}
    ...                                            operation=create
    ${param_list}=            Create List          ${param_dict}

    ${change_dict}=           Create Dictionary    distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            operation=create
    ...                                            parameters=${param_list}
    ${delta}=                 Create List          ${change_dict}
    ${delta_json}=            Evaluate             json.dumps(${delta})    json
    vcu.Perform Delta Recommissioning    delta_file=${delta_json}


Check Active Alarm VCU
    [Arguments]  ${alarm_id}  ${fault_id}
     Set Test Variable    ${alarm_presence}     ${False}

     ${active_alarms}  Vcu.Get Active Alarms
     ${alarms_list}  Set Variable  ${active_alarms}[alarms]
     Set Test Variable    ${alarm_presence}    ${False}
     FOR  ${alarm}  IN  @{alarms_list}
#        Set Test Variable    ${alarm_presence}     ${False}

        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        Run Keyword If  ${status_alarm_id} and ${status_fault_id}
        ...  Run Keywords    Set Test Variable    ${alarm_presence}    ${True}
        ...  AND    Log  Alarm:${fault_id} is visible in active alarms
        ...  AND    Exit For Loop

     END
    Run Keyword If   ${alarm_presence}
        ...    Log  Alarm:${fault_id} is visible in active alarms
        ...    ELSE
        ...    Fail  Alarm with fault id: ${fault_id} is not visible in WebEM. [NOK]

Check Active Alarm VDU
    [Arguments]  ${alarm_id}  ${fault_id}
     Set Test Variable    ${alarm_presence}     ${False}

     ${active_alarms}  vdu.Vdu Get Active Alarms
     ${alarms_list}  Set Variable  ${active_alarms}[alarms]
     Set Test Variable    ${alarm_presence}    ${False}
     FOR  ${alarm}  IN  @{alarms_list}
#        Set Test Variable    ${alarm_presence}     ${False}

        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        Run Keyword If  ${status_alarm_id} and ${status_fault_id}
        ...  Run Keywords    Set Test Variable    ${alarm_presence}    ${True}
        ...  AND    Log  Alarm:${fault_id} is visible in active alarms
        ...  AND    Exit For Loop

     END
    Run Keyword If   ${alarm_presence}
        ...    Log  Alarm:${fault_id} is visible in active alarms
        ...    ELSE
        ...    Fail  Alarm with fault id: ${fault_id} is not visible in WebEM. [NOK]

Wait alarm clear
    [Arguments]    ${alarm_id}    ${fault_id}
    ${alarm_status}    run keyword and return status    Check Active Alarm VCU    ${alarm_id}    ${fault_id}
    Run keyword if  ${alarm_status}
    ...  Fail    Fault ${fault_id} " - still present  console=${True}
    ...  ELSE PASS    Fault ${fault_id} - ok cleared  console=${True}

TC Setup
    Common VDU Setup
    Common VCU Setup   modules_check=${FALSE}

TC Teardown
    [Documentation]
    ...   Teardown test
    Log    \nTeardown: teardown test    console=${True}
    RMOD power on
    Deintegrate NE From NetAct     dist_name=PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}
    Deintegrate NE From NetAct     dist_name=PLMN-PLMN/MRBTS-${VCU_MRBTS_ID}
    Logs To Rotta Copy
