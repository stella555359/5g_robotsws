*** Settings ***
Documentation
...   author: cristinel.sava@nokia.com
...   contact: cristinel.sava@nokia.com
...   update: cristinel.sava@nokia.com

Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Library    taf.transport.ssh         WITH NAME    tafssh
Library    taf.rfrl.cbts.utilities.generic_utils
Library    taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library    taf.rfrl.cbts.devices.vdu.business.vdu_cm_business    WITH NAME   vdu_cm_business
Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot
Library    taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    taf.gnb.oam.coam.vdu.interface.vdu   WITH NAME  vdu1
Library    taf.rfrl.cbts.utilities.generic_utils    WITH NAME    generic_utils
Library           json


Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot


*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
${REVERT_DELTA_CHANGES}    ${False}

${cell_list}    1
*** Keywords ***
TC__LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Documentation]
    ...  CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct

    Set Tags  CA-VRF7  OWNER-cristinel.sava@nokia.com  AUTHOR-cristinel.sava@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS26R2  FEATURE-CB006483-5G-D

    Step 0: Precondition
    Step 1: Update max number of snapshots by fault triggers per day
    Step 2:Testing block cell trigger vdu snapshot collection for 1st time
    Step 3:Testing block cell trigger vdu snapshot collection for 2nd time
    Step 4:Testing block cell trigger vdu snapshot collection failure for 3rd time
    Step 5:Check Diagnostic Snapshot Collection via substring trigger for 4th time
    Step 6:Testing block cell trigger vdu snapshot collection failure for 5th time

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
     Log    \nStep 0: Precondition    console=${True}
     Log    \nConnecting to vDU and set all necessary variables   console=${True}

#    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
#    ${rmod_listed}    vdu.get rmods status
#    ${ids}    Create List
#    Set Test Variable    ${ids}
#    ${serial_numbers}      Create List

#    FOR    ${item}    IN    @{rmod_listed}
#        ${serial_number}    Get From Dictionary    ${item}    serial_number
#        ${id}    Get From Dictionary    ${item}    id
#        ${dist_names}    Get From Dictionary    ${item}    dist_names
#        Append To List    ${ids}    ${id}
#    END
#
#    ${config_value}    Set Variable    ${dist_names['config']}
#    ${split}    Split String    ${config_value}    /
#    ${mr_id}    Get From List    ${split}    0
#    ${vdu_id}    Split String    ${mr_id}    -
#    ${vdu_id}    Get From List    ${vdu_id}   1
    Set Test Variable  ${vdu_id}    ${VDU_MRBTS_ID}

    ${date}     Get Current Date    time_zone=UTC    result_format=%Y-%m-%d
    Set Test Variable    ${date}

#    Set Test Variable    ${logs_dir}    ${TEST_RESULTS_DIR}
#
#    Run    mkdir -p ${logs_dir}/snapshotON
#    Run    mkdir -p ${logs_dir}/snapshotOFF
#    Run    mkdir -p ${logs_dir}/RU_permanent_filesON
#    Run    mkdir -p ${logs_dir}/RU_permanent_filesOFF

#    sleep    3

Step 1: Update max number of snapshots by fault triggers per day

    Log    \nStep 1 Update max number of snapshots by fault triggers per day    console=${True}

    Add Trigger Fault 49
    Update Snapshot Configuration to NetAct     #max=2
    Reset VDU
#    Reset VDU And Wait For Ping
    Connect To VDU  host=${VDU_OAM_IP}
    wait until keyword succeeds     15min    30s     Check Cells To Be OnAir
    sleep    60    reason=wait for vdu ready to operate
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  alias=${alias}

Step 2:Testing block cell trigger vdu snapshot collection for 1st time
    Log    \nStep 2 Testing block cell trigger vdu snapshot collection for 1st time    console=${True}

    ${time}    Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}

    vdu.Block cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${True}

    wait until keyword succeeds    1min    10sec    Check Diagnostic Snapshot Collection Info
    ...   diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection    diagSnapFilename=${EMPTY}

    wait until keyword succeeds    10min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection ready    diagSnapFilename=${VDU_MRBTS_NAME}
    sleep    10s
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    unblock cell: ${cell_id}
    vdu.Unblock cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${False}
    Connect To VDU  host=${VDU_OAM_IP}
    wait until keyword succeeds     15min    30s     Check Cells To Be OnAir
    Log to Console    cells are OnAir
    sleep    15min

