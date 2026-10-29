*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007552_D/CB007552_D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_2xAHPF

Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Activate Debug Logs     AND
...             Replace swconfig  ${swconfig_local_path}  ${swconfig_remote_path}  ${asib_connection}       AND
...             Setup attenuators

Test Teardown   Run keywords
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test

*** Variables ***

${swconfig_local_path}      testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007552_D/resources/swconfig.txt
${swconfig_remote_path}     /ffs/run/swconfig.txt
${asib_connection}               asib

*** Test Cases ***

[1]CB007552-5G-D_5_CB007552-D#D.5.1_Two_or_more_Ues_served_with_large_and_small_BWP_profiles_in_the_cell_simultanously
    [Tags]      SBTS00
    ...         SBTS23R1
    ...         SBTS23R2
    [1]CB007552-5G-D_5_CB007552-D#D.5.1_Two_or_more_Ues_served_with_large_and_small_BWP_profiles_in_the_cell_simultanously

[1]CB007552-5G-D_6_CB007552-D#IWK.6.1_Successful_Intra-frequency_Intra-gNB_handover
    [Tags]      SBTS00
    ...         SBTS23R1
    ...         SBTS23R2
    [1]CB007552-5G-D_6_CB007552-D#IWK.6.1_Successful_Intra-frequency_Intra-gNB_handover

[1]CNI_78446_B_3_RRC_connection_reestablishment_via_RRC_Setup_to_the_serving_cell_to_large_BWP
    [Tags]      SBTS00
    ...         SBTS23R1
    ...         SBTS23R2
    [1]CNI_78446_B_3_RRC_connection_reestablishment_via_RRC_Setup_to_the_serving_cell_to_large_BWP

[1]CNI_78446_B_1_SA intra-gNB Handover after inital RRC Setup with dedicated config in initialDownlinkBWP to large BWP
    [Tags]      SBTS00
    ...         SBTS23R1
    ...         SBTS23R2
    [1]CNI_78446_B_1_SA_intra-gNB_Handover_after_inital_RRC_Setup_with_dedicated_config_in_initialDownlinkBWP_to_large_BWP
