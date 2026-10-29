*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

...   To this file we have collected all test keywords that are needed to tests that are done for SOC of BBMOD.

...   BBMOD hw type and primary and secondary SOCs:
...     BBMOD hw type: ABIA, Primary Soc: K2A, Secondary SOCs: K2B, K2C, K2D
...     BBMOD hw type: ABIO, Primary Soc: SNF, Secondary SOCs: LOKI#A, LOKI#B
...     BBMOD hw type: ABIN, Primary Soc: SNF, Secondary SOCs: LOKI#A
...     BBMOD hw type: ABIC, Primary Soc: LFA, Secondary SOCs: LFB, LUNUM
...     BBMOD hw type: ABIP, Primary Soc: Marlin, Secondary SOCs: Thor
...     BBMOD hw type: ABIQ, Primary Soc: Marlin, Secondary SOCs: Magni
...     BBMOD hw type: ABIL, Primary Soc: XEONA, Secondary SOCs: XEONB, LONER

...    Applications running on non virtual nodes of BBMOD:
...     ABIA:
...         FaultServiceExe, CRMexe

...    Applications running on virtual nodes of BBMOD:
...      ABIA:
...         FDDMACNODE: CCSEmDispatcherExe
...      ABIN/O/P:
...         FDDMACNODE: CCSEmDispatcherExe
...         LTEL2NODE: CCSEmDispatcherExe
...         D_CPNODE: FaultServiceExe, CellCExe, UECexe
...         CRMNODE: CRMexe


Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/unit_state_check_kws.robot


*** Keywords ***
Kill application from primary SoC and expect Baseband card autonomous reset
    [Documentation]  This KW kills application from primary SOC of BBMOD and expects Baseband card autonomous reset.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              BBMOD can be for example ABIA1 and SOC for example K2A and application for example FaultServiceExe
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${STEP}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get Bbmod Object From User Given Values  ${UNIT}
    ${CELLS_OF_BBMOD}=                   Get Cells Of Bbmod  ${BBMOD_OBJ.name}
    Run Keyword If                       '${SOC}' == '${EMPTY}'  Set Suite Variable  ${SOC}  ${BBMOD_OBJ.primary_soc}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=2087
                        ...              fault_name=Baseband card autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Check If 4019 Should Be Expected Bbmod Alarm  ${BBMOD_OBJ}  ${APPLICATION}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    # check if fhs in environment and if is then add as allowed alarm
    ${FHS_10_as_allowed}=                Check If Fault 10 Should Be Allowed To FHS
    Print Step Text                      ${STEP}.2  Fault is generated and ${BBMOD_OBJ.name} (${SOC}) Warm recovery reset is executed
    Run Keyword And Continue On Failure  Kill Real Application From SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
    Print Text To Eventlog               Wait for autonomous reset to occur and that mapped cells of tested FSP are disabled
    Run Keyword And Continue On Failure  Wait For Cells Faulty  300  ${CELLS_OF_BBMOD}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Run Keyword And Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions
    # remove allowed allowed fhs alarm if it was added and check active alarms
    IF   ${FHS_10_as_allowed}
        Run Keyword And Continue On Failure    Remove Allowed Alarm   fault_id=10   fault_name=No connection to unit
        Run Keyword And Continue On Failure    Check Active Alarms    test_step_txt=after allowed 10 fault is removed
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from primary SoC and expect Baseband card power autonomous reset
    [Documentation]  This KW is created to add one step before shtdown due to PR804929.
    ...              This KW kills application from primary SOC of BBMOD and expects Baseband card power autonomous reset.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              BBMOD can be for example ABIA1 and SOC for example K2A and application for example FaultServiceExe
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${STEP}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get Bbmod Object From User Given Values  ${UNIT}
    ${CELLS_OF_BBMOD}=                   Get Cells Of Bbmod  ${BBMOD_OBJ.name}
    Run Keyword If                       '${SOC}' == '${EMPTY}'  Set Suite Variable  ${SOC}  ${BBMOD_OBJ.primary_soc}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=2087
                        ...              fault_name=Baseband card power autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Check If 4019 Should Be Expected Bbmod Alarm  ${BBMOD_OBJ}  ${APPLICATION}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      ${STEP}.2  Fault is generated and ${BBMOD_OBJ.name} (${SOC}) Warm recovery reset is executed
    Run Keyword And Continue On Failure  Kill Real Application From SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
    Print Text To Eventlog               Wait for autonomous reset to occur and that mapped cells of tested FSP are disabled
    Run Keyword And Continue On Failure  Wait For Cells Faulty  300  ${CELLS_OF_BBMOD}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Run Keyword And Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}


