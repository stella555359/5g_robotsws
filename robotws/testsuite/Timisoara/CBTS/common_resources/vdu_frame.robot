*** Settings ***
Documentation  This suite contains vDU KWs used by setup and teardown in TCs

Library  Collections
Library  DateTime
Library  OperatingSystem
Library  String
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library  taf.nms.netact  WITH NAME  netact
Library  SSHLibrary
Library  python_resources/export_variables_from_init_file.py
Library  python_resources/extract.py
Resource  vdu_general.robot
Variables  python_resources/common_variables.py


*** Variables ***
${COLLECT_SNAPSHOT}  never
${NETACT_USERNAME}  omc
${NETACT_PASSWORD}  Medsql!_1893
@{GLOBALLY_IGNORED_ALARMS}  @{EMPTY}


*** Keywords ***
Common VDU Setup
    [Documentation]  This keyword is used to common VDU setup
    [Arguments]
    ...  ${vdu_connection_launch}=${TRUE}
    ...  ${modules_check}=${TRUE}
    ...  ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}
    ...  ${expected_vdu_status}=onAir
    ...  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}

    Log  Common VDU Setup  console=true
    Set Test Variable  ${SETUP_FAILED}  ${TRUE}
    ${test_timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${test_results_path}  OperatingSystem.Join Path  ${OUTPUT_DIR}  ${test_timestamp}_TEST-${TEST_NAME}
    Create Directory  ${test_results_path}
    Set Test Variable  ${TEST_RESULTS_DIR}  ${test_results_path}
    Set Config Variables  ${TL}
    Set Test Variable  ${VDU_OAM_IP}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][IP_ADDRESS]
    Set Test Variable  ${VDU_OAM_PASSWORD}  Nokia@123
    Set Test Variable  ${VDU_SSH_IP}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][SSH_IP]
    Set Test Variable  ${VDU_SSH_USERNAME}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][SSH_USERNAME]
    Set Test Variable  ${VDU_SSH_PASSWORD}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][SSH_PASSWORD]
    Set Test Variable  ${VDU_INSTANCE_ID}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][INSTANCE_ID]
    Set Test Variable  ${VDU_CRAN}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][VDU_CRAN]

    Run Keyword If  ${vdu_connection_launch}
    ...  Run Keywords
    ...  Connect To VDU  host=${VDU_OAM_IP}
    ...  AND
    ...  Log VDU Software Version
    ...  AND
    ...  Check Operational State And F1 C Link Status For VDU  ${expected_vdu_status}
    Run Keyword If  ${vdu_connection_launch} and ${modules_check}
    ...  Run Keywords
    ...  Check RMODs To Be OnAir
    ...  AND
    ...  Check Pods To Be OnAir
    Run Keyword If  ${vdu_connection_launch} and ${cells_check}
    ...  Check Cells To Be OnAir
    Run Keyword If  ${vdu_connection_launch} and ${alarms_check}
    ...  vdu_frame.Check Active Alarms  ${expected_alarms}  ${ignored_alarms}

    Set VDU SCF Path
    ${vdu_data}  vdu.Get Vdu State Data
    Set Test Variable  ${VDU_MRBTS_ID}  ${vdu_data}[mrbts_id]
    Set Test Variable  ${VDU_NRBTS_ID}  ${vdu_data}[nrbts_id]
    Set Test Variable  ${VDU_MRBTS_NAME}  ${vdu_data}[name]
    Set Test Variable  ${SETUP_FAILED}  ${FALSE}
    Log  End of Common VDU Setup  console=true


Connect To VDU
    [Documentation]  This keyword is used to connect to VDU
    [Arguments]  ${host}  ${port}=443  ${username}=Nemuadmin  ${password}=Nokia@123  ${secure}=True

    Log  Trying to connect to VDU (max 5 min)  console=true
    ${vdu_connection_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  vdu.Connect To  host=${host}  port=${port}  username=${username}  password=${password}  secure=${secure}
    Run Keyword If  ${vdu_connection_started}
    ...  Log  Connection to VDU successfully established!  console=true
    ...  ELSE
    ...  Fail  VDU connection did not start.


Log VDU Software Version
    [Documentation]  This keyword is used to log VDU software version

    ${vdu_state_data}  vdu.Get VDU State Data
    Log  Active VDU SW version: ${vdu_state_data}[software_version]  console=true
    Set Test Variable  ${VDU_ACTIVE_SW_VERSION}  ${vdu_state_data}[software_version]
    ${VDU_ACTIVE_SW_RELEASE}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    Set Test Variable  ${VDU_ACTIVE_SW_RELEASE}
    Set tags  vDU_SW_active-${VDU_ACTIVE_SW_VERSION}


Check Operational State And F1 C Link Status For VDU
    [Documentation]  This keyword is used to check operational state and F1 C link status for VDU
    [Arguments]  ${expected_vdu_status}

    ${vdu_state_data}  vdu.Get VDU State Data
    Should Be Equal As Strings  ${vdu_state_data}[operational_state]  ${expected_vdu_status}  ignore_case=True
    ...  msg=VDU operational state is not onAir. TC will stop execution.
    Should Be Equal As Strings  ${vdu_state_data}[f1_c_link_status_du]  available  ignore_case=True
    ...  msg=F1 C link status DU is not Available. TC will stop execution.


Check RMODs To Be OnAir
    [Documentation]  This keyword is used to check RMODs to be OnAir

    ${rmods_statuses}  vdu.Get Rmods Status
    FOR  ${rmod_statuses}  IN  @{rmods_statuses}
        ${rmod_dist_name}  Set Variable  ${rmod_statuses}[dist_names][config]
        Should Be Equal As Strings  ${rmod_statuses}[administrative_state]  Unlocked  ignore_case=True
        ...  msg=Administrative state for ${rmod_dist_name} is not Unlocked. TC will stop execution.
        Should Be Equal As Strings  ${rmod_statuses}[availability_status]  on line  ignore_case=True
        ...  msg=Availability status for ${rmod_dist_name} is not Online. TC will stop execution.
        Should Be Equal As Strings  ${rmod_statuses}[operational_state]  enabled  ignore_case=True
        ...  msg=Operational state for ${rmod_dist_name} is not Enabled. TC will stop execution.
    END
    Log  RMODs are unlocked, online and enabled  console=true


Check Pods To Be OnAir
    [Documentation]  This keyword is used to check pods to be onAir

    ${pods_info}  vdu.Get Pods Info
    FOR  ${pod_info}  IN  @{pods_info}
        Should Be Equal As Strings  ${pod_info}[availability_status]  on line  ignore_case=True
        ...  msg=Availability status for ${pod_info}[name] with instance id: ${pod_info}[instance] is not Online. TC will stop execution.
        Should Be Equal As Strings  ${pod_info}[operational_state]  enabled  ignore_case=True
        ...  msg=Operational state for ${pod_info}[name] with instance id: ${pod_info}[instance] is not Enabled. TC will stop execution.
    END
    Log  PODs are online and enabled  console=true


Check Cells To Be OnAir
    [Documentation]  This keyword is used to check cells to be onAir

    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell_statuses}  IN  @{cells_statuses}
        Should Be Equal As Strings  ${cell_statuses}[administrative_state]  Unlocked  ignore_case=True
        ...  msg=Administrative state for ${cell_statuses}[name] is not Unlocked. TC will stop execution.
        Should Be Equal As Strings  ${cell_statuses}[availability_status]  on line  ignore_case=True
        ...  msg=Availability status for ${cell_statuses}[name] is not Online. TC will stop execution.
        Should Be Equal As Strings  ${cell_statuses}[blocking_state]  Unblocked  ignore_case=True
        ...  msg=Blocking state for ${cell_statuses}[name] is not Unblocked. TC will stop execution.
        Should Be Equal As Strings  ${cell_statuses}[operational_state]  enabled  ignore_case=True
        ...  msg=Operational state for ${cell_statuses}[name] is not Enabled. TC will stop execution.
        Should Be Equal As Strings  ${cell_statuses}[procedural_status]  configured  ignore_case=True
        ...  msg=Procedural status for ${cell_statuses}[name] is not Configured. TC will stop execution.
    END
    Log  All cells are unlocked, online, unblocked, enabled, configured  console=true


Check Active Alarms
    [Documentation]  This keyword will Fail if not all expected alarms are active or alarms different from ignored alarms occur.
    ...  ${expected_alarms} - list of expected alarms, default ${EMPTY}
    ...  ${ignored_alarms}  - list of ignored alarms, default ${EMPTY}
    ...  Each alarm from both lists should have 2 keys: fault_id and fault_name.
    [Arguments]  ${expected_alarms}=${EMPTY}  ${ignored_alarms}=${EMPTY}

    vdu_frame.Set Additional Ignored Alarms
    ${status_ignored_alarms}  Run Keyword And Return Status
    ...  Should Be Empty  ${ignored_alarms}
    ${ignored_alarms}  Run Keyword If  ${status_ignored_alarms}
    ...  Create List  @{GLOBALLY_IGNORED_ALARMS}
    ...  ELSE
    ...  Combine Lists  ${ignored_alarms}  @{GLOBALLY_IGNORED_ALARMS}
    ${status_expected_alarms}  Run Keyword And Return Status
    ...  Should Be Empty  ${expected_alarms}
    ${expected_alarms}  Run Keyword If  ${status_expected_alarms}
    ...  Create List
    ...  ELSE
    ...  Set Variable  ${expected_alarms}
    ${status_ignored_alarms}  Run Keyword And Return Status
    ...  Should Be Empty  ${ignored_alarms}
    ${ignored_alarms}  Run Keyword If  ${status_ignored_alarms}
    ...  Create List
    ...  ELSE
    ...  Set Variable  ${ignored_alarms}
    ${active_alarms}  vdu.Vdu Get Active Alarms
    ${active_alarms_simplified}  vdu_frame.Create Alarm List With Fault Id Fault Name And Severity  ${active_alarms}[alarms]
    vdu_frame.Check Expected And Ignored Alarms  ${active_alarms_simplified}  ${expected_alarms}  ${ignored_alarms}


Create Alarm List With Fault Id Fault Name And Severity
    [Documentation]  This keyword is used to create alarm list with fault id fault name and severity
    [Arguments]  ${active_alarms}

    ${active_alarms_simplified}  Create List
    FOR  ${active_alarm}  IN  @{active_alarms}
        ${alarm}  Create Dictionary  fault_id=${active_alarm}[fault_id]  fault_name=${active_alarm}[fault_name]  severity=${active_alarm}[severity]
        Append To List  ${active_alarms_simplified}  ${alarm}
    END

    [Return]  ${active_alarms_simplified}


Check Expected And Ignored Alarms
    [Documentation]  Keyword fails if at least one active alarm is not expected, not ignored and it has the severity different from minor.
    ...  In case one active alarm is unexpected and it has severity=minor, this alarm will be logged and TC will continue its execution.
    [Arguments]  ${active_alarms_simplified}  ${expected_alarms}  ${ignored_alarms}

    FOR  ${active_alarm}  IN  @{active_alarms_simplified}
        ${active_fault_details}  Create Dictionary  fault_id=${active_alarm}[fault_id]  fault_name=${active_alarm}[fault_name]
        ${alarm_is_expected}  Run Keyword And Return Status
        ...  List Should Contain Value  ${expected_alarms}  ${active_fault_details}
        ${alarm_is_ignored}  Run Keyword And Return Status
        ...  List Should Contain Value  ${ignored_alarms}  ${active_fault_details}
        Run Keyword If  not ${alarm_is_expected} and not ${alarm_is_ignored}
        ...  Fail  Unexpected ${active_alarm}[severity] alarm is active: ${active_alarm}[fault_id], ${active_alarm}[fault_name]
    END
    Log  No unexpected alarms are active  console=true


Set Additional Ignored Alarms
    [Documentation]  This keyword is used to set additional ignored alarms

    ${var_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${ADDITIONAL_IGNORED_ALARMS}
    Return From Keyword If  not ${var_exists}
    Log  Setting Additional Ignored Alarms:${ADDITIONAL_IGNORED_ALARMS}  console=true
    ${additional_ignored_alarms}  Evaluate  ${ADDITIONAL_IGNORED_ALARMS}
    FOR  ${alarm}  IN  @{additional_ignored_alarms}
        ${ignored_alarm}  Create Dictionary
        Set To Dictionary  ${ignored_alarm}  @{alarm}
        Append To List  ${GLOBALLY_IGNORED_ALARMS}  ${ignored_alarm}
    END


Common VDU Teardown
    [Documentation]  This keyword is used to common VDU Teardown
    [Arguments]  ${collect_snapshot}=${collect_snapshot}

    Run Keyword If  '${collect_snapshot}'=='always' or ${SETUP_FAILED} or '${TEST_STATUS}'=='FAIL'
    ...  Collect VDU Snapshot
    vdu.Disconnect
    Log  End of Common VDU Teardown  console=true


Collect VDU Snapshot
    [Documentation]  This keyword is used to collect VDU Snapshot
    [Arguments]  ${directory_name}=Snapshot

    ${snapshot_status}  ${snapshot_operation_information}  Run Keyword And Ignore Error
    ...  vdu.Get Snapshot Operations Information
    Run Keyword If  '${snapshot_status}'=='PASS'
    ...  vdu.Cancel Snapshot Operation  ${snapshot_operation_information}[0][operation_id]
    ${operation_id}  vdu.Trigger Local Snapshot
    ${snapshot_trigerred_status}  vdu.Check Snapshot Status
    Should Be Equal As Strings  ${snapshot_trigerred_status}  local-ongoing  msg=Collect snapshot not started
    Create Directory  ${TEST_RESULTS_DIR}/${directory_name}_${operation_id}
    vdu.Check Local Snapshot Status And Save It  directory=${TEST_RESULTS_DIR}/${directory_name}_${operation_id}  operation_id=${operation_id}
    ...  compressed_or_not=True

    RETURN  ${TEST_RESULTS_DIR}/${directory_name}_${operation_id}


Set VDU SCF Path
    [Documentation]  This keyword is used to set vDU SCF path

    ${software_version}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    ${config_path}  Fetch From Right  ${CONFIGURATION}  .
    ${vdu_scf_path}  Catenate  SEPARATOR=  /home/ute/testline_configuration/${config_path}/node1  /${TOPOLOGY}_${software_version}.xml
    Set Test Variable  ${VDU_SCF_PATH}
    Log  SCF path is: ${VDU_SCF_PATH}  console=true
