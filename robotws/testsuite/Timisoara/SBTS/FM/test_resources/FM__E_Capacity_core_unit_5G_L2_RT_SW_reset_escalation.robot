*** Settings ***
Documentation
    ...  This TC stops four times one L2 process, which is processing 5G cells, via pkill command.
    ...  1: Site reset is performed to clear all counters.
    ...  2: ABIO, ABIN or ASOE (depending on MODULE_TYPE variable) with 5G RAT is chosen randomly.
    ...  3: Ssh connection to SoC 0 (Snowfish) of module is established.
    ...  4: List of L2 processes are found by sending the command ll in /ram folder on SoC 0. One L2 process is chosen randomly to be stopped.
    ...  The first 3 operations of stopping the L2 process cause
    ...  the fault 4383 with name: 'Internal BTS processes autonomous reset as recovery action' to appear.
    ...  ActForceAutoReset is set to True and at the 4th operation fault 4383 with name: 'RAT autonomous reset as recovery action' will appear.
    ...  If fault 'Internal BTS processes autonomous reset as recovery action' is active, 5G cells linked to L2 process will be Failed.
    ...  In the second case when fault 'RAT autonomous reset as recovery action' appears, all 5G cells are offline.
    ...  In the end, after the 4th operation and the proper checks, all cells must be onAir.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${MODULE_TYPE}  ${EMPTY}  # Optional, either module type or serial number must be provided; type can be ABIO, ABIN, ABIP, ABIQ, ASOE or ASOF.
${MODULE_SN}  ${EMPTY}  # Optional, either module type or serial number must be provided; module serial number for test.
${CELLS_FAILED_TIMEOUT}  300
${CELLS_ONLINE_TIMEOUT}  600
${ALARM_TIMEOUT}  300
${NETACT_TIMEOUT}  120


*** Keywords ***
TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22954
    ...
    ...  History of changes
    ...  ******************
    ...  12.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22954 - Initial TAT creation
    ...  26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24350 - Add common keywords
    ...  05.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25316 - Costumize TC to work with ASOE
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26034 - Update cells check timing
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26509 - Adapt TC to work with ASOF
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26883 - Adapt TC to work with ABIP and ABIQ
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26949 - Update TC's crashing methods
    ...  20.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27529 - Keyword fail
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  12.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27616 - Changing the site reset method
    ...  13.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27632 - Handling multiple cases in the site reset method
    ...  02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27545 - Improving cells check
    ...  02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27547 - Filter actRatResetEnhancement changes based of SW version
    ...  09.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27761 - Changing procces name for each crash
    ...  09.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27907 - Update infomodel query
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28315 - Increase prompt timeout
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29292 - Fix L2 RT process name identification
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  12.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29704 - Test fails at faultsignature check
    ...  11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29824 - Test needs update to add SN
    ...  12.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30628 - Wait until alarm history is populated
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22  FEATURE-CB007442

    Step1: Perform Site Reset To Clear All Counters
    Step2: Set Variables And Open Connection To SoC
    Step3: Cause Crash Of 5G L2RT SW Component
    Step4: Cause Crash Of 5G L2NRT SW Component
    Step5: Cause Crash Of 5G L3 SW Component
    Step6: Cause Crash Of Random SW Component


Step1: Perform Site Reset To Clear All Counters
    Log  \nStep1: Perform site reset to clear all counters.  console=true
    IF  ${SCF_COUNT_NR} == 0  Fail  5G RAT does not exist.
    IF  '${MODULE_TYPE}'=='${EMPTY}' and '${MODULE_SN}'=='${EMPTY}'  Fail  Please provide MODULE_TYPE or MODULE_SN for test.
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
    IF  '${ENB_BRANCH}'>='SBTS24R2' or '${ENB_BRANCH}'=='SBTS00'  Change FEATCADM Parameter  actRatResetEnhancement  true


