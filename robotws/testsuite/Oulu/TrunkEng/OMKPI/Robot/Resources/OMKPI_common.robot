*** Settings ***

Documentation
...   Author:   Test script team
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.BlackBoxChecks
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.SwdlShutdownTime

*** Variables ***
${CONNECTION}            log_admin
${IP_TO_PING}            192.168.255.129
@{FIRMWARE_UPDATE}       ADETMASTER,\s+.OUT.\s+API2_RESET_REQ_MSG.*info.FirmwareActivationColdReset   BW.bin updated
...                      status = 70426 UPDATED
${kpi_method}
${WAIT_BETWEEN_SWDLS}    0
# Values of these are updated
${BUILD_T1}
${BUILD_T2}
${BUILD_N}
${SWDL_FIRST}             1
${SWDL_SECOND}            2
${LMP_OR_S1_TEXT}         Use LMP connection for SWDL
${TIME_KW_SUCCESS}        ${True}
${LOGS_WERE_NEEDED}       ${False}
${DO_SW_PRECHECK}         ${False}
${SW_PRECHECK_TYPE}       FullCheck
${WAIT_AFTER_BG_SWDL}     300

*** Keywords ***

Time KPI results
    [Documentation]     Report KPI results to reporting portal
    [Arguments]         ${KPIS}  ${REFERENCE_TESTLINE}=${EMPTY}

    FOR  ${ELEMENT}  IN  @{KPIS.keys()}
        ${KPI_NAME}         Set Variable   ${ELEMENT}
        ${RESULT}           Set Variable   ${KPIS}[${ELEMENT}]
        Run Keyword and Continue On Failure  Startup.Report Kpi Results
        ...                                  kpi_name=${KPI_NAME}  result=${RESULT}  reference_name=${REFERENCE_TESTLINE}
    END

Report Success Rate
    [Documentation]    Report success rate to reporting portal
    [Arguments]        ${CASE_NAME}  ${RESULT}  ${REFERENCE_TESTLINE}=${EMPTY}

    Run Keyword and Continue On Failure   Startup.Report Kpi Results
    ...                                   time=${False}
    ...                                   case_name=${CASE_NAME}
    ...                                   success=${RESULT}
    ...                                   reference_name=${REFERENCE_TESTLINE}

Reset Time
    [Arguments]     ${REPORT}  ${OAM_KPI_TARGETS}  ${AVG_OAM_KPI_TARGETS}  ${REFERENCE_TESTLINE}

    Run Keyword If  ${REPORT}             Startup.Report KPI Results TAF  ${OAM_KPI_TARGETS}  ${REFERENCE_TESTLINE}
    Run Keyword and Continue On Failure   Startup.Check KPIs TAF  ${OAM_KPI_TARGETS}  ${AVG_OAM_KPI_TARGETS}
    Add KPIs to zip
    Run Keyword And Continue On Failure   Change Kpi Targets Back To Normal
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${TIME_KW_SUCCESS}  ${False}

Update SW And Make Checks
    [Documentation]    Gets active Sw. Uploads bts sw build sw to BTS. Wait for ping to be lost and to reply again.
    ...                Waits for all cells up. Verify that uploaded SW is activated on BTS and checks unit states and alarms.
    ...                NOTE that this KW is not usable if SW is already in passive bank because then ping is not lost.
    [Arguments]        ${BUILD_TO_DL}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}

    Run Keyword And Continue On Failure   Get Active SW Of BTS
    Run Keyword And Continue On Failure   Get Blackbox File Content From Bts   before
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Run Keyword And Continue On Failure   Teardown Suite Admin
    Print Text To Eventlog                Stop Real time alarm listener
    Run Keyword and Continue On Failure   Stop RT Alarm Listener
    Run Keyword and Continue On Failure   Reset Admin Connection
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    ${TIME_IN_SYSLOG}=                    Get Time Of Last Syslog Line
    Print Step Text                       ${STEP}.1  Upload ${TEXT_IN_STEP} sw to BTS
    IF   ${DO_SW_PRECHECK}
        Run Keyword And Continue On Failure   Software Precheck   ${BUILD_TO_DL}   precheck_type=${SW_PRECHECK_TYPE}
    END
    Print Text To Eventlog                Request software update to ${BUILD_TO_DL}
    ${SWDL_START}=                        Get Start Time
    Set Suite Variable   ${SWDL_START}
    Run Keyword And Continue On Failure   Update Software On Bts  ${BUILD_TO_DL}  timeout=${18000}  admin_connection=log_admin
    Print Text To Eventlog                Software update request done
