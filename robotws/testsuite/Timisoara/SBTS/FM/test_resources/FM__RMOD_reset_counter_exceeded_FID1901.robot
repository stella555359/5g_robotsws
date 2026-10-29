*** Settings ***
Documentation
    ...  Test case will verify that the fault signature fields are populated in the alarm raised
    ...  for fault 1901 on radios release RF 6.1 from Master, Amber and Scorpio families.
    ...  In first step test case precondition will be verified:
    ...  check if configuration has radio module type for test, perform site reset to clear all recovery counters,
    ...  change actFaultSignature parameter to true and set test case variables.
    ...  In second step fault 1901 will be triggered by removing one of the calibration file for tested radio module.
    ...  In third step the presence of fault 1901 will be verified in WebEm and Netact.
    ...  Radio autonomous reset is performed three times and fault 1901 is raised with warning severity each time.
    ...  After three consecutive 1901 faults, fault is raised once again with critical severity.
    ...  Fault signature fields will be checked in alarms raised in WebEM and Netact.
    ...  In fourth step fault 1901 will be cleared by restoring calibration file of tested radio module and rebooting unit.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # [Optional] Radio Module serial number for test.
@{SUPPORTED_RMOD_TYPE}  AEQE  AENB  AZQJ  AZQU  # Supported RMOD types for test. RF 6.1 from Master, Amber and Scorpio families.
${STARTUP_TIMEOUT}  660  # Timeout for SBTS recovery after site reset.
${ALARM_TIMEOUT}  1200  # Timeout for critical alarm reporting in WebEM.
${NETACT_TIMEOUT}  120  # Timeout for fault reporting in Netact.


*** Keywords ***
TC__FM__RMOD_reset_counter_exceeded_FID1901
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23753
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23753 - Initial test case creation
    ...  - 09.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24064 - TC fails because connection to RF is not successful
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24109 - Give correct arguments to keyword
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  - 26.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25598 - Test fails when checking extra_info field from fault signature
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 13.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28083 - Change RMOD reset method for alarm clearance
    ...  - 30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28027 - Add check for 4241-4247 faults in Raw Alarm History
    ...  - 07.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28197 - Fix file rights with mount command
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28297 - Test fails due to reboot command
    ...  - 07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28341 - Test fails when checking fault in rawAlarmHistory
    ...  - 05.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28377 - Test fails due to hour not matching when check alarm in WebEM and Netact
    ...  - 01.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28763 - Created radio modules data file and new RMOD connection method
    ...  - 22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29741 - Update retrieval method of RMOD credentials
    ...  *******************

    Set Tags  OWNER-mircea.vladulescu@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  CA-FM  PHASE-CRT  SW-SBTS22  FEATURE-CB007273

    Step 1: Test Case Preconditions
    Step 2: Trigger Fault 1901
    Step 3: Verify Fault Presence
    Step 4: Clear Fault 1901
    Step 5: Verify Faults Presence In RawAlarmHistory File


Step 1: Test Case Preconditions
    Log  Step 1: Test case preconditions.  console=true
    Set Radio Module For Test
    Should Not Be Empty  ${RMOD_TYPE}  The RMOD_TYPE variable is not set correctly. [NOK]
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_R_DN}
    ${username}  ${password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_USERNAME}  ${username}
    Set Test Variable  ${RMOD_PASSWORD}  ${password}
    Set Test Variables For Test
    Perform Site Reset
    Set ActFaultSignature Value  true


Step 2: Trigger Fault 1901
    Log  Step 2: Trigger fault 1901.  console=true
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Send fault 1901


Step 3: Verify Fault Presence
    Log  Step 3: Verify fault presence.  console=true
    Verify Alarm Presence In WebEm
    Verify Alarm Presence In Netact
    Verify RMOD Status  ${DISABLED}  ${FAILED}
    Check Fault Signature In WebEM For All Radio Modules  ${FAULT_1901_RADIO_AUTO_RST}[fault_id]  ${FAULT_1901_RADIO_AUTO_RST}[severity]
    ...  ${SERIAL_NUMBERS}  ${RMODS_COUNT}  ${CATEGORY}  ${SCOPE}  ${EXTRA_INFO}  ${SW_VERSION}  ${START_TIME_WEBEM}
    Check Fault Signature In Netact For All Radio Modules  ${FAULT_1901_RADIO_AUTO_RST}[fault_id]  ${SERIAL_NUMBERS}  ${CATEGORY}  ${SCOPE}
    ...  ${EXTRA_INFO}  ${SW_VERSION}  ${START_TIME_NETACT}


Step 4: Clear Fault 1901
    Log  Step 4: Clear fault 1901.  console=true
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Clear fault 1901
    Check Alarms Inactive
    Wait Until Keyword Succeeds  300s  60s
    ...  Verify RMOD Status  ${ENABLED}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check Modules And Cells
    IF  ${status}
        Log  SBTS is onAir state.  console=true
    ELSE
        Fail  SBTS didn't manage to reach on air state.
    END


Step 5: Verify Faults Presence In RawAlarmHistory File
    Log  \nStep 5: Verify Faults Presence In RawAlarmHistory File.  console=true
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS_RAW}
       ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME_RAW}
       IF  ${fault_status}  RETURN
    END
    Fail  No fault from ${EXPECTED_FAULTS_RAW} list reported in "RawAlarmHistory" file on current date, after ${CURRENT_DATE_TIME_RAW}. [NOK]


Set Radio Module For Test
    IF  '${RMOD_SN}' != ''
        ${rmod}  Get Radio Module By Serial Number  ${RMOD_SN}
    ELSE
        ${rmod}  Get Random Radio Module From Configuration
    END
    Log  Selected radio module: ${rmod}[productName] with serial number ${rmod}[serialNumber].  console=true
    Set Test Variable  ${RMOD}
    Set Test Variable  ${RMOD_TYPE}  ${RMOD}[productName]
    Set Test Variable  ${RMOD_R_DN}  ${RMOD}[id]


Get Radio Module By Serial Number
    [Arguments]  ${serial_number}

    ${rmods_config_list}  Get Parameters For All  RMOD
    ${match}  Set Variable  False
    FOR  ${rmod}  IN  @{rmods_config_list}
        ${match}  Run Keyword And Return Status
        ...  Should Be Equal  ${serial_number}  ${rmod}[serialNumber]
        ${radio_module}  Set Variable If  ${match}  ${rmod}
        IF  ${match}  BREAK
    END
    IF  ${match}==${FALSE}  Fail  Wrong serial number provided.

    RETURN  ${radio_module}


Get Random Radio Module From Configuration
    ${rmods_config_list}  Get Parameters For All  RMOD
    ${rmods_matches}  Create List
    FOR  ${rmod}  IN  @{rmods_config_list}
        ${match}  Run Keyword And Return Status
        ...  List Should Contain Value  ${SUPPORTED_RMOD_TYPE}  ${rmod.productName}
        IF  ${match}  Append To List  ${rmods_matches}  ${rmod}
    END
    ${length}  Get Length  ${rmods_matches}
    IF  ${length}
        Log  Suitable radio module for test found in configuration.  console=true
    ELSE
        Fail  No suitable radio module found in configuration.
    END
    ${radio_module}  Evaluate  random.choice(${rmods_matches})  random

    RETURN  ${radio_module}


Set Test Variables For Test
    ${rmod_l}  Query Infomodel  get object //RMOD_L-* is [serialNumber=${RMOD}[serialNumber]]
    ${smod_l}  Query Infomodel  get object ${rmod_l.masterAgentDN}
    ${bts_dist_name}  Fetch From Left  ${smod_l.dist_name}  /EQM_L
    ${bts_l}  Query Infomodel  get object ${bts_dist_name}
    Set Test Variable  ${RMOD_IP}  ${rmod_l.ipAddress}
    Set Test Variable  ${RMOD_SIDE}  ${bts_l}[hwapiDomainId]
    Set Test Variable  ${STORED_ROLE}  ${bts_l}[storedRole]
    Set Test Variable  ${RMODS_COUNT}  1
    ${serial_numbers}  Create List
    Append To List  ${serial_numbers}  ${RMOD}[serialNumber]
    Set Test Variable  ${SERIAL_NUMBERS}  ${serial_numbers}

    Set Test Variable  ${SCOPE}  RFM
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*

    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}
    ${start_time_webem}  Get BTS time in UTC format  %Y%m%d
    Set Test Variable  ${START_TIME_WEBEM}
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    Set Test Variable  ${EXPECTED_FAULTS_RAW}


