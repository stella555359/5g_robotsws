*** Settings ***

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_bbpool_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_4d_omkpi_targets.py

*** Keywords ***
5_Automated_OAMKPI_Baseband_Pool_Reset
    ${BBPOOL_TO_RESET}             Set Variable    BBPool12
    ${WAIT_FOR_CELLS_UP}        Set Variable    120
    ${REPORT}                   Set Variable    ${True}
    ${WAIT_CHECKS}              Set Variable    60
    ${COLLECT_LOGS}             Set Variable    On failure
    # Collect logs variable. Possible values are: On failure/Never/Always
    ${TEST_LOOPS}               Set Variable    10
    ${REFERENCE_TESTLINE}       Set Variable    CNF_LTE_4d
    @{SYSLOG_LIST}=             Create List
    @{UNALLOWED_SYSLOGS}=       Create List     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

    [Documentation]  Reset user given BBPool and checks alarms and cell states.
    [Tags]           "Bbpool reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBPOOL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset BBPool
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBPool
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}