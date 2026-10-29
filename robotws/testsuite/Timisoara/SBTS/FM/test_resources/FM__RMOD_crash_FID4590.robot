*** Settings ***
Documentation
    ...  Tescase scope is to trigger fault 4590 on radio module and verify recovery.
    ...  For each hardware generation (5.1, 6.1, 6.2, 7.1), the test case will randomly select one RMOD and subsequently trigger a fault on it.
    ...  Site reset is performed and all cells are onAir. actFaultSignature value is changed to true.
    ...  Then the connection to primary core is opened to get information about the given RMOD.
    ...  Following this, fault 4590 is generated one single time by executing kill -11 PID to crash the eventcollector process on radio module.
    ...  Fault signature for crash or failure alarm should be reported one time in WebEM and Netact.
    ...  Fault signature fields for the Fault signature for crash or failure alarm should be populated correctly.
    ...  After the alarm is cleared, all modules and cells should be onAir.
    ...  actFaultSignature value is changed to false and all connections are closed.
    ...  Starting release 26R1 test will also verify feature CB012530-SR-A in case of eCPRI radio modules.
    ...  CB012530-SR-A scope is to enrich Fault 10 with Supplementary alarm information tab,
    ...  and to inform operator about the possible failure reasons of an eCPRI radio unit.
    ...
    ...  SBTS sends updates to NetAct once every 8 seconds and there are cases when Fid 10 is cleared in less than 4
    ...  seconds in WebEM and it is not reported to NetAct.
    ...  In these cases, TC is improved by checking active and clear time for Fid 10 and Ne3sAdapt update timestamps.
    ...  If there is a Ne3sAdapt update timestamp between active and clear times, fid 10 will be checked in NetAct
    ...  historical alarms.
    ...  If fid 10 is active for more than 8 seconds in WebEM, it will be checked in NetAct active alarms.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # [Optional] Radio module serial number.
${STARTUP_TIMEOUT}  1500  # [in seconds] Timeout for SBTS to recover after site reset.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC__FM__RMOD_crash_FID4590
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23692
    ...
    ...  *****************
    ...  History of changes
    ...  *****************
    ...  28.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23692 - Initial TAT creation
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  27.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26027 - Change the selection of RMOD
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  11.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26554 - Update TC to be compatible with another RMOD type
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28027 - Add check for 4241-4247 faults in Raw Alarm History
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28341 - Test fails when checking fault in rawAlarmHistory
    ...  12.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26524 - Enhancement for CB009824
    ...  21.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28360 - Enhancement for eCPRI RMODS - not checking faults 4242-4247
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  01.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28763 - Created radio modules data file and new RMOD connection method
    ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29741 - Update retrieval method of RMOD credentials
    ...  14.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30141 - Enhancement for CB012530-SR-A
    ...  23.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30390 - Updated the testing method to ensure compatibility with more RMODs
    ...  22.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30422 - Check Ne3sAdapt updates for fid 10
    ...  13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30234 - Modify keyword in resource file
    ...  06.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30504 - Enhancement to perform crash on multiple random RUs from different families
    ...  02.04.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30723 - Enhancement to check rfm_gpp field in fault signature
    ...  ******************

    Set Tags  CA-FM  OWNER-delia.nacov@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22  FEATURE-CB007273  FEATURE-CB009824  FEATURE-CB012530-SR-A

    Step0: Set Tested Radio Modules For Test
    Step1: Perform Site Reset And Change ActFaultSignature
    Step2: Trigger Fault On Radio Modules And Verify Faults


