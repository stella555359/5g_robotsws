*** Settings ***
Documentation
    ...  The feature is activated by setting the parameter actRuResetResiliency to true,
    ...  setting the parameter uncntrldResetMplaneBreakTime to true
    ...  and setting the parameter cntrldResetMplaneBreakTime to 420.
    ...  The test should be performed on a randomly selected AHFII RMOD, and the BBMOD it is connected to should have both 4G and 5G RATs mapped.
    ...  The first step of the test is to trigger FID 1956 on the selected AHFII RMOD.
    ...  After this, alarms with fault name 'Radio autonomous reset as recovery action' should appear 3 times.
    ...  Then, alarms with fault name 'Baseband card autonomous reset as recovery action' should appear 2 times.
    ...  An alarm with fault name 'Baseband card power autonomous reset as recovery action' should appear once.
    ...  After this alarm appears, its cleared time should be saved as a test variable to be used later in the test.
    ...  The final alarm in this sequence should be 'Critical BER detected on the optical connection to Radio Module'.
    ...  This alarm should remain active on the RMOD throughout the test duration.
    ...  The next step is to check the uptime of all RMODs. The RMOD on which the crash was triggered should reset,
    ...  but all other AHFII RMODs connected to the same BBMOD should not reset.
    ...  This verification step will be performed after each crash trigger or NR Hard Reset action.
    ...  The next step is to perform an NR Hard Reset to cover the controlled case.
    ...  The uptime of the RMODs will be checked again.
    ...  Next, an L1SOC reset will be triggered on the BBMOD.
    ...  An alarm with fault name 'SoC autonomous reset as recovery action' should appear.
    ...  It is possible that fault 1956 will be resent. A check for this case is implemented.
    ...  After all these steps, the final crash will be an FSP reset.
    ...  The test should wait 1 hour from the last BB Power reset before triggering the FSP reset.
    ...  After the FSP reset, an alarm with fault name 'Baseband card autonomous reset as recovery action' should appear.
    ...  Fault 1956 will also be resent, and the check will be executed accordingly.
    ...  At the end, a recovery action will be performed, and SBTS should return on air.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  # [Mandatory] RMOD product name.
${ALARM_TIMEOUT}  600  # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  900  # Timeout for SBTS to become on-air


*** Keywords ***
TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28751
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  30.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28751 - Initial TAT creation
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  01.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28763 - Created radio modules data file and new RMOD connection method
    ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29741 - Update retrieval method of RMOD credentials
    ...  03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29687 - Fix bbmod selection
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CB010846-SR-I

    Step0: Set Test Preconditions
    Step1: Activate feature
    Step2: Trigger Fault 1956
    Step3: Check If RMOD Is Resetting
    Step4: NR Hard Reset
    Step5: Check If RMOD Is Resetting
    Step6: Trigger L1SOC reset
    Step7: Trigger FSP reset
    Step8: Check If RMOD Is Resetting
    Step9: Check Alarms In RAW Alarms History
    Step10: Recovery Action


Step0: Set Test Preconditions
    Log  \nStep0: Set Test Preconditions  console=true

    IF  '${ENB_BRANCH}' < 'SBTS25R2'
        Fail  Active software is ${ENB_BRANCH}. The test is supported on software versions equal to or higher than 25R2.
    END

    Should Not Be Empty  ${RMOD_TYPE}  The RMOD_TYPE variable is not set correctly. [NOK]

    ${ahfii_rmods_list}  Create List
    ${all_rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{all_rmods}
        IF  '${rmod}[productName]' == '${RMOD_TYPE}'  Append To List  ${ahfii_rmods_list}  ${rmod}
    END
    ${random_rmod}  Evaluate  random.choice(${ahfii_rmods_list})  random
    Set Test Variable  ${RMOD_IP}  ${random_rmod}[ipAddress]
    Set Test Variable  ${RMOD_DN}  ${random_rmod}[id]
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${username}  ${password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_USERNAME}  ${username}
    Set Test Variable  ${RMOD_PASSWORD}  ${password}
    Remove Values From List  ${ahfii_rmods_list}  ${random_rmod}
    Set Test Variable  ${AHFII_RMODS}  ${ahfii_rmods_list}

    ${cablinks}  Get Parameters For All  cablink
    ${cablink_ecpri_list}  Create List
    FOR  ${cablink}  IN  @{cablinks}
        IF  '${RMOD_DN}'=='${cablink}[secondEndpointDN]' and '${cablink}[linkModeSynchronization]' == 'True'
          Set Test Variable  ${BBMOD_R_DN}  ${cablink}[firstEndpointDN]
          BREAK
        END
    END
    ${bbmod_parameters}  coam.Get Parameters  ${BBMOD_R_DN}
    ${bbmod_product_name}  Fetch From Left  ${bbmod_parameters}[productName]  ${SPACE}
    Set Test Variable  ${BBMOD_PRODUCT_NAME}  ${bbmod_product_name}

    ${ref_object}  coam.Get Parameters  ${BBMOD_R_DN}/POWERGROUP_R-1/REF-1
    IF  '${BBMOD_PRODUCT_NAME}' in ['ABIP','ABIQ']
        ${bbmod_l_dn}  Fetch From Left  ${ref_object}[distName]  /BOARD
    ELSE
        ${bbmod_l_dn}  Fetch From Left  ${ref_object}[distName]  /BBU
    END
    Set Test Variable  ${BBMOD_L_DN}  ${bbmod_l_dn}
    ${stored_role}  Get StoredRole From MODULE_L  ${bbmod_l_dn}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}
    ${bts_dn}  Fetch From Left  ${bbmod_l_dn}  /EQM_L
    ${bts_hwapi_domain_id}  coam.Get Parameters  ${bts_dn}  hwapiDomainId
    Set Test Variable  ${RMOD_SIDE}  ${bts_hwapi_domain_id}[hwapiDomainId]

    Set SOC Position Which Has L1 Process On It

    ${bbmod_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    Set Test Variable  ${BBMOD_POSITION}

    Check If 4G/5G Cells Are Mapped On RMOD

    ${affected_cells}  Get Cell Mapping By Module Id  ${RMOD_DN}
    ${unaffected_cells}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${UNAFFECTED_CELLS}  ${unaffected_cells}
    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${TEST_START_TIME}  ${current_date_time_raw}


Step1: Activate feature
    Log  \nStep1: Activate feature  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    Change FEATCADM Parameter  actRuResetResiliency  true
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  420
    Change FEATCADM Parameter  cntrldResetMplaneBreakTime  420
    Log  Feature CB010846-SR-I has been activated successfully.  console=true


Step2: Trigger Fault 1956
    Log  \nStep2: Trigger Fault 1956  console=true
    Set RMODS Reset Time That Should Not Reset Before Crash
    Set RMOD Reset Time That Should Reset Before Crash
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Trigger Fault 1956 On RMOD
    Repeat Keyword  3  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_RADIO_AUTO_RST}
    Repeat Keyword  2  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_AUTO_RST}
    Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_POWER_AUTO_RST}

    ${fault_1956_critical_ber_params}  Get String With Alarm Parameters  ${FAULT_1956_CRITICAL_BER}
    Set Test Variable  ${FAULT_1956_CRITICAL_BER_PARAMS}  ${fault_1956_critical_ber_params}
    Assert Alarm Active  parameters=${FAULT_1956_CRITICAL_BER_PARAMS}  timeout=${ALARM_TIMEOUT}
    Log  Fault 'Critical BER detected on the optical connection to Radio Module' has been detected and is now visible on WebEM.  console=true

    Set Cleared Time For The Last BB Reset Alarm

    ${fault_4714_params}  Get String With Alarm Parameters  ${FAULT_4714}
    ${status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4714_params}  timeout=120
    IF  ${status}
        Log  Fault with fault name "${FAULT_4714}[fault_name]" has been detected and is now visible on WebEM. [OK]  console=true
    ELSE
        Log  Fault with fault name "${FAULT_4714}[fault_name]" has not been detected and is not visible on WebEM. [OK]  console=true
    END

    ${status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_4714_params}  timeout=120
    IF  ${status}
        Log  Fault with fault name "${FAULT_4714}[fault_name]" has been cleared and is not visible on WebEM. [OK]  console=true
    ELSE
        Log  Fault with fault name "${FAULT_4714}[fault_name]" has not been cleared and is visible on WebEM. [NOK]  console=true
    END


Step${index}: Check If RMOD Is Resetting
    Log  \nStep${index}: Check If RMOD Is Resetting  console=true
    Sleep  120s  Waiting to connect on RMOD and obtain the uptime.
    IF  ${index}!=5  Check If RMOD Is Resetting
    Check RMODS To Not Reset


Step4: NR Hard Reset
    Log  \nStep4: NR Hard Reset  console=true
    Set RMODS Reset Time That Should Not Reset Before Crash
    Set RMOD Reset Time That Should Reset Before Crash
    Rat Reset  rat_type=NR  reset_type=Hard  timeout=900
    Log  Check RMOD status to be failed.  console=true
    Assert  RMOD  ${RMOD_DN}  availabilityStatus=${FAILED}  timeout=900
    Wait Until Keyword Succeeds  1200  10  Check If RMOD Is Resetting
    Log  Check unaffected cells to be enabled after NR hard reset.  console=true
    Wait Until Keyword Succeeds  1200  10  Check Unaffected Cells Enabled


Step6: Trigger L1SOC reset
    Log  \nStep6: Trigger L1SOC reset  console=true
    Set RMODS Reset Time That Should Not Reset Before Crash
    Set RMOD Reset Time That Should Reset Before Crash
    Trigger L1SOC Reset On Given BBMOD
    Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_2087_SOC_AUTO_RST}
    Check If Fault 1956 Is Resent

    [Teardown]  SSHLibrary.Close All Connections


Step7: Trigger FSP reset
    Log  \nStep7: Trigger FSP reset  console=true
    Sleep Until 1 Hour Target Is Reached
    Set RMODS Reset Time That Should Not Reset Before Crash
    Set RMOD Reset Time That Should Reset Before Crash
    Trigger FSP Reset On Given BBMOD
    Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_2087_BB_AUTO_RST}
    ${status}  Run Keyword And Return Status  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_RADIO_AUTO_RST}
    IF  ${status}
        Repeat Keyword  2  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_RADIO_AUTO_RST}
        Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_AUTO_RST}
        Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_POWER_AUTO_RST}
        Assert Alarm Active  parameters=${FAULT_1956_CRITICAL_BER_PARAMS}  timeout=${ALARM_TIMEOUT}
        Log  Fault 'Critical BER detected on the optical connection to Radio Module' has been detected and is now visible on WebEM.  console=true
    ELSE
        Log  Fault 1956 was not resent. [OK]  console=true
    END

    [Teardown]  SSHLibrary.Close All Connections


Check If Fault 1956 Is Resent
    ${status}  Run Keyword And Return Status  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_RADIO_AUTO_RST}
    IF  ${status}
        Repeat Keyword  2  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_RADIO_AUTO_RST}
        Repeat Keyword  2  Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_AUTO_RST}
        Verify Alarm To Become Active/Inactive In WebEM  ${FAULT_1956_BB_POWER_AUTO_RST}
        Assert Alarm Active  parameters=${FAULT_1956_CRITICAL_BER_PARAMS}  timeout=${ALARM_TIMEOUT}
        Log  Fault 'Critical BER detected on the optical connection to Radio Module' has been detected and is now visible on WebEM.  console=true
        Set Cleared Time For The Last BB Reset Alarm
    ELSE
        Log  Fault 1956 was not resent. [OK]  console=true
    END


Step9: Check Alarms In RAW Alarms History
    Log  \nStep9: Check Alarms In RAW Alarms History  console=true
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


Step10: Recovery Action
    Log  \nStep10: Recovery Action  console=true
    Perform Recovery Action And Verify Alarm Status


Perform Recovery Action And Verify Alarm Status

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Recovery Action
    Assert Alarm Inactive  parameters=${FAULT_1956_CRITICAL_BER_PARAMS}  timeout=${ALARM_TIMEOUT}
    Log  Fault 'Critical BER detected on the optical connection to Radio Module' has cleared and is no longer visible on WebEM.  console=true


Recovery Action
    SSHLibrary.Write  echo $'/ action create ConfigAccess /CI/ConfigAccess_Module /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo $'/CI/ConfigAccess_Module action delete "book_init_data.bin"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    Log  Reset RMOD with distName ${RMOD_DN}  console=true
    coam.Reset Unit  ${RMOD_DN}  timeout=600
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells


Check Unaffected Cells Enabled
    ${unaffected_cells_status}  Run Keyword And Return Status  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${unaffected_cells_status}
        Log  Unaffected cells are enabled. [OK]  console=true
    ELSE
        Fail  Unaffected cells are not enabled. [NOK]
    END


Set RMODS Reset Time That Should Not Reset Before Crash
    ${list_uptimes}  Create List
    FOR  ${rmod}  IN  @{AHFII_RMODS}
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[id]
        Append To List  ${list_uptimes}  ${rmod_measurements}[uptime][seconds]
        Set Test Variable  ${LIST_UPTIMES}  ${list_uptimes}
    END


Set RMOD Reset Time That Should Reset Before Crash
    ${rmod_measurements}  Get Rmod Measurements By Id  ${RMOD_DN}
    Set Test Variable  ${RMOD_UPTIME_BEFORE_CRASH}  ${rmod_measurements}[uptime][seconds]


Check RMODS To Not Reset
    ${length_list}  Get Length  ${AHFII_RMODS}
    FOR  ${index}  IN RANGE  ${length_list}
        ${rmod}  Set Variable  ${AHFII_RMODS}[${index}]
        ${uptime}  Set Variable  ${LIST_UPTIMES}[${index}]
        ${rmod_measurements}  Get Rmod Measurements By Id  ${rmod}[id]
        ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
        IF  ${rmod_uptime} >= ${uptime}
            Log  RMOD(${rmod}[id]) reset was not performed. [OK]  console=true
            Continue For Loop
        ELSE
            Fail  RMOD(${rmod}[id]) reset was performed during BBMOD (${BBMOD_R_DN}) reset. [NOK]
        END
    END


Set SOC Position Which Has L1 Process On It
    IF  '${BBMOD_PRODUCT_NAME}' in ['ABIP','ABIQ']
        ${sw_node_l_list}  Query Infomodel  get list ${BBMOD_L_DN}/BOARD_L-1/POWER_GROUP_L-*/SOC_L-*/SW_NODE_L-*
    ELSE
        ${sw_node_l_list}  Query Infomodel  get list ${BBMOD_L_DN}/BBU_L-1/POWER_GROUP_L-*/SOC_L-*/SW_NODE_L-*
    END
    FOR  ${sw_node_obj}  IN  @{sw_node_l_list}
        IF  '${sw_node_obj}[variant]'!='L1Software'  Continue For Loop
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
    Set Test Variable  ${SOC_POSITION}  ${soc_position}


Check If 4G/5G Cells Are Mapped On RMOD
    ${lte_nr_cells_rmod}  Create List
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_DN}
    FOR  ${cell}  IN  @{rmod_cells}
        ${status_cells}  Run Keyword And Return Status  Should Contain Any  ${cell}  LNCEL  NRCEL
        IF  ${status_cells}  Append To List  ${lte_nr_cells_rmod}  ${cell}
    END
    ${status_cells_rmod}  Run Keyword And Return Status  Should Not Be Empty  ${lte_nr_cells_rmod}
    IF  ${status_cells_rmod}
        Log  LTE/NR cells are mapped on RMOD ${RMOD_DN}.  console=true
    ELSE
        Fail  There are not LTE/NR cells mapped on RMOD ${RMOD_DN}. [NOK]
    END


Verify Alarm To Become Active/Inactive In WebEM
    [Arguments]  ${fault_dict}
    ${fault_params}  Get String With Alarm Parameters  ${fault_dict}
    ${status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_params}  timeout=${ALARM_TIMEOUT}
    IF  ${status}
        Log  Fault with fault name "${fault_dict}[fault_name]" has been detected and is now visible on WebEM.  console=true
    ELSE
        Fail  Fault with fault name "${fault_dict}[fault_name]" has not been detected and is not visible on WebEM. [NOK]
    END

    ${status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_params}  timeout=${ALARM_TIMEOUT}
    IF  ${status}
        Log  Fault with fault name "${fault_dict}[fault_name]" has cleared and is no longer visible on WebEM.  console=true
    ELSE
        Fail  Fault with fault name "${fault_dict}[fault_name]" has not cleared and is still visible on WebEM. [NOK]
    END


Trigger Fault 1956 On RMOD
    ${second_command}  Catenate  SEPARATOR=  echo $'/CI/ConfigAccess_Module action fetch DECODED "book_init_data.
    ...  bin" "/ram/book_init_data.json"' | frmonShellClient 127.0.0.1 2000
    ${third_command}  Catenate  SEPARATOR=  echo $'/CI/ConfigAccess_Module action store PERMANENT DECODED "book_init_data.
    ...  bin" "/ram/book_init_data.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Write  echo $'/ action create ConfigAccess /CI/ConfigAccess_Module /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${second_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${third_command}
    SSHLibrary.Read Until Prompt
    Log  Reset RMOD with distName ${RMOD_DN}  console=true
    coam.Reset Unit  ${RMOD_DN}  timeout=600


Check If RMOD Is Resetting
    ${rmod_measurements}  Get Rmod Measurements By Id  ${RMOD_DN}
    ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
    IF  ${rmod_uptime} < ${RMOD_UPTIME_BEFORE_CRASH}
        Log  RMOD(${RMOD_DN}) reset was performed.${rmod_uptime},${RMOD_UPTIME_BEFORE_CRASH} [OK]  console=true
    ELSE
        Fail  RMOD(${RMOD_DN}) reset was not performed.${rmod_uptime},${RMOD_UPTIME_BEFORE_CRASH} [NOK]
    END


Set BBMOD and CPRI/ECPRI RMOD Connected With 4G/5G Cells
    [Arguments]  ${cablink_bbmod_list}
    ${random_cablink}  Evaluate  random.choice(${cablink_bbmod_list})  random
    ${bbmod_parameters}  coam.Get Parameters  ${random_cablink}[firstEndpointDN]
    ${bbmod_product_name}  Fetch From Left  ${bbmod_parameters}[productName]  ${SPACE}
    Set Test Variable  ${BBMOD_PRODUCT_NAME}  ${bbmod_product_name}
    Set Test Variable  ${BBMOD_R_DN}  ${random_cablink}[firstEndpointDN]
    Set Test Variable  ${RMOD_DN}  ${random_cablink}[secondEndpointDN]

    Log  Test will reset bbmod: ${BBMOD_R_DN}  console=true
    Log  Test will check reset on rmod: ${RMOD_DN}  console=true

    ${lte_nr_cells_rmod}  Create List
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_DN}
    FOR  ${cell}  IN  @{rmod_cells}
        ${status_cells}  Run Keyword And Return Status  Should Contain Any  ${cell}  LNCEL  NRCEL
        IF  ${status_cells}  Append To List  ${lte_nr_cells_rmod}  ${cell}
    END
    ${status_cells_rmod}  Run Keyword And Return Status  Should Not Be Empty  ${lte_nr_cells_rmod}
    IF  ${status_cells_rmod}
        Log  LTE/NR cells are mapped on RMOD ${RMOD_DN}.  console=true
    ELSE
        Fail  There are not LTE/NR cells mapped on RMOD ${RMOD_DN}. [NOK]
    END


Trigger L1SOC Reset On Given BBMOD
    Open Connection To Primary Core
    IF  '${Idle}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  ${SOC_POSITION}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\~)
    SSHLibrary.Write  ps aux | grep l1_application_rt
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${lines}  Split To Lines  ${command_output}
    @{string}  Split String  ${lines}[0]
    ${pid}  Set Variable  ${string}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt


Trigger FSP Reset On Given BBMOD
    Open Connection To Primary Core
    IF  '${Idle}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  0
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\~)
    SSHLibrary.Write  ps -eaf | grep HWRIcomSExe
    ${command_output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${command_output}  /opt/hwr/HWRIcomSExe
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt


Set Cleared Time For The Last BB Reset Alarm
    ${historical_alarms}  Get Historic Alarms  load_history=true  timeout=60s
    FOR  ${alarm}  IN  @{historical_alarms}
        ${timestamp}  Fetch From Left  ${alarm}[clearedTime]  +
        ${time}  Convert Date  ${timestamp}
        ${status_alarm}  Run Keyword And Return Status  Should Contain  ${alarm}[alarmDetail]  ${FAULT_1956_BB_POWER_AUTO_RST}[fault_name]
        IF  ${status_alarm}
            Set Test Variable  ${CLEARED_TIME_BB_POWER_ALARM}  ${time}
        ELSE
            Continue For Loop
        END
    END


Sleep Until 1 Hour Target Is Reached
    ${current_date}  Get Current Date
    ${timestamp1}  Fetch From Right  ${CLEARED_TIME_BB_POWER_ALARM}  ${SPACE}
    ${timestamp2}  Fetch From Right  ${current_date}  ${SPACE}
    ${time_diff}  Subtract Time From Time  ${timestamp1}  ${timestamp2}  result_format=number
    ${time_hour}  Convert Time  ${time_diff}  verbose
    ${time}  Fetch From Right  ${time_hour}  -${SPACE}
    ${time_final}  Fetch From Left  ${time}  ${SPACE}minutes
    Log  \nTime passed since the previous BB Power alarm: ${time_final}  console=true
    ${time_to_sleep}  Evaluate  62-${time_final}
    Log  Minutes remaining to reach the 1 hour target: ${time_to_sleep} minutes  console=true
    Sleep  ${time_to_sleep}min  Waiting to reach the 1 hour mark before triggering FSP reset crash.


Deactivate Feature CB010846_SR_I
    Log  Deactivate Feature will be performed  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Change FEATCADM Parameter  actRuResetResiliency  false
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  0
    Change FEATCADM Parameter  cntrldResetMplaneBreakTime  0
    Log  Feature CB010846-SR-I has been deactivated successfully.  console=true


TC Setup
    Common Test Setup  tc_name=FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956


TC Teardown
    Deactivate Feature CB010846_SR_I
    Run Keyword If Test Failed  Perform Recovery Action And Verify Alarm Status
    Common Test Teardown
