*** Settings ***
Documentation
...   CB008490 Test cases regression - CRT
...   Topology:  CLOUD_5G_I_[LO][LO]_AP_[LOO]
...   Variant:   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...   author:    Marcin Kotuła (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library      ta5g_pm_counters
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource     ${folder_path}/CB008490-B_B3_1_Large_data_transfer_in_downlink.robot
Resource     ${folder_path}/CB008490-B_B3_2_Large_data_transfer_in_downlink_TCP.robot
Resource     ${folder_path}/CB008490-B_B3_3_Multi_ue.robot
Resource     ${folder_path}/CB008490-D_B13_PSCell_Addition_with_PDCP_Status_Report.robot
Resource     ${folder_path}/CB008490-D_B14_Initial_DL_Traffic_Routing_post_NR-DC_PSCell_Addition.robot
Resource     ${folder_path}/CB008490-D_B17_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-PDCP_PDU_Duplication.robot
Resource     ${folder_path}/CB008490-D_B18_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Delay_based_PDCP_PDU_Retransmission.robot
Resource     ${folder_path}/CB008490-D_B20_Configuration_of_Nominal_Bit_Rate_during_NR-DC_PSCell_Addition.robot
Resource     ${folder_path}/CB008490-F_B4_1_NR-DC_bearer_takeback_UDP.robot
Resource     ${folder_path}/CB008490-F_B4_3_NR-DC_bearer_takeback_TCP.robot
Resource     ${folder_path}/CB008490-F_B4_4_NR-DC_bearer_takeback_multi_ue.robot
Resource     ${folder_path}/CB008490-FB_B104_Inter-gNB_NR-DC_Bearer_Takeback_Triggered_Due_To_HFN_Desynchronization_in_SN.robot
Resource     ${folder_path}/CB008490-FB_B105_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_PDCP_count_rollover_in_SN.robot

Test Setup    Run Keywords    Set RD For Mcs
...           AND             Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
...           AND             Set DlPreferredPathNrDc To Secondary On Gnb3

Test Teardown    Run Keywords    Deregister Ue     ue_id=1
...              AND             Set RD For Mcs    ${default_mcs_rd_value}
...              AND             Common Test Teardown CB008490

*** Variables ***
${folder_path}=            ../../CB008490_Inter-gNB_FR1-FR2_NR_DC_for_Fixed_Wireless_Access
${iphy}=                   iphy_2c_nrdc_n78_n257.xml
${MN_scf}=                 full_scf_gnb2_MN_nrdc_n78.xml
${SN_scf}=                 full_scf_gnb3_SN_nrdc_n257.xml
${cfg_filepath}=           ${EPCSIM_CFG_PATH_INTER_GNB_NRDC_TDD}
${default_mcs_rd_value}=   0x1FFFFFFF

*** Test Cases ***
[1][1.0] CB008490-B_B3_1_Large_udp_data_transfer_in_downlink

    CB008490-B_B3_1_Large_udp_data_transfer_in_downlink

[1][1.0] CB008490-B_B3_2_Large_data_transfer_in_downlink_TCP

    CB008490-B_B3_2_Large_data_transfer_in_downlink_TCP

[1][1.0] CB008490-B_B3_3_Multi_ue

    CB008490-B_B3_3_Multi_ue

[1][1.0] CB008490-D_B13_NR-DC_PSCell_Addition_with_the_DL_Transmission_at_SN_starting_post_the_reception_of_PDCP_Status_Report
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Set DlPreferredPathNrDc To Secondary On Gnb3
    ...         AND             Set ActDlTxResumeOnPdcpStatRep To True

    CB008490-D_B13_NR-DC_PSCell_Addition_with_the_DL_Transmission_at_SN_starting_post_the_reception_of_PDCP_Status_Report

[1][1.0] CB008490-D_B14_Initial_DL_Traffic_Routing_post_NR-DC_PSCell_Addition
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Set DlPreferredPathNrDc To Secondary On Gnb3

    CB008490-D_B14_Initial_DL_Traffic_Routing_post_NR-DC_PSCell_Addition

[1][1.0] CB008490-D_B17_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-PDCP_PDU_Duplication

    CB008490-D_B17_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-PDCP_PDU_Duplication

[1][1.0] CB008490-D_B18_Inter-gNB_NR-DC_PSCell_Addition_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Delay_based_PDCP_PDU_Retransmission
    [Setup]     Run Keywords    Set RD For Mcs
    ...         AND             Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Prepare Testmode For Harq Errors
    ...         AND             Enable Pdcp Pdu Delay Retx On Gnb3

    CB008490-D_B18_Inter-gNB_NR-DC_PSCell_Addition_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Delay_based_PDCP_PDU_Retransmission

[1][1.0] CB008490-D_B20_Configuration_of_Nominal_Bit_Rate_during_NR-DC_PSCell_Addition
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Set NBR
    ...         AND             Set DlPreferredPathNrDc To Secondary On Gnb3

    CB008490-D_B20_Configuration_of_Nominal_Bit_Rate_during_NR-DC_PSCell_Addition

[1][1.0] CB008490-F_B4_1_NR-DC_bearer_takeback_UDP

    CB008490-F_B4_1_NR-DC_bearer_takeback_UDP

[1][1.0] CB008490-F_B4_1_NR-DC_bearer_takeback_TCP

    CB008490-F_B4_1_NR-DC_bearer_takeback_TCP

[1][1.0] CB008490-F_B4_4_NR-DC_bearer_takeback_multi_ue
    [Setup]     Run Keywords    Set RD For Mcs
    ...         AND             Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}

    CB008490-F_B4_4_NR-DC_bearer_takeback_multi_ue

[1][1.0] CB008490-FB_B104_Inter-gNB_NR-DC_Bearer_Takeback_Triggered_Due_To_HFN_Desynchronization_in_SN
    [Setup]     Run Keywords    Set NR PDCP Ciphering To Distributed In Config File
    ...         AND             Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Set ulDataPathNrDc to ulDataSplit_PrimaryPathSCG On Gnb2 And Gnb3
    ...         AND             Enable actPdcpHfnDesyncDetectAlgo On Gnb2 And Gnb3
    ...         AND             Enable aes ciphering On Gnb2 And Gnb3
    ...         AND             Enable miNrPDCPCell On Gnb2 And Gnb3

    CB008490-FB_B104_Inter-gNB_NR-DC_Bearer_Takeback_Triggered_Due_To_HFN_Desynchronization_in_SN

[1][1.0] CB008490-FB_B105_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_PDCP_count_rollover_in_SN
    [Setup]     Run Keywords    Prepare Test Environement for Real MN With SN And Reach Onair    ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    ...         AND             Setup multigNB devices aliases
    ...         AND             Set DlPreferredPathNrDc To Secondary On Gnb3
    ...         AND             Set KeyRefrMarg To Max Value On Gnb2 And Gnb3

    CB008490-FB_B105_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_PDCP_count_rollover_in_SN