Step0: Set Tested Radio Modules For Test
    Log  \nStep0: Set tested radio modules for test.  console=true

    ${is_sn_given}  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_SN}
    IF  ${is_sn_given}
        ${tested_rmods}  Get Tested Rmod With Given Serial Number  ${RMOD_SN}
        ${list_length}  Get Length  ${tested_rmods}
        IF  '${list_length}'=='0'  Fail  Radio module with ${RMOD_SN} not present in configuration.
    ELSE
        ${tested_rmods}  Get Tested Rmods From Each Hardware Generation Available In Configuration
        ${list_length}  Get Length  ${tested_rmods}
        IF  '${list_length}'=='0'  Fail  Configuration does not have radio modules from hardware generation 5.1, 6.1, 6.2 or 7.1.
    END
    Set Test Variable  ${TESTED_RMODS}
    Log  Set test variables for fault signature check.  console=true
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  RFM
    Set Test Variable  ${RFM_GPP}  .*lastFailedServiceClassId=eventcollector.*
    Log  Set test variables for check in RawAlarmHistory.  console=true
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    Set Test Variable  ${EXPECTED_FAULTS_RAW}


Step1: Perform Site Reset And Change ActFaultSignature
    Log  \nStep1: Perform site reset and change actFaultSignature.  console=true

    Perform Site Reset
    Set ActFaultSignature Value  true


Step2: Trigger Fault On Radio Modules And Verify Faults
    Log  \nStep2: Trigger fault on radio modules and verify faults.  console=true

    FOR  ${rmod}  IN  @{TESTED_RMODS}
        Log  \nIteration for ${rmod}[id].  console=true
        Set Variables For Rmod  ${rmod}
        Trigger Fault On RMOD
        Check Fault Signature In WebEM And Netact
        Verify Faults Presence In RawAlarmHistory File
        Compare Fault 4590 Content Between WebEm And Netact
    END


Set Variables For Rmod
    [Arguments]  ${rmod}

    Log  Step2.1: Set Variables For Rmod.  console=true
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Set Test Variable  ${START_TIME_WEBEM}
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}

    ${rmod_l_dn}  Get Logical Object From Runtime Reference  ${rmod}[id]
    ${left_side_string}  Fetch From Left  ${rmod_l_dn}[distName]  /EQM_L
    ${rmod_side}  Fetch From Right  ${left_side_string}  /BTS_L-
    IF  ${rmod_side}==1
        ${rmod_side}  Set Variable  1
    ELSE IF  ${rmod_side}==4
        ${rmod_side}  Set Variable  2
    END
    ${bbmod_l_dn}  Get BBMOD Logical Object From BBMOD Runtime Object Mapped On A Given RMOD  ${rmod}[id]
    ${stored_role}  Get StoredRole From MODULE_L  ${bbmod_l_dn}
    Set Test Variable  ${RMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${RMOD_IP}  ${rmod}[ipAddress]
    Set Test Variable  ${RMOD_SN}  ${rmod}[serialNumber]
    Set Test Variable  ${RMOD_R_DN}  ${rmod}[id]
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_R_DN}
    ${username}  ${password}  Get User And Password For RMOD  ${sw_line}  ${rmod}[productName]
    Set Test Variable  ${RMOD_USERNAME}  ${username}
    Set Test Variable  ${RMOD_PASSWORD}  ${password}
    ${status_ecpri}  Check l3Protocol For Given RMOD Type  ${rmod}[productName]  .*(ecpri|eCPRI|ECPRI).*
    Set Test Variable  ${STATUS_ECPRI}  ${status_ecpri}


