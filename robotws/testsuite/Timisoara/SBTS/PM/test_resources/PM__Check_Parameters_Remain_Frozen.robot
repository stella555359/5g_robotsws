*** Settings ***
Documentation
...  This TC checks if following parameters remain frozen.
...  1. berMajorAlarmThreshold shall be set to a value '-12'.
...  2. preventCellActivation shall be set to value 'false'.
...  3. txPathFailureMode shall be set to value 'keepCellInService'.
...  4. planFileActivationMode shall be set to value 'totalServiceLossAllowed'.
...  5. enableAutoLock shall be set to value 'Enabled'.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__Check_Parameters_Remain_Frozen
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28922
    ...
    ...  *******************
    ...  History of changes
    ...  - 02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28922 - Initial TC creation

    Set Tags  CA-PM  OWNER-mihai-adrian.pirjol@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB014041

    Step0: TC Preconditions
    Step1: Check Parameters Remain Frozen


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true
    ${LTE_CELLS_IDS}  Create List
    Set Test Variable  ${LTE_CELLS_IDS}
    ${cells_dn}  Admin Get IDs For All LTE Cells
    FOR  ${cell_dn}  IN  @{cells_dn}
        ${cell_id}  Fetch From Right  ${cell_dn}  -
        Append To List    ${LTE_CELLS_IDS}    ${cell_id}
    END
    ${LNBTS_ID}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${NRBTS_ID}  Admin Get NRBTS ID
    Set Test Variable  ${NRBTS_ID}


Step1: Check Parameters Remain Frozen
    Log  \nStep1: Check Parameters Remain Frozen  console=true
    Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/EQM-1/APEQM-1  berMajorAlarmThreshold  -14
    FOR  ${cell_id}  IN  @{LTE_CELLS_IDS}
        Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}  preventCellActivation  true
    END
    Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  txPathFailureMode  disableCell
    Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  txPathFailureMode  disableCell
    Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  planFileActivationMode  noServiceLossAllowed
    Check If Parameter Remains Unchanged  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  enableAutoLock  Disabled


Check If Parameter Remains Unchanged
    [Arguments]  ${dist_name}  ${parameter}  ${value}

    ${status}  Run Keyword And Return Status  Perform Parameter Recommissioning
    ...  dist_name=${dist_name}  parameter=${parameter}  operation=update  value=${value}  timeout=180
    IF  ${status}
        Fail  Parameter:${parameter} on object:${dist_name} can change to value:${value}
    ELSE
        Log  Parameter:${parameter} on object:${dist_name} cannot be changed![OK]  console=true
    END


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