#    Run Keyword and Continue On Failure   Calculate Duration  ${SWDL_START}
    Run Keyword And Continue On Failure   Wait Cells Disabled Collect IMS  wait_cells_disabled=180
    Print Step Text                       ${STEP}.2  Wait for BTS disconnection and reconnection
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection
    ...                                   disconnection=True  time_to_wait=180   ping_answers=${1}   level_in_error=info
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure   Check If Admin Connection Reset Can Be Done
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  time_to_wait=300
    Run Keyword and Continue On Failure   Wait Admin Connection   connect_always=${True}
    Run Keyword and Continue On Failure   Connect Suite Admin
    Print Text To Eventlog                Start Real time alarm listener
    Run Keyword and Continue On Failure   Start RT Alarm Listener
    Wait Time And Reason                  15   before checking if fault 4420 is activated
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       ${STEP}.3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                       ${STEP}.4  Check that active SW is ${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Check That SW Has Been Updated  ${BUILD_TO_DL}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                       ${STEP}.5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                       ${STEP}.6  Verify that unallowed syslog prints are not found from syslogs
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}  time_stamp=${TIME_IN_SYSLOG}
    Run Keyword And Continue On Failure   Get Blackbox File Content From Bts   after
    Run Keyword And Continue On Failure   Compare Firmware Versions
    Run Keyword And Continue On Failure   Check If Found From Syslog  ${FIRMWARE_UPDATE}  print_eventlog=${False}  time_stamp=${TIME_IN_SYSLOG}
    ...                                   was_found_txt=Firmware versions are updated (according to syslog prints).
    ...                                   was_not_found_txt=Firmware versions are not updated (according to syslog prints).
    Run Keyword And Continue On Failure   Get SW Update Report To Logs  file_name=${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Clear Swdl Path Variables
    Run Keyword And Continue On Failure   Clear Blackbox Variables

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Update SW LMP or S1 And Make Checks
    [Documentation]    Gets active Sw. Uploads bts sw build sw to BTS via LMP connection or via S1 connection. Wait for ping to be
    ...                lost and to reply again. Waits for all cells up. Verify that uploaded SW is activated on BTS and checks unit
    ...                states and alarms.
    ...                NOTE that this KW is not usable if sw is already in passive bank because then ping is not lost.
    [Arguments]        ${BUILD_TO_DL}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_CONNECTION}
    ...                ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    # reset log_admin admin connection in the beginning of the SWDL procedure to get all admin logs to right folder
    Run Keyword and Continue On Failure  Reset Admin Connection
    Run Keyword And Continue On Failure  Get Active SW Of BTS
    Run Keyword And Continue On Failure  Get Blackbox File Content From Bts   before
    ${USER_GIVEN_MPLANE}=  Get Variable Value   ${DEFAULT_ADMIN_IP}   ${EMPTY}
    ${length}=    Get Length    ${USER_GIVEN_MPLANE}
    IF    ${length} == 0 and '${LMP_CONNECTION}' == '${False}'
        Run Keywords    Set Suite Variable  ${CONNECTION}    s1    AND
        ...             Take S1 Connection To Admin                AND
        ...             Set S1 Ip                                  AND
        ...             Set Suite Variable  ${LMP_OR_S1_TEXT}  Use S1 connection for SWDL
    ELSE IF    ${length} > 0
        Set Suite Variable  ${LMP_OR_S1_TEXT}   Using M-Plane IP connection (${USER_GIVEN_MPLANE}) for SWDL
        Set Suite Variable  ${IP_TO_PING}       ${USER_GIVEN_MPLANE}
    END
    Print Text To Eventlog                ${LMP_OR_S1_TEXT}
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    IF     not ${HIGH_AVAILABILITY_ENVIRONMENT}
        Print Text To Eventlog                Stop Real time alarm listener and realtime syslog print search before SWDL
        Run Keyword and Continue On Failure   Stop RT Alarm Listener
        Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    END
    ${TIME_IN_SYSLOG}=                    Get Time Of Last Syslog Line
    Print Step Text                       ${STEP}.1  Upload ${TEXT_IN_STEP} sw to BTS
    IF   ${DO_SW_PRECHECK}
        Run Keyword And Continue On Failure   Software Precheck   ${BUILD_TO_DL}   precheck_type=${SW_PRECHECK_TYPE}
    END
    Print Text To Eventlog                Request software update to ${BUILD_TO_DL}
    ${SWDL_START}=                        Get Start Time
    Set Suite Variable   ${SWDL_START}
    # use common interface kw to catch errors
    Run Keyword And Continue On Failure   Update Software On Bts  ${BUILD_TO_DL}  timeout=${18000}  admin_connection=${CONNECTION}
    ${REQUEST_DONE}=                      Get Start Time
    Print Text To Eventlog                Software update request done
    # Run Keyword and Continue On Failure   Calculate Duration  ${SWDL_START}
    # NOTE if sw in passive bank then ping to Bts should not be lost also in blue-green swdl ping is not lost
    IF     not ${HIGH_AVAILABILITY_ENVIRONMENT}
        # wait cells disabled, collect ims2
        Run Keyword And Continue On Failure   Wait Cells Disabled Collect Ims   wait_cells_disabled=180
        Print Step Text                       ${STEP}.2  Wait for BTS disconnection and reconnection
        Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}
        ...                                   disconnection=${True}  time_to_wait=180   ping_answers=${1}   level_in_error=info
        Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Run Keyword And Continue On Failure   Check If Admin Connection Reset Can Be Done   always_reset=${True}
        Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}  time_to_wait=900
        Run Keyword and Continue On Failure   Wait Admin Connection   connect_always=${True}
        Run Keyword and Continue On Failure   Connect Suite Admin
        Print Text To Eventlog                Start Real time alarm listener
        Run Keyword and Continue On Failure   Start RT Alarm Listener
    ELSE
