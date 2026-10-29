*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot
Resource    ../../resources/selenium.robot

Documentation
...  TEST NAME:     ALD.02_ALD_SW_Restart
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if ALD SW reset procedure works correctly according to operator
...  request - via WebEM interface.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  08.01.2020 https://jira3.int.net.nokia.com/browse/TAT-18719
...  17.03.2020 - Test creation
...  16.10.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20342
...  21.10.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20353
...  16.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20641
...  19.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21336
...  17.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21476
...  11.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-5 - migration to TAF
...  18.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-11 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  04.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-142 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  31.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28150 - Fix legal notice for new SBTS interface
...  13.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29801 - Add extra step: Autonomous reset and FID 4592 check
...  05.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30268 - Add syslogs check after site reset
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Keywords ***
ALD.02_ALD_SW_Restart

    ALD.02_ALD_SW_Restart.Test_Step.0 Check If ALDs Are In Configuration
    ALD.02_ALD_SW_Restart.Test_Step.1 ALD Software Reset Via WebEM
    ALD.02_ALD_SW_Restart.Test_Step.2 Checking ALD State After SW Reset
    ALD.02_ALD_SW_Restart.Test_Step.3 Autonomous reset and FID 4592 check

ALD.02_ALD_SW_Restart.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.02_ALD_SW_Restart.Test_Step.1 ALD ${type} Reset Via WebEM
    [Documentation]  ${type} reset for all ALDs via WebEM.
    Log to console    \n========================================
    Log  Step: 1 ALD ${type} reset via WebEM  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    ALD Software Reset Via WebEM  ${ALD_R_ALL}  ${ALD_expected_state_busy}
    Sleep  60
    [Teardown]  Selenium2Library.Close All Browsers

ALD.02_ALD_SW_Restart.Test_Step.2 Checking ALD State After SW Reset
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 2 Checking ALD State After SW Reset  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  4291

ALD.02_ALD_SW_Restart.Test_Step.3 Autonomous reset and FID 4592 check
    [Documentation]  Autonomous reset and FID 4592 check with Supplementary Alarm Information  due to recovery
    Log  Step: 3 Checking ALD State After SW Reset  console=${True}
    Allow Fault In Watchdog  faultID=6450
    Log  Opening connection to primary core.  console=true
    SSHLibrary.Open Connection  192.168.255.129
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\~)
    SSHLibrary.Write  ps aux | grep BTSOMexe
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${lines}  Get Lines Containing String  ${command_output}  SLl
    @{string}  Split String  ${lines}
    ${pid}  Set Variable  ${string}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    IF  '${enb_release}' >= 'SBTS24R3'
    ...  Check Fault 4592 Supplementary Alarm Information  due to recovery
    ${syslog_file}  Set Variable  ${RESULTS}/syslog
    ${syslog_collected}  Run Keyword And Return Status
    ...  Collect Syslog Files
    IF  ${syslog_collected}
      Log  Syslog file is collected.  console=true
    ELSE
      Fail  Syslog file is not collected. [NOK]
    END
    Set Test Variable  ${found_all_messages}  ${TRUE}
    ${missing_messages}  Create List
    ${API_MESSAGES}  Create List  API_RESET_HISTORY_GET_REQ_MSG  API_RESET_HISTORY_GET_RESP_MSG
    ...  API_RESET_HISTORY_FLUSH_REQ_MSG  API_RESET_HISTORY_FLUSH_RESP_MSG
    FOR  ${message}    IN    @{API_MESSAGES}
       ${grep_rc}  Run And Return RC  zcat ${syslog_file}/syslog.tar.gz | tar -xO | grep -qi "${message}"
       IF  ${grep_rc} != 0
         Set Test Variable  ${found_all_messages}  ${FALSE}
         Append To List    ${missing_messages}    ${message}
       END
    END
    IF  ${found_all_messages} == ${TRUE}
      Log  All messages appeared, reset counter of PICASSO FPGA was incremented.  console=true
    ELSE
      Fail  Messages didn't appear: ${missing_messages}
    END

ALD.02_ALD_SW_Restart.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
