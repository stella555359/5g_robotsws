*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
# Default value is set to False, if commissioning is causing reset it will be set to True
${COMMISSIONING_TRIGGERED_RESET}    ${False}

*** Keywords ***
Trs Sec Delta commissioning
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${DELTA_FILE_PATH}
    [Documentation]  Delta Configuration Plan Update with user given file
    Print Step Text                    1   Check Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Common Preconditions
    ${IPS_TO_PING}=   Get Ips From Scf     mme=${True}  oms=${False}  sgw=${False}  top=${True}  ntp=${True}
    Print Step Text                    2   Ping ips of mme, top and ntp from smod before delta commissioning
    Run Keyword And Continue On Failure    Ping Ips  ${IPS_TO_PING}
    ${original_scf}=                       Get Path Of Current Scf File
    Run Keyword And Continue On Failure    Print Text To Eventlog   Update information of environment to delta file
    Run Keyword And Continue On Failure    Update Information Of Env To Json
    Print Step Text                    3   Perform delta commissioning
    Run Keyword And Continue On Failure    Recommissioning With Delta File   ${DELTA_FILE_PATH}
#    Run Keyword And Continue On Failure    Wait Time And Reason   ${WAIT_CHECKS}   after delta commissioning...
#    Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Wait Cells Faulty And All Cells Up  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Print Text To Eventlog   Get updated scf file to test logs
    Run Keyword And Continue On Failure    SCF.Get Scf
    ${IPS_TO_PING2}=   Get Ips From Scf    mme=${True}  oms=${False}  sgw=${False}  top=${True}  ntp=${True}
    Print Step Text                    4   Ping ips of mme, top and ntp from smod after delta commissioning
    Run Keyword And Continue On Failure    Ping Ips  ${IPS_TO_PING2}
    Print Step Text                    5   Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions
    ${collect}=                        Logs Should Be Collected
    Run Keyword If    '${collect}' == '${True}'  Run Keyword and Continue On Failure
    ...               Get Snapshot And Ims Log  info_text=after delta commissioning  extra_name=after_delta_commissioning
    Print Step Text                    6   Do cleaner commissioning with original scf and check post conditions
    Run Keyword And Continue On Failure    Perform Commissioning With Scf File  ${original_scf}  create_own_connection=${False}
#    Wait Time And Reason                   sleep_time=${WAIT_CHECKS}  wait_reason=after commissioning before checking post conditions
#    Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Wait Cells Faulty And All Cells Up  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    SCF.Get Scf
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Trs Sec Full Configuration Commissioning
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${CONFIGURATION_FILE_PATH}
    [Documentation]  Full Configuration Commissioning with user given file
    Print Step Text                    1   Check Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Common Preconditions
    ${IPS_TO_PING}=   Get Ips From Scf     mme=${True}  oms=${False}  sgw=${False}  top=${True}  ntp=${True}
    Print Step Text                    2   Ping ips of mme, top and ntp from smod before commissioning
    Run Keyword And Continue On Failure    Ping Ips  ${IPS_TO_PING}
    ${original_scf}=                       Get Path Of Current Scf File
    Run Keyword And Continue On Failure    Print Text To Eventlog   Update information of environment to commissioning file
    Run Keyword And Continue On Failure    Update Ips To Configurationfile
    Run Keyword And Continue On Failure    Replace Bts Id
    Print Step Text                    3   Perform full configuration commissioning
    Run Keyword And Continue On Failure    Perform Commissioning With Scf File  ${CONFIGURATION_FILE_PATH}  create_own_connection=${False}
    Run Keyword And Continue On Failure    Wait Cells Faulty And All Cells Up  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Print Text To Eventlog   Get updated scf file to test logs
    Run Keyword And Continue On Failure    SCF.Get Scf
    Run Keyword And Continue On Failure    Copy File To Folder  ${CONFIGURATION_FILE_PATH}
    ${IPS_TO_PING2}=   Get Ips From Scf    mme=${True}  oms=${False}  sgw=${False}  top=${True}  ntp=${True}
    Print Step Text                    4   Ping ips of mme, top and ntp from smod after commissioning
    Run Keyword And Continue On Failure    Ping Ips  ${IPS_TO_PING2}
    Print Step Text                    5   Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions
    ${collect}=                        Logs Should Be Collected
    Run Keyword If    '${collect}' == '${True}'  Run Keyword and Continue On Failure
    ...               Get Snapshot And Ims Log  info_text=after commissioning  extra_name=after_commissioning
    Print Step Text                    6   Do cleaner commissioning with original scf and check post conditions
    Run Keyword And Continue On Failure    Perform Commissioning With Scf File  ${original_scf}  create_own_connection=${False}
    Run Keyword And Continue On Failure    Wait Cells Faulty And All Cells Up  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    SCF.Get Scf
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
