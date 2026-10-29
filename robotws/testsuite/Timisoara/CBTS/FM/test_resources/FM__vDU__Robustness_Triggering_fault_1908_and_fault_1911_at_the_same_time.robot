*** Settings ***
Documentation
    ...  This TC is created to trigger faults 1908 and 1911 on RMOD.
    ...  For both faults: vDU, pod and RMOD connections are opened first.
    ...  For the first fault, connection to a single made-node is opened and two parameters from "gc.json" file are changed.
    ...  After editing the file, lock and unlock operations must be performed on the cell that is mapped on RMOD.
    ...  In this stage, RMOD state is checked and alarm must be reported in WebEM.
    ...  To cancel the fault, the parameters from "gc.json" must be brought back to initial values,
    ...  and lock+unlock operations must be performed again.
    ...  For the second fault, connection to multiple made-nodes is opened.
    ...  After sending a command to each made-node, fault must be reported in WebEM.
    ...  Also, RMOD state and cell state must be checked.
    ...  In the end, RMOD and cell must be on air.
    ...  Fault signature is checked only if the fault 1911 is reported with severity: Warning.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/cbts_general.robot


*** Variables ***
${ALARM_TIMEOUT}  600
${EXPECTED_ALARM_ID}  7116
${EXPECTED_ALARM_NAME}  BASE STATION SERVICE PROBLEM
${EXPECTED_FAULT_ID}  1908
${EXPECTED_FAULT_NAME}  RF Module gain adjusting failure
${SEVERITY}  regex"Major|major"
${EXPECTED_ALARM_ID_SECOND}  7116
${EXPECTED_ALARM_NAME_SECOND}  BASE STATION SERVICE PROBLEM
${EXPECTED_FAULT_ID_SECOND}  1911
${EXPECTED_FAULT_NAME_SECOND}  RX out of order
${SEVERITY_SECOND}  regex"Critical|critical|Warning|warning"
${RMOD_USER}  serviceuser
${RMOD_PASS}  bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25241
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  20.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25241 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  FEATURE-CB00699

    Step 0: TC Prerequisites
    Step 1: Trigger Fault 1908
    Step 2: Trigger Fault 1911


Step 0: TC Prerequisites
    Log  \nStep0: TC Prerequisites.  console=true
    ${vdu_cells_status}  Get Vdu Cells Status
    ${cell_dictionary}  Evaluate  random.choice(${vdu_cells_status})  random
    ${cell_dn}  Set Variable  ${cell_dictionary}[dist_names][config]
    ${cell_id}  Fetch From Right  ${cell_dn}  -
    Set Test Variable  ${CELL_DN}
    Set Test Variable  ${CELL_ID}
    ${rmods}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods}
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${rmod}[cell_ids]  ${CELL_ID}
        Run Keyword If  ${cell_status}
        ...  Run Keywords
        ...  Set Test Variable  ${RMOD_DN}  ${rmod}[dist_names][runtime]
        ...  AND
        ...  Set Test Variable  ${RMOD_SN}  ${rmod}[serial_number]
        ...  AND
        ...  Set Test Variable  ${RMOD_ID}  ${rmod}[id]
        ...  AND
        ...  Exit For Loop
    END
    Should Not Be Empty  ${RMOD_DN}  msg=RMOD dist name not set correctly. [NOK]
    ${all_rmods_ips}  Get All ECPRI RMODs Ips From RMODs Dedicated Pod  ${RMOD_USER}
    ${rmod_ip}  Get ECPRI RMOD Ip By Serial Number  ${RMOD_SN}  ${RMOD_USER}  ${RMOD_PASS}  ${all_rmods_ips}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${ANT_DN}  ${RMOD_DN}/PHYANT_R-1
    ${test_start_time}  Get Current Date  UTC  exclude_millis=True
    Set Test Variable  ${TEST_START_TIME}


Step 1: Trigger Fault 1908
    Log  \nStep 1: Trigger fault 1908.  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASS}
    Connect To Made-node From RMOD
    Send Fault 1908 On RMOD
    Change Specific Parameter For VDU  administrativeState  Locked  ${CELL_DN}
    Change Specific Parameter For VDU  administrativeState  Unlocked  ${CELL_DN}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Visible In VDU WebEM
    ...  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${SEVERITY}
    Wait Until Keyword Succeeds  300  10
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  availability_status  ${DEGRADED}
    Log  RMOD with dist name: ${RMOD_DN} has the expected state: Degraded. [OK]  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASS}
    Connect To Made-node From RMOD
    Cancel Fault 1908 On RMOD
    Change Specific Parameter For VDU  administrativeState  Locked  ${CELL_DN}
    Change Specific Parameter For VDU  administrativeState  Unlocked  ${CELL_DN}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Cleared From VDU WebEM  ${EXPECTED_ALARM_ID}  ${EXPECTED_FAULT_ID}
    Wait Until Keyword Succeeds  300  10
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  availability_status  ${ONLINE}
    Log  RMOD with dist name: ${RMOD_DN} has the expected state: Online. [OK]  console=true