Send Fault 1901
    Log  Fault will be provoked.  console=true
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Write  sudo mount -o remount rw /mnt/factory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo mv /mnt/factory/configs/unit/calibration_dlpath1.bin /mnt/factory/configs/unit/temp_filename
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    Reset unit  ${RMOD}[id]  timeout=300


Clear Fault 1901
    Log  Fault will be cleared.  console=true
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Write  sudo mount -o remount rw /mnt/factory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo mv /mnt/factory/configs/unit/temp_filename /mnt/factory/configs/unit/calibration_dlpath1.bin
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    Reset unit  ${RMOD}[id]  timeout=300


Verify Alarm Presence In WebEm
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_critical_alarm
    ${alarm_critical_parameters}  Get String With Alarm Parameters  ${FAULT_1901_RF_FILE_NOT_FOUND}
    ${critical_alarm}  Run Keyword In Background  Assert alarm active  parameters=${alarm_critical_parameters}  timeout=${ALARM_TIMEOUT}
    ...  alias=check_critical_alarm
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_warning_alarm
    ${alarm_warning_parameters}  Get String With Alarm Parameters  ${FAULT_1901_RADIO_AUTO_RST}
    ${warning_alarm}  Run Keyword In Background  Assert alarm active  parameters=${alarm_warning_parameters}  timeout=300  alias=check_warning_alarm

    ${check_warning}  Collect Keyword Result  ${warning_alarm}  timeout=300
    IF  ${check_warning}
        Log  Fault ${FAULT_1901_RADIO_AUTO_RST} was raised in WebEM.  console=true
    ELSE
        Fail  Fault ${FAULT_1901_RADIO_AUTO_RST} is not present in WebEM.
    END
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=check_warning_alarm

    ${check_critical}  Collect Keyword Result  ${critical_alarm}  timeout=${ALARM_TIMEOUT}
    IF  ${check_critical}
        Log  Fault ${FAULT_1901_RF_FILE_NOT_FOUND} was raised in WebEM.  console=true
    ELSE
        Fail  Fault ${FAULT_1901_RF_FILE_NOT_FOUND} is not present in WebEM.
    END
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=check_critical_alarm


Verify Alarm Presence In Netact
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na_critical}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1901_RF_FILE_NOT_FOUND}
    ...  additional_fault_id=${FAULT_1901_RF_FILE_NOT_FOUND}[fault_id]
    IF  ${check_fault_na_critical}
        Log  Given alarm and fault fields are correct in NA, alarm is present in NA.  console=true
    ELSE
        Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA.
    END
    ${check_fault_na_warning}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1901_RADIO_AUTO_RST}  time_from=${START_TIME_NETACT}
    ...  additional_fault_id=${FAULT_1901_RADIO_AUTO_RST}[fault_id]
    IF  ${check_fault_na_warning}
        Log  Given alarm and fault fields are correct in NA, alarm is present in NA cleared alarms.  console=true
    ELSE
        Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA cleared alarms.
    END


Check Alarms Inactive
    ${alarm_critical_parameters}  Get String With Alarm Parameters  ${FAULT_1901_RF_FILE_NOT_FOUND}
    ${alarm_warning_parameters}  Get String With Alarm Parameters  ${FAULT_1901_RADIO_AUTO_RST}
    Assert Alarm Inactive  parameters=${alarm_critical_parameters}  timeout=180
    Assert Alarm Inactive  parameters=${alarm_warning_parameters}  timeout=180
    Admin Check Active Alarms Taf


TC Setup
    Common Test Setup  tc_name=FM__RMOD_reset_counter_exceeded_FID1901
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Recover Unit
    ...  Clear fault 1901  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Teardown NetAct
    Common Test Teardown
