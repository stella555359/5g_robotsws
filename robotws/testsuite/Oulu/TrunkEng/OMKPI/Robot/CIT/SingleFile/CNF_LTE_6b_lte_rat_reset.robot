*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rat_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_6b_omkpi_targets.py

*** Keywords ***
6_LTE_RAT_Reset
    ${RAT_TO_RESET}              Set Variable    LTE
    ${RESET_TYPE}               Set Variable    Soft
    ${KPI}                      Set Variable    KPI#7
    ${WAIT_FOR_CELLS_UP}        Set Variable    800
    ${REPORT}                   Set Variable    ${True}
    ${WAIT_CHECKS}              Set Variable    60
    ${COLLECT_LOGS}             Set Variable    On failure
    # Collect logs variable. Possible values are: On failure/Never/Always
    ${TEST_LOOPS}               Set Variable    10
    ${REFERENCE_TESTLINE}       Set Variable    CNF_LTE_6b
    @{SYSLOG_LIST}=             Create List
    @{UNALLOWED_SYSLOGS}=       Create List     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

    [Documentation]  Reset user given RAT and checks alarms and cell states.
    [Tags]    "RAT reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    ...    ${RAT_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RESET_TYPE}  ${KPI}
    ...    name=Reset RAT
    ...    test_case=1
    ...    loops=${TEST_LOOPS}
    ...    keywords=RAT Reset
    ...    expected_pass_rate=1
    ...    collect_test_logs=${COLLECT_LOGS}
    ...    omkpi_case=${True}