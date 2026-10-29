*** Settings ***

Documentation
...     Author:     Valtteri Lamberg
...     Contact:    I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library             Collections
Library             taf.sw.reporting_portal
Resource            testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library             testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiEnergyConsumption  WITH NAME  OmkpiEnergyConsumption
Resource            testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_energy_consumption.robot
Library             testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface  WITH NAME  OmkpiCommissioningInterface

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

Test Setup          Run Keywords  Common Test Setup
...                 AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown       Common Test Teardown

*** Variables ***
@{RMODS}                    RMOD-1    # List of RMODs to be checked separated by at least two spaces
${WAIT_FOR_CELLS_UP}        300
${COLLECT_LOGS}             On failure
${TEST_LOOPS}               1
${REFERENCE_TESTLINE}       ${EMPTY}
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${True}
@{SYSLOG_LIST}              Detected most recent reset type was  Failed to execute executable  RecoveryConstraints
                   ...      RecoveryActionController    Executing recovery action
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              180    # seconds, 0 if no waiting nor printing before post conditions check
# Optional limits
${M40002C0_LIMIT}           3000
${M40002C1_LIMIT}           3000
${M40002C2_LIMIT}           3000

*** Test Cases ***
Energy Consumption Measurement
    [Tags]  "Energy Consumption" -test loops: ${TEST_LOOPS}
    [Documentation]  Perform site reset and measure energy consumption
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    name=Commission Energy Consumption Parameters
        ...    test_case=1
        ...    loops=1
        ...    keywords=Commission Energy Consumption Parameters
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}

    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMODS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${REFERENCE_TESTLINE}
        ...    name=Energy Consumption
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Energy Consumption
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
