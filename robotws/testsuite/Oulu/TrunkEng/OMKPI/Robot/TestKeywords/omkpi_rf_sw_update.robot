*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface

*** Variables ***
${FAULTY_CELLS_RAISE_ERROR}   ${False}
${RU_SW_WAIT}                 300
${RADIOS_TO_UPDATE}
${KPI55d_test}                ${False}
${ignore_ru_swdl_check}       ${False}

*** Keywords ***
OMKPI RF SW Update
    [Documentation]    Update SW to RF units and check KPIs. First T1, then T2 and finally normal build again.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background   ${SYSLOG_LIST}
#    Run Keyword And Continue On Failure    Check If Netboot Is Active And Deactivate It
    ${CHECK_CALIBRATION_FILES}=            Get Variable Value  ${CHECK_CALIBRATION_FILES}  ${False}
    ${calibration_files}=                  Create List  /mnt/factory/configs/unit/disable_tx_bf_calibration.txt
    ...                                                 /mnt/factory/configs/unit/disable_rx_bf_calibration.txt
    Run Keyword If    '${CHECK_CALIBRATION_FILES}' == '${True}'   Run Keyword And Continue On Failure
    ...                Check And Create File On Radio  radio=all  file_names=${calibration_files}
    Run Keyword                            Set Build Names And Get Packages That Will Be Used In Swdl   ${None}
    Run Keyword And Continue On Failure    Check If Build In Passive Side Is Same That Is Planned To Be Downloaded   ${BUILD_T1}   check_ru=${True}
    Run Keyword And Continue On Failure    Get Value Of Ru Phase Activation Reset Policy
# T1
    Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                                                            ${BUILD_T1}  T1   Collect_KPI55
# T2
    Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                                                            ${BUILD_T2}  T2   Collect_KPI55
# Normal build
    Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                                                            ${BUILD_N}  Normal   Collect_KPI55

    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Log Folders And Radio Software Update
    [Documentation]    Create new sub log folder, update SW to RF units and collect logs if needed.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}  ${BUILD}  ${STAND_ALONE}
    oam_kpi_calculations.Save Search Start Timestamp
    ${STEP}=          Check If Step Smaller Or Same As Saved If Is Increase    0
    Run Keyword And Continue On Failure    Create New Log Folder  RF_SWDL_of_${BUILD}
    Set Suite Variable  ${EXTRA_INFO_FOR_LOOP}  _RF_SWDL_of_${BUILD}
    Run Keyword And Continue On Failure    Radio Software Update Test Steps  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
    ...                                                                      ${PATH_IN_PC}  ${STEP}  ${STAND_ALONE}
    ${log_collection}=      Logs Should Be Collected
    Run Keyword If    '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
    ...               COLLECTLOGS.Collect Snapshot   extra_name=${BUILD}
    Run Keyword If    '${STAND_ALONE}' != 'Collect_KPI55' and '${log_collection}' == '${True}'   Run Keyword and Continue On Failure
    ...               COLLECTLOGS.Collect Ims        extra_name=${BUILD}
    Run Keyword And Continue On Failure    Check If IM Analysis Should Be Done In Swdl
    Run Keyword And Continue On Failure    Get Syslogs And E2e
    IF   '${log_collection}' == '${True}'
        Print Step Text                        ${STEP}.8  Check Postconditions after log collection
        Run Keyword And Continue On Failure    Common Postconditions
    END
    Run Keyword And Continue On Failure    Clear Swdl Path Variables
    Run Keyword And Continue On Failure    Switch To Original Log Folder
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'   Set Suite Variable  ${KW_SUCCESS}  ${False}

Radio Software Update Test Steps
    [Documentation]    Update SW to RF units and check KPIs.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}  ${PATH_IN_PC}  ${STEP}  ${STAND_ALONE}
    ${RU_SW_ACTIVATION}=                  Get Variable Value  ${RU_SW_ACTIVATION}  ${True}
    Print Step Text                    ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    ${RF_SW_VERSIONS}=                    Get Rf Sw Version
# If RU should be activated and there is DU in upgradePhase of all RU, RU_SW_ACTIVATION is set to False
    IF   ${RU_SW_ACTIVATION}
        ${ignore_ru_swdl_check}=          Upgrade Phase Parameter Of Radios    DU
        IF  '${ignore_ru_swdl_check}' == '${True}'
            Set Suite Variable    ${RU_SW_ACTIVATION}   ${False}
        END
    END

