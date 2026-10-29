*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_4e_omkpi_target.py

*** Keywords ***
3_Automated_OAMKPI_Site_Reset
    ${WAIT_FOR_CELLS_UP}        Set Variable    450
    ${COLLECT_LOGS}             Set Variable    Always  #Possible values are: On failure/Never/Always
    # How many times test will be run, needs to be more than 0
    ${TEST_LOOPS}               Set Variable    10
    ${REFERENCE_TESTLINE}       Set Variable    CNF_LTE_4f
    ${REPORT}                   Set Variable    ${True}
    @{SYSLOG_LIST}=             Create List
    @{UNALLOWED_SYSLOGS}=       Create List     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
    ${WAIT_CHECKS}              Set Variable    90    # seconds, 0 if no waiting nor printing before post conditions check
    @{ALLOWED_ALARMS}=          Create List

    [Documentation]  Perform site reset and collect KPI results.
    [Tags]           "Site reset" -test loops: ${TEST_LOOPS}
     Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Site Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Site reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}