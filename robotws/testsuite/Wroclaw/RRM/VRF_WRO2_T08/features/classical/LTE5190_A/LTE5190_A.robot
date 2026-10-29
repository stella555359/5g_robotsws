*** Settings ***
Documentation
...   maintainer: Marta Hendler
...   contact: marta.hendler@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/LTE5190_A/resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2

Suite Setup  Run Keywords  Prepare Testline  AND  ADB Reboot UE

*** Test Cases ***
[1]LTE5190_A_001_ENB_Receives_Partial_Reset_Required_From_EN_GNB
    [Documentation]   This test case checks if the UE falls back to LTE cell when a block is performed on NRCELL.
    ...               Then it checks if UE attaches back to the NRCELL after it's unblocked.

    [Setup]   Test Setup
    [1]LTE5190_A_001_ENB_Receives_Partial_Reset_Required_From_EN_GNB
    [Teardown]   Test Teardown
