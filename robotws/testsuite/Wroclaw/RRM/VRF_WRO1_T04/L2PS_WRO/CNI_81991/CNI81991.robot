*** Settings ***
Documentation
...   CNI 81991 Test cases regression - CRT
...   Topology - CLOUD_5G_I_LO_AP_LO
...   Variant - SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author:  Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/webem_alarms.py
Library      ta_pcmd.tshark_plugin_configurator

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_A_B1_FDD_5MHz.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_A_B1_TDD_100MHz.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_A_B2_FDD_20MHz.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_A_B5_FDD_20MHz_Reestablish.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_A_E2_TDD_20MHz.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_AB_B1_FDD_20MHz.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CNI_81991/CNI81991_AB_B1_TDD_100MHz.robot

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    RAN_5G    RAN_5G_TDD    CRT     SBTS00

Suite Setup    Start Default Logging

Suite Teardown   Print Active Alarms

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${iphy_A_B1_FDD_5MHz}=                       ${CURDIR}/config/iphy_2AHLOA_5MHz.xml
${iphy_TDD}=                                 ${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
${iphy_A_B2_FDD_20MHz}=                      ${CURDIR}/config/iphy_FDD.xml
${iphy_AB_B1_FDD_20MHz}=                     ${CURDIR}/config/iphy.xml

${scfc_filename_A_B1_FDD_5MHz}=              full_FDD_5Mhz_initialBWP.xml
${scfc_filename_A_B1_TDD_100MHz}=            full_TDD_100MHz_initialBWP.xml
${scfc_filename_A_B2_FDD_20MHz}=             full_CNI81991_FDD_20MHZ.xml
${scfc_filename_A_B2_FDD_20MHz_Re}=          full_CNI_81991_20MHz_reestablish_1.xml
${scfc_filename_A_E2_TDD_20MHz}=             TDD_20MHz_1c_new.xml
${scfc_filename_AB_B1_FDD_20MHz}=            full_FDD_20MHz.xml
${scfc_filename_AB_B1_TDD_100MHz}=           full_TDD_100MHz.xml

${lua_cfg_A_B1_FDD_5MHz}=                    ${CURDIR}/config/basic_setup_FDD_5MHz.cfg
${lua_cfg_basic_setup}=                      ${CURDIR}/config/basic_setup.cfg
${lua_cfg_basic_setup_fdd}=                  ${CURDIR}/config/basic_setup_fdd.cfg
${lua_cfg_basic_setup_tdd}=                  ${CURDIR}/config/basic_setup_tdd.cfg
${lua_cfg_AB_B1_FDD_20MHz}=                  ${CURDIR}/config/basic_setup_FDD_20MHz.cfg

*** Test Cases ***
[1][1.0] CNI-81991-A_B1_RRC_connection_estab_with_smallest_RRCSetup_FDD_5MHz
    [Setup]    Commmon Test Setup    ${iphy_A_B1_FDD_5MHz}  ${scfc_filename_A_B1_FDD_5MHz}  ${lua_cfg_A_B1_FDD_5MHz}

    CNI-81991-A_B1_RRC_connection_estab_with_smallest_RRCSetup_FDD_5MHz

[1][1.0] CNI-81991-A_B1_RRC_connection_estab_with_smallest_RRCSetup_TDD
    [Setup]    Commmon Test Setup    ${iphy_TDD}  ${scfc_filename_A_B1_TDD_100MHz}  ${lua_cfg_basic_setup}

    CNI-81991-A_B1_RRC_connection_estab_with_smallest_RRCSetup_TDD

[1][1.0] CNI-81991-A_B2_RRC_connection_estab_with_smallest_RRCSetup_with_ICS_with_PDU_session_FDD_Cell_center
    [Setup]    Commmon Test Setup    ${iphy_A_B2_FDD_20MHz}  ${scfc_filename_A_B2_FDD_20MHz}  ${lua_cfg_basic_setup_fdd}

    CNI-81991-A_B2_RRC_connection_estab_with_smallest_RRCSetup_with_ICS_with_PDU_session_FDD_Cell_center

[1][1.0] CNI-81991-A_B5_RRC_connection_estab_with_smallest_RRCSetup_IWK_with_RRC_reestablishment_FDD
    [Setup]    Commmon Test Setup    ${iphy_A_B2_FDD_20MHz}  ${scfc_filename_A_B2_FDD_20MHz_Re}  ${lua_cfg_basic_setup_fdd}

    CNI-81991-A_B5_RRC_connection_estab_with_smallest_RRCSetup_IWK_with_RRC_reestablishment_FDD

[1][1.0] CNI-81991-A_E2_RRC_connection_estab_failure_timeout_on_RRCReconfigurationComplete_TDD_20MHz
    [Setup]    Commmon Test Setup    ${iphy_TDD}  ${scfc_filename_A_E2_TDD_20MHz}  ${lua_cfg_basic_setup_tdd}

    CNI-81991-A_E2_RRC_connection_estab_failure_timeout_on_RRCReconfigurationComplete_TDD_20MHz

[1][1.0] CNI-81991-AB_B1_RRC_connection_estab_with_smallest_RRCSetup_and_BWP-1_in1st_RRCreconf_FDD
    [Setup]    Commmon Test Setup    ${iphy_AB_B1_FDD_20MHz}  ${scfc_filename_AB_B1_FDD_20MHz}  ${lua_cfg_AB_B1_FDD_20MHz}

    CNI-81991-AB_B1_RRC_connection_estab_with_smallest_RRCSetup_and_BWP-1_in1st_RRCreconf_FDD

[1][1.0] CNI-81991-AB_B1_RRC_connection_estab_with_smallest_RRCSetup_and_BWP-1_in1st_RRCreconf_TDD
    [Setup]    Commmon Test Setup    ${iphy_TDD}  ${scfc_filename_AB_B1_TDD_100MHz}  ${lua_cfg_basic_setup}

    CNI-81991-AB_B1_RRC_connection_estab_with_smallest_RRCSetup_and_BWP-1_in1st_RRCreconf_TDD