#         Print Text To Eventlog                Start Real time alarm listener
#         Run Keyword and Continue On Failure   Start RT Alarm Listener
         Print Text To Eventlog                In blue-green swdl ping to BTS is not lost and all cells are not disabled at the same time.
         Wait Time And Reason                  ${WAIT_AFTER_BG_SWDL}   for blue-green swdl to proceed before continuing with checks
    END

    Run Keyword And Continue On Failure   Special Logs And Or Ssh Commands After Reset Before Test
    IF    ${length} == 0 and '${LMP_CONNECTION}' == '${False}'
        Run Keyword And Continue On Failure  Teardown Selected Admin Connection  s1
    END
    Wait Time And Reason                  15   before checking if fault 4420 is activated
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       ${STEP}.3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Get Ims2 File From Disconnection File
    Print Step Text                       ${STEP}.4  Check that active SW is ${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Check That Sw Has Been Updated    ${BUILD_TO_DL}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                       ${STEP}.5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                       ${STEP}.6  Verify that unallowed syslog prints are not found from syslogs
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}  time_stamp=${TIME_IN_SYSLOG}
# Commented out because of FCA_TATSCRIPTS-182446 Robotization for SWDL cases: Remove states checking
#    Print Step Text                       ${STEP}.6  Check from history that SMOD, RMODs, BBMODs and cells were reseted
#    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States  file_name=IMS_of_${TEXT_IN_STEP}
# FCA_TATSCRIPTS-182904 Remove cell history check
#    Print Step Text                       ${STEP}.6  Check from history that cells were reseted
#    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled
#    ...                                   all_cells=${True}  file_name=IMS_of_${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Get Blackbox File Content From Bts   after
    ${firmware_was_updated1}=             Compare Firmware Versions
    ${firmware_was_updated2}=             Check If Found From Syslog  ${FIRMWARE_UPDATE}  print_eventlog=${False}  time_stamp=${TIME_IN_SYSLOG}
    ...                                   was_found_txt=Firmware versions are updated (according to syslog prints).
    ...                                   was_not_found_txt=Firmware versions are not updated (according to syslog prints).
    ${firmware_was_updated}=              Boolean Or Operation  ${firmware_was_updated1}  ${firmware_was_updated2}
    Run Keyword And Continue On Failure   Select Kpi Depending On Firmware Update  ${firmware_was_updated}   ${SELECTED_KPI}
    Print Step Text                       ${STEP}.7  Collect KPIs
    Run Keyword and Continue On Failure   Collect KPIs    ${SELECTED_KPI}  SWDL_test  ${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Check Loop KPI  ${SELECTED_KPI}  ${OAM_KPI_TARGETS}
    Print Step Text                       ${STEP}.8  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  SWDL_test  ${REQUEST_DONE}
    Run Keyword And Continue On Failure   Get SW Update Report To Logs  file_name=${TEXT_IN_STEP}
    ${intra_or_inter}=                    Get Intra Or Inter
    IF    '${intra_or_inter}' == 'intra'
        Run Keyword And Continue On Failure   Check Swdl Shutdown Times
    END
#    Run Keyword And Continue On Failure   Clear Swdl Variables
#    Run Keyword And Continue On Failure   Clear Blackbox Variables

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Omkpi Testkeyword Failed   SWDL of ${TEXT_IN_STEP}

Omkpi Testkeyword Failed
    [Arguments]        ${TC_KW}

    Print Text To Eventlog    Failure noticed during ${TC_KW}
    Set Suite Variable        ${KW_SUCCESS}  ${False}
    Fail                      ${TC_KW} failed

Update SW LMP or S1
    [Documentation]    Gets active Sw. Uploads bts sw build sw to BTS via LMP connection or via S1 connection. Wait for ping to be
    ...                lost and to reply again. Waits for all cells up. Verify that uploaded SW is activated on BTS and checks unit
    ...                states and alarms. NOTE This KW doesn't calculate any KPI values.
    ...                NOTE that this KW is not usable if sw is already in passive bank because then ping is not lost.
    [Arguments]        ${BUILD_TO_DL}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_CONNECTION}

    Run Keyword And Continue On Failure  Get Active SW Of BTS
    Run Keyword And Continue On Failure  Get Blackbox File Content From Bts   before
