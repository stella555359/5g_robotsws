*** Settings ***
Documentation    Test suite for overheating alarm verification of feature CB005758-F
...              authors: Marek Szlapa, Marcin Bereznicki
...              contact: marek.szlapa@nokia.com, marcin.bereznicki@nokia.com

Library          taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnb_alarms
Library          taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    gnb_ru
Library          ./resources/hub_keywords.py
Library          ./resources/asir_keywords.py
Resource         taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables        taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags       STATE_SW_UPLOADED    CRT    PY36

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${fault_name}    Failure detected on assigned antennas
@{asir_fault_ids}    ${1937}    ${1938}
@{CUSTOM_ALLOWED_ALARMS}    ${fault_name}   BTS Reset Cause

*** Test Cases ***
[1]CB005758-F_ASiR_diagnostic_and_serviceability_parity-gen1_or_gen2_pRRH_overheating_protection
    [Setup]       Run Keywords    Common Preconditions With Watching Alarms
    ...    AND    Verify and Back Up Hub Config
    Decrease Temperature Threshold
    asir_keywords.Reset Antenna
    Wait Until Keyword Succeeds    30sec    1sec    gnb_alarms.Verify Alarm Is Active    fault_name=${fault_name}
    Verify Any Alarm Is Active    fault_ids=@{asir_fault_ids}
    Restore Hub Config
    asir_keywords.Reset Antenna
    Wait Until Keyword Succeeds    30sec    1sec    gnb_alarms.Verify Alarm Is Not Active    fault_name=${fault_name}
    Verify Any Alarms Are Not Active    fault_ids=@{asir_fault_ids}
    [Teardown]    Run Keywords    Run Keyword If Test Failed    Restore Hub Config
    ...    AND    Run Keyword If Test Failed    asir_keywords.Reset Antenna
    ...    AND    Common Postconditions With Watching Alarms