Trigger Fault On RMOD
    Log  Step2.2: Trigger fault on RMOD.  console=true
    Start Syslog For Checking Ne3sAdapt Updates
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_alarm  admin_api_log_dir=${BTS_FILES}

    ${bts_name}  Get Bts Name
    ${short_dist_name}  Replace String Using Regexp  ${RMOD_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_4590_parameters}  Get String With Alarm Parameters  ${FAULT_4590}
    ${fault_4590_parameters}  Catenate  ${fault_4590_parameters},  notifier="[${bts_name}] ${short_dist_name}"
    ${alarm_web_em}  Run Keyword In Background  Assert alarm active  parameters=${fault_4590_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_alarm
    Sleep  20  # Wait added to RMOD to stabilize after site reset.
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Send Fault 4590

    ${fault_10_dictionary}  Copy Dictionary  ${FAULT_10_CRITICAL}
    Remove From Dictionary  ${fault_10_dictionary}  severity
    ${fid_10_params}  Get String With Alarm Parameters  ${fault_10_dictionary}
    ${transceiver_identifier}  IF  ${STATUS_ECPRI}  Get Sfp Transceiver Identifier For Radio Module  ${RMOD_R_DN}
    ${suppl_alarm_info_text}  Set Variable If  ${STATUS_ECPRI} and '${ENB_BRANCH}'>='SBTS26R1'
    ...  RU connection was lost in runtime.*SFP type is ${transceiver_identifier}.*Protocol is eCPRI.*
    ...  RU connection was lost in runtime
    ${fault_10_with_suppl_alarm_info}  Catenate  ${fid_10_params},  supplAlarmInfo=regex"${suppl_alarm_info_text}",  severity=regex"Major|Critical",
    ...  notifier="[${bts_name}] ${short_dist_name}"
    Assert Alarm Active  parameters=${fault_10_with_suppl_alarm_info}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${fault_10_with_suppl_alarm_info} was active in WebEm. [OK]  console=true

    ${fid_10_is_cleared_in_less_than_8sec}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_10_with_suppl_alarm_info}
    ...  timeout=8
    Sleep  30s  TC wait for additional logs to be saved in syslog.
    Collect Additional Syslog And Restart Default Session

    IF  ${fid_10_is_cleared_in_less_than_8sec}
        ${active_time}  ${clear_time}  Get Active And Clear Time For Specific Fid And Severity  10  critical
        ${fid_10_should_be_checked_in_netact}  Check If Fid Should Be Reported In NetAct Historical Alarms  ${active_time}  ${clear_time}
        IF  ${fid_10_should_be_checked_in_netact}
            ${start_time}  Convert Date  ${clear_time}  datetime
            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
            ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_10_CRITICAL}  time_from=${start_time}
            ...  suppl_info=${suppl_alarm_info_text}  object_id=${short_dist_name}  severity=Critical  additional_severity=Major
            ...  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
            Log  Fault ${fault_10_with_suppl_alarm_info} was reported and cleared from Netact. [OK]  console=true
        END
    ELSE
        Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
        ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  suppl_info=${suppl_alarm_info_text}
        ...  severity=Critical  additional_severity=Major  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]  object_id=${short_dist_name}
        Log  Fault ${fault_10_with_suppl_alarm_info} is reported and active in Netact. [OK]  console=true
    END

    ${check_alarm_webem}  Collect Keyword Result  ${alarm_web_em}  timeout=${ALARM_TIMEOUT}
    IF  ${check_alarm_webem}
        Log  Fault ${fault_4590_parameters} was active in WebEm. [OK]  console=true
    ELSE
        Fail  Fault ${fault_4590_parameters} was not active in WebEm. [NOK]
    END
    Assert Alarm Inactive  parameters=${fault_4590_parameters}  timeout=${ALARM_TIMEOUT}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4590}  time_from=${START_TIME_NETACT}
    ...  additional_fault_id=${FAULT_4590}[fault_id]  object_id=${short_dist_name}
    Log  Fault ${fault_4590_parameters} was reported and cleared in Netact. [OK]  console=true

    [Teardown]  Run Keywords  Run Keyword And Continue On Failure  Teardown Admin  alias=check_alarm
    ...  AND  Run Keyword And Ignore Error  Run  rm -r ${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE


Check Fault Signature In WebEM And Netact
    Log  Step2.3: Check fault signature in WebEM and Netact.  console=true
    Wait Until Keyword Succeeds  120  30  Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  category=${CATEGORY}
    ...  component=${RMOD_SN}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  rfm_gpp=${RFM_GPP}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${START_TIME_NETACT}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  component=COMPONENT:${SPACE}${RMOD_SN}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  rfm_gpp=${RFM_GPP}
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30  Check Modules And Cells
    IF  ${status}
        Log  SBTS is on air, all services are operational. [OK]  console=true
    ELSE
        Fail  Site didn't manage to reach on air state. [NOK]
    END


Verify Faults Presence In RawAlarmHistory File
    Log  Step2.4: Verify Faults Presence In RawAlarmHistory File.  console=true
    IF  ${STATUS_ECPRI}  RETURN
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS_RAW}
        ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME_RAW}
        IF  ${fault_status}  RETURN
    END
    Fail  No fault from ${EXPECTED_FAULTS_RAW} list reported in "RawAlarmHistory" file on current date, after ${CURRENT_DATE_TIME_RAW}. [NOK]


