*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for ROHC-A

Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/keywords_774_A.robot

Suite Setup      Initialise Attenuator

Test Setup       Nullify attenuation on all ports

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              Detach UE    UE_2                                AND
...              Nullify attenuation on all ports


*** Test Cases ***
5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly using an IPv4-configured APN (FDD).
    ...               EDA for 04054426 ACC_UE_UL_DRB_DATA_5QI1 and ACC_UE_UL_DRB_DATA_PMQAP comparison since 24R3.
    5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD


5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly using an IPv6-configured APN and maxCidAllowed=1. FDD
    5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1


5GC000774_A_05_Successful_Intra-frequency_Intra-DU_Intra-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly after/during Intra HO. FDD.
    5GC000774_A_05_Successful_Intra-frequency_Intra-DU_Intra-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD


5GC000774_A_08_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly after/during Inter HO. FDD.
    5GC000774_A_08_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD


5GC000774_A_09_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_1_to_2
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly after/during Inter HO to BTS with different maxCidAllowed.
    5GC000774_A_09_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_1_to_2


5GC000774_A_10_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_2_to_1
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly after/during Inter HO to BTS with different maxCidAllowed.
    5GC000774_A_10_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_2_to_1


5GC000774_A_14_Successful_setup_of_Emergency_(voice)_call_on_top_of_an_existing_VoNR_call_with_ROHC_enabled_FDD
    [Documentation]   The TC verifies whether emergency VoNr call over an existing call with ROHC works correctly using an IPv4-configured APN. FDD.
    5GC000774_A_14_Successful_setup_of_Emergency_(voice)_call_on_top_of_an_existing_VoNR_call_with_ROHC_enabled_FDD
