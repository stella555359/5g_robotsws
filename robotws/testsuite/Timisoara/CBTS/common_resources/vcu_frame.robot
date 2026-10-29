*** Settings ***
Documentation  This suite contains vCU KWs used by setup and teardown in TCs

Library  Collections
Library  OperatingSystem
Library  String
Library  taf.gnb.oam.coam.cu  WITH NAME  vcu
Library  python_resources/export_variables_from_init_file.py
Resource  vcu_general.robot
Variables  python_resources/common_variables.py


*** Variables ***
${COLLECT_SNAPSHOT}  never
&{IGNORED_FAULT_61653}  fault_id=61653  fault_name=IP Address mapping failed
@{GLOBALLY_IGNORED_ALARMS}  ${IGNORED_FAULT_61653}
${CELLS_CHECK}  ${FALSE}
${ALARMS_CHECK}  ${FALSE}
${NETACT_USERNAME}  omc
${NETACT_PASSWORD}  Medsql!_1893


*** Keywords ***
Common VCU Setup
    [Documentation]  This keyword is used to common VCU Setup.
    [Arguments]
    ...  ${vcu_connection_launch}=${TRUE}
    ...  ${modules_check}=${TRUE}
    ...  ${expected_vcu_status}=enabled
    ...  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}

    Log  Common VCU Setup  level=INFO  console=true
    Set Test Variable  ${SETUP_FAILED}  ${TRUE}
    ${test_timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${test_results_path}  OperatingSystem.Join Path  ${OUTPUT_DIR}  ${test_timestamp}_TEST-${TEST_NAME}
    Create Directory  ${test_results_path}
    Set Test Variable  ${TEST_RESULTS_DIR}  ${test_results_path}
    Set Config Variables  ${TL}
    Set Test Variable  ${VCU_OAM_IP}  ${VCU_CONNECTION_DETAILS}[IP_ADDRESS]
    Set Test Variable  ${VCU_OAM_PASSWORD}  Nokia@123
    Set Test Variable  ${VCU_SSH_IP}  ${VCU_CONNECTION_DETAILS}[SSH_IP]
    Set Test Variable  ${VCU_SSH_USERNAME}  ${VCU_CONNECTION_DETAILS}[SSH_USERNAME]
    Set Test Variable  ${VCU_SSH_PASSWORD}  ${VCU_CONNECTION_DETAILS}[SSH_PASSWORD]
    Set Test Variable  ${VCU_CRAN}  ${VCU_CONNECTION_DETAILS}[VCU_CRAN]
    Set Test Variable  ${VDU_ID}  ${VDU_CONNECTION_DETAILS_LIST}[0][VDU_ID][INSTANCE_ID]

    Run Keyword If  ${vcu_connection_launch}
    ...  Run Keywords
    ...  Connect To VCU  host=${VCU_OAM_IP}
    ...  AND
    ...  Log VCU Software Version
    ...  AND
    ...  Check Operational State For VCU  ${expected_vcu_status}
    Run Keyword If  ${vcu_connection_launch} and ${modules_check}
    ...  Check VDU To Be OnAir
    Run Keyword If  ${vcu_connection_launch} and ${CELLS_CHECK}
    ...  Check Cells On VDU To Be OnAir
    Run Keyword If  ${vcu_connection_launch} and ${ALARMS_CHECK}
    ...  vcu_frame.Check Active Alarms  ${expected_alarms}  ${ignored_alarms}

    Set VCU SCF Path
    ${vcu_data}  Get Cu State
    Set Test Variable  ${VCU_MRBTS_ID}  ${vcu_data}[mrbts_id]
    Set Test Variable  ${VCU_NRBTS_ID}  ${vcu_data}[nrbts_id]
    Set Test Variable  ${VCU_MRBTS_NAME}  ${vcu_data}[bts_name]

    Set Test Variable  ${SETUP_FAILED}  ${FALSE}
    Log  End of Common VCU Setup  level=INFO  console=true


Connect To VCU
    [Documentation]  This keyword is used to connect to VCU.
    [Arguments]  ${host}  ${port}=443  ${username}=Nemuadmin  ${password}=Nokia@123  ${secure}=True

    Log  Trying to connect to VCU (max 5 min)  level=INFO  console=true
    ${vcu_connection_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  vcu.Connect To  host=${host}  port=${port}  username=${username}  password=${password}  secure=${secure}
    Run Keyword If  ${vcu_connection_started}
    ...  Log  Connection to VCU successfully established!  level=INFO  console=true
    ...  ELSE
    ...  Fail  VCU connection did not start.


Log VCU Software Version
    [Documentation]  This keyword is used to log VCU software version

    ${vcu_active_sw_version}  vcu.Get Active Software Version
    Log  Active VCU SW version: ${vcu_active_sw_version}  console=true
    Set Test Variable  ${VCU_ACTIVE_SW_VERSION}
    ${VCU_ACTIVE_SW_RELEASE}  Fetch From Left  ${VCU_ACTIVE_SW_VERSION}  _
    Set Test Variable  ${VCU_ACTIVE_SW_RELEASE}
    Set tags  vCU_SW_active-${VCU_ACTIVE_SW_VERSION}


Check Operational State For VCU
    [Documentation]  This keyword is used to check operational state for VCU
    [Arguments]  ${expected_vcu_status}

    ${cu_state}  vcu.Get Cu State
    Should Be Equal As Strings  ${cu_state}[operational_state]  ${expected_vcu_status}  ignore_case=True
    ...  msg=CU operational state is not enabled. TC will stop execution.


Check VDU To Be OnAir
    [Documentation]  This keyword is used to check VDU to be onAir

    ${du_state}  vcu.Get Du  ${VDU_ID}
    Should Be Equal As Strings  ${du_state}[administrative_state]  Unlocked  ignore_case=True
    ...  msg=${du_state}[name] is not Unlocked. TC will stop execution.
    Should Be Equal As Strings  ${du_state}[f1_link_status]  available  ignore_case=True
    ...  msg=F1 link status for ${du_state}[name] is not Available. TC will stop execution.
    Log  VDU ${du_state}[name] is onAir  level=INFO  console=true


Check Cells On VDU To Be OnAir
    [Documentation]  This keyword is used to check cells on VDU to be onAir

    ${du_state}  vcu.Get Du  ${VDU_ID}
    ${cells_summary}  Convert To String  ${du_state}[cells_summary]
    Number Of Cells With NOK State Should Be 0  disabled  ${cells_summary}  ${du_state}[name]
    Number Of Cells With NOK State Should Be 0  locked  ${cells_summary}  ${du_state}[name]
    Number Of Cells With NOK State Should Be 0  shutting_down  ${cells_summary}  ${du_state}[name]
    Log  Cells on ${du_state}[name] are unlocked and enabled  level=INFO  console=true


Number Of Cells With NOK State Should Be 0
    [Documentation]  This keyword is used to verify number of cells with NOK state should be 0
    [Arguments]  ${state}  ${cells_summary}  ${du_name}

    ${state_cells}  Get Regexp Matches  ${cells_summary}  '${state}':\\s\\d+
    ${state_cells_no}  Fetch From Right  ${state_cells}[0]  ${SPACE}
    Should Be Equal As Strings  ${state_cells_no}  0  msg=There are disabled cells on ${du_name}. TC will stop execution.


Check Active Alarms
    [Documentation]  This keyword will Fail if not all expected alarms are active or alarms different from ignored alarms occur.
    ...  ${expected_alarms} - list of expected alarms, default ${EMPTY}
    ...  ${ignored_alarms}  - list of ignored alarms, default ${EMPTY}
    ...  Each alarm from both lists should have 2 keys: fault_id and fault_name.
    [Arguments]  ${expected_alarms}=${EMPTY}  ${ignored_alarms}=${EMPTY}

    vcu_frame.Set Additional Ignored Alarms
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

    ${active_alarms}  vcu.Get Active Alarms
    ${active_alarms_simplified}  vcu_frame.Create Alarm List With Fault Id Fault Name And Severity  ${active_alarms}[alarms]
    vcu_frame.Check Expected And Ignored Alarms  ${active_alarms_simplified}  ${expected_alarms}  ${ignored_alarms}


Create Alarm List With Fault Id Fault Name And Severity
    [Documentation]  This keyword is used to Create Alarm List With Fault Id Fault Name And Severity
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


Common VCU Teardown
    [Documentation]  This keyword is used to common VCU teardown.
    [Arguments]  ${collect_snapshot}=${collect_snapshot}

    Log  Common VCU Teardown  level=INFO  console=true
    Run Keyword If  '${collect_snapshot}'=='always' or ${SETUP_FAILED} or '${TEST_STATUS}'=='FAIL'
    ...  Collect VCU Snapshot
    vcu.Disconnect
    Log  End of Common VCU Teardown  level=INFO  console=true


Collect VCU Snapshot
    [Documentation]  This keyword is used to collect VCU snapshot
    [Arguments]  ${directory_name}=Snapshot

    ${snapshot_status}  ${snapshot_operation_information}  Run Keyword And Ignore Error
    ...  vcu.Get Snapshot Operations Information
    Run Keyword If  '${snapshot_status}'=='PASS'
    ...  vcu.Cancel Snapshot Operation  ${snapshot_operation_information}[0][operation_id]
    ${operation_id}  vcu.Trigger Local Snapshot
    ${snapshot_trigerred_status}  vcu.Check Snapshot Status
    Should Be Equal As Strings  ${snapshot_trigerred_status}  local-ongoing  msg=Collect snapshot did not started
    Create Directory  ${TEST_RESULTS_DIR}/${directory_name}_${operation_id}
    vcu.Get Local Snapshot By Id  directory=${TEST_RESULTS_DIR}/${directory_name}_${operation_id}  operation_id=${operation_id}


Set VCU SCF Path
    [Documentation]  This keyword is used to set vCU SCF path

    ${software_version}  Fetch From Left  ${VCU_ACTIVE_SW_VERSION}  _
    ${config_path}  Fetch From Right  ${CONFIGURATION}  .
    ${vcu_scf_path}  Catenate  SEPARATOR=  /home/ute/testline_configuration/${config_path}/node1  /${TOPOLOGY}_${software_version}.xml
    Set Test Variable  ${VCU_SCF_PATH}
    Log  SCF path is: ${VCU_SCF_PATH}  console=true
