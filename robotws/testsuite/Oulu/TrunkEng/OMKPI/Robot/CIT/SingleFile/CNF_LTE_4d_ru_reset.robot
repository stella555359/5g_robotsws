*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_radio_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_4d_omkpi_targets.py

*** Keywords ***
4_Automated_OAMKPI_RU_Reset
    &{COMMISSIONIN_LTE441-A_PARAMETERS}=  Create Dictionary  dlMimoMode  Dynamic Open Loop MIMO
    Set To Dictionary  ${COMMISSIONIN_LTE441-A_PARAMETERS}  txPathFailureMode  keepCellInService
    Set To Dictionary  ${COMMISSIONIN_LTE441-A_PARAMETERS}  syncSigTxMode  TxDiv

    ${WAIT_FOR_CELLS_UP}    Set Variable    300
    ${REPORT}               Set Variable        ${True}
    ${RMOD_TO_RESET}        Set Variable    RMOD-1
    ${KPI}                  Set Variable    A/B       # A/B or C
    @{SYSLOG_LIST}=         Create List
    @{UNALLOWED_SYSLOGS}=   Create List     13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                                        ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
    ${WAIT_CHECKS}          Set Variable    10    # seconds, 0 if no waiting nor printing before post conditions check
    ${COLLECT_LOGS}         Set Variable    On failure  # Possible values are: On failure/Never/Always
    ${TEST_LOOPS}           Set Variable    10
    ${REFERENCE_TESTLINE}   Set Variable    CNF_LTE_4d

    [Documentation]  Reset user given radio and checks alarms and cell states.
    [Tags]           "Radio reset" -test loops: ${TEST_LOOPS}
    Run Keyword If   '${KPI}' == 'C'
        ...    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_LTE441-A_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_RESET}  ${KPI}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset radio
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
