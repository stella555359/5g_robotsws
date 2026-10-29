*** Settings ***
Documentation
    ...  The purpose of the test is to verify changes introduced by feature CB008880 in case of NR RAT recovery reset.
    ...  In Step0, test parameters are configured based on the software branch, alarm parameters are set and variables
    ...  for fault signature verification are initialized. Step also determines if only 5G RAT is configured on SBTS.
    ...  In Step1, a site reset will be performed to clear all recovery reset counters.
    ...  In Step2, the CPCL software node will be crashed and RAT recovery reset will be checked for NR cells.
    ...  Alarm with fault 4383 will be checked in WebEM and Netact. Fault signature in alarm will be checked.
    ...  In Step3 and Step4, CPNB and TRACECC software nodes will be crashed. Recovery action, alarm presence and fault signature will be checked.
    ...  In Step5, the TRACECM software node will be crashed. RAT recovery reset is not performed. Alarm with the original fault is reported.
    ...  In Step6, if only 5G RAT is configured, the crash sequence (CPCL, CPNB, TRACECC, TRACECM) is repeated three more times
    ...  within a 1-hour window to activate the critical alarm and trigger site autonomous reset.
    ...  In Step7, the test blocks online NR cells, waits 11 minutes, and verifies that fault 4753 (RAT Outage alarm) is raised in WebEM and NetAct.
    ...  Then actAlarmOfRatOutage parameter is set to false and alarm clearance is verified.
    ...  In Step8, a maintenance window is created and the forced recovery mechanism is verified.
    ...  For 5G-only scenarios, maintenance window result is validated; otherwise, force recovery parameters are checked.
    ...  In Step9, the maintenance window is deleted/cleaned up.
    ...  In Step10, a site reset will be performed to recover services (skipped for 5G-only scenarios).
    ...  Software nodes will be crashed by executing kill -option command.
    ...  In releases higher than or equal to SBTS26R2 (functionality introduced by CNI-99796), for CPCL and CPNB sw nodes,
    ...  the test will randomly choose a kill method from: SIGKILL (kill -9) or SIGSTOP (kill -s SIGSTOP).
    ...  If the method of CPCL/CPNB crash is SIGSTOP, crashing of the other node will be done with SIGKILL.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM.