Step 2: Trigger Fault 1911
    Log  \nStep 2: Trigger fault 1911.  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASS}
    Connect To Each Made-node And Send Crash Command
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Visible In VDU WebEM  ${EXPECTED_ALARM_ID_SECOND}
    ...  ${EXPECTED_ALARM_NAME_SECOND}
    ...  ${EXPECTED_FAULT_ID_SECOND}
    ...  ${EXPECTED_FAULT_NAME_SECOND}
    ...  ${SEVERITY_SECOND}
    ${status_not_installed}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  10
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  availability_status  ${NOT_INSTALLED}
    Run Keyword If  ${status_not_installed}
    ...  Log  RMOD with dist name: ${RMOD_DN} is in expected state: Not installed. [OK]  console=true
    ...  ELSE
    ...  Fail  RMOD with dist name: ${RMOD_DN} is not in expected state: Not installed. [NOK]
    Wait Until Keyword Succeeds  300  10
    ...  Check The Specific Cell From VDU  ${CELL_ID}  availability_status=${FAILED}
    Log  Cell with id: ${CELL_ID} is in expected state: Failed. [OK]  console=true
    Log  Checking RMOD and cell to be on air, and alarm to be cleared.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check The Specific Cell From VDU  ${CELL_ID}  availability_status=${ONLINE}
    Wait Until Keyword Succeeds  300  10
    ...  Check If Fault Is Cleared From VDU WebEM  ${EXPECTED_ALARM_ID_SECOND}  ${EXPECTED_FAULT_ID_SECOND}
    Log  Alarm with fault id: ${EXPECTED_FAULT_ID_SECOND} is cleared, and RMOD and cell are on air. [OK]  console=true
    ${alarm_severity_status}  Run Keyword And Return Status
    ...  Should Contain  regex"Warning|warning"  ${ALARM_INFO}[severity]
    Run Keyword If  ${alarm_severity_status}
    ...  Interrogate Historical Alarms And Check Fault Signature
    ...  ELSE
    ...  Log  Alarm with fault id: ${EXPECTED_FAULT_ID_SECOND}, doesn't have the severity Warning, no need to check fault signature.  console=true


Connect To Made-node From RMOD
    SSHLibrary.Write  ssh serviceuser@192.168.101.2
    ${made_node_connection}  SSHLibrary.Read Until Prompt
    ${made_node_connection_status}  Run Keyword And Return Status
    ...  Should Contain  ${made_node_connection}  MADE
    Run Keyword If  ${made_node_connection_status}==${FALSE}
    ...  Fail  Conection to made-node failed.
    Log  Made-node connection successfully done. [OK]  console=true


