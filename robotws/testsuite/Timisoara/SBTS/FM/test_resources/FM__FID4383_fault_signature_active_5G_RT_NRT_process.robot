*** Settings ***
Documentation
    ...  This test case is created to send fault 4383.
    ...  TC sets parameter actFaultSignature on true.
    ...  Test will randomly select BBMOD from ABIN, ABIO, ABIL, ABIP with NR technology.
    ...  First, the fault is sent to UPUE process, and the alarm becomes visible in WebEM.
    ...  Once the alarm appears in the Alarm History, the fault signature will be verified.
    ...  Second, the fault is sent to CPUE process cp_sb file, and the alarm becomes visible in WebEM.
    ...  After the alarm is recorded in the Alarm History, the fault signature check will be conducted.
    ...  Third, the fault is sent to CPUE process cp_ue file, and the alarm becomes visible in WebEM.
    ...  Once the alarm is listed in the Alarm History, the fault signature will be verified.
    ...  Each time the alarm is present in the Alarm History,
    ...  the info field must be completed with one of the following values: "cp_sb crash, cp_ue crash, CCS supervised or CCS".
    ...  If the info field is not populated with "CCS supervised" or "CCS,"
    ...  the fault trigger on the CPUE process cp_ue file will be sent again.
    ...  After the alarm reappears in the Alarm History, the info field must be updated to include "CCS supervised" or "CCS."
    ...  If the info field is still not completed correctly, the test will fail.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after site reset
${NETACT_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in Netact
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in WebEM
${BBMOD_TYPE}  ${EMPTY}  # Mandatory. BBMOD type, can be ABIN, ABIO, ABIL


*** Keywords ***
TC__FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25059
    ...
    ...  *******************
    ...  History of changes
    ...  ******************
    ...  - 19.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25059 - Initial TAT creation
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27003 - Enhancement for test case
    ...  - 28.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28316 - Increase prompt timeout
    ...  - 12.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28376 - Verify syslog fault signature in teardown.
    ...  - 06.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28030 - Adding new steps
    ...  - 23.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29270 - Fix variable not found.
    ...  - 03.04.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30687 - Enhancement to increase test coverage for CNI-99796
    ...  ******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CB008506  CNI-99796

    Step0: Set Parameters And Perform Site Reset
    Step1: Trigger Crash On UP 5G L2 UPUE Process
    Step2: Check If Fault Signature Is Raised
    Step3: Trigger Crash On Up 5G CPUE Cp Sb Process
    Step4: Check If Fault Signature Is Raised
    Step5: Trigger Crash On Up 5G CPUE Cp Ue Process
    Step6: Check If Fault Signature Is Raised
    Step7: Verify If Correct Form Of Info Field Is Visible
    Step8: Trigger Last Crash On Up 5G CPUE Cp Ue Process


Step0: Set Parameters And Perform Site Reset
    Log  \nStep0: Set parameters and perform site reset.  console=true

    IF  '${SCF_COUNT_NR}'=='0'  Fail  5G RAT does not exist.
    IF  '${BBMOD_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (ABIO/ABIN/ABIL/ABIP).
    Set ActFaultSignature Value  true

    ${bbmod_r_object}  Get Random BBMOD That Processes 5G Cells
    ${bbmod_r_dn}  Set Variable  ${bbmod_r_object}[id]
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_r_object}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_r_object}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_r_object}[productCode]

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

    Perform Site Reset
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${NO_OF_CP_UE_CRASHES}  0
    ${list_info}  Create List  AaError_Linux(_[a-zA-Z]+)?.c.*  cp_sb crash  cp_ue crash
    ${list_info_with_CSS}  Create List  CCS supervised  CCS
    Set Test Variable  ${LIST_INFO}  ${list_info}
    Set Test Variable  ${INFO_CCS_SUPERVISED}  ${list_info_with_CSS}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  0
    ${minor_info_list}  Create List
    Set Test Variable  ${MINOR_INFO_LIST}


Step1: Trigger Crash On UP 5G L2 UPUE Process
    Log  \nStep1: Trigger crash on UP 5G L2 UPUE process.  console=true

    Trigger Crash On UP 5G L2
    Log  Crash on L2 UPUE was sent.  console=true


Step3: Trigger Crash On Up 5G CPUE Cp Sb Process
    Log  \nStep3: Trigger crash on UP 5G CPUE Cp Sb process.  console=true

    Trigger Crash On CPUE Process  cp_sb
    Log  Crash on CPUE cp_sb was sent.  console=true


