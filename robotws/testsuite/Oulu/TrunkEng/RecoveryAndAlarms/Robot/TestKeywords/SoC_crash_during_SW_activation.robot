*** Settings ***
Documentation
...   Author:   Essi Passoja/Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface

*** Keywords ***
Crash During SW Activation for all BBMODs
    [Arguments]       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}
    ...               ${GRACEFUL_REBOOT}

    @{UNITS}=                            Get All BBMODs
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR  ${UNIT}  IN  @{UNITS}
        Run Keyword And Continue On Failure  Crash Primary SoC During SW Activation
        ...          ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...          ${GRACEFUL_REBOOT}  ${STEP}
        ${collect}=  Logs Should Be Collected
        Run Keyword If    '${collect}' == '${True}'  Run Keyword and Continue On Failure
        ...               Get Snapshot And Ims Log  info_text=before SW rollback  extra_name=soc_crash_during_swdl
        ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
        Print Step Text                      ${STEP}  Request Rollback Before Testing With Next BBMOD
        Run Keyword And Continue On Failure  Get Active SW Of Bts
        Run Keyword And Continue On Failure  Rollback To Passive SW  timeout=${1200}
        Print Step Text                      ${STEP}  Wait for all cells faulty
        Run Keyword And Continue On Failure  Wait For Cells Faulty  ${WAIT_DISABLED_CELLS}
#   Check Site disconnection & reconnection
        Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
        ...                                  time_to_wait=${300}  level_in_error=warning
        Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection
        ...                                  time_to_wait=${600}  level_in_error=warning
        Run Keyword And Continue On Failure  Check If Admin Connection Available    360
        Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log    extra_name=after_rollback
        Run Keyword And Continue On Failure  Get Active SW Of Bts
    END
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Crash Primary SoC During SW Activation
    [Arguments]    ${UNIT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...            ${GRACEFUL_REBOOT}  ${STEP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    ${affected_cells}=                   Get Cells Of BBMOD  ${UNIT}
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  Make SSH Log
    ${b_t1}                           Get Build That Is Currently Active On BTS  testpackage=T1
    Set Suite Variable                ${BUILD_T1}  ${b_t1}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Request software update to ${BUILD_T1}
    Run Keyword And Continue On Failure  Teardown Suite Admin
    Print Text To Eventlog               Stop Real time alarm listener
    Run Keyword and Continue On Failure  Stop RT Alarm Listener
    Run Keyword and Continue On Failure  Reset Admin Connection
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    ${swdl_start}=                       Get Start Time
    Run Keyword And Continue On Failure  Update Software On Bts  ${BUILD_T1}  timeout=${18000}  admin_connection=log_admin
    Print Text To Eventlog               Software update request done
    Run Keyword and Continue On Failure  Calculate Duration  ${SWDL_START}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Generate fault to tested FSP ${UNIT} before BTS disconnects due to SW update
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Generate Fault To FSP  ${bbmod}  graceful_reboot=${GRACEFUL_REBOOT}
    ...                                  during_startup=${True}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Wait For Cells Faulty  180  cells_to_be_faulty=${affected_cells}  check_only_given_cells=${True}
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=True  time_to_wait=900
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129  time_to_wait=300

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Reset admin connection
    Run Keyword And Continue On Failure  Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure  Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure  Connect Suite Admin
    Print Text To Eventlog               Start Real time alarm listener
    Run Keyword and Continue On Failure  Start RT Alarm Listener

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Collect IMS when cells are disabled, then wait for BTS disconnection
    Run Keyword And Continue On Failure  Get Snapshot And Ims Log    extra_name=before_bts_disconnect

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check That SW Has Been Updated  ${BUILD_T1}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking post conditions

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Check Postconditions, alarms
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Crash Secondary SoC for all BBMODs During SW Activation
    [Arguments]       ${SOC}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}

    @{UNITS}=                            Get All BBMODs
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR  ${UNIT}  IN  @{UNITS}
        Run Keyword And Continue On Failure  Crash Secondary SoC During SW Activation
        ...          ${UNIT}  ${SOC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${STEP}
        ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
        Print Step Text                   ${STEP}  Request Rollback Before Testing With Next BBMOD
        Run Keyword And Continue On Failure  Get Active SW Of Bts
        Run Keyword And Continue On Failure  Rollback To Passive SW  timeout=${1200}
        Print Step Text                      ${STEP}  Wait for all cells faulty
        Run Keyword And Continue On Failure  Wait For Cells Faulty  ${WAIT_DISABLED_CELLS}
#   Check Site disconnection & reconnection
        Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
        ...                                  time_to_wait=${300}  level_in_error=warning
        Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection
        ...                                  time_to_wait=${600}  level_in_error=warning
        Run Keyword And Continue On Failure  Check If Admin Connection Available    360
        Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log    extra_name=after_rollback
        Run Keyword And Continue On Failure  Get Active SW Of Bts
    END
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Crash Secondary SoC During SW Activation
    [Arguments]    ${UNIT}  ${SOC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${STEP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    ${affected_cells}=                   Get Cells Of BBMOD  ${UNIT}
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  Make SSH Log
    ${b_t1}                           Get Build That Is Currently Active On BTS  testpackage=T1
    Set Suite Variable                ${BUILD_T1}  ${b_t1}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Request software update to ${BUILD_T1}
    Run Keyword And Continue On Failure  Teardown Suite Admin
    Print Text To Eventlog               Stop Real time alarm listener
    Run Keyword and Continue On Failure  Stop RT Alarm Listener
    Run Keyword and Continue On Failure  Reset Admin Connection
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    ${swdl_start}=                       Get Start Time
    Run Keyword And Continue On Failure  Update Software On Bts  ${BUILD_T1}  timeout=${18000}  admin_connection=log_admin
    Print Text To Eventlog               Software update request done
    Run Keyword and Continue On Failure  Calculate Duration  ${SWDL_START}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Generate fault to tested FSP ${UNIT} before BTS disconnects due to SW update
    ${bbmod}=                            Get BBMOD Object From User Given Values  ${UNIT}
    Run Keyword And Continue On Failure  Generate Fault To FSP  ${bbmod}  primary=${False}  secondary_soc=${SOC}  during_startup=${True}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Wait For Cells Faulty  180  cells_to_be_faulty=${affected_cells}  check_only_given_cells=${True}
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=True  time_to_wait=900
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129  time_to_wait=300

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Reset admin connection
    Run Keyword And Continue On Failure  Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure  Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure  Connect Suite Admin
    Print Text To Eventlog               Start Real time alarm listener
    Run Keyword and Continue On Failure  Start RT Alarm Listener

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Collect IMS when cells are disabled, then wait for BTS disconnection
    Run Keyword And Continue On Failure  Get Snapshot And Ims Log    extra_name=before_bts_disconnect

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check That SW Has Been Updated  ${BUILD_T1}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking post conditions

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                   ${STEP}  Check Postconditions, alarms
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
