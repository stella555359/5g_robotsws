*** Settings ***
Documentation    Suite description
#Library         taf.ue
Library         ute_ue
Library         taf.ul.messaging.mtk      WITH NAME    mtk
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001347/5GC001347-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/5GC001348-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/5GC002060.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002197/5GC002197-M.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/5GC000865.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-8741/FGCR-8741.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-E.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000865/resources/bts_log_check.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot


Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB


Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Setup attenuators

Test Setup      Run keywords
...             Reserve UEs MTK For tests  AND
...             Run Keyword and Ignore Error   Start syslog collection  AND
...             Connect to Coam   AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID   AND
...             Set initial attenuation

Test Teardown   Run Keywords
...             Sleeping cell test    AND
...             Detach UEs Used By Test   AND
...             Make snapshot in case of error    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Verify Crash occurrence In Syslog  AND
...             Disconnect coam

*** Test Cases ***
[1]5GC000900-C_30_Successful_NSA_and_SA_calls_setup_in_NSA+SA_cell
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]5GC000900-C_30_Successful_NSA_and_SA_calls_setup_in_NSA+SA_cell

# [1]5GC000900-A_09_Successful_NSA_and_SA_calls_setup_when_gNB_is_operating_in_mixed_mode
#     [Tags]   SBTS23R4
#     [1]5GC000900-A_09_Successful_NSA_and_SA_calls_setup_when_gNB_is_operating_in_mixed_mode

# [1][1.0] 5GC002060_A_3_FGCR8144_NSA_TMO
#     [Tags]   SBTS23R4
#     [1][1.0] 5GC002060_A_3_FGCR8144_NSA_TMO

# [1]5GC000900-D_47_Successful_intra-frequency_inter-gNB_handover_from_NSA_cell_to_NSA-SA_cell_and_back
#     [Tags]   SBTS23R4
#     [1]5GC000900-D_47_Successful_intra-frequency_inter-gNB_handover_from_NSA_cell_to_NSA-SA_cell_and_back

[1]5GC002534-A_44_PDSCH traffic at SSB slot for multiple users with PRB blanking. NSA+SA. chBW=20MHz
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]5GC002534-A_44_PDSCH traffic at SSB slot for multiple users with PRB blanking chBW=20MHZ

# [1]5GC001347_A;5GC001347_B_002_02_A-B_Activation_mUE_Attach-Traffic_ul-dl-DmrsAdditionalPosition_PTRS-OFF_GRC
#     [Tags]   SBTS23R4
#     [1]5GC001347_A;5GC001347_B_002_02_A-B_Activation_mUE_Attach-Traffic_ul-dl-DmrsAdditionalPosition_PTRS-OFF_GRC

[1]5GC001348_B_11_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_PUSCH_Received_and_decoded_Cell_BW_5M
     [Tags]   SBTS00
     ...      SBTS23R4
     [1]5GC001348_B_11_5GC001348_B_NSA_Uplink_Channel_Multeplixing_Activated_PUSCH_Received_and_decoded_Cell_BW_5M

# [1]5GC002534-A_16_PDSCH traffic at SSB slot. SA. chBW=15MHz
#     [Tags]   SBTS23R1
#     [1]5GC002534-A_16_PDSCH traffic at SSB slot. SA. chBW=15MHz
