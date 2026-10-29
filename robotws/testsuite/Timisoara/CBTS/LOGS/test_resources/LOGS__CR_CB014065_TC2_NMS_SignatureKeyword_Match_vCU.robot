*** Settings ***
Documentation
...    Tests for CB016065 CR
Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Library     taf.hw.pdu     WITH NAME   pdu
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library  taf.gnb.oam.coam.cu.interface    WITH NAME  vcu
Library    taf.nms.netact     WITH NAME    netact
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

*** Keywords ***
TC__LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU
    [Documentation]
    ...  CB014065 test

    Step 0: Precondition
    Step 1: Update vCU snapshot object
    Step 2: Update vCU fault snapshot trigger list with FID 4592
    Step 3: Trigger 4592 and check alarm history
    Step 4: Check vCU Snapshot on NMS

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
    Log    \nStep 0: Precondition    console=${True}
    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}
    Set Test Variable    ${logs_dir}    ${TEST_RESULTS_DIR}
    Set Test Variable  ${vdu_id}    ${VDU_MRBTS_ID}
    ${vdu_data}  vdu.Get Vdu State Data
    Set Test Variable  ${VDU_SW}  ${vdu_data}[software_version]
    ${snapshot_name_vdu}  Set Variable  *Snapshot_MRBTS-${vdu_id}_*_${VDU_SW}_*
    Set Test Variable    ${snapshot_name_vdu}
    ${vcu_data}  vcu.Get cu State
    Set Test Variable   ${VCU_SW}  ${vcu_data}[software_version]
    Set Test Variable   ${VCU_name}  ${vcu_data}[bts_name]
     Set Test Variable       ${snapshot_name_vcu}    *Snapshot_MRBTS-${VCU_MRBTS_ID}_${VCU_name}_${VCU_SW}_*
    Set Test Variable   ${na_node_ip}    ${netact['sn_node']}
    ${software_version}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    log to console    sw version is: ${software_version}
    ${release}     Fetch From Right  ${software_version}  CNF
    Setup NetAct    ${netact}
    Integrate NE To NetAct
    ...    mrbts_addr=${VCU_OAM_IP}    dist_name=PLMN-PLMN/MRBTS-${VCU_MRBTS_ID}   release_version=${release}VCU   mr=MRC-COMMON/MR-CLOUD

Step 1: Update vCU snapshot object
    vCU Delete faultSnapshotTriggers
    vCU Update maxNumSnapByFaultTrigPerDay
    vCU Update diagSnapDestination

Step 2: Update vCU fault snapshot trigger list with FID 4592
    Update vCU fault snapshot trigger list with FID 4592

Step 3: Trigger 4592 and check alarm history

    FOR     ${i}    IN RANGE    3
        ${timestamp}  Get Current Date  exclude_millis=true     increment=2 hours
        Set Test Variable  ${FAULT_TIMESTAMP_before}  ${timestamp}
        Reboot VCU
        ${result}   Check alarm history for FS
        Exit For Loop If    ${result} == True
    END

Step 4: Check vCU Snapshot on NMS
    Check Snapshot on NMS    snapshot_name=${snapshot_name_vcu}

Reboot VCU
    Reset VCU And Wait For Ping
    Wait Until Keyword Succeeds  900s  10s  Check All Cells From VCU  operational_state="Enabled|enabled"

Check alarm history for FS

    ${alarms_history}  vcu.Get Historical Alarms  sorted_by=appearTime  sort_order=desc  filter_by_text=4592
    log to console    ${alarms_history} #[alarms][0]
    Run Keyword If  ${alarms_history}[total]==0
    ...  Fail  Error: "No alarm ${parameters}[alarm_id] was found in alarm history" [NOK].
    ${alarm_entry}  Set Variable  ${alarms_history}[alarms][0]
    ${alarm_id}  Set Variable  ${alarm_entry}[alarm_id]

    ${last_alarm_time}  Set Variable  ${alarm_entry}[appear_time]
    ${last_alarm_time}  Replace String  ${last_alarm_time}  T  ${SPACE}
    ${last_alarm_time}  Fetch From Left  ${last_alarm_time}  .

    ${post_check_start_timestamp}    DateTime.Convert Date    ${FAULT_TIMESTAMP_before}    result_format=epoch
    ${post_check_stop_timestamp}     DateTime.Convert Date    ${last_alarm_time}     result_format=epoch
    Run Keyword And Continue On Failure    Should Be True     ${post_check_stop_timestamp} > ${post_check_start_timestamp}
        ...  msg= Fault alarm time ok
    ${FS_present}   Run Keyword And Return Status    Get From Dictionary    ${alarm_entry}    fault_signature

    [Return]     ${FS_present}

Trigger FID 4350

    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable   ${ip_addr}  ${vcu_ssh_connection_params['ip_addr']}
    Set Test Variable   ${username}  ${vcu_ssh_connection_params['username']}
    Set Test Variable   ${password}  ${vcu_ssh_connection_params['password']}

    ${command_pod}    Set variable    oc get pod -n cran150 |grep cpue | awk \'{print $1}\'
    ${command_ctr_begin}    Set variable    oc -n cran150 describe pod

    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp

    ${pod}    ssh.Execute  ${command_pod}  connection=ocp
    ${pod}=    Fetch from left   ${pod}  \r\n
    ${command_ctr}=  catenate  ${command_ctr_begin} ${pod} |grep ctr-cpue | awk 'NR==1 {print $2}'
    ${command_ctr}=    Fetch from left   ${command_ctr}  \r\n
    ${cont}    ssh.Execute  ${command_ctr}  connection=ocp
    ${cont}=    Fetch from left   ${cont}  \r\n
    Set Test Variable    ${cmd_kctl_new}    kubectl exec -it -n cran150 ${pod} -c ${cont} -- bash

    Login SSH
