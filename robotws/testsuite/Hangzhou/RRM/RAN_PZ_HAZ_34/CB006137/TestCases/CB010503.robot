*** Settings ***
Documentation    10503 Cases based on 8406 frame structure
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006137/Resources/CB006137_keywords.robot

Force Tags        5G_RRM
...   PY36    RF50

Suite Setup        Suite preparation
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB010503_01_US01_FDD_20Mhz_TDD_100Mhz_UL_DL_Traffic_BF_Disabled_Blind_ScellActivated
    [Tags]    CRT_TRUNK
    [Documentation]   author: Fang ludan This case is to verify if peak throughput can be reached on both UL and DL.
    ...    The execution order will be:
    ...      1) UE attach and verify no scell addition since CB008311 is enabled
    ...      2) Start UL traffic and verify UL throughput: No UL CA
    ...      3) Stop UL traffic
    ...      4) Start DL traffic and verify DL throughput: DL CA exist
    ...      5) Start UL traffic and verify bi-direction throughput
    ...      6) Stop data transmission and detach UE.
    [Setup]    6137 Case setup    dict_params_to_modify=${RESTAPI_ACT_CB008311_DICT}
    ULCA_peak_tput_verification    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}        is_btslog_required=${False}
    ...    restapi_restore_nidd=${RESTAPI_DISABLE_CB008311_BTS_LEVEL}


*** Keywords ***
Suite preparation
    set suite variable    ${INIT_PA}    ${INIT_PA_F1_T1_F2_T3}
    6137 Suite preparation    cell_chbw_config=4CC_F20M_F10M_100M_60M_10503
    ...    pa_values_mapping=${INIT_PA}
    ...    ca_group_mapping_3cc=${None}
    ...    ca_group_mapping_4cc=${F1_T1_F2_T3_4CC_CA_GROUP_COMMON}
    Set tput expectation for suite level

Set tput expectation for suite level
    ${EXP_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_T100M_4x4_256QAM_8406}    ${EXP_DL_T60M_4x4_256QAM_8406}
    ${EXP_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    ${EXP_UL_T100M_2x2_64QAM_8406}    -1
    ${EXP_DL_INDIV_NO_CA}    Create List    ${EXP_DL_F20M_2x2_256QAM}    0    0
    ${EXP_UL_INDIV_NO_CA}    Create List    ${EXP_UL_F20M_2x2_64QAM}    0    -1
    run keyword if    '${CC_NUM}'=='4CC'    run keywords
    ...           insert_into_list    list_=${EXP_DL_INDIV}    index=-1    value=${EXP_DL_F10M_2x2_256QAM}
    ...    AND    append_to_list    ${EXP_UL_INDIV}    -1
    ...    AND    append_to_list    ${EXP_DL_INDIV_NO_CA}    0
    ...    AND    append_to_list    ${EXP_UL_INDIV_NO_CA}    -1

    # Bellow total tput values are only used in peak test cases, whose result is uploaded to CI power BI
    ${EXP_DL_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_DL_INDIV}
    ${EXP_UL_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_UL_INDIV}
    ${EXP_DL_INDIV_NO_CA_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_DL_INDIV_NO_CA}
    ${EXP_UL_INDIV_NO_CA_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_UL_INDIV_NO_CA}

    Set suite variable    ${EXP_DL_INDIV}
    Set suite variable    ${EXP_UL_INDIV}
    Set suite variable    ${EXP_DL_INDIV_NO_CA}
    Set suite variable    ${EXP_UL_INDIV_NO_CA}
    Set suite variable    ${EXP_DL_TOTAL}
    Set suite variable    ${EXP_UL_TOTAL}
    Set suite variable    ${EXP_DL_INDIV_NO_CA_TOTAL}
    Set suite variable    ${EXP_UL_INDIV_NO_CA_TOTAL}