Kill CCSDaemon from BBMOD then make SoC and BBMOD reset
    [Documentation]  This KW kills CCSDaemonExe from BBMOD and expects SOC autonomous reset and Baseband card autonomous reset.
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${STEP}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get Bbmod Object From User Given Values  ${UNIT}
    ${CELLS_OF_BBMOD}=                   Get Cells Of Bbmod  ${BBMOD_OBJ.name}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=4019 / 6292
                        ...              fault_name=Baseband card autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm  severity=Warning  alarm_id=7101  fault_id=4019
                        ...              fault_name=SoC autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      ${STEP}.2  Fault is generated and ${BBMOD_OBJ.name} (${SOC}) SOC & BBMOD resets are executed
    Run Keyword And Continue On Failure  Kill Real Application From SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
    Print Text To Eventlog               Wait for autonomous reset to occur
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Run Keyword And Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                      ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill CCSEmDispatcher From BBMOD and expect internal BTS reset
    [Documentation]  This KW kills CCSEmDispatcher from BBM OD and expects Internal BTS processes autonomous reset as recovery action.
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${UNIT}     ${STEP}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase   ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values    ${UNIT}
    ${CELLS_OF_BBMOD}=                   Get Cells Of BBMOD  ${BBMOD_OBJ.name}
    Run Keyword And Continue On Failure  Check Rmod Uptimes
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=4383
                        ...              fault_name=Internal BTS processes autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      ${STEP}.2  Fault is generated and ${BBMOD_OBJ.name}  Internal BTS reset is executed
    Run Keyword And Continue On Failure  Kill CCSEmDispatcherExe From BBMOD    ${BBMOD_OBJ}
    Print Text To Eventlog               Wait for autonomous reset to occur
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Run Keyword And Continue On Failure  Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check Rmod Uptimes
    Print Step Text                      ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from primary SoC and wait for active alarm and faulty BBMOD
    [Documentation]  This KW kills application from primary SOC of BBMOD and expects alarm Critical SW Component failure to be active
    ...              and 10 alarm to all radios connected to faulted BBMOD unit.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              BBMOD can be for example ABIA1 and SOC for example K2A and application for example FaultServiceExe.
    [Arguments]      ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${STEP}  ${WAIT_CHECKS}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase   ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values  ${UNIT}
    ${cells_of_bbmod}=                   Get Cells Of BBMOD  ${BBMOD_OBJ.name}
    Run Keyword If  '${SOC}' == '${EMPTY}'  Set Suite Variable  ${SOC}  ${BBMOD_OBJ.primary_soc}
    ${bbmod_alarm_id}=                   Get Alarm Id Based On Cell Resources On Bbmod  ${BBMOD_OBJ.name}  ${CELLS_OF_BBMOD}
    ${radios_of_bbmod}=                  Get RMODs Connected to BBMOD  ${BBMOD_OBJ.name}
    Run Keyword And Continue On Failure  Add Expected Alarm  alarm_id=${bbmod_alarm_id}  fault_id=2087
                        ...              fault_name=Critical SW Component failure
                        ...              unit_path=${BBMOD_OBJ.unit_path}
                        ...              hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios  ${radios_of_bbmod}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      ${STEP}.2   Fault is generated and ${BBMOD_OBJ.name} Shutdown is executed
    Run Keyword And Continue On Failure  Kill Real Application From SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
    Print Text To Eventlog               Wait for alarm to occur
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                      ${STEP}.3  Check states of cells, radios, BBMODs and SMOD
    Run Keyword And Continue On Failure  Check if affected cells disabled  ${cells_of_bbmod}
    Run Keyword And Continue On Failure  Check if affected radios disabled  ${radios_of_bbmod}
    @{bbmod_list}=                       Create List    ${BBMOD_OBJ.name}
    Run Keyword And Continue On Failure  Check if affected BBMODs disabled  ${bbmod_list}
    ${bts_state}=                        Get Expected BTS State  ${cells_of_bbmod}
    Run Keyword And Continue On Failure  Check BTS State    ${bts_state}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from secondary SoC and expect only SoC autonomous reset
    [Documentation]  This KW kills application from secondary SOC of BBMOD and expects SoC autonomous reset as recovery action.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              BBMOD can be for example ABIA1 and SOC for example K2C and application for example FaultServiceExe
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}    ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values    ${UNIT}
    ${CELLS_OF_SOC}=                     Get Cells Of SoC    ${BBMOD_OBJ.name}    ${SOC}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=2087
                        ...              fault_name=SoC autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}
                        ...              hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure  Check Rmod Uptimes
    Print Step Text                      ${STEP}.2  Fault is generated to ${BBMOD_OBJ.name} ${SOC} and soc recovery reset is executed
    Run Keyword And Continue On Failure  Kill Application From Secondary SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Run Keyword And Continue On Failure  Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Check Rmod Uptimes
    Print Step Text                      ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}


