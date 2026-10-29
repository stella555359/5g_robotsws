*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/cli.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.05_Admin_CLI_ALDSharing
...  AUTHOR:        antoni.zamorski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if:
...  getALDScanningStatus, startALDScanning and stopALDScanning commands via Admin command line are working.
...  These commands allow the operator to start/stop scanning for shared ALDs and check the scanning status.
...  *****************
...  Pre-conditions
...  *****************
...  actAldSharing flag is set to true, aldAllowedList is configured
...  ******************
...  History of changes
...  ******************
...  06.12.2022 - https://jiradc.ext.net.nokia.com/projects/TAW/issues/TAW-297 - test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
CLI.05_Admin_CLI_ALDSharing

    CLI.05_Admin_CLI_ALDSharing.Test_Step.0 Check If RETs Are In Configuration
    CLI.05_Admin_CLI_ALDSharing.Test_Step.1 Enable CLI Feature
    CLI.05_Admin_CLI_ALDSharing.Test_Step.2 Sending Start Scanning Via CLI And Verify Output
    CLI.05_Admin_CLI_ALDSharing.Test_Step.3 Sending Check Status Via CLI And Verify Output After Start Scanning
    CLI.05_Admin_CLI_ALDSharing.Test_Step.4 Sending Stop Scanning Via CLI And Verify Output
    CLI.05_Admin_CLI_ALDSharing.Test_Step.5 Sending Check Status Via CLI And Verify Output After Stop Scanning
    CLI.05_Admin_CLI_ALDSharing.Test_Step.6 Check ALDs State

CLI.05_Admin_CLI_ALDSharing.Test_Step.0 Check If RETs Are In Configuration
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${num_of_RETs}
    Run Keyword If  ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}

CLI.05_Admin_CLI_ALDSharing.Test_Step.1 Enable CLI Feature
    [Documentation]
    ...    1. Check if parameter actCli is set as "true", if not then change it to "true".
    ...    2. Select random RET.
    Log to console    \n========================================
    Log  Step: 1 Enable CLI Feature  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Set Feature On Expected Value  parameter=actCli  value=true
    ${feature_state}  Set Feature On Expected Value  parameter=actAldSharing  value=true  #since 23R2
    Set Test Variable  ${feature_state}


CLI.05_Admin_CLI_ALDSharing.Test_Step.2 Sending Start Scanning Via CLI And Verify Output
    [Documentation]  This keyword sends startALDScanning and getALDScanningStatus commands.
    Log to console    \n========================================
    Log  Step: 2 Sending Start Scanning Request Via CLI  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"startALDScanning"}}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed' or '${requestMessage}' != 'Succeeded'
    ...  Fail  msg=Start Scanning command sent with status: ${requestStatus} and ${requestMessage}
    ...  ELSE   Log   Check Status command sent with status: ${requestStatus} and result: ${requestMessage}  console=${True}

CLI.05_Admin_CLI_ALDSharing.Test_Step.3 Sending Check Status Via CLI And Verify Output After Start Scanning
    [Documentation]  This keyword sends startALDScanning and getALDScanningStatus commands.
    Log to console    \n========================================
    Log  Step: 3 Sending Check Status Request Via CLI  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"getALDScanningStatus"}}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed' or '${requestMessage}' != 'Ongoing'
    ...  Fail  msg=Check Status command sent with status: ${requestStatus} and ${requestMessage}
    ...  ELSE   Log   Check Status command sent with status: ${requestStatus} and result: ${requestMessage}  console=${True}

CLI.05_Admin_CLI_ALDSharing.Test_Step.4 Sending Stop Scanning Via CLI And Verify Output
    [Documentation]  This keyword sends stopALDScanning and getALDScanningStatus commands.
    Log to console    \n========================================
    Log  Step: 4 Sending Stop Scanning Request Via CLI  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"stopALDScanning"}}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed' or '${requestMessage}' != 'Succeeded'
    ...  Fail  msg=Stop Scanning command sent with status: ${requestStatus} and ${requestMessage}
    ...  ELSE   Log   Check Status command sent with status: ${requestStatus} and result: ${requestMessage}  console=${True}

CLI.05_Admin_CLI_ALDSharing.Test_Step.5 Sending Check Status Via CLI And Verify Output After Stop Scanning
    [Documentation]  This keyword sends startALDScanning and getALDScanningStatus commands.
    Log to console    \n========================================
    Log  Step: 5 Sending Check Status Request Via CLI  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"getALDScanningStatus"}}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed' or '${requestMessage}' != 'Not ongoing'
    ...  Fail  msg=Check Status command sent with status: ${requestStatus} and ${requestMessage}
    ...  ELSE   Log   Check Status command sent with status: ${requestStatus} and result: ${requestMessage}  console=${True}

CLI.05_Admin_CLI_ALDSharing.Test_Step.6 Check ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 6 Check ALDs State  console=${True}
    Log to console    ========================================
    Run Keyword If  '${feature_state}' == 'true'  Set Feature On Expected Value  parameter=actAldSharing  value=true
    ...  ELSE
    ...  Set Feature On Expected Value  parameter=actAldSharing  value=false
    Check ALDs State  ${ALD_expected_states}
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit

CLI.05_Admin_CLI_ALDSharing.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}


