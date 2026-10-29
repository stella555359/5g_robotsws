*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP


*** Keywords ***
Set ABIO Loki A or B Into Failure State
    [Documentation]  Gives command "bmutool -s <slot> -r 0x10 0xA0" for LOKI#A and "bmutool -s <slot> -r 0x11 0xA0" for LOKI#B.
    ...              Slot 1 is for BBMOD1, 2 for BBMOD2, and 3 for BBMOD3. After command, waits for fault to appear and cells of
    ...              LOKI to be disabled.
    ...              NOTE  If you want to remove the fault, you can do it after the test with command "bmutool -s <slot> -r 0x1F 1"
    ...              or with power reset or with remote power reset.
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure  Common Preconditions
    Set Suite Variable    ${BREAK_LOKI}     ${True}
    Set Suite Variable    ${LOKI_TO_BREAK}  ${UNIT}/${SOC}
    Run Keyword And Continue On Failure  Check That Max Allowed FSP Recovery Is Set To Default
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Set Loki Suite Variables  ${bbmod}  ${SOC}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Generate fault to tested FSP ${UNIT} (${bbmod.name}) - ${SOC}
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    ${soc_reason}=                       Get Soc Reason  ${SOC}
    Add Expected Alarm                   alarm_id=7100  fault_id=252  fault_name=Baseband Module Hardware Failure
    ...                                  hw_path=${bbmod.hw_path}  unit_path=${bbmod.unit_path}  reason=${soc_reason}
    Run Keyword And Continue On Failure  Generate Fault To ABIO Loki AB  ${bbmod.name}  ${SOC}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions, alarms
    Run Keyword And Continue On Failure  Common Postconditions
