*** Settings ***
Documentation  Tests for feature 7797-A

Library    ute_ue
Library    ../../resources/attenuator_keywords.py
Library    resources/keywords_7797.py

Resource   resources/keywords_7797.robot
Resource   ../5GC001167/resources/keywords.robot
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME    python_1167
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py

*** Variables ***
${UE_SA}=    UE_1

*** Keywords ***
CB007797_A3_016_Dynamic_Switching_between_64QAM_mode_and_256QAM_mode_UE_SA_UE_NSA_20MHz
    Activate DSS    min_nr_dss_ratio=60   max_nr_dss_ratio=70    lte_bandwith=10
    Activate Prb Blanking
    Set Attenuation 1 cell    cell_id=2
    Set Preferred Cell    2
    Require UE    ${UE_SA}    ${UE_SA}
    256 QAM for PUSCH Dynamic Switching between 64QAM and 256 QAM
    ...    ue=${UE_SA}
    ...    check_counters=${FALSE}
    ...    mcs_table_only=${FALSE}

    [Teardown]  Run Keywords
    ...    Deactivate Prb Blanking    AND
    ...    Deactivate DSS    60    70    AND
    ...    Set Initial Attenuation 3 cells
