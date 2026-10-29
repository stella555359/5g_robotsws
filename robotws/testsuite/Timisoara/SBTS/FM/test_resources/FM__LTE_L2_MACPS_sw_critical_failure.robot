*** Settings ***
Documentation
    ...  This test is created to perform failure on ABIN/ABIO/ABIP/ABIQ/ASOE/ASOF.
    ...  First, BBMOD with 4G cells is chosen.
    ...  Site reset is performed to clear all counters.
    ...  Conection to SOC is opened and fault 4383 is sent for one time on the following processes:
    ...  LTENODE, FDD or TDD and D-CPNODE.
    ...  All LTE cells mapped on it must be disabled.
    ...  After that, one process is chosen and will be triggered like that:
    ...  crash on LTENODE for 2 more times, crash on D-CPNODE for 3 more times and crash on FDD or TDD for 2 more times.
    ...  After all these crashes, all LTE cells should be disabled and alarm RAT autonomous reset as recovery action
    ...  should appear and reset LTE RAT should be performed.
    ...  Alarm 7107 should appear on some NR cells.
    ...  After recovery, all services must be operational.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${MODULE_TYPE}  ${EMPTY}  # Mandatory. Could be ABIN/ABIO/ABIP/ABIQ/ASOE/ASOF.
${RAT}  LNCEL  # Cells type deployed on module.
${TECHNOLOGY}  FDD  # Can be TDD orr FDD.
${STARTUP_TIMEOUT}  600  # Time for SBTS to recover from site reset.
${RECOVERY_TIMEOUT}  900  # Time for SBTS to reach onAir state after TC.
${ALARM_TIMEOUT}  300  # Timeout for alarms to appear or disappear.


*** Keywords ***
FM__LTE_L2_MACPS_sw_critical_failure
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24907
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  07.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24907 - Initial TAT creation
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  07.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26950 - Update TC's crashing methods
    ...  14.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27615 - Changing the site reset method
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  17.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28551 - Add associated IoT cells to affected cells list
    ...  11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28708 - Move keyword to resource file
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  17.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30003 - New method of process crash
    ...  ******************

    Set Tags  CA-FM  OWNER-simona.marcu@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB008880

    Step0: TC Preconditions
    Step1: Perform Site Reset
    Step2: Perform SOC Recovery Reset On LTENODE
    Step3: Perform SOC Recovery Reset On FDD Or TDD
    Step4: Perform SOC Recovery Reset On D-CPNODE
    Step5: Perform 2 Or 3 More Times SOC Recovery Reset On A Random Process


Step0: TC Preconditions
    Log  \nStep0: TC preconditions...  console=true

    IF  '${MODULE_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (ABIN/ABIO/ABIP/ABIQ/ASOE/ASOF).
    Change FMCADM Parameter  actForceAutoReset  true
    Change FEATCADM Parameter  actRatResetEnhancement  true

    ${module}  Set Variable If  '${MODULE_TYPE}'=='ASOE'  SMOD  BBMOD
    ${module_r_dn}  ${module_sn}  ${module_cells}  Get Module Info Based On Technology  ${module}  ${RAT}  ${MODULE_TYPE}
    ${module_l_dn}  Get Module L Dist Name  ${module_sn}  ${module}
    ${module_position}  Get Module Vertical Position  ${module_r_dn}
    ${stored_role}  Get StoredRole From MODULE_L  ${module_l_dn}
    ${affected_cells}  Create List
    FOR  ${cell}  IN  @{module_cells}
        ${technology_status}  Run Keyword And Return Status  Should Contain  ${cell}  ${RAT}
        IF  ${technology_status}  Append To List  ${affected_cells}  ${cell}
    END
    ${affected_cells}  Check If Affected Cells Have IoT Associated Cells And Add Them To List  ${affected_cells}
    ${unaffected_cells}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${MODULE_R_DN}
    Set Test Variable  ${MODULE_L_DN}
    Set Test Variable  ${MODULE_POSITION}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}
    Set Test Variables For Fault Signature


Step1: Perform Site Reset
    Log  \nStep1: Perform site reset...  console=true

    Open Connection To Primary Core
    SSHLibrary.Write  uptime
    ${output}  SSHLibrary.Read Until Prompt
    ${matches}  Get Regexp Matches  ${output}  \\d+\\sday(s|S)?\\s\\d{2}:\\d{2}
    ${status_matches}  Run Keyword And Return Status  Should Not Be Empty  ${matches}
    ${status_day}  Run Keyword And Return Status  Should Contain  ${output}  day
    IF  ${status_matches}
        ${final_time}  Convert Complex Time To Total Hours  ${matches}
    ELSE IF  ${status_day}
        ${final_time}  Convert Days To Hours  ${output}
    ELSE
        ${final_time}  Convert Hour Time In Hours  ${output}
    END
    IF  ${final_time}>=36
        Log  Perform site reset will be skipped because SBTS has not been reset for ${final_time} hours.  console=true
    ELSE
        Perform Site Reset
    END


