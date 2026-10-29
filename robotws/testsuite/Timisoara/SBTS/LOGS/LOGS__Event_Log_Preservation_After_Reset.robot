*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***


*** Keywords ***
TC__LOGS__Event_Log_Preservation_After_Reset.robot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12247
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-09-17 - https://jira3.int.net.nokia.com/browse/TAT-12247 - Initial Creation
    ...  - 2018-10-16 - https://jira3.int.net.nokia.com/browse/TAT-12422
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2021-12-23 - TAT-22173 - move states check to resource ca_pm_logs_general
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Simple test case designed to check if EVENT and SYSTEM logs in Info Model are preserved after BTS Site Reset.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Event_Log_Preservation_After_Reset.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CRT    SW-SBTS17

    Step 1: Site Reset
    Step 2: Check EVENT/SYSTEM Logs Presence


Step 1: Site Reset
    Log  \nStep 1: Perform site reset  console=${TRUE}
    ${number_of_event_logs_before_reset}  Check EVENT/SYSTEM Logs Number  EVENT_LOG-1
    ${number_of_system_logs_before_reset}  Check EVENT/SYSTEM Logs Number  SYSTEM_LOG-1
    ${number_of_event_logs_before_reset_dualcore}  Run Keyword If  ${SMOD2_exists}  Check EVENT/SYSTEM Logs Number  EVENT_LOG-4
    ${system_logs_before_reset_dualcore_nr}  Run Keyword If  ${SMOD2_exists}  Check EVENT/SYSTEM Logs Number  SYSTEM_LOG-4
    Set Test Variable  ${number_of_event_logs_before_reset}
    Set Test Variable  ${number_of_system_logs_before_reset}
    Set Test Variable  ${number_of_event_logs_before_reset_dualcore}
    Set Test Variable  ${system_logs_before_reset_dualcore_nr}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes


Step 2: Check EVENT/SYSTEM Logs Presence
    Log  \nStep 2: Check EVENT/SYSTEM logs presence  console=${TRUE}
    ${number_of_event_logs_after_reset}  Check EVENT/SYSTEM Logs Number  EVENT_LOG-1
    ${number_of_system_logs_after_reset}  Check EVENT/SYSTEM Logs Number  SYSTEM_LOG-1

    ${event_logs_after_reset_dualcore_nr}  Run Keyword If  ${SMOD2_exists}  Check EVENT/SYSTEM Logs Number  EVENT_LOG-4
    ${system_logs_after_reset_dualcore_nr}  Run Keyword If  ${SMOD2_exists}  Check EVENT/SYSTEM Logs Number  SYSTEM_LOG-4

    Run Keyword If  ${number_of_event_logs_before_reset}>${number_of_event_logs_after_reset}
    ...  verdicts.Set Test Failed
    ...  EVENT_LOG-1 logs after reset: ${number_of_event_logs_after_reset} is lower than before reset: ${number_of_event_logs_before_reset}.
    ...  ELSE  Run Keywords
    ...  Log  Number of EVENT_LOG-1 logs after reset: ${number_of_event_logs_after_reset}  console=${True}
    ...  AND  Log  is not lower than number of EVENT logs before reset: ${number_of_event_logs_before_reset}  console=${TRUE}

    Run Keyword If  ${number_of_system_logs_before_reset}>${number_of_system_logs_after_reset}
    ...  verdicts.Set Test Failed
    ...  SYSTEM_LOG-1 logs after reset: ${number_of_system_logs_after_reset} is lower than logs before reset: ${number_of_system_logs_before_reset}.
    ...  ELSE  Run Keywords
    ...  Log  Number of SYSTEM_LOG-1 logs after reset: ${number_of_system_logs_after_reset}  console=${TRUE}
    ...  AND  Log  is not lower than number of SYSTEM logs before reset: ${number_of_system_logs_before_reset}  console=${TRUE}

    Run Keyword If  ${SMOD2_exists}
    ...  Check EVENT/SYSTEM Logs for Dual Core  ${event_logs_after_reset_dualcore_nr}  ${system_logs_after_reset_dualcore_nr}

Check EVENT/SYSTEM Logs for Dual Core
    [Arguments]  ${event_logs_after_reset_dualcore_nr}  ${system_logs_after_reset_dualcore_nr}
    Run Keyword If  ${number_of_event_logs_before_reset_dualcore}>${event_logs_after_reset_dualcore_nr}
    ...  verdicts.Set Test Failed
    ...  EVENT_LOG-4 logs after reset: ${event_logs_after_reset_dualcore_nr} is lower than logs before reset: ${event_logs_after_reset_dualcore_nr}.
    ...  ELSE  Run Keywords
    ...  Log  Number of EVENT_LOG-4 logs after reset: ${event_logs_after_reset_dualcore_nr}  console=${TRUE}
    ...  AND  Log  is not lower than number of EVENT_LOG-4 logs before reset: ${number_of_event_logs_before_reset_dualcore}  console=${TRUE}

    Run Keyword If  ${system_logs_before_reset_dualcore_nr}>${system_logs_after_reset_dualcore_nr}
    ...  verdicts.Set Test Failed
    ...  SYSTEM_LOG-4 logs after reset:${system_logs_after_reset_dualcore_nr} is lower than logs before reset:${system_logs_before_reset_dualcore_nr}.
    ...  ELSE  Run Keywords
    ...  Log  Number of SYSTEM_LOG-4 logs after reset: ${system_logs_after_reset_dualcore_nr}  console=${TRUE}
    ...  AND  Log  is not lower than number of SYSTEM_LOG-4 logs before reset: ${system_logs_before_reset_dualcore_nr}  console=${TRUE}

Check EVENT/SYSTEM Logs Number
    [Arguments]  ${input}
    ${event_logs}  Run Keyword And Ignore Error  Query Infomodel  get list /MRBTS-1/RAT-1/${input}/EVENT-*
    ${number_of_event_logs}  Run Keyword If  '${event_logs[0]}'=='PASS'
    ...  Get Length  ${event_logs[1]}
    ...  ELSE  Set Variable  0
    [Return]  ${number_of_event_logs}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
