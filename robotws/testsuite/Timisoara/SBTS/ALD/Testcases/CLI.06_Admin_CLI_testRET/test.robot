*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/cli.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.06_Admin_CLI_testRET
...  AUTHOR:        tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if testRET command via Admin command line are working.
...  *****************
...  Pre-conditions
...  *****************
...  1. RET is present on site, physically connected to RMOD, comissioned and detected.
...  2. RMOD to which RET is connected uses one of those Nokia RP1 protocols (OBSAI/CPRI-N/eCPRI.
...  ******************
...  History of changes
...  ******************
...  23.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-501 - test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
CLI.06_Admin_CLI_testRET

    CLI.06_Admin_CLI_testRET.Test_Step.0 Check If RETs Are In Configuration
    CLI.06_Admin_CLI_testRET.Test_Step.1 Enable CLI Feature
    CLI.06_Admin_CLI_testRET.Test_Step.2 Sending testRET Request Via CLI For Selected RET
    CLI.06_Admin_CLI_testRET.Test_Step.3 Sending testRET Request Via CLI For Selected RMOD
    CLI.06_Admin_CLI_testRET.Test_Step.4 Sending testRET Request Via CLI To All RETs
    CLI.06_Admin_CLI_testRET.Test_Step.5 Sending testRET Request Via CLI With Invalid DN
    CLI.06_Admin_CLI_testRET.Test_Step.6 Sending testRET Request Via CLI With Unsupported DN

CLI.06_Admin_CLI_testRET.Test_Step.0 Check If RETs Are In Configuration
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${num_of_RETs}
    IF  ${num_of_RETs}==${0}  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}

CLI.06_Admin_CLI_testRET.Test_Step.1 Enable CLI Feature
    [Documentation]  Check if parameter actCli is set as "true", if not then change it to "true".
    Log to console    \n========================================
    Log  Step: 1 Enable CLI Feature  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true

CLI.06_Admin_CLI_testRET.Test_Step.2 Sending testRET Request Via CLI For Selected RET
    [Documentation]
    ...    1. Select random RET.
    ...    2. Send CLI request with command testRET for selected RET.
    Log to console    \n========================================
    Log  Step: 2 Sending testRET Request Via CLI And Verify Output  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${chosen_RET}=  Select Random RET  ${ALD_R_RETs}
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RET}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    IF  '${requestStatus}' != 'completed'
        Fail     msg=Command sent with status: ${requestStatus}
    ELSE
        Log   Command sent with status: ${requestStatus}  console=${True}
    END

CLI.06_Admin_CLI_testRET.Test_Step.3 Sending testRET Request Via CLI For Selected RMOD
    [Documentation]
    ...    1. Select random RMOD.
    ...    2. Send CLI request with command testRET for selected RMOD.
    Log to console    \n========================================
    Log  Step: 3 Sending testRET Request Via CLI For Selected RMOD  console=${True}
    Log to console    ========================================
    Get RMODs
    ${chosen_RMOD}=  Evaluate  random.choice(${rmods})  random
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_RMOD}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    IF  '${requestStatus}' != 'completed'
        Fail     msg=Command sent with status: ${requestStatus}
    ELSE
        Log   Command sent with status: ${requestStatus}  console=${True}
    END

CLI.06_Admin_CLI_testRET.Test_Step.4 Sending testRET Request Via CLI To All RETs
    [Documentation]  Send command testRET for all RET devices.
    Log to console    \n========================================
    Log  Step: 4 Sending testRET Request Via CLI To All RETs  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"MRBTS-${MRBTS_ID}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    IF  '${requestStatus}' != 'completed'
        Fail     msg=Command sent with status: ${requestStatus}
    ELSE
        Log   Command sent with status: ${requestStatus}  console=${True}
    END

CLI.06_Admin_CLI_testRET.Test_Step.5 Sending testRET Request Via CLI With Invalid DN
    [Documentation]  Send command testRET with invalid DistName object.
    Log to console    \n========================================
    Log  Step: 5 Sending testRET Request Via CLI With Invalid DN  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"MRBTS-999999999999"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    IF  '${requestStatus}' != 'rejected' and '${error_code}' != '70'
        Fail     msg=Command sent with status: ${requestStatus} and errorCode: ${error_code}
    ELSE
        Log   Command sent with status: ${requestStatus} and errorCode: ${error_code}  console=${True}
    END

CLI.06_Admin_CLI_testRET.Test_Step.6 Sending testRET Request Via CLI With Unsupported DN
    [Documentation]  Send command testRET with unsupported DistName object.
    Log to console    \n========================================
    Log  Step: 6 Sending testRET Request Via CLI With Unsupported DN  console=${True}
    Log to console    ========================================
    Get BBMODs
    ${chosen_BBMOD}=  Evaluate  random.choice(${bbmods})  random
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"testRET","parameters":{"targetDN":"${chosen_BBMOD}"}}}
    Log To Console    Generated command CLI: ${command_cli}
    ${requestStatus}  ${requestMessage}  ${error_code}  Send Command CLI And Return Outputs  ${command_cli}
    IF  '${requestStatus}' != 'rejected' and '${error_code}' != '3'
        Fail     msg=Command sent with status: ${requestStatus} and errorCode: ${error_code}
    ELSE
        Log   Command sent with status: ${requestStatus} and errorCode: ${error_code}  console=${True}
    END

CLI.06_Admin_CLI_testRET.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
