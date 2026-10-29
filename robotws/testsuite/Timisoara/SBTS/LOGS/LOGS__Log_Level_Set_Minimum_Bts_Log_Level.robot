*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/rad_flags.robot
Resource    ../resources/BTS_log_level.robot

*** Variables ***


*** Keywords ***
TC__LOGS__Log_Level_Set_Minimum_Bts_Log_Level
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15673
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2019-04-12 - https://jira3.int.net.nokia.com/browse/TAT-15673 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 15.04.2023 - TAT-25131 - resource imports changed due to repo migration
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if BTS Log Level can be to 'Minimum'. In Step 1 it is checked if BTS Log Level read from WebEM is correct.
    ...  In Step 2 BTS Log Level is set to 'Minimum' and the values of AaSyslog rad parameters are read from AaShell. Test case is passed
    ...  when the value of those parameters is 0x6 ('Minimum' log level)
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Log_Level_Set_Minimum_Bts_Log_Level.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS17

    Step 0: Preconditions
    Step 1: Verify Bts Log Level In WebEM
    Step 2: Change Bts Log Level To Minimum


Step 0: Preconditions
    [Documentation]
    ...  In Step 0 It is checked if BTS Log Level is set to level different than 'Minimum' and change it to 'Normal' if it is.

    Log  \nStep 0: Preconditions  console=${True}
    Log  BTS Log Level must be different than 'Minimum'  console=${True}
    Set Test Variable  &{LOG_LEVEL_MAP}  1=Full  2=Normal  6=Minimum  other=Different than Minimum, Normal or Full
    ${log_level_value}  rad_flags.Read Bts Log Level Value from AaSyslog
    Set Test Variable  ${BASE_LOG_LEVEL_VALUE}  ${log_level_value}
    Log  BTS Log Level is set to ${LOG_LEVEL_MAP['${log_level_value}']}  console=${True}

    Run Keyword If  '${log_level_value}'=='6'  Run Keywords
    ...  Log  BTS Log Level will be changed to 'Normal'  console=${True}
    ...  AND  BTS_log_level.WebEM Login
    ...  AND  BTS_log_level.Go To BTS Log Level View
    ...  AND  BTS_log_level.Change Bts Log Level  2
    ...  AND  Close Browser

Step 1: Verify Bts Log Level In WebEM
    [Documentation]
    ...  In Step 1 It is checked current BTS Log Level is correctly displayed in WebEM.

    Log  \nStep 1: Verify Bts Log Level In WebEM  console=${True}
    ${log_level_value}  rad_flags.Read Bts Log Level Value from AaSyslog
    BTS_log_level.WebEM Login
    BTS_log_level.Go To BTS Log Level View
    ${WebEM_log_level_is_correct}  BTS_log_level.Check If BTS Log Level In WebEM Is Set To  ${log_level_value}
    Run Keyword If  ${WebEM_log_level_is_correct}
    ...  Log  BTS log level read from WebEM is correctly set to: ${LOG_LEVEL_MAP['${log_level_value}']}  console=${True}
    ...  ELSE  FAIL  BTS log level read from WebEM is incorrectly set to: ${LOG_LEVEL_MAP['${log_level_value}']}

Step 2: Change Bts Log Level To Minimum
    [Documentation]
    ...  In Step 2 BTS Log Level is changed to 'Minimum'. It is checked is AaSyslog rad parameters are set to '0x6' ('Minimum' log level)

    Log  \nStep 2: Change Bts Log Level To Minimum  console=${True}
    ${bts_log_level_changed}  BTS_log_level.Change Bts Log Level  6
    Close Browser
    Run Keyword If  ${bts_log_level_changed}
    ...  Log  BTS Log Level successfully changed to 'Minimum'  console=${True}
    ...  ELSE  FAIL  Failes to change BTS Log Level to 'Minimum'

    ${log_level_value}  rad_flags.Read Bts Log Level Value from AaSyslog

    Run Keyword If  '${log_level_value}'=='6'
    ...  Log  The values of AaSysLogInputLevel and AaSysLogOutputLevel rad parameters are correctly set  console=${True}
    ...  ELSE  FAIL  msg=The values of AaSysLogInputLevel and AaSysLogOutputLevel rad parameters are incorrectly set

Custom Test Teardown
    [Documentation]
    ...  BTS Log Level is changed back to the value from preconditions.

    Log  \nCustom Test Teardown  console=${True}
    ${log_level_value}  rad_flags.Read Bts Log Level Value from AaSyslog
    Run Keyword If  ${BASE_LOG_LEVEL_VALUE}!=${log_level_value}  Run Keywords
    ...  Log  BTS Log Level will be changed back to '${LOG_LEVEL_MAP['${BASE_LOG_LEVEL_VALUE}']}'  console=${True}
    ...  AND  BTS_log_level.WebEM Login
    ...  AND  BTS_log_level.Go To BTS Log Level View
    ...  AND  BTS_log_level.Change Bts Log Level  ${BASE_LOG_LEVEL_VALUE}
    ...  AND  Close Browser
    ...  ELSE  Log  BTS Log Level is correctly set to '${LOG_LEVEL_MAP['${BASE_LOG_LEVEL_VALUE}']}'  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown


