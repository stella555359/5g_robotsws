*** Settings ***
Documentation
    ...  Purpose of the test is to test changes introduced by feature CB008880 in case of NR RAT recovery reset.
    ...  In first step, site reset will be performed to clear all recovery reset counters.
    ...  In second step, CPCL software node will be crashed and RAT recovery reset will be checked for NR cells.
    ...  Alarm 7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION will be checked in WebEM and Netact.
    ...  In third and fourth step, CPNB and CPNRT software nodes will be crashed. Recovery action and alarm presence will be checked.
    ...  In fifth step, site reset will be performed to clear all recovery reset counters.
    ...  In last step, CPIF software node will be crashed. Recovery action and alarm presence will be checked.
    ...  TC will also check CB010846 that ensures that CPRI/ECPRI radios will not reset after process crash.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM.
${CELLS_TIMEOUT}  180  # [in seconds] Timeout for cells to be in expected state.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact.
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after RAT reset.
${BREAK_TIME_VALUE}  220  # [in seconds] Value for cntrldResetMplaneBreakTime parameter.

*** Keywords ***
TC__FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-28078
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  09.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28169 - Initial TAT creation
    ...  11.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28358 - Replace multiple tests with only one
    ...  19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28420 - Test fails at setting the variables
    ...  21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28423 - Test fail because "faulty cells" are calculated after physicalId not lcrId
    ...  12.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28438 - Parameter values updated to 180 for all steps
    ...  14.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28614 - Test fails when changing parameter
    ...  23.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28568 - Check process in secondary core
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29334 - Fix alarm appeared in raw alarm history for OBSAI radio.
    ...  27.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30019 - Fixed alarm verification in Raw Alarm History for all RMOD types
    ...  25.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30681 - Fixed alarm verification in Raw Alarm History for 4247 and split correction
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB008880  FEATURE-CB010846

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Crash CPCL Process And Verify Recovery With Parameter cntrldResetMplaneBreakTime Set to ${BREAK_TIME_VALUE}
    Step3: Crash CPNB Process And Verify Recovery With Parameter cntrldResetMplaneBreakTime Set to ${BREAK_TIME_VALUE}
    Step4: Crash CPNRT Process And Verify Recovery With Parameter cntrldResetMplaneBreakTime Set to ${BREAK_TIME_VALUE}
    Step5: Perform Site Reset
    Step6: Crash CPIF Process And Verify Recovery With Parameter cntrldResetMplaneBreakTime Set to ${BREAK_TIME_VALUE}
    Step7: Check Alarms In RAW Alarms History


Step0: Set Parameters
    Log  \nStep0: Set parameters.  console=true
    Change FEATCADM Parameter  actRatResetEnhancement  false
    Change FEATCADM Parameter  actRuResetResiliency  true
    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${TEST_START_TIME}  ${current_date_time_raw}


Step${index}: Perform Site Reset
    Log  \nStep${index}: Perform site reset.  console=true
    Perform Site Reset
    IF  '${index}' == '5'
        Collect All Syslogs
        Start Syslog  alias=test_syslog  log_dir=${TEMP_LOGS_DIR}  log_name=SYSLOG_RAT_RESET  ip=192.168.255.126  ports=@{UDP_PORTS}  file_limit=0
    END


