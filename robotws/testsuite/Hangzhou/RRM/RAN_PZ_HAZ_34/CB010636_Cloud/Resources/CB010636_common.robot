*** Settings ***
Documentation    author：Pengliang Wu
...              contact: pengliang.wu@nokia-sbell.com
...              squad group: PZ3 SG4


Library    taf.transport.ssh    WITH NAME    csn
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library    Process
Library    taf.converters.eventdecoder    WITH NAME    ctti
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu


*** Variables ***
${CU_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${DU_IP}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${DU_username}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${DU_password}        ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
${DU_OAM_IP_1}        ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${DU_OAM_username}    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${DU_OAM_password}    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${TEST_PC_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}   ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}
${vdu_namespace}      ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
${vcu_namespace}      ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
@{cell_list}    ${GNB_CELL_NAME}2    ${GNB_CELL_NAME}3    ${GNB_CELL_NAME}4    ${GNB_CELL_NAME}12    ${GNB_CELL_NAME}5    ${GNB_CELL_NAME}14
...    ${GNB_CELL_NAME}15

${tcpdump_filter}       nr-rrc.physCellId && nr-rrc.newUE_Identity
&{Non_CA_eligible}     ${5}=NonCA    ${7}=NonCA
${NRBTS}              ${GNB_NR_BTS_NAME}

${GAP_Acceptable}    2000

&{A_DL_Counters}    RLC_PDU_VOL_TX_NON_CA_SA=M55310C02021
...                 RLC_PDU_VOL_TX_PRI_SA_CA=M55310C02022
...                 RLC_PDU_VOL_TX_SEC_SA_CA_FR1=M55349C00022
...                 RLC_PDU_VOL_TX_SCELL_SA_CA=M55310C02024
...                 NR_RLC_PDU_DL_VOL_CA_PCELL=M55310C20001
...                 NR_RLC_PDU_DL_VOL_CA_SCELL=M55310C20000
...                 RLC_PDU_VOL_TX_NON_CA_NSA=M55310C02025
...                 RLC_PDU_VOL_TX_PRI_NSA_CA=M55310C02026
...                 RLC_PDU_VOL_TX_SEC_NSA_CA_FR1=M55349C00024
...                 RLC_PDU_VOL_TX_SCELL_NSA_CA=M55310C02028

&{A_UL_Counters}    RLC_PDU_VOL_RX_NON_CA_SA=M55310C02029
...                 RLC_PDU_VOL_RX_PRI_SA_CA=M55310C02030
...                 RLC_PDU_VOL_RX_SEC_SA_CA_FR1=M55349C00025
...                 RLC_PDU_VOL_RX_SCELL_SA_CA=M55310C02032
...                 UL_RLC_PDU_VOL_RX_PRI_PATH=M55316C14001
...                 UL_RLC_PDU_VOL_RX_SEC_PATH=M55316C14002
...                 RLC_PDU_VOL_RX_NON_CA_NSA=M55310C02033
...                 RLC_PDU_VOL_RX_PRI_NSA_CA=M55310C02034
...                 RLC_PDU_VOL_RX_SCELL_NSA_CA=M55310C02036

&{C_DL_Counters}    DL_RLC_PDU_VOL_UE_TPUT=M55349C03002
...                 DL_RLC_PDU_TIME_UE_TPUT=M55349C04002
...                 DL_MAC_SDU_VOL_UE_TPUT=M55309C00002
...                 DL_MAC_SDU_TIME_UE_TPUT=M55309C00003
...                 DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7=M55353C00002
...                 DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-7=M55353C00003
...                 DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-5=M55353C00002
...                 DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-5=M55353C00003
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00026
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00027
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_3CC=M55349C00028
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_4CC=M55349C00029
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_5CC=M55349C00030
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_1CC=M55349C00032
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_2CC=M55349C00033
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_3CC=M55349C00034
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_4CC=M55349C00035
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_5CC=M55349C00036
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_1CC=M55349C00038
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_2CC=M55349C00039
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_1CC=M55349C00040
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_2CC=M55349C00041

&{C_UL_Counters}    UL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00042
...                 UL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00043
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_1CC=M55349C00044
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_2CC=M55349C00045
...                 UL_RLC_TIME_UE_TPUT=M55349C04001
...                 UL_RLC_VOL_UE_TPUT_TOT=M55349C03001

&{D_DL_Counters}    DL_RLC_PDU_UE_TPUT_DENOM_FR1=M55349C00046

*** Keywords ***
Start SYSLOG On DU And Tcpdump On CU
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    #Start Capture tcpdump on Cloud CU    pcap_filename=tcpdump_cplane_cu
    Start Capture tcpdump on Cloud CU Via CU OAM
    Start Capture SYSLOG on Cloud DU    pod_filter=l2rt-a    syslog_filename=L2RT_SYSLOG
    Start Capture SYSLOG on Cloud DU    pod_filter=l2nrt    syslog_filename=L2HI_SYSLOG

