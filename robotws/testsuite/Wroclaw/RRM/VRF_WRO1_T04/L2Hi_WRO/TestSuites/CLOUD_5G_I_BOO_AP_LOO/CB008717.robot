*** Settings ***
Documentation
...   CB008717 Test cases regression - CRT
...   Topology: CLOUD_5G_I_BOO_AP_LOO
...   author:   Marcin Kotula (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py
Library    taf.ul.ettf.setups

Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B2_Start_of_DL_data_transmission_over_secondary_path.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B3_DL_and_UL_data_handling.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B4_B7_DL_and_UL_Ping.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B5_Web_browsing-bursty_traffic_profile.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B8_Verification_of_dlDataSplitMode_with_dlOverF1Uonly.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-B_B9_Mue_Nrdc_Ues.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-D_B2_UL_data_transfer.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-D_B4a_UL_data_set_exclusively_to_SCG.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-D_B4b_UL_data_set_to_MCGSCG_UE_capable_of_UL_data_split.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-D_B4c_UL_data_set_to_MCGSCG_UE_not_capable_of_UL_data_split.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-D_B4d_Successful_PSCell_Addition_with_multiple_PDU_Session_for_split_based_on_highest_AMBR.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-E_B6a_UE_Release_without_bearer_takeback_due_to_PDCP_count_rollover.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-E_B7_UE_Release_without_bearer_takeback_due_to_GTP-U_Error.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-F_B8_NR-DC_bearer_takeback_triggered_due_to_RLF.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-I_B3_Initial_DL_Traffic_Routing_post_SCG_Addition_with_prior_DL_data_transmission.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-I_B4_Initial_DL_Traffic_Routing_post_SCG_Addition_without_prior_DL_data_transmission.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-T_B_ENDC_preferred_path_selection.robot
Resource   ../../CB008717_Intra-gNB_FR1-FR2/CB008717-T_B_NRDC_preferred_path_selection.robot
Resource   ../../EDA-PR778668_CB008322_with_2CC/EDA-PR778668_CB008322_with_2CC.robot

Test Teardown    Run Keywords    Deregister Ue    ue_id=1
...              AND             Send Configuration ID To Scout
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
...              AND             Stop Default Processes And Gather Logs And Compress Logs
...              AND             Check For An Unexpected Alarm

*** Variables ***
${iphy_n78}=                   iphy_2c_nrdc_n78_n257.xml
${iphy_n1}=                    iphy_2c_nrdc_n1_n257.xml
${scf_n78}=                    full_scf_2c_nrdc_n78_n257.xml
${scf_n1}=                     full_scf_2c_nrdc_n1_n257.xml
${cfg_filepath_TDD}=           ${EPCSIM_CFG_PATH_NRDC_TDD_new}
${cfg_filepath_FDD}=           ${EPCSIM_CFG_PATH_NRDC_FDD}
${eda_config_folder_path}=     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/EDA-PR778668_CB008322_with_2CC/config

*** Test Cases ***
[1][1.0] CB008717-B_B2_Start_of_DL_data_transmission_over_secondary_path
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1UX2U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B2_Start_of_DL_data_transmission_over_secondary_path

[1][1.0] CB008717-B_B3_DL_and_UL_data_handling
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1UX2U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B3_DL_and_UL_data_handling

[1][1.0] CB008717-B_B4_B7_DL_and_UL_Ping
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1UX2U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B4_B7_DL_and_UL_Ping

[1][1.0] CB008717-B_B5_Web_browsing-bursty_traffic_profile
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1UX2U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B5_Web_browsing-bursty_traffic_profile

[1][1.0] CB008717-B_B8_Verification_of_dlDataSplitMode_with_dlOverF1Uonly
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B8_Verification_of_dlDataSplitMode_with_dlOverF1Uonly

[1][1.0] CB008717-B_B9_Mue_Nrdc_Ues
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND             Set Dl Split Mode To DlOverF1UX2U
    ...         AND             Disable Uplane Ciphering

    CB008717-B_B9_Mue_Nrdc_Ues

[1][1.0] CB008717-D_B2_UL_data_transfer
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_71}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND             Set Ul Data Split Primary Path SCG

    CB008717-D_B2_UL_data_transfer

[1][1.0] CB008717-D_B4a_UL_data_set_exclusively_to_SCG
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND             Set Ul Over SCG

    CB008717-D_B4a_UL_data_set_exclusively_to_SCG

[1][1.0] CB008717-D_B4b_UL_data_set_to_MCGSCG_UE_capable_of_UL_data_split
    [Setup]     Run Keywords    Set Ul Data Split Primary Path MCG
    ...         AND             Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}

    CB008717-D_B4b_UL_data_set_to_MCGSCG_UE_capable_of_UL_data_split

[1][1.0] CB008717-D_B4c_UL_data_set_to_MCGSCG_UE_not_capable_of_UL_data_split
    [Setup]     Run Keywords    Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND             Set Ul Data Path For Ul Split Not Capable Ue
    ...         AND             Set Internal Traffic Type To UEs    ue_id=4    pdu_id=4

    CB008717-D_B4c_UL_data_set_to_MCGSCG_UE_not_capable_of_UL_data_split

    [Teardown]    Run Keywords    Deregister Ue    ue_id=4
    ...           AND             Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

[1][1.0] CB008717-D_B4d_Successful_PSCell_Addition_with_multiple_PDU_Session_for_split_based_on_highest_AMBR
    [Setup]     Run Keywords      Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND               Set Ul Over SCG

    CB008717-D_B4d_Successful_PSCell_Addition_with_multiple_PDU_Session_for_split_based_on_highest_AMBR

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

[1][1.0] CB008717-E_B6a_UE_Release_without_bearer_takeback_due_to_PDCP_count_rollover
    [Setup]     Run Keywords      Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND               Set PDCP Count KeyRefrMarg To Max Value

    CB008717-E_B6a_UE_Release_without_bearer_takeback_due_to_PDCP_count_rollover

[1][1.0] CB008717-E_B7_UE_Release_without_bearer_takeback_due_to_GTP-U_Error
    [Setup]     Run Keywords      Common Test Setup CB008717    ${iphy_n1}    ${scf_n1}    ${cfg_filepath_FDD}
    ...         AND               Set Ul Data Split Primary Path SCG

    CB008717-E_B7_UE_Release_without_bearer_takeback_due_to_GTP-U_Error

[1][1.0] CB008717-F_B8_NR-DC_bearer_takeback_triggered_due_to_radio_link_failure_detected_by_gNB-DU_in_SCG-with_PDCP_data_retransmission
    [Setup]     Run Keywords      Set RD Flag For Mcs 5
    ...         AND               Increase WTS Buffer Size
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Set Dl Split Mode To DlOverF1UX2U
    ...         AND               Disable Uplane Ciphering
    ...         AND               Enable PDCP Status Handling

    CB008717-F_B8_NR-DC_bearer_takeback_triggered_due_to_radio_link_failure_detected_by_gNB-DU_in_SCG-with_PDCP_data_retransmission

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Reset RD Flag For Mcs
    ...           AND             Reset Testline

[1][1.0] CB008717-I_B3_Initial_DL_Traffic_Routing_post_SCG_Addition_with_prior_DL_data_transmission
    [Setup]     Run Keywords      Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable Uplane Ciphering
    ...         AND               Set Dl Split Mode To DlOverF1UX2U And Initial DL Traffic Routing To initDLoverF1U

    CB008717-I_B3_Initial_DL_Traffic_Routing_post_SCG_Addition_with_prior_DL_data_transmission

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Reset RD Flag For Mcs
    ...           AND             Reset Testline

[1][1.0] CB008717-I_B4_Initial_DL_Traffic_Routing_post_SCG_Addition_without_prior_DL_data_transmission
    [Setup]     Run Keywords      Common Test Setup CB008717    ${iphy_n71}    ${scf_n71}    ${cfg_filepath_TDD}
    ...         AND               Disable Uplane Ciphering
    ...         AND               Set Dl Split Mode To DlOverF1UX2U And Initial DL Traffic Routing To initDLoverXxU

    CB008717-I_B4_Initial_DL_Traffic_Routing_post_SCG_Addition_without_prior_DL_data_transmission

[1][1.0] CB008717-T_B1_ENDC_preferred_path_selection_with_dlPreferredPath_F1U_initialDLTrafficRouting_initDLoverX2U_actPrioritizeX2AfterInactivity_0
    [Setup]     Run Keywords      Set RD Flag For Mcs 3
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable 256qam Modulation

    CB008717-T_B1_ENDC_preferred_path_selection_with_dlPreferredPath_F1U_initialDLTrafficRouting_initDLoverX2U_actPrioritizeX2AfterInactivity_0

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Reset RD Flag For Mcs
    ...           AND             Reset Testline

[1][1.0] CB008717-T_B2_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_0
    [Setup]     Run Keywords      Set RD Flag For Mcs 3
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable 256qam Modulation

    CB008717-T_B2_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_0

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Reset RD Flag For Mcs
    ...           AND             Reset Testline

[1][1.0] CB008717-T_B3_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_1
    [Setup]     Run Keywords      Set RD Flag For Mcs 3
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable 256qam Modulation

    CB008717-T_B3_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_1

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Reset RD Flag For Mcs
    ...           AND             Reset Testline

[1][1.0] CB008717-T_B4_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_MCG_initialDLTrafficRoutingNrDc_initDLoverXxU_actPrioXxAfterInactNrDc_0
    [Setup]     Run Keywords      Set RD Flag For Mcs 5
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable Uplane Ciphering

    CB008717-T_B4_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_MCG_initialDLTrafficRoutingNrDc_initDLoverXxU_actPrioXxAfterInactNrDc_0

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

[1][1.0] CB008717-T_B5_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_0
    [Setup]     Run Keywords      Set RD Flag For Mcs 5
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable Uplane Ciphering

    CB008717-T_B5_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_0

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

[1][1.0] CB008717-T_B6_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_1
    [Setup]     Run Keywords      Set RD Flag For Mcs 5
    ...         AND               Common Test Setup CB008717    ${iphy_n78}    ${scf_n78}    ${cfg_filepath_TDD}
    ...         AND               Disable Uplane Ciphering

    CB008717-T_B6_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_1

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

[1][1.0] EDA-PR778668_CB008322_with_2CC
    [Setup]     Run Keywords    Get and Update BSR File
    ...         AND             Update And Put Iphy Xml    input_filepath=${eda_config_folder_path}/iphy.xml
    ...         AND             Fix And Send Full Commissioning With Given Scf Filepath
    ...                         scfc_filepath=${eda_config_folder_path}/full_scf_BOOLOO_3cells_2T1F.xml
    ...         AND             Prepare interfaces for virtual nodes
    ...         AND             Reach Onair    lua_cfg=${eda_config_folder_path}/wts.cfg
    ...         AND             Set Internal Traffic Type To UEs

    EDA-PR778668_CB008322_with_2CC

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Check For An Unexpected Alarm
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