#    Run Keyword If  '${LMP_CONNECTION}' == '${False}'   Run Keywords    Set Suite Variable  ${CONNECTION}    s1    AND
#    ...                                                                 Take S1 Connection To Admin                AND
#    ...                                                                 Set S1 Ip
    ${USER_GIVEN_MPLANE}=  Get Variable Value   ${DEFAULT_ADMIN_IP}   ${EMPTY}
    ${length}=    Get Length    ${USER_GIVEN_MPLANE}
    IF    ${length} == 0 and '${LMP_CONNECTION}' == '${False}'
        Run Keywords    Set Suite Variable  ${CONNECTION}    s1    AND
        ...             Take S1 Connection To Admin                AND
        ...             Set S1 Ip                                  AND
        ...             Set Suite Variable  ${LMP_OR_S1_TEXT}  Use S1 connection for SWDL
    ELSE IF    ${length} > 0
        Set Suite Variable  ${LMP_OR_S1_TEXT}   Using M-Plane IP connection (${USER_GIVEN_MPLANE}) for SWDL
        Set Suite Variable  ${IP_TO_PING}       ${USER_GIVEN_MPLANE}
    END
    Run Keyword and Continue On Failure   Teardown Suite Admin
    Print Text To Eventlog                Stop Real time alarm listener
    Run Keyword and Continue On Failure   Stop Rt Alarm Listener
    Run Keyword and Continue On Failure   Reset Admin Connection
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    ${TIME_IN_SYSLOG}=                    Get Time Of Last Syslog Line
    Print Step Text                       ${STEP}.1  Upload ${TEXT_IN_STEP} sw to BTS
    IF   ${DO_SW_PRECHECK}
        Run Keyword And Continue On Failure   Software Precheck   ${BUILD_TO_DL}   precheck_type=${SW_PRECHECK_TYPE}
    END
    Print Text To Eventlog                Request software update to ${BUILD_TO_DL}
    ${SWDL_START}=                        Get Start Time
    Set Suite Variable   ${SWDL_START}
    Run Keyword And Continue On Failure   Update Software On Bts  ${BUILD_TO_DL}  timeout=${18000}  admin_connection=${CONNECTION}
    Print Text To Eventlog                Software update request done
