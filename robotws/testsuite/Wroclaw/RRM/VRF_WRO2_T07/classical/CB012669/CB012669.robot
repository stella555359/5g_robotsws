*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the TESTSUITE file for feature CB009142


Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012669/resources/keywords_669.robot


Suite Setup      Initialise Attenuator

Test Setup       Run Keywords
...              Nullify attenuation on all ports

Test Teardown    Run Keywords
...              Nullify attenuation on all ports                  AND
...              Detach UE  UE_1



*** Test Cases ***

CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz
    [Documentation]   The purpose of this TC is
    CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz

CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz_pooling_off
    [Documentation]   The purpose of this TC is
    CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz_pooling_off