${CELLS_TIMEOUT}  180  # [in seconds] Timeout for cells to be in expected state.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact.
${RECOVERY_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after RAT reset.


*** Keywords ***
TC__FM__B_5G_RAT_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-26983
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26983 - Initial TAT creation
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27304 - Update fault signature check
    ...  15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27496 - Alarm not found at fault signature check
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27764 - Raise FID 4753 and check it's appearance
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27947 - Check FID 4753 only for newer releases
    ...  21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27965 - Block cells that are on air
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28423 - Test fail because "faulty cells" are calculated after physicalId not lcrId
    ...  06.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-29245 - 5G RAT only case covered
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29367 - Enhancement for CB008708
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29516 - Skip CB008708 for software versions below 25R3
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29708 - Enhancement covering the maintenance window case for 5G RAT only
    ...  04.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30285 - Test fails at fault signature check due to wrong minor field set
    ...  18.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30278 - Filtering alarms for different software versions
    ...  26.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30686 - Enhancement to increase test coverage for CNI-99796
    ...  ******************

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB008880  CNI-99796

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Crash CPCL Process And Verify Recovery
    Step3: Crash CPNB Process And Verify Recovery
    Step4: Crash TRACECC Process And Verify Recovery
    Step5: Crash TRACECM Process And Verify Original Fault
    Step6: Crash Processes And Verify Recovery If Only 5G
    Step7: Wait 11 Minutes And Verify Fault 4753
    Step8: Activate Maintenance Window
    Step9: Deactivate Maintenance Window
    Step10: Perform Site Reset


Step0: Set Parameters
    Log  \nStep0: Set parameters.  console=true

    IF  '${ENB_BRANCH}' < 'SBTS24R3'  Fail  CB008880 functionality not available in releases older than SBTS24R3.
    IF  '${ENB_BRANCH}' <= 'SBTS26R1'
        ${alarm_4383_parameters}  Get String With Alarm Parameters  ${FAULT_4383_VNODE_NOT_RESP}
        Set Test Variable  ${ALARM_4383_DICT}  ${FAULT_4383_VNODE_NOT_RESP}
        Set Test Variable  ${ALARM_4383_CRITICAL_PARAMETERS}  ${alarm_4383_parameters}
    ELSE
        ${alarm_4383_parameters}  Get String With Alarm Parameters  ${FAULT_4383_INTERNAL_NOT_RESP}
        Set Test Variable  ${ALARM_4383_DICT}  ${FAULT_4383_INTERNAL_NOT_RESP}
        Set Test Variable  ${ALARM_4383_CRITICAL_PARAMETERS}  ${alarm_4383_parameters}
    END
    Change FEATCADM Parameter  actRatResetEnhancement  true
    Change FMCADM Parameter  actAlarmOfRatOutage  true
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'  Maintenance Window Cleanup
    ${4753_parameters}  Get String With Alarm Parameters  ${FAULT_4753}
    Set Test Variable  ${4753_PARAMETERS}
    IF  '${SCF_COUNT_GSM}'=='0' and '${SCF_COUNT_WCDMA}'=='0' and '${SCF_COUNT_LTE}'=='0' and '${SCF_COUNT_NR}'!='0'
        Log  There are only 5G RAT on SBTS.  console=true
        Set Test Variable  ${ONLY_5G_RAT}  ${TRUE}
    ELSE
        Set Test Variable  ${ONLY_5G_RAT}  ${FALSE}
    END
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    Set Test Variable  ${NR_OF_TRACECM_CRASHES}  0
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${use_sigstop_process}  Evaluate  random.choice(['CPCL','CPNB'])  random
    ELSE
        ${use_sigstop_process}  Set Variable  ${None}
    END
    Set Test Variable  ${USE_SIGSTOP_PROCESS}


Step${index}: Perform Site Reset
    Log  \nStep${index}: Perform site reset.  console=true

    IF  ${index}==10 and ${ONLY_5G_RAT}==${TRUE}  RETURN
    Perform Site Reset
    Set Test Variables For Fault Signature
    ${date}  Get Current Date  time_zone=UTC
    Set Test Variable  ${START_TIME_TRIGGER_CRASHES}  ${date}


Step${index}: Crash ${name} Process And Verify Recovery
    Log  \nStep${index}: Crash ${name} process and verify recovery.  console=true

    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    IF  '${USE_SIGSTOP_PROCESS}' == '${name}'
        Crash Process  ${name}  SIGSTOP
    ELSE
        Crash Process  ${name}
    END
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_background}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=fault
    ${state}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${nr_cells_status}  Run Keyword And Return Status  Assert Every  NRCEL  ${state}  timeout=${CELLS_TIMEOUT}
    IF  ${nr_cells_status}
        Log  NR cells were failed. [OK]  console=true
    ELSE
        Set Test Failed  NR cells were not failed. [NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Check Modules And Cells
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was not reported in WebEM. [NOK]
    END
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${date_netact}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    ${minor_id}  Get Minor Id String For Fault Signature  ${DIST_NAME_${name}}
    IF  '${USE_SIGSTOP_PROCESS}' == '${name}'
        ${first_two}  Get Substring  ${name}  0  2
        ${last_two}  Get Substring  ${name}  2  4
        ${string}  Convert To Lower Case  ${first_two}-${last_two}
        ${info_field}  Set Variable  ${string} crash.*description: process did not acknowledge heartbeats
        ${category_field}  Set Variable  SW_FAILURE
    ELSE
        ${info_field}  Set Variable  ${INFO}
        ${category_field}  Set Variable  ${CATEGORY}
    END
    Log  Verify fault signature of fault in WebEM and Netact.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  filtering_minor_field=${minor_id}  category=${category_field}
    ...  extra_info=${EXTRA_INFO}  info=${info_field}  load_name=${SW_VERSION}  minor=${minor_id}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${date_netact}  category=CATEGORY:${SPACE}${category_field}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${info_field}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${minor_id}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Teardown Admin  alias=fault


Step${index}: Crash TRACECM Process And Verify Original Fault
    Log  \nStep${index}: Crash TRACECM process and verify original fault.  console=true

    Crash Process  TRACECM
    ${NR_OF_TRACECM_CRASHES}  Evaluate  ${NR_OF_TRACECM_CRASHES} + 1
    Set Test Variable  ${NR_OF_TRACECM_CRASHES}
    IF  ${ONLY_5G_RAT} and ${NR_OF_TRACECM_CRASHES} < 4
        Verify Site Reset Auto Alarm In WebEM And Netact
        RETURN
    END
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${ALARM_4383_CRITICAL_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${ALARM_4383_DICT} was reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${ALARM_4383_DICT} was not reported in WebEM. [NOK]
    END
    ${state}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${nr_cells_status}  Run Keyword And Return Status  Assert Every  NRCEL  ${state}  timeout=${CELLS_TIMEOUT}
    IF  ${nr_cells_status}
        Log  NR cells were failed. [OK]  console=true
    ELSE
        Set Test Failed  NR cells were not failed. [NOK]
    END
    Sleep  ${NETACT_TIMEOUT}s  Wait for fault to be reported in Netact.
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  &{ALARM_4383_DICT}
    ...  additional_fault_id=${ALARM_4383_DICT}[fault_id]
    IF  ${fault_status_netact}
        Log  Fault ${ALARM_4383_DICT} was reported in Netact. [OK]  console=true
    ELSE
        Fail  Fault ${ALARM_4383_DICT} was not reported in Netact.
    END


Verify Site Reset Auto Alarm In WebEM And Netact
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_SITE_AUTO_RST}
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${FAULT_4383_SITE_AUTO_RST}[fault_id] "${FAULT_4383_SITE_AUTO_RST}[fault_name]" was reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_SITE_AUTO_RST}[fault_id] "${FAULT_4383_SITE_AUTO_RST}[fault_name]" was not reported in WebEM. [NOK]
    END

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    IF  ${ping_loss_status}==${FALSE}
        Set Test Failed  Ping has not been lost within timeout=120
    ELSE
        Log  Ping is lost  console=true
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=120
    IF  ${ping_regain_status}==${FALSE}
        Set Test Failed  Ping has not been regained within timeout
    ELSE
        Log  Target is Reachable  console=true
    END
    Wait Until Keyword Succeeds  600  10  Assert Every  NRCEL  operationalState=${ENABLED}  timeout=10
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_SITE_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4383_SITE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_SITE_AUTO_RST}[fault_id] "${FAULT_4383_SITE_AUTO_RST}[fault_name]" is cleared in Netact. [OK]  console=true