Step 3:Testing block cell trigger vdu snapshot collection for 2nd time
    Log    \nStep 3 Testing block cell trigger vdu snapshot collection for 2nd time    console=${True}

    ${time}    Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}
    vdu.Block cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${True}

    wait until keyword succeeds    1min    10sec    Check Diagnostic Snapshot Collection Info
    ...   diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection    diagSnapFilename=${EMPTY}

    wait until keyword succeeds    10min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection ready    diagSnapFilename=${VDU_MRBTS_NAME}
    sleep    10s
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    unblock cell: ${cell_id}
    vdu.Unblock cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${False}
    sleep    15min

Step 4:Testing block cell trigger vdu snapshot collection failure for 3rd time
    Log    \nStep 4 Testing block cell trigger vdu snapshot collection failure for 3rd time    console=${True}

    ${time}      Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}
    vdu.Block cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${True}

    check upload failed in snapshot history
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    unblock cell: ${cell_id}
    vdu.Unblock cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec    Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${False}
    Connect To VDU  host=${VDU_OAM_IP}
    wait until keyword succeeds     15min    30s     Check Cells To Be OnAir
    sleep    15min

Step 5:Check Diagnostic Snapshot Collection via substring trigger for 4th time
    Log    \nStep 5: Check Diagnostic Snapshot Collection via substring trigger for 4th time

    ${time}      Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}
    Recovery Snapshot Configuration to NetAct
    ${set_value}    set variable    cell state is disabled, procedure is CellInIdle
    Set Syslog Substring Trigger Value    set_value=${set_value}
    ...    operation=add
    VDU Reset Cell   cell_id=${cell_list[0]}
    wait until keyword succeeds    15min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=substring cell state is disabled, procedure is CellInIdle trigger snapshot
    ...    diagSnapState=Collection ready    diagSnapFilename=Snapshot_MRBTS-${VDU_MRBTS_ID}
    Connect To VDU  host=${VDU_OAM_IP}
    wait until keyword succeeds     10min    5s     Check Cells To Be OnAir
    sleep    15min

Step 6:Testing block cell trigger vdu snapshot collection failure for 5th time
    Log to Console    Step 6 Testing block cell trigger vdu snapshot collection failure for 5rd time
    ${time}    Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}
#    ${cell_list}    vDU Get Cells ID list
    vdu.Block cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec     Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${True}
    Sleep    5s
    check upload failed in snapshot history
    Log to Console    unblock cell: ${cell_id}
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    unblock cell: ${cell_id}
    vdu.Unblock cell  cell_id=${cell_id}
    wait until keyword succeeds    3min    5sec    Check Alarm exist in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_id}
    ...    exist=${False}
    Connect To VDU  host=${VDU_OAM_IP}
    wait until keyword succeeds     15min    30s     Check Cells To Be OnAir

Add Trigger Fault 49
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${alarm_dict}    create dictionary    faultNumber=${49}    triggerType=onFaultDetection    snapshotCoverageLevel=Full
    ${faultSnapshotTriggers}    create list    ${alarm_dict}
    ${distname}    Set Variable   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'faultSnapshotTriggers': ${faultSnapshotTriggers}}, 'replace']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${exist}    set variable    ${False}
    FOR    ${fault}    IN    @{faultSnapshotTriggers}
        ${status}    run keyword and return status    dictionary should contain sub dictionary    ${fault}    ${alarm_dict}
        ${exist}    set variable if    ${status}    ${True}    ${False}
    END
    should be true    ${exist}    msg=Trigger fault 49 not in triggers!
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Update Snapshot Configuration to NetAct
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nUpdate Snapshot Configuration to NetAct
	${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
	${delta_data_list}    run keyword if    '${diagSnapDestination}'=='nms'    Evaluate
    ...    [['${distname}', {'maxNumSnapByFaultTrigPerDay': '2'}, 'replace']]    ELSE    Evaluate
    ...    [['${distname}', {'diagSnapDestination': 'nms', 'lssConfig': 'null', 'maxNumSnapByFaultTrigPerDay': '2'}, 'replace']]
    ${out}   vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Recovery Snapshot Configuration to NetAct
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nUpdate Snapshot Configuration to NetAct
	${diagSnapDestination}    Get Diagnostic Snapshot Destination
    ${distname}    Set Variable   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
	${delta_data_list}    run keyword if    '${diagSnapDestination}'=='nms'    Evaluate
    ...    [['${distname}', {'maxNumSnapByFaultTrigPerDay': '20'}, 'replace']]    ELSE    Evaluate
    ...    [['${distname}', {'diagSnapDestination': 'nms', 'lssConfig': 'null', 'maxNumSnapByFaultTrigPerDay': '20'}, 'replace']]
    ${out}   vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Check Diagnostic Snapshot Collection Info
    [Arguments]
    ...    ${diagSnapAddInfo}=49 - On fault detection
    ...    ${diagSnapState}=Collection ready
    ...    ${diagSnapFilename}=Snapshot_MRBTS
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1/TRBLCADM_R-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM_R
    ...    dist_names=${dist_names}
    ${trblcadm_r}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm_r['json_repr']}
    ${BTS_diagSnapAddInfo}    set variable    ${json_repr['diagSnapAddInfo']}
    should contain    ${BTS_diagSnapAddInfo}    ${diagSnapAddInfo}
    ${BTS_diagSnapState}    set variable    ${json_repr['diagSnapState']}
    should contain    ${BTS_diagSnapState}    ${diagSnapState}
    ${BTS_SnapFilename}    set variable    ${json_repr['diagSnapFilename']}
    should contain    ${BTS_SnapFilename}    ${diagSnapFilename}
    [Teardown]  vDU Rest Logout


Get Snapshot Fault list
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${status}    run keyword and return status    dictionary should contain key    ${json_repr}    faultSnapshotTriggers
    ${faultSnapshotTriggers}    run keyword if    ${status}    get from dictionary    ${json_repr}    faultSnapshotTriggers
    ...    ELSE    create list
    [Return]  ${faultSnapshotTriggers}
    [Teardown]  vDU Rest Logout

Get Diagnostic Snapshot Destination
    VDU Rest Login
    ${dist_names}    create list   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${objects}    vdu.get_current_plan_objects    class_name=TRBLCADM
    ...    dist_names=${dist_names}
    ${trblcadm}    set variable    ${objects['objects']}[0]
    ${json_repr}    json.loads    ${trblcadm['json_repr']}
    ${diagSnapDestination}    get from dictionary    ${json_repr}    diagSnapDestination
    [Return]  ${diagSnapDestination}
    [Teardown]  vDU Rest Logout

Reset VDU
    Log To Console   \nReset VDU
    ${alias}    VDU Rest Login
    vdu.reset_vdu   vdu_connection=${alias}
    sleep    3min
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Get vdu time
    [Arguments]  ${alias}=vDU
    Connect To K8s Master    alias=${alias}
    ${cmd}    set variable   date -u +"%Y-%m-%d %H:%M:%S"
    ${result}    tafssh.Execute    ${cmd}    connection=${alias}
    [Return]  ${result}
    [Teardown]  Disconnect From K8s Master    connection=${alias}

Connect To K8s Master
    [Arguments]   ${alias}=default
    [Documentation]    Connect To K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=up     | container=l1hi  | command=ls -l /tmp |        |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide |           |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide -n mynamespace |
    ...    | ${out}      | tafssh.Execute | command=kubectl get namespace |
    ...    | Disconnect From K8s Master   |
    ...
    ...    | Connect To K8s master | alias=myalias |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl describe pod    | connection=myalias |
    ...    | Disconnect From K8s Master   | connection=myalias |
    ...
    tafssh.Connect_To
    ...   hostname=${VDU_SSH_IP}
    ...  username=${VDU_SSH_USERNAME}
    ...  password=${VDU_SSH_PASSWORD}
    ...  alias=${alias}

