*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/cli.robot

Documentation
...  TEST NAME:     PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if NRCELLGRP reset via CLI working correctly according to CB006830 feature.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  12.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-374 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI

    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.0 Select Randon NRCELLGRP
    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.1 Enable Feature And Parameters
    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.2 Sending Request For Selected NRCELLGRP
    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.3 Check Cells States

PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.0 Select Randon NRCELLGRP
    [Documentation]  Test step which selecting random NRCELLGRP.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${NRCELLGRP_parameters}=  admin.get managed objects  NRCELLGRP_A
    Set Test Variable  ${NRCELLGRP_parameters}
    ${NRCELLGRP_dn_list}=  Create List
    FOR  ${NRCELLGRP}  IN  @{NRCELLGRP_parameters}
        Append To List  ${NRCELLGRP_dn_list}  ${NRCELLGRP['distName']}
    END
    ${chosen_NRCELLGRP}=  Evaluate  random.choice(${NRCELLGRP_dn_list})  random
    ${NRCELLGRP_ID}=  Evaluate  re.search(r'NRCELLGRP_A-(\\d+)','''${chosen_NRCELLGRP}''').group(1)  re
    Set Test Variable  ${NRCELLGRP_ID}
    Log  NRCELLGRP-${NRCELLGRP_ID} selected for reset  console=${True}

PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.1 Enable Feature And Parameters
    [Documentation]
    ...    1. Check if parameter actCli is set as "true", if not then change it to "true".
    ...    2. Check if parameters related to graceful cell shutdown are set correctly.
    Log to console    \n========================================
    Log  Step: 1 Setting parameters related to CLI and graceful cell shutdown features  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true
    ${NRBTS_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    admin.perform parameter recommissioning  ${NRBTS_DN}  actGrflShdn  update  false  ${SKIP_PARAMETER_RELATION_ERRORS}  timeout=600
    admin.perform parameter recommissioning  ${NRBTS_DN}  shutdownWindow  update  180  ${SKIP_PARAMETER_RELATION_ERRORS}  timeout=600

PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.2 Sending Request For Selected NRCELLGRP
    [Documentation]  This keyword send CLI reset command for selected NRCELLGRP.
    Log to console    \n========================================
    Log  Step: 2 Sending Reset Request For Selected RET Via CLI  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${CLI_param}=  Set Variable  "parameters":{"id":"/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_ID}"
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"reset",${CLI_param},"gracefulCellShutdown":true}}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${command_cli}
    IF  '${requestStatus}' != 'completed'
        Fail  msg=Command sent with status: ${requestStatus}
    ELSE
        Log   Command sent with status: ${requestStatus}  console=${True}
    END
    Wait Until Keyword Succeeds  5min  20s  Check Syslog For Gracefull Shutdown Messages  NR

PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test_Step.3 Check Cells States
    [Documentation]  Check if all cells achieve expected state.
    Log to console    \n========================================
    Log  Step: 3 Check Cells State  console=${True}
    Log to console    ========================================
    Wait Until Keyword Succeeds  10min  15sec  Check If NLWG Cells Are OnAir

PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
