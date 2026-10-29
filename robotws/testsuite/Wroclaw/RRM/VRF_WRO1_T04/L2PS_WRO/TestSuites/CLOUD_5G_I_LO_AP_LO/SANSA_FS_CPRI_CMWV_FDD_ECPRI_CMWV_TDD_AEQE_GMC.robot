*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author:   Marcin Kotula (marcin.kotula@nokia.com)

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_test_setup.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_keywords.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/aashell_management.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/webem_alarms.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008367/CB008367-A-B2-32UE.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008367/CB008367-A_B5.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010944/CB010944-B_B8.robot

Test Teardown    Common Test Teardown    iphy=${LO_AP_LO_IPHY}    scf=${LO_AP_LO_SCF}

*** Variables ***
${LO_AP_LO_SCF}     /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC/scfc.xml
${LO_AP_LO_IPHY}    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC/iphy.xml

*** Test Cases ***
[1][1.0] CB008367-A_B2_1UE_tput_large-BWP_and_multi-UE_tput_small-BWP
    [Setup]    Common Test Setup    iphy=${iphy_CB008367}    scf=${scf_CB008367}    cfg=${cfg_CB008367}

    CB008367-A_B2_1UE_tput_large-BWP_and_multi-UE_tput_small-BWP


[1][1.0] CB008367-A_B5_control_UEs_switching_from_large-BWP_to_PS-BWP
    [Setup]    Common Test Setup    iphy=${iphy_CB008367_B5}    scf=${scf_CB008367_B5}     cfg=${cfg_CB008367_B5}

    CB008367-A_B5_control_UEs_switching_from_large-BWP_to_PS-BWP


[1][1.0] CB010944-B#B8_Interworking with 5GC002538 PDSCH Extension in SSB and TRS slots
    [Setup]    Run Keywords    Common Test Setup    iphy=${iphy_CB010944}    scf=${scf_CB010944}     cfg=${cfg_CB010944}
    ...        AND             Active Emf1 Beam
    CB010944-B#B8_Interworking with 5GC002538 PDSCH Extension in SSB and TRS slots