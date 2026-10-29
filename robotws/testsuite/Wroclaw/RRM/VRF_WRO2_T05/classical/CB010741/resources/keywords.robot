*** Settings ***
Documentation
...   author: Karol Palac

*** Keywords ***
Read counters value 10741-A_B9
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list    M55113C00025    M55138C03512    M55138C03513    M55138C03524    M55118C00089
    ...     M55118C00090    M55118C00094    M55118C00098    M55118C00097
    #    M55349C00030    M55349C00036
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   6  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 10741-A_B9
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 10741-A_B9
    ${SCELL_CONFIG_SUCC_UL_BUFFER_SA}    get_counter_value_from_single_cell   ${counters}  800    M55113C00025
    ${GNB_DL_SCELL_3_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55138C03512
    ${GNB_DL_SCELL_4_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55138C03513
    ${GNB_UL_SCELL_1_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  800    M55138C03524
    ${PCELL_DL_3_SCELL_CONFIG_DUR_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C00089
    ${PCELL_DL_4_SCELL_CONFIG_DUR_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C00090
    ${PCELL_UL_1_SCELL_CONFIG_DUR_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C00094
    ${SCELL_CONFIG_DUR_SA}               get_counter_value_from_single_cell   ${counters}  800    M55118C00098
    ${SCELL_CONFIG_RRC_RECNFG_DUR_SA}    get_counter_value_from_single_cell   ${counters}  800    M55118C00097

    Should Be True      1<=${SCELL_CONFIG_SUCC_UL_BUFFER_SA}
    Should Be True      1<=${GNB_DL_SCELL_3_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DL_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_UL_SCELL_1_ADMI_REQ_SA}
    Should Be True      1<=${PCELL_DL_3_SCELL_CONFIG_DUR_SA}
    Should Be True      1<=${PCELL_DL_4_SCELL_CONFIG_DUR_SA}
    Should Be True      1<=${PCELL_UL_1_SCELL_CONFIG_DUR_SA}
    Should Be True      1<=${SCELL_CONFIG_DUR_SA}
    Should Be True      1<=${SCELL_CONFIG_RRC_RECNFG_DUR_SA}

Deattenuate scells 10741
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_2}  value=40
    Sleep  1s
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_2}  value=20
    Sleep  1s
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_2}  value=0
