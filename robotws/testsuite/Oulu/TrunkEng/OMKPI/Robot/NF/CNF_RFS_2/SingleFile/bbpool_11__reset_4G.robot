*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rat_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

*** Keywords ***
bbpool_11_reset_4G


    ${WAIT_FOR_CELLS_UP}    Set Variable    300
    ${REPORT}               Set Variable    ${True}
	${BBPOOL_TO_RESET}      Set Variable	BBPool11
    @{SYSLOG_LIST}=         Create List
    @{UNALLOWED_SYSLOGS}=   Create List     4 (ERPresetTypeSpuriousReset)   14 (ERPresetTypeSpuriousResetBts)
    ${WAIT_CHECKS}          Set Variable    90    # seconds, 0 if no waiting nor printing before post conditions check
    ${COLLECT_LOGS}         Set Variable    Always  # Possible values are: On failure/Never/Always
    ${TEST_LOOPS}           Set Variable    10
    ${REFERENCE_TESTLINE}   Set Variable    CNF_RFS_2
	${MASTER}               Set Variable	Other
	${ZIP_LOGS}             Set Variable	${True}
	@{ALLOWED_ALARMS_LIST}=   Create List   1815  10

Automated_OAMKPI_Baseband_Pool_Reset
    [Documentation]  Reset user given BBPool and checks alarms and cell states.
    [Tags]    "Bbpool reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBPOOL_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset BBPool
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBPool
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}



