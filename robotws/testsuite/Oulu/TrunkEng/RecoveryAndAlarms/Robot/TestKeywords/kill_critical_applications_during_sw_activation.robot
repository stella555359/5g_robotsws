*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/ssh_commands_kws.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH


*** Keywords ***
Critical application kill during SW activation
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${WAIT_CHECKS}
    ...            ${SYSLOG_LIST}  ${SYSLOG_PRINT}  ${WAIT_DISABLED_CELLS}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                        ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
    Run Keyword                            Check That Max Allowed FSP Recovery Is Set To Default
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure    Check If Fault 4589 Should Be Allowed
# Added because of PR740214, more info in https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-182327
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword And Continue On Failure    Add Fault 7504 As Allowed If 5g

    ${b_t1}                           Get Build That Is Currently Active On BTS  testpackage=T1
    Set Suite Variable                     ${BUILD_T1}  ${b_t1}
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                        ${STEP}  Request software update to ${BUILD_T1}
    Run Keyword And Continue On Failure    Teardown Suite Admin
    Print Text To Eventlog                 Stop Real time alarm listener
    Run Keyword and Continue On Failure    Stop RT Alarm Listener
    Run Keyword and Continue On Failure    Reset Admin Connections
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    ${swdl_start}=                    Get Start Time
    Run Keyword And Continue On Failure    Update Software On Bts  ${BUILD_T1}  timeout=${18000}  admin_connection=log_admin
    Print Text To Eventlog                 Software update request done
    Run Keyword and Continue On Failure    Calculate Duration  ${SWDL_START}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure    Ssh to bts and kill application    ${APPLICATION}    2
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                    disconnection=True  time_to_wait=900
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    ip_to_ping=192.168.255.129  time_to_wait=300

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                        ${STEP}  Reset admin connection
    Run Keyword And Continue On Failure    Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure    Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure    Connect Suite Admin
    Print Text To Eventlog                 Start Real time alarm listener
    Run Keyword and Continue On Failure    Start RT Alarm Listener

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                        ${STEP}  Wait for all cells up, then check syslog prints
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Print Step Text                        ${STEP}  Check alarms
    Run Keyword And Continue On Failure    Check Alarm History
    Run Keyword And Continue On Failure    Check If Syslog Print Is Found  ${SYSLOG_PRINT}
    Wait Time And Reason                   ${WAIT_CHECKS}  before checking post conditions

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                        ${STEP}  Check Postconditions and Reset alarms
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    Reset Alarms

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                        ${STEP}  Request Rollback to passive SW
    Run Keyword And Continue On Failure    Get Active SW Of Bts
    Run Keyword And Continue On Failure    Rollback To Passive SW  timeout=${1200}
    Print Step Text                        ${STEP}  Wait for all cells faulty
    Run Keyword And Continue On Failure    Wait For Cells Faulty  ${WAIT_DISABLED_CELLS}
#   Check Site disconnection & reconnection
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    Run Keyword And Continue On Failure    Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Get Snapshot And Ims Log    extra_name=after_rollback
    Run Keyword And Continue On Failure    Get Active SW Of Bts

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                        ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog                 Request site reset
    Run Keyword And Continue On Failure    Reset Site  detailed_output=True
    #   Check Site disconnection & reconnection, reset site will wait for reconnection i not asked otherwise
#    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
#    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    Run Keyword And Continue On Failure    Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                        ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions

# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
   Run Keyword And Continue On Failure     Site reset cleaner    ${WAIT_FOR_CELLS_UP}
    ...              ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${6}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
