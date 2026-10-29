*** Settings ***
Documentation
...     Author:   Valtteri Lamberg
...     Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library           taf.sw.reporting_portal
Library           Collections
Library           String
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_radio_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
&{COMMISSIONING_LTE441-A_PARAMETERS}   txPathFailureMode=keepCellInService
                                 ...   dlMimoMode=Dynamic Open Loop MIMO
                                 ...   syncSigTxMode=TxDiv
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${False}
${KPI}                  A/B       # A/B or C
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
# NOTE also regex can be used
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          90    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
Automated_OAMKPI_RU_succession_reset
    [Documentation]  Reset all radios in succession and checks alarms and cell states.
    [Tags]           "Radio reset" -test loops: ${TEST_LOOPS}

    Run Keyword If      '${KPI}' == 'C'
        ...    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_LTE441-A_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

    @{RMOD_LIST}=    Get All Radios    multifibre_radios=${False}
    FOR    ${INDEX}    ${RMOD}    IN ENUMERATE    @{RMOD_LIST}
        ${SAFE_RMOD}=    Replace String    ${RMOD}    ${SPACE}    _
        ${SAFE_RMOD}=    Replace String    ${SAFE_RMOD}    :    _
        ${SAFE_RMOD}=    Replace String    ${SAFE_RMOD}    (    _
        ${SAFE_RMOD}=    Replace String    ${SAFE_RMOD}    )    _
        ${DIR_PATH}=     Set Variable      ${INDEX + 1}_${SAFE_RMOD}
        Run Keyword And Continue On Failure    Run Keyword In Loop And Return Pass Rate
        ...    ${KPI}    ${WAIT_FOR_CELLS_UP}    ${WAIT_CHECKS}    ${SYSLOG_LIST}    ${UNALLOWED_SYSLOGS}
        ...    ${COMMISSIONING_LTE441-A_PARAMETERS}    ${RMOD}
        ...    name=Reset All Radios In Succession
        ...    test_case=${DIR_PATH}
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset all radios in succession
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
    END