Compare Fault 4590 Content Between WebEm And Netact
    Log  Step2.5: Compare fault 4590 content between WebEm and Netact.  console=true
    Compare Alarms Between WebEM And Netact  ${FAULT_4590}  ${START_TIME_WEBEM}  ${START_TIME_NETACT}


Get Tested Rmods From Each Hardware Generation Available In Configuration
    [Documentation]
    ...  Selects one random RMOD from each hardware generations (5.1, 6.1, 6.2, 7.1) found in configuration.
    ...  Fails if no RMODs from these generations are found.
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${5_1_rmods}  Create List
    ${6_1_rmods}  Create List
    ${6_2_rmods}  Create List
    ${7_1_rmods}  Create List
    ${rmods_list}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_list}
        ${product_name_match}  Get Regexp Matches  ${rmod}[productName]  ^A[A-Z]{3,5}
        ${rmod_status}  Run Keyword And Return Status  Should Not Be Empty  ${product_name_match}
        IF  ${rmod_status}
            ${hw_generation}  Get Hw Generation For RMOD  ${rmod}[productName]
            IF  '${hw_generation}'=='5.1'
                Append To List  ${5_1_rmods}  ${rmod}
            ELSE IF  '${hw_generation}'=='6.1'
                Append To List  ${6_1_rmods}  ${rmod}
            ELSE IF  '${hw_generation}'=='6.2'
                Append To List  ${6_2_rmods}  ${rmod}
            ELSE IF  '${hw_generation}'=='7.1'
                Append To List  ${7_1_rmods}  ${rmod}
            END
        END
    END
    ${tested_rmods}  Create List
    ${tested_rmods}  Append Random Rmod To Tested Rmods  ${5_1_rmods}  ${tested_rmods}
    ${tested_rmods}  Append Random Rmod To Tested Rmods  ${6_1_rmods}  ${tested_rmods}
    ${tested_rmods}  Append Random Rmod To Tested Rmods  ${6_2_rmods}  ${tested_rmods}
    ${tested_rmods}  Append Random Rmod To Tested Rmods  ${7_1_rmods}  ${tested_rmods}

    RETURN  ${tested_rmods}


Append Random Rmod To Tested Rmods
    [Arguments]  ${rmod_list}  ${target_list}

    ${list_length}  Get Length  ${rmod_list}
    IF  ${list_length} > 0
        ${chosen_rmod}  Evaluate  random.choice(${rmod_list})  random
        Append To List  ${target_list}  ${chosen_rmod}
    END

    RETURN  ${target_list}


Get Tested Rmod With Given Serial Number
    [Documentation]
    ...  Returns radio module information that matches the provided serial number.
    ...  If no RMOD is found with the given serial number, the keyword will fail.
    ...  *AUTHOR* laura.craciunel@nokia.com

    [Arguments]  ${serial_number}

    ${rmods_list}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_list}
        IF  '${rmod}[serialNumber]'=='${serial_number}'
            ${tested_rmod}  Create List
            Append To List  ${tested_rmod}  ${rmod}
            RETURN  ${tested_rmod}
        END
    END


Start Syslog For Checking Ne3sAdapt Updates
    Collect All Syslogs
    Sleep  60  TC waits until syslog files are completely filled.
    OperatingSystem.Run  mkdir ${UDP_LOGS}/syslog_before_fid_4590
    ${files}  OperatingSystem.Run  ls -l ${UDP_LOGS} | grep .tar.gz
    ${lines}  Split To Lines  ${files}
    FOR  ${line}  IN  @{lines}
        ${file}  Fetch From Right  ${line}  ${SPACE}
        OperatingSystem.Run  mv ${UDP_LOGS}/${file} ${UDP_LOGS}/syslog_before_fid_4590
    END
    Start Syslog  alias=SYSLOG_NE3SADAPT_UPDATE  log_dir=${UDP_LOGS}  log_name=SYSLOG_NE3SADAPT_UPDATE  ip=192.168.255.126  add_line_number=True


