*** Settings ***
Documentation
...    author: Michal Halucha
...    contact: michal.halucha@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB006877/resources/test_specific_keywords.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB006877/resources/test_constants.py


*** Variables ***
${LOG_PATH}    ${OUTPUT DIR}

*** Test Cases ***
CB006877_part_A_TC01_CB006877_Dynamic_UL_resource_allocation_in_FDD_cells_feature_activation
    [Setup]   Setup
    Set Cell Attenuation    20MHZ    0
    Verify Feature    20MHz_feature_disabled    ${feature_disabled_20MHz}
    Setup Vdu Parameters    20MHz    true
    Sleep    45s
    Verify Feature    20MHz_feature_enabled    ${feature_enabled_20MHz}
    Set Cell Attenuation    20MHZ    90
    Set Cell Attenuation    15MHZ    0
    Verify Feature    15MHz_feature_disabled    ${feature_disabled_15MHz}
    Setup Vdu Parameters   15MHz    true
    Sleep    45s
    Verify Feature    15MHz_feature_enabled    ${feature_enabled_15MHz}
    Set Cell Attenuation    15MHZ    90
    [Teardown]   Run Keywords
    ...          Trigger Detach
    ...          Turn Off Feature On All Cells

CB006877_B3_TC02_PRB_Blanking_interworking_when_CB006877_is_enabled
    [Setup]   Setup
    Setup Nbr Of Blanked Prb    ON
    Sleep    60s
    Set Cell Attenuation    20MHZ    0
    ${reference_du}=    Collect Vdu Pm Counters    ${vdu_pm_counters_dict}
    Verify Feature    20MHz_feature_disabled    ${feature_disabled_20MHz_blanking}
    Setup Vdu Parameters    20MHz    true
    Sleep    45s
    Verify Feature    20MHz_feature_enabled    ${feature_enabled_20MHz_blanking}
    Set Cell Attenuation    20MHZ    90
    Sleep    400
    ${updated_du}=    Collect Vdu Pm Counters    ${vdu_pm_counters_dict}
    Verify Pm Counters    ${reference_du}    ${updated_du}
    [Teardown]   Run Keywords
    ...          Trigger Detach    AND
    ...          Setup Nbr Of Blanked Prb    OFF    AND
    ...          Turn Off Feature On All Cells

*** Keywords ***
Verify Feature
    [Arguments]    ${feature_state}    ${prb_values}
    Trigger Attach And Verify Tput    ${feature_state}    ${LOG_PATH}
    Convert To Json And Verify Num Of Prbs   ${prb_values}    ${LOG_PATH}