Step2: Perform SOC Recovery Reset On LTENODE
    Log  \nStep2: Perform SOC recovery reset on LTENODE...  console=true

    Kill Process On SOC And Verify Alarms And Cells States  process_name=LTEL2


Step3: Perform SOC Recovery Reset On FDD Or TDD
    Log  \nStep3: Perform SOC recovery reset on FDD or TDD...  console=true

    FOR  ${cell}  IN  @{AFFECTED_CELLS}
        ${cell_info}  Get Cell Specific Info  ${cell}
        ${cell_status}  Run Keyword And Return Status  Should Contain  ${cell_info}[technology]  ${TECHNOLOGY}
        IF  '${cell_status}'=='${False}'
            Append To List  ${UNAFFECTED_CELLS}  ${cell}
            Remove Values From List  ${AFFECTED_CELLS}  ${cell}
        END
    END
    IF  "${TECHNOLOGY}"=="FDD"
        Kill Process On SOC And Verify Alarms And Cells States  process_name=FDDMACNODE
    ELSE
        Kill Process On SOC And Verify Alarms And Cells States  process_name=TDDMACNODE
    END


Step4: Perform SOC Recovery Reset On D-CPNODE
    Log  \nStep4: Perform SOC recovery reset on D-CPNODE...  console=true

    FOR  ${cell}  IN  @{AFFECTED_CELLS}
        ${cell_info}  Get Cell Specific Info  ${cell}
        ${cell_status}  Run Keyword And Return Status  Should Contain  ${cell_info}[technology]  ${TECHNOLOGY}
        IF  '${cell_status}'=='${False}'
            Append To List  ${UNAFFECTED_CELLS}  ${cell}
            Remove Values From List  ${AFFECTED_CELLS}  ${cell}
        END
    END
    Kill Process On SOC And Verify Alarms And Cells States  process_name=D-CPNODE


Step5: Perform 2 Or 3 More Times SOC Recovery Reset On A Random Process
    Log  \nStep5: Perform 2 or 3 more times SOC recovery reset on a random process...  console=true

    ${list_names_crash}  Create List  LTEL2  D-CPNODE
    IF  "${TECHNOLOGY}"=="FDD"
        Append To List  ${list_names_crash}  FDDMACNODE
    ELSE
        Append To List  ${list_names_crash}  TDDMACNODE
    END
    ${random_crash_name}  Evaluate  random.choice(${list_names_crash})  random
    IF  '${random_crash_name}'=='LTEL2'
        Kill Process On SOC And Verify Alarms And Cells States  process_name=LTEL2
        Kill Process On SOC And Verify Alarms And Cells States  process_name=LTEL2  is_last_trigger=${TRUE}
    ELSE IF  '${random_crash_name}'=='D-CPNODE'
        Repeat Keyword  2  Kill Process On SOC And Verify Alarms And Cells States  process_name=D-CPNODE
        Kill Process On SOC And Verify Alarms And Cells States  process_name=D-CPNODE  is_last_trigger=${TRUE}
    ELSE IF  '${random_crash_name}'=='FDDMACNODE'
        Kill Process On SOC And Verify Alarms And Cells States  process_name=FDDMACNODE
        Kill Process On SOC And Verify Alarms And Cells States  process_name=FDDMACNODE  is_last_trigger=${TRUE}
    ELSE IF  '${random_crash_name}'=='TDDMACNODE'
        Kill Process On SOC And Verify Alarms And Cells States  process_name=TDDMACNODE
        Kill Process On SOC And Verify Alarms And Cells States  process_name=TDDMACNODE  is_last_trigger=${TRUE}
    END
    Wait Until Keyword Succeeds  300  20  Check Modules And Cells


