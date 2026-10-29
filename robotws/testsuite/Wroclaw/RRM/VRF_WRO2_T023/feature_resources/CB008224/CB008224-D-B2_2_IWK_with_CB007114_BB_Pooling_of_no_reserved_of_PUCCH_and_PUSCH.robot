*** Settings ***
Documentation    Keywords for the CB008224

Library     ta5g_testline_management
Library     ute_wtssim
Library     ta5g_pm_counters


*** Variables ***
@{ue_ids_1-5}=     1    2    3    4    5
@{ue_ids_6-10}=    6    7    8    9    10

@{GW_IDs}=    3    3    4    4    5    5    6    6    6    6

${PCELL_ID1}=    1
${PCELL_ID2}=    2

${GNB_ID} =    2


*** Keywords ***
TC__CB008224-D-B2_2_IWK_with_CB007114_BB_Pooling_of_no_reserved_of_PUCCH_and_PUSCH_Sched_UEs_for_SDL_Cell_with_load_metric
    Attach Multiple UEs And Verify Establishing PDU Sessions And Start Data Traffic    ue_ids=${ue_ids_1-5}
    ...    gw_ids=${GW_IDs}    cell_id=${PCELL_ID1}
    Attach Multiple UEs And Verify Establishing PDU Sessions And Start Data Traffic    ue_ids=${ue_ids_6-10}
    ...    gw_ids=${GW_IDs}    cell_id=${PCELL_ID2}
    Waiting For Stability Data Traffic For All Ues
    Verify PM Counters Max Number of UEs Scheduled Per Slot in DL and UL

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:MME_SIM    ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:EPCsim    ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:S11    ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2U    ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_S1    ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_XC2    ip_with_mask=10.0.1.137/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:MME_SIM    ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:EPCsim    ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:S11    ip_with_mask=10.0.1.134/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB_X2U    ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB_S1    ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB_XC2    ip_with_mask=10.0.1.137/24

Attach Multiple UEs And Verify Establishing PDU Sessions And Start Data Traffic
    [Arguments]    ${ue_ids}    ${gw_ids}    ${cell_id}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Attach UE And Establish PDU Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_id}    enb_id=${gnb_id}
        ...                                    pdu_id=1    gw_id=${gw_ids}[${ue_index}]
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=1 dir=dl mbps=25 trf_id=1
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=1 dir=ul mbps=25 trf_id=1
    END

Verify PM Counters Max Number of UEs Scheduled Per Slot in DL and UL
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55308C17002    4    MAX_SCHED_UE_PDSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55308C17002    4    MAX_SCHED_UE_PDSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55308C17002    4    MAX_SCHED_UE_PDSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55308C18002    4    MAX_SCHED_UE_PUSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55308C18002    4    MAX_SCHED_UE_PUSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55308C18002    0    MAX_SCHED_UE_PUSCH
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
        ...    file_path=${pm_counter_file}

Waiting For Stability Data Traffic For All Ues
    Sleep    250s
