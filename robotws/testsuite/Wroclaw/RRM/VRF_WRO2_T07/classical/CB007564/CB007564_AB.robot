*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file for feature CB007564
...
...      == HISTORY ==
...         [16.05.2022] - Aligned CB007564-B_4 test with the changes introduced in 5G_L3_FLOW_59779 for PR644597

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_FDD
#...           RAN_5G    RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36
#...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
#...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB

Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline            AND
...              Initialise Attenuator

Test Setup       Run Keywords
...              Nullify attenuation on all ports                 AND
...              BTSLOG Start btslog on local machine

Test Teardown    Run Keywords
...              BTSLOG Collect btslog                            AND
...              Nullify attenuation on all ports


*** Test Cases ***
CB007564-A_3_NG_FLOW_STP_ATT_INC_HO_and_NG_FLOW_STP_SUC_INC_HO_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of
     ...              QoS Flow setup due to to Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.
    CB007564-A_3_NG_FLOW_STP_ATT_INC_HO_and_NG_FLOW_STP_SUC_INC_HO_due_to_Intra-gNB_Intra_DU_HO

CB007564-B_5_NG_FLOW_REL_IANR_SUC_HO_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              during Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.
    CB007564-B_5_NG_FLOW_REL_IANR_SUC_HO_incrementation_due_to_Intra-gNB_Intra_DU_HO

CB007564-B_4_NG_FLOW_REL_GNB_RLF_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              when Radio Link Failure (RLF) is detected by gNB. The gNB initiate the UE context release
     ...              procedure over F1 and NG interface and send UE to idle state
     ...              by initiating the RRC Release procedure.
    CB007564-B_4_NG_FLOW_REL_GNB_RLF_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF

CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Documentation]   This test case verifies incrementation of counter provided to measure number QoS Flow release
     ...              when gNB initiated Ue Context Release due to DRB inactivity.
    CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
