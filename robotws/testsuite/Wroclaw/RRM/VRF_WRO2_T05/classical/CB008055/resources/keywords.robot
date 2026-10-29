*** Settings ***
Documentation
...   author: Karol Palac
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/phase_shifter/ps.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.py

*** Keywords ***
Read counters value 8055-A
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list    M55118C02014    M55118C02015    M55118C02016    M55138C00048    M55138C00049
    ...    M55139C00023    M55139C00024    M55118C11054    M55118C11064    M55138C03513    M55138C03520
    ...    M55139C05505    M55139C05512    M55156C00026    M55118C07510
    #    M55349C00030    M55349C00036
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8055-A
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 8055-A
    ${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C02014
    ${RRC_RECONF_ADD4DLSCELL_ATT_SA}     get_counter_value_from_single_cell   ${counters}  800    M55118C02015
    ${UE_PCELL_4_CONF_SCELL_DL_SA}       get_counter_value_from_single_cell   ${counters}  800    M55118C02016
    ${GNB_SCELL_4_ADMI_REQ_SA}           get_counter_value_from_single_cell   ${counters}  800    M55138C00048
    ${GNB_SCELL_4_ADMI_SUCC_SA}          get_counter_value_from_single_cell   ${counters}  800    M55138C00049
    ${GNB_DU_SCELL_4_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55139C00023
    ${GNB_DU_SCELL_4_ADMI_SUCC_SA}       get_counter_value_from_single_cell   ${counters}  800    M55139C00024
    ${GNB_DL_SCELL_4_CONFIG_REQ_SA}      get_counter_value_from_single_cell   ${counters}  800    M55118C11054
    ${GNB_DL_SCELL_4_CONFIG_SUCC_SA}     get_counter_value_from_single_cell   ${counters}  800    M55118C11064
    ${GNB_DL_SCELL_4_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55138C03513
    ${GNB_DL_SCELL_4_ADMI_SUCC_SA}       get_counter_value_from_single_cell   ${counters}  800    M55138C03520
    ${GNB_DU_DL_SCELL_4_ADMI_REQ_SA}     get_counter_value_from_single_cell   ${counters}  800    M55139C05505
    ${GNB_DU_DL_SCELL_4_ADMI_SUCC_SA}    get_counter_value_from_single_cell   ${counters}  800    M55139C05512
    ${MAX_UE_PCELL_4_CONF_SCEL_DL_SA}    get_counter_value_from_single_cell   ${counters}  800    M55156C00026
#    ${DL_RLC_VOL_UE_TPUT_FR1_SA_5CC}     get_counter_value_from_single_cell   ${counters}  800    M55349C00030
#    ${DL_RLC_TIM_UE_TPUT_FR1_SA_5CC}     get_counter_value_from_single_cell   ${counters}  800    M55349C00036
    ${UE_SCELL_4_CONF_SCELL_DL_SA_1}     get_counter_value_from_single_cell   ${counters}  200    M55118C07510
    ${UE_SCELL_4_CONF_SCELL_DL_SA_2}     get_counter_value_from_single_cell   ${counters}  210    M55118C07510
    ${UE_SCELL_4_CONF_SCELL_DL_SA_3}     get_counter_value_from_single_cell   ${counters}  215    M55118C07510
    ${UE_SCELL_4_CONF_SCELL_DL_SA_4}     get_counter_value_from_single_cell   ${counters}  700    M55118C07510
    Should Be True      1<=${RRC_RECONF_ADD4DLSCELL_SUCC_SA}
    Should Be True      1<=${RRC_RECONF_ADD4DLSCELL_ATT_SA}
    Should Be True      1<=${UE_PCELL_4_CONF_SCELL_DL_SA}
    Should Be True      1<=${GNB_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DL_SCELL_4_CONFIG_REQ_SA}
    Should Be True      1<=${GNB_DL_SCELL_4_CONFIG_SUCC_SA}
    Should Be True      1<=${GNB_DL_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DL_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_DL_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_DL_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${MAX_UE_PCELL_4_CONF_SCEL_DL_SA}
#    Should Be True      1<=${DL_RLC_VOL_UE_TPUT_FR1_SA_5CC}
#    Should Be True      1<=${DL_RLC_TIM_UE_TPUT_FR1_SA_5CC}
    Should Be True      1<=${UE_SCELL_4_CONF_SCELL_DL_SA_1}
    Should Be True      1<=${UE_SCELL_4_CONF_SCELL_DL_SA_2}
    Should Be True      1<=${UE_SCELL_4_CONF_SCELL_DL_SA_3}
    Should Be True      1<=${UE_SCELL_4_CONF_SCELL_DL_SA_4}

Deattenuate scells
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_7}  value=0
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_2}  value=0
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_1}  value=0

Read counters value 8055-B
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list    M55118C00004    M55118C00001    M55118C00013    M55138C03504    M55138C03507
    ...    M55139C03003    M55139C03006    M55118C11055    M55118C11065    M55138C03514    M55138C03521    M55139C05506
    ...    M55139C05513    M55156C00027    M55118C00018    # M55349C00031    M55349C00037
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8055-B
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 8055-B
    ${RRC_RECONF_ADD5DLSCELL_SUCC_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C00004
    ${RRC_RECONF_ADD5DLSCELL_ATT_SA}     get_counter_value_from_single_cell   ${counters}  800    M55118C00001
    ${UE_PCELL_5_CONF_SCELL_DL_SA}       get_counter_value_from_single_cell   ${counters}  800    M55118C00013
    ${GNB_SCELL_5_ADMI_REQ_SA}           get_counter_value_from_single_cell   ${counters}  800    M55138C03504
    ${GNB_SCELL_5_ADMI_SUCC_SA}          get_counter_value_from_single_cell   ${counters}  800    M55138C03507
    ${GNB_DU_SCELL_5_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55139C03003
    ${GNB_DU_SCELL_5_ADMI_SUCC_SA}       get_counter_value_from_single_cell   ${counters}  800    M55139C03006
    ${GNB_DL_SCELL_5_CONFIG_REQ_SA}      get_counter_value_from_single_cell   ${counters}  800    M55118C11055
    ${GNB_DL_SCELL_5_CONFIG_SUCC_SA}     get_counter_value_from_single_cell   ${counters}  800    M55118C11065
    ${GNB_DL_SCELL_5_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55138C03514
    ${GNB_DL_SCELL_5_ADMI_SUCC_SA}       get_counter_value_from_single_cell   ${counters}  800    M55138C03521
    ${GNB_DU_DL_SCELL_5_ADMI_REQ_SA}     get_counter_value_from_single_cell   ${counters}  800    M55139C05506
    ${GNB_DU_DL_SCELL_5_ADMI_SUCC_SA}    get_counter_value_from_single_cell   ${counters}  800    M55139C05513
    ${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}    get_counter_value_from_single_cell   ${counters}  800    M55156C00027
#    ${DL_RLC_VOL_UE_TPUT_FR1_SA_6CC}     get_counter_value_from_single_cell   ${counters}  800    M55349C00031
#    ${DL_RLC_TIM_UE_TPUT_FR1_SA_6CC}     get_counter_value_from_single_cell   ${counters}  800    M55349C00037
    ${UE_SCELL_5_CONF_SCELL_DL_SA_1}     get_counter_value_from_single_cell   ${counters}  100    M55118C00018
    ${UE_SCELL_5_CONF_SCELL_DL_SA_2}     get_counter_value_from_single_cell   ${counters}  200    M55118C00018
    ${UE_SCELL_5_CONF_SCELL_DL_SA_3}     get_counter_value_from_single_cell   ${counters}  210    M55118C00018
    ${UE_SCELL_5_CONF_SCELL_DL_SA_4}     get_counter_value_from_single_cell   ${counters}  215    M55118C00018
    ${UE_SCELL_5_CONF_SCELL_DL_SA_5}     get_counter_value_from_single_cell   ${counters}  700    M55118C00018
    Should Be True      1<=${RRC_RECONF_ADD5DLSCELL_SUCC_SA}
    Should Be True      1<=${RRC_RECONF_ADD5DLSCELL_ATT_SA}
    Should Be True      1<=${UE_PCELL_5_CONF_SCELL_DL_SA}
    Should Be True      1<=${GNB_SCELL_5_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_5_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_5_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_5_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DL_SCELL_5_CONFIG_REQ_SA}
    Should Be True      1<=${GNB_DL_SCELL_5_CONFIG_SUCC_SA}
    Should Be True      1<=${GNB_DL_SCELL_5_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DL_SCELL_5_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_DL_SCELL_5_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_DL_SCELL_5_ADMI_SUCC_SA}
    Should Be True      1<=${MAX_UE_PCELL_5_CONF_SCEL_DL_SA}
#    Should Be True      1<=${DL_RLC_VOL_UE_TPUT_FR1_SA_6CC}
#    Should Be True      1<=${DL_RLC_TIM_UE_TPUT_FR1_SA_6CC}
    Should Be True      1<=${UE_SCELL_5_CONF_SCELL_DL_SA_1}
    Should Be True      1<=${UE_SCELL_5_CONF_SCELL_DL_SA_2}
    Should Be True      1<=${UE_SCELL_5_CONF_SCELL_DL_SA_3}
    Should Be True      1<=${UE_SCELL_5_CONF_SCELL_DL_SA_4}
    Should Be True      1<=${UE_SCELL_5_CONF_SCELL_DL_SA_5}

Read counters value 8055-C
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list    M55316C14001    M55316C14002    M55316C14003    M55316C14004    M55316C04001
    ...    M55316C06001    M55316C02001    M55316C04000    M55316C06000    M55316C09000    M55316C09001    M55316C01002
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8055-C
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 8055-C
    ${UL_RLC_PDU_VOL_RX_PRI_PATH}      get_counter_value_from_single_cell   ${counters}  800    M55316C14001
    ${SAMPLES_UL_UE_AMOUNTS}           get_counter_value_from_single_cell   ${counters}  800    M55316C01002
    ${UL_RLC_PDU_RX_PRI_PATH}          get_counter_value_from_single_cell   ${counters}  800    M55316C14003
    ${PSCELL_UE_1_ACT_SCELL_UL}        get_counter_value_from_single_cell   ${counters}  800    M55316C04001
    ${MAX_PSCELL_UE_1_ACT_SCELL_UL}    get_counter_value_from_single_cell   ${counters}  800    M55316C06001
    ${UE_PSCELL_ACT_SCELL_UL}          get_counter_value_from_single_cell   ${counters}  800    M55316C02001
    ${PSCELL_UE_0_ACT_SCELL_UL}        get_counter_value_from_single_cell   ${counters}  800    M55316C04000
    ${MAX_PSCELL_UE_0_ACT_SCELL_UL}    get_counter_value_from_single_cell   ${counters}  800    M55316C06000
    ${UL_RLC_PDU_RX_SEC_PATH}          get_counter_value_from_single_cell   ${counters}  100    M55316C14004
    ${UL_RLC_PDU_VOL_RX_SEC_PATH}      get_counter_value_from_single_cell   ${counters}  100    M55316C14002
    ${SCELL_ACTIVATIONS}               get_counter_value_from_single_cell   ${counters}  100    M55316C09000
    ${SCELL_DEACT_BUFFER_STATUS}       get_counter_value_from_single_cell   ${counters}  100    M55316C09001

    Should Be True      1<=${UL_RLC_PDU_VOL_RX_PRI_PATH}
    Should Be True      1<=${UL_RLC_PDU_VOL_RX_SEC_PATH}
    Should Be True      1<=${UL_RLC_PDU_RX_PRI_PATH}
    Should Be True      1<=${UL_RLC_PDU_RX_SEC_PATH}
    Should Be True      1<=${PSCELL_UE_1_ACT_SCELL_UL}
    Should Be True      1<=${MAX_PSCELL_UE_1_ACT_SCELL_UL}
    Should Be True      1<=${UE_PSCELL_ACT_SCELL_UL}
    Should Be True      1<=${PSCELL_UE_0_ACT_SCELL_UL}
    Should Be True      1<=${MAX_PSCELL_UE_0_ACT_SCELL_UL}
    Should Be True      1<=${SCELL_ACTIVATIONS}
    Should Be True      1<=${SCELL_DEACT_BUFFER_STATUS}
    Should Be True      1<=${SAMPLES_UL_UE_AMOUNTS}

Trigger A2 PCell Change
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=5
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=15
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=25
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=30
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=35
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=40
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=45
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=50
    Sleep    2s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=60
    Sleep    11s
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=0
    Log to Console    Triggered PCell Change

Read counters value 8055-D
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list    M55149C02501    M55149C02502
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8055-D
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 8055-D
    ${ATT_A2_IF_INTRA_DU_HO_SLICE}      get_counter_value_from_single_cell   ${counters}  260    M55149C02501
    ${SUCC_A2_IF_INTRA_DU_HO_SLICE}     get_counter_value_from_single_cell   ${counters}  260    M55149C02502