Set Test Variables For Fault Signature
    ${cells_string}  Get Matching Lcr Ids String For All RAT Cells  NRCEL
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=NR:${cells_string}
    ${sw_nodes_list}  coam.Get Managed Objects  SW_NODE_L
    FOR  ${sw_node}  IN  @{sw_nodes_list}
        IF  '${sw_node}[parameters][rat]'=='NR' and 'CPCL' in '${sw_node}[parameters][hostname]'
            ${sw_node_cpcl}  Set Variable  ${sw_node}
            CONTINUE
        END
        IF  '${sw_node}[parameters][rat]'=='NR' and 'CPNB' in '${sw_node}[parameters][hostname]'
            ${sw_node_cpnb}  Set Variable  ${sw_node}
            CONTINUE
        END
        IF  '${sw_node}[parameters][rat]'=='NR' and 'TRACECC' in '${sw_node}[parameters][hostname]'
            ${sw_node_tracecc}  Set Variable  ${sw_node}
        END
    END
    Set Test Variable  ${DIST_NAME_CPCL}  ${sw_node_cpcl}[distName]
    Set Test Variable  ${DIST_NAME_CPNB}  ${sw_node_cpnb}[distName]
    Set Test Variable  ${DIST_NAME_TRACECC}  ${sw_node_tracecc}[distName]
    ${smod_l_dn}  Fetch From Left  ${sw_node_cpcl}[distName]  /SMOD_L-1
    ${MODULE_R_DN}  Get Runtime Object Dist_name From Logical Object Dist_name  ${smod_l_dn}/SMOD_L-1
    ${smod_l_parameters}  coam.Get Parameters  ${MODULE_R_DN}
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${smod_l_parameters}[coreHwBoardSerialNumber]
    Set Test Variable  ${CORE_PRODUCT_CODE}  ${smod_l_parameters}[coreHwBoardProductCode]
    Set Test Variable  ${PRODUCT_NAME}  ${smod_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_l_parameters}[serialNumber]
    ${smod_r_list}  coam.Get Managed Objects  SMOD_R
    FOR  ${smod}  IN  @{smod_r_list}
         IF  '${smod}[parameters][serialNumber]'=='${smod_l_parameters}[serialNumber]'
             ${smod_r}  Set Variable  ${smod}
             BREAK
         END
    END
    Set Unit Position For Fault Signature  ${smod_r}[distName]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${SCOPE}  NR RAT
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Get Minor Id String For Fault Signature
    [Arguments]  ${sw_node_dist_name}

    ${sw_node_parameters}  coam.Get Parameters  ${sw_node_dist_name}
    ${sw_node_id}  Convert To Hex  ${sw_node_parameters}[nodeId]  prefix=0x
    ${process_name}  Get Regexp Matches  ${sw_node_parameters}[hostname]  [A-Z]+
    IF  '${ENB_BRANCH}' < 'SBTS24R3'
        ${minor_id_string}  Set Variable  ${sw_node_id}
    ELSE IF  '${USE_SIGSTOP_PROCESS}' in '${sw_node_parameters}[hostname]'
        ${minor_id_string}  Set Variable  ${process_name}[0]${SPACE}${sw_node_id}
    ELSE
        ${minor_id_string}  Set Variable  ${sw_node_id}${SPACE}${process_name}[0]
    END

    RETURN  ${minor_id_string}


