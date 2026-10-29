*** Settings ***
Documentation
    ...  This test case is created to send fault 4383.
    ...  TC sets parameter actFaultSignature on true.
    ...  Test will randomly select BBMOD from ABIN, ABIO, ABIL with LTE tehnology.
    ...  After sending the fault 4383, alarm is available in WebEM.
    ...  Checks are made if the parameters in the FaultSignature are present.
    ...  FaultSignature info is checked to be present in the syslog file.
    ...  The alarm is also checked in NetAct.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after site reset
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to appear in Netact
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in WebEM
${BBMOD_TYPE}  ${EMPTY}  # Mandatory. BBMOD type, can be ABIN, ABIO, ABIL


*** Keywords ***
TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25060
    ...
    ...  *******************
    ...  History of changes
    ...  ******************
    ...  - 19.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25060 - Initial TAT creation
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28316 - Increase prompt timeout
    ...  - 12.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28376 - Verify syslog fault signature in teardown
    ...  - 21.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29191 - Parse Syslog Files And Verify Fault Signature keyword fails
    ...  ******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CB008506

    Step0: Set Parameters And Perform Site Reset
    Step1: Trigger Crash On UP 4G L2 Process
    Step2: Check If Fault Signature Is Raised


Step0: Set Parameters And Perform Site Reset
    Log  \nStep0: Set parameters and perform site reset.  console=true
    IF  '${SCF_COUNT_LTE}'=='0'  Fail  4G RAT does not exist.
    IF  '${BBMOD_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (ABIO/ABIN/ABIL).
    Set ActFaultSignature Value  true

    ${bbmod_r_object}  Get Random BBMOD That Processes 4G Cells
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_r_object}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_r_object}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_r_object}[productCode]

    ${bbmod_r_dn}  Set Variable  ${bbmod_r_object}[id]
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_r_dn}
    Set Test Variable  ${BBMOD_POSITION}
    ${vertical_position}  Evaluate  ${BBMOD_POSITION}+1
    ${horizontal_position}  Get Module Horizontal Position  ${bbmod_r_dn}
    Set Test Variable  ${UNIT_POSITION}  ${horizontal_position}${vertical_position}

    ${bbmod_l_dn}  Get Module L Dist Name  ${bbmod_r_object}[serialNumber]  BBMOD
    Set Test Variable  ${BBMOD_L_DN}

    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${TIME_ALARM}
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  Virtual Node
    Set Test Variable  ${INFO}  .*Abort signal received.*

    Perform Site Reset


Step1: Trigger Crash On UP 4G L2 Process
    Log  \nStep1: Trigger crash on UP 4G L2 process.  console=true
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  0
    Trigger Crash On UP 4G L2
    SSHLibrary.Close Connection


Step2: Check If Fault Signature Is Raised
    Log  \nStep2: Check if fault signature is raised.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    ${assert_alarm}  Assert Alarm Active  parameters=${alarm_parameters}  timeout=300
    IF  ${assert_alarm}
      Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id] "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is visible in WebEM. [OK]  console=True
    ELSE
      Fail  Fault ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id] "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" was not visible in WebEM. [NOK]
    END

    ${check_fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_PROCESSES_AUTO_RST}  time_from=${TIME_ALARM}
    ...  additional_fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    IF  ${check_fault_na}
      Log  Given alarm and fault fields are correct in NA, alarm is present in NA. [OK]  console=true
    ELSE
      FAIL  Given alarm and fault fields are incorrect in NA or alarm is missing in NA. [NOK]
    END

    Sleep  60s  Wait for alarm to appear in alarms history.
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  category=${CATEGORY}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Log  Verify fault signature of fault in Netact.  console=True
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${TIME_ALARM}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}
    ...  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Get Random BBMOD That Processes 4G Cells
    ${bbmod_list}  Create List
    ${module_objects}  coam.Get Parameters For All  BBMOD
    FOR  ${module_object}  IN  @{module_objects}
        ${bbmod_type_status}  Run Keyword And Return Status  Should Contain  ${module_object}[productName]  ${BBMOD_TYPE}
        ${cells_on_module_dns}  coam.Get Cell Mapping By Module Id  ${module_object}[id]
        ${nr_status}  Check If LTE Is Deployed On Module  ${cells_on_module_dns}
        IF  ${bbmod_type_status} and ${nr_status}  Append To List  ${bbmod_list}  ${module_object}
    END
    ${length}  Get Length  ${bbmod_list}
    IF  ${length} == 0  Fail  SBTS does not have ${BBMOD_TYPE} unit with 4G cells.
    ${random_bbmod_object}  Evaluate  random.choice(${bbmod_list})  random

    [Return]  ${random_bbmod_object}


Check If LTE Is Deployed On Module
    [Arguments]  ${cells_on_module_dns}

    FOR  ${cell_dn}  IN  @{cells_on_module_dns}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  LNCEL
        IF  ${status}  RETURN  ${TRUE}
    END

    [Return]  ${FALSE}


Trigger Crash On UP 4G L2
    SSHLibrary.Set Client Configuration  prompt=~ >  timeout=30s
    SSHLibrary.Write  ps -aux | grep container*
    Sleep  5s
    ${container}  SSHLibrary.Read Until Prompt
    ${match}  Get Regexp Matches  ${container}  \/ram\/node_LTEL2NODE[0-9]+\/[a-z.]+ -n 0x[0-9]{4}
    ${node_id}  Get Regexp Matches  ${match}[0]  0x[0-9]{4}
    SSHLibrary.Set Client Configuration  prompt= >
    SSHLibrary.Write  cd /tmp
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  lxc-ls
    ${output_lxc}  SSHLibrary.Read Until Prompt
    Should Contain  ${output_lxc}  ${node_id}[0]  msg=Virtual node ${node_id}[0] not exist
    SSHLibrary.Write  lxc-attach -n ${node_id}[0]
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  kill -SIGABRT $(echo $(ps -Leo tid,comm |grep "Disp_1") | awk '{ print $1 }')
    SSHLibrary.Read Until Prompt
    Set Test Variable  ${MINOR}  ${node_id}[0]


TC Setup
    Common Test Setup  tc_name=FM__FID4383_fault_signature_active_UP_4G_L2_process
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
    Parse Syslog Files And Verify Fault Signature