Kill application from secondary SoC and expect SoC autonomous reset
    [Documentation]  This KW kills application from secondary SOC of BBMOD and expects SoC autonomous reset as recovery action.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              BBMOD can be for example ABIA1 and SOC for example K2C and application for example FaultServiceExe
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}    ${STEP}
    Print Step Text                      ${STEP}.1  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get Bbmod Object From User Given Values    ${UNIT}
    ${CELLS_OF_SOC}=                     Get Cells Of Soc    ${BBMOD_OBJ.name}    ${SOC}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=2087
                        ...              fault_name=SoC autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=4341
                        ...              fault_name=DSP group autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      ${STEP}.2  Fault is generated to ${BBMOD_OBJ.name} ${SOC} and soc recovery reset is executed
    Run Keyword And Continue On Failure  Kill Real Application From SoC  ${BBMOD_OBJ}  ${SOC}  ${APPLICATION}
#    Print Text To Eventlog   Wait for SOC autonomous reset and if there are mapped cells on tested SOC, that they are disabled.
## if there is no cells on selected soc, do not wait for faulty cells
#    Run Keyword And Continue On Failure    Wait For Cells Faulty    300    ${CELLS_OF_SOC}
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Print Step Text                        ${STEP}.3  Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}


Kill application from primary SoC until alarm is active
    [Documentation]  This KW kills application from primary SOC of BBMOD. It expects three times Baseband card autonomous reset,
    ...              once Baseband card power autonomous reset due to PR804929 and after fifth application kill,
    ...              that alarm 'Critical SW Component failure'
    ...              is active and 10 alarms are also active to all radios that are connected to faulted BBMOD unit.

    ...              NOTE with this KW, application cannot be started on virtual node and selected SOC needs to be primary SOC.
    ...              NOTE this KW can be run only in environments where are more than one BBMOD. Also all cell resources
    ...              cannot be on tested BBMOD. These restrictions are because if all cell resources are down site reset
    ...              is executed instead of activating alarm.

    ...              Primary SOCs: K2A, SNF, LFA, Marlin, XEONA
    ...              BBMOD can be for example ABIA1 and SOC for example K2A and application for example FaultServiceExe.
    ...              More possible selections for this KW you can find from the beginning of this file
    ...              (testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot).

    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
    ...          ${WAIT_FOR_RECO_COUNTER_CLEAR}    ${WAIT_CHECKS}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Baseband card autonomous reset as recovery action x3
    FOR    ${index}    IN RANGE    1    4
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Kill application from primary SoC and expect Baseband card autonomous reset
            ...     ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${index}
    END