#    Run Keyword and Continue On Failure   Calculate Duration      ${SWDL_START}
# wait cells disabled, collect ims2
    Run Keyword And Continue On Failure   Wait Cells Disabled Collect Ims   wait_cells_disabled=180
    Print Step Text                       ${STEP}.2  Wait for BTS disconnection and reconnection
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}
    ...                                   disconnection=True  time_to_wait=180   ping_answers=${1}   level_in_error=info
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure   Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=${IP_TO_PING}  time_to_wait=900
    Run Keyword and Continue On Failure   Wait Admin Connection   connect_always=${True}
    Run Keyword and Continue On Failure   Connect Suite Admin
    Print Text To Eventlog                Start Real time alarm listener
    Run Keyword and Continue On Failure   Start Rt Alarm Listener
    IF    ${length} == 0 and '${LMP_CONNECTION}' == '${False}'
        Run Keyword And Continue On Failure  Teardown Selected Admin Connection  s1
    END
    Wait Time And Reason                  15   before checking if fault 4420 is activated
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       ${STEP}.3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                       ${STEP}.4  Check that active SW is ${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Check That Sw Has Been Updated    ${BUILD_TO_DL}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                       ${STEP}.5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                       ${STEP}.6  Verify that unallowed syslog prints are not found from syslogs
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}  time_stamp=${TIME_IN_SYSLOG}
    Run Keyword And Continue On Failure   Get Blackbox File Content From Bts   after
    Run Keyword And Continue On Failure   Compare Firmware Versions
    Run Keyword And Continue On Failure   Check If Found From Syslog  ${FIRMWARE_UPDATE}  print_eventlog=${False}  time_stamp=${TIME_IN_SYSLOG}
    ...                                   was_found_txt=Firmware versions are updated (according to syslog prints).
    ...                                   was_not_found_txt=Firmware versions are not updated (according to syslog prints).
    Run Keyword And Continue On Failure   Get SW Update Report To Logs   file_name=${TEXT_IN_STEP}
    Run Keyword And Continue On Failure   Clear Swdl Path Variables
    Run Keyword And Continue On Failure   Clear Blackbox Variables

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Rollback To Previous SW
    [Documentation]    Request software rollback to build that is in passive bank.
    [Arguments]    ${ACTIVE_SW}  ${OLD_SW}  ${STEP}  ${WAIT_CHECKS}
    # reset log_admin admin connection in the beginning of the SWDL procedure to get all admin logs to right folder
    Run Keyword and Continue On Failure   Reset Admin Connection
    ${STEP}=                              Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    ${passive_sw}=                        Get Passive Sw Of Bts
    ${TIME_IN_SYSLOG}=                    Get Time Of Last Syslog Line
    Print Step Text                       ${STEP}.1  Rollback from ${ACTIVE_SW} SW to ${OLD_SW} SW
    Print Text To Eventlog                Request rollback to ${OLD_SW}
    Run Keyword And Continue On Failure   Rollback To Passive Sw  timeout=${1800}  admin_connection=log_admin
    Print Text To Eventlog                Request to rollback done
# wait cells disabled
    Print Step Text                       ${STEP}.2  Wait for all cells faulty
    Run Keyword And Continue On Failure   Wait For Cells Faulty    600
    ${collect}=                           Logs Should Be Collected
    Run Keyword If     '${collect}' == '${True}'   Run Keyword And Continue On Failure
    ...                COLLECTLOGS.Collect Ims  ims_file=${EMPTY}  connection=log_admin   extra_name=Rollback_to_${passive_sw}
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection
    ...                                   disconnection=${True}  time_to_wait=180   ping_answers=${1}   level_in_error=info
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection     time_to_wait=900
    Run Keyword and Continue On Failure   Sleep    90s
    Print Text To Eventlog                Reset admin connections after rollback
    Run Keyword And Continue On Failure   Reset Admin Connections
    Run Keyword And Continue On Failure   Sleep    60s
    Print Step Text                       ${STEP}.3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up    time_limit=2000
    Run Keyword And Continue On Failure   Get Ims2 File From Disconnection File   fail_if_not_success=${False}
    Print Step Text                       ${STEP}.4  Check that active SW is ${OLD_SW}
    Run Keyword And Continue On Failure   Check That Sw Has Been Updated    ${OLD_SW}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       ${STEP}.5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                       ${STEP}.6  Verify that unallowed syslog prints are not found from syslogs
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}  time_stamp=${TIME_IN_SYSLOG}
    Run Keyword And Continue On Failure   Get SW Update Report To Logs

    [Teardown]   Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Omkpi Testkeyword Failed   Rollback to older SW

