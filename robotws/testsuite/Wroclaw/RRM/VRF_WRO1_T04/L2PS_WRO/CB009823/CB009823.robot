*** Settings ***
Documentation
...   CB009823 Test cases regression - CRT
...   Topology - CLOUD_5G_I_LO_AP_LO
...   Variant - SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author:  Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009823/CB009823_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/webem_alarms.py
Library      CB009823_verify.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009823/CB009823_A_1070_const.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009823/CB009823_A_1116_transmission.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009823/CB009823_A_1208_transmission_regardles_of_RI.robot


Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    RAN_5G    RAN_5G_TDD    CRT     SBTS00

Suite Setup    Start Default Logging

Suite Teardown   Print Active Alarms

Test Teardown    Run Keywords    Stop Tcp Pcap
...              AND             Stop And Teardown PCMD
...              AND             Stop All Data Transfers And Detach UE
...              AND             Send Configuration ID To Scout
...              AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${iphy}=                            ${CURDIR}/config/AEQE_iphy.xml

${scfc_filename_1070}=              full_CB009823_A_1070.xml
${scfc_filename_1116}=              full_CB009823_A_1116_100mhz.xml
${scfc_filename_1208}=              full_CB009823_1208_100MHz.xml

${lua_cfg}=                         ${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

@{L2PS_RI_DEBUG_1070_1116}=           0x58057A = 4
...                                   0x580582 = 3
...                                   0x58057b = 8
...                                   0x58057f = 72
...                                   0x3F007C = 1500

@{L2PS_RI_DEBUG_1208}=                0x58057A = 4 # rdFeatureFlagBitmapLevel
...                                   0x580582 = 3 # rdFeatureFlagBitmap7
...                                   0x58057f = 74 # rdFeatureFlagBitmap4
...                                   0x58057b = 8 # rdFeatureFlagBitmap0
...                                   0x3F007C = 1000

*** Test Cases ***
[1][1.0] CB009823-A3_Start_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001070
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy}  ${scfc_filename_1070}  ${lua_cfg}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{L2PS_RI_DEBUG_1070_1116}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup X2 Link
    ...        AND             Start PCMD

    CB009823-A3_Start_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001070

[1][1.0] CB009823-A1_Start_RIMRS_transmission_and_RS1_detection_depending_on_RI_enabled_5GC001116_4GP_0ms_shift
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy}  ${scfc_filename_1116}  ${lua_cfg}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{L2PS_RI_DEBUG_1070_1116}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup X2 Link
    ...        AND             Start PCMD

    CB009823-A1_Start_RIMRS_transmission_and_RS1_detection_depending_on_RI_enabled_5GC001116_4GP_0ms_shift

[1][1.0] CB009823-A3_Start_and_stop_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001208
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy}  ${scfc_filename_1208}  ${lua_cfg}
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{L2PS_RI_DEBUG_1208}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup X2 Link
    ...        AND             Start PCMD

    CB009823-A3_Start_and_stop_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001208