#    ${SWDL_AFFECTED_CELLS}=               Get Cells That Are Affected By Swdl   ${PATH_IN_PC}
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
# Because of 4420 fault occasionally BTS is busy and it is not possible to get information from it before 4420 is cleared
    Run Keyword And Continue On Failure   Check If Fault Active And Wait For It To Clear  4420
#    ${TIME_IN_SYSLOG}=                    Get Time Of Last Syslog Line
# stop realtime alarms and syslog parsing (so moving packages from test PC to BTS will be a bit faster)
    Run Keyword and Continue On Failure   Stop RT Alarm Listener
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Print Step Text                    ${STEP}.2  Upload ${PATH_IN_PC} sw to BTS
    Print Text To Eventlog                Request RF software update to ${PATH_IN_PC}
    ${SWDL_START}=                        Get Start Time
    Run Keyword And Continue On Failure   Update Software On Bts  ${PATH_IN_PC}  should_activate=${RU_SW_ACTIVATION}  ru_swdl_only=${True}
    ...                                   timeout=${12000}  admin_connection=log_admin
    Print Text To Eventlog                RF Software update request done
    # Run Keyword and Continue On Failure   Calculate Duration      ${SWDL_START}
# start realtime alarms and syslog parsing
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    IF     ${HIGH_AVAILABILITY_ENVIRONMENT}
        Set Suite Variable   ${RT_ALARM_UPDATE_INTERVAL}   ${1000}
    END
    Run Keyword and Continue On Failure   Start RT Alarm Listener
    Run Keyword If    '${RU_SW_ACTIVATION}' == '${True}'  Run Keyword And Continue On Failure
    ...                                   Wait And Check Cells And Sw Version  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${RF_SW_VERSIONS}  ${STEP}
    Print Step Text                    ${STEP}.6  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If    '${STAND_ALONE}' == 'Collect_KPI55' and '${RU_SW_ACTIVATION}' == '${True}'    Run Keyword And Continue On Failure
    ...                                   RU KPI Calculations    ${STEP}
    Print Step Text                    ${STEP}.7  Print Extra Kpis
    IF   ${KPI55d_test}
        Run Keyword If    '${RU_SW_ACTIVATION}' == '${True}'    Run Keyword And Continue On Failure
        ...               Print Extra KPIs   Independent sequential RUs SW upgrade duration  start_point=${SWDL_START}  cells=${True}
    ELSE
        Run Keyword If    '${RU_SW_ACTIVATION}' == '${True}'    Run Keyword And Continue On Failure
        ...               Print Extra KPIs   Manual RU SW upgrade downtime  start_point=${SWDL_START}  cells=${True}
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RU KPI Calculations
    [Documentation]    Calculate RU KPIs.
    [Arguments]        ${STEP}
    Print Step Text                       ${STEP}.7  Collect KPIs
    IF   ${KPI55d_test}
        Run Keyword and Continue On Failure   Collect KPIs  Independent sequential RUs SW upgrade duration
        Run Keyword And Continue On Failure   Check Loop Kpi  Independent sequential RUs SW upgrade duration  ${OAM_KPI_TARGETS}
    ELSE
        Run Keyword and Continue On Failure   Collect KPIs  Manual RU SW upgrade downtime
        Run Keyword And Continue On Failure   Check Loop Kpi  Manual RU SW upgrade downtime  ${OAM_KPI_TARGETS}
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Wait And Check Cells And Sw Version
    [Documentation]    Wait for cells to be disabled, wait for all cells to be up and check that radio software has been updated.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${RF_SW_VERSIONS}  ${STEP}
    ${only_some_radios}=  Get Variable Value   ${ADD_KPI55E}   ${False}
    IF  ${only_some_radios}
        Print Step Text                       ${STEP}.3
        ...                                   Wait until selected radios have updated their SW
        Run Keyword And Continue On Failure   Wait Until Given Radios Have Updated Sw
        ...                                   ${RF_SW_VERSIONS}  ${RADIOS_TO_UPDATE}  time_limit=${RU_SW_WAIT}
    ELSE
        Print Step Text                       ${STEP}.3
        ...                                   Wait until all radios have updated their SW
        Run Keyword And Continue On Failure   Wait Until All Radios Have Updated Sw
        ...                                   ${RF_SW_VERSIONS}  time_limit=${RU_SW_WAIT}
    END
    Print Step Text                       ${STEP}.4  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure   Wait Time And Reason  sleep_time=${WAIT_CHECKS}
    Print Step Text                       ${STEP}.5  Check that radio software has been update
    Run Keyword And Continue On Failure   Compare Radio Sw Versions  ${RF_SW_VERSIONS}   kpi55e=${only_some_radios}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RU SWDL With KPI55D
    [Documentation]    First do needed commissioning for KPI#55d - Independent sequential RUs SW upgrade duration. This
    ...                KPI measures independent sequential upgrade of all RUs using common BTS SW package during activation for RU SW only.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Set Suite Variable                    ${ADD_KPI55D}   ${True}
    Set Suite Variable                    ${KPI55d_test}  ${True}
    Run Keyword And Continue On Failure   Kpi55d Commissioning
    Run Keyword And Continue On Failure   OMKPI RF SW Update  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RU SWDL With KPI55E
    [Documentation]    First do needed commissioning for KPI#55e - Independent selective RUs SW upgrade duration. This
    ...                KPI measures independent sequential upgrade of selective RUs  group (low bands RUs only) using common
    ...                BTS SW package during activation for RU SW only.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RADIO_NAME}
    Set Suite Variable                    ${ADD_KPI55E}   ${True}
    ${RADIOS_TO_UPDATE}=                  Get Rmods Of Name   ${RADIO_NAME}
    Set Suite Variable                    ${RADIOS_TO_UPDATE}
    Run Keyword And Continue On Failure   Kpi55e Commissioning   ${RADIOS_TO_UPDATE}
    Run Keyword And Continue On Failure   OMKPI RF SW Update  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Special Builds RU SWDL
    [Documentation]    First do needed commissioning if there is ADD_KPI55D or ADD_KPI55E given as True. Then do RU SWDL using
    ...                special builds given by user in BUILD_N, BUILD_T1 and BUILD_T2 variables.
    ...                In this test case user gives manually paths to builds that are used in SWDLs.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ${suite_variables}=      Get variables
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background   ${SYSLOG_LIST}
#    Run Keyword And Continue On Failure    Check If Netboot Is Active And Deactivate It
    ${CHECK_CALIBRATION_FILES}=            Get Variable Value  ${CHECK_CALIBRATION_FILES}  ${False}
    ${calibration_files}=                  Create List  /mnt/factory/configs/unit/disable_tx_bf_calibration.txt
    ...                                                 /mnt/factory/configs/unit/disable_rx_bf_calibration.txt
    Run Keyword If    '${CHECK_CALIBRATION_FILES}' == '${True}'   Run Keyword And Continue On Failure
    ...                Check And Create File On Radio  radio=all  file_names=${calibration_files}
    IF  "\${ADD_KPI55D}" in $suite_variables
        Set Suite Variable  ${ADD_KPI55D}   ${True}
        Set Suite Variable  ${KPI55d_test}  ${True}
        Run Keyword And Continue On Failure   Kpi55d Commissioning
    ELSE IF    "\${ADD_KPI55E}" in $suite_variables
        Set Suite Variable  ${ADD_KPI55E}  ${True}
        IF  "\${RADIO_NAME}" not in $suite_variables
            Set Suite Variable  ${RADIO_NAME}   AHLOA
        END
        ${RADIOS_TO_UPDATE}=    Get Rmods Of Name   ${RADIO_NAME}
        Set Suite Variable      ${RADIOS_TO_UPDATE}
        Run Keyword And Continue On Failure   Kpi55e Commissioning   ${RADIOS_TO_UPDATE}
    END
    Run Keyword And Continue On Failure    Get Value Of Ru Phase Activation Reset Policy
# T1
    IF  "\${BUILD_T1}" in $suite_variables and "${BUILD_T1}" != "${EMPTY}"
        Run Keyword                            Check If Special SW Is Found  ${BUILD_T1}
        Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
        ...                                                                            ${BUILD_T1}  T1   Collect_KPI55
    END
# T2
    IF  "\${BUILD_T2}" in $suite_variables and "${BUILD_T2}" != "${EMPTY}"
        Run Keyword                            Check If Special SW Is Found  ${BUILD_T2}
        Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
        ...                                                                            ${BUILD_T2}  T2   Collect_KPI55
    END
# Normal build
    IF  "\${BUILD_N}" in $suite_variables and "${BUILD_N}" != "${EMPTY}"
        Run Keyword And Continue On Failure    Log Folders And Radio Software Update   ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${UNALLOWED_SYSLOGS}
        ...                                                                            ${BUILD_N}  Normal   Collect_KPI55
    END
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Set Suite Variable   ${LOGS_ALREADY_COLLECTED}   ${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