Disconnect From K8s Master
    [Arguments]   ${connection}=default
    [Documentation]    Disconnect From K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | Disconnect From K8s Master |
    ...
    tafssh.Disconnect   connection=${connection}

Check Alarm exist in active Alarm
    [Arguments]  ${fault_id}    ${alarming_object}=${None}    ${exist}=${True}
    vdu rest login
    ${out}   vdu.vdu_get_active_alarms
    ${alarm_list}   get from dictionary    ${out}    alarms
    ${check_flag}    set variable    ${False}
    FOR    ${alarm}    IN    @{alarm_list}
        continue for loop if    '${alarm['fault_id']}'!='${fault_id}'
        ${get_alarming_object}    get from dictionary    ${alarm}    alarming_object
        ${status}    run keyword and return status    should contain    ${get_alarming_object}    ${alarming_object}
        ${check_flag}    set variable if    ${status} or '${alarming_object}'=='${None}'   ${True}    ${check_flag}
        exit for loop if    ${check_flag}
    END
    should be true    ${check_flag}==${exist}
    run keyword if    ${exist}    Log To Console   \nFault ${fault_id} Appeard in Active Alarm
    ...    ELSE    Log To Console   \nFault ${fault_id} Disappeard in Active Alarm
    [Teardown]  vDU Rest Logout

check upload failed in snapshot history
    Log To Console   \ncheck upload failed in snapshot history
    Connect To VDU  host=${VDU_OAM_IP}
#    vdu rest login
    ${file_path}    vdu.get_snapshot_history_file
    ${content}    OperatingSystem.Get File    ${file_path}
    ${check_log}    Get Regexp Matches    ${content}
    ...    failed\_reason[\\s\\S]*maxNumSnapByFaultTrigPerDay[\\s\\S]*exceeded[\\s\\S]*snapshot\_result[\\s\\S]*ignored
    ${check_log}    set variable    ${check_log[0]}
    [Teardown]  vDU Rest Logout

Set Syslog Substring Trigger Value
    [Arguments]    ${set_value}    ${operation}=replace    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log To Console   \nSet Syslog Substring Value to ${set_value}
    ${distname}    Set Variable   MRBTS-${vdu_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${delta_data_list}=    Evaluate    [['${distname}', {'syslogSubstringTrigger': '${set_value}'}, '${operation}']]
    vdu_cm_business.delta_commission_step_by_step    delta_data_list=${delta_data_list}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

VDU Reset Cell
    [Arguments]    ${cell_id}    ${connection}=default
    Log To Console    \n*** Reset Cell By REST ***
    ${time}      Get vdu time
    Connect To VDU  host=${VDU_OAM_IP}
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Log to Console    ${cell_id}
    ${dist_name}    Get Dist Name By Cell ID    ${cell_id}    connection=${connection}
    Log to Console    dist name: ${dist_name}
    ${out}    vdu1.reset_cells    dist_name=${dist_name}    vdu_connection=${connection}
    Sleep    30s    reason=wait for cell reset

Get Dist Name By Cell ID
    [Arguments]    ${cell_id}       ${connection}
    Connect To VDU  host=${VDU_OAM_IP}
    ${cells_status}    vdu.get_vdu_cells_status     vdu_connection=${connection}
    ${dist_name}    Set Variable    ${None}
    FOR    ${cell}    IN    @{cells_status}
        ${dist_name}=    Set Variable If    '${cell["id"]}' == '${cell_id}'    ${cell["dist_names"]["config"]}
        Run Keyword If    '${cell["id"]}' == '${cell_id}'    Exit For Loop
    END
    [Return]    ${dist_name}

TC Setup
    Common VDU Setup

TC Teardown
    Common VDU Teardown
#    Logs To Rotta Copy
