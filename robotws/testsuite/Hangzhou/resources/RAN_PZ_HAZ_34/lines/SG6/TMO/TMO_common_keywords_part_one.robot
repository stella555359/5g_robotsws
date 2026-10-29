*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot


*** Keywords ***
#--- Common Procedures KW ---#
Convert Dl Tput based on Process num
    [Documentation]  author: lei.jia@nokia-sbell.com.
    ...    2024.05.06: due to appserver issue, cannot send traffic larger than 1800M, using -P=2 instead
    ...    if ${process_num}=1, ${dl_throughput}=2500M, -P 1 -f m -b 2500M
    ...    if ${process_num}=2, ${dl_throughput}=2500M, -P 2 -f m -b 1250M
    [Arguments]        ${process_num}=${2}    ${dl_throughput}=2500MKbits/sec
    ${tput_value}    Get Regexp Matches    ${dl_throughput}    (\\d+\.?\\d)    1
    ${used_tput_value}    Evaluate       int(int(${tput_value[0]})/${process_num})
    ${tputstring}    Fetch From Right    ${dl_throughput}    ${tput_value[0]}
    ${dl_throughput}    Set Variable    ${used_tput_value}${tputstring}
    [Return]    ${dl_throughput}

Procedures.Verify CA Basic L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${detach_request}=${true}
    ...            ${power_reset}=False
    ...            ${5Gstatus}=PASS
    ...            ${scell_addition_method}=A1
    ...            ${ul_throughput}=150M
    ...            ${dl_throughput}=2500MKbits/sec
    ...            ${protocol}=udp
    ...            ${start_keep_on_duration}=1200
    ...            ${tput_collect_duration}=180
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.9
    ...            ${min_DL_percent}=0.5
    ...            ${min_UL_percent}=0.5
    ...            ${whether_check_scell_addition}=${False}
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_check_tupt}=${True}
    ...            ${expect_tp_percent}=1
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${expect_addition_scell_indexs}=${SCELL_INDEX_LIST}
    ...            ${pcell_mapping}=${PCELL_MAPPING}
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${exp_status}=notBarred
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${whether_need_ue_log}=${True}
    ...            ${ignore_time}=1min
    ...            ${whether_do_lte_barred_action}=${False}
    ...            ${lte_exp_status}=notBarred
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=35 sec
    ...            ${check_pcell_tput}=${True}
    ...            ${check_scell_tput}=${True}
    ...            ${whether_start_dl_call}=${True}
    ...            ${whether_start_ul_call}=${True}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${dl_process_num}=${2}
    ...            ${list_cell_ids}=${LTE_CELL_INDEX}
    ...            ${whether_do_lte_cell_locked}=${False}
    ...            ${min_scell_percent}=0.05
    ...            ${whether_change_fren}=${True}
    ...            ${whether_DL_nonGBR}=${False}
    ...            ${whether_check_scell_ul_tupt}=${False}
    ...            ${special_scell_index_for_UL}=None
    ...            ${get_spark_license}=${true}
    ...            ${ip_type}=4
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${dl_process_num}    dl_throughput=${dl_throughput}
    Run Keyword If   '${ue_mode}'=='NSA'    Get RU Index Of LTE Cell    cell_index=${list_cell_ids}
    ...                                                                 gnb_id=${gnb_index}
    ...                                                                 enb_index=${enb_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}
    ...                                                                                ue_index=${ue_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ue_mode}'=='NSA'    Change cellBarred Parameter Value Of Lte Cells
    ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells
    ...                                                      list_cell_ids=${list_cell_ids}
    ...                                                      exp_status=${lte_exp_status}
    ...                                                      enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Run Keyword If   '${ue_mode}'=='NSA' and ${whether_change_fren}
    ...               Update Priority Of NR Frequency Band In ENDCDMEASCONF    cell_index=${b1_select_cell_index}
    ...                                                                        enb_index=${enb_index}
    Run Keyword If    ${whether_check_on_air}    Check TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'      Do All TDD-LTE Cells Action
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                           detach_request=${detach_request}      power_reset=${power_reset}
    ...                                           get_spark_license=${get_spark_license}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    ${4G_check}    Set Variable If    '${ue_mode}'=='NSA'    True    False
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=${ue_mode}
    ...                                              ue_type=${ue_type}
    ...                                              ue_index=${ue_index}
    ...                                              enb_wireshark_log_prefix=${enb_wireshark_log_prefix}
    ...                                              enb_index=${enb_index}
    ...                                              common_unit_index=${common_unit_index}
    ...                                              sleep_interval=${sleep_interval}
    ...                                              gnb_index=${gnb_index}
    ...                                              du_index=${du_index}
    ...                                              4G_check=${4G_check}
    ...                                              5Gstatus=${5Gstatus}
    ...                                              hwcheck_index=${hwcheck_index}
    ...                                              power_reset=${power_reset}
    ${attach_cell_index}    Set Variable If    '${ue_mode}'=='NSA'    ${b1_select_cell_index}    ${notbarred_cell_index}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${attach_cell_index}
    ${addition_scell_index_list}    Run Keyword If    ${whether_check_scell_addition}
    ...    Run Keyword And Continue On Failure    Procedures.Check TMO Scell Addition
    ...                                               attach_info=${attach_info}
    ...                                               ue_mode=${ue_mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                               scell_addition_method=${scell_addition_method}
    ...                                               pcell_mapping=${pcell_mapping}
    ...                                               scell_mapping=${scell_mapping}
    ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
    ...    ${attach_info['enb_wireshark_log_path']}
    ...    ${attach_info['cpif_log_path']}
    Procedures.Start TMO L3 Call    cpif_log_path=${attach_wireshark}
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             protocol=${protocol}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ul_throughput=${ul_throughput}
    ...                             dl_throughput=${dl_throughput}
    ...                             apn_address=${apn_address}
    ...                             whether_start_dl_call=${whether_start_dl_call}
    ...                             whether_start_ul_call=${whether_start_ul_call}
    ...                             iperf_path=${ue_iperf_path}
    ...                             dl_process_num=${dl_process_num}
    ...                             ue_type=${ue_type}
    ...                             whether_DL_nonGBR=${whether_DL_nonGBR}
    ...                             ip_type=${ip_type}
    ${check_ul_pcell_tput_type}    Set Variable If    '${ue_mode}'=='NSA' or '${ue_type}'=='samsung'    layer1    ${check_ul_pcell_tput_type}
    Run Keyword If    ${whether_check_tupt}    Procedures.Check TMO Throughput    ue_index=${ue_index}
    ...                                                                           addition_scell_index_list=${expect_addition_scell_indexs}
    ...                                                                           tput_collect_duration=${tput_collect_duration}
    ...                                                                           expect_tp_percent=${expect_tp_percent}
    ...                                                                           ignore_time=${ignore_time}
    ...                                                                           check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                                           check_scell_tput_type=${check_scell_tput_type}
    ...                                                                           check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                                           check_pcell_tput=${check_pcell_tput}
    ...                                                                           check_scell_tput=${check_scell_tput}
    ...                                                                           ue_type=${ue_type}
    ...                                                                           pcell_mapping=${pcell_mapping}
    ...                                                                           scell_mapping=${scell_mapping}
    ...                                                                           target_DL_avg_percent=${target_DL_avg_percent}
    ...                                                                           target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                                           min_DL_percent=${min_DL_percent}
    ...                                                                           min_UL_percent=${min_UL_percent}
    ...                                                                           min_scell_percent=${min_scell_percent}
    ...                                                                           whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                     	                                                  special_scell_index_for_UL=${special_scell_index_for_UL}
    [Return]    ${attach_info}
    [Teardown]    Run Keywords    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}   AND
    ...    Run Keyword And Ignore Error     Recover Collect Syslog On GNB     AND    Sleep    3min    AND
    ...    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'    Run Keyword And Ignore Error
    ...    Do All TDD-LTE Cells Action    cell_action=unlocked

Procedures.Verify CA Basic Handover Test
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}=${HO_PCELL_INDEX}    ${ue_index}=${0}    ${ue_mode}=SA    ${timeout}=${600}
    ...            ${source_pa_value}=25    ${target_pa_value}=15    ${scell_addition_method}=A1
    ...            ${gnb_id}=0    ${connection}=GNB_OAM0    ${asik_alias}=ASIK Master0    ${whether_check_tupt}=${False}
    ...            ${whether_check_scell_addition}=${True}
    Get Pcell And Scell Mapping Info For Pcell Change    ho_pcell_index=${ho_pcell_index}
    ...                                                  gnb_id=${gnb_id}
    ...                                                  connection=${connection}
    ...                                                  timeout=${timeout}
    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${PCELL_MAPPING['ru_index_mapping']}
    ${ho_ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${HO_PCELL_MAPPING['ru_index_mapping']}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=handover
    ...    asik_connection_alias=${asik_alias}
    ...    gnb_index=${gnb_id}
    Sleep    30sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${HO_PCELL_MAPPING['ru_index_mapping']}
        ...                                                                                   ue_index=${ue_index}
        ...                                                                                   pa_off_value=${target_pa_value}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ho_ru_whether_connect_mcs}
        ...                                        Set Case Related MCS Port Value    att_value=${target_pa_value}
        ...                                                                           ue_index=${ue_index}
        ...                                                                           whether_do_Angles=${False}
        ...                                                                           whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Sleep    2sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Modify PA Value Setting For Required RU    modify_ru_id=${PCELL_MAPPING['ru_index_mapping']}
        ...                                                                                   ue_index=${ue_index}
        ...                                                                                   pa_off_value=${source_pa_value}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...                                        Set Case Related MCS Port Value    att_value=${source_pa_value}
        ...                                                                           ue_index=${ue_index}
        ...                                                                           whether_do_Angles=${False}
        ...                                                                           whether_do_mcs_setup=${False}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    Sleep    45sec
    ${handover_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=handover
    ${handover_addition_scell_index_list}    Run Keyword If    ${whether_check_scell_addition}
    ...               Run Keyword And Continue On Failure    Check Scell Addition Success
    ...                                      cpif_log_path=${handover_wireshark}
    ...                                      mode=${ue_mode}
    ...                                      addition_method=${scell_addition_method}
    ...                                      scell_mapping=${HO_SCELL_MAPPING}
    ...                                      expect_addition_scell_indexs=${HO_SCELL_INDEX_LIST}
    Run Keyword If    ${whether_check_tupt}    Run Keyword And Continue On Failure
    ...                                           Procedures.Check TMO Throughput    ue_index=${ue_index}
    ...                                                                              addition_scell_index_list=${HO_SCELL_INDEX_LIST}
    ...                                                                              pcell_mapping=${HO_PCELL_MAPPING}
    ...                                                                              scell_mapping=${HO_SCELL_MAPPING}
    ...                                                                              tput_collect_duration=180
    ...                                                                              ignore_time=5sec
    [Return]    ${handover_wireshark}

Procedures.Verify Non-CA Basic L3 Call
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${ul_throughput}=150MKbits/sec
    ...            ${dl_throughput}=1500MKbits/sec
    ...            ${expect_dl_tput}=1000
    ...            ${expect_ul_tput}=60
    ...            ${start_keep_on_duration}=1200
    ...            ${tput_collect_duration}=180
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_do_lte_cell_barred}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_check_tupt}=${True}
    ...            ${whether_check_attach_cell}=${True}
    ...            ${whether_start_traffic}=${True}
    ...            ${whether_start_uelog}=${True}
    ...            ${whether_stop_uelog}=${True}
    ...            ${expect_tp_percent}=1
    ...            ${notbarred_cell_index}=${301}
    ...            ${apn_address}=${tl.core.pdns[1].apn}
    ...            ${connection}=GNB_OAM
    ...            ${ignore_time}=1min
    ...            ${4G_check}=True
    ...            ${exp_status}=notBarred
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${is_power_ue_code}=${False}
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${enb_index}=${1}
    log    ${expect_tp_percent}
    log    ${ue_iperf_path}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Set Test Variable    ${direction_component_list}
    Run Keyword If    ${whether_do_lte_cell_barred}    Change cellBarred Parameter Value Of Lte Cells
    ...                     list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    Run Keyword If    ${whether_check_on_air}    Check TMO Gnb Ready And All Cell On Air    connection=${connection}
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${whether_start_uelog} and '${ue_type}'=='huawei_sigspark'    Spark_common_keywords.Spark Start UE Log
    ...                                                                                 ue_index=${ue_index}
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=${ue_mode}    ue_index=${ue_index}    ue_type=${ue_type}
    ...               4G_check=${4G_check}    ue_alias=${ue_alias}       enb_index=${enb_index}
    ...               attach_mode=${attach_mode}    is_power_ue_code=${is_power_ue_code}
    Run Keyword If    ${whether_check_attach_cell}     Run Keyword And Continue On Failure
    ...                    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${notbarred_cell_index}

    ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
    ...    ${attach_info['enb_wireshark_log_path']}    ${attach_info['cpif_log_path']}
#    Run Keyword If    ${whether_start_traffic}
#    ...    Run Keyword And Continue On Failure    Procedures.Start Data Transfer
#    ...                                    cpif_log_path=${attach_wireshark}
#    ...                                    ue_mode=${ue_mode}
#    ...                                    ue_index=${ue_index}
#    ...                                    start_keep_on_duration=${start_keep_on_duration}
#    ...                                    ul_throughput=${ul_throughput}
#    ...                                    dl_throughput=${dl_throughput}
#    ...                                    iperf_path=${ue_iperf_path}
#    ...                                    ue_type=${ue_type}
#    ...                                    apn_address=${apn_address}
#    ...                                    is_power_ue_code=${is_power_ue_code}
#    Sleep    30s
    Run Keyword If    ${whether_start_traffic}     Spark_common_keywords.Start L3 Traffic
    ...                             ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             duration=${start_keep_on_duration}
    ...                             ul_throughput=${ul_throughput}
    ...                             dl_throughput=${dl_throughput}
    ...                             apn_address=${apn_address}
    ...                             ue_type=${ue_type}
    Sleep    30s
    Run Keyword If    ${whether_check_tupt}    Check Tput With Power UE
    ...                                 cellid=${notbarred_cell_index}
    ...                                 direction_component_list=${direction_component_list}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_tput=${expect_dl_tput}
    ...                                 target_avg_percent=0.9
    ...                                 duration=${tput_collect_duration}
    ...                                 is_ulbler_calcu=${False}
    ...                                 check_source=aasyslog
    ...                                 ignore_time=${ignore_time}
    Run Keyword If    ${whether_stop_uelog} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...     Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}


#--- Common keywords for L3 Call---#
Procedures.Check network mode
    [Documentation]   author: lei.jia@nokia-sbell.com
    ...               preferred_network_mode:
    ...               0:'WCDMA_preferred',1:'GSM_only', 2:'WCDMA_only', 3:'GSM_WCDMA_auto', 4:'CDMA_EvDo',
    ...               5:'CDMA_only', 6:'EvDo_only', 7:'Global', 8:'LTE_CDMA_EvDo',9:'LTE_GSM_WCDMA',10:'LTE_CDMA_EvDo_GSM_WCDMA',
    ...               11:'LTE_only',12:'LTE_WCDMA',13:'TD_SCDMA_only',14:'TD_SCDMA_WCDMA',15:'TD_SCDMA_LTE',16:'TD_SCDMA_GSM',
    ...               17:'TD_SCDMA_GSM_LTE',18:'TD_SCDMA_GSM_WCDMA',19:'TD_SCDMA_WCDMA_LTE',20:'TD_SCDMA_GSM_WCDMA_LTE',
    ...               21:'TD_SCDMA_GSM_WCDMA_CDMA_EvDo',22:'TD_SCDMA_LTE_CDMA_EvDo_GSM_WCDMA',23:'NR_only',24:'NR_LTE',
    ...               25:'NR_LTE_CDMA_EVDO',26:'NR_LTE_GSM_WCDMA',27:'NR_LTE_CDMA_EVDO_GSM_WCDMA',28:'NR_LTE_WCDMA',29:'NR_LTE_TDSCDMA',
    ...               30:'NR_LTE_TDSCDMA_GSM',31:'NR_LTE_TDSCDMA_WCDMA',32:'NR_LTE_TDSCDMA_GSM_WCDMA',33:'NR_LTE_TDSCDMA_CDMA_EVDO_GSM_WCDMA'
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell settings list global|grep preferred_network_mode    connection=cpc_${ue_index}
    Sleep    1sec
    ${output}    csn.read_output    connection=cpc_${ue_index}
    ${preferred_network_mode_list}    Get Regexp Matches    ${output}    preferred_network_mode=(\\d+)    1
    ${preferred_network_mode_id}    Convert To Integer    ${preferred_network_mode_list[0]}
    #Should Be True    ${preferred_network_mode_id} >= 24
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Procedures.Start UE Prepare
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${get_spark_license}=${true}
    ...            ${detach_request}=${true}      ${power_reset}=False
    Log To Console     ${\n}INFO: --Start UE Prepare
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Prepare UE    ue_index=${ue_index}
    ...    ELSE    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${get_spark_license}
    ...                                  detach_request=${detach_request}      power_reset=${power_reset}

Procedures.Start TMO Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Modify:Stella.lin@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_type}=${ue_type}
    ...            ${ue_mode}=SA
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=15 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${4G_check}=True
    ...            ${5Gstatus}=PASS
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${is_power_ue_code}=${False}
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    log    ${apn_address}
    log    ${is_power_ue_code}
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${coam_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${5Grach_ed}    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
#    ...    ELSE IF    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'
#    ...                Spark_common_keywords.Start UE Attach And Enable Data Service
#    ...                ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    ...                                  ue_alias=${ue_alias}
    ...                                  attach_mode=${attach_mode}
#    Run Keyword If    '${tl_prefix}'=='T073'    Sleep    45sec
    Sleep    30sec
    Run Keyword If     '${ue_type}'=='huawei_sigspark'
    ...                Spark_common_keywords.Start UE Attach in X65 multi UE x65   ue_index=${ue_index}
    Sleep    30sec
    Run Keyword If    '${ue_type}'!='mtk'    power_ue.Verify attach    ue_type=${ue_type}
    ...                                                                ue_index=${ue_index}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                du_index=${du_index}
    ...                                                                5Grach_ed=${5Grach_ed}
    ...                                                                4G_check=${4G_check}
    ...                                                                5Gstatus=${5Gstatus}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    ${sleep_interval}
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ${attach_info}    Run Keyword If    '${ue_mode}'=='NSA'
    ...            Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                 attach_cell_index=${attach_cell_index}
    ...                                 enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Procedures.Check TMO Scell Addition
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${attach_info}
    ...            ${ue_mode}=SA
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${scell_addition_method}=A1
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${pcell_mapping}=${PCELL_MAPPING}
    Log To Console    ${\n}INFO:-- start to check scell addition --
    ${addition_scell_index_list}    Run Keyword If    '${scell_addition_method}'=='A1'
    ...                                               Message_Flow_Check.A1 Addition Process
    ...                                               addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${ue_mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                               pcell_mapping=${pcell_mapping}
    ...                                               scell_mapping=${scell_mapping}
    ...    ELSE    Check Scell Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                            mode=${ue_mode}
    ...                                            expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                            scell_mapping=${scell_mapping}
    [Return]    ${addition_scell_index_list}

Procedures.Start TMO L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...              for mtk and samsung ue, default iperf_path is '/data/local/tmp/iperf'; for qxc_dx50, default iperf_path is 'iperf'
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=150M    ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${iperf_path}=iperf
    ...            ${ul_process_num}=${1}    ${dl_process_num}=${2}    ${seg_size}=${1350}    ${window}=16M
    ...            ${whether_start_dl_call}=${True}    ${whether_start_ul_call}=${True}    ${ue_type}=${ue_type}
    ...            ${whether_DL_nonGBR}=${False}    ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}    ${ip_type}=4
    Log To Console    ${\n}INFO:-- start to L3 call --
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
    Run Keyword If    ${whether_start_dl_call}    Run Keyword And Continue On Failure
    ...    Procedures.Start DL Call    cpif_log_path=${cpif_log_path}
    ...                                ue_type=${ue_type}
    ...                                ue_mode=${ue_mode}
    ...                                ue_index=${ue_index}
    ...                                apn_address=${apn_address}
    ...                                dl_throughput=${dl_throughput}
    ...                                start_keep_on_duration=${start_keep_on_duration}
    ...                                buffer_size=${buffer_size}
    ...                                appserver=${appserver}
    ...                                protocol=${protocol}
    ...                                process_num=${dl_process_num}
    ...                                seg_size=${seg_size}
    ...                                window=${window}
    ...                                whether_DL_nonGBR=${whether_DL_nonGBR}
    ...                                dl_port=${dl_port}
    ...                                ip_type=${ip_type}
    ${ul_throughput_spark}    Replace String    ${ul_throughput}    M    MKbits/sec
    ${ul_throughput}    Set Variable If    '${ue_type}'=='huawei_sigspark'    ${ul_throughput_spark}    ${ul_throughput}
    Run Keyword If    '${protocol}'=='udp' and '${ue_type}'=='huawei_sigspark' and ${whether_start_ul_call}
    ...    Spark_common_keywords.Start UL Traffic with spark UE   ul_throughput=${ul_throughput}
    ...             duration=${start_keep_on_duration}
    ...             apn_address=${apn_address}
    ...             ue_mode=${ue_mode}
    ...             ue_index=${ue_index}
    ...    ELSE IF   ${whether_start_ul_call} and '${ue_type}'!='huawei_sigspark'
    ...    traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...        ue_index=${ue_index}
    ...        ul_time=${start_keep_on_duration}
    ...        ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...        ul_throughput=${ul_throughput}
    ...        ul_length=${buffer_size}
    ...        appserver=${appserver}
    ...        protocol=${protocol}
    ...        iperf_path=${iperf_path}
    ...        process_num=${ul_process_num}

Procedures.Start DL Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${whether_DL_nonGBR}=${False}
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M    ${ue_type}=${ue_type}
    ...            ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}    ${ip_type}=4
    log   ${apn_address}
    log   ${ue_type}
    Log To Console    ${\n}INFO:-- start to DL call --
    ${ue_ip_dict}    Run Keyword If   ${whether_DL_nonGBR}==${False}   Get ALL PDU IP Address From Wireshark
    ...    cpif_log_path=${cpif_log_path}    mode=${ue_mode}    ip_type=${ip_type}
    ...    ELSE    Get mutiple nonGBR PDU IP Address From Wireshark    cpif_log_path=${cpif_log_path}    mode=${ue_mode}
    ${dl_throughput}    Replace String    ${dl_throughput}    MKbits/sec    M
#    ${dl_throughput}    Run Keyword If    '${ue_type}'!='huawei_sigspark'    Replace String    ${dl_throughput}    MKbits/sec    M
#    Run Keyword If    '${protocol}'=='udp' and '${ue_type}'=='huawei_sigspark'
#    ...                                       Spark_common_keywords.Start DL Traffic    dl_throughput=${dl_throughput}
#    ...                                                                                 duration=${start_keep_on_duration}
#    ...                                                                                 apn_address=${apn_address}
#    ...                                                                                 ue_mode=${ue_mode}
#    ...                                                                                 ue_index=${ue_index}
#    ...    ELSE    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
#    ...                                                       dl_time=${start_keep_on_duration}
#    ...                                                       dl_port=${tl.ues[${ue_index}].iperf_details.port}
#    ...                                                       dl_throughput=${dl_throughput}
#    ...                                                       dl_length=${buffer_size}
#    ...                                                       appserver=${appserver}
#    ...                                                       protocol=${protocol}
#    ...                                                       ue_index=${ue_index}
#    ...                                                       process_num=${process_num}
#    ...                                                       seg_size=${seg_size}
#    ...                                                       window=${window}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                                       dl_time=${start_keep_on_duration}
    ...                                                       dl_port=${dl_port}
    ...                                                       dl_throughput=${dl_throughput}
    ...                                                       dl_length=${buffer_size}
    ...                                                       appserver=${appserver}
    ...                                                       protocol=${protocol}
    ...                                                       ue_index=${ue_index}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Procedures.Collect the Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${ue_type}    ${ue_index}=${0}    ${cell_type}=nr
    ...             ${gnb_index}=0    ${du_index}=0    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}
    ...             ${tput_collect_duration}=180    ${ignore_time}=1min    ${check_source}=aasyslog
    Log To Console    ${\n}INFO:-- start to collect tupt --
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    ${host}    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${tput_file_1}    Run Keyword If    ${4g_whether_in_gnb}    power_ue.Collect Tput    ue_type=${ue_type}
    ...                                                                                gnb_index=${gnb_index}
    ...                                                                                du_index=${du_index}
    ...                                                                                duration=${tput_collect_duration}
    ...                                                                                ignore_time=${ignore_time}
    ...                                                                                ue_index=${ue_index}
    ...                                                                                check_source=${check_source}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    Run Keywords
    ...    Start To Capture Aasyslog    gnb_index=${gnb_index}    du_index=${du_index}    host=${host}    AND
    ...    Sleep    ${tput_collect_duration} sec
    ${tput_file_2}    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Stop To Capture And Download Aasyslog    host=${host}
    ${tput_file}   Set Variable If     ${4g_whether_in_gnb}      ${tput_file_1}     ${tput_file_2}
    [Return]    ${tput_file}

Procedures.Check TMO Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               If ${whether_collect_tput}=${False}, the parameter ${tput_file_use_collested} must not be ${None}
    ...               Need to collect tput first, then set the vlaue of ${tput_file_use_collested} is the existed file.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${addition_scell_index_list}=${None}
    ...            ${tput_collect_duration}=300    ${check_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9    ${check_ul_pcell_tput_type}=peak
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85    ${expect_tp_percent}=1
    ...            ${pcell_mapping}=${PCELL_MAPPING}    ${scell_mapping}=${SCELL_MAPPING}
    ...            ${whether_collect_tput}=${True}    ${tput_file_use_collected}=${None}
    ...            ${check_source}=aasyslog    ${ignore_time}=1min
    ...            ${check_pcell_tput}=${True}    ${check_scell_tput}=${True}
    ...            ${whether_check_scell_ul_tupt}=${False}     ${special_scell_index_for_UL}=None
    log    ${ue_index}
    Log To Console    ${\n}INFO:-- start to check CA tupt --
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        gnb_index=${gnb_index}
    ...                        duration=${tput_collect_duration}
    ...                        addition_scell_index_list=${addition_scell_index_list}
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    ...                        target_DL_avg_percent=${target_DL_avg_percent}
    ...                        target_UL_avg_percent=${target_UL_avg_percent}
    ...                        min_DL_percent=${min_DL_percent}
    ...                        min_UL_percent=${min_UL_percent}
    ...                        min_scell_percent=${min_scell_percent}
    ...                        expect_tp_percent=${expect_tp_percent}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        pcell_mapping=${pcell_mapping}
    ...                        scell_mapping=${scell_mapping}
    ...                        whether_collect_tput=${whether_collect_tput}
    ...                        tput_file_use_collected=${tput_file_use_collected}
    ...                        check_source=${check_source}
    ...                        ignore_time=${ignore_time}
    ...                        check_pcell_tput=${check_pcell_tput}
    ...                        check_scell_tput=${check_scell_tput}
    ...                        whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                        special_scell_index_for_UL=${special_scell_index_for_UL}


Procedures.Stop TMO L3 Call And Detach
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${is_power_ue_code}=${False}
    ...                                ${apn_address}=${tl.core.pdns[0].apn}     ${power_reset}=False
    log    ${is_power_ue_code}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
    ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
    ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    apn_address=${apn_address}
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    '${ue_type}'!='mtk' or '${ue_type}'!='sigspark_multiUE'    Run Keyword And Ignore Error
    ...   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    Run Keyword If    '${ue_type}'=='sigspark_multiUE'     Run Keyword And Ignore Error    power_ue.UE Attach     ue_type=sigspark_multiUE
    Run Keyword If    '${ue_type}'=='mtk'    Run Keyword And Ignore Error    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}


Procedures.Adb Reboot UE And Verify
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keywords
    ...    Connect to control pc enhanced    ${ue_index}    AND
    ...    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}    AND
    ...    Sleep    10s    AND
    ...    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]    Run Keyword If    '${ue_type}'=='qct_dx50'    Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}


Procedures.Start UE Prepare MTK80
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Prepare UE For MTK80    ue_index=${ue_index}
    ...    ELSE    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

## Procedures for 4G L3 call
Procedures.Verify 4G L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${ue_index}=${0}
    ...            ${ue_type}=${ue_type}
    ...            ${cell_type}=lte
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${dl_throughput}=1000MKbits/sec
    ...            ${start_keep_on_duration}=900
    ...            ${expect_dl_tput}=150
    ...            ${expect_ul_tput}=10
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${whether_need_ue_log}=${False}
    ...            ${ignore_time}=1min
    ...            ${enb_index}=${0}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=35 sec
    ...            ${whether_do_lte_barred_action}=${True}
    ...            ${whether_do_barred_action}=${True}
    ...            ${tput_collect_duration}=120
    ...            ${iperf_path}=/data/local/tmp/iperf
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=50M
    ...            ${ue_mode}=NSA
    ...            ${process_num}=${2}
    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${dl_throughput}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${notbarred_cell_index}
    ...                                                                                                    exp_status=notBarred
    ...                                                                                                    enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=all
    ...                                                                                          exp_status=barred
    Run Keyword If    ${whether_check_on_air}    Check TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_check_on_air}    Wait Until Keyword Succeeds    2 min    20 sec    Verify Enb All Cell On Air
    ...                                                                                                enb_index=${enb_index}
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'!='T284'   Run Keyword And Continue On Failure
    ...    Change Network Mode Between SA And NSA For 8UE Module    ue_mode=${ue_mode}    ue_index=${ue_index}
    Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'=='T284'   Run Keyword And Continue On Failure
    ...    Change Network Mode Between SA And NSA and LTE For 8UE X65 Module    ue_mode=LTE    ue_index=${ue_index}
    ${attach_info}    Procedures.Start 4G Attach    ue_type=${ue_type}
    ...                                             ue_index=${ue_index}
    ...                                             enb_index=${enb_index}
    ...                                             common_unit_index=${common_unit_index}
    ...                                             sleep_interval=${sleep_interval}
    ...                                             gnb_index=${gnb_index}
    ...                                             du_index=${du_index}
    ...                                             cell_type=${cell_type}
    ...                                             hwcheck_index=${hwcheck_index}
    ...                                             power_reset=${power_reset}
    ...                                             ue_mode=${ue_mode}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${notbarred_cell_index}
    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec    Get ALL PDU IP Address From Wireshark
    ...    cpif_log_path=${attach_info['cpif_log_path']}    mode=${ue_mode}
    ${dl_throughput}       Replace String    ${dl_throughput}    MKbits/sec    M
    ${ul_throughput}   Run Keyword If    '${ue_type}'=='huawei_sigspark'
    ...                                  Replace String      ${ul_throughput}      M        MKbits/sec
    ...                ELSE   Set Variable   ${ul_throughput}
    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
    Run Keyword If    '${ue_type}'=='huawei_sigspark'   power_ue.Start traffic
    ...                                                      ue_type=${ue_type}
    ...                                                      direction=ul
    ...                                                      throughput=${ul_throughput}
    ...                                                      duration=${start_keep_on_duration}
    ...                                                      dt_name=DT_ul
    ...                                                      apn_address=${apn_address}
    ...                                                      ue_mode=${ue_mode}
    ...                                                      ue_index=${ue_index}
    ...   ELSE         traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...                                        ue_index=${ue_index}
    ...                                        ul_time=${start_keep_on_duration}
    ...                                        ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                        ul_throughput=${ul_throughput}
    ...                                        ul_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        iperf_path=${iperf_path}
    ...                                        process_num=${1}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                        dl_time=${start_keep_on_duration}
    ...                                        dl_port=${tl.ues[${ue_index}].iperf_details.port}
    ...                                        dl_throughput=${dl_throughput}
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${ue_index}
    ...                                        process_num=${process_num}
    ...                                        seg_size=${1350}
    ...                                        window=2M
    Run Keyword And Continue On Failure    Check 4G Tput With Power UE
    ...                               expect_dl_tput=${expect_dl_tput}
    ...                               expect_ul_tput=${expect_ul_tput}
    ...                               ue_type=${ue_type}
    ...                               ue_index=${ue_index}
    ...                               cell_type=${cell_type}
    ...                               tput_collect_duration=${tput_collect_duration}
    ...                               ignore_time=${ignore_time}
    ...                               enb_index=${enb_index}
    [Teardown]   Run Keyword If    ${whether_need_ue_log} and '${ue_type}'=='huawei_sigspark'
    ...    Run Keyword And Ignore Error   Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'!='T284'
    ...                Change Network Mode Between SA And NSA For 8UE Module    ue_mode=SA    ue_index=${ue_index}
    ...    ELSE IF   '${ue_type}'=='huawei_sigspark' and '${tl_prefix}'=='T284'   Run Keyword And Ignore Error
    ...    Change Network Mode Between SA And NSA and LTE For 8UE X65 Module    ue_mode=SA    ue_index=${ue_index}

Check 4G Tput With Power UE
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                Param： When ${whether_need_collect}=${False}, ${tput_log_path} must be given
    [Arguments]    ${expect_dl_tput}    ${expect_ul_tput}   ${ue_type}=${ue_type}    ${ue_index}=${0}
    ...            ${gnb_index}=0    ${du_index}=0    ${cell_type}=lte
    ...            ${tput_collect_duration}=180    ${ignore_time}=1min    ${check_source}=aasyslog
    ...            ${whether_need_collect}=${True}    ${tput_log_path}=${None}
    ...            ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ${tput_log}    Run Keyword If    ${whether_need_collect}    Procedures.Collect the Throughput
    ...                                                             ue_type=${ue_type}
    ...                                                             ue_index=${ue_index}
    ...                                                             cell_type=${cell_type}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             du_index=${du_index}
    ...                                                             gnb_connection=${gnb_connection}
    ...                                                             enb_index=${enb_index}
    ...                                                             tput_collect_duration=${tput_collect_duration}
    ...                                                             ignore_time=${ignore_time}
    ...                                                             check_source=${check_source}
    ...    ELSE    Set Variable    ${tput_log_path}
    ${log_name}    Set Variable    4G_dl_Aasyslog_tupt.txt
    ${ul_log_name}    Set Variable    4G_ul_Aasyslog_tupt.txt
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    ${ul_log_full_path_ute}     join path    ${log_dir_ute}    ${ul_log_name}
    OperatingSystem.Run   command=cat ${tput_log} | grep -a "INF/PDCP/STATS/DL: DRB S1" > ${log_full_path_ute}
    OperatingSystem.Run   command=cat ${tput_log} | grep -a "INF/PDCP/STATS/UL: DataPDU" > ${ul_log_full_path_ute}
    ${real_DL_tput}    4GL3call.check_4G_dl_throughput    log_file=${log_full_path_ute}
    ${real_UL_tput}    4GL3call.check_4G_ul_throughput    log_file=${ul_log_full_path_ute}
    ${expect_dl_tput}    Evaluate    int(${expect_dl_tput})
    ${expect_ul_tput}    Evaluate    int(${expect_ul_tput})
    ${dl_status}    Evaluate    ${real_DL_tput} >= ${expect_dl_tput}
    ${ul_status}    Evaluate    ${real_UL_tput} >= ${expect_ul_tput}
    Should Be True    ${dl_status}    msg=4G DL average throughput ${real_DL_tput} is lower than ${expect_dl_tput}
    Should Be True    ${ul_status}    msg=4G UL average throughput ${real_UL_tput} is lower than ${expect_ul_tput}

Get 4G Attach Cell Index From Wireshark
    [Arguments]    ${cpif_log_path}    ${cell_type}=lte
    ...            ${alias}=parser    ${timeout}=${600}
    ...            ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=s1ap    alias=${alias}
    ${cell_lte_identity_on_wireshark}    pcap.get_field_value_by_xpath    xpath=.//s1ap.CellIdentity
    ...                                                                   attribute_name=show
    ...                                                                   pcap_parser=${alias}
    ${cell_lte_identity_on_wireshark}    Get Substring     ${cell_lte_identity_on_wireshark[0]}    0   10
    ${cell_lte_identity_on_wireshark}    Convert To Binary    ${cell_lte_identity_on_wireshark}    base=16
    ${cell_lte_identity}    Convert To Integer    ${cell_lte_identity_on_wireshark}    base=2
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${4g_whether_in_gnb}==${False}    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    '${item['globalCellId']}'=${item['eutranCellId']}
    END
    ${cell_index_list}    Get Dictionary Keys    ${cell_list_info}
    ${eutranCellId_list}    Get Dictionary Values    ${cell_list_info}
    ${cellid_index}    Get Index From List    ${eutranCellId_list}    ${cell_lte_identity}
    Set Test Variable   ${attach_cell_index}   ${cell_index_list[${cellid_index}]}
    ${attach_cell_index}    Evaluate    int(${attach_cell_index})
    [Return]    ${attach_cell_index}
    [Teardown]    Teardown GNB and ENB Connections

Procedures.Start 4G Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}=${ue_type}
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${enb_index}=${1}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=5 sec
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${cell_type}=lte
    ...            ${alias}=parser
    ...            ${timeout}=${600}
    ...            ${gnb_connection}=GNB_OAM
    ...            ${enb_connection}=enblte_${enb_index}
    ...            ${wireshark_log_prefix}=cpif_attach
    ...            ${ue_mode}=NSA
    ...            ${enb_host}=${None}
    ...            ${enb_user}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${enb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ${enb_in_init_file_existence}    ${output}    Run Keyword And Ignore Error    Set Variable    ${tl.enbs[0]}
    ${enb_ip}    Run Keyword If    '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='FAIL'
    ...    Get ENB IPaddress From GNB    gnb_index=${gnb_index}
    ...    ELSE IF   '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}' and '${enb_in_init_file_existence}'=='PASS'
    ...    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If     '${ue_mode}'=='NSA' and '${is_multi_rat}'=='${False}'    ${enb_ip}    ${enb_host}
    Run Keyword If    '${ue_mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    ...                                                                        is_multi_rat=${is_multi_rat}
    ...                                                                        gnb_index=${gnb_index}
    ...                                                                        enb_host=${enb_host}
    ...                                                                        enb_user=${enb_user}
    ...                                                                        enb_password=${enb_password}
    Sleep    ${sleep_interval}
    Log To Console    ${\n}INFO:-- start to attach --
    ${power_reset}    Set Variable If    'spark' in '${ue_type}'    true    ${power_reset}
    Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ...    ELSE    power_ue.UE Attach    ue_type=${ue_type}
    ...                                  ue_index=${ue_index}
    ...                                  gnb_index=${gnb_index}
    ...                                  hwcheck_index=${hwcheck_index}
    ...                                  du_index=${du_index}
    ...                                  power_reset=${power_reset}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    15sec
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${enb_wireshark_log_name}
    ${attach_cell_index}    Get 4G Attach Cell Index From Wireshark    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                cell_type=${cell_type}
    ...                                                                alias=${alias}
    ...                                                                timeout=${timeout}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                enb_index=${enb_index}
    ...                                                                gnb_connection=${gnb_connection}
    ...                                                                enb_connection=${enb_connection}
    ${attach_info}    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}


#--- Common keywords for Spark Tupt via mac tp---#
Check Tupt Via Spark App
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :Param:sleep_time---get tupt via keyword "get_mac_tp" every one sec.
    ...                :Param:get_times---how many times do get tupt via keyword "get_mac_tp"
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${sleep_time}=1sec    ${get_times}=180
    ${ul_tupt_list}    Create List
    ${dl_tupt_list}    Create List
    FOR    ${i}    IN RANGE    ${get_times}
        ${tupt}    spark.check_throughput_on_ue    ue_alias=${ue_alias}
        Append To List    ${ul_tupt_list}    ${tupt[0]}
        Append To List    ${dl_tupt_list}    ${tupt[1]}
        Sleep    ${sleep_time}
    END
    ${ul_tupt_avg}    Evaluate    (sum(${ul_tupt_list})/len(${ul_tupt_list}))/1000/1000
    ${dl_tupt_avg}    Evaluate    (sum(${dl_tupt_list})/len(${dl_tupt_list}))/1000/1000
    ${avg_tupt}    Create List    ${ul_tupt_avg}    ${dl_tupt_avg}
    [Return]    ${avg_tupt}

Disable actDlSrsBm and releated params via Admin API
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                Disable 8247 for N41+N71+N25 3CC, as N25 tput will degrade
    [Arguments]    ${cell_index}=${PCELL_INDEX}     ${value}=false     ${actDlMuMimoEnh_value}=false
    ...            ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    @{params_need_to_modify}    create list
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    #cell level parameters
    &{actDlSrsBm_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlSrsBm    value=${value}
    &{actDlMuMimoEnh_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlMuMimoEnh    value=${actDlMuMimoEnh_value}
    &{actDlRankProbing_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlRankProbing    value=${value}
    &{actPdschBeamPowerBalance_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actPdschBeamPowerBalance    value=${value}
    &{actMuAwareTdSch_dict}    Create Dictionary
    ...              dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}/NRDLMUMIMO-1
    ...              parameter=actMuAwareTdSch    value=${value}
    &{actDlMuPairingGroup_dict}    Create Dictionary
    ...              dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}/NRDLMUMIMO-1
    ...              parameter=actDlMuPairingGroup    value=${value}
    &{actSrsBeamFallbackByRetrx_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actSrsBeamFallbackByRetrx    value=${value}
    &{actDlSrsSubbandBm_dict}    Create Dictionary    dist_name=${dist_name}
    ...                    parameter=actDlSrsSubbandBm    value=${value}
    &{actDlSrsForCA_dict}    Create Dictionary    dist_name=${dist_name}
    ...                 parameter=actDlSrsForCA    value=${value}
    ${update_actNoAddDlDmrsSwitchSbBf}    catenate   {'dist_name':'${dist_name}',
    ...    'parameter':'srsForSubbandBm','value':[{'actNoAddDlDmrsSwitchSbBf':'${value}'}]}
    ${actNoAddDlDmrsSwitchSbBf_list}    Evaluate    ${update_actNoAddDlDmrsSwitchSbBf}
    ${update_actTasSrsForCriticalBandCombo}    catenate   {'dist_name':'${dist_name}',
    ...    'parameter':'srsForSubbandBm','value':[{'actTasSrsForCriticalBandCombo':'${value}'}]}
    ${actTasSrsForCriticalBandCombo_list}    Evaluate    ${update_actTasSrsForCriticalBandCombo}
    #bts level parameters
    &{actTddCsiRsOpt_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}
    ...                 parameter=actTddCsiRsOpt   value=${value}
    &{actTddCsiImRm_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}
    ...                 parameter=actTddCsiImRm   value=${value}
    #all cell level parameters
    ${all_cell_index}     Run Keyword If    '${tl_prefix}'=='T283'
    ...    create list    301   302  303   311   312   313    351    352   353
    ...    ELSE IF    '${tl_prefix}'=='T073'
    ...    create list    301   302  303   311   312   313    351    352   353
    ...    ELSE    create list    301   302  303   311   312   313
    FOR   ${cell_index}    IN    @{all_cell_index}
        &{actCsiRsMuting_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...                 parameter=actCsiRsMuting  value=${value}
        Append To List    ${params_need_to_modify}    ${actCsiRsMuting_dict}
        &{actSubTRSRateMatch_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        ...                 parameter=actSubTRSRateMatch   value=${value}
        Append To List    ${params_need_to_modify}     ${actSubTRSRateMatch_dict}
#        &{pagingOffset_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID} /NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
#        ...                 parameter=pagingOffset   value=0
#        Append To List    ${params_need_to_modify}     ${pagingOffset_dict}
    END
    IF    '${tl_prefix}'=='T819'
        Append To List    ${params_need_to_modify}    ${actDlSrsBm_dict}    ${actDlMuMimoEnh_dict}
        ...               ${actDlRankProbing_dict}    ${actPdschBeamPowerBalance_dict}
        ...               ${actSrsBeamFallbackByRetrx_dict}    ${actDlSrsSubbandBm_dict}    ${actDlSrsForCA_dict}
        ...               ${actTddCsiRsOpt_dict}    ${actTddCsiImRm_dict}
    ELSE
        Append To List    ${params_need_to_modify}    ${actDlSrsBm_dict}    ${actDlMuMimoEnh_dict}    ${actMuAwareTdSch_dict}
        ...               ${actDlRankProbing_dict}    ${actPdschBeamPowerBalance_dict}
        ...               ${actSrsBeamFallbackByRetrx_dict}    ${actDlSrsSubbandBm_dict}    ${actDlSrsForCA_dict}
        ...               ${actTddCsiRsOpt_dict}    ${actTddCsiImRm_dict}    ${actNoAddDlDmrsSwitchSbBf_list}
        ...               ${actDlMuPairingGroup_dict}    ${actTasSrsForCriticalBandCombo_list}
    END
    Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}    timeout=600

Get actDlSrsBm Param Value
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get the value of actDlSrsBm on GNB
    [Arguments]    ${cell_index}=${PCELL_INDEX}    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    ...            ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${actDlSrsBm_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlSrsBm
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlMuMimoEnh_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlMuMimoEnh
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actMuAwareTdSch_value}    coam_parameter.get_single_value_from_scf_file    parameter=actMuAwareTdSch
    ...          dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}/NRDLMUMIMO-1
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlRankProbing_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlRankProbing
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actDlSrsSubbandBm_value}    coam_parameter.get_single_value_from_scf_file    parameter=actDlSrsSubbandBm
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actPdschBeamPowerBalance_value}    coam_parameter.get_single_value_from_scf_file    parameter=actPdschBeamPowerBalance
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
    ${actSrsBeamFallbackByRetrx_value}    coam_parameter.get_single_value_from_scf_file    parameter=actSrsBeamFallbackByRetrx
    ...                                                                    dist_name=${dist_name}
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
	[Return]    ${actDlSrsBm_value}     ${actDlMuMimoEnh_value}    ${actMuAwareTdSch_value}    ${actDlRankProbing_value}
	...         ${actDlSrsSubbandBm_value}    ${actPdschBeamPowerBalance_value}    ${actSrsBeamFallbackByRetrx_value}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Lock AHFII FDD cells
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AHFII    ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${action}=block
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    log    ${enb_connection}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    enb_index=${enb_index}
    ...    ru_type=${ru_type}    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
    END


Lock AEHC FDD and NR Cells
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${action}=lock
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    log    ${enb_connection}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=lte
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${nr_cell_list}    Get Cell List For Special RU    cell_type=nr
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    ${used_nr_cell}    Convert to String     ${PCELL_INDEX}
    Remove Values From List 	${nr_cell_list} 	${used_nr_cell}
    FOR    ${cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=lte    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=lte    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
    END
    FOR    ${cell_index}    IN    @{nr_cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=nr    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=nr    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
    END

#--- Common keywords for Cases---#
Start To Capture Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738
    ...            ${filter}=${EMPTY}    ${host}=${EMPTY}    ${timeout}=15m
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   aasyslog.Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                             host=${host}    username=${username}    password=${password}
    aasyslog.Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                               aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                               host=${host}    username=${username}    password=${password}
    aasyslog.Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                          gnb_path=${gnb_path}    log_name=${log_name}
    ...                                          host=${host}    username=${username}    password=${password}
    ...                                          log_ip=${log_ip}    timeout=${timeout}
    [Return]    ${host}

Stop To Capture And Download Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${host}    ${gnb_index}=0    ${du_index}=0    ${Teardown_after_finished}=${True}
    ...            ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                             host=${host}    username=${username}    password=${password}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    aasyslog.Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                         gnb_index=${gnb_index}    du_index=${du_index}
    ...                                         host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    Run Keyword If    '${Teardown_after_finished}'=='${True}'
    ...           aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                           host=${host}    username=${username}    password=${password}

Update Values Of Some Parameters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                For caseID: 5603009
    [Arguments]    ${cell_index}
    ...            ${lte_cell_earfcnDL}
    ...            ${nrhoirDNList_value}=${None}
    ...            ${measurement_time}=5min
    ...            ${b2Threshold1hoRsrp_value}=76
    ...            ${b2Threshold2hoRsrp_value}=50
    ...            ${a2ThresholdhoSsbRsrpSA_value}=76
    ...            ${a1ThresholdhoSsbRsrpSA_value}=78
    ...            ${actInterRatHoSADlDataForward_value}=true
    ...            ${a1ThresholdSCellAddSsbRsrpTDD_value}=100
    ...            ${a1ThresholdSCellAddSsbRsrpFDD_value}=100
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRHOIR_A    connection=${connection}    timeout=${timeout}
    FOR    ${mo}    IN    @{MOs}
        ${nrhoir_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${nrhoir_dist_name}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRHOIR-${nrhoir_id}
        ${earfcnValue}    Set Variable    ${mo['parameters']['earfcnValue']}
        Run Keyword If    '${earfcnValue}'=='${lte_cell_earfcnDL}' and ('${nrhoir_dist_name}' in ${nrhoirDNList_value})    Exit For Loop
    END
    ${cell_index}    Evaluate    str(${cell_index})
    ${miNrNRPFW}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1
    ...                                  parameter=miNrNRPFW
    ...                                  value=${measurement_time}
    &{a1ThresholdSCellAddSsbRsrp}   Create Dictionary    a1ThresholdSCellAddSsbRsrpFDD=${a1ThresholdSCellAddSsbRsrpFDD_value}
    ...                                                  a1ThresholdSCellAddSsbRsrpTDD=${a1ThresholdSCellAddSsbRsrpTDD_value}
    ${actInterRatHoSADlDataForward}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                                     parameter=actInterRatHoSADlDataForward
    ...                                                     value=${actInterRatHoSADlDataForward_value}
    ${b2Threshold1hoRsrp}    Create Dictionary    dist_name=${nrhoir_dist_name}
    ...                                           parameter=b2Threshold1hoRsrp
    ...                                           value=${b2Threshold1hoRsrp_value}
    &{b2Threshold2hoRsrp_param}    Create Dictionary    b2Threshold2hoRsrp=${b2Threshold2hoRsrp_value}
    ${b2Threshold2hoRsrp}    Evaluate
    ...    {'dist_name': '${nrhoir_dist_name}', 'parameter': 'eutraB2MeashoRsrp','value':[&{b2Threshold2hoRsrp_param}]}
    ${a2ThresholdhoSsbRsrpSA_dist_name}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    &{a2ThresholdhoSsbRsrpSA_param}    Create Dictionary    a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA_value}
    ${a2ThresholdhoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2ThresholdhoSsbRsrpSA_param}]}
    &{a1ThresholdhoSsbRsrpSA_param}    Create Dictionary    a1ThresholdhoSsbRsrpSA=${a1ThresholdhoSsbRsrpSA_value}
    ${a1ThresholdhoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}', 'parameter': 'a1MeashoSsbRsrpSA','value':[&{a1ThresholdhoSsbRsrpSA_param}]}
    &{a1MeasSsbRsrp}    Evaluate
    ...    {'dist_name': '${a2ThresholdhoSsbRsrpSA_dist_name}','parameter': 'a1MeasSCellAddSsbRsrp','value':[&{a1ThresholdSCellAddSsbRsrp}]}
    @{param_list}    Create List    ${miNrNRPFW}    ${actInterRatHoSADlDataForward}    ${b2Threshold1hoRsrp}
    ...                             ${b2Threshold2hoRsrp}    ${a2ThresholdhoSsbRsrpSA}    ${a1MeasSsbRsrp}    ${a1ThresholdhoSsbRsrpSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update values of some ANR parameters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                For caseID: 5603090
    [Arguments]    ${pcell_index}
    ...            ${ho_pcell_index}
    ...            ${ue_mode}=SA
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
#    ...            ${drxLongCycle_value}=320ms
#    ...            ${drxOnDurationTimer_value}=10ms
    ...            ${cellBarred_value}=notBarred
    ...            ${a2ThresholdhoSsbRsrpSA_value}=76
    ...            ${a2ThresholdhoSsbRsrp_value}=76
    ...            ${a1ThresholdhoSsbRsrp_value}=78
    ...            ${a1ThresholdhoSsbRsrpSA_value}=78
    ...            ${a2MeasReleaseEnabled_value}=none
    ...            ${a3MeasEnabled}=rsrp
    ...            ${a3HysteresisSsbRsrp}=2
    ...            ${a3OffsetSsbRsrp}=8
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    @{param_list}    Create List
    ${pcell_nrhoif_dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${ho_pcell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a3MeasEnabled}    Create Dictionary    dist_name=${pcell_nrhoif_dist_name}
    ...                                                parameter=a3MeasEnabled
    ...                                                value=${a3MeasEnabled}
    &{a3SsbRsrp_param}    Create Dictionary    a3HysteresisSsbRsrp=${a3HysteresisSsbRsrp}
    ...                                        a3OffsetSsbRsrp=${a3OffsetSsbRsrp}
    ${a3SsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_nrhoif_dist_name}', 'parameter': 'a3MeasSsbRsrp','value':[&{a3SsbRsrp_param}]}
    Append To List    ${param_list}      ${a3SsbRsrp}
    ${srbInactivityTimerSA}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    ...                                      parameter=srbInactivityTimerSA    value=600
    Append To List    ${param_list}      ${srbInactivityTimerSA}
    @{cell_list}    Create List     ${pcell_index}     ${ho_pcell_index}
    FOR    ${cell}   IN    @{cell_list}
        ${cellBarred}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                      parameter=cellBarred
        ...                                      value=${cellBarred_value}
        ${a2MeasReleaseEnabled}    Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ...                                                parameter=a2MeasReleaseEnabled
        ...                                                value=${a2MeasReleaseEnabled_value}
        &{a2ThresholdhoSsbRsrpSA_param}    Create Dictionary     a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA_value}
        &{a2ThresholdhoSsbRsrp_param}    Create Dictionary     a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp_value}
        ${dist_name}    Set Variable    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell}
        ${a2ThresholdhoSsbRsrpSA}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2ThresholdhoSsbRsrpSA_param}]}
#        &{drxProfile_values}    Create Dictionary    drxLongCycle=${drxLongCycle_value}
#        ...                                            drxOnDurationTimer=${drxOnDurationTimer_value}
#        ${drxLongCycle}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'drxProfileNrAnr','value':[&{drxProfile_values}]}
        ${a2ThresholdhoSsbRsrp}      Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a2MeashoSsbRsrp','value':[&{a2ThresholdhoSsbRsrp_param}]}
        &{a1ThresholdhoSsbRsrpSA_param}    Create Dictionary    a1ThresholdhoSsbRsrpSA=${a1ThresholdhoSsbRsrpSA_value}
        ${a1ThresholdhoSsbRsrpSA}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a1MeashoSsbRsrpSA','value':[&{a1ThresholdhoSsbRsrpSA_param}]}
        &{a1ThresholdhoSsbRsrp_param}    Create Dictionary    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp_value}
        ${a1ThresholdhoSsbRsrp}    Evaluate
        ...    {'dist_name': '${dist_name}', 'parameter': 'a1MeashoSsbRsrp','value':[&{a1ThresholdhoSsbRsrp_param}]}
#        Append To List    ${param_list}    ${drxLongCycle}    ${cellBarred}
        Append To List    ${param_list}    ${cellBarred}
        Run Keyword If   '${ue_mode}'=='NSA'     Append To List    ${param_list}      ${a2ThresholdhoSsbRsrp}     ${a2MeasReleaseEnabled}
        ...                                                                           ${a1ThresholdhoSsbRsrp}
        ...   ELSE IF    '${ue_mode}'=='SA'      Append To List    ${param_list}      ${a2ThresholdhoSsbRsrpSA}    ${a1ThresholdhoSsbRsrpSA}
    END
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}   timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create maxCsirsNumber parameters
    [Arguments]      ${cell_idx}=${PCELL_INDEX}
    ...              ${maxCsirsNumber}=none
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
    log   ${nr_bts_id}
    log    ${MRBTS_id}
    ${maxCsirsNumber_params}    create dictionary    maxCsirsNumber=${maxCsirsNumber}
    ${maxCsirsNumber_params_list}    create list    ${maxCsirsNumber_params}
    ${maxCsirsNumber_mo}    create dictionary    dist_name=${dist_name}    value=${maxCsirsNumber_params_list}
    ...    parameter=periodicCsiAcquisition
    ${maxCsirsNumber_mo_list}    create list    ${maxCsirsNumber_mo}
    [Return]    ${maxCsirsNumber_mo_list}

Get maxCsirsNumber value From SCF
    [Arguments]      ${cell_idx}=${PCELL_INDEX}
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    log many    ${nr_bts_id}       ${MRBTS_id}
    Connect to gnb coam via ssl
    ${modify_params}    Create maxCsirsNumber parameters    cell_idx=${cell_idx}
    ${periodicCsiAcquisition_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${modify_params}
    ...    connection=${connection}
    ${maxCsirsNumber}    Set Variable    ${periodicCsiAcquisition_values[0]['value'][0]['maxCsirsNumber']}
    [Return]    ${maxCsirsNumber}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get and Modify actCsirsMultiplexing via Admin API
    [Documentation]   lei.jia@nokia-sbell.com
    ...           This keyword is used to modify paramters online via admin CLI.
    [Arguments]      ${timeout}=15 min
    log    ${timeout}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${dist_name}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${PCELL_INDEX}
    ${cur_para_value}    coam_parameter.get_single_value_from_scf_file    parameter=actCsirsMultiplexing
    ...                                                                   dist_name=${dist_name}    connection=GNB_OAM
    ...                                                                   timeout=300
    ${value}    Set Variable If    '${cur_para_value}'=='false'    true    false
    Update actCsirsMultiplexing via Admin API    dist_name=${dist_name}    value=${value}

Update actCsirsMultiplexing via Admin API
    [Arguments]    ${dist_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${PCELL_INDEX}    ${value}=true
    @{params_need_to_modify}    create list
    &{para_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                  parameter=actCsirsMultiplexing    value=${value}
    Append To List    ${params_need_to_modify}    ${para_dict}
    Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}

Update maxCsirsNumber via Admin API
    [Arguments]    ${maxCsirsNumber}=4
    ${maxCsirsNumber_mo_list}    Create maxCsirsNumber parameters    maxCsirsNumber=${maxCsirsNumber}
    Update Params Via RestApi    params_need_to_modify=${maxCsirsNumber_mo_list}

Update BasedPCellSwitchEnabled Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Update a1BasedPCellSwitchEnabled and a2BasedPCellSwitchEnabled of all cells status
    [Arguments]    ${a1BasedPCellSwitchEnabled_value}=false
    ...            ${a2BasedPCellSwitchEnabled_value}=false
    ...            ${class_name}=NRHOIF_A
    ...            ${timeout}=300
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    @{param_list}    Create List
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
        ${a1BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
        ...                                                  parameter=a1BasedPCellSwitchEnabled
        ...                                                  value=${a1BasedPCellSwitchEnabled_value}
        ${a2BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
        ...                                                  parameter=a2BasedPCellSwitchEnabled
        ...                                                  value=${a2BasedPCellSwitchEnabled_value}
        Append To List    ${param_list}    ${a1BasedPCellSwitchEnabled}    ${a2BasedPCellSwitchEnabled}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
	[Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Some Related Parameters Of LTE Cell
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Get eutranCellId, physicalCellId and earfcnDL Of LTE Cell
    [Arguments]    ${cell_index}    ${timeout}=120
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Get eutranCellId, physicalCellId and earfcnDL Of LTE Cell----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${eutranCellId}    Set Variable    ${item['eutranCellId']}
        ${physicalCellId}    Set Variable    ${item['physicalCellId']}
        ${earfcnDL}    Set Variable    ${item['earfcnDownlink']}
        Run Keyword If    'LNCEL-${cell_index}' in '${item['id']['configuration']}'    Exit For Loop
    END
    [Return]    ${eutranCellId}    ${physicalCellId}    ${earfcnDL}
    [Teardown]    Teardown GNB and ENB Connections

Modify Pcell Change Based On A1 Related Paremeters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${scell_index}
    ...            ${actConnectedModeMobilityCA}=true
    ...            ${a1BasedPCellSwitchEnabled}=true
    ...            ${a2MeasSCellRelEnabled}=rsrp
    ...            ${a2HysteresisSCellRelSsbRsrp}=0
    ...            ${a2ThresholdSCellRelSsbRsrp}=34
    ...            ${a1MeasPCellSwitchEnabled}=rsrp
    ...            ${a1HysteresisPCellSwitchSsbRsrp}=0
    ...            ${a1ThresholdPCellSwitchSsbRsrp}=80
    ...            ${a1MeashoEnabledSA}=none
    ...            ${a2MeashoEnabledSA}=none
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    ${actConnectedModeMobilityCA}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRDU-1
    ...                                                   parameter=actConnectedModeMobilityCA
    ...                                                   value=${actConnectedModeMobilityCA}
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
#    FOR    ${mo}    IN    @{MOs}
#        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
#        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
#        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
#        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
#        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
#        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
#        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
#    END
    ${dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${scell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a1BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
    ...                                                  parameter=a1BasedPCellSwitchEnabled
    ...                                                  value=${a1BasedPCellSwitchEnabled}
    ${pcell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${pcell_index}
    ${a2MeasSCellRelEnabled}    Create Dictionary    dist_name=${pcell_distname}
    ...                                              parameter=a2MeasSCellRelEnabled
    ...                                              value=${a2MeasSCellRelEnabled}
    &{a2MeasSCellRelSsbRsrp_param}    Create Dictionary    a2HysteresisSCellRelSsbRsrp=${a2HysteresisSCellRelSsbRsrp}
    ...                                                    a2ThresholdSCellRelSsbRsrp=${a2ThresholdSCellRelSsbRsrp}
    ${a2MeasSCellRelSsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeasSCellRelSsbRsrp','value':[&{a2MeasSCellRelSsbRsrp_param}]}
    ${scell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${scell_index}
    ${a1MeasPCellSwitchEnabled}    Create Dictionary    dist_name=${scell_distname}
    ...                                                 parameter=a1MeasPCellSwitchEnabled
    ...                                                 value=${a1MeasPCellSwitchEnabled}
    ${a1MeashoEnabledSA}    Create Dictionary    dist_name=${scell_distname}    parameter=a1MeashoEnabledSA    value=${a1MeashoEnabledSA}
    ${a2MeashoEnabledSA}    Create Dictionary    dist_name=${scell_distname}    parameter=a2MeashoEnabledSA    value=${a2MeashoEnabledSA}
    &{a1MeasPCellSwitchSsbRsrp_param}    Create Dictionary    a1HysteresisPCellSwitchSsbRsrp=${a1HysteresisPCellSwitchSsbRsrp}
    ...                                                       a1ThresholdPCellSwitchSsbRsrp=${a1ThresholdPCellSwitchSsbRsrp}
    ${a1MeasPCellSwitchSsbRsrp}    Evaluate
    ...    {'dist_name': '${scell_distname}', 'parameter': 'a1MeasPCellSwitchSsbRsrp','value':[&{a1MeasPCellSwitchSsbRsrp_param}]}
    @{param_list}    Create List    ${actConnectedModeMobilityCA}    ${a1BasedPCellSwitchEnabled}
    ...                             ${a2MeasSCellRelEnabled}    ${a2MeasSCellRelSsbRsrp}
    ...                             ${a1MeasPCellSwitchEnabled}    ${a1MeasPCellSwitchSsbRsrp}
    ...                             ${a1MeashoEnabledSA}    ${a2MeashoEnabledSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get expected NRHOIF Value for specified cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]        ${pcell_index}    ${scell_index}
    ...                ${gnb_index}=${0}    ${timeout}=300    ${connection}=GNB_OAM
    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${NRHOIF_dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
    END
    [Return]    ${NRHOIF_dist_name}



Modify Pcell Change Based On A2 Related Paremeters
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${scell_index}
    ...            ${actInterMeNBMobility}=true
    ...            ${actInterFreqHoSA}=true
    ...            ${a2BasedPCellSwitchEnabled}=true
    ...            ${thresholdPCellSwitchTargetRsrp}=50
    ...            ${thresholdPCellSwitchTargetRsrq}=40
    ...            ${a2MeasPCellSwitchEnabled}=rsrp
    ...            ${a2HysteresisPCellSwitchSsbRsrp}=0
    ...            ${a2ThresholdPCellSwitchSsbRsrp}=76
    ...            ${a2ThresholdhoSsbRsrpSA}=66
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    ${actInterMeNBMobility}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                             parameter=actInterMeNBMobility
    ...                                             value=${actInterMeNBMobility}
    ${actInterFreqHoSA}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...                                         parameter=actInterFreqHoSA
    ...                                         value=${actInterFreqHoSA}
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${scell_index}    gnb_index=${gnb_index}    timeout=${timeout}
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${MOs}    coam.get_managed_objects    class_name=NRHOIF_A    connection=${connection}    timeout=${timeout}
#    FOR    ${mo}    IN    @{MOs}
#        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
#        ${nrbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
#        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
#        ${nrhoif_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
#        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-${nrhoif_id}
#        ${ssbFrequency}    Set Variable    ${mo['parameters']['ssbFrequency']}
#        Run Keyword If    '${ssbFrequency}'=='${arfcnSsbPbch}' and '${nrcell_id}'=='${pcell_index}'    Exit For Loop
#    END
    ${dist_name}    Get expected NRHOIF Value for specified cell
    ...                pcell_index=${pcell_index}    scell_index=${scell_index}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${a2BasedPCellSwitchEnabled}    Create Dictionary    dist_name=${dist_name}
    ...                                                  parameter=a2BasedPCellSwitchEnabled
    ...                                                  value=${a2BasedPCellSwitchEnabled}
    ${thresholdPCellSwitchTargetRsrp}    Create Dictionary    dist_name=${dist_name}
    ...                                                       parameter=thresholdPCellSwitchTargetRsrp
    ...                                                       value=${thresholdPCellSwitchTargetRsrp}
    ${thresholdPCellSwitchTargetRsrq}    Create Dictionary    dist_name=${dist_name}
    ...                                                       parameter=thresholdPCellSwitchTargetRsrq
    ...                                                       value=${thresholdPCellSwitchTargetRsrq}
    ${pcell_distname}    Set Variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${pcell_index}
    ${a2MeasPCellSwitchEnabled}    Create Dictionary    dist_name=${pcell_distname}
    ...                                                 parameter=a2MeasPCellSwitchEnabled
    ...                                                 value=${a2MeasPCellSwitchEnabled}
    &{a2MeasPCellSwitchSsbRsrp_param}    Create Dictionary    a2HysteresisPCellSwitchSsbRsrp=${a2HysteresisPCellSwitchSsbRsrp}
    ...                                                       a2ThresholdPCellSwitchSsbRsrp=${a2ThresholdPCellSwitchSsbRsrp}
    ${a2MeasPCellSwitchSsbRsrp}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeasPCellSwitchSsbRsrp','value':[&{a2MeasPCellSwitchSsbRsrp_param}]}
    &{a2MeashoSsbRsrpSA_param}    Create Dictionary    a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA}
    ${a2MeashoSsbRsrpSA}    Evaluate
    ...    {'dist_name': '${pcell_distname}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2MeashoSsbRsrpSA_param}]}
    @{param_list}    Create List    ${actInterMeNBMobility}    ${actInterFreqHoSA}
    ...                             ${a2BasedPCellSwitchEnabled}    ${thresholdPCellSwitchTargetRsrp}    ${thresholdPCellSwitchTargetRsrq}
    ...                             ${a2MeasPCellSwitchEnabled}    ${a2MeasPCellSwitchSsbRsrp}    ${a2MeashoSsbRsrpSA}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check InterRAT HO To LTE Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check 911 call success via wireshark log
    [Arguments]    ${log_path}    ${eutranCellId}    ${physicalCellId}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser
    #---fileter the Handover Required---#
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${cellIdentity_value}    Get Field Value From Pdml    filter_expression=ngap.procedureCode == 12 && s1ap.CellIdentity
    ...                                                   xpath=.//s1ap.CellIdentity
    ...                                                   attribute_name=show
    ${cellIdentity_value}    Get Substring     ${cellIdentity_value[0]}    0   10
    ${cellIdentity_value}    Convert To Binary    ${cellIdentity_value}    base=16
    ${cellIdentity_value}    Convert To Integer    ${cellIdentity_value}    base=2
    Should Be Equal    ${cellIdentity_value}    ${eutranCellId}    msg=InterRAT_HO_LTE is not successful

    #---fileter the required MR of EUTRA ho---#
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=nr-rrc.MeasResultEUTRA_element    alias=${alias}
    ${eutra_PhysCellId}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasResultEUTRA_element/nr-rrc.eutra_PhysCellId
    ...                                                     pcap_parser=${alias}
    ${eutra_PhysCellId}    Remove Duplicates    ${eutra_PhysCellId}
    ${eutra_PhysCellId_length}    Get Length    ${eutra_PhysCellId}
    run keyword if  not '${eutra_PhysCellId_length}'=='1'    Fail    msg=mr abnormal!!!
    ${physicalCellId}    Evaluate    str(${physicalCellId})
    Should Be Equal    ${eutra_PhysCellId}[0]    ${physicalCellId}    msg=InterRAT_HO_LTE is not successful

Check Pcell Change Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check Pcell Change Success in wireshark
    ...               A1 for TDD, A2 for FDD, all for scell
    [Arguments]    ${attach_info}
    ...            ${pcell_change_wireshark_log}
    ...            ${event_type}
    ...            ${scell_index}
    ...            ${after_change_scell_index}
    ...            ${rrc_message_filter}=${SA_RRC_RECONFIGURE_FILTER_ATTACH}
    ...            ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap
    ...            ${alias}=parser
    ...            ${mode}=SA
    ...            ${addition_method}=A1
    log    ${filter}
    #---from cell index change into pci---#
    ${pcell_pci}    Evaluate    str(${PCELL_MAPPING['physicalCellId']})
    ${scell_pci}    Evaluate    str(${SCELL_MAPPING[${scell_index}]['all_cell_info']['physicalCellId']})
    ${after_change_scell_pci}    Evaluate    str(${HO_SCELL_MAPPING[${after_change_scell_index}]['all_cell_info']['physicalCellId']})
    ${rrc_message_filter}    Set Variable If    '${mode}'=='SA'    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                            ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${meas_info_in_rrc}    Get Info From RRC Reconfiguration    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                                         message_filter_expression=${rrc_message_filter}
    ...                                                         alias=${alias}
    Convert CPIF Pcap To Pdml    file_path=${attach_info['cpif_log_path']}
    ...                          filter=f1ap.procedureCode == 12 && nr-rrc.measObjectId && nas-5gs
    ...                          alias=${alias}
    ${measObjectId}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasObjectToAddMod_element/nr-rrc.measObjectId    pcap_parser=${alias}
    ${ssbfrequency}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measObjectNR_element/nr-rrc.ssbFrequency    pcap_parser=${alias}
    ${meas_list}    Get Dictionary Keys    ${meas_info_in_rrc['add_meas_info']}
    FOR    ${meas}    IN    @{meas_list}
        ${mesObj}    Set Variable    ${meas_info_in_rrc['add_meas_info']['${meas}']['mesObj']}
        Run Keyword If    '${mesObj}'=='${measObjectId}[0]'    Set To Dictionary    ${meas_info_in_rrc['add_meas_info']['${meas}']}
        ...    ssbfrequency    ${ssbfrequency}[0]
    END
    ${ssbfreq_regex}    Set Variable If    '${event_type}'=='A2'
    ...                                    x[1]['ssbfrequency']=='${PCELL_MAPPING['ssbfrequency']}'
    ...                                    '${event_type}'=='A1'
    ...                                    x[1]['ssbfrequency']=='${SCELL_MAPPING[${scell_index}]['all_cell_info']['ssbfrequency']}'
    ${event_regex}    Set Variable    x[1]['event_type']=='${event_type}'
    ${lambda_expression}    Set Variable    x:${ssbfreq_regex} and ${event_regex}
    ${meas_info_mapping}    Evaluate    list(filter(lambda ${lambda_expression},${meas_info_in_rrc['add_meas_info']}.items()))
    ${meas_id_length}    Get Length    ${meas_info_mapping}
    Run Keyword If    ${meas_id_length}==${0}    Fail    msg=event type ${event_type} is not configured
    Should Be Equal   ${meas_id_length}    ${1}    msg=more than one measid for event type ${event_type} is filter out,not a valid result.
    ${add_meas_id_in_rrc}    Set Variable    ${meas_info_mapping[0][0]}

    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=nr-rrc.measurementReport_element && nr-rrc.measId
    ...                          alias=${alias}
    ${measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measId    pcap_parser=${alias}
    List Should Contain Value    ${measId_list}    ${add_meas_id_in_rrc}    msg=Measurement Report For ${event_type} is not triggered.

    #---fileter the required Measurement Report---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==13 && nr-rrc.measResultServingMOList && nr-rrc.measId==${add_meas_id_in_rrc}
    ...                          alias=${alias}
    ${pci_list_before_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${pci_list_before_change}[0]    ${pcell_pci}
    Should Be Equal    ${pci_list_before_change}[-1]    ${scell_pci}
    #---fileter the required pci of ho_pcell in rrc reconfiguration after pcell change---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==12 && nr-rrc.spCellConfigCommon_element
    ...                          alias=${alias}
    ${pcell_pci_after_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${pcell_pci_after_change}[0]    ${scell_pci}
    #---fileter the required pci of ho_scell in rrc reconfiguration after pcell change---#
    Convert CPIF Pcap To Pdml    file_path=${pcell_change_wireshark_log}
    ...                          filter=f1ap.procedureCode==12 && nr-rrc.sCellToAddModList
    ...                          alias=${alias}
    ${scell_pci_after_change}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    Should Be Equal    ${scell_pci_after_change}[0]    ${after_change_scell_pci}

Check Mutiple NonGBR Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}
    ...            ${apn}=mdrb.nokia.com
    ...            ${drb_ToAddModList_value}=2
    ...            ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}
    ...                          filter=nr-rrc.rrcReconfiguration_element && nas_5gs.pdu_session_id && nas_5gs.cmn.dnn==${apn}
    ...                          alias=${alias}
    ${drb_ToAddModList}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.drb_ToAddModList    pcap_parser=${alias}
    Should Be Equal    ${drb_ToAddModList}[0]    ${drb_ToAddModList_value}

Modify PA Value By Steps For LA
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Before use this keword must run the keyword "Spark_common_keywords.Spark Start UE Log"
    [Arguments]    ${origin_value}=6    ${times}=${0}    ${modify_ru_id}=0
    ...            ${ue_index}=${0}    ${step}=${1}    ${range}=70    ${sleep_duration}=2
    ${modify_times}    Set Variable    ${times}
    FOR    ${round}    IN RANGE    1    ${range}
        ${interval}    Evaluate    ${round}*${step}
        ${modify_value}    Evaluate    ${origin_value}+${interval}
        Modify PA Value Setting For Required RU    modify_ru_id=${modify_ru_id}    ue_index=${ue_index}    pa_off_value=${modify_value}
        Sleep    ${sleep_duration}sec
        ${modify_times}    Evaluate    ${modify_times}+${step}
        ${NR_RSRP}    Create List    NR SSB RSRP[dBm]
        ${rsrp}    Get Parameter Value    param=${NR_RSRP}
        ${status}    Run Keyword If    ${step}==${1}    Evaluate    ${rsrp}[0]<=-124
        ...          ELSE IF    ${step}==${-1}    Evaluate    ${modify_times}==${0}
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${modify_value}    ${modify_times}

Modify MCS Value By Steps For LA
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Before use this keword must run the keyword "Spark_common_keywords.Spark Start UE Log"
    [Arguments]    ${origin_value}=0    ${times}=${0}    ${ue_index}=${0}    ${step}=${1}    ${range}=70    ${sleep_duration}=2
    ${modify_times}    Set Variable    ${times}
    FOR    ${round}    IN RANGE    1    ${range}
        ${interval}    Evaluate    ${round}*${step}
        ${modify_value}    Evaluate    ${origin_value}+${interval}
        Set Case Related MCS Port Value    att_value=${modify_value}    ue_index=${ue_index}    whether_do_Angles=${False}
        Sleep    ${sleep_duration}sec
        ${modify_times}    Evaluate    ${modify_times}+${step}
        ${NR_RSRP}    Create List    NR SSB RSRP[dBm]
        ${rsrp}    Get Parameter Value    param=${NR_RSRP}
        ${status}    Run Keyword If    ${step}==${1}    Evaluate    ${rsrp}[0]<=-124
        ...          ELSE IF    ${step}==${-1}    Evaluate    ${modify_times}==${0}
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${modify_value}    ${modify_times}

#--- Common keywords for CMAS ---#
Get The Numeber Of Beams From Cellgroup
    [Documentation]   Auther: tingting.1.liu@nokia-sbell.com
    ...               Description: Get the numeber of beams and return.
    [Arguments]    ${cell_id}=1    ${gnb_id}=${0}   ${connection}=GNB_OAM
    Set Test Variable    ${cell_group_id}   ${cell_id}
    ${beamset_para_value}    coam_parameter.get_single_value_from_scf_file
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELLGRP-${cell_group_id}
    ...    parameter=numberOfTransmittedSsBlocks
    ...    connection=${connection}
    ...    timeout=300
    ${beamnumber_para_value}    Fetch From Left    string=${beamset_para_value}    marker=${SPACE}
    ${number_of_beam}    Convert To Integer    ${beamnumber_para_value}
    [Return]    ${number_of_beam}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Current AMF info
    [Arguments]
    Set Test Variable   &{tang_amf}    connect_hostname=10.110.227.31
    Set Test Variable   &{feng_amf}    connect_hostname=10.110.194.163
    Set Test Variable   &{han_amf}    connect_hostname=10.107.180.36
    Set Test Variable   &{zhou_amf}    connect_hostname=10.110.90.92
    Set Test Variable   &{zheng_amf}    connect_hostname=10.110.133.97
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${amf_info}    get_amf_info
    ${amf_info}    Set Variable    ${amf_info['AMF primary IP address']}
    ${current_amf}    Set Variable If    '${amf_info}' == '10.110.90.68'    ${zhou_amf}
    ...                                  '${amf_info}' == '10.110.227.5'    ${tang_amf}
    ...                                  '${amf_info}' == '10.107.180.5'    ${han_amf}
    ...                                  '${amf_info}' == '10.110.133.68'    ${zheng_amf}
    ...                                  '${amf_info}' == '10.110.194.134'    ${feng_amf}
    Set Test Variable   ${current_amf}
    [Teardown]   COAM selenium logout

Trigger CMAS Notification and Capture Logs
    [Arguments]    ${amf}
    ...            ${tac}
    ...            ${nr_phy_cell_ids}
    ...            ${warning_area_list_id}
    ...            ${gnb_id}=${0}
    ...            ${connection}=cbctest
    ...            ${cbctest_ip}=10.9.202.153
    ...            ${cbctest_usr}=cbctest
    ...            ${cbctest_psw}=cbctest
    ...            ${wireshark_log_prefix}=cpif_CMAS
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${timer}=900
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${content_idx}=${1}
    ...            ${timer}=20
    ...            ${mcc}=${tl.core.mcc}
    ...            ${mnc}=${tl.core.mnc}
    log    ${gnb_id}
    log    ${cbctest_usr}
    log    ${cbctest_psw}
    log    ${cbctest_ip}
    Precondition for CMAS Notification    timer=${timer}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_prefix}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    Run Keyword And Continue On Failure
    ...    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${nr_phy_cell_ids}
    Trigger CMAS Notification    amf=${amf}    tac=${tac}    warning_area_list_id=${warning_area_list_id}
    ...                          message_identifier=${message_identifier}    serial_number=${serial_number}
    ...                          repetition_period=${repetition_period}
    ...                          number_of_broadcasts_requested=${number_of_broadcasts_requested}
    ...                          connection=${connection}
    ...                          content_idx=${content_idx}
    ...                          timer=${timer}
    ...                          mcc=${mcc}
    ...                          mnc=${mnc}
    ${bip_log_list}    Run Keyword And Continue On Failure
    ...    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ${cpif_CMAS_log}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}
    [Return]    ${bip_log_list[0]}   ${cpif_CMAS_log}

Precondition for CMAS Notification
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}   ${timer}=${900}   ${connection}=GNB_OAM   ${gnb_id}=${0}
    log many    ${download_dir}    ${timer}
    Connect to gnb coam via ssl    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${dict_gnb_length}    coam_parameter.get_single_value_from_scf_file    dist_name=${dist_name}   parameter=gNbIdLength
    ...                                                                 connection=${connection}
    ...                                                                 timeout=300
    Set Test Variable    ${nr_of_bits_g_node_b_id}    ${dict_gnb_length}
    ${gnb_info}    coam.get_bts_info    connection=${connection}
    Set Test Variable    ${gnodeb_id}   ${gnb_info['mrbtsID']}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BtsName From Gnb
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=${900}   ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}
    Connect to gnb coam via ssl    gnb_index=${gnb_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${gnb_info}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${btsName}    Set Variable    ${gnb_info['name']}
    [Return]    ${btsName}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BtsName and SwVersion
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${timeout}=${900}   ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}
    Connect to gnb coam via ssl    gnb_index=${gnb_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${gnb_info}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${btsName}    Set Variable    ${gnb_info['name']}
    ${swVersion}    Set Variable    ${gnb_info['swInfo']['swVersion']}
    [Return]    ${btsName}    ${swVersion}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get scf stream and sw stream
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${scf_name}    ${sw_version}
    # get stream version from sw version
    ${version_splitted}    Split String    ${sw_version}    _
#    ${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    ${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    _9999_    _9990_
#    ${stream_version}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}

    # get scf version from sw name
    ${stream_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${part_scf_name}    Fetch From Right    ${scf_name}    ${tl_prefix}_gNB_
    ${scf_version}    Fetch From Left    ${part_scf_name}    _
	[Return]    ${scf_version}    ${stream_version}

Start BIP Capture and Download File with Interface Mirroring Collector
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_prefix}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    Collect Interface Mirroring Bip Collector    target_file_name=${log_prefix}    nr_phy_cell_ids=${nr_phy_cell_ids}
    Sleep    3 sec
    ${bip_log_list}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${log_prefix}
    [Return]    ${bip_log_list[0]}

Trigger CMAS Notification
    [Arguments]    ${amf}
    ...            ${tac}
    ...            ${warning_area_list_id}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${content_idx}=${0}
    ...            ${cbctest_ip}=10.9.202.153
    ...            ${cbctest_usr}=cbctest
    ...            ${cbctest_psw}=cbctest
    ...            ${connection}=cbctest
    ...            ${timer}=30
    ...            ${mcc}=${tl.core.mcc}
    ...            ${mnc}=${tl.core.mnc}
    ${cmd_local}   Run Keyword If  '${tl_prefix}'=='T283'   catenate    /tmp/cit/testcase /home/cbctest/test_amf_cit_ltt.py
    ...                         ${amf}[connect_hostname] ${tl.core.mcc} ${tl.core.mnc}
    ...                         ${tac} ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${repetition_period}
    ...                         ${number_of_broadcasts_requested} ${warning_area_list_id} ${content_idx}
         ...    ELSE    catenate    /tmp/cit/testcase /home/cbctest/test_amf_tmoe2e_gnb80.py
    ...                             ${amf}[connect_hostname] ${mcc} ${mnc}
    ...                             ${tac} ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                             ${message_identifier} ${serial_number} ${repetition_period}
    ...                             ${number_of_broadcasts_requested} ${warning_area_list_id} ${content_idx}
    csn.connect to    hostname=${cbctest_ip}
    ...               username=${cbctest_usr}
    ...               password=${cbctest_psw}
    ...               alias=${connection}
    Log To Console     ${\n}INFO: -- Start to send command on CMAS: ${cmd_local}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${timer}s
    csn.read_output    connection=${connection}

Check Complete Procedure for CMAS Broadcasting
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${cpif_CMAS_log_path}
    ...            ${bip_log_path}
    ...            ${cellid}=${0}
    ...            ${alias}=parser
    ...            ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${last_segment_repeat_times}=${default_last_segment_repeat_times}
    log many    ${cellid}    ${filter}
    ${string}    Convert To Hex    ${serial_number}    length=4
    ${string}    Convert To String    ${string}
    ${substring_0}    Get Substring    ${string}    0    2
    ${substring_1}    Get Substring    ${string}    2
    ${serial_number}    Set Variable    ${substring_0}:${substring_1}
    ${ngap_WRWReq_filter_expression}    catenate    ngap.WriteReplaceWarningRequest_element and ngap.procedureCode == 51
    ...                                             and ngap.SerialNumber == ${serial_number}
    ...                                             and ngap.MessageIdentifier == ${message_identifier}
    ...                                             and ngap.RepetitionPeriod == ${repetition_period}
    ...                                             and ngap.NumberOfBroadcastsRequested == ${number_of_broadcasts_requested}
    Convert CPIF Pcap To Pdml    file_path=${cpif_CMAS_log_path}    filter=f1ap||nr-rrc||ngap
    ...                          alias=${alias}
    ${output1}  pcap.Filter Packets By Expression    filter_expression=${ngap_WRWReq_filter_expression}  pcap_parser=${alias}
    ${values1}    pcap.get_field_value_by_xpath    xpath=.//ngap.initiatingMessage_element/ngap.procedureCode    pcap_parser=${alias}
    should not be empty    ${values1}
    ${wmc}    pcap.get_field_value_by_name    field_name=ngap.WarningMessageContents    pcap_parser=${alias}
    ${wac}    pcap.get_field_value_by_name    field_name=ngap.WarningAreaCoordinates   pcap_parser=${alias}
    ${output2}  pcap.Filter Packets By Expression    filter_expression=f1ap.WriteReplaceWarningRequest_element  pcap_parser=${alias}
    ${values2}    pcap.get_field_value_by_xpath    xpath=.//f1ap.initiatingMessage_element/f1ap.procedureCode   pcap_parser=${alias}
    should not be empty    ${values2}
    ${output3}  pcap.Filter Packets By Expression    filter_expression=f1ap.WriteReplaceWarningResponse_element and f1ap.id == 146
    ...                                              pcap_parser=${alias}
    ${values3}    pcap.get_field_value_by_xpath    xpath=.//f1ap.successfulOutcome_element/f1ap.procedureCode   pcap_parser=${alias}
    should not be empty    ${values3}
    Run Keyword And Ignore Error    pcap.Filter Packets By Expression
    ...          filter_expression=ngap.WriteReplaceWarningResponse_element and ngap.procedureCode == 51 and ngap.id == 13
    ...                                              pcap_parser=${alias}
    ${status}   ${value}   Run Keyword And Ignore Error   pcap.get_field_value_by_name
    ...                                             field_name=ngap.NRCellIdentity   pcap_parser=${alias}
    Run Keyword And Ignore Error   should not be empty    ${value}
    run keyword if  not '${status}' == 'PASS'   Run Keywords   pcap.Filter Packets By Expression
    ...          filter_expression=ngap.WriteReplaceWarningResponse_element and ngap.procedureCode == 51 and ngap.id == 13
    ...                                              pcap_parser=${alias}
    ...   AND   pcap.get_field_value_by_xpath
       ...              xpath=.//_[1]/ngap.CellIDBroadcastNR_Item_element/ngap.nR_CGI_element/ngap.NRCellIdentity
       ...              pcap_parser=${alias}
    ${bip_sib8_wmc_filter_expression}    catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and nr-rrc.sib_TypeAndInfo_item == 6
    ${bip_sib8_datacodingscheme_filter_expression}   catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and nr-rrc.warningMessageSegmentNumber==0
    ...                                              and nr-rrc.dataCodingScheme == 04
    ...                                              and nr-rrc.sib_TypeAndInfo_item == 6
#    ${sib8_periodicity}    Check SIB8 Scheduling in SIB1    bip_log=${bip_log_path}
    Convert CPIF Pcap To Pdml     file_path=${bip_log_path}
    ...                          filter=nr-rrc.sib_TypeAndInfo_item == 6
    ...                          alias=${alias}
    pcap.filter_packets_by_expression    filter_expression=${bip_sib8_wmc_filter_expression}   pcap_parser=${alias}
    ${warningMessageSegmentType}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegmentType
    ...                                                             pcap_parser=${alias}
    ${last_segment_cnt}    Get Count    ${warningMessageSegmentType}    1
    ${real_number_of_lastsegment}    Evaluate    ${last_segment_repeat_times} * ${number_of_broadcasts_requested}
    ${status}  Set Variable If   ${last_segment_cnt}>=${real_number_of_lastsegment}   ${True}   ${False}
    Should Be True   '${status}' == 'True'
    ${values}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegment    pcap_parser=${alias}
    should not be empty    ${values}
    Convert CPIF Pcap To Pdml     file_path=${bip_log_path}
    ...                          filter=nr-rrc.sib_TypeAndInfo_item == 6
    ...                          alias=${alias}
    pcap.filter_packets_by_expression    filter_expression=${bip_sib8_datacodingscheme_filter_expression}    pcap_parser=${alias}
    ${values}    pcap.get_field_value_by_name    field_name=nr-rrc.warningAreaCoordinatesSegment    pcap_parser=${alias}
    should not be empty    ${values}
    Compare WMC and WAC in SIB8    bip_log=${bip_log_path}
    ...                            filter_expression=${bip_sib8_wmc_filter_expression}
    ...                            wmc=${wmc[0]}
    ...                            wac=${wac[0]}
    [Return]    ${wmc[0]}    ${wac[0]}

