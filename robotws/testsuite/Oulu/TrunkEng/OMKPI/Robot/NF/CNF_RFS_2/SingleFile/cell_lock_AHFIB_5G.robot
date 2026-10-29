*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_cell_lock_unlock.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

*** Keywords ***
cell_lock_AHFIB_5G

    ${WAIT_FOR_CELLS_UP}    Set Variable    100
    ${REPORT}               Set Variable    ${True}
	${CELL_TO_LOCK}         Set Variable     1   # AHFIB
	${USED_RAT}             Set Variable	NR
    @{SYSLOG_LIST}=         Create List
    @{UNALLOWED_SYSLOGS}=   Create List     4 (ERPresetTypeSpuriousReset)   14 (ERPresetTypeSpuriousResetBts)
    ${WAIT_CHECKS}          Set Variable    90    # seconds, 0 if no waiting nor printing before post conditions check
    ${COLLECT_LOGS}         Set Variable    Always  # Possible values are: On failure/Never/Always
    ${TEST_LOOPS}           Set Variable    10
    ${REFERENCE_TESTLINE}   Set Variable    CNF_RFS_2
	${MASTER}               Set Variable	This
	${ZIP_LOGS}             Set Variable	${True}

    [Documentation]  Locks and unlocks cell. Checks KPI values.
    [Tags]           "Cell lock/unlock" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CELL_TO_LOCK}  ${USED_RAT}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Cell lock unlock
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Cell lock and unlock
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}