# Baseband card power autonomous reset as recovery action x1
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Kill application from primary SoC and expect Baseband card power autonomous reset
        ...     ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${index}
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Kill application from primary SoC and wait for active alarm and faulty BBMOD
        ...     ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${10}    ${WAIT_CHECKS}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from primary SoC and expect BBMOD reset
    [Documentation]  This KW kills application from primary SOC of BBMOD. It expects Baseband card autonomous reset.
    ...              NOTE with this KW, application cannot be started on virtual node and selected SOC needs to be primary SOC.

    ...              Primary SOCs: K2A, SNF, LFA, Marlin, XEONA
    ...              BBMOD can be for example ABIA1 and SOC for example K2A and application for example FaultServiceExe.
    ...              More possible selections for this KW you can find from the beginning of this file
    ...              (testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot).
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
    ...          ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Baseband card autonomous reset as recovery action x1
    Run Keyword And Continue On Failure    Kill application from primary SoC and expect Baseband card autonomous reset
            ...     ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${1}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${2}
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from secondary SoC and expect SoC reset
    [Documentation]  This KW kills application from secondary SOC of BBMOD. It expects SoC autonomous reset as recovery action.
    ...              NOTE with this KW, application cannot be started on virtual node and selected SOC needs to be secondary SOC.

    ...              Secondary SOCs: K2B, K2C, K2D, LOKI#A, LOKI#B, LFB, LUNUM, Thor, XEONB, LONER
    ...              BBMOD can be for example ABIA1 and SOC for example K2B and application for example FaultServiceExe.
    ...              More possible selections for this KW you can find from the beginning of this file
    ...              (testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot).
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
    ...          ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Baseband card autonomous reset as recovery action x1
    Run Keyword And Continue On Failure    Kill application from secondary SoC and expect SoC autonomous reset
            ...     ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${1}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${2}
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from secondary SoC and expect only SoC reset
    [Documentation]  This KW kills application from secondary SOC of BBMOD. It expects SoC autonomous reset as recovery action.
    ...              NOTE with this KW, application cannot be started on virtual node and selected SOC needs to be secondary SOC.

    ...              Secondary SOCs: K2B, K2C, K2D, LOKI#A, LOKI#B, LFB, LUNUM, Thor, XEONB, LONER
    ...              BBMOD can be for example ABIA1 and SOC for example K2B and application for example FaultServiceExe.
    ...              More possible selections for this KW you can find from the beginning of this file
    ...              (testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot).
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
    ...          ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Baseband card autonomous reset as recovery action x1
    Run Keyword And Continue On Failure    Kill application from secondary SoC and expect only SoC autonomous reset
            ...     ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${1}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${2}
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Command To Container Of Bbmod Soc
    [Documentation]  This KW  give command to container of BBMOD SOC
    [Arguments]      ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}
    ...              ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure  Common Preconditions
    ${BBMOD_OBJ}=                        Get BBMOD Object From User Given Values    ${UNIT}
    ${CELLS_OF_BBMOD}=                   Get Cells Of BBMOD  ${BBMOD_OBJ.name}
    ${RIGHT_SIDE}=                       Smod Is On Right Side Of Rack
    Run Keyword And Continue On Failure  Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=4383
                        ...              fault_name=Internal BTS processes autonomous reset as recovery action
                        ...              unit_path=${BBMOD_OBJ.unit_path}  hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    Print Step Text                      2  Give command ${COMMAND} to container ${CONTAINER} of ${BBMOD_OBJ.name}  automatic=${True}
    Run Keyword And Continue On Failure  Ssh To Bbmod Soc Lxc Attach Container And Command
    ...                                  ${BBMOD_OBJ}   soc=${SOC}   container=${CONTAINER}   command=${COMMAND}   right_smod=${RIGHT_SIDE}
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Wait Time and Reason                 15  Wait before checking cells
    Run Keyword And Continue On Failure  Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time and Reason                 ${WAIT}  before checking post conditions
    Print Step Text                      3  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
