*** Settings ***
Documentation
    ...  This TC is changing temperature value for AVQC module.
    ...  actPipePowerDecreased1dBFaults is set to True. In this way, generated faults
    ...  are also visible in WebEM.
    ...  Temperature is set to 115 and Minor fault 1927 'RF Power decreased' must be active in WebEM and in
    ...  /ram/fault_history_log_temp.txt file from RF.
    ...  Then, temperature is set to 125 and Major fault 1927 'RF Power decreased' is active and minor fault is cleared.
    ...  In the end, temperature is set to its initial value and major fault must be cleared.
    ...  VDU must be in operational state.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vdu_general.robot


*** Variables ***
${RMOD_PRODUCT_NAME}  AVQC  # Product name of RMOD
${RMOD_USER}  serviceuser  # username used to login to RMOD from pod
${RMOD_PASSWORD}  kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=  # password used to login to RMOD from pod
${RESTORE_TIMEOUT}  900  # Time in seconds for vDU to reach on air state


*** Keywords ***
TC__KPI__vDU__Software_Signing_For_RU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27745
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27745 - Initial TAT creation
    ...  ******************

    Set Tags  CA-KPI  OWNER-iulian_catalin.lazar@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf   PHASE-CRT
    ...  FEATURE-CB010413-C

    Step0: Set AVQC IP Address
    Step1: Change actPipePowerDecreased1dBFaults Parameter To True
    Step2: Connect To AVQC And Send Minor Fault 1927
    Step3: Check Minor Fault 1927 To Be Active
    Step4: Connect To AVQC And Send Major Fault 1927
    Step5: Check Major Fault 1927 To Be Active And Minor Fault 1927 To Be Inactive
    Step6: Restore Temperature Initial Value And Check Major Fault 1927 To Be Inactive


Step0: Set AVQC IP Address
    Log  \nStep0: Set AVQC IP Address  console=true
    ${rmod_ips}  Get All ECPRI RMODs Ips From RMODs Dedicated Pod  ${RMOD_USER}
    ${rmods_statuses}  vdu.Get Rmods Status
    ${rmods}  Create List
    FOR  ${rmod_statuses}  IN  @{rmods_statuses}
        Run Keyword If  '${rmod_statuses}[product_name]'=='${RMOD_PRODUCT_NAME}'
        ...  Append To List  ${rmods}  ${rmod_statuses}
    END
    ${rmod}  Evaluate  random.choice(${rmods})  random
    ${rmod_ip}  Get ECPRI RMOD Ip By Serial Number  ${rmod}[serial_number]  ${RMOD_USER}  ${RMOD_PASSWORD}  ${rmod_ips}  $
    ...  /mnt/factory/configs/unit/module_serial_number.txt
    Set Test Variable  ${RMOD_IP}


Step1: Change actPipePowerDecreased1dBFaults Parameter To True
    Log  \nStep1: Change actPipePowerDecreased1dBFaults Parameter To True  console=true
    ${power_decreased_faults_value}  VDU Get Parameter Value  actPipePowerDecreased1dBFaults  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Run Keyword If  '${power_decreased_faults_value}'!='true'
    ...  Change Specific Parameter For VDU  actPipePowerDecreased1dBFaults  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Set Test Variable  ${POWER_DECREASED_FAULTS_INITIAL_VALUE}  ${power_decreased_faults_value}


Step2: Connect To AVQC And Send Minor Fault 1927
    Log  \nStep2: Connect To AVQC And Send Minor Fault 1927  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}  $
    SSHLibrary.Write  echo $'/ action create ThermometerDevice /CI/Sensor1 /temp/mars1/internal1' | frmonShellClient localhost 2000
    ${create_command_output}  SSHLibrary.Read Until Prompt
    ${status_done}  Run Keyword And Return Status  Should Contain  ${create_command_output}  done ok
    ${status_path_taken}  Run Keyword And Return Status  Should Contain  ${create_command_output}  Path already taken
    Should Be True  ${status_done} or ${status_path_taken}  "create" command not executed correctly.

    SSHLibrary.Write  echo $'/CI/Sensor1 get temperature' | frmonShellClient localhost 2000
    ${get_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_temp_command_output}  done ok  "get" command not executed correctly.
    ${temp_initial_value}  Get Regexp Matches  ${get_temp_command_output}  done ok \\d+
    ${temp_initial_value}  Fetch From Right  ${temp_initial_value}[0]  ${SPACE}
    Set Test Variable  ${TEMP_INITIAL_VALUE}

    SSHLibrary.Write  echo $'/CI/Sensor1 action override TEMPERATURE 115' | frmonShellClient localhost 2000
    ${override_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${override_temp_command_output}  done ok  "override" command not executed correctly.
    SSHLibrary.Write  echo $'/CI/Sensor1 get temperature' | frmonShellClient localhost 2000
    ${get_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_temp_command_output}  115  Temperature is different than 115.

    [Teardown]  SSHLibrary.Close Connection


Step3: Check Minor Fault 1927 To Be Active
    Log  \nStep3: Check Minor Fault 1927 To Be Active  console=true
    Wait Until Keyword Succeeds  120  10  Check If Fault Is Visible In VDU WebEM  7115  BASE STATION INFORMATION  1927  RF Power decreased  minor
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}  $
    Check Active Fault In History Log Output  EFaultId_PipeTxPowerDecreased_1dB (1312)  minor

    [Teardown]  SSHLibrary.Close Connection


Step4: Connect To AVQC And Send Major Fault 1927
    Log  \nStep4: Connect To AVQC And Send Major Fault 1927  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}  $
    SSHLibrary.Write  echo $'/CI/Sensor1 action override TEMPERATURE 125' | frmonShellClient localhost 2000
    ${override_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${override_temp_command_output}  done ok  "override" command not executed correctly.
    SSHLibrary.Write  echo $'/CI/Sensor1 get temperature' | frmonShellClient localhost 2000
    ${get_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_temp_command_output}  125  Temperature is different than 125.

    [Teardown]  SSHLibrary.Close Connection


Step5: Check Major Fault 1927 To Be Active And Minor Fault 1927 To Be Inactive
    Log  \nStep5: Check Major Fault 1927 To Be Active And Minor Fault 1927 To Be Inactive  console=true
    Wait Until Keyword Succeeds  120  10  Check If Fault Is Visible In VDU WebEM  7116  BASE STATION SERVICE PROBLEM  1927  RF Power decreased
    ...  major
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}  $
    Check Active Fault In History Log Output  EFaultId_Tx_PowerDecreased (1152)  major
    Check If Fault Is Cleared From VDU WebEM  7115  1927
    Check Inactive Fault In History Log Output  EFaultId_PipeTxPowerDecreased_1dB  minor

    [Teardown]  SSHLibrary.Close Connection


Step6: Restore Temperature Initial Value And Check Major Fault 1927 To Be Inactive
    Log  \nStep6: Restore Temperature Initial Value And Check Major Fault 1927 To Be Inactive  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}  $
    SSHLibrary.Write  echo $'/CI/Sensor1 action override TEMPERATURE ${TEMP_INITIAL_VALUE}' | frmonShellClient localhost 2000
    ${override_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${override_temp_command_output}  done ok  "override" command not executed correctly.
    SSHLibrary.Write  echo $'/CI/Sensor1 get temperature' | frmonShellClient localhost 2000
    ${get_temp_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_temp_command_output}  ${TEMP_INITIAL_VALUE}  Temperature is different than ${TEMP_INITIAL_VALUE}.

    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Check If Fault Is Cleared From VDU WebEM  7116  1927
    Check Inactive Fault In History Log Output  EFaultId_Tx_PowerDecreased  major

    [Teardown]  SSHLibrary.Close Connection


Check Active Fault In History Log Output
    [Arguments]  ${fault_identifier}  ${fault_severity}

    SSHLibrary.Write  cat /ram/fault_history_log_temp.txt
    ${history_log}  SSHLibrary.Read Until Prompt
    ${active_faults}  Fetch From Left  ${history_log}  InActive faults:
    ${active_faults}  Fetch From Right  ${active_faults}  Active faults:
    ${active_fault_entries}  Get Lines Containing String  ${active_faults}  ${fault_identifier}
    ${active_fault_entries}  Split To Lines  ${active_fault_entries}
    Should Not Be Empty  ${active_fault_entries}  Fault 1927 with ${fault_severity} severity is not active in history log. [NOK]

    FOR  ${fault_entry}  IN  @{active_fault_entries}
        Should Contain  ${fault_entry}  ${fault_severity}
        ...  At least one active fault 1927 doesn't have ${fault_severity} severity in history log. [NOK]
    END
    ${timestamp}  Fetch From Left  ${fault_entry}  ${SPACE}
    ${timestamp}  Remove String  ${timestamp}  ${SPACE}
    ${severity_uppercase}  Convert To Uppercase  ${fault_severity}
    Set Test Variable  ${ACTIVE_${severity_uppercase}_1927_LAST_TIMESTAMP}  ${timestamp}
    Log  Fault 1927 with ${fault_severity} severity is active in history log. [OK]  console=true


Check Inactive Fault In History Log Output
    [Arguments]  ${fault_identifier}  ${fault_severity}

    SSHLibrary.Write  cat /ram/fault_history_log_temp.txt
    ${history_log}  SSHLibrary.Read Until Prompt
    ${inactive_faults}  Fetch From Left  ${history_log}  Fault events:
    ${inactive_faults}  Fetch From Right  ${inactive_faults}  InActive faults:
    ${inactive_fault_entries}  Get Lines Containing String  ${inactive_faults}  ${fault_identifier}
    ${inactive_fault_entries}  Split To Lines  ${inactive_fault_entries}
    Should Not Be Empty  ${inactive_fault_entries}  Fault 1927 with ${fault_severity} severity is not cleared in history log. [NOK]

    ${no_of_inactive_entries}  Set Variable  0
    ${severity_uppercase}  Convert To Uppercase  ${fault_severity}
    FOR  ${fault_entry}  IN  @{inactive_fault_entries}
        ${timestamp}  Fetch From Left  ${fault_entry}  ${SPACE}
        Continue For Loop If  '${timestamp}'<'${ACTIVE_${severity_uppercase}_1927_LAST_TIMESTAMP}'
        Should Contain  ${fault_entry}  ${fault_severity}
        ...  At least one inactive fault 1927 doesn't have ${fault_severity} severity in history log. [NOK]
        ${no_of_inactive_entries}  Evaluate  ${no_of_inactive_entries}+1
    END
    Should Be True  ${no_of_inactive_entries}>0  Fault 1927 with ${fault_severity} severity is not cleared in history log. [NOK]
    Log   Fault 1927 with ${fault_severity} severity is inactive in history log. [OK]  console=true


Restore Initial Value
    ${power_decreased_faults_value}  VDU Get Parameter Value  actPipePowerDecreased1dBFaults  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Run Keyword If  '${power_decreased_faults_value}'!='${POWER_DECREASED_FAULTS_INITIAL_VALUE}'
    ...  Change Specific Parameter For VDU  actPipePowerDecreased1dBFaults  ${POWER_DECREASED_FAULTS_INITIAL_VALUE}
    ...  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1


TC Setup
    Common VDU Setup
    Modify Resource Search Order  KPI__vDU__Software_Signing_For_RU


TC Teardown
    Restore Initial Value
    Common VDU Teardown