*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface

*** Variables ***
&{cell_enabled}      operationalState=enabled
&{cell_disabled}     operationalState=disabled
${SNAPSHOT_D}        ${True}
${LOOPING_KW}        ${False}

*** Keywords ***
Crash Application From SMOD During SW Activation
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${WAIT_AFTER_SWDL}  ${WAIT_DISABLED_CELLS}  ${SYSLOG_LIST}
    ...  ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword                          Common Preconditions
    Run Keyword                          Check That Max Allowed FSP Recovery Is Set To Default
    Run Keyword And Continue On Failure  Make SSH Log
    Run Keyword And Continue On Failure  Make BTS SSH Connection
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm  severity=Warning  alarm_id=${ALARM_NBR_SITE_RESET}
    ...                                  fault_id=${FAULT_NBR_SITE_RESET}
    ...                                  fault_name=${FAULT_NAME_SITE_RESET}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}.1  Get pid of ${APPLICATION}
    ${VIRTUAL_NODE_PIDS}=             Get Virtual Pids    CentralCPlane
    ${pid}=                           Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    ${radio_uptimes}=                 Check Rmod Uptimes
    ${b_t1}                           Get Build That Is Currently Active On BTS  testpackage=T1
    Set Suite Variable                   ${BUILD_T1}  ${b_t1}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Request software update to ${BUILD_T1}
    Run Keyword And Continue On Failure  Teardown Suite Admin
    Print Text To Eventlog               Stop Real time alarm listener
    Run Keyword and Continue On Failure  Stop RT Alarm Listener
    Run Keyword and Continue On Failure  Reset Admin Connection
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    ${swdl_start}=                    Get Start Time
    Run Keyword And Continue On Failure  Update Software On Bts  ${BUILD_T1}  timeout=${18000}  admin_connection=log_admin
    Print Text To Eventlog               Software update request done
    Run Keyword and Continue On Failure  Calculate Duration  ${SWDL_START}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text    ${STEP}  Kill application ${APPLICATION} from SMOD before BTS disconnects due to SW update

    Print Step Text    ${STEP}.2  Kill ${APPLICATION} -application and expect Site autonomous reset
    Run Keyword And Continue On Failure  Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure  Close BTS SSH Connection
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  disconnection=True  time_to_wait=900
    Run Keyword And Continue On Failure  Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                  time_to_wait=300

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Reset admin connection
    Run Keyword And Continue On Failure  Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure  Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure  Connect Suite Admin
    Print Text To Eventlog               Start Real time alarm listener
    Run Keyword and Continue On Failure  Start RT Alarm Listener

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Wait for all cells up, then check syslog prints
    Wait Time And Reason                 ${WAIT_AFTER_SWDL}  after SWDL
    Run Keyword And Continue On Failure  Check If Syslog Print Is Found  ${SYSLOG_PRINT}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Check If Rmods Were Reset  ${radio_uptimes}
# Reset alarms after common post conditions check
    Run Keyword And Continue On Failure    Reset Alarms

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Request Rollback to passive SW
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

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Make site reset and wait for all cells up
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  Reset Site  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
