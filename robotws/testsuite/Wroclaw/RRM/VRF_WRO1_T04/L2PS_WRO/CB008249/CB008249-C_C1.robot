*** Settings ***
Documentation
...   CB008249 Test cases regression - CRT
...   Topology - CLOUD_5G_I_LO_AP_LO
...   Variant - SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008249/CB008249_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/webem_alarms.py
Library      CB008249_keywords.py

Resource     ./CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001070_GP2_SA.robot
Resource     ./CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001116_GP4_3ms_NSA.robot
Resource     ./CB008249-C_C1_Robustness.robot

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CRT    SBTS00    RAN_5G

Suite Teardown   Print Active Alarms

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${iphy}=                            ${CURDIR}/config/iphy_AEQE_8249_C.xml

${scfc_filename_1070}=              full_cb008247_C_1070_SRS.xml
${scfc_filename_1116}=              full_cb008247_C_1116_SRS.xml
${scfc_filename_robustness}=        robustness_scf.xml

${lua_cfg_1070}=                    ${CURDIR}/config/basic_setup_8249-C_SA_SRS.cfg
${lua_cfg_1116}=                    ${CURDIR}/config/basic_setup_NSA.cfg

*** Test Cases ***
[1][1.0] CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001070_GP2_SA
    [Setup]    Commmon Test Setup    ${iphy}  ${scfc_filename_1070}  ${lua_cfg_1070}

    CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001070_GP2_SA

[1][1.0] CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001116_GP4_3ms_NSA
    [Setup]    Commmon Test Setup    ${iphy}  ${scfc_filename_1116}  ${lua_cfg_1116}

    CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001116_GP4_3ms_NSA

[1][1.0] CB008249-C_C1_Robustness
    [Setup]    Commmon Test Setup    ${iphy}  ${scfc_filename_robustness}  ${lua_cfg_1116}

    CB008249-C_C1_Robustness