Stop SYSLOG On DU And Tcpdump On CU
    #Stop Capture tcpdump on Cloud CU
    Stop Capture SYSLOG on Cloud DU    pod_filter=l2rt-a
    Stop Capture SYSLOG on Cloud DU    pod_filter=l2nrt

Dowload SYSLOG And Tcpdump
    [Arguments]    ${filter}=${tcpdump_filter}
    #Download tcpdump from Cloud CU    pcap_filename=tcpdump_cplane_cu
    Stop And Download Capture tcpdump on Cloud CU Via CU OAM
    ${du_l2rt_syslog_path}    Download syslog from Cloud DU    remote_path=/tmp    syslog_filename=L2RT_SYSLOG
    ${du_l2hi_syslog_path}    Download syslog from Cloud DU    remote_path=/tmp    syslog_filename=L2HI_SYSLOG
    ${txt_path}    Convert pcap to text    pcap_filename=tcpdump_cplane_cu    filter=${filter}
    [Return]    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}

Analysis SYSLOG And Tcpdump
    [Arguments]    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}
    get_dl_tput_from_syslog    path=${du_l2rt_syslog_path}
    get_ul_tput_from_syslog    path=${du_l2rt_syslog_path}
    log to console    l2hi log saved in: ${du_l2hi_syslog_path}
    ${ca_info}    get_rnti_and_ca_info    txt_file_path=${txt_path}
    log to console    [ca_info]:\n ${ca_info}
    [Return]    ${ca_info}

Get VDU PM Counters
    [Arguments]    ${counter_id_dict}    ${dist_name}    ${connection}=vdu_pm
    Log to console    get ${dist_name} counters from webui.
    vdu.connect_to    host=${DU_OAM_IP_1}    port=443   secure=${True}
    ...    username=${DU_OAM_username}    password=${DU_OAM_password}    connection_name=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${counter_value}    Create dictionary
    FOR    ${counter_name}    IN    @{counter_id_list}
        ${counter_id}    set variable    ${counter_id_dict}[${counter_name}]
        ${last_word}    String.Fetch From Right    ${counter_name}    marker=_
        ${counter_dist_name}     set variable if    'PMQAP' in '${counter_name}'    ${dist_name}/${last_word}    ${dist_name}
        ${counter_result}    vdu.get_counter_values
        ...    counter_id=${counter_id}
        ...    dimension_dn=${counter_dist_name}
        ...    vdu_connection=${connection}
        set to dictionary    ${counter_value}    ${counter_name}=${counter_result}
    END
    [Return]   ${counter_value}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=${connection}

Get VDU PM Counters Latest period time
    [Arguments]    ${counter_id_dict}    ${connection}=vdu_pm
    ${dist_name}    set variable    ${cell_list}[${0}]
    vdu.connect_to    host=${DU_OAM_IP_1}    port=443   secure=${True}
    ...    username=${DU_OAM_username}    password=${DU_OAM_password}    connection_name=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${counter_last_period_time_dict}    Create dictionary
    ${counter_start_time}    set variable    now
    FOR    ${counter_name}    IN    @{counter_id_list}
        ${counter_id}    set variable    ${counter_id_dict}[${counter_name}]
        ${counter_result}    vdu.get_counter_values
        ...    counter_id=${counter_id}
        ...    dimension_dn=${dist_name}
        ...    vdu_connection=${connection}
        ${counter_start_time}    _get_pm_data_strat_time    counter_result=${counter_result}
        Exit For Loop
    END
    set to dictionary    ${counter_last_period_time_dict}    start_time=${counter_start_time}
    [Return]   ${counter_last_period_time_dict}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=${connection}

_get_pm_data_strat_time
    [Arguments]    ${counter_result}
    ${counter_start_time}    set variable    now
    ${counter_length}    Get Length    ${counter_result}
    FOR    ${i}    IN RANGE    ${counter_length}-1    ${-1}    ${-1}
        ${counter_start_time}    set variable    ${counter_result}[${i}][start_time]
        Exit For Loop
    END
    [Return]    ${counter_start_time}


###### From pengliang CB010636 robot #######
Get A_Counter From MacSubPdu Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl    ${isDefaultCA}=${True}
    log to console    Get CB010636-A: ${direction} counters from MacSubPduTX(RX)Am18.csv
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.getMacSubPduAm18    caInfo=${ca_info}    channelInfo=${Non_CA_eligible}    isDefaultCA=${isDefaultCA}

Get C_Counter From MacPduMuxReq Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl
    log to console    Get CB010636-C: ${direction} counters from MacPduMuxReq.csv
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.get_mac_sdu_value_from_L2LO_ttitrace_log
    dealCounter.get_RLC_value_from_L2LO_ttitrace_log    path=${OUTPUT_DIR}/${TEST NAME}    ca_info=${ca_info}
    dealCounter.get_RLC_per_CC_DL_counters    path=${OUTPUT_DIR}/${TEST NAME}    ca_info=${ca_info}    output_path=${OUTPUT_DIR}/${TEST NAME}