Upgrade Sw build On Older Build
    [Documentation]    In the beginning of this KW it is expected that older SW build is active on BTS. Updates of
       ...             tested software packages are always done on it and between test package downloads rollback is made.
       ...             You are able to increase wait time between SWDLs with WAIT_BETWEEN_SWDLS variable.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}  ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}
       ...         ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  ${BUILD_T1}  ${BUILD_T2}  ${BUILD_N}  ${OLDER_SW_BUILD}
    Run Keyword and Continue On Failure   Check If Build In Passive Side Is Same That Is Planned To Be Downloaded  ${BUILD_T1}
    ${RU_SWDL}=                Get Variable Value  ${RU_SWDL}  ${False}
# Check if ru swdl and run test
    IF   '${RU_SWDL}' == '${True}'
        Run Keyword And Continue On Failure  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
        ...                                  ${UNALLOWED_SYSLOGS}   ${BUILD_T1}  T${SWDL_FIRST}  No_KPI55
        ${STEP}=   BTS.Increase Test Step
    END

# T1 (or T2 if T1 was in passive side)
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_T${SWDL_FIRST}
    Run Keyword and Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_T1}  T${SWDL_FIRST} testpackage  ${STEP}  ${WAIT_CHECKS}   ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  SWDL_of_T${SWDL_FIRST}
    Run Keyword And Continue On Failure   Create New Log Folder  Rollback_from_T${SWDL_FIRST}
    Run Keyword and Continue On Failure   Rollback and Log Collection If Fail
    ...                                   ${BUILD_T1}    ${OLDER_SW_BUILD}    ${STEP}  ${WAIT_CHECKS}
    ...                                   Rollback_from_T${SWDL_FIRST}
# T2 (or T1 if T1 was in passive side)
    Run Keyword And Continue On Failure   Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting T${SWDL_SECOND} SWDL
# Check if ru swdl and run test
    Run Keyword If                        '${RU_SWDL}' == '${True}'  Run Keyword And Continue On Failure
    ...  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                          ${BUILD_T2}  T${SWDL_SECOND}  No_KPI55
    ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_T${SWDL_SECOND}
    Run Keyword and Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_T2}  T${SWDL_SECOND} testpackage  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  SWDL_of_T${SWDL_SECOND}
    Run Keyword And Continue On Failure   Create New Log Folder  Rollback_from_T${SWDL_SECOND}
    Run Keyword and Continue On Failure   Rollback and Log Collection If Fail
    ...                                   ${BUILD_T2}    ${OLDER_SW_BUILD}    ${STEP}  ${WAIT_CHECKS}
    ...                                   Rollback_from_T${SWDL_SECOND}
# Normal
    Run Keyword And Continue On Failure   Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting normal build SWDL
# Check if ru swdl and run test
    Run Keyword If                        '${RU_SWDL}' == '${True}'  Run Keyword And Continue On Failure
    ...  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                          ${BUILD_N}  normal  No_KPI55
    ${STEP}=               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_normal
    Run Keyword and Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_N}  normal build  ${STEP}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  SWDL_of_normal

    ${EXTRA_ROLLBACK}=     More Than One Test Loop
    ${LAST_LOOP}=          Loop Is the Last One
    Run Keyword If  '${EXTRA_ROLLBACK}' == '${True}' and '${LAST_LOOP}' == '${False}'   Run Keywords  Run Keyword and Continue On Failure
    ...             Create New Log Folder  Rollback_from_normal   AND
    ...             Rollback and Log Collection If Fail  ${BUILD_N}  ${OLDER_SW_BUILD}  ${STEP}  ${WAIT_CHECKS}
    ...                                                  Rollback_from_normal   AND
    ...  Run Keyword and Continue On Failure   Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting T1 SWDL
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Rollback and Log Collection If Fail
    [Documentation]    Rollback to passive SW and collect logs if KW_SUCCESS is False.
    [Arguments]    ${BUILD_N}  ${OLDER_SW_BUILD}  ${STEP}  ${WAIT_CHECKS}  ${NAME_FOR_LOG}