Step5: Trigger Crash On Up 5G CPUE Cp Ue Process
    Log  \nStep5: Trigger crash on UP 5G CPUE Cp Ue process.  console=true

    Trigger Crash On CPUE Process  cp_ue
    Log  Crash on CPUE cp_ue was sent.  console=true


Step${index}: Check If Fault Signature Is Raised
    Log  \nStep${index}: Check if fault signature is raised.  console=true

    Check If Alarm 4383 Is Visible In WebEM And Netact
    IF  ${index} in [2, 4, 6]
        Check Fault Signature In WebEM and Netact With Specific Info Field  ${index}
    END


Step7: Verify If Correct Form Of Info Field Is Visible
    Log  \nStep7: Verify if correct form of info field is visible.  console=true

    IF  ${NO_OF_CP_UE_CRASHES}==1 and ${CCS_SUPERVISED}==${FALSE}
      Trigger Crash On 5G CPUE Third Time
    ELSE
      Log  Info field of CPUE second crash is correctly completed.  console=true
    END


Step8: Trigger Last Crash On Up 5G CPUE Cp Ue Process

    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        Log  \nStep8: Trigger last crash on Up 5G CPUE Cp Ue process.  console=true
        Change FMCADM Parameter  actForceAutoReset  false
        ${open_sc_connection}  Set Variable If  "${STORED_ROLE}"=="Idle"  ${TRUE}  ${FALSE}
        Crash Process With Sigstop  CPUE  ${open_sc_connection}  ${BBMOD_POSITION}
        Check If Alarm 4383 Is Visible In WebEM And Netact
        ${info}  Set Variable  cp-ue crash.*description: process did not acknowledge heartbeats
        FOR  ${id}  IN  @{NODE_IDS}
            ${webem_status_info_field}  Run Keyword And Return Status
            ...  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}s  30s
            ...  Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  category=${CATEGORY}  info=${info}
            ...  load_name=${SW_VERSION}  minor=${id}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
            ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
            IF  ${webem_status_info_field}  BREAK
        END
        Should Be True  ${webem_status_info_field}  Fault signature info is not correctly filled in WebEm.
        ${netact_status_info_field}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  30s
        ...  Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${TIME_ALARM}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  info=INFO:${SPACE}${info}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${id}
        ...  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
        ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        Should Be True  ${netact_status_info_field}  Fault signature info is not correctly filled in Netact.
    END


Trigger Crash On 5G CPUE Third Time
    Trigger Crash On CPUE Process  cp_ue
    Check If Alarm 4383 Is Visible In WebEM And Netact
    Sleep  60s  Wait for alarm to appear in alarms history.
    FOR  ${info}  IN  @{INFO_CCS_SUPERVISED}
        ${minor_ccs_crash}  ${status_ccs_supervised}  Get Right Minor Field For Fault Signature  ${info}
        IF  ${status_ccs_supervised}
            Set Test Variable  ${INFO_THIRD_CCS_CRASH}  ${info}
            Set Test Variable  ${MINOR_CCS}  ${minor_ccs_crash}
            BREAK
        END
    END
    IF  ${status_ccs_supervised}
        Log  Info field of CPUE third crash is correctly completed with ${INFO_THIRD_CCS_CRASH}.  console=true
    ELSE
        Fail  Info field of CPUE third crash is not correctly completed with ${INFO_CCS_SUPERVISED}. [NOK]
    END
    Check Fault Signature And Append Fields To List  ${INFO_THIRD_CCS_CRASH}  ${MINOR_CCS}


Check If Alarm 4383 Is Visible In WebEM And Netact
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    ${assert_alarm}  Assert Alarm Active  parameters=${alarm_parameters}  timeout=300
    IF  ${assert_alarm}
        Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id] "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is visible in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id] "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" was not visible in WebEM. [NOK]
    END
    ${check_fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_PROCESSES_AUTO_RST}  time_from=${TIME_ALARM}
    ...  additional_fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    Should Be True  ${check_fault_na}  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].
    Log  Given alarm and fault fields are correct in NA, alarm is present in NA [OK].  console=true


