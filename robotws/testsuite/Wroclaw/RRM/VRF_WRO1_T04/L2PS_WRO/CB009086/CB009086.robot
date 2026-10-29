*** Settings ***
Documentation
...   CB009086 Test cases regression - CRT
...   Topology - CLOUD_5G_I_MP_AP_LO
...   Variant - SANSA_FS_CPRI_CMWV_FDD
...   author: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/resources/9086_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/resources/9086_keywords.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/CB009086-B-B1-1.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/CB009086-B-B1-2.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/CB009086-B-B1-3.robot


Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_TDD    CRT     SBTS00

Suite Setup    Start Default Logging

Test Teardown    Run Keywords    Stop All Data Transfers And Detach UE SA
...              AND             Stop Default Processes And Gather Logs And Compress Logs
...              AND             Send Configuration ID To Scout

*** Variables ***
${iphy_B1}=                       ${CURDIR}/config/iphy.xml

${scfc_filename_B1}=              CB009086_B_B1_new.xml

${lua_cfg_B1}=                    ${CURDIR}/config/basic_setup_9086_B_B1.cfg
${lua_cfg_B1_3}=                  ${CURDIR}/config/basic_setup_9086_B_B1_3.cfg

@{SWCONFIG_FLAGS_1}=     0x59006a = 0    0x58057a = 4    0x58057c = 0x1800000    0x58057d = 0x400
@{SWCONFIG_FLAGS_2}=     0x59006a = 1    0x58057a = 4    0x58057c = 0x1800000    0x58057d = 0x400

*** Test Cases ***
[1][1.0] CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_2_DL_layers_and_CRI-RI-CQI_with_PMI_reporting
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_B1}  ${scfc_filename_B1}  ${lua_cfg_B1}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_1}

    CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_2_DL_layers_and_CRI-RI-CQI_with_PMI_reporting

[1][1.0] CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_2_DL_layers_and_CRI-RI-CQI_wo_PMI_reporting
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_B1}  ${scfc_filename_B1}  ${lua_cfg_B1}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_2}

    CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_2_DL_layers_and_CRI-RI-CQI_wo_PMI_reporting

[1][1.0] CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_4_DL_layers_and_CRI-RI-CQI_with_PMI_reporting
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_B1}  ${scfc_filename_B1}  ${lua_cfg_B1_3}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_1}

    CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_4_DL_layers_and_CRI-RI-CQI_with_PMI_reporting
