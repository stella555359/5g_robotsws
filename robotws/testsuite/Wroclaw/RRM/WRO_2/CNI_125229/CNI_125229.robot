*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS25R1    CLOUD_5G_I_MP_AP_LOOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     CNI_125229_feature_keywords.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy

Suite Setup    Run Keywords    Configure Eth3 And Eth4 Interfaces    AND
...                            Install Bsr Package    AND
...                            Update And Put Iphy Xml    input_filepath=${iphy}    AND
...                            With Gnb Configuration    commissioning=${scfc}    AND
...                            Wait For Testline Icmp Echo Replies And Ssh Services    AND
...                            Start Default Logging    AND
...                            Wait For Gnb Environment Stabilization    AND
...                            Configure Wts Environment    lua_cfg=${wts_config}


*** Variables ***
${LOGS_COMPRESSION}=    ${True}

${iphy}=          ${CURDIR}/config/iphy.xml
${scfc}=          scf_TDD_ecpri_SA_NSA_100Mhz.xml
${wts_config}=    ${CURDIR}/config/singleAP_sansa_2_AP_12cell_SA_NSA_t2r4_n2.lua

@{UE_IDs}=      1      2      21     22     41     42     61     62     81     82     101    102
    ...         121    122    141    142    161    162    181    182    201    202    221    222
@{PDU_IDs}=     1    2     3    4    5    6    7    8    9    10    11    12    13    14    15    1    2    3    4    5    6    7    8    9
@{GW_IDs}=      1      2      21     22     41     42     61     62     81     82     101    102
    ...         121    122    141    142    161    162    181    182    201    202    221    222
@{CELL_IDs}=    1    1     2    2    3    3    4    4    5    5    6    6    7    7    8    8    9    9    10    10    11    11    12    12

${GNB_ID}=    2


*** Test Cases ***
CNI-125229_B_20_slots_NDM_SRS_periodicity_is_supported_for_SRS_configuration_for_SB_BF_for_2_UEs_in_12cell
    [Documentation]
    ...    Test for 12 cells/ABIP with allowSlowPrbPoolingStatNdmSrs = FALSE

    Attach Multiple Ues To The Different Cells And Start Data Traffic    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    gw_ids=${GW_IDs}    cell_ids=${CELL_IDs}    gnb_id=${GNB_ID}    inactive_timer=10

    [Teardown]    Run Keywords    Stop Data Traffic And Release Multiple Ues    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}
    ...    AND    Add Scout Data Info To Testcase
