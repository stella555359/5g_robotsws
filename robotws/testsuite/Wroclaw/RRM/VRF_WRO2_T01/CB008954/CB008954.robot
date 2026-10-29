# robocop: disable=not-allowed-char-in-name
# robocop: disable=empty-section
*** Settings ***
Documentation
...  Author:        Maciej Cupial
...  Contact:       maciej.cupial@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   main *.robot file with regression tests.
...                 [1] - NSA, [2] - SA
...
...  Feature can not be fully automated (DAL22) due to manual loading EFS files onto UE using PCAT interface.
...  Special keyword is prepared to confirm by using via terminal that operation of loading file is finished.


Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008954/resources/tests_CB008954.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Resource      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot


Suite Setup         Suite Setup For 8954
Suite Teardown      Suite Teardown For 8954
Test Teardown       Add Scout Data Info To Testcase

*** Test Cases ***
[1]02A-B.3_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_PRB_blanking_with_streaming
    [Tags]  8954    8954ab1     ab1
    [Documentation]  Test case describes feature activation and configuration of 3 dedicated BWPs and does not have
    ...              impact on performance of TDD cell, which is checked by throughput and verified with emergency call.
    [Setup]     Test Setup For 8954    if_samode=${TRUE}    is_item_H=${TRUE}
    run_keyword_and_allow_retest
    ...  [1]01A-B.1_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_TDD_cell_without_PRB_blanking with emergency call
    [Teardown]  Test Teardown For 8954    if_samode=${TRUE}    is_item_H=${FALSE}


[1]04C-B.2_Initial_Context_Setup_UE_configured_with_second_BWP_profile_with_counter_verification
    [Tags]  8954    8954cb2     cb2
    [Documentation]    This test case verifies BWP2 in 3 dedicated BWP configuration with TDD cell
    [Setup]     Test Setup For 8954    if_samode=${TRUE}
    run_keyword_and_allow_retest
    ...  [1]04C-B.2_Initial_Context_Setup_UE_configured_with_second_BWP_profile_with_counter_verification
    [Teardown]  Test Teardown For 8954    if_samode=${TRUE}


[1]07C-B.5_Successful_Intra_Inter-frequency_Inter-gNB_handover_with_TDD_cells_by_RMOD_lock
    [Tags]  8954    8954cb5     cb5
    [Documentation]  This test case verifies Inter-frequency handover-inter gNB to 3rd dedicated BWP TDD cell.
    ...  Scenario covers 3 UEs with capabilities of BWP1, BWP2 and BWP3 performing handover one by one to respective
    ...  dedicated BWP of target cell.
    [Setup]     Test Setup For 8954   if_samode=${TRUE}
    run_keyword_and_allow_retest
    ...  [1]07C-B.5_Successful_Intra_Inter-frequency_Inter-gNB_handover_with_TDD_cells_by_RMOD_lock
    [Teardown]  Test Teardown For 8954    if_samode=${TRUE}


[1]09C-B.6_RRC_connection_re-establishment_with_serving_cell_with_valid_UE_context_and_site_reset
    [Tags]  8954    8954cb6     cb6
    [Documentation]  Scenario describes the common gNB behaviour with regards to UE supporting only
    ...  small BWP re-establishes RRC Connection to the same cell the UE previously connected.
    [Setup]     Test Setup For 8954
    run_keyword_and_allow_retest
    ...  [1]09C-B.6_RRC_connection_re-establishment_with_serving_cell_with_valid_UE_context_and_site_reset
    [Teardown]  Test Teardown For 8954


[1]10C-B.7_PRB_blanking_interaction_with_CB009915_and_VoNR
    [Tags]  8954    8954cb7     cb7
    [Documentation]    Scenario describes the common gNB behaviour with regards to UE context setup when UE supporting
    ...  large, dedicated BWP when PRB blanking is enabled
    [Setup]     Test Setup For 8954   if_samode=${TRUE}
    run_keyword_and_allow_retest
    ...  [1]10C-B.7_PRB_blanking_interaction_with_CB009915_and_VoNR
    [Teardown]  Test Teardown For 8954    if_samode=${TRUE}    recomm=${TRUE}



[1]11C-B.8,10_Inter-DU_Xn_handover_by_blocking_cells_between_BWP1_of_20_MHz_and_BWP2_of_50_100_MHz_2-BWP cells_TDD_interaction with_CB006878
    [Tags]  8954    8954cb8     cb8
    [Documentation]   This test case verifies Inter-DU Xn handover by ANR between BWP1 of 20 MHz and BWP2 of 80 Mhz
    ...  and BWP3 of 50/100 MHz (BWP1 is 20% of cell bandwidth) 2-BWP TDD cells_interaction with_CB006878
    [Setup]     Test Setup For 8954
    [1]11C-B.8,10_Inter-DU_Xn_handover_by_blocking_cells_between_BWP1_of_20_MHz_and_BWP2_of_50_100_MHz_2-BWP cells_TDD_interaction with_CB006878
    [Teardown]  Test Teardown For 8954



[1]12D-B.2_Successful_EN-DC_with_small_BWP_and_interaction_with_Power_Saving_part_2_(CB010442&CB010443)
    [Tags]  8954    8954db2     db2
    [Documentation]  This user scenario describes the gNB behavior in a successful case when the UE supports
    ...  small dedicated BWP. This is with regards to UE context setup for NSA 3x (EN-DC) for any band combination
    ...  of NR and LTE cells.
    [Setup]     Test Setup For 8954
    run_keyword_and_allow_retest
    ...  [1]12D-B.2_Successful_EN-DC_with_small_BWP_and_interaction_with_Power_Saving_part_2_(CB010442&CB010443)
    [Teardown]  Test Teardown For 8954


[1]18E-B.4_NSA_CA_PSCell_with_1st_or_2nd_or_3rd_BWP.Scell_with_1st_or_2nd_or_3rd_BWP.Plus_PS_II_(TDD+TDD)
    [Tags]  8954    8954eb4     eb4
    [Documentation]  This user scenario describes the successful SCell addition for CarrierAggregation in case the UE is
    ...  supporting 1st (small) or 2nd or 3rd (large) dedicated BWP in PSCell. The user scenario applies to NSA mode.
    ...  User scenario will be performed using FDD-TDD CA and blind SCell  addition with error case covered.
    ...  This user scenario also tests if the DL and UL resource utilization and peak throughput are maximized for
    ...  the selected BWP. The gNB can assign DL and UL resources in the entire configured largest dedicated BWP,
    ...  if the UE supports.
    [Setup]     Test Setup For 8954
    run_keyword_and_allow_retest
    ...  [1]18E-B.4_NSA_CA_PSCell_with_1st_or_2nd_or_3rd_BWP.Scell_with_1st_or_2nd_or_3rd_BWP.Plus_PS_II_(TDD+TDD)
    [Teardown]  Test Teardown For 8954


[1]20H-IWK.1_Power_Saving_BWP_not_configured_along_small_BWP
    [Tags]  8954    8954iwk1    iwk1
    [Documentation]  This user scenario describes the interaction with 5GC000937, when selected dedicated BWP is smaller
    ...  or equal power saving BWP then power saving BWP should not be configured.
    [Setup]     Test Setup For 8954    is_item_H=${TRUE}
    run_keyword_and_allow_retest
    ...  [1]20H-IWK.1_Power_Saving_BWP_not_configured_along_small_BWP
    [Teardown]  Test Teardown For 8954    is_item_H=${TRUE}