#    read until prompt
    Write    ${cmd_kctl_new}
    ${output}=  Read  delay=2s
    Write    ps -eaf | grep Daemon | awk 'NR==1 {print $2}'
    ${output}=  Read  delay=2s
    ${pid_cpue}=    Fetch from left   ${output}  \r\n
    Write    kill -11 ${pid_cpue}
    ${output}=  Read  delay=2s

    Log to console    Kill cpue second time, sleep 20s
    sleep    20s

    Write    ps -eaf | grep Daemon | awk 'NR==1 {print $2}'
    ${output}=  Read  delay=2s
    ${pid_cpue}=    Fetch from left   ${output}  \r\n
    Write    kill -11 ${pid_cpue}
    ${output}=  Read  delay=2s

Login SSH
    Open Connection  ${ip_addr}
    Login  core  ${password}

Check Snapshot on NMS
    [Documentation]    Check if snapshot is on netact
    [Arguments]      ${snapshot_name}
    Log  \nStep 3: Check if snapshot is on netact  console=${True}

    Log to console      ${netact['sn_node']}
    Sleep  800s
    ${na_node_ip}  Set Variable   ${netact['sn_node']}
    ${NA_OMC_PASS}  Set Variable  Medsql!_1893
    ${NA_OMC_LOGIN}  Set Variable  omc
    ${cmd}  Set Variable  find /d/oss/global/diagsnap/ne3sws -name ${snapshot_name} -cmin -15 2>/dev/null
    ${cmd_rm}    Set Variable    rm -rf /d/oss/global/diagsnap/ne3sws/${snapshot_name}
    ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
    ${snapshot_name_with_path}  ssh_utils.Run Command  ${cmd}
    ${snapshot_name_with_path}  Convert To String  ${snapshot_name_with_path}
    ${snap_dest_on_netact}  Set Variable  ${snapshot_name_with_path.replace("\r\n", " ")}
     ${isEmpty}  Get length  ${snap_dest_on_netact}
    Run Keyword If  ${isEmpty}==0
    ...   verdicts.Set Test Failed  Snapshot NOT found on NetAct.  ${TRUE}
    ...   ELSE   Log   Snapshot found on NetAct   console=true
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

vCU Delete faultSnapshotTriggers
    ${parameter1}  Create Dictionary      parameterName=actDefaultFaultSnapTriggers    operation=update    value=false
    ${parameter_change_list1}  Create List  ${parameter1}
    ${parameter_changed_param1}   Create Dictionary    distName=MRBTS-10050/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list1}

    ${parameter2}  Create Dictionary      parameterName=faultSnapshotTriggers    operation=delete
    ${parameter_change_list2}  Create List  ${parameter2}
    ${parameter_changed_param2}   Create Dictionary    distName=MRBTS-10050/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list2}

    ${changed_parameter_list}  Create List        ${parameter_changed_param1}    ${parameter_changed_param2}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}

vCU Update maxNumSnapByFaultTrigPerDay

    ${parameter3}  Create Dictionary      parameterName=maxNumSnapByFaultTrigPerDay    operation=update    value=20
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-10050/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}

vCU Update diagSnapDestination
    ${parameter3}  Create Dictionary      parameterName=diagSnapDestination    operation=update    value=nms
    ${parameter_change_list3}  Create List  ${parameter3}
    ${parameter_changed_param3}   Create Dictionary    distName=MRBTS-10050/MNL-1/MNLENT-1/TRBLCADM-1     operation=update
    ...    parameters=${parameter_change_list3}

    ${changed_parameter_list}  Create List    ${parameter_changed_param3}
	${changed_parameters_string}  Evaluate  json.dumps(${changed_parameter_list})  json
	vcu.Perform Delta Recommissioning  ${changed_parameters_string}

Update vCU fault snapshot trigger list with FID 4592
    [Documentation]    Description:    This keyword configures snapshot trigger for fault 4350 with
    ...                                triggerType=onAlarmSend on vCU.
    Log    Configuring snapshot trigger for fault 4350    console=${True}
    ${complex_param_dict}=    Create Dictionary    faultNumber=4592
    ...                                            triggerType=onAlarmCancellation
    ...                                            faultSignatureKeywords=OAM_RESET
    ...                                            snapshotCoverageLevel=Full
    ${complex_param_list}=    Create List          ${complex_param_dict}

    ${param_dict}=            Create Dictionary    parameterName=faultSnapshotTriggers
    ...                                            value=${complex_param_list}
    ...                                            operation=create
    ${param_list}=            Create List          ${param_dict}

    ${change_dict}=           Create Dictionary    distName=MRBTS-10050/MNL-1/MNLENT-1/TRBLCADM-1
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

TC Setup
    Common VDU Setup    modules_check=${FALSE}    cells_check=${FALSE}
    Common VCU Setup   modules_check=${FALSE}

TC Teardown
    [Documentation]
    ...   Teardown test
    Log    \nTeardown: teardown test    console=${True}
    Deintegrate NE From NetAct     dist_name=PLMN-PLMN/MRBTS-10050
    Logs To Rotta Copy
