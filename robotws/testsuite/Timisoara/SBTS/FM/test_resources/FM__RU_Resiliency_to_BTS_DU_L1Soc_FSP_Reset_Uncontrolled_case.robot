*** Settings ***
Documentation
    ...  The feature is activated by setting the parameter ActForce(Unit)AutoReset to true,
    ...  setting the parameter actRuResetResiliency to true
    ...  and changing the parameter uncntrldResetMplaneBreakTime to 420.
    ...  This test should be executed on a random BBMOD that has a CPRI/eCPRI RMOD connected to it
    ...  and 4G/5G RAT mapped there.
    ...  The BBMOD should also have a variant of L1Software that corresponds to the one found on the SW_NODE object.
    ...  The L1SOC trigger will be performed 3 times.
    ...  Alarm of SoC autonomous reset as recovery action should appear after each fault trigger.
    ...  After that, the BBMOD reset will be performed and the SBTS should be fully on-air at the end.
    ...  The RMOD should not reset, meaning the uptime must be less than 10 minutes.
    ...  On the 4th time iteration, the crash is triggered and
    ...  the alarm of Baseband card autonomous reset as recovery action should appear.
    ...  Following this, the BBMOD reset will be performed again, ensuring that the SBTS is fully operational.
    ...  The RMOD should still not reset, maintaining an uptime less than 10 minutes.
    ...  At the end of the test, alarms in the range 4241-4247 should be checked in the RawAlarmHistory file.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  600  # Timeout for SBTS to become on-air


*** Keywords ***
TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28079
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  05.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28616 - Initial TAT creation
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  31.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29666 - Test fails at fault signature check
    ...  11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29271 - Check uptime for all RMODs connected to selected BBMOD
    ...  13.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30388 - Update extra info to work for NR and LTE
    ...  30.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30656 - Add 1815 fault check
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010846-SR-D

    Step0: Set Test Preconditions
    Step1: Activate feature
    Step2: Trigger L1SOC reset
    Step3: Check If RMOD Is Resetting
    Step4: Trigger L1SOC reset
    Step5: Check If RMOD Is Resetting
    Step6: Trigger L1SOC reset
    Step7: Check If RMOD Is Resetting
    Step8: Trigger L1SOC reset
    Step9: Check If RMOD Is Resetting
    Step10: Check Alarm In RawAlarmHistory


Step0: Set Test Preconditions
    Log  \nStep0: Set test preconditions.  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R2'
    ...  Fail  Active software is ${ENB_BRANCH}. The test is supported on software versions equal to or higher than 25R2.

    Perform Site Reset
    ${cablinks}  Get Parameters For All  cablink
    ${cablink_ecpri_list}  Create List
    FOR  ${cablink}  IN  @{cablinks}
        IF  'eCpri' in '${cablink}[linkSpeed]' or 'Cpri' in '${cablink}[linkSpeed]'
        ...  Append To List  ${cablink_ecpri_list}  ${cablink}
    END
    ${cablink_bbmod_list}  Create List
    FOR  ${cablink}  IN  @{cablink_ecpri_list}
        ${bbmod_parameters}  coam.Get Parameters  ${cablink}[firstEndpointDN]
        ${bbmod_product_name}  Fetch From Left  ${bbmod_parameters}[productName]  ${SPACE}
        IF  '${bbmod_product_name}' in ['ABIP','ABIQ','ABIO','ABIN','ABIL']
        ...  Append To List  ${cablink_bbmod_list}  ${cablink}
    END

    Set BBMOD and CPRI/ECPRI RMOD Connected With 4G/5G Cells  ${cablink_bbmod_list}
    ${ref_object}  coam.Get Parameters  ${BBMOD_R_DN}/POWERGROUP_R-1/REF-1
    ${bbmod_l_dn}  IF  '${BBMOD_PRODUCT_NAME}' in ['ABIP','ABIQ']
    ...  Fetch From Left  ${ref_object}[distName]  /BOARD
    ...  ELSE
    ...  Fetch From Left  ${ref_object}[distName]  /BBU
    Set Test Variable  ${BBMOD_L_DN}  ${bbmod_l_dn}
    ${bbmod_l_parameters}  coam.Get Parameters  ${BBMOD_L_DN}
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_l_parameters}[productCode]
    Set SOC Position Which Has L1 Process

    ${bbmod_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    Set Test Variable  ${BBMOD_POSITION}
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}
    Set Unit Position For Fault Signature  ${BBMOD_R_DN}

    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${TEST_START_TIME}  ${current_date_time_raw}
    Set Test Variable  ${INFO}  failed process:.*l1_application_rt.*
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE_SOC}  SoC
    Set Test Variable  ${SCOPE_BOARD}  Board
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*(NR|LTE):[0-9]+.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Step1: Activate feature
    Log  \nStep1: Activate feature.  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    Change FEATCADM Parameter  actRuResetResiliency  true
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  420
    Log  Feature CB010846-SR-D has been activated successfully.  console=true