Collect Additional Syslog And Restart Default Session
    syslog.Collect Syslog Results  destination=${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE.tar.gz  unzip=False  alias=SYSLOG_NE3SADAPT_UPDATE
    Start All Syslogs Collection
    OperatingSystem.Run  mkdir ${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE
    OperatingSystem.Run  tar -xf ${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE.tar.gz -C ${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE

    [Teardown]  Run Keyword And Ignore Error  syslog.Stop Syslog  alias=SYSLOG_NE3SADAPT_UPDATE


Get Active And Clear Time For Specific Fid And Severity
    [Arguments]  ${fault_id}  ${severity}

    ${critical_alarms_cleared}  Get Historic Alarms  severity=${severity}
    FOR  ${alarm}  IN  @{critical_alarms_cleared}
        IF  '${alarm}[faultId]'=='${fault_id}'  BREAK
    END
    ${gmt}  Fetch From Left  ${alarm}[btsLastUpdateTimezone]  :
    ${gmt}  Fetch From Right  ${gmt}  +
    ${active_time}  Evaluate  ${alarm}[eventTime]/1000
    ${active_time}  Subtract Time From Date  ${active_time}  ${gmt} hours
    ${active_time}  Convert Date  ${active_time}  epoch

    ${clear_time}  Evaluate  ${alarm}[disappearTime]/1000
    ${clear_time}  Subtract Time From Date  ${clear_time}  ${gmt} hours
    ${clear_time}  Convert Date  ${clear_time}  epoch

    RETURN  ${active_time}  ${clear_time}


Check If Fid Should Be Reported In NetAct Historical Alarms
    [Arguments]  ${active_time}  ${clear_time}

    ${grep_command}  Catenate  grep -F "INF/Ne3sAdapter/Common, [ImRepository] Write InfoModelUpdate to DB"
    ...  ${UDP_LOGS}/SYSLOG_NE3SADAPT_UPDATE/SYSLOG_NE3SADAPT_UPDATE | grep SPECIFIC | tail -n 20
    ${syslog_ne3sadapt_updates}  Run  ${grep_command}
    ${syslog_ne3sadapt_updates}  Split To Lines  ${syslog_ne3sadapt_updates}
    FOR  ${update}  IN  @{syslog_ne3sadapt_updates}
        ${timestamp}  Get Regexp Matches  ${update}  <.+>
        ${ne3sadapt_update_epoch}  Convert Date  ${timestamp}[0]  epoch
        ${diff}  Evaluate  ${ne3sadapt_update_epoch}-${active_time}
        IF  ${diff}>=1  BREAK
    END
    ${diff}  Evaluate  ${clear_time}-${ne3sadapt_update_epoch}
    IF  ${diff}>=1  RETURN  ${TRUE}

    RETURN  ${FALSE}


Send Fault 4590
    SSHLibrary.Write  sudo su
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\$)
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ps -eaf | grep eventcollector
    ${process_info}  SSHLibrary. Read Until Prompt
    ${status}  Run Keyword And Return Status  Should Contain  ${process_info}  invalid option
    IF  ${status}
        SSHLibrary.Write  ps | grep eventcollector
        ${process_info}  SSHLibrary. Read Until Prompt
    END
    ${process_eventcollector}  Get Regexp Matches  ${process_info}  (((\\d+\\s+(root|rfsw))|((root|rfsw)\\s+\\d+))).*libevent_collector
    ${match_ids}  Get Regexp Matches  ${process_eventcollector}[0]  [0-9]+
    ${pid}  Set Variable  ${match_ids}[0]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close All Connections


TC Setup
    Common Test Setup  tc_name=FM__RMOD_crash_FID4590
    Setup Netact


TC Teardown
    SSHLibrary.Close All Connections
    Teardown Netact
    Common Test Teardown