Crash Process
    [Arguments]  ${name}  ${crash_type}=SIGKILL

    IF  '${crash_type}'=='SIGKILL'
        Crash Process With Sigkill  ${name}
    ELSE IF  '${crash_type}'=='SIGSTOP'
        Crash Process With Sigstop  ${name}
    END


Crash Process With Sigkill
    [Documentation]  Kills the specified process using SIGKILL (-9) signal.
    [Arguments]  ${name}

    Log  Crash ${name} process using SIGKILL.  console=true
    Open Connection To Primary Core
    SSHLibrary.Write  ps aux | grep lxc
    ${output}  SSHLibrary.Read Until Prompt
    ${status}  ${lines}  Run Keyword And Ignore Error  Get Lines Containing String  ${output}  ${name}
    IF  '${status}' == '${FALSE}'
        Open Connection To Secondary Core
        SSHLibrary.Write  ps aux | grep lxc
        ${output}  SSHLibrary.Read Until Prompt
        ${lines}  Get Lines Containing String  ${output}  ${name}
    END
    ${root}  Get Regexp Matches  ${lines}  root *[0-9]*
    ${process_id}  Evaluate  random.choice(${root})  random
    ${id}  Get Regexp Matches  ${process_id}  [0-9]+
    SSHLibrary.Write  kill -9 ${id}[0]
    SSHLibrary.Read Until Prompt


Step6: Crash Processes And Verify Recovery If Only 5G
    Log  \nStep6: Crash Processes And Verify Recovery If Only 5G.  console=true

    IF  ${ONLY_5G_RAT}
        Log  SBTS contains only 5G cells. Therefore, crashes will be repeated three more times to activate the critical alarm.  console=true
        FOR  ${loop}  IN RANGE  2  5
            Log  \nIteration ${loop} of sending the 4 faults.  console=true
            Check 1 Hour Target For Only 5G Scenario
            ${loop}  Catenate  SEPARATOR=.  6  ${loop}
            Step${loop}: Crash CPCL Process And Verify Recovery
            Step${loop}: Crash CPNB Process And Verify Recovery
            Step${loop}: Crash TRACECC Process And Verify Recovery
            Step${loop}: Crash TRACECM Process And Verify Original Fault
        END
    ELSE
        Log  SBTS do not contains only 5G cells. Test will continue.  console=true
    END


