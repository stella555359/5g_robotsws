*** Settings ***
Documentation
...  Author:   Sirpa Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/unit_state_check_kws.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/ssh_commands_kws.robot

*** Variables ***
${RESET_TYPE}        Warm

*** Keywords ***
SilentCrash Primary SoC
    [Arguments]   ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}

    ${BBMOD_LIST}=                               Get All Bbmods
    ${STEP}=                                     Check If Step Smaller Or Same As Saved If Is Increase    ${0}

    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                     Get Bbmod Object From User Given Values    ${bbmod}
        Run Keyword And Continue On Failure  SilentCrash Primary SoC During SW Activation
        ...          ${BBMOD_OBJ}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...          ${STEP}
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
        Run Keyword And Continue On Failure  Get Active SW Of Bts
        Run Keyword And Continue On Failure        Remove Expected Alarms
    END

    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


SilentCrash Primary SoC During SW Activation
    [Arguments]    ${BBMOD_OBJ}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...            ${STEP}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    ${CELLS_OF_BBMOD}=                Get Cells Of Bbmod  ${BBMOD_OBJ.name}
    Print Step Text                   ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure  Common Preconditions
    Run Keyword And Continue On Failure  Check That Max Allowed FSP Recovery Is Set To Default
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

    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Add Expected alarm
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm  severity=Warning  alarm_id=7101  fault_id=6706
    ...                                  fault_name=Baseband card autonomous reset as recovery action
    ...                                  unit_path=${BBMOD_OBJ.unit_path}
    ...                                  hw_path=${BBMOD_OBJ.hw_path}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                      ${STEP}  Silent crash for ${BBMOD_OBJ.name}  K2A
    Run Keyword and Continue On Failure  Generate DSP Crash To ABIA  ${BBMOD_OBJ}  K2A
    Print Text To Eventlog  Wait for autonomous reset to occur and that mapped cells of tested BBMOD/K2A are disabled
    Run Keyword And Continue On Failure  Wait For Cells Faulty    time_limit=${WAIT_FOR_CELLS_UP}
    ...                                  cells_to_be_faulty=${CELLS_OF_BBMOD}

    ${STEP}=                          Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                   ${STEP}  Collect IMS when cells are disabled, then wait for BTS disconnection
    Run Keyword And Continue On Failure  Wait For Cells Faulty  180  cells_to_be_faulty=${CELLS_OF_BBMOD}
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
