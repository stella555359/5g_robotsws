*** Settings ***
Documentation
...   CB001354 Test cases regression - CRT
...   Topology: CLOUD_5G_I_MP_AP_LO
...   Variant:  SANSA_FS_ECPRI_CMWV_TDD
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    ../../CB006898_PMQAP_profiles_for_NR/CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-B-B2_UDP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C-B2_Ca_Enabled_Classical.robot
Resource    ../../CB009823_RIM_Framework-1/CB009823-B1_Start_RIMRS_Detection_5GC001116_4GP_0ms_shift_ABIP.robot
Resource    ../../CB009324_Traffic_shaping_at_gNB_L2_with_DL_data_over_X2-U/CB009324-B-US3_Multi_Nsa_Ue.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${MP_AP_LO_GMC_TDD_SCF_FILE}

*** Test Cases ***
[1][1.0] CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue
    [Setup]    Run Keywords    Enable Tput Counters
    ...        AND             Add Qos Group
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD}

    CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue

[1][1.0] 5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Udp
    [Setup]    Run Keywords    Enable NSA HO
    ...        AND             Enable X2 Measurments
    ...        AND             Enable 1354-B
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD}

    5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Udp

[1][1.0] 5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Classical
    [Setup]    Run Keywords    Update Gscn In Iphy File    GSCN_1=7880    GSCN_2=7902
    ...        AND             Enable Carrier Aggregation With Blind Scell Activation
    ...        AND             Disable 256qam Modulation
    ...        AND             Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable Split F1UX2U
    ...        AND             Set Drxlongcycle To 320ms
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_2CC}

    5GC001354-C-B2_Nsa_Non_Gbr_Drb_Retransmission_Of_Pdcp_Pdus_Due_To_Rlo_With_Ca_Enabled_Classical

[1][1.0] CB009823-B1_Start_Rimrs_Detection_Enabled_5GC001116_4gp_0ms_Shift
    [Setup]    Run Keywords    Configure VM interfaces For Second Gnb
    ...        AND             Enable actDisableEcpriUlScalingEnh
    ...        AND             Enable actRinCmFmReport
    ...        AND             Set Tdd Frame
    ...        AND             Configure Rimrs Framework-1
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD}

    CB009823-B1_Start_Rimrs_Detection_Enabled_5GC001116_4gp_0ms_Shift

[1][1.0] CB009324-B-US3_Traffic_Shaping_For_DL_Split_Traffic_Over_X2-U_For_Multiple_UEs_PDCP_Fast_Retransmissions_And_Forwarded_Data_Over_X2-U
    [Setup]    Run Keywords    Enable Burst Size Divider
    ...        AND             Update Gscn In Iphy File    GSCN_1=7880    GSCN_2=7902
    ...        AND             Enable Carrier Aggregation With Blind Scell Activation
    ...        AND             Enable Traffic Shaping TDD
    ...        AND             Adapt RLO Params
    ...        AND             Enable X2 Measurments
    ...        AND             Enable F1 Measurments
    ...        AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...        AND             Enable FSTSCH Counters
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_2CC}

    CB009324-B-US3_Traffic_Shaping_For_DL_Split_Traffic_Over_X2-U_For_Multiple_UEs_PDCP_Fast_Retransmissions_And_Forwarded_Data_Over_X2-U