Step7: Wait 11 Minutes And Verify Fault 4753
    Log  \nStep7: Wait 11 minutes and verify fault 4753.  console=true

    IF  '${ENB_BRANCH}' < 'SBTS24R3'
        Log  Software branch is: ${ENB_BRANCH}. No need to run this step.  console=true
        RETURN
    END
    IF  ${ONLY_5G_RAT}  RETURN
    Block online cells for given RAT  nr
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Sleep  11 min  Wait for fault to appear.
    Assert Alarm Active  parameters=${4753_PARAMETERS}  timeout=120s
    Log  Fault ${FAULT_4753}[fault_id] with name "${FAULT_4753}[fault_name]" - reported in WebEM. [OK]  console=true
    Change FMCADM Parameter  actAlarmOfRatOutage  false
    Assert Alarm Inactive  parameters=${4753_PARAMETERS}  timeout=180s
    Log  Fault ${FAULT_4753}[fault_id] with name "${FAULT_4753}[fault_name]" - cleared from WebEM. [OK]  console=true
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4753}  time_from=${date_netact}
    ...  additional_fault_id=${FAULT_4753}[fault_id]  suppl_info=All cells are failed
    IF  ${fault_status_netact}
        Log  Fault ${FAULT_4753}[fault_id] with name "${FAULT_4753}[fault_name]" - reported in NetAct. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4753}[fault_id] with name "${FAULT_4753}[fault_name]" - not reported in NetAct. [NOK]
    END


Step8: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep8: Activate Maintenance Window.  console=true

    Create Maintenance Window
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  10s  Check All Cells
    IF  ${ONLY_5G_RAT}
        Verify Maintenance Window Result If 5G Only
    ELSE
        ${parameter_object}  Wait Until Keyword Succeeds  300  10  Get Forced Recovery Parameter When Is Completed
        Verify Force Recovery Parameters  ${parameter_object}  ${ALARM_4383_DICT}
    END


Step9: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep9: Deactivate Maintenance Window.  console=true

    Delete Maintenance Window


Check 1 Hour Target For Only 5G Scenario
    ${current_date}  Get Current Date  time_zone=UTC
    ${timestamp1}  Fetch From Right  ${START_TIME_TRIGGER_CRASHES}  ${SPACE}
    ${timestamp2}  Fetch From Right  ${current_date}  ${SPACE}
    ${time_diff}  Subtract Time From Time  ${timestamp1}  ${timestamp2}  result_format=number
    ${time_hour}  Convert Time  ${time_diff}  verbose
    ${time}  Fetch From Right  ${time_hour}  -${SPACE}
    ${time_final}  Fetch From Left  ${time}  ${SPACE}minutes
    Log  \nTime passed since the previous BTS site autonomous reset: ${time_final}  console=true
    ${remaining_time}  Evaluate  60-${time_final}
    Log  Minutes remaining to reach the 1 hour target: ${remaining_time} minutes  console=true
    IF  ${remaining_time}>15
        Log  There are more than 15 minutes left before 1 hour target is reached.  console=true
    ELSE IF  ${remaining_time}==15
        Log  There are only 15 minutes left before 1 hour target is reached. It's time for only one iteration more.  console=true
    ELSE
        Fail  Test scenario could not be executed into 1 hour to complete test scenario.
    END


Verify Maintenance Window Result If 5G Only
    ${recovery_execution_result}  Set Variable  BTS site recovery reset:MRBTS-${BTS_ID}
    ${list}  Create List  maintenanceWindowResult
    Log  \nVerifying maintenance window result in Parameter Editor to be equal to recoveryExecutionResult from Info Model.  console=true
    ${maintenance_window_result_object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${actual_value_parameter_editor}  Set Variable  ${maintenance_window_result_object}[0][parameters][maintenanceWindowResult]
    Check Equality For Force Recovery Parameter  ${recovery_execution_result}  ${actual_value_parameter_editor}
    ...  Maintenance Window Result did not match.
    Log  Maintenance Window Result from Parameter Editor was correctly completed.  console=true

    Log  \nVerifying maintenance window result from Netact to be equal to recoveryExecutionResult from Parameter Editor.  console=true
    Log  Parameter from the given path is not present in CM Editor, configuration must be uploaded from CM Operations Manager.  console=true
    ${maintenance_window_result_netact}  Upload Configuration and Get Maintenance Window Result From Netact

    Check Equality For Force Recovery Parameter  ${actual_value_parameter_editor}  ${maintenance_window_result_netact}[maintenanceWindowResult]
    ...  Maintenance Window Result From the Parameter Editor did not match the one from Netact.
    Log  Maintenance Window Result from Netact was correctly completed.  console=true


Recovery Action If Test Fails
    Change FMCADM parameter  actAlarmOfRatOutage  false
    Maintenance Window Cleanup
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__B_5G_RAT_reset_counter_exceeded
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Recovery Action If Test Fails
    Teardown NetAct
    Common Test Teardown