Step2: Set Variables And Open Connection To SoC
    Log  \nStep2: Set variables and open connection to SoC.  console=true
    IF  '${MODULE_SN}'!='${EMPTY}'
        Choose Module Bassed On Serial Number
    ELSE IF  '${MODULE_TYPE}'=='${EMPTY}'
        Fail  Please provide module type (ABIO/ABIN/ABIP/ABIQ/ASOE/ASOF).
    ELSE IF  '${MODULE_TYPE}' == 'ASOE' or '${MODULE_TYPE}' == 'ASOF'
        Choose Random Module That Processes 5G Cells  SMOD
    ELSE
        Choose Random Module That Processes 5G Cells  BBMOD
    END
    Set Test Variables For Fault Signature
    ${param_initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${PARAM_INITIAL_VALUE}
    Set M Dist Names For All 5G Cells

    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    Open Ssh Connection To SBTS
    Set Names And Hex Addresses For All Processes
    Set Cells For L2rt Process  ${L2_RT_PROCESS_NAME}
    ${module_r_id}  Fetch From Right  ${MODULE_R_DN}  /
    Log  ${L2_RT_PROCESS_NAME} process on ${module_r_id} is chosen.  console=true

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    Set Test Variable  ${ALARM_PARAMETERS}  ${alarm_parameters}
    ${4th_alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    Set Test Variable  ${4_TH_ALARM_PARAMETERS}  ${4th_alarm_parameters}


Step3: Cause Crash Of 5G L2RT SW Component
    Log  \nStep3: Cause crash of 5G L2RT SW component.  console=true
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact  process_name=${L2_RT_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}
    ...  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Disabled
    ...  availability_status=Failed


Step4: Cause Crash Of 5G L2NRT SW Component
    Log  \nStep4: Cause crash of 5G L2NRT SW component.  console=true
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact  process_name=${L2_NRT_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}
    ...  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Enabled


Step5: Cause Crash Of 5G L3 SW Component
    Log  \nStep5: Cause crash of 5G L3 SW component.  console=true
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact  process_name=${L3_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}
    ...  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Enabled


Step6: Cause Crash Of Random SW Component
    Log  \nStep6: Cause crash of random SW component.  console=true
    ${list_names_crash}  Create List  L2RT  L2NRT  L3
    ${random_crash_name}  Evaluate  random.choice(${list_names_crash})  random
    IF  '${random_crash_name}'=='L2RT'
        Crash L2RT Process For 3 More Times
    ELSE IF  '${random_crash_name}'=='L2NRT'
        Crash L2NRT Process For 3 More Times
    ELSE IF  '${random_crash_name}'=='L3'
        Crash L3 Process For 3 More Times
    END


Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    [Arguments]
    ...  ${process_name}
    ...  ${alarm_parameters}
    ...  ${fault_parameters}
    ...  ${scope_fault_signature}
    ...  ${administrative_state}
    ...  ${operational_state}
    ...  ${availability_status}=${EMPTY}

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_alarm
    ${status_l2rt}  Run Keyword And Return Status  Should Contain  ${process_name}  L2RT
    ${status_upue}  Run Keyword And Return Status  Should Contain  ${process_name}  UPUE
    ${status_cpue}  Run Keyword And Return Status  Should Contain  ${process_name}  CPUE
    IF  ${status_l2rt}
        Stop L2RT Process  ${L2_RT_PROCESS_ADDRESS}
    ELSE IF  ${status_upue}
        Stop L2NRT Process  ${L2_NRT_PROCESS_ADDRESS}
    ELSE IF  ${status_cpue}
        Stop L3 Process  ${L3_PROCESS_ADDRESS}
    ELSE
        Fail  No suitable process was found. [NOK]
    END
    ${minor}  Set Variable If  ${status_l2rt}  ${L2_RT_PROCESS_ADDRESS}
    ...  ${status_upue}  ${L2_NRT_PROCESS_ADDRESS}
    ...  ${status_cpue}  .*(CPUE)?.*${L3_PROCESS_ADDRESS}
    Verify Cells Status And Alarm In WebEM And Netact  ${alarm_parameters}  ${fault_parameters}  ${administrative_state}  ${operational_state}
    ...  ${availability_status}
    Log  Check fault signature.  console=true
    Wait Until Keyword Succeeds  120s  2s  Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}
    ...  load_name=${SW_VERSION}  minor=${minor}  reset_counter=${RESET_COUNTER}  scope=${scope_fault_signature}  info=${INFO}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${start_time}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${minor}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${scope_fault_signature}  info=INFO:${SPACE}${INFO}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Crash L2RT Process For 3 More Times
    Log  Crash L2RT process for 3 more times and check alarms in WebEM and Netact.  console=true
    Repeat Keyword  2
    ...  Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L2_RT_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}
    ...  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Disabled  availability_status=Failed
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L2_RT_PROCESS_NAME}  alarm_parameters=${4_TH_ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_RAT_AUTO_RST}
    ...  scope_fault_signature=${SCOPE_RAT}  administrative_state=Unlocked  operational_state=Disabled  availability_status=Failed


Crash L2NRT Process For 3 More Times
    Log  Crash L2NRT process for 3 more times and check alarms in WebEM and Netact.  console=true
    Repeat Keyword  2
    ...  Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L2_NRT_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}
    ...  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Enabled
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L2_NRT_PROCESS_NAME}  alarm_parameters=${4_TH_ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_RAT_AUTO_RST}
    ...  scope_fault_signature=${SCOPE_RAT}  administrative_state=Unlocked  operational_state=Disabled  availability_status=Failed


Crash L3 Process For 3 More Times
    Log  Crash L3 process for 3 more times and check alarms in WebEM and Netact.  console=true
    Repeat Keyword  2
    ...  Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L3_PROCESS_NAME}  alarm_parameters=${ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_PROCESSES_AUTO_RST}
    ...  scope_fault_signature=${SCOPE}  administrative_state=Unlocked  operational_state=Enabled
    Crash On Process And Verify Cells Status And Alarm In WebEM And Netact
    ...  process_name=${L3_PROCESS_NAME}  alarm_parameters=${4_TH_ALARM_PARAMETERS}  fault_parameters=${FAULT_4383_RAT_AUTO_RST}
    ...  scope_fault_signature=${SCOPE_RAT}  administrative_state=Unlocked  operational_state=Disabled  availability_status=Failed


Verify Cells Status And Alarm In WebEM And Netact
    [Arguments]  ${alarm_parameters}  ${fault_dict}  ${administrative_state}  ${operational_state}  ${availability_status}=${EMPTY}

    ${time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${alarm_webem}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_alarm
    IF  '${fault_dict}[fault_name]'=='RAT autonomous reset as recovery action'
        Verify All NR Cells To Be In The Right State  ${DISABLED}
    ELSE
        Verify Cells On Process To Be In The Right State  ${administrative_state}  ${operational_state}  ${availability_status}
    END

    ${check_alarm_webem}  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    IF  ${check_alarm_webem}
        Log  Fault ${fault_dict}[fault_id] - ${fault_dict}[fault_name] is active in WebEm.  console=true
    ELSE
        Fail  Fault ${fault_dict}[fault_id] - ${fault_dict}[fault_name] is not active in WebEm.
    END
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=180
    Log  Fault ${fault_dict}[fault_id] - ${fault_dict}[fault_name] is inactive in WebEm.  console=true

    Wait Until Keyword Succeeds  180  1
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{fault_dict}  time_from=${time}
    ...  additional_fault_id=${fault_dict}[fault_id]

    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CELLS_ONLINE_TIMEOUT}  5
    ...  Check All Cells
    IF  ${status}
        Log  All cells are onAir.  console=true
    ELSE
        Set Test Failed  Not all cells are onAir.
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_alarm


Choose Random Module That Processes 5G Cells
    [Arguments]  ${smod_bbmod}

    ${module_dn_list}  Create List
    ${module_dns}  Get Ids For All  ${smod_bbmod}
    FOR  ${module_dn}  IN  @{module_dns}
        ${module_parameters}  coam.Get Parameters For  ${smod_bbmod}  ${module_dn}
        ${module_type_status}  Run Keyword And Return Status  Should Contain  ${module_parameters}[productName]  ${MODULE_TYPE}
        ${cells_on_module_dns}  coam.Get Cell Mapping By Module Id  ${module_dn}
        ${nr_status}  Check If NR Is Deployed On Module  ${cells_on_module_dns}
        IF  ${module_type_status} and ${nr_status}  Append To List  ${module_dn_list}  ${module_dn}
    END
    ${length}  Get Length  ${module_dn_list}
    IF  ${length} == 0  Fail  SBTS does not have ${MODULE_TYPE} unit with 5G cells.
    ${random_module_dn}  Evaluate  random.choice(${module_dn_list})  random
    Set Test Variable  ${MODULE_R_DN}  ${random_module_dn}
    ${module_parameters}  coam.Get Parameters  ${MODULE_R_DN}
    ${module_l_dn}  Get Module L Dist Name  ${module_parameters}[serialNumber]  ${smod_bbmod}
    Set Test Variable  ${MODULE_L_DN}


Choose Module Bassed On Serial Number
    ${smods_list}  Get Fsm Info
    ${bbmods_list}  Get Fbb Info
    ${modules_list}  Combine Lists  ${smods_list}  ${bbmods_list}
    FOR  ${module}  IN  @{modules_list}
        IF  '${module}[serialNumber]'=='${MODULE_SN}'
            Set Test Variable  ${MODULE_R_DN}  ${module}[id][internal]
            ${smod_bbmod}  Set Variable If  'ASOE' in '${module}[productName]' or 'ASOF' in '${module}[productName]'  SMOD  BBMOD
            BREAK
        END
    END
    ${module_parameters}  coam.Get Parameters  ${MODULE_R_DN}
    ${module_l_dn}  Get Module L Dist Name  ${module_parameters}[serialNumber]  ${smod_bbmod}
    Set Test Variable  ${MODULE_L_DN}


Check If NR Is Deployed On Module
    [Arguments]  ${cells_on_module_dns}

    FOR  ${cell_dn}  IN  @{cells_on_module_dns}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCEL
        IF  ${status}  Return From Keyword  ${TRUE}
    END

    [Return]  ${FALSE}


Set M Dist Names For All 5G Cells
    ${all_cells_m_dn}  Create List
    ${result}  Get Bts Info
    ${dict}  Set Variable  ${result}[cells]
    FOR  ${key}  IN  @{dict.keys()}
        ${cell_m_on_rat}  Get M Dist Names For Cells On Every RAT  ${dict}[${key}]
        Append To List  ${all_cells_m_dn}  @{cell_m_on_rat}
    END
    ${all_5g_cells_dn}  Create List
    FOR  ${cell_m_dn}  IN  @{all_cells_m_dn}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_m_dn}  NRBTS
        IF  ${status}  Append To List  ${all_5g_cells_dn}  ${cell_m_dn}
    END
    Set Test Variable  ${ALL_5_G_CELLS_M_DN}  ${all_5g_cells_dn}


Get M Dist Names For Cells On Every RAT
    [Arguments]  ${rat_list}

    ${m_dn_list}  Create List
    FOR  ${cell}  IN  @{rat_list}
        ${first_channel_m_dn}  Get M Dist Name For One Cell  ${cell}[carrierList]
        ${cell_m_dn}  Fetch From Left  ${first_channel_m_dn}  /CHANNEL_GROUP_M
        Append To List  ${m_dn_list}  ${cell_m_dn}
    END

    [Return]  ${m_dn_list}


