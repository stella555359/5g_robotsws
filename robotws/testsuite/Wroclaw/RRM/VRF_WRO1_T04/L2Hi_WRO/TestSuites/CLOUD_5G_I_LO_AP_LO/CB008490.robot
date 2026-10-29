*** Settings ***
Documentation
...   CB008490 Test cases regression - CRT
...   Topology  CLOUD_5G_I_LO_AP_LO
...   Variant   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library      ta5g_pm_counters
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource     ${folder_path}/CB008490-D_B16_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Lost_PDU_Retransmission.robot
Resource     ${folder_path}/CB008490-DCA.robot
Resource     ${folder_path}/CB008490-DCB_Incorrect_UP_message_received_over_XN_interface.robot
Resource     ${folder_path}/CB008490-FB_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_GTP-U_Error.robot

Test Setup    Run Keywords    Set RD Flag For Mcs 5
...           AND             Prepare Test Environement for SimMN And Reach Onair
...           AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

Test Teardown    Run Keywords    Check For An Unexpected Alarm
...              AND             Send Configuration ID To Scout
...              AND             Stop Default Processes And Gather Logs And Compress Logs
...              AND             Update And Put Iphy Xml    input_filepath=${LO_AP_LO_GMC_IPHY_FILE}
...              AND             Send Full Commissioning    ${LO_AP_LO_GMC_SCF_FILE}
...              AND             Reset RD Flag For Mcs
...              AND             Reset Testline And Wait For Rmods

*** Variables ***
${folder_path}=     ../../CB008490_Inter-gNB_FR1-FR2_NR_DC_for_Fixed_Wireless_Access

*** Test Cases ***
[1][1.0] CB008490-FB#B101_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_Xn-U_Dl_data_GTP-U_Error

    CB008490-FB#B101_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_Xn-U_Dl_data_GTP-U_Error

[1][1.0] CB008490-FB#B103_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_NG-U_Ul_data_GTP-U_Error

    CB008490-FB#B103_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_NG-U_Ul_data_GTP-U_Error

[1][1.0] CB008490-DCA_7_Number_of_downlink_XN-U_packet_received_which_out_of_order
    [Setup]     Run Keywords    Set RD Flag For Mcs 5
    ...         AND             Prepare Test Environement for SimSN And Reach Onair
    ...         AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

    CB008490-DCA_7_Number_of_downlink_XN-U_packet_received_which_out_of_order

[1][1.0] CB008490-DCA_8_Number_of_uplink_PDCP_PDUs_lost_over_XN-U

    CB008490-DCA_8_Number_of_uplink_PDCP_PDUs_lost_over_XN-U

[1][1.0] CB008490-DCB_PMO#1_Incorrect_UP_message_received_over_XN_interface_by_MN
    [Setup]     Run Keywords    Prepare Test Environement for SimSN And Reach Onair
    ...         AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

    CB008490-DCB_PMO#1_Incorrect_UP_message_received_over_XN_interface_by_MN

[1][1.0] CB008490-DCB_PMO#2_Incorrect_UP_message_received_over_XN_interface_by_SN
    [Setup]     Run Keywords    Prepare Test Environement for SimMN And Reach Onair
    ...         AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

    CB008490-DCB_PMO#2_Incorrect_UP_message_received_over_XN_interface_by_SN

[1][1.0] CB008490-D_B16_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Lost_PDU_Retransmission
    [Setup]     Run Keywords    Set RD Flag For Mcs 5
    ...         AND             Prepare Test Environement for SimMN And Reach Onair
    ...         AND             Activate Fast Retransmissions for lost PDCP PDU
    ...         AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

    CB008490-D_B16_DL_Transmission_with_PDCP_Flow_Control_Fast_Retransmission-Lost_PDU_Retransmission