Get D_Counter From MacPduMuxReq Csv Log
    [Arguments]    ${csv_path}    ${ca_info}    ${direction}=dl
    log to console    Get CB010636-D: ${direction} counters from MacPduMuxReq.csv
    dealCounter.setCsvPath    csv_path=${csv_path}
    dealCounter.get_RLC_time_DENOM_from_L2LO_tti    ca_info=${ca_info}

Check CB010636_A Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl    ${isDefaultCA}=${True}
    log to console    \n[Get CB010636-A ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get A_Counter From MacSubPdu Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}    isDefaultCA=${isDefaultCA}
    log to console    \n[Get CB010636-A ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${result}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}    outputpath=${OUTPUT_DIR}/${TEST NAME}/
    ...    gap=${GAP_Acceptable}
    Run Keyword And Continue On Failure    Should be true    ${result}    msg=CB010636_A Some ${direction} Counters eroor

Check CB010636_C Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl    ${percc_flag}=${True}
    log to console    \n[Get CB010636-C ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get C_Counter From MacPduMuxReq Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}
    log to console    \n[Get CB010636-C ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${burst_length}    dealCounter.getBurstLength
    log to console    burst_length: ${burst_length}
    ${dl_legacy_check}    compare_percc_counter_with_legacy    web_counter_dict=${all_cell_counter_dict}    dlul=${direction}
    ...    burst_id_length=${burst_length}
    Run Keyword And Continue On Failure    Should be True    ${dl_legacy_check}    msg=CB010636_C_DL Counters mismatch with legacy
    ${result}    run keyword if    ${percc_flag}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}
    ...    outputpath=${OUTPUT_DIR}/${TEST NAME}/    gap=${GAP_Acceptable}    subfeature=C
    run keyword if    ${percc_flag}    run keyword and ignore error    Should be true    ${result}
    ...    msg=CB010636_C Some ${direction} Counters eroor

Check CB010636_C UL Counter between Log and Webui
    [Arguments]  ${before_counter_time}    ${nsa_ul_cell}=${Empty}
    log to console    \n[Get CB010636-C ul counters from WEBUI]:
    ${c_ul_counters_dict}    Get All NRCELL Counter From VDU    counter_dict=${C_UL_Counters}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    dict_to_csv    data=${c_ul_counters_dict}    output_path=${OUTPUT_DIR}/${TEST NAME}/CB010636_C_UL_Counters.csv
    ${ul_result}    compare_percc_counter_with_legacy    web_counter_dict=${c_ul_counters_dict}    dlul=ul    nsa_ul_cell=${nsa_ul_cell}
    Run Keyword And Continue On Failure    Should be True    ${ul_result}    msg=CB010636_C_UL Counters mismatch with legacy

Check CB010636_D Counter between Log and Webui
    [Arguments]    ${csv_path}    ${ca_info}    ${counter_dict}    ${before_counter_time}    ${direction}=dl
    log to console    \n[Get CB010636-D ${direction} counters from TTI]:
    Log to console    TTI Path: ${csv_path}
    Get D_Counter From MacPduMuxReq Csv Log    csv_path=${csv_path}    ca_info=${ca_info}    direction=${direction}
    log to console    \n[Get CB010636-D ${direction} counters from WEBUI]:
    ${all_cell_counter_dict}    Get All NRCELL Counter From VDU    counter_dict=${counter_dict}    nrcell_list=${cell_list}
    ...    before_counter_time=${before_counter_time}
    ${result}    dealCounter.checkCounters    OamCounterData=${all_cell_counter_dict}    outputpath=${OUTPUT_DIR}/${TEST NAME}/
    ...    gap=${GAP_Acceptable}    subfeature=D
    Run Keyword And Continue On Failure    Should be true    ${result}    msg=CB010636_D Some ${direction} Counters eroor

Get All NRCELL Counter From VDU
    [Arguments]    ${counter_dict}    ${before_counter_time}    ${nrcell_list}=${cell_list}
    ${after_counter_dict}    Create dictionary
    FOR    ${cell}    IN    @{nrcell_list}
        ${web_counter}    Get VDU PM Counters    counter_id_dict=${counter_dict}    dist_name=${cell}
        ${cell_name}    String.Fetch From Right    ${cell}    marker=/
        set to dictionary    ${after_counter_dict}    ${cell_name}=${web_counter}
    END
    ${all_cell_counter_dict}    get_counter_sum_value_after_dedicate_time
    ...    before_counter_time=${before_counter_time}
    ...    after_counter_dict=${after_counter_dict}
    [Return]    ${all_cell_counter_dict}