Step${index}: Crash ${name} Process And Verify Recovery With Parameter cntrldResetMplaneBreakTime Set to ${cntrldResetMplaneBreakTime_value}
    Log  \nStep${index}: Crash ${name} process and verify recovery.  console=true
    Set Test Variables For Fault Signature  ${name}
    Change FEATCADM Parameter  cntrldResetMplaneBreakTime  ${cntrldResetMplaneBreakTime_value}
    ${ru_uptime_before_crash}  Get CPRI And ECPRI RMODS Uptime
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Teardown Infomodel
    Log  Connection to infomodel terminated  console=true
    Run Keyword And Continue On Failure  Start Infomodel
    Crash ${name} Process
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_background}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=fault
    ${state}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${nr_cells_status}  Run Keyword And Return Status  Assert Every  NRCEL  ${state}  timeout=${CELLS_TIMEOUT}
    IF  ${nr_cells_status}
        Log  NR cells were failed. [OK]  console=true
    ELSE
        Fail  NR cells were not failed. [NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Check Modules And Cells
    ${fault_status_webem}  Run Keyword And Return Status  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was not reported in WebEM. [NOK]
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=fault
    ${fault_status_netact}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${date_netact}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    IF  ${fault_status_netact}
        Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] - ${FAULT_4383_RAT_AUTO_RST}[fault_name] was reported in NetAct. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] - ${FAULT_4383_RAT_AUTO_RST}[fault_name] was not reported in NetAct. [NOK]
    END
    Log  Verify fault signature of fault in WebEM and Netact.  console=true
    Sleep  60s  Wait for alarm to appear in historical alarms
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  filtering_minor_field=${MINOR_ID}  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${date_netact}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR_ID}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    IF  '${index}' == '6'  Check Recovery Reset Counter In Syslog File
    Check CPRI And ECPRI Did Not Reset  ${ru_uptime_before_crash}


Step7: Check Alarms In RAW Alarms History
    Log  \nStep7: Check alarms in raw alarm history.  console=true
    Verify Alarm In RawAlarmHistory File  4801  ${TEST_START_TIME}  alarm_status=active
    ...  additional_fault_name=EFaultId_RadioMplaneConnectionEstablishedAl
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247

    ${obsai_links}  Get Cablinks Available By Provided Protocol  obsai
    ${obsai_sn}  Create List
    FOR  ${link}  IN  @{obsai_links}
        ${radio}  coam.Get Parameters  ${link}[secondEndpointDN]
        Append To List  ${obsai_sn}  ${radio}[serialNumber]
    END

    ${status_4592}  ${faults_4592}  Run Keyword And Ignore Error  Verify Alarm In RawAlarmHistory File  4592  ${TEST_START_TIME}  alarm_status=all
    ${fault_4592_present}  Set Variable If  '${status_4592}' == 'PASS'  ${TRUE}  ${FALSE}
    Log  Fault 4592 present in RawAlarmHistory: ${fault_4592_present}  console=true

    FOR  ${fault_id}  IN  @{expected_faults_raw}
        ${status}  ${faults}  Run keyword And Ignore Error  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${TEST_START_TIME}  alarm_status=all
        IF  '${status}'=='FAIL'
            Log  Alarm with fault ${fault_id} is not present in RawAlarmHistory file - [OK]  console=true
        ELSE IF  '${status}'=='PASS'
            ${faults_str}  Catenate  SEPARATOR=\n  @{faults}
            ${fault_lines}  Split To Lines  ${faults_str}
            FOR  ${fault}  IN  @{fault_lines}
                IF  '${fault_id}' == '4247'
                    IF  ${fault_4592_present}
                        Log  Alarm with fault 4247 appeared in RawAlarmHistory file - accepted because fault 4592 is present. - [OK]  console=true
                        CONTINUE
                    ELSE
                        Fail  Alarm with fault 4247 appeared in RawAlarmHistory file but fault 4592 is not present. - [NOK]
                    END
                END
                FOR  ${radio_sn}  IN  @{obsai_sn}
                    ${status_sn_obsai}  Run Keyword And Return Status  Should Contain  ${fault}  ${radio_sn}
                    ${status_fault_id_4243}  Run Keyword And Return Status  Should Contain  ${fault}  4243
                    IF  ${status_sn_obsai} and ${status_fault_id_4243}
                        Log  Alarm with fault ${fault_id} appeared in RawAlarmHistory file for OBSAI RMOD with SN ${radio_sn}. - [OK]  console=true
                        BREAK
                    ELSE IF  ${status_sn_obsai} and not(${status_fault_id_4243})
                        Fail  Alarm with fault ${fault_id} appeared in RawAlarmHistory file for OBSAI RMOD with SN ${radio_sn}. - [NOK]
                    ELSE IF  not(${status_sn_obsai})
                        Log  The check should be continued on the next OBSAI RMOD.  console=true
                        CONTINUE
                    ELSE
                        Fail  Alarm with fault ${fault_id} appeared in RawAlarmHistory file. - [NOK]
                    END
                END
            END
        END
    END


Set Test Variables For Fault Signature
    [Arguments]  ${process_name}
    ${cells_string}  Get Matching Lcr Ids String For All RAT Cells  NRCELL
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=NR:${cells_string}
    ${sw_node_l}  Query Infomodel  get object //SW_NODE_L-* is [rat=NR hostname=regex"${process_name}"]
    ${node_id}  Convert To Hex  ${sw_node_l}[nodeId]  prefix=0x
    ${software}  Get Software Info
    ${active_sw}  Get From Dictionary  ${software}  Active SW version
    ${sw_variant}  Fetch From Left  ${active_sw}  _
    ${minor_id}  Set Variable If  '${sw_variant}' < 'SBTS24R3'  ${node_id}  ${node_id}${SPACE}${process_name}
    Set Test Variable  ${MINOR_ID}
    ${smod_l_dn}  Fetch From Left  ${sw_node_l}[dist_name]  /BOARD
    ${smod_l_parameters}  Query Infomodel  get object ${smod_l_dn}
    Set Test Variable  ${PRODUCT_NAME}  ${smod_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_l_parameters}[serialNumber]
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${smod_l_parameters}[serialNumber]]
    Set Unit Position For Fault Signature  ${smod_r}[dist_name]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${SCOPE}  NR RAT
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Crash ${name} Process
    Log  Crash ${name} process.  console=true
    Open Connection To Primary Core
    SSHLibrary.Write  ps aux | grep lxc
    ${lxc_processes}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${lxc_processes}  ${name}
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${lines}
    ${lxc_processes}  IF  ${status} == ${FALSE}
    ...  Open Connection To SC And Return Processes
    ...  ELSE
    ...  Set Variable  ${lxc_processes}
    ${lines}  Get Lines Containing String  ${lxc_processes}  ${name}
    ${root}  Get Regexp Matches  ${lines}  root *[0-9]*
    ${process_id}  Evaluate  random.choice(${root})  random
    ${id}  Get Regexp Matches  ${process_id}  [0-9]+
    SSHLibrary.Write  kill -9 ${id}[0]
    SSHLibrary.Read Until Prompt


Open Connection To SC And Return Processes
    Open Connection To Secondary Core
    SSHLibrary.Write  ps aux | grep lxc
    ${lxc_processes}  SSHLibrary.Read Until Prompt

    RETURN  ${lxc_processes}


Check Recovery Reset Counter In Syslog File
    ${nr_bts}  Query Infomodel  get object //NRBTS_R-*
    ${nr_rat_id}  Fetch From Right  ${nr_bts}[dist_name]  /NRBTS_R-
    ${syslog_collected}  Run Keyword And Return Status
    ...  Collect Syslog Results  alias=test_syslog  destination=${UDP_LOGS}/syslog_rat_reset  unzip=true
    IF  ${syslog_collected}
        Log  Syslog file is collected.  console=true
    ELSE
        Fail  Syslog file is not collected.[NOK]
    END
    ${reset_counter_matches}  Grep File  ${UDP_LOGS}/syslog_rat_reset/SYSLOG_RAT_RESET  ResetCounter  encoding_errors=replace
    Should Contain  ${reset_counter_matches}  [ResetCounter #0#] Reset counter for /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${nr_rat_id} is: 0
    ...  msg=Reset counter not found in syslogs.[NOK]
    Log  Reset counter found in syslogs.  console=true


TC Setup
    Common Test Setup  tc_name=FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Site Reset
    Change FEATCADM Parameter  actRatResetEnhancement  true
    Teardown NetAct
    Common Test Teardown
