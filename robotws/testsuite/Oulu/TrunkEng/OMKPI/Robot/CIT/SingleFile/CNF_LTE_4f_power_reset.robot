*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_power_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_4e_omkpi_target.py

*** Keywords ***
2_Automated_OAMKPI_Power_Reset
    ${WAIT_FOR_CELLS_UP}        Set Variable   500
    ${PB_WAIT}                  Set Variable   5      # seconds to wait between power off and on
    ${COLLECT_LOGS}             Set Variable   On failure  #Possible values are: On failure/Never/Always
    ${TEST_LOOPS}               Set Variable   10
    ${REFERENCE_TESTLINE}       Set Variable   CNF_LTE_4f
    ${REPORT}                   Set Variable   ${True}
    @{SYSLOG_LIST}=             Create List
    @{UNALLOWED_SYSLOGS}=       Create List    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
    ${WAIT_CHECKS}              Set Variable   90    # seconds, 0 if no waiting nor printing before post conditions check
    @{ALLOWED_ALARMS}=          Create List    4590

    [Documentation]  Perform power reset and collect KPI results.
    [Tags]           "Power reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${PB_WAIT}
        ...    ${OAM_KPI_TARGETS}
        ...    name=Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Power Reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}