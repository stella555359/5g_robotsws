*** Settings ***
Documentation
    ...    Test Case: OAMKPI - Maximum Supported Number of Alarms on vDU
    ...    Purpose: This test verifies the vDU ability to handle the required number
    ...    of active alarms according to the KPI criteria. It ensures that the system
    ...    can reach and maintain the alarm count equal to or exceeding the KPI threshold.
    ...
    ...    Test Steps:
    ...    1. Retrieve the current vDU plan file and extract identifiers (MRBTS_ID, NRBTS_ID).
    ...    2. Verify the current number of active critical alarms on the vDU.
    ...    3. Inject additional alarms to reach the KPI target threshold.
    ...    4. Verify that the total number of active alarms is equal to or greater than
    ...       the defined KPI value.
    ...    5. Remove the injected alarms to restore the system to its initial state.
    ...
    ...    Expected Result:
    ...    - The total number of active alarms on the vDU is greater than or equal
    ...      to the configured KPI threshold.
    ...
    ...    Change History:
    ...        01.08.2025 - Initial creation
    ...    Author: jakub.kokoszka@nokia.com

*** Keywords ***
OAMKPI Capacity Active Alarms vDU
    [Documentation]
    ...    This keyword verifies whether the KPI for active alarm capacity on the vDU
    ...    is achieved. It performs the following actions:
    ...    - Retrieves MRBTS and NRBTS identifiers from the vDU plan.
    ...    - Confirms that initially there are no active critical alarms.
    ...    - Injects alarms until the KPI threshold is reached.
    ...    - Validates that the total number of active alarms meets or exceeds the KPI target.
    ...    - Cleans up by removing all injected alarms after verification.
    ...
    ...    Arguments:
    ...        - ${KPI_vDU_alarm_capacity_target}: The target number of alarms
    ...          required for KPI validation.
    [Timeout]    12h
    [Arguments]    ${KPI_vDU_alarm_capacity_target}

    ${MRBTS_ID}    ${NRBTS_ID}    Get MRBTS and NRBTS IDs    vDU
    Check active critical alarm summary is equal    0    vDU
    Log to console    ${KPI_vDU_alarm_capacity_target} alarms will be injected for KPI validation
    Inject or delete alarms    1    ${KPI_vDU_alarm_capacity_target}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VDU}    49    vDU
    Sleep    15s
    Run Keyword And Continue On Failure
    ...    Check active critical alarm summary is equal    ${KPI_vDU_alarm_capacity_target}    vDU
    Inject or delete alarms    0    ${KPI_vDU_alarm_capacity_target}  ${MRBTS_ID}  ${NRBTS_ID}    ${CRAN_VDU}    49    vDU
    Sleep    15s
    Check active critical alarm summary is equal    0    vDU
