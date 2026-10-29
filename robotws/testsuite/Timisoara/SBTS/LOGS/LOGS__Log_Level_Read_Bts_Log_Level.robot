*** Settings ***
Documentation
    ...    Author: cristinel.sava@nokia.com

Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/rad_flags.robot
Resource    ../resources/BTS_log_level.robot

#*** Variables ***
*** Keywords ***
TC__LOGS__Log_Level_Read_Bts_Log_Level
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15670
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2019-04-12 - https://jira3.int.net.nokia.com/browse/TAT-15670 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if correct BTS Log Level is displayed in WebEM. In Step 1,AaSysLogInputLevel and AaSysLogOutputLevel flag values are read.
    ...  BTS Log Level (Full, Normal, Minimum, different) is set based on those flags and displayed in WebEM (checked in Step 2)
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Log_Level_Read_BTS_Log_Level.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS17

    Step 1: Read AaSysLogLevel Values From AaShell
    Step 2: Verify Bts Log Level In WebEM


Step 1: Read AaSysLogLevel Values From AaShell
    [Documentation]
    ...  In Step 1 rad flag values for AaSysLogInputLevel and AaSysLogOutputLevel are read from AaShell.

    Log  \nStep 1: Read AaSysLogLevel Values From AaShell  console=${TRUE}

    Set Test Variable  &{LOG_LEVEL_MAP}  1=Full  2=Normal  6=Minimum  other=Different than Minimum, Normal or Full

    ${LOG_LEVEL_VALUE}  rad_flags.Read Bts Log Level Value from AaSyslog
    Set Test Variable  ${LOG_LEVEL_VALUE}

Step 2: Verify Bts Log Level In WebEM
    [Documentation]
    ...  In Step 2 it is checked if BTS Log Level read from WebEM is correct. If LOG_LEVEL_VALUE from Step 1 is set to:
    ...  1, then BTS Log Level read from WebEM should be: FULL
    ...  2, then BTS Log Level read from WebEM should be: Normal
    ...  6, then BTS Log Level read from WebEM should be: Minimal
    ...  other, then BTS Log Level read from WebEM should be: Different than Minimum, Normal or Full

    Log  \nStep 2: Verify Bts Log Level In WebEM  console=${TRUE}
    BTS_log_level.WebEM Login
    BTS_log_level.Go To BTS Log Level View
    ${WebEM_log_level_is_correct}  BTS_log_level.Check If BTS Log Level In WebEM Is Set To  ${LOG_LEVEL_VALUE}
    SeleniumLibrary.Close Browser
    Run Keyword If  ${WebEM_log_level_is_correct}
    ...  Log  BTS log level read from WebEM is correctly set to: ${LOG_LEVEL_MAP['${LOG_LEVEL_VALUE}']}  console=${True}
    ...  ELSE  FAIL  BTS log level read from WebEM is incorrectly set to: ${LOG_LEVEL_MAP['${LOG_LEVEL_VALUE}']}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown


