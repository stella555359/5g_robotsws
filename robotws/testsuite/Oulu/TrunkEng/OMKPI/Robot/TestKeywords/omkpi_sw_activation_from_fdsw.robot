*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot

Library          taf.fdsw.rc  WITH NAME  RC
Library          testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
Library          testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole
Resource         testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/failsafe_boot_ute.robot

*** Variables ***
&{FLAG_VALUE}    0x10041=5

*** Keywords ***
SW Activation From FDSW One Build
    [Documentation]    Get T1 or T2 Test package or Normal from artifactory. Do configuration reset. Activate SW from FDSW. Calculate KPIs.
    ...                Do commissioning and set swconfig.txt. Do radio software update. Check that BTS up and running and
    ...                no unexpected alarms or syslog prints.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background   ${SYSLOG_LIST}
    ${BUILD}=                             Get Build given As One_build Argument    ${ONE_BUILD}
    Run Keyword And Continue On Failure   Check If Build In Passive Side Is Same That Is Planned To Be Downloaded
    ...                                   ${BUILD}    switch_order=${False}
    Run Keyword And Continue On Failure   SW Activation From FDSW Test Steps    ${BUILD}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
    ...                                   ${WAIT_RC_CONNECTION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${ONE_BUILD}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    ${log_collection}=  Logs Should Be Collected
    Run Keyword If    '${log_collection}' == '${True}'   Run Keyword and Continue On Failure  Run Keywords
    ...                                   COLLECTLOGS.Get Snapshot And Ims Log  extra_name=${ONE_BUILD}   AND
    ...                                   COLLECTLOGS.Collect Syslog
    Run Keyword And Continue On Failure   Check If IM Analysis Should Be Done In Swdl
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

SW Activation From FDSW
    [Documentation]    Get T1 and T2 Test packages and Normal software package from artifactory.
    ...                Do configuration reset. Activate SW from FDSW. Calculate KPIs.
    ...                Do commissioning and set swconfig.txt. Do radio software update. Check that BTS up and running and
    ...                no unexpected alarms or syslog prints.
    ...                Do this one by one to all three software packages, T1 Test package, T2 Test package and Normal package.
    ...                NOTE If T1 package is in passive side, T2 package will be installed first.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background   ${SYSLOG_LIST}
    Run Keyword                           Set Build Names And Get Packages That Will Be Used In Swdl   ${None}
    Run Keyword And Continue On Failure   Check If Build In Passive Side Is Same That Is Planned To Be Downloaded   ${BUILD_T1}
    ${MAIN_LOG_FOLDER}=                   Get Current Log Folder
# T1(or T2)
    Run Keyword And Continue On Failure   Create Folder SWDL from FDSW and Log Collecting
    ...                                   ${BUILD_T1}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}
    ...                                   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  T${SWDL_FIRST}  From_FDSW_to_T${SWDL_FIRST}
    Run Keyword And Continue On Failure   Switch To Original Log Folder  ${MAIN_LOG_FOLDER}
# T2(or T1)
    Run Keyword And Continue On Failure   Create Folder SWDL from FDSW and Log Collecting
    ...                                   ${BUILD_T2}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}
    ...                                   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  T${SWDL_SECOND}  From_FDSW_to_T${SWDL_SECOND}
    Run Keyword And Continue On Failure   Switch To Original Log Folder  ${MAIN_LOG_FOLDER}
# Normal build
    Run Keyword And Continue On Failure   Create Folder SWDL from FDSW and Log Collecting
    ...                                   ${BUILD_N}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}
    ...                                   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  Normal  From_FDSW_to_Normal
    Run Keyword And Continue On Failure   Switch To Original Log Folder  ${MAIN_LOG_FOLDER}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

SW Activation From FDSW Test Steps
    [Documentation]    Do configuration reset that activates FDSW. Install SW from RescueConsole. Commissioning.
    ...                Calculate KPIs. Do RU SWDL.
    [Arguments]        ${BUILD}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}
    ...                ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${BUILD_TEXT}
#    Run Keyword And Continue On Failure    Check If Netboot Is Active And Deactivate It
# check if fdsw is installed
    Run Keyword And Continue On Failure    Failsafe Pre Checks  ${SYSLOG_LIST}
# configuration reset
    Print Step Text                        3  Perform configuration reset   automatic=${True}
    Run Keyword And Continue On Failure    Perform Configuration Reset
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Wait Time And Reason                   ${WAIT_RC_CONNECTION}     before connecting to RescueConsole
    Run Keyword And Continue On Failure    Connect To RC
    Print Step Text                        4  Check partition and SW   automatic=${True}
    Run Keyword And Continue On Failure    Check Partition And SW
    Run Keyword And Continue On Failure    Update Software To BTS On FDSW   ${BUILD}
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_id=23  fault_name=Incompatible SW version detected
    Run Keyword And Continue On Failure    Start Rt Alarm Listener
# Enable ssh from admin
    Run Keyword And Continue On Failure    Enable Ssh Access From Admin
# Enable syslog without extra reset
    Run Keyword And Continue On Failure    Add Flags Via Telnet    ${FLAG_VALUE}
# Commissioning
    Print Step Text                        5  Perform commissioning   automatic=${True}
    Run Keyword And Continue On Failure    Perform Commissioning With Scf File  create_own_connection=${False}
    Wait Time And Reason                   sleep_time=${WAIT_CHECKS}  wait_reason=after commissioning before checking if bts pings
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    ip_to_ping=192.168.255.129  time_to_wait=${WAIT_CHECKS}
# Get SWDLreport and calculate KPI
    # Print Step Text                        6  Calculate KPI#61a: BTS SW upgrade from FDSW   automatic=${True}
    ${VAR_SWDL_REPORT}=                    Get Sw Update Report To Logs  file_name=${BUILD_TEXT}
    Run Keyword And Continue On Failure    Get Sw Activation Time From Fdsw To Rat Sw   ${VAR_SWDL_REPORT}
    Set Suite Variable     ${SWDL_REPORT}   ${VAR_SWDL_REPORT}
    Print Step Text                        6  Collect KPIs  automatic=${True}
    Run Keyword and Continue On Failure    Collect KPIs  BTS SW upgrade from FDSW
    Run Keyword And Continue On Failure    Check Loop Kpi  BTS SW upgrade from FDSW  ${OAM_KPI_TARGETS}
# Upload swconfig.txt to BTS before radio software update
    Run Keyword And Continue On Failure    Upload File To Bts
# Do radio SWDL to get BTS up and running
#    Print Text To Eventlog                Check if there were problems and collect logs if needed before RU Software update
#    ${log_collection}=  Logs Should Be Collected
#    Run Keyword If    '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
#    ...                                   COLLECTLOGS.Get Snapshot And Ims Log  extra_name=${BUILD_TEXT}_before_ru_swdl
    Run Keyword And Continue On Failure    Update Radio Software  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${BUILD}
    Print Step Text                        7  Check Postconditions   automatic=${True}
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    Remove Allowed Alarm  fault_id=23  fault_name=Incompatible SW version detected
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Update Radio Software
    [Documentation]    Update SW to RF units and check that BTS is up and running.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${BUILD}
#    Run Keyword And Continue On Failure    Create New Log Folder  RF_SWDL_of_${BUILD_TEXT}
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
    Print Step Text                       1  Upload ${BUILD} sw to BTS   automatic=${True}
    Print Text To Eventlog                Request RF software update to ${BUILD}
    ${SWDL_START}=                        Get Start Time
    Run Keyword And Continue On Failure   Update Software On Bts  ${BUILD}  should_activate=${True}  ru_swdl_only=${True}
    ...                                   timeout=${12000}  admin_connection=log_admin
    Print Text To Eventlog                RF Software update request done
    Run Keyword and Continue On Failure   Calculate Duration      ${SWDL_START}
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Wait Time And Reason  sleep_time=${WAIT_CHECKS}
    Run Keyword And Continue On Failure   Get Rf Sw Version
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Create Folder SWDL from FDSW and Log Collecting
    [Documentation]    Create new sub log folder, do steps of SW Activation From FDSW and collect logs if needed.
    [Arguments]        ${BUILD}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...                ${BUILD_TEXT}  ${NAME_FOR_LOG}
    Run Keyword And Continue On Failure   Create New Log Folder  From_FDSW_to_${BUILD_TEXT}
    ${START_LINE}=                        Get Last Line From Syslogs
    Run Keyword And Continue On Failure   SW Activation From FDSW Test Steps    ${BUILD}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
    ...                                   ${WAIT_RC_CONNECTION}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${BUILD_TEXT}
    ${log_collection}=  Logs Should Be Collected
    Run Keyword If    '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
    ...                                   COLLECTLOGS.Get Snapshot And Ims Log  extra_name=${NAME_FOR_LOG}
    ${END_LINE}=      Get Last Line From Syslogs
    Run Keyword And Continue On Failure   Get Syslogs Between Two Lines  ${START_LINE}  ${END_LINE}  file_name=${NAME_FOR_LOG}
    Run Keyword And Continue On Failure   Check If IM Analysis Should Be Done In Swdl
    Run Keyword And Continue On Failure   Switch To Original Log Folder
    Run Keyword And Continue On Failure   Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
