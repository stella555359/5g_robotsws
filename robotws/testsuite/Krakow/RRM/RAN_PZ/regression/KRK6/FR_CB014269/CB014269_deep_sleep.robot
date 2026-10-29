*** Settings ***
Documentation     Verification suite for waking up radio from deep sleep state
...               maintainer: dawid.dabrowski@nokia.com

Resource          ./resources/suite_specific_keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Variables ***
${RMOD1}          MRBTS-85025/EQM-1/APEQM-1/RMOD-1
${RMOD2}          MRBTS-85025/EQM-1/APEQM-1/RMOD-3

*** Test Cases ***
CB014269_General_SiSo_Deep_Sleep_Mode_for_Energy_Efficiency_enhancement
    Configure Power Meter
    ${normal_power}=         Get Power Usage On RUs
    Enable Deep Sleep        ${RMOD1}
    Enable Deep Sleep        ${RMOD2}
    Lock Cells And Wait For SLEEP State On RMODs
    ${deep_sleep_power}=     Get Power Usage On RUs
    Unlock Cells And Wait For AWAKE State On RMODs
    Validate Power Usage Change
    ...    start_power_usage=${normal_power}
    ...    end_power_usage=${deep_sleep_power}
    ...    expected_change_type=reduction
    ...    expected_change_percent=50
