*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Force Tags    RF50

Resource    ./resources/keywords.robot

Suite Setup       Suite Setup Custom
Test Setup        Run Keywords
...               Set Allowed Alarms    AND
...               Common Preconditions
Test Teardown     Common Postconditions
Suite Teardown    GnbLogs.collect_snapshot

*** Test Cases ***
[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
    [Tags]    CIT    CDRT    CRT
    Lock Lane From SFP Via GUI
    Wait Until SFP Status Is Disabled
    Unlock Lane From SFP Via GUI
    Wait Until SFP Status Is Enabled
    Wait Until All Cells Are Operating Correctly

[1][1.0] General_SiSo_Auto_PRACH_Performance_Test
    [Tags]    CRT
    [Setup]    Run Keywords    Set Allowed Alarms    AND
    ...                        Common Preconditions    AND
    ...                        Set Cell Info    AND
    ...                        Reset To Test Dedicated
    Connect To BTS
    Start Uplink Prach Test
    Validate Prach Test Results
    [Teardown]    Run Keywords    Stop Performance Test    AND
    ...                           Exit Test Dedicated    AND
    ...                           Common Postconditions

[1][3.0] General_SiSo_Auto_PUCCH_Performance_Test
    [Tags]    CRT
    [Setup]    Run Keywords    Set Allowed Alarms    AND
    ...                        Common Preconditions    AND
    ...                        Set Cell Info    AND
    ...                        Reset To Test Dedicated
    Connect To BTS
    Start Uplink Pucch Test
    Validate Pucch Test Results
    [Teardown]    Run Keywords    Stop Performance Test    AND
    ...                           Exit Test Dedicated    AND
    ...                           Common Postconditions

[1][1.0] General_SiSo_Auto_PUSCH_Performance_Test
    [Tags]    CRT
    [Setup]    Run Keywords    Set Allowed Alarms    AND
    ...                        Common Preconditions    AND
    ...                        Set Cell Info    AND
    ...                        Reset To Test Dedicated
    Connect To BTS
    Start Uplink Pusch Test
    Validate Pusch Test Results
    [Teardown]    Run Keywords    Stop Performance Test    AND
    ...                           Exit Test Dedicated    AND
    ...                           Common Postconditions
