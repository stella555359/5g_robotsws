*** Settings ***
Documentation
...   Test Suite for testing CB009469 feature
...   author: Aleksander Gospodarczyk, Natalia Czech, Bartosz Odziomek
...   contact: aleksander.gospodarczyk@nokia.com, natalia.czech@nokia.com, bartosz.odziomek@nokia.com


Resource             testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB009469/resources/keywords.robot


Suite Setup          keywords.Test Suite Setup
Suite Teardown       Common Suite Teardown
Test Setup           Common Preconditions With Watching Alarms
Test Teardown        Common Postconditions With Watching Alarms


*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}        No X2 link available
...                             Diagnostic Files collected
...                             BTS Reset Cause
...                             Sanity Check Error
...                             Radio Diagnostic Files collected
@{CRITICAL_FAULTS}              0010  0016  1806  1868  4341  4352  4383
${MUMIN_CONFIG_FILE}=           /home/ute/auto/testline_configuration/7_7_UTE5GCLOUDT084/mumin.yaml
*** Test Cases ***

General_SiSo_Commissioning_BTS_Recommissioning
    keywords.02_Re-Commissioning_via_WebEM
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir

General_SiSo_RU_lock_unlock
    General SiSo Auto RF Lock Unlock

General_SiSo_RU_module_reset_from_GUI
    General SiSo Auto RF module reset from WebUI

General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock

General_SiSo_BTS_reset_with_RF_power_reset
    [Setup]    Test Setup With Watching Alarms
    General SiSo BTS reset with RF power reset
