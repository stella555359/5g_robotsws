*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Keywords ***
Crash DSP From ABIA
    [Documentation]  This KW causes DSP crash to ABIA, causing alarm 6706.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${UNIT}  ${SOC}
    Print Step Text                   1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values  ${UNIT}
    ${bbmod_unit_path}=                  Get Values From Object  ${BBMOD_OBJ}  unit_path
    ${bbmod_hw_path}=                    Get Values From Object  ${BBMOD_OBJ}  hw_path
    ${bbmod_name}=                       Get Values From Object  ${BBMOD_OBJ}  name
    ${affected_cells}=                   Get Cells Of Bbmod   ${bbmod_name}
    Print Step Text                   2  Crash DSP
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=6706
    ...  fault_name=Baseband card autonomous reset as recovery action / DSP group autonomous reset as recovery action
    ...  unit_path=${bbmod_unit_path}  hw_path=${bbmod_hw_path}
    Generate DSP Crash To ABIA           ${BBMOD_OBJ}  ${SOC}
    Print Step Text                   2  Wait for 6706 alarm
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Print Step Text                   3  Wait for cells to be up
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}  ${affected_cells}
    Print Step Text                   4  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions
