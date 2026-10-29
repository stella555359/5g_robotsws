*** Settings ***
Force Tags          CLOUD_FR4_ASOH_[11]_[AHEH_AHEH]

Documentation
...   Author:       Heikki Autio
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

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
@{RMODS}                    RMOD-1  RMOD-2    # List of RMODs to be checked separated by at least two spaces
${WAIT_FOR_CELLS_UP}        600
${COLLECT_LOGS}             Always
${TEST_LOOPS}               1
${REFERENCE_TESTLINE}       CNF_LTE_16
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${False}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              90    # seconds, 0 if no waiting nor printing before post conditions check

*** Test Cases ***
Automated_OAMKPI_Energy_Consumption_Measurements
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
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Energy Consumption
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