Check Fault Signature In WebEM and Netact With Specific Info Field
    [Arguments]  ${index}
    Sleep  60s  Wait for alarm to appear in alarms history.

    FOR  ${info}  IN  @{LIST_INFO}
        ${minor_crash}  ${status}  Get Right Minor Field For Fault Signature  ${info}
        IF  ${status}
            Set Test Variable  ${INFO_CRASH}  ${info}
            Set Test Variable  ${MINOR_CRASH}  ${minor_crash}
            Set Test Variable  ${STATUS_INFO_CRASH}  ${TRUE}
            BREAK
        ELSE
            Set Test Variable  ${INFO_CRASH}  ${info}
            Set Test Variable  ${STATUS_INFO_CRASH}  ${FALSE}
        END
    END

    FOR  ${info}  IN  @{INFO_CCS_SUPERVISED}
        ${minor_ccs_crash}  ${status_ccs_supervised}  Get Right Minor Field For Fault Signature  ${info}
        IF  ${status_ccs_supervised}
            Set Test Variable  ${INFO_CCS_CRASH}  ${info}
            Set Test Variable  ${MINOR_CCS}  ${minor_ccs_crash}
            Set Test Variable  ${STATUS_CCS_SUPERVISED}  ${TRUE}
            BREAK
        ELSE
            Set Test Variable  ${STATUS_CCS_SUPERVISED}  ${FALSE}
        END
    END

    IF  ${index}==2 and ${STATUS_INFO_CRASH}
        Check Fault Signature And Append Fields To List   ${INFO_CRASH}  ${MINOR_CRASH}
    ELSE IF  ${index}==2 and ${STATUS_INFO_CRASH}==${FALSE}
        Fail  Info field of L2 UPUE crash is not correctly completed with ${INFO_CRASH}. [NOK]
    ELSE IF  ${index}==4 and ${STATUS_INFO_CRASH}
        Set Test Variable  ${CCS_SUPERVISED}  ${STATUS_CCS_SUPERVISED}
        Check Fault Signature And Append Fields To List  ${INFO_CRASH}  ${MINOR_CRASH}
    ELSE IF  ${index}==4 and ${STATUS_CCS_SUPERVISED}
        Set Test Variable  ${CCS_SUPERVISED}  ${STATUS_CCS_SUPERVISED}
        Check Fault Signature And Append Fields To List  ${INFO_CCS_CRASH}  ${MINOR_CCS}
    ELSE IF  ${index}==4 and (${STATUS_CCS_SUPERVISED}==${FALSE} and ${STATUS_INFO_CRASH}==${FALSE})
        Fail  Info field of CPUE cp_sb crash is not correctly completed with ${INFO_CRASH}. [NOK]
    ELSE IF  ${index}==6 and (${STATUS_INFO_CRASH} and ${CCS_SUPERVISED})
        Check Fault Signature And Append Fields To List  ${INFO_CRASH}  ${MINOR_CRASH}
    ELSE IF  ${index}==6 and (${STATUS_INFO_CRASH} and ${CCS_SUPERVISED}==${FALSE})
        Set Test Variable  ${CCS_SUPERVISED}  ${STATUS_CCS_SUPERVISED}
        Check Fault Signature And Append Fields To List  ${INFO_CRASH}  ${MINOR_CRASH}
    ELSE IF  ${index}==6 and ${STATUS_CCS_SUPERVISED}
        Set Test Variable  ${CCS_SUPERVISED}  ${STATUS_CCS_SUPERVISED}
        Check Fault Signature And Append Fields To List  ${INFO_CCS_CRASH}  ${MINOR_CCS}
    ELSE IF  ${index}==6 and (${STATUS_CCS_SUPERVISED}==${FALSE} and ${STATUS_INFO_CRASH}==${FALSE})
        Fail  Info field of CPUE cp_ue crash is not correctly completed with ${INFO_CRASH}. [NOK]
    END


Check Fault Signature And Append Fields To List
    [Arguments]  ${info}  ${minor}
    Check Fault Signature In Netact With Specific Info Field  ${info}  ${minor}
    ${dictionary}  Create Dictionary  minor=${minor}  info=${info}
    Append To List  ${MINOR_INFO_LIST}  ${dictionary}


Get Right Minor Field For Fault Signature
    [Arguments]  ${info}

    FOR  ${id}  IN  @{NODE_IDS}
        ${status}  Run Keyword And Return Status  Check Fault Signature Of Alarm In WebEM
        ...  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  category=${CATEGORY}  info=${info}
        ...  load_name=${SW_VERSION}  minor=${id}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
        ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ${minor_crash}  Set Variable If  ${status}  ${id}
        IF  ${status}  RETURN  ${minor_crash}  ${status}
    END

    RETURN  ${EMPTY}  ${FALSE}


