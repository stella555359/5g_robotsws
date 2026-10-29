*** Settings ***
Documentation
    ...    Test Case: OAMKPI Alarm Capacity on vDU
    ...    Purpose: This test case verifies the alarm capacity of the vDU by ensuring
    ...    that the number of historical alarms can reach and exceed the KPI target value.
    ...
    ...    Test Steps:
    ...    1. Retrieve the current vDU plan file and extract identifiers (MRBTS_ID, NRBTS_ID).
    ...    2. Get the current number of historical alarms on the vDU.
    ...    3. Inject additional alarms to reach the KPI alarm capacity target.
    ...    4. Verify that the total number of alarms meets or exceeds the KPI target.
    ...
    ...    Expected Result:
    ...    - The total number of alarms is greater than or equal to the configured KPI target.
    ...
    ...    History of changes:
    ...        01.08.2025 - Initial creation
    ...    Author: jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Capacity Alarm History vDU
    [Documentation]
    ...    This keyword verifies whether the vDU alarm capacity KPI is achieved.
    ...    It performs the following:
    ...    - Ensures the vDU has enough historical alarms by injecting alarms if necessary.
    ...    - Validates that the total alarms exceed the KPI target.
    ...
    ...    Arguments:
    ...        - ${KPI_vDU_alarm_capacity_target}: Target number of alarms for KPI validation.
    [Timeout]    12h
    [Arguments]    ${KPI_vDU_alarm_capacity_target}

    ${MRBTS_ID}    ${NRBTS_ID}    Get MRBTS and NRBTS IDs    vDU
    ${historical_alarms}=    vdu_admin.vdu_get_historical_alarms   vdu_connection=${vdu_connection}
    ${total}=    Get From Dictionary    ${historical_alarms}    total
    ${count}=    Evaluate    ${KPI_vDU_alarm_capacity_target} - ${total}
    Log to console  There are ${total} historical alarms, need to inject ${count} to check full capacity = ${KPI_vDU_alarm_capacity_target}

    Inject Alarms on vDU With Full Cleanup    ${count}    ${MRBTS_ID}    ${NRBTS_ID}

    ${historical_alarms}=    vdu_admin.vdu_get_historical_alarms   vdu_connection=${vdu_connection}
    ${total}=    Get From Dictionary    ${historical_alarms}    total
    Should Be True    ${total} >= ${KPI_vDU_alarm_capacity_target}
    Log to console    Amount of historical alarms on vDU >= KPI target, ${total} >= ${KPI_vDU_alarm_capacity_target}

Inject Alarms on vDU With Full Cleanup
    [Arguments]    ${count}    ${MRBTS_ID}    ${NRBTS_ID}
    ${remaining}=    Set Variable    ${count}
    WHILE    ${remaining} > 0
        ${portion}=    Evaluate    min(${remaining}, 100)

        Log to console    Injecting ${portion} alarms
        Inject or delete alarms    1    ${portion}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VDU}    49    vDU
        Sleep    15s
        Check active critical alarm summary is equal    ${portion}    vDU

        Log to console    Deleting ${portion} alarms
        Inject or delete alarms    0    ${portion}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VDU}    49    vDU
        Sleep    15s
        Check active critical alarm summary is equal    0    vDU
        ${remaining}=    Evaluate    ${remaining} - ${portion}
    END