Get M Dist Name For One Cell
    [Arguments]  ${carrier_list}

    FOR  ${carrier}  IN  @{carrier_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${carrier}[id][internal]  CHANNEL_M
        IF  ${status}  Return From Keyword  ${carrier}[id][internal]
    END


Set Cells For L2rt Process
    [Arguments]  ${l2rt_process_name}

    ${cells_on_process}  Create List
    ${cell_to_pool_list}  Query Infomodel  get list //NRTS-*/CELL_TO_POOL_MAPPING_L-*
    FOR  ${object}  IN  @{cell_to_pool_list}
        ${pool_dn}  Get First Pool DN For L2_RT  ${object}[cellSlots]
        ${core_pool}  coam.Get Parameters  ${pool_dn}
        ${core_dn}  Set Variable  ${core_pool}[cores][0][coreDN]
        ${sw_node_schema}  coam.Get Parameters  ${core_dn}
        ${status}  Check If Cell Is On L2_RT Process Chosen  ${l2rt_process_name}  ${sw_node_schema}[uniqueInstanceId]
        IF  ${status}  Append To List  ${cells_on_process}  ${object}[cellDN]
    END
    Set Test Variable  ${CELLS_ON_PROCESS}
    ${5_g_cells_m_dn_left}  Create List  @{ALL_5_G_CELLS_M_DN}
    Remove Values From List  ${5_g_cells_m_dn_left}  @{CELLS_ON_PROCESS}
    Set Test Variable  ${5_G_CELLS_M_DN_LEFT}


Get First Pool DN For L2_RT
    [Arguments]  ${cell_slots}

    FOR  ${slot}  IN  @{cell_slots}
        IF  '${slot}[type]'=='L2_RT'  RETURN  ${slot}[poolDN]
    END


Check If Cell Is On L2_RT Process Chosen
    [Arguments]  ${l2rt_process_name}  ${unique_instance_number}

    IF  '${MODULE_TYPE}' in ['ASOE','ASOF','ABIP','ABIQ']
        ${sw_node_l_list}  Query Infomodel  get list ${MODULE_L_DN}/BOARD_L-1/POWER_GROUP_L-1/SOC_L-1/SW_NODE_L-*
    ELSE
        ${sw_node_l_list}  Query Infomodel  get list ${MODULE_L_DN}/BBU_L-1/POWER_GROUP_L-1/SOC_L-1/SW_NODE_L-*
    END
    FOR  ${sw_node_obj}  IN  @{sw_node_l_list}
        IF  '${sw_node_obj}[hostname]'=='${l2rt_process_name}' and '${sw_node_obj}[uniqueInstanceId]'=='${unique_instance_number}'
            RETURN  ${TRUE}
        END
    END

    [Return]  ${FALSE}


Open Ssh Connection To SBTS
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    ${module_vertical_position}  Get Module Vertical Position  ${MODULE_R_DN}
    Open Connection To Primary Core
    IF  '${smod_stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${module_vertical_position}  0


Set Names And Hex Addresses For All Processes
    SSHLibrary.Set Client Configuration  prompt=:/ram >  timeout=30s
    SSHLibrary.Write  cd /ram
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l
    ${output_ll}  SSHLibrary.Read Until Prompt
    ${l2rt_lines_concatenated}  Get Lines Containing String  ${output_ll}  /ram/node_L2RT
    ${upue_lines_concatenated}  Get Lines Containing String  ${output_ll}  /ram/node_UPUE
    ${cpue_lines_concatenated}  Get Lines Containing String  ${output_ll}  /ram/node_CPUE

    ${l2rt_lines}  Split To Lines  ${l2rt_lines_concatenated}
    ${upue_lines}  Split To Lines  ${upue_lines_concatenated}
    ${cpue_lines}  Split To Lines  ${cpue_lines_concatenated}

    ${l2rt_process}  Evaluate  random.choice(${l2rt_lines})  random
    ${upue_process}  Evaluate  random.choice(${upue_lines})  random
    ${cpue_process}  Evaluate  random.choice(${cpue_lines})  random

    ${l2rt_process_name}  Get Regexp Matches  ${l2rt_process}  L2RT_?[a-zA-Z0-9]+
    ${upue_process_name}  Get Regexp Matches  ${upue_process}  UPUE[a-zA-Z0-9]+
    ${cpue_process_name}  Get Regexp Matches  ${cpue_process}  CPUE[a-zA-Z0-9]+

    ${l2rt_node_hex}  Get Regexp Matches  ${l2rt_process}  node_0x\\d+
    ${upue_node_hex}  Get Regexp Matches  ${upue_process}  node_0x\\d+
    ${cpue_node_hex}  Get Regexp Matches  ${cpue_process}  node_0x\\d+

    ${l2rt_process_address}  Remove String  ${l2rt_node_hex}[0]  node_
    ${upue_process_address}  Remove String  ${upue_node_hex}[0]  node_
    ${cpue_process_address}  Remove String  ${cpue_node_hex}[0]  node_

    ${l2rt_process_name}  Fetch From Left  ${l2rt_process_name}[0]  a
    ${l2nrt_process_name}  Fetch From Left  ${upue_process_name}[0]  a
    ${l3_process_name}  Fetch From Left  ${cpue_process_name}[0]  a

    Set Test Variable  ${L2_RT_PROCESS_NAME}  ${l2rt_process_name}
    Set Test Variable  ${L2_NRT_PROCESS_NAME}  ${l2nrt_process_name}
    Set Test Variable  ${L3_PROCESS_NAME}  ${l3_process_name}

    Set Test Variable  ${L2_RT_PROCESS_ADDRESS}  ${l2rt_process_address}
    Set Test Variable  ${L2_NRT_PROCESS_ADDRESS}  ${upue_process_address}
    Set Test Variable  ${L3_PROCESS_ADDRESS}  ${cpue_process_address}


Stop L2RT Process
    [Arguments]  ${l2rt_process_address}

    SSHLibrary.Write  pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=${l2rt_process_address}'
    SSHLibrary.Read Until Prompt
    Log  The command to stop L2RT process has been sent.  console=true


Stop L2NRT Process
    [Arguments]  ${l2nrt_process_address}

    SSHLibrary.Write  pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=${l2nrt_process_address}'
    SSHLibrary.Read Until Prompt
    Log  The command to stop L2NRT process has been sent.  console=true


Stop L3 Process
    [Arguments]  ${l3_process_address}

    SSHLibrary.Write  pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=${l3_process_address}'
    SSHLibrary.Read Until Prompt
    Log  The command to stop L3 process has been sent.  console=true


Check Cell M Objects
    [Arguments]  ${cells_m_dn_list}  ${administrative_state}  ${operational_state}  ${availability_status}=${EMPTY}

    FOR  ${cell_m_dn}  IN  @{cells_m_dn_list}
        ${parameters}  coam.Get Parameters  ${cell_m_dn}
        Should Be Equal As Strings  ${parameters}[stateInfo][administrativeState]  ${administrative_state}
        Should Be Equal As Strings  ${parameters}[stateInfo][operationalState]  ${operational_state}
        IF  '${availability_status}'!='${EMPTY}'  Should Be Equal As Strings  ${parameters}[stateInfo][availabilityStatus]  ${availability_status}
    END


Verify Cells On Process To Be In The Right State
    [Arguments]  ${administrative_state}  ${operational_state}  ${availability_status}

    ${status_cells_on_process}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CELLS_FAILED_TIMEOUT}  1
    ...  Check Cell M Objects  ${CELLS_ON_PROCESS}  ${administrative_state}  ${operational_state}  ${availability_status}
    IF  ${status_cells_on_process}
        Log  5G cells are ${administrative_state} ${operational_state}.[OK]  console=true
    ELSE
        Set Test Failed  5G cells are not in the right state ${administrative_state} ${operational_state}. [NOK]
    END


Verify All NR Cells To Be In The Right State
    [Arguments]  ${operational_state}

    Assert Every  NRCEL  operationalState=${operational_state}  timeout=300
    Log  All NR cells are in the right state - ${operational_state}.  console=true


Set Test Variables For Fault Signature
    Log  Setting variables for fault signature.  console=true
    ${is_smod}  Run Keyword And Return Status  Should Contain  ${MODULE_L_DN}  SMOD
    ${module_type}  Set Variable If  ${is_smod}  SMOD  BBMOD
    ${module_l_parameters}  Query Infomodel  get object ${MODULE_L_DN}
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    IF  '${module_type}' == 'SMOD'
        ${module_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${module_l_parameters}[serialNumber]]
    ELSE
        ${module_r}  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${module_l_parameters}[serialNumber]]
    END
    Set Unit Position For Fault Signature  ${module_r}[dist_name]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  Virtual Node
    Set Test Variable  ${SCOPE_RAT}  NR RAT
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${INFO}  .*(AaError_Linux|CCSDaemon crash)?.*


TC Setup
    Common Test Setup  tc_name=FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  ${PARAM_INITIAL_VALUE}  actForceAutoReset
    Teardown NetAct
    Common Test Teardown