Check Fault Signature In Netact With Specific Info Field
    [Arguments]  ${info}  ${minor}

    Log  Info field is correctly completed with ${info}.  console=true
    Log  Verify fault signature of fault in Netact.  console=true
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${TIME_ALARM}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  info=INFO:${SPACE}${info}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${minor}
    ...  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Get Random BBMOD That Processes 5G Cells
    ${bbmod_list}  Create List
    ${module_objects}  coam.Get Parameters For All  BBMOD
    FOR  ${module_object}  IN  @{module_objects}
        ${bbmod_type_status}  Run Keyword And Return Status  Should Contain  ${module_object}[productName]  ${BBMOD_TYPE}
        ${cells_on_module_dns}  coam.Get Cell Mapping By Module Id  ${module_object}[id]
        ${nr_status}  Check If NR Is Deployed On Module  ${cells_on_module_dns}
        IF  ${bbmod_type_status} and ${nr_status}  Append To List  ${bbmod_list}  ${module_object}
    END
    ${length}  Get Length  ${bbmod_list}
    IF  '${length}'=='0'  Fail  SBTS does not have ${BBMOD_TYPE} unit with 5G cells.
    ${random_bbmod_object}  Evaluate  random.choice(${bbmod_list})  random

    RETURN  ${random_bbmod_object}


Check If NR Is Deployed On Module
    [Arguments]  ${cells_on_module_dns}

    FOR  ${cell_dn}  IN  @{cells_on_module_dns}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCEL
        IF  ${status}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Trigger Crash On UP 5G L2
    [Documentation]  Crashes the L2 UPUE dispatcher thread (Disp_1) via lxc-attach and sets NODE_IDS for fault signature verification.
    ...  Kills the specified process using kill SIGABRT (or kill -6) abort signal.

    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~ >)  timeout=30s
    SSHLibrary.Write  ps -aux | grep container*
    Sleep  5s  Wait until the output is displayed.
    ${container}  SSHLibrary.Read Until Prompt
    ${match}  Get Regexp Matches  ${container}  \/ram\/node_UPUE.?[0-9]+\/[a-z.]+ -n 0x[0-9]{4}
    ${node_id}  Get Regexp Matches  ${match}[0]  0x[0-9]{4}
    ${cpue_match}  Get Regexp Matches  ${container}  \/ram\/node_CPUE.?[0-9]+\/[a-z.]+ -n 0x[0-9]{4}
    ${first_cpue_node_id}  Get Regexp Matches  ${cpue_match}[0]  0x[0-9]{4}
    ${second_cpue_node_id}  Get Regexp Matches  ${cpue_match}[1]  0x[0-9]{4}
    SSHLibrary.Set Client Configuration  prompt= >
    SSHLibrary.Write  cd /tmp
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  lxc-ls
    ${output_lxc}  SSHLibrary.Read Until Prompt
    Should Contain  ${output_lxc}  ${node_id}[0]  Virtual node ${node_id}[0] not exist
    SSHLibrary.Write  lxc-attach -n ${node_id}[0]
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  kill -SIGABRT $(echo $(ps -Leo tid,comm |grep "Disp_1") | awk '{ print $1 }')
    SSHLibrary.Read Until Prompt
    ${NODE_IDS}  Create List  ${node_id}[0]  ${first_cpue_node_id}[0]  ${second_cpue_node_id}[0]
    Set Test Variable  ${NODE_IDS}


Trigger Crash On CPUE Process
    [Documentation]  Triggers a crash on the specified CPUE process (cp_sb or cp_ue).
    ...  Kills the specified process using kill SIGABRT (or kill -6) abort signal.
    ...  Increments crash counter for cp_ue process.
    [Arguments]  ${process_name}

    Log  Trigger Crash On 5G CPUE ${process_name} File  console=true
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~ >|>)  timeout=10s
    SSHLibrary.Write  ps -aux | grep ${process_name}
    Sleep  5s
    ${output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output}
    ...  /opt/nokia/SS_CPLANE/bin/${process_name} --config /opt/nokia/SS_CPLANE/etc/${process_name}.enb_conf.ini
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -6 ${pid}
    SSHLibrary.Read Until Prompt
    IF  '${process_name}'=='cp_ue'
        ${NO_OF_CP_UE_CRASHES}  Evaluate  ${NO_OF_CP_UE_CRASHES} + 1
        Set Test Variable  ${NO_OF_CP_UE_CRASHES}  ${NO_OF_CP_UE_CRASHES}
    END


TC Setup
    Common Test Setup  tc_name=FM__FID4383_fault_signature_active_5G_RT_NRT_process
    Setup NetAct


TC Teardown
    Run Keyword And Ignore Error  SSHLibrary.Close All Connections
    Teardown NetAct
    Common Test Teardown
    Run Keyword And Ignore Error  Parse Syslog Files And Verify Fault Signature