Step${index}: Trigger L1SOC reset
    Log  \nStep${index}: Trigger L1SOC reset.  console=true
    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${TIME_ALARM}
    Set RMODS Reset Time That Should Not Reset Before Crash
    Trigger L1SOC Reset On BBMOD
    IF  ${index}==2 or ${index}==4 or ${index}==6
        Verify Alarm To Become Active In WebEM  ${FAULT_2087_SOC_AUTO_RST}
    ELSE IF  ${index}==8
        Verify Alarm To Become Active In WebEM  ${FAULT_2087_BB_AUTO_RST}
        Check Fault 1815 In Case It Will Be Visible  ${BBMOD_R_DN}  L1Software  ${SOC_DN}
    END


Step${index}: Check If RMOD Is Resetting
    Log  \nStep${index}: Check if RMOD is resetting.  console=true
    Check If RMOD Is Resetting
    IF  ${index}==3 or ${index}==5 or ${index}==7
        Log  Check fault signature in alarm.  console=true
        Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
        ...  info=${INFO}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE_SOC}  full_product_name=${PRODUCT_NAME}
        ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ...  core_unit_position=${CORE_UNIT_POSITION}
        Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${time_alarm}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
        ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE_SOC}
        ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ...  core_unit_position=${CORE_UNIT_POSITION}
    ELSE IF  ${index}==9
        Log  Check fault signature in alarm.  console=true
        Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_BB_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
        ...  info=${INFO}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE_BOARD}  full_product_name=${PRODUCT_NAME}
        ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ...  core_unit_position=${CORE_UNIT_POSITION}
        Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_BB_AUTO_RST}[fault_id]  time_from=${time_alarm}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
        ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE_BOARD}
        ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
        ...  core_unit_position=${CORE_UNIT_POSITION}
    END


Step10: Check Alarm In RawAlarmHistory
    Log  \nStep10: Check alarm in RawAlarmHistory.  console=true
    Verify Alarm In RawAlarmHistory File  4801  ${TEST_START_TIME}  alarm_status=active
    ...  additional_fault_name=EFaultId_RadioMplaneConnectionEstablishedAl
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    FOR  ${fault_id}  IN  @{expected_faults_raw}
       ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${TEST_START_TIME}  alarm_status=all
       IF  ${fault_status}
           Fail  Alarm with fault ${fault_id} appeared in RawAlarmHistory file - [NOK]
       ELSE
           Log  Alarm with fault ${fault_id} is not present in RawAlarmHistory file - [OK]  console=true
       END
    END


Set SOC Position Which Has L1 Process
    IF  '${BBMOD_PRODUCT_NAME}' in ['ABIP','ABIQ']
        ${sw_node_l_list}  Query Infomodel  get list ${BBMOD_L_DN}/BOARD_L-1/POWER_GROUP_L-*/SOC_L-*/SW_NODE_L-*
    ELSE
        ${sw_node_l_list}  Query Infomodel  get list ${BBMOD_L_DN}/BBU_L-1/POWER_GROUP_L-*/SOC_L-*/SW_NODE_L-*
    END
    FOR  ${sw_node_obj}  IN  @{sw_node_l_list}
        IF  '${sw_node_obj}[variant]'!='L1Software'  CONTINUE
        Set Test Variable  ${SW_NODE_OBJECT}  ${sw_node_obj}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${SW_NODE_OBJECT}
    IF  ${status}
        Log  SW_NODE object with L1Software variant was found: ${SW_NODE_OBJECT}.  console=true
    ELSE
        Fail  SW_NODE object with L1Software variant was not found. [NOK]
    END
    ${soc_dn}  Fetch From Left  ${SW_NODE_OBJECT}[dist_name]  /SW_NODE_L
    ${soc_position}  Get SOC Position  ${soc_dn}  ${BBMOD_PRODUCT_NAME}
    Set Test Variable  ${SOC_DN}
    Set Test Variable  ${SOC_POSITION}  ${soc_position}


Verify Alarm To Become Active In WebEM
    [Arguments]  ${fault_dict}
    ${fault_params}  Get String With Alarm Parameters  ${fault_dict}
    ${status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_params}  timeout=${ALARM_TIMEOUT}
    IF  ${status}
        Log  Fault 2087 has been detected and is now visible on WebEM.  console=true
    ELSE
        Fail  Fault 2087 has not been detected and is not visible on WebEM. [NOK]
    END


Trigger L1SOC Reset On BBMOD
    Open Connection To Primary Core
    IF  '${STORED_ROLE}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  ${SOC_POSITION}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\~)
    SSHLibrary.Write  ps aux | grep l1_application_rt
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${lines}  Split To Lines  ${command_output}
    @{string}  Split String  ${lines}[0]
    ${pid}  Set Variable  ${string}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections


Check If RMOD Is Resetting
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells
    FOR  ${rmod}  IN  @{RMOD_UPTIMES}
        ${initial_uptime}  Set Variable  ${rmod}[uptime]
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[distName]
        ${after_fault_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
        IF  ${after_fault_uptime} >= ${initial_uptime}
            Log  RMOD(${rmod}) reset was not performed. [OK]  console=true
        ELSE
            Fail  RMOD(${rmod}) reset was performed during BBMOD (${BBMOD_R_DN}) reset. [NOK]
        END
    END


Set BBMOD and CPRI/ECPRI RMOD Connected With 4G/5G Cells
    [Arguments]  ${cablink_bbmod_list}
    ${random_cablink}  Evaluate  random.choice(${cablink_bbmod_list})  random
    ${bbmod_parameters}  coam.Get Parameters  ${random_cablink}[firstEndpointDN]
    ${bbmod_product_name}  Fetch From Left  ${bbmod_parameters}[productName]  ${SPACE}
    Set Test Variable  ${BBMOD_PRODUCT_NAME}  ${bbmod_product_name}
    Set Test Variable  ${BBMOD_R_DN}  ${random_cablink}[firstEndpointDN]
    Set Test Variable  ${RMOD_R_DN}  ${random_cablink}[secondEndpointDN]

    Log  Test will reset bbmod: ${BBMOD_R_DN}  console=true
    Log  Test will check reset on rmod: ${RMOD_R_DN}  console=true

    ${rmods_connected_on_bbmod}  Create List
    FOR  ${cablink_bbmod}  IN  @{cablink_bbmod_list}
        IF  '${cablink_bbmod}[firstEndpointDN]' == '${BBMOD_R_DN}'
            Append To List  ${rmods_connected_on_bbmod}  ${cablink_bbmod}[secondEndpointDN]
        ELSE
            CONTINUE
        END
    END
    ${rmods_connected_on_bbmod}  Remove Duplicates  ${rmods_connected_on_bbmod}
    Set Test Variable  ${RMODS_ON_BBMOD}  ${rmods_connected_on_bbmod}

    ${lte_nr_cells_rmod}  Create List
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_R_DN}
    FOR  ${cell}  IN  @{rmod_cells}
        ${status_cells}  Run Keyword And Return Status  Should Contain Any  ${cell}  LNCEL  NRCEL
        IF  ${status_cells}  Append To List  ${lte_nr_cells_rmod}  ${cell}
    END
    ${status_cells_rmod}  Run Keyword And Return Status  Should Not Be Empty  ${lte_nr_cells_rmod}
    IF  ${status_cells_rmod}
        Log  LTE/NR cells are mapped on RMOD ${RMOD_R_DN}.  console=true
    ELSE
        Fail  There are not LTE/NR cells mapped on RMOD ${RMOD_R_DN}. [NOK]
    END


Set RMODS Reset Time That Should Not Reset Before Crash
    ${rmod_uptimes_list}  Create List
    FOR  ${rmod}  IN  @{RMODS_ON_BBMOD}
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}
        ${uptime}  Get From Dictionary  ${rmod_measurements}  uptime
        ${seconds}  Get From Dictionary  ${uptime}  seconds
        ${rmod_info}  Create Dictionary  distName=${rmod}  uptime=${seconds}
        Append To List  ${rmod_uptimes_list}  ${rmod_info}
    END
    Set Test Variable  ${RMOD_UPTIMES}  ${rmod_uptimes_list}


Deactivate Feature CB010846_SR_D
    Log  Deactivate feature CB010846_SR_D.  console=true
    Change FEATCADM Parameter  actRuResetResiliency  false
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  0
    Log  Feature CB010846-SR-D has been deactivated successfully.  console=true


TC Setup
    Common Test Setup  tc_name=FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled
    Setup Netact


TC Teardown
    Deactivate Feature CB010846_SR_D
    Teardown Netact
    Common Test Teardown
