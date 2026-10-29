*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rat_reset.robot
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

*** Keywords ***
rat_reset_10b_5G


    ${WAIT_FOR_CELLS_UP}    Set Variable    300
    ${REPORT}               Set Variable    ${True}
	${RAT_TO_RESET}         Set Variable	NR
	${RESET_TYPE}           Set Variable	Hard
	${KPI}					Set Variable	KPI#10b
    @{SYSLOG_LIST}=         Create List
    @{UNALLOWED_SYSLOGS}=   Create List     4 (ERPresetTypeSpuriousReset)   14 (ERPresetTypeSpuriousResetBts)
    ${WAIT_CHECKS}          Set Variable    90    # seconds, 0 if no waiting nor printing before post conditions check
    ${COLLECT_LOGS}         Set Variable    Always  # Possible values are: On failure/Never/Always
    ${TEST_LOOPS}           Set Variable    10
    ${REFERENCE_TESTLINE}   Set Variable    CNF_RFS_2
	${MASTER}               Set Variable	This
	${ZIP_LOGS}             Set Variable	${True}
	@{ALLOWED_ALARMS_LIST}=   Create List   7107

    [Documentation]  Reset user given RAT and checks alarms and cell states.
    [Tags]           "RAT reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RAT_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RESET_TYPE}  ${KPI}
        ...    name=Reset RAT
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=RAT Reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}