#    ${START_LINE}=    Get Last Line From Syslogs
    Set Suite Variable   ${EXTRA_INFO_FOR_LOOP}   _${NAME_FOR_LOG}
    Run Keyword And Continue On Failure    Check If Allowed Alarms During Rollback
    Run Keyword And Continue On Failure    Rollback To Previous SW  ${BUILD_N}  ${OLDER_SW_BUILD}  ${STEP}  ${WAIT_CHECKS}
    ${collect}=  Logs Should Be Collected
    IF   '${collect}' == '${True}'
        Run Keyword And Continue On Failure   Get Snapshot And Ims Log  info_text=after rollback  extra_name=${NAME_FOR_LOG}
    END
    Run Keyword And Continue On Failure    Get Syslogs And E2e
    Run Keyword And Continue On Failure    Check If Allowed Alarms During Rollback  remove=${False}
    Run Keyword And Continue On Failure    Clear Swdl Path Variables
    Run Keyword And Continue On Failure    Switch To Original Log Folder
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

SW Update and Log Collection If Fail
    [Documentation]    Update SW to BTS and collect logs if KW_SUCCESS is False. If given build is same that already is active writes error.
    [Arguments]  ${BUILD}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}
    ...          ${SELECTED_KPI}  ${NAME_FOR_LOG}
    Set Suite Variable   ${EXTRA_INFO_FOR_LOOP}   _${NAME_FOR_LOG}
    Check If Build In Active Side Is Same That Is Planned To Be Downloaded  ${BUILD}
    oam_kpi_calculations.Save Search Start Timestamp

    Run Keyword and Continue On Failure    Update SW LMP or S1 And Make Checks  ${BUILD}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}
    ...                                    ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    Run Keyword And Continue On Failure    Check If Logs Should Be Collected  ${NAME_FOR_LOG}   ${False}   ${TEXT_IN_STEP}
    Run Keyword And Continue On Failure    Check If IM Analysis Should Be Done In Swdl
    ${FAULT_30_ACTIVATED}=   Check If Fault Is Active   30
    IF  ${FAULT_30_ACTIVATED}
        Get File From Zip Or Tar           SWDLreport
    END
    Run Keyword And Continue On Failure    Get Syslogs And E2e
    ${log_collection}=  Logs Should Be Collected
    IF   '${log_collection}' == '${True}'
        Print Step Text                        ${STEP}.9  Check Postconditions after log collection
        Run Keyword And Continue On Failure    Common Postconditions
        Run Keyword And Continue On Failure    Check If Logs Should Be Collected  ${NAME_FOR_LOG}   ${True}  ${TEXT_IN_STEP}
    END
    Run Keyword And Continue On Failure    Clear Swdl Path Variables
    Run Keyword And Continue On Failure    Clear Blackbox Variables
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Switch To Original Log Folder

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Logs Should Be Collected
    [Documentation]    Check if logs should be collected based on KW_SUCCESS, LOOP_KPI and COLLECT_LOGS variable.
    [Arguments]    ${NAME_FOR_LOG}   ${CHECK_PREVIOUS_LOGS}=${False}   ${TEXT_IN_STEP}=${EMPTY}
    ${log_collection}=  Logs Should Be Collected
    ${other_master_lmp_swdl_test}=    Get Variable Value   ${OTHER_MASTER_LMP_SWDL}   ${False}
    IF   '${log_collection}' == '${True}'
# If CHECK_PREVIOUS_LOGS: Check if logs were already collected and only collect logs, if was not collected before
        IF  '${CHECK_PREVIOUS_LOGS}' == '${False}' or ('${CHECK_PREVIOUS_LOGS}' == '${True}' and '${log_collection}' != '${LOGS_WERE_NEEDED}')
            Run Keyword and Continue On Failure   COLLECTLOGS.Collect Snapshot  extra_name=${NAME_FOR_LOG}
            IF  '${other_master_lmp_swdl_test}' == '${True}'
                Run Keyword and Continue On Failure    Get Admin Logs From Other To Test Logs
            END
        END
        Run Keyword and Continue On Failure   COLLECTLOGS.Check If Ims2 Files Are Collected   ${TEXT_IN_STEP}
    END
    Set Suite Variable   ${LOGS_WERE_NEEDED}   ${log_collection}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

SW Update No KPI Calculations and Log Collection If Fail
    [Documentation]    Update SW to BTS and collect logs if KW_SUCCESS is False or COLLECT_LOGS is Always.
    ...                Doesn't calculate any KPI values, just SWDL is made.
    [Arguments]  ${BUILD}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}  ${NAME_FOR_LOG}
    Run Keyword And Continue On Failure   Create New Log Folder  ${NAME_FOR_LOG}
    Run Keyword and Continue On Failure   Update SW LMP or S1  ${BUILD}  ${TEXT_IN_STEP}  ${STEP}  ${WAIT_CHECKS}
    ...                                   ${WAIT_FOR_CELLS_UP}  ${LMP_SWDL}
    ${log_collection}=  Logs Should Be Collected
    Run Keyword If    '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
    ...               Get Snapshot And Ims Log  info_text=after ${TEXT_IN_STEP} because there has been failure  extra_name=${NAME_FOR_LOG}
    Run Keyword And Continue On Failure    Get Syslogs And E2e
    Run Keyword And Continue On Failure    Clear Swdl Path Variables
    Run Keyword And Continue On Failure    Clear Blackbox Variables
    Run Keyword And Continue On Failure    Switch To Original Log Folder
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Upgrade Sw build
    [Documentation]   Download builds T1, T2 and normal of software that is currently active on BTS and update them one by one.
       ...            You are able to increase wait time between SWDLs with WAIT_BETWEEN_SWDLS variable.
       ...            NOTE no rollbacks are made between downloads.
    [Arguments]   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${STEP}  ${UNALLOWED_SYSLOGS}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}
    ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword and Continue On Failure   Check If Build In Passive Side Is Same That Is Planned To Be Downloaded  ${BUILD_T1}
    ${RU_SWDL}=             Get Variable Value  ${RU_SWDL}  ${False}
# T1 (or T2 if T1 was in passive side)
# Check if ru swdl and run test
    IF    '${RU_SWDL}' == '${True}'
        Run Keyword And Continue On Failure   Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
        ...  ${UNALLOWED_SYSLOGS}   ${BUILD_T1}  T${SWDL_FIRST}   No_KPI55
        ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    END
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_T${SWDL_FIRST}
    Run Keyword and Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_T1}  T${SWDL_FIRST} testpackage  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${SELECTED_KPI}  SWDL_of_T${SWDL_FIRST}
# T2 (or T1 if T1 was in passive side)
# Check if ru swdl and run ru swdl test
    Run Keyword If                        '${RU_SWDL}' == '${True}'  Run Keyword And Continue On Failure
    ...  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                          ${BUILD_T2}  T${SWDL_SECOND}   No_KPI55
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_T${SWDL_SECOND}
    Run Keyword And Continue On Failure   Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting T${SWDL_SECOND} SWDL
    ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_T2}  T${SWDL_SECOND} testpackage  ${STEP}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}    ${SELECTED_KPI}  SWDL_of_T${SWDL_SECOND}
# Normal
# Check if ru swdl and run ru swdl test
    Run Keyword If                        '${RU_SWDL}' == '${True}'  Run Keyword And Continue On Failure
    ...  Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                          ${BUILD_N}  normal  No_KPI55
    Run Keyword And Continue On Failure   Create New Log Folder  SWDL_of_normal
    Run Keyword And Continue On Failure   Wait Time And Reason   ${WAIT_BETWEEN_SWDLS}   before starting normal build SWDL
    ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure   SW Update and Log Collection If Fail
    ...                                   ${BUILD_N}  normal build  ${STEP}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}
    ...                                   ${LMP_SWDL}  ${OAM_KPI_TARGETS}    ${SELECTED_KPI}  SWDL_of_normal
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Set S1 Ip
    ${ip}=    Get S1 Ip
    Set Suite Variable    ${IP_TO_PING}    ${ip}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}
