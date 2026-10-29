*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010627 (AWHQC support for BW 50MHz)
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Resource    ./resources/CB010627_keywords.robot

Force Tags    STATE_SW_UPLOADED    CRT    PY36

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
Suite Teardown      Common Suite Teardown

*** Test Cases ***
[1][1.0] CB010627-01_ASiR-pRRH_discovery_by_ASiR-sHUB
    [Setup]     TC01 test setup
    Enable PoE for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1
    Wait for Cell-0 to be onair
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2
    Verify if Cell-1 is disabled
    Enable PoE for AWHQC-2
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2
    Wait for Cell-1 to be onair
    [Teardown]  TC01 test teardown

[1][1.0] CB010627-02_ASiR-pRRH_discovery_by_ASiR-sHUB_supercell
    [Setup]     TC02 test setup
    Enable PoE for AWHQC-1 (supercell)
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2 (supercell)
    Verify if Cell-0 is disabled
    Enable PoE for AWHQC-2 (supercell)
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2 (supercell)
    Wait for Cell-0 to be onair
    [Teardown]  TC02 test teardown

[1][1.0] CB010627-03_TDD FR1_50Mhz_configuration
    [Setup]     TC03 test setup
    Load Config1 for BTS and ASiR and wait for onair
    Perform L3 call on Cell-0
    Perform L3 call on Cell-1
    [Teardown]  TC03 test teardown

[1][1.0] CB010627-04_TDD FR1_50Mhz_configuration_supercell
    [Setup]     TC04 test setup
    Load Config2 for BTS and ASiR and wait for onair
    Perform L3 call on Cell-0 (supercell)
    [Teardown]  Common Postconditions with watching alarms
