*** Settings ***
Documentation
...   author: Adam Chamera
...   contact: adam.chamera@nokia.com
...   This is the TESTSUITE file for CB008200
...
...      == HISTORY ==
...         [16.05.2022] - Aligned CB008200-D_2 and CB008200-F_8 tests with the changes introduced in 5G_L3_FLOW_59779 for PR644597

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/keywords_8200.robot

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_FDD
#...           RAN_5G    RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36
#...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
#...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB


Suite Setup     Run Keywords
...             Prepare Testline                                  AND
...             Initialise Attenuator                             AND
...             Set counter period parameters for all             AND
...             Require Ues  2


*** Test Cases ***

PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call


CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call
    CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call


CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup


CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1


CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1


CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered
    CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered


CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause
    CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause


CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call
    CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call


CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup


CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session
    CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session


PART_2__D_2__F_8__RLF
    PART_2__D_2__F_8__RLF


CB008200-D_2_NG_FLOW_REL_GNB_UE_LOST_5QI1_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    CB008200-D_2_NG_FLOW_REL_GNB_UE_LOST_5QI1_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF


CB008200-F_8_NG_FLOW_REL_GNB_RLF_PMQAP_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    CB008200-F_8_NG_FLOW_REL_GNB_RLF_PMQAP_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF


PART_3__B_7__F_15__REESTABLISHMENT
    PART_3__B_7__F_15__REESTABLISHMENT


CB008200-B_7_NG_FLOW_STP_ATT_RES_IADU_5QI1_and_NG_FLOW_STP_SUC_RES_IADU_5QI1_due_to_reestablishment_to_different_cell_same_gNB
    CB008200-B_7_NG_FLOW_STP_ATT_RES_IADU_5QI1_and_NG_FLOW_STP_SUC_RES_IADU_5QI1_due_to_reestablishment_to_different_cell_same_gNB


CB008200-F_15_NG_FLOW_STP_ATT_RES_IADU_PMQAP_and_NG_FLOW_STP_SUC_RES_IADU_PMQAP_due_to_reestablishment_to_different_cell_same_gNB
    CB008200-F_15_NG_FLOW_STP_ATT_RES_IADU_PMQAP_and_NG_FLOW_STP_SUC_RES_IADU_PMQAP_due_to_reestablishment_to_different_cell_same_gNB

#TODO:
#PART_4__B_1__F_2__FALLBACK
#    PART_4__B_1__F_2__FALLBACK


#CB008200-B_1_NG_FLOW_STP_FAIL_FALLBACK_5QI1_incrementation_due_to_voice_fallback_to_LTE
#     CB008200-B_1_NG_FLOW_STP_FAIL_FALLBACK_5QI1_incrementation_due_to_voice_fallback_to_LTE


#CB008200-F_2_NG_FLOW_STP_FAIL_FALLBACK_PMQAP_incrementation_due_to_voice_fallback_to_LTE
#    CB008200-F_2_NG_FLOW_STP_FAIL_FALLBACK_PMQAP_incrementation_due_to_voice_fallback_to_LTE


#PART_5__D_1__F_7__REDIRECTION
#    PART_5__D_1__F_7__REDIRECTION


#CB008200-D_1_NG_FLOW_REL_GNB_REDIRECT_5QI1_incrementation_due_to_redirection_of_Voice_call_to_LTE
#    CB008200-D_1_NG_FLOW_REL_GNB_REDIRECT_5QI1_incrementation_due_to_redirection_of_Voice_call_to_LTE


#CB008200-F_7_NG_FLOW_REL_GNB_REDIRECT_PMQAP_incrementation_due_to_redirection_of_Voice_call_to_LTE
#    CB008200-F_7_NG_FLOW_REL_GNB_REDIRECT_PMQAP_incrementation_due_to_redirection_of_Voice_call_to_LTE


PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO


CB008200-B_3_NG_FLOW_STP_ATT_INC_HO_5QI1_and_NG_FLOW_STP_SUC_INC_HO_5QI1_due_to_Intra-gNB_Intra_DU_HO
    CB008200-B_3_NG_FLOW_STP_ATT_INC_HO_5QI1_and_NG_FLOW_STP_SUC_INC_HO_5QI1_due_to_Intra-gNB_Intra_DU_HO


CB008200-D_3_NG_FLOW_REL_IANR_SUC_HO_5QI1_incrementation_due_to_Intra-gNB_Intra_DU_HO
    CB008200-D_3_NG_FLOW_REL_IANR_SUC_HO_5QI1_incrementation_due_to_Intra-gNB_Intra_DU_HO


CB008200-F_4_NG_FLOW_STP_ATT_INC_HO_PMQAP_and_NG_FLOW_STP_SUC_INC_HO_PMQAP_due_to_Intra-gNB_Intra_DU_HO
    CB008200-F_4_NG_FLOW_STP_ATT_INC_HO_PMQAP_and_NG_FLOW_STP_SUC_INC_HO_PMQAP_due_to_Intra-gNB_Intra_DU_HO


CB008200-F_9_NG_FLOW_REL_IANR_SUC_HO_PMQAP_incrementation_due_to_Intra-gNB_Intra_DU_HO
    CB008200-F_9_NG_FLOW_REL_IANR_SUC_HO_PMQAP_incrementation_due_to_Intra-gNB_Intra_DU_HO

#TODO:
#PART_7__D_5__F_11__INTER__RAT__HO__From__5G__To__LTE
#    PART_7__D_5__F_11__INTER__RAT__HO__From__5G__To__LTE


#CB008200-D_5_NG_FLOW_REL_IRAT_SUC_HO_5QI1_incrementation_due_to_Inter-RAT_HO_from_5G
#    CB008200-D_5_NG_FLOW_REL_IRAT_SUC_HO_5QI1_incrementation_due_to_Inter-RAT_HO_from_5G


#CB008200-F_11_NG_FLOW_REL_IRAT_SUC_HO_PMQAP_incrementation_due_to_Inter-RAT_HO_from_5G
#    CB008200-F_11_NG_FLOW_REL_IRAT_SUC_HO_PMQAP_incrementation_due_to_Inter-RAT_HO_from_5G
