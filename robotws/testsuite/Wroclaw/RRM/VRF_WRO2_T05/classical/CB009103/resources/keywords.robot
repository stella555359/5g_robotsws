*** Settings ***
Documentation
...   author: VRF_WRO2_T05

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.py  WITH NAME  messg
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.py

*** Keywords ***
Set initial attenuation for 9103-E
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=0
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Sleep    3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=0
    Log to Console    >Attenuation for 9103-E prepared. AEHC-1,AHFIB-1,AHFIB-2,ext-AHLOA-1 are deattenuated.<

Set initial attenuation for 9103-G
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=0
    Sleep    3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Sleep    3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep  3s
    Log to Console    >Attenuation for 9103-E prepared. AEHC-1,AHFIB-1,AHFIB-2,ext-AHLOA-1 are deattenuated.<

Add flags to sw config CB009103-B t410
    [Documentation]    0x8900AE = 1 # rdIntergnbStepwiseSCellAddition = enabled
    ${sw}=  coam.get_software_info  connection=cOAM
    ${flags_to_add}  Set variable    0x8900AE = 1
    add_flag_to_swconfig    swconfig_backup    ${flags_to_add}    reset=${True}    sw_config_path=/ffs/run/swconfig.txt

Add flags to sw config CB009103-B t186
    [Documentation]    0x8900AE = 1 # rdIntergnbStepwiseSCellAddition = enabled
    ADMIN CLI remote connection  10.44.149.65
    ${sw}=  coam.get_software_info  connection=remote_admin
    ${flags_to_add}  Set variable  0x8900AE = 1
    add_flag_to_swconfig  swconfig_backup_t186  ${flags_to_add}  reset=${True}  sw_config_path=/ffs/run/swconfig.txt
    ...  hostname=10.44.137.49  connection=remote_admin
    ADMIN CLI disconnection  connection=remote_admin

Verify PM Counters 9103-B Prime GNB
    [Arguments]  ${cell}=1
    Log to console   Waiting for counters to appear, please wait...
    Sleep   240s
    ${counters}                    Read Counters Values 9103-B
    ${IGNB_CA_ATT_SA_REJ}          Get Counter Value From Single Cell        ${counters}     ${cell}    M55118C11007
    Should Be True   1<=${IGNB_CA_ATT_SA_REJ}

Verify PM Counters 9103-B External GNB
    log to console    Verify PM counter values External GNB
    ${counters}       Read Counters Values 9103-B Ext
    ${IGNB_CA_ADD_REQ_SA_REJ_ADJ}        Verify 8140 BTS counter                 ${counters}    M55199C00002    260
    ${IGNB_CA_SCELL_ADMI_UNSUCC_SA}      Get Counter Value From Single Cell       ${counters}     4    M55138C03503
    Should Be True      1<=${IGNB_CA_ADD_REQ_SA_REJ_ADJ}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_UNSUCC_SA}

Read Counters Values 9103-B
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55118C11007
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read Counters Values 9103-B Ext
    ${counters_values}=   Create List
    Collect counters ext gnb   n_last=8
    ${stream_name}=     Get stream name
    @{counters}=    Create list  M55138C03503    M55199C00002
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 9103-E Prime GNB
    [Arguments]  ${cell}=301
    Log to console   Waiting for counters to appear, please wait...
    Sleep   240s
    ${counters}                    Read Counters Values 9103-E
    ${DUR_UL_SCELL_SCHED_SUSP}         Get Counter Value From Single Cell    ${counters}    ${cell}    M55316C00001
    ${DUR_UL_SCELL_SCHED_SUSP_DNOM}    Get Counter Value From Single Cell    ${counters}    ${cell}    M55316C00002
    ${SCELL_SUSP_RECOV_SA}             Get Counter Value From Single Cell    ${counters}    ${cell}    M55316C15016
    ${UL_RLC_PDU_VOL_RX_SEC_PATH}      get_counter_value_from_single_cell    ${counters}    21         M55316C14002
    Should Be True   1>${DUR_UL_SCELL_SCHED_SUSP}
    Should Be True   1>${DUR_UL_SCELL_SCHED_SUSP_DNOM}
    Should Be True   1>${SCELL_SUSP_RECOV_SA}
    Should Be True   10000<=${UL_RLC_PDU_VOL_RX_SEC_PATH}

Read Counters Values 9103-E
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55316C00001    M55316C00002    M55316C15016    M55316C14002
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 9103-E External GNB
    log to console    Verify PM counter values External GNB
    ${counters}       Read Counters Values 9103-E Ext
    ${IGNB_CA_SCELL_ADMI_REQ_SA}         Get Counter Value From Single Cell      ${counters}     1      M55138C03501
    ${IGNB_CA_SCELL_ADMI_SUCC_SA}        Get Counter Value From Single Cell      ${counters}     1      M55138C03502
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_REQ_SA}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_SUCC_SA}

Read Counters Values 9103-E Ext
    ${counters_values}=   Create List
    Collect counters ext gnb   n_last=8
    ${stream_name}=     Get stream name
    @{counters}=    Create list  M55138C03501    M55138C03502
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read Counters Values 9103-G
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55349C00031    M55349C00037    M55310C01022    M55349C00023    M55316C03005
    ...    M55118C00103
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 9103-G
    [Arguments]  ${cell}=1
    Log to console   Waiting for counters to appear, please wait...
    Sleep   300s
    ${counters}    Read Counters Values 9103-G
    ${DL_RLC_TIM_UE_TPUT_FR1_SA_6CC}    Get Counter Value From Single Cell    ${counters}    ${cell}    M55349C00037
    ${DL_RLC_VOL_UE_TPUT_FR1_SA_6CC}    Get Counter Value From Single Cell    ${counters}    ${cell}    M55349C00031
    ${IGNB_PDU_DL_VOL_CA_PCELL}         Get Counter Value From Single Cell    ${counters}    ${cell}    M55310C01022
    ${IGNB_RLC_PDU_VOL_TX_SEC}          Get Counter Value From Single Cell    ${counters}    ${cell}    M55349C00023
    ${PSCELL_UE_5_ACT_SCELL_DL}         Get Counter Value From Single Cell    ${counters}    ${cell}    M55316C03005
    ${UE_SCELL_ACROSS_2_GNB_SA}         Get Counter Value From Single Cell    ${counters}    ${cell}    M55118C00103
    Should Be True   10<${DL_RLC_TIM_UE_TPUT_FR1_SA_6CC}
    Should Be True   100.000<${DL_RLC_VOL_UE_TPUT_FR1_SA_6CC}
    Should Be True   100<${IGNB_PDU_DL_VOL_CA_PCELL}
    Should Be True   100<${IGNB_RLC_PDU_VOL_TX_SEC}
    Should Be True   1<${PSCELL_UE_5_ACT_SCELL_DL}
    Should Be True   1<${UE_SCELL_ACROSS_2_GNB_SA}
