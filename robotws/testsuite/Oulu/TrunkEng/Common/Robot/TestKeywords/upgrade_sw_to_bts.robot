*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library         testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface

*** Variables ***
${IP_TO_PING}      192.168.255.129

*** Keywords ***
Upgrade Sw To Bts
    [Arguments]    ${BUILD_TO_DOWNLOAD}  ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}
    Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                          1  Check Preconditions
    Run Keyword And Continue On Failure         Common Preconditions
    Print Step Text                          2  Get URL of build to artifactory
    ${SW_BUILD}=                                Get Build From Artifactory  ${BUILD_TO_DOWNLOAD}  save_to_pc=${SAVE_BUILD_TO_PC}
    Print Text To Eventlog                      Stop Real time alarm listener
    Run Keyword and Continue On Failure         Stop RT Alarm Listener
    Run Keyword And Continue On Failure         Stop Background Syslog Print Search
    Print Step Text                          3  Upload sw to bts
    Run Keyword And Continue On Failure         Update Software On Bts  ${SW_BUILD}  timeout=${18000}  admin_connection=log_admin
    Print Step Text                          4  Wait for BTS disconnection and reconnection
    Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}
    ...                                         disconnection=True  time_to_wait=${900}
    Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}
    ...                                         time_to_wait=${900}
    Run Keyword and Continue On Failure         Wait Admin Connection   connect_always=${True}
    Run Keyword and Continue On Failure         Connect Suite Admin
    Print Text To Eventlog                      Start Real time alarm listener
    Print Step Text                          5  Wait for all cells up
    Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                          6  Check that active SW is ${BUILD_TO_DOWNLOAD}
    Run Keyword And Continue On Failure         Check That Sw Has Been Updated    ${BUILD_TO_DOWNLOAD}
    Wait Time And Reason                        ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                          7  Check Postconditions
    Run Keyword And Continue On Failure         Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure         Stop Background Syslog Print Search
    Run Keyword And Continue On Failure         Common Postconditions
