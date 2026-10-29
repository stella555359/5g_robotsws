*** Settings ***
Documentation
...   author: Piotr Frydrych
...   maintainer: Piotr Frydrych
...   contact: piotr.frydrych@nokia.com
...   Description: Test Cases for CB012346 feature


Resource    ./resources/CB012346_keywords.robot

Force Tags    CA_VRF_KRK    RF50

Suite Setup          Suite Setup
Suite Teardown       Common Suite Teardown
Test Setup           Common Preconditions
Test Teardown        Common Postconditions

*** Test Cases ***
CB012346_TC08_Manual_cells_to_baseband_modules_configuration_NOT_align_with_portsMappingToPort1234_Strict
    [Teardown]    Test Teardown with cells disabled
    Perform Delta Commissioning And Expect Validation Error    ${strict_mode_parameters}
    Perform Delta Commissioning With Validation Error    ${strict_mode_parameters}

CB012346_TC09_Manual_cells_to_baseband_modules_configuration_NOT_align_with_portsMappingToPort1234_reconfig_Strict
    [Setup]   Test Setup with cells disabled
    Perform Delta Commissioning On gNB    delta=${ports_mapping_fixed_parameters}
    Wait until keyword succeeds    60 sec    15 sec    gnbcell.Verify All Cells Are Onair

CB012346_TC08_Manual_cells_to_baseband_modules_configuration_NOT_align_with_portsMappingToPort1234_Override
    Perform Delta Commissioning And Expect Validation Error    ${override_mode_parameters}
    Perform Delta Commissioning With Validation Error    ${override_mode_parameters}
    Wait until keyword succeeds    60 sec    15 sec    gnbcell.Verify All Cells Are Onair

CB012346_TC09_Manual_cells_to_baseband_modules_configuration_NOT_align_with_portsMappingToPort1234_reconfig_Override
    Perform Delta Commissioning On gNB    delta=${ports_mapping_fixed_parameters}
    Wait until keyword succeeds    60 sec    15 sec    gnbcell.Verify All Cells Are Onair
