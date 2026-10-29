*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5G_I_MP_AP_LO
...   Variant:  SANSA_FS_ECPRI_CMWV_TDD
...   author:   Marcin Kotula (marcin.kotula@nokia.com)

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_test_setup.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_keywords.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/aashell_management.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/webem_alarms.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009843/CB009843.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009843/CB009843_CB008701.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009514/CB008305.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009514/CB008701.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010944/CB010944-B_B3_7_2e.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB012169/CB012169_supercell.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB012169/CB012169_ABIP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008697/CB008697_A_b_12_1.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008367/CB008367-B_IWK3_alt.robot

Test Teardown    Common Test Teardown    iphy=${MP_AP_LOOO_IPHY}    scf=${MP_AP_LOOO_SCF}

*** Variables ***
${BSR_AHVA}           BSR_AVHA_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
${BSR_AVQL}           BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
${MP_AP_LOOO_SCF}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_ECPRI_CMWV_TDD_GMC/scfc.xml
${MP_AP_LOOO_IPHY}    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_ECPRI_CMWV_TDD_GMC/iphy.xml

*** Test Cases ***
[1][4.0] General_SiSo_Cell_block_and_unblock
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB009843}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS_CB009843}
    ...                                                     bsr_file_name=${BSR_AVQL}    scf=${SCF_CB009843}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB009843}

    General_SiSo_Cell_block_and_unblock


[1][2.0] Manual_SiSo_CM_Recommissioning
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB009843}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS_CB009843}
    ...                                                     bsr_file_name=${BSR_AVQL}    scf=${SCF_CB009843}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB009843}

    Manual_SiSo_CM_Recommissioning


[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB009843}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS_CB009843}
    ...                                                     bsr_file_name=${BSR_AVQL}    scf=${SCF_CB009843}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB009843}

    General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing


[1][1.0] CB008305-A_B4_Two_UEs_rank3_or_4_non-GBR_are_paired
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB008305}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS}
    ...                                                     bsr_file_name=${BSR_AHVA}    scf=${SCF_CB008305}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB008305}

    CB008305-A_B4_Two_UEs_rank3_or_4_non-GBR_are_paired


[1][1.0] CB010944_B_B3_Load_generation_IWK_with_CB008247_SRS_based_DL_BF
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB010944}        SWCONFIG_FLAGS=@{L2PS_BIP_SIZE}
    ...                                                     bsr_file_name=${BSR_AVQL}    scf=${SCF_CB010944}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB010944}
    ...        AND            Enable Emf
    ...        AND            Active beam

    CB010944_B_B3_Load_generation_IWK_with_CB008247_SRS_based_DL_BF


[1][1.0] CB008701-A_15_Verify_PMCounter_For_MUMIMO
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB008701}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS}
    ...                                                     bsr_file_name=${BSR_AHVA}    scf=${SCF_CB008701}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB008701}

    CB008701-A_15_Verify_PMCounter_For_MUMIMO


[1][2.0] CB008701-A_15_Verify_PMCounter_For_MUMIMO
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${IPHY_CB009843_AVHA}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS}
    ...                                                     bsr_file_name=${BSR_AHVA}         scf=${SCF_CB009843_AVHA}
    ...        AND            Start Logs And Reach Onair    cfg=${CFG_CB009843_AVHA}

    CB008701-A_15_Verify_PMCounter_For_MUMIMO_24_UE


[1][1.0] CB009514_H_05_SA_multi_UE_2TDD_2CC_CA_DL_with_BF_CB007922
    [Setup]    Run Keywords   Common Test Setup With BSR    iphy=${iphy_CB012169}        SWCONFIG_FLAGS=@{SWCONFIG_FLAGS}
    ...                                                     bsr_file_name=${BSR_AVQL}    scf=${scf_CB012169}
    ...        AND            Start Logs And Reach Onair    cfg=${cfg_CB012169}

    CB009514_H_05_SA_multi_UE_2TDD_2CC_CA_DL_with_BF_CB007922


[1][1.0] Manual_SiSo_SM_Cell_Block_Unblock
    [Setup]    Run Keywords   Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link}
    ...        AND            Configure Netconf Credentials
    ...        AND            load ncsnapshot      ncsnap_path=${ncsnap_path0}
    ...        AND            load ncsnapshot      ncsnap_path=${ncsnap_path1}
    ...        AND            load ncsnapshot      ncsnap_path=${ncsnap_path2}
    ...        AND            Common Test Setup With BSR    iphy=${iphy_CB012169_ABIP}
    ...                                                     SWCONFIG_FLAGS=@{SWCONFIG_FLAGS_CB009843}
    ...                                                     bsr_file_name=${BSR_AVQL}
    ...                                                     scf=${scf_CB012169_ABIP}
    ...        AND            Start Logs And Reach Onair    cfg=${cfg_CB012169_ABIP}

    Manual_SiSo_SM_Cell_Block_Unblock


[1][1.0] CB008697_A_b_12_1_FDD_FDD_2xTDD_OAI_activation_more_Scells_than_currently_allowed_to_be_active_for_overheating
    [Setup]    Run Keywords   Common Test Setup    iphy=${iphy_CB0008697_A_b_12_1}    scf=${scf_CB0008697_A_b_12_1}
    ...                                            cfg=${cfg_CB0008697_A_b_12_1}      skip_relation_errors=True
    ...        AND            Wait For Next Full Pm Interval

    CB008697_A_b_12_1_FDD_FDD_2xTDD_OAI_activation_more_Scells_than_currently_allowed_to_be_active_for_overheating


[1][1.0] CB008367-B_IWK3_with_CB008940_CB010513_BB_pooling_1UE_in_large-BWP_and_multi-UEs_in_small and_PS-BWPs
    [Setup]    Run Keywords   Update Iphy Configuration And Modify Swconfig
    ...                       iphy_xml_filepath=${iphy_CB008367}
    ...                       swconfig_flags_list=@{SWCONFIG_FLAGS_CB008367}
    ...        AND            Start Default Logging
    ...        AND            Download and Modify L1Pool Vendor File and perform commissioning    scf=${scf_CB008367}
    ...        AND            Check Radios Availability
    ...        AND            Reach Onair    lua_cfg=${cfg_CB008367}

    CB008367-B_IWK3_with_CB008940_CB010513_BB_pooling_1UE_in_large-BWP_and_multi-UEs_in_small and_PS-BWPs
