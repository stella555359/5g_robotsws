*** Settings ***
Documentation
...   CB010784 Test cases regression - CRT
...   Topology - CLOUD_5G_I_LO_AP_LO
...   Variant - SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author:  Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_keywords.robot

Library      ../resources/Python/webem_alarms.py
Library      CB010784_keywords.py
Library      ute_admin_infomodel

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784-A_B2.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784-A_B3.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784-A_B4_GP6.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784-B_HighSpeed.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_C_C1.robot

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    RAN_5G    RAN_5G_TDD    CRT     SBTS00

Suite Setup      Start Default Logging

Suite Teardown   Print Active Alarms

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${iphy_A_B2}=                       ${CURDIR}/config/iphy_1AEQE_100M_addExtDelay_50.xml
${iphy_A_B3}=                       ${CURDIR}/config/iphy_1AEQE_100M_addExtDelay_20_ring_cell.xml
${iphy_A_B4}=                       ${CURDIR}/config/iphy_1AZQJ_1cell_100M_addExtDelay_150.xml
${iphy_B}=                          ${CURDIR}/config/iphy_1AEQE_addExtDelay_80_ring_cell.xml
${iphy_C}=                          ${CURDIR}/config/iphy_CB010784_C1_C2.xml

${scfc_filename_A_B2}=              CB010784_prach_148_addExtDelay_50_4DL2UL.xml
${scfc_filename_A_B3}=              CB010784_prach_146_addExtDelay_20_4DL2UL.xml
${scfc_filename_A_B4}=              CB010784_prach_145_addExtDelay_150_4DL4UL.xml
${scfc_filename_B}=                 scfc_10784_prach_161_addExtDelay_80_HighSpeed_ring_cell.xml
${scfc_filename_C}=                 scf_CB010784_C1_C2.xml

${lua_cfg_basic}=                   ${CURDIR}/config/basic_setup.cfg
${lua_cfg_B}=                       ${CURDIR}/config/basic_setup_HS.cfg
${lua_cfg_C}=                       ${CURDIR}/config/basic_setup_CB010784_C.cfg

*** Test Cases ***
[1][1.0] CB010784-A_B2_UE_call_to_regular_cell_with_3rdPS_SA_prach148
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_A_B2}  ${scfc_filename_A_B2}  ${lua_cfg_basic}
    ...        AND             ADMIN Setup Admin       alias=admin

    CB010784-A_B2_UE_call_to_regular_cell_with_3rdPS_SA_prach148

[1][1.0] CB010784-A_B3_UE_call_to_ring_cell_wo_3rdPS_addDelay20_NSA_prach146
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_A_B3}  ${scfc_filename_A_B3}  ${lua_cfg_basic}
    ...        AND             ADMIN Setup Admin       alias=admin

    CB010784-A_B3_UE_call_to_ring_cell_wo_3rdPS_addDelay20_NSA_prach146

[1][1.0] CB010784-A_B4_UE_call_to_regular_cell_with_3rdPS_SA_UEspecificCSIRS_GP6
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_A_B4}  ${scfc_filename_A_B4}  ${lua_cfg_basic}
    ...        AND             ADMIN Setup Admin       alias=admin

    CB010784-A_B4_UE_call_to_regular_cell_with_3rdPS_SA_UEspecificCSIRS_GP6

[1][1.0] CB010784-B_IWK1_HighSpeed_UE_call_to_ring_cell_wo_3rdPS_addDelay80_SA_prach161
    [Setup]    Run Keywords    Commmon Test Setup    ${iphy_B}  ${scfc_filename_B}  ${lua_cfg_B}
    ...        AND             Start Tshark With Alias

    CB010784-B_IWK1_HighSpeed_UE_call_to_ring_cell_wo_3rdPS_addDelay80_SA_prach161

[1][1.0] CB010784-C_IWK1_UE_call_to_ring_cell_with_reducedSSBsize_wo_3rdPS_addDelay90
    [Setup]    Run Keywords    Download AP MCshark Plugin
	...    	   AND             Commmon Test Setup    ${iphy_C}  ${scfc_filename_C}  ${lua_cfg_C}
	...    	   AND             Start AP L1l2bipLogs Collector
	...        AND             ADMIN Setup Admin       alias=admin

    CB010784-C_IWK1_UE_call_to_ring_cell_with_reducedSSBsize_wo_3rdPS_addDelay90