Send Fault 1908 On RMOD
    Log  Sending fault 1908 on RMOD.  console=true
    ${sed_command}  Catenate  SEPARATOR=  sudo sed -i -E ':a;N;$!ba;s/"analogGainLimits":${SPACE}\\{[${SPACE}]*\\n[${SPACE}]*"min":${SPACE}-29.0,
    ...  [${SPACE}]*\\n[${SPACE}]*"max":${SPACE}-2.0/"analogGainLimits":${SPACE}\\{\\n\\t"min":${SPACE}-2.0,
    ...  ${SPACE}\\n\\t"max":${SPACE}-29.0/g' gc.json
    Fetch Json File
    SSHLibrary.Write  ${sed_command}
    SSHLibrary.Read Until Prompt
    Save Json File And Reboot Module
    SSHLibrary.Close Connection


Cancel Fault 1908 On RMOD
    Log  Canceling fault 1908 on RMOD.  console=true
    ${sed_command}  Catenate  SEPARATOR=  sudo sed -i -E ':a;N;$!ba;s/"analogGainLimits":${SPACE}\\{[${SPACE}]*\\n[${SPACE}]*"min":${SPACE}-2.0,
    ...  [${SPACE}]*\\n[${SPACE}]*"max":${SPACE}-29.0/"analogGainLimits":${SPACE}\\{\\n\\t"min":${SPACE}-29.0,
    ...  ${SPACE}\\n\\t"max":${SPACE}-2.0/g' gc.json
    Fetch Json File
    SSHLibrary.Write  ${sed_command}
    SSHLibrary.Read Until Prompt
    Save Json File And Reboot Module
    SSHLibrary.Close Connection


Fetch Json File
    SSHLibrary.Set Client Configuration  prompt=#
    SSHLibrary.Write  echo $'/ action create ConfigAccess /ca /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ca action fetch DECODED "gc.bin" "/ram/gc.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cd /ram
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo cat gc.json
    SSHLibrary.Read Until Prompt


Save Json File And Reboot Module
    SSHLibrary.Write  echo $'/ca action store PERMANENT DECODED "gc.bin" "/ram/gc.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/ca action update' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo cat gc.json
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  reboot
    SSHLibrary.Read Until Prompt


Connect To Each Made-node And Send Crash Command
    SSHLibrary.Write  ip neigh
    ${ip_neigh_output}  SSHLibrary.Read Until Prompt
    ${made_nodes_ips}  Get Regexp Matches  ${ip_neigh_output}  192.168.101.[0-9]+
    FOR  ${made_node}  IN  @{made_nodes_ips}
        SSHLibrary.Write  ssh serviceuser@${made_node}
        ${made_node_connection}  SSHLibrary.Read Until Prompt
        ${made_node_connection_status}  Run Keyword And Return Status
        ...  Should Contain  ${made_node_connection}  MADE
        Run Keyword If  ${made_node_connection_status}==${FALSE}
        ...  Fail  Not able to connect on made-node with ip: ${made_node}.
        SSHLibrary.Write  sudo devmem 0xFC98025C 32 0x0
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close Connection


Interrogate Historical Alarms And Check Fault Signature
    Login Using M2M Interface  ${VDU_OAM_IP}
    ${command}  Catenate  SEPARATOR=  https://${VDU_OAM_IP}/api/licensed/v2/alarms/historical?pageNumber=1&itemsPerPage=50&sortedBy=appearTime
    ...  &sortOrder=asc&filterByAlarmingObject=${RMOD_DN}&filterByText=${EXPECTED_FAULT_ID_SECOND}
    ${historical_alarms}  Run M2M Command  GET  "${command}"  Bearer  ${TOKEN}
    ${historical_alarms}  Remove M2M Output Noise  ${historical_alarms}
    ${historical_alarms_dictionary}  Evaluate  json.loads('''${historical_alarms}''')  json
    ${historical_alarms_list}  Set Variable  ${historical_alarms_dictionary}[alarms]
    FOR  ${alarm}  IN  @{historical_alarms_list}
        ${alarm_time_status}  Run Keyword And Return Status
        ...  Check Alarm Appear Time  ${alarm}[appearTime]
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[faultId]  ${EXPECTED_FAULT_ID_SECOND}
        Run Keyword If  ${fault_id_status} and ${alarm_time_status}
        ...  Run Keywords
        ...  Check Fault Signature Fields For Fault 1911  ${alarm}[faultSignature]  ${VDU_ACTIVE_SW_VERSION}  ${RMOD_SN}
        ...  AND
        ...  Logout Using M2M Interface  ${VDU_OAM_IP}
        ...  AND
        ...  Return From Keyword
    END
    Fail  Wasn't able to check fault signature for alarm with fault id: ${EXPECTED_FAULT_ID_SECOND}. [NOK]


Check Alarm Appear Time
    [Arguments]  ${alarm_appearence_time}

    ${alarm_time}  Remove String Using Regexp  ${alarm_appearence_time}  \\+[0-9]+:[0-9]+
    ${alarm_time}  Replace String Using Regexp  ${alarm_time}  T  ${SPACE}
    Run Keyword If  '${alarm_time}' > '${TEST_START_TIME}'
    ...  Return From Keyword  True
    ...  ELSE
    ...  Fail  Alarm did not appear after the test started. [NOK]


Check Fault Signature Fields For Fault 1911
    [Arguments]  ${fault_signature}  ${vdu_active_sw}  ${module_sn}

    ${category}  Create List  OAM_RESET  ASSERT  EXCEPTION  TIMEOUT  POWER_OFF  SW_FAILURE  HW_FAILURE  UNKNOWN
    ${scope}  Create List  Site  Board  Partial  DSP group  BBPOOL  RFM  ESM  GSM RAT  WCDMA RAT  LTE RAT  NR RAT  SoC
    List Should Contain Value  ${category}  ${fault_signature}[category]  Category field in fault signature is not displayed correctly. [NOK]
    List Should Contain Value  ${scope}  ${fault_signature}[scope]  Scope field in fault signature is not displayed correctly. [NOK]
    Should Be Equal As Strings  ${fault_signature}[loadName]  ${vdu_active_sw}  loadName field in fault signature is not displayed correctly. [NOK]
    Should Be Equal As Strings  ${fault_signature}[component]  ${module_sn}  Component field in fault signature is not displayed correctly. [NOK]
    Log  All fault signature fields are displayed correctly. [OK]  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time


TC Teardown
    Common VDU Teardown
