*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_remote_power_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_6b_omkpi_targets.py

*** Keywords ***
5_Remote_Power_Reset
    ${WAIT_FOR_CELLS_UP}        Set Variable    1200
    ${REPORT}                   Set Variable    ${True}
    ${WAIT_CHECKS}              Set Variable    90
    ${COLLECT_LOGS}             Set Variable    On failure
    # Collect logs variable. Possible values are: On failure/Never/Always
    ${TEST_LOOPS}               Set Variable    10
    ${REFERENCE_TESTLINE}       Set Variable    CNF_LTE_6b
    @{SYSLOG_LIST}=             Create List
    @{UNALLOWED_SYSLOGS}=       Create List     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

    [Documentation]  Perform remote power reset and collect KPI results.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${RESET_WITH_SNAPSHOT}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Remote Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Remote power reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}