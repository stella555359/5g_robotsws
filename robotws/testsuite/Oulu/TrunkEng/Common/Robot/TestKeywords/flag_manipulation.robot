*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

*** Keywords ***
Change flag to swconfig
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Print Step Text                        1    Check Preconditions and start syslog monitoring
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                        2    ${TEXT_TO_STEP} ${FLAG_VALUE} to swconfig
    Run Keyword And Continue On Failure    Add And remove Flags With Swconfig   ${FLAG_VALUE}   add_flag=${ADD_FLAG}
    ${RESET_NEEDED}=   Site Reset Is Needed
    Run Keyword If    '${RESET_NEEDED}' == '${True}'   Do Site Reset, Wait Cells Up  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
    Run Keyword If    '${RESET_NEEDED}' == '${False}'   Site Reset Is Not Needed, Skip Steps
    Print Step Text                        5    Check Postconditions and stop syslog monitoring
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions

Add flag without need for reset
    [Arguments]    ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Add Flags Via Telnet    ${FLAG_VALUE}
    Run Keyword And Continue On Failure    Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions

Do Site Reset, Wait Cells Up
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
    Print Step Text                        3    Reset site to activate modified swconfig.txt
    Run Keyword And Continue On Failure    ADMIN.Reset Site    detailed_output=True  timeout=900
    Print Step Text                        4    Wait for all cells up
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Wait Time And Reason  ${WAIT_CHECKS}  before stopping syslog and postconditions checks

Site Reset Is Not Needed, Skip Steps
    Print Text To Eventlog  Because site reset is not needed, steps 3 and 4 are skipped and no need to wait before post conditions check
