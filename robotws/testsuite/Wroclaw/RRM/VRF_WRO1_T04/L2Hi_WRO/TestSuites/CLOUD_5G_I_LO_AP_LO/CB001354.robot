*** Settings ***
Documentation
...   5GC001354 Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   Author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B2_Tcp_High_Tput_Clasical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B2_Tcp_High_Tput_Clasical_Retxbasedonfc.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B2_Udp_Low_Tput_Clasical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B4_Udp_Clasical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B5_Clasical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B1_Multi_UE.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B1_TCP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B1_UDP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B2_TCP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B2_UDP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B1_Delaythresh1enabled_Classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B1_Long_Drx_Cycle_Classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B1_Low_Tput_Classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B1_Subfeatures_On_Classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B2_Ca_Enabled_Classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-D.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

*** Test Cases ***
[1][1.0] 5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Pdcp_Pdus_Over_X2u_Interface_Tcp_High_Tput_Clasical
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable 1354-A
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Pdcp_Pdus_Over_X2u_Interface_Tcp_High_Tput_Clasical

[1][1.0] 5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Tcp_High_Tput_Clasical_Retxbasedonfc
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable F1 Measurments
    ...        AND              Enable 1354-A With Retxbasedonfc
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Tcp_High_Tput_Clasical_Retxbasedonfc

[1][1.0] 5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_Low_Tput_Clasical
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable 1354-A
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_Low_Tput_Clasical

[1][1.0] 5GC001354-A-B4_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Duplicated_PDU_X2_Udp_Classical
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable 1354-A
    ...        AND              Enable 1354-B
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-A-B4_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Duplicated_PDU_X2_Udp_Classical

[1][1.0] 5GC001354-A-B5_Nsa_Non_Gbr_Drb_Duplicate_Transmission_Of_Pdcp_Pdu_For_Ddds_Handling_During_Pdcp_Sn_Rollover_Classical
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable F1 Measurments
    ...        AND              Enable HO
    ...        AND              Enable 1354-A
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-A-B5_Nsa_Non_Gbr_Drb_Duplicate_Transmission_Of_Pdcp_Pdu_For_Ddds_Handling_During_Pdcp_Sn_Rollover_Classical

[1][1.0] 5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Multi_UE_Udp_Tcp
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable 1354-B
    ...        AND              Enable MultiDrbNSA
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Multi_UE_Udp_Tcp

[1][1.0] 5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Tcp_TDD
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable 1354-B
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Tcp_TDD

[1][1.0] 5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Udp_TDD
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable 1354-B
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Udp_TDD

[1][1.0] 5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Tcp
    [Setup]    Run Keywords    Enable NSA HO
    ...        AND             Enable X2 Measurments
    ...        AND             Enable 1354-B
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Tcp

[1][1.0] 5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Udp
    [Setup]    Run Keywords    Enable NSA HO
    ...        AND             Enable X2 Measurments
    ...        AND             Enable 1354-B
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Udp

[1][1.0] 5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Delaythresh1enabled_Classical
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable Split F1UX2U
    ...        AND             Enable 1354-C With Only Treshold 1 Enabled
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Delaythresh1enabled_Classical

[1][1.0] 5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Long_Drx_Cycle_Classical
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable Split F1UX2U
    ...        AND             Set Drxlongcycle To 320ms
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Long_Drx_Cycle_Classical

[1][1.0] 5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Low_Tput_Classical
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable Split F1UX2U
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Low_Tput_Classical

[1][1.0] 5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Subfeatures_On_Classical
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable 1354-A
    ...        AND             Enable 1354-B
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Subfeatures_On_Classical

[1][1.0] 5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Classical
    [Setup]    Run Keywords    Update Gscn In Iphy File    GSCN_1=7832    GSCN_2=7902
    ...        AND             Enable Carrier Aggregation With Blind Scell Activation
    ...        AND             Disable 256qam Modulation
    ...        AND             Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable Split F1UX2U
    ...        AND             Set Drxlongcycle To 320ms
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_2CC}

    5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Classical

[1][1.0] 5GC001354-D-5GC001354-A_With_5GC001248-J
    [Setup]    Run Keywords    Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable 1354-A
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC001354-D-5GC001354-A_With_5GC001248-J
