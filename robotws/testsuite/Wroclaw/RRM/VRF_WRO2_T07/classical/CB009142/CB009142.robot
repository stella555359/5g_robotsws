*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the TESTSUITE file for feature CB009142


Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009142/resources/keywords_9142.robot


Suite Setup      Initialise Attenuator

Test Setup       Run Keywords
...              Nullify attenuation on all ports                 AND
...              BTSLOG Start btslog on local machine

Test Teardown    Run Keywords
...              BTSLOG Collect btslog                             AND
...              Nullify attenuation on all ports                  AND
...              Detach UE  UE_1                                   AND
...              Unlock all cells


*** Test Cases ***

CB009142_01_A_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA
    [Documentation]   The purpose of this TC is to verify Subercell 6 subcells activation/deactivation o full ABIP
        ...              and call in all sub-cells.
    CB009142_01_A_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA

CB009142_01_B_Supercell_with_6_subcells_activation_deactivation_with_VoNR_establishment_on_each_subcell_SA
    [Documentation]   The purpose of this TC is to verify Subercell 6 subcells activation/deactivation o full ABIP
        ...              and call in all sub-cells.
    CB009142_01_B_Supercell_with_6_subcells_activation_deactivation_with_VoNR_stablishment_on_each_subcell_SA

CB009142_02_2_supercells_with_2_and_4_subcells_inter_freq_handover_between_supercells_NSA
   [Documentation]   The purpose of this TC is to verify configuration of 2 supercells 2 and 4 subcells on full ABIP
    ...              and inter frequency handover between 2 supercells.
    CB009142_02_2_supercells_with_2_and_4_subcells_inter_freq_handover_between_supercells_NSA

CB009142_03_Supercell_with_3_subcells_handover_to_normal_cell_TDD_NSA
   [Documentation]   The purpose of this TC is to verify configuration of supercell 3 subcells on half ABIP
    ...              and handover between supercell and normal cell TDD.
    CB009142_03_Supercell_with_3_subcells_handover_to_normal_cell_TDD_NSA

CB009142_04_3_Supercells_with_2_subcells_handover_to_normal_cell_FDD_SA
   [Documentation]   The purpose of this TC is to verify configuration of 3 supercell 2 subcells on full ABIP
    ...              and handover between supercell and normal cell FDD.
    CB009142_04_3_Supercells_with_2_subcells_handover_to_normal_cell_FDD_SA