Kill Process On SOC And Verify Alarms And Cells States
    [Arguments]  ${process_name}  ${is_last_trigger}=${FALSE}

    Log  Crash process ${process_name}...  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Open Connection To SOC And Kill Process  ${process_name}
    ${sw_node_l}  Query Infomodel  get object //SW_NODE_L-* is [rat=LTE deploymentTargetDn=regex"${MODULE_L_DN}" hostname=regex"${process_name}"]
    ${node_id}  Convert To Hex  ${sw_node_l}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    ${minor}  Set Variable  ${low_node_id}
    IF  '${process_name}'=='D-CPNODE'
        ${info}  Set Variable  .*CCSDaemon crash.*
    ELSE
        ${info}  Set Variable  .*AaError_Linux_BB.*
    END
    IF  ${is_last_trigger}
        Verify Rat Auto Reset Scenario
        IF  '${process_name}'=='D-CPNODE'
            ${process_name}  Replace String Using Regexp  ${process_name}  -  _
            ${minor}  Set Variable  ${process_name}${SPACE}${minor}
        END
        Log  Check fault signature...  console=true
        Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
        ...  info=${info}  load_name=${SW_VERSION}  minor=${minor}  reset_counter=${RESET_COUNTER}  scope=${SCOPE_RAT}
        ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
        ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
        Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  time_from=${START_TIME}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${info}
        ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${minor}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
        ...  scope=SCOPE:${SPACE}${SCOPE_RAT}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
        ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    ELSE
        Verify Process Auto Reset Scenario
        Log  Check fault signature...  console=true
        Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  category=${CATEGORY}  info=${info}
        ...  load_name=${SW_VERSION}  minor=${minor}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
        ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
        ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
        Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${START_TIME}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  info=INFO:${SPACE}${info}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
        ...  minor=MINOR:${SPACE}${minor}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
        ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ...  core_unit_position=${CORE_UNIT_POSITION}
    END


Open Connection To SOC And Kill Process
    [Arguments]  ${process_name}

    Open Connection To Primary Core
    IF  '${STORED_ROLE}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${MODULE_POSITION}  0  :~ >
    SSHLibrary.Write  ll /tmp | grep node_0x
    ${command_output}  SSHLibrary.Read Until Prompt
    ${process_line}  Get Lines Containing String  ${command_output}  ${process_name}
    ${node_id}  Get Regexp Matches  ${process_line}  node_[a-z0-9]*
    Should Not Be Empty  ${node_id}  msg=Node Id not found for process: ${process_name}
    ${node_id}  Fetch From Right  ${node_id}[0]  _
    IF  '${process_name}'=='D-CPNODE'
        SSHLibrary.Write  pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=${node_id}'
    ELSE
        SSHLibrary.Write  pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=${node_id}'
    END
    SSHLibrary.Read Until Prompt
    Log  Process ${process_name} has been killed.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Verify Process Auto Reset Scenario
    Check Affected/UnAffected Cells States  ${AFFECTED_CELLS}  ${DISABLED}
    Check Affected/UnAffected Cells States  ${UNAFFECTED_CELLS}  ${ENABLED}
    ${fault_4383__processs_params}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    Assert Alarm Active  parameters=${fault_4383__processs_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_PROCESSES_AUTO_RST}
    ...                                                                               time_from=${START_TIME}
    ...                                                                               additional_fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} was reported & cleared from Mantaray.  console=true
    Check Affected/UnAffected Cells States  ${AFFECTED_CELLS}  ${ENABLED}
    Assert Alarm Inactive  parameters=${fault_4383__processs_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} is cleared from WebEM.  console=true


Verify Rat Auto Reset Scenario
    ${fault_4383_rat_params}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    Assert Alarm Active  parameters=${fault_4383_rat_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}
    ...                                                                               time_from=${START_TIME}
    ...                                                                               additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} was reported & cleared from Mantaray.  console=true
    Assert Every  LNCEL  operationalState=${DISABLED}  timeout=300
    Log  All LTE cells are in the right state - ${DISABLED}.  console=true
    ${fault_7107_params}  Get String With Alarm Parameters  ${FAULT_7107}
    Assert Alarm Active  parameters=${fault_7107_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_7107} is active in WebEM.  console=true
    Assert Any  NRCEL  operationalState=${DISABLED}  timeout=300
    Log  NR cells are in the right state - ${DISABLED}.  console=true
    Assert Alarm Inactive  parameters=${fault_4383_rat_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} is cleared from WebEM.  console=true
    Assert Alarm Inactive  parameters=${fault_7107_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_7107} is cleared from WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7107}
    ...                                                                               time_from=${START_TIME}
    ...                                                                               additional_fault_id=${FAULT_7107}[fault_id]
    Log  Fault ${FAULT_7107} was reported & cleared from Mantaray.  console=true


Check Affected/UnAffected Cells States
    [Arguments]  ${cells}  ${status}

    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  10
    ...  Check Parameters Status For Cells  ${cells}  operationalState=${status}
    IF  ${cells_status}
        Log  Cells: ${cells} are in the right state: ${status}. [OK]  console=true
    ELSE
        Fail  Cells: ${cells} are not in the right state: ${status}. [NOK]
    END


Set Test Variables For Fault Signature
    Log  Setting variables for fault signature.  console=true
    Set Unit Position For Fault Signature  ${MODULE_R_DN}
    ${module_l_parameters}  coam.Get Parameters  ${MODULE_L_DN}
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=LTE:[0-9]+.*(gracefully_shutdown_cells:LTE[0-9]+)?
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  Virtual Node
    Set Test Variable  ${SCOPE_RAT}  LTE RAT
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


TC Setup
    Common Test Setup  tc_name=FM__LTE_L2_MACPS_sw_critical_failure
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown