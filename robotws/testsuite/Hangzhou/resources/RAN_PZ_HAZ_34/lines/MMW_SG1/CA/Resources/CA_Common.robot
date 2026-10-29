*** Settings ***
Documentation
...   Refine CA keywords
...   squad group: MMW_SG1
...   Author: Ding Binmei

Resource    ./WAs.robot
Resource    ./mobility.robot
Library    taf.analyzer.pcap    WITH NAME    pcap

*** Keywords ***
UE attach to Pcell and verify CA
    [Documentation]    Author: Wang Yixiang
    ...    UE attach to cell pcell and verify CA is added
    ...    check from CA from cpif log
    ...    2021-09-30 Ding Binmei: Refine keyword to remove un-used WA and parameters
    ...    ${ENB_Cellid} and ${pcell_id} are needed only when NSA_SA==NSA
    [Arguments]    ${ue_index}=${0}    ${tcpdump_log_name}=basic_l3_call    ${scell_addition_method}=blind
    ...    ${check_counter}=${False}    ${NSA_SA}=SA   ${ENB_Cellid}=${4}    ${pcell_id}=${PCELL_ID}
    run keyword if  '${NSA_SA}'=='NSA'    Make SgNBAddition on specific cell   LTE_ID=${ENB_Cellid}   gnb_ps_cell_index=${pcell_id}
    ${4G_check}    Set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    UE attach and verify CA    4G_check=${4G_check}    tcpdump_log_name=${tcpdump_log_name}  NSA_SA=${NSA_SA}
    ...    check_counter=${check_counter}    scell_addition_method=${scell_addition_method}    ue_index=${ue_index}

UE attach to Pcell and verify NO CA
    [Documentation]    Author: Wang Yixiang
    ...    UE attach to FDD cell and TDD add as scell
    ...    check from CA from cpif log
    ...    2021-10-08 Ding Binmei: Refine keyword to remove un-used WA and parameters
    ...    ${ENB_Cellid} and ${pcell_id} are needed only when NSA_SA==NSA
    [Arguments]    ${ue_index}=${0}   ${tcpdump_log_name}=basic_l3_call_no_ca
    ...    ${NSA_SA}=SA   ${ENB_Cellid}=${4}   ${pcell_id}=${PCELL_ID}
    run keyword if  '${NSA_SA}'=='NSA'      Make SgNBAddition on specific cell   LTE_ID=${ENB_Cellid}   gnb_ps_cell_index=${pcell_id}
    ${4G_check}    Set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    UE attach and verify NO CA    4G_check=${4G_check}    tcpdump_log_name=${tcpdump_log_name}    ue_index=${ue_index}
    ...   NSA_SA=${NSA_SA}

Data transmission only on PCell
    [Documentation]    Author: Cui Lingxue
    ...    Check throughput on all cells, the expectation is:
    ...        - DL: data transfer only on PCell, tput on SCell is 0.
    ...        - UL: data transfer only on PCell, tput on SCell is 0.
    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},0
    ...    ul_cell_id=${PCELL_ID},${SCELL_ID}    exp_ul=${PCELL_EXP_UL},0

Wait until cluster ready based on NSA_SA type
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${NSA_SA}=SA    ${is_need_to_setup_gnb_connection}=${True}        ${connection}=GNB_OAM    ${timeout}=${TIMER_FOR_CELL_ON_AIR}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    Wait until cluster is on cell on air status    timeout=${timeout}    is_all_cells_checking_needed=${True}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}    connection=${connection}
