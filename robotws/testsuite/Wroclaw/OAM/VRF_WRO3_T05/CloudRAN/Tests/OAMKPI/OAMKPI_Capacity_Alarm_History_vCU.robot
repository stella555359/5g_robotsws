*** Settings ***
Documentation
    ...    Test Case: OAMKPI Alarm Capacity on vCU
    ...    Purpose: This test case verifies the alarm capacity of the vCU by ensuring
    ...    that the number of historical alarms can reach and exceed the KPI target value.
    ...
    ...    Test Steps:
    ...    1. Retrieve the current vCU plan file and extract identifiers (MRBTS_ID, NRBTS_ID).
    ...    2. Get the current number of historical alarms on the vCU.
    ...    3. Inject additional alarms to reach the KPI alarm capacity target.
    ...    4. Verify that the total number of alarms meets or exceeds the KPI target.
    ...
    ...    Expected Result:
    ...    - The total number of alarms is greater than or equal to the configured KPI target.
    ...
    ...    History of changes:
    ...        07.08.2025 - Initial creation
    ...    Author: jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Capacity Alarm History vCU
    [Documentation]
    ...    This keyword verifies whether the vCU alarm capacity KPI is achieved.
    ...    It performs the following:
    ...    - Ensures the vCU has enough historical alarms by injecting alarms if necessary.
    ...    - Validates that the total alarms exceed the KPI target.
    ...
    ...    Arguments:
    ...        - ${KPI_vCU_alarm_capacity_target}: Target number of alarms for KPI validation.
    [Timeout]    12h
    [Arguments]    ${KPI_vCU_alarm_capacity_target}

    ${MRBTS_ID}    ${NRBTS_ID}    Get MRBTS and NRBTS IDs    vCU
    ${historical_alarms}=    vcu_admin.get_historical_alarms_summary    connection=${vcu_connection}
    ${total}=    Get From Dictionary    ${historical_alarms}    total
    ${count}=    Evaluate    ${KPI_vCU_alarm_capacity_target} - ${total}
    Log to console  There are ${total} historical alarms, need to inject ${count} to check full capacity = ${KPI_vCU_alarm_capacity_target}
    Inject Alarms on vCU With Full Cleanup    ${count}    ${MRBTS_ID}    ${NRBTS_ID}

    ${historical_alarms}=    vcu_admin.get_historical_alarms_summary    connection=${vcu_connection}
    ${total}=    Get From Dictionary    ${historical_alarms}    total
    Should Be True    ${total} >= ${KPI_vCU_alarm_capacity_target}
    Log to console    Amount of historical alarms on vCU >= KPI target, ${total} >= ${KPI_vCU_alarm_capacity_target}

Inject Alarms on vCU With Full Cleanup
    [Arguments]    ${count}    ${MRBTS_ID}    ${NRBTS_ID}
    ${remaining}=    Set Variable    ${count}
    WHILE    ${remaining} > 0
        ${portion}=    Evaluate    min(${remaining}, 1000)

        Log to console    Injecting ${portion} alarms
        Inject or delete alarms    1    ${portion}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    9001    vCU
        Sleep    15s
        Check active critical alarm summary is equal    ${portion}    vCU

        Log to console    Deleting ${portion} alarms
        Inject or delete alarms    0    ${portion}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VCU}    9001    vCU
        Sleep    15s
        Check active critical alarm summary is equal    0    vCU
        ${remaining}=    Evaluate    ${remaining} - ${portion}
    END
