*** Settings ***
Documentation    Common keyword for mobility and CA cases.
Library    mobility_and_ca_lib.py
Library    mobility_and_ca_lib.MobilityCAConfiguration    WITH NAME  mbca
Library    mobility_and_ca_lib.GnbOperation    WITH NAME  gnbaction
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/CA_common_keywords.robot


*** Variables ***
&{EVENT_TYPE_MAPPING}    0=A1    1=A2   2=A3    4=A5    5=A6    3=A4    not_event=${None}
${SA_RRC_RECONFIGURE_FILTER_ATTACH}    nr-rrc.rrcReconfiguration_element&&nas_5gs.pdu_session_id&&nr-rrc.measObjectToAddModList
${NSA_RRC_RECONFIGURE_FILTER_ATTACH}    x2ap.procedureCode == 27 && nr-rrc.measIdToAddModList
${SA_RRC_RECONFIGURE_FILTER_HANDOVER}   f1ap.procedureCode == 12 && nr-rrc.physCellId && !nr-rrc.sCellToAddModList
#${SA_RRC_RECONFIGURE_FILTER_HANDOVER}   nr-rrc.measIdToAddModList && f1ap.procedureCode == 12  && nr-rrc.eventId == 1
${NSA_RRC_RECONFIGURE_FILTER_HANDOVER}    x2ap.procedureCode == 30 && nr-rrc.physCellId && !nr-rrc.sCellToAddModList
${NSA_RRC_RECONFIGURE_FILTER_HANDOVER_A13}    f1ap.procedureCode == 12 && nr-rrc.physCellId && !nr-rrc.sCellToAddModList
${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}    nr-rrc.sCellToAddModList && f1ap.procedureCode == 12
${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_A1}    nr-rrc.sCellToAddModList && x2ap.procedureCode == 30
${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_blind}    nr-rrc.sCellToAddModList && x2ap.procedureCode == 27
${SA_RRC_RECONFIGURE_FILTER_SCELL_RELEASE}    nr-rrc.rrcReconfiguration_element && nr-rrc.sCellToReleaseList
${NSA_RRC_RECONFIGURE_FILTER_SCELL_RELEASE}    x2ap.procedureCode == 30 && nr-rrc.sCellToReleaseList
${SA_INTER_HO_RRC_RECONFIGURE_FILTER}    f1ap.procedureCode == 7 && nr-rrc.physCellId
${NSA_INTER_HO_RRC_RECONFIGURE_FILTER}    x2ap.procedureCode == 30 && nr-rrc.physCellId
${NSA_INTER_HO_MEAS_RRC_RECONFIGURE_FILTER}    x2ap.procedureCode == 27 && x2ap.protocolIEs == 5
${SA_INTER_HO_MEAS_RRC_RECONFIGURE_FILTER}    f1ap.procedureCode == 5 && nr-rrc.measId
${INTRA_RRC_RECONFIGURE_FILTER_FALLBACK}    f1ap.procedureCode == 12 && nr-rrc.physCellId && !(nr-rrc.sCellToAddModList == 1)

*** Keywords ***
#--- Common Procedures KW ---#
Procedures.CA Basic Attach L3 Call Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${mode}=SA    ${gnb_index}=0    ${coam_connection}=GNB_OAM
    ...            ${tput_collect_duration}=120    ${expect_addition_scell_indexs}=${None}    ${scell_addition_method}=A1
    ...            ${check_pcell_tput_type}=peak   ${check_scell_tput_type}=peak    ${data_transfer_duration}=3600
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.8
    ...            ${check_ul_pcell_tput_type}=peak    ${ue_index}=${0}
    ...            ${dl_data_transfer}=3000M    ${ul_data_transfer}=130M
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${is_vonr_ip_exist}=${False}
    ...            ${is_vonr_call_needed}=${False}
    ...            ${is_do_require_ue}=${True}
    ...            ${scell_activation_method}=buffer
    ...            ${is_scell_addition_needed}=${True}
    ...            ${check_scell_tput}=${True}
    ...            ${enb_index}=0
    ...            ${inactivate_scell_index_list}=@{EMPTY}
    ...            ${auto_required_dl_tput_layers}=${False}
    ...            ${is_capture_bip_during_traffic}=${False}
    ...            ${extra_expect_secll_tp_percent}=1
    ...            ${extra_expect_pecll_tp_percent}=1
    ...            ${whether_8311_feature_enable}=${False}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${nr_phy_cell_ids}=333,411
    Log To Console    \n****** start to attach and verify L3 call ******\n
    Comment    \n****** step0:some additional operations before attach ******\n
    Run Keyword If    '${mode}'=='NSA'    Modify PA Value For ENB
    Comment    \n****** step1:start to attach with specific UE type ******\n
    Run keyword if    ${is_do_require_ue}    Procedures.UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_mode=${mode}
    ...                                       ue_type=${ue_type}
    ...                                       coam_connection=${coam_connection}
    ...                                       ue_index=${ue_index}
    ...                                       gnb_index=${gnb_index}
    ...                                       enb_wireshark_log_prefix=enb_wireshark_log
    ...                                       enb_index=${enb_index}
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    Log To Console    ${attach_info}
    Comment    \n****** step2:generate pcell and scell mapping result: ${PCELL_MAPPING},${SCELL_MAPPING} ******\n
    Generate Pcell And Scell Mapping Info    pcell_index=${attach_info['attach_cell_index']}    source_gnb_id=${gnb_index}
    Comment    \n****** step3(Optional):check scell addition success with A1 or blind method ******\n
    ${addition_scell_index_list}    Run Keyword If    ${is_scell_addition_needed} and '${scell_addition_method}'=='A1'
    ...                                               Message_Flow_Check.A1 Addition Process
    ...                                               addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...    ELSE IF    ${is_scell_addition_needed}     Check Scell Addition Success
    ...                                               cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                               addition_method=${scell_addition_method}
    Comment    \n****** step4(Optional):check scell activatation success if activation method is blind ******\n
    ${status}    ${attach_aasyslog_list}    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=5Grach
    Run Keyword If    ${is_scell_addition_needed} and '${scell_activation_method}' == 'blind'
    ...                Run Keyword And Ignore Error    Check Scell Activation Success    log_path=${attach_aasyslog_list[0]}
    Comment    \n****** step5:get pcell and scell belonged ru index  ******\n
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    ${temp_empty_list}    Create List
    ${addition_scell_index_list}    Set Variable If
    ...    ${is_scell_addition_needed}    ${addition_scell_index_list}
    ...    '${is_scell_addition_needed}'=='${False}' and ${whether_8311_feature_enable}    ${expect_addition_scell_indexs}
    ...    '${is_scell_addition_needed}'=='${False}' and '${whether_8311_feature_enable}'=='${False}'    ${temp_empty_list}
    FOR  ${scell_index}  IN  @{addition_scell_index_list}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Comment    \n****** step6 start ul/dl data transfer   ******\n
    ${ue_iperf_path}    Set Variable If    '${ue_type}'=='mtk'     /data/local/tmp/iperf    iperf
    ${need_get_ue_ip}    Set Variable If    '${ue_type}'=='mtk' or ${is_vonr_ip_exist}    ${True}    ${False}
    ${cpif_log_path}    Set Variable If    '${mode}'=='NSA'    ${attach_info['enb_wireshark_log_path']}
    ...                                                        ${attach_info['cpif_log_path']}
    Run Keyword If    ${whether_8311_feature_enable}    Run Keyword And Continue On Failure
    ...    Start Container Capture Wireshark Log     tcpdump_collector_name=cpif_scell_addition
    ...    cprt_collector_name=cprt_scell_addition
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=${data_transfer_duration}
    ...                            need_get_ue_ip=${need_get_ue_ip}
    ...                            cpif_log_path=${cpif_log_path}
    ...                            ue_iperf_path=${ue_iperf_path}
    ...                            mode=${mode}
    ...                            ue_index=${ue_index}
    Sleep    5sec
    ${cpif_scell_addition_log_on_testPC}    Run Keyword If    ${whether_8311_feature_enable}
    ...    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=cpif_scell_addition
    ...                                                                                      cprt_collector_name=cprt_scell_addition
    ...                                                                                      gnb_index=${gnb_index}
    ${dl_layers_dict}    Run Keyword If    ${auto_required_dl_tput_layers}    Get DL Tput Layers From Wireshark
    ...                                                                       cpif_log_path=${cpif_log_path}
    ...                                                                       mode=${mode}
    ...                                                                       alias=parser
    ...                                                                       addition_method=${scell_addition_method}
    ...                                                                       whether_8311_feature_enable=${whether_8311_feature_enable}
    ...                                                                       scell_cpif_log_path=${cpif_scell_addition_log_on_testPC}
    Comment    \n****** step7(Optional):start vonr call if vonr case  ******\n
    Run Keyword If    ${is_vonr_call_needed}    Procedures.Vonr Call Setup Test     gnb_index=${gnb_index}    ue_index=${ue_index}
    Comment    \n****** step8:check ul/dl tput  ******\n
    ${tupt_output}    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_index}
    ...                                    duration=${tput_collect_duration}
    ...                                    addition_scell_index_list=${addition_scell_index_list}
    ...                                    check_pcell_tput_type=${check_pcell_tput_type}
    ...                                    check_scell_tput_type=${check_scell_tput_type}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    check_scell_tput=${check_scell_tput}
    ...                                    inactivate_scell_index_list=${inactivate_scell_index_list}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    ...                                    extra_expect_pecll_tp_percent=${extra_expect_pecll_tp_percent}
    ...                                    extra_expect_secll_tp_percent=${extra_expect_secll_tp_percent}
    Comment    \n****** step9(Optional):start vonr call if vonr case  ******\n
    Run Keyword If    ${is_vonr_call_needed}    Procedures.Vonr Call Release Test     gnb_index=${gnb_index}    ue_index=${ue_index}
    Comment    \n****** step9.1(Optional):start capture bip logs  ******\n
    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
    ...    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${nr_phy_cell_ids}
    Run Keyword If    ${is_capture_bip_during_traffic}    Sleep    6sec
    ${bip_log_path}    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
    ...    Get Bip Log Via Interface Mirroring Collector
#    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
#    ...    Capture Logs With gNB_logs    bbmod_slots=${capture_bbmod_slot}    duration=6    log_type=BIP    gnb_index=${gnb_index}
#    ${bip_log_path}    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
#    ...    Get Captured BIP File    gnb_index=${gnb_index}
    Comment    \n****** step10:return detailed pcell and scell related info dict during attach ******\n
    ${attach_ca_cell_info_dict}    Create Dictionary    pcell_index=${attach_info['attach_cell_index']}
    ...                                                 scell_index_list=${addition_scell_index_list}
    ...                                                 source_gnb_id=${gnb_index}
    ...                                                 pcell_ru_index=${pcell_ru_index}
    ...                                                 scell_ru_index_list=${scell_ru_index_list}
    ...                                                 attach_cpif_log=${attach_info['cpif_log_path']}
    ...                                                 bip_log_path=${bip_log_path}
    ...                                                 cpif_scell_addition_log=${cpif_scell_addition_log_on_testPC}
    ...                                                 tput_dict=${tupt_output}
    [Return]    ${attach_ca_cell_info_dict}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=cpif_scell_addition    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=cpif_scell_addition    AND
    ...                           Run Keyword If    ${is_vonr_call_needed}    Run keyword and ignore error     Hang Up Vonr Call
    ...                                                                                                            ue_index=${ue_index}

Procedures.Deactivate And Reactivate Data Transfer Process
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_log_path}    ${addition_scell_index_list}    ${tput_collect_duration}=60    ${gnb_index}=0
    ...            ${check_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85    ${expect_tp_percent}=1
    ...            ${dl_data_transfer}=3000M    ${ul_data_transfer}=130M
    ...            ${ue_iperf_path}=/data/local/tmp/iperf    ${ue_index}=${0}
    ...            ${need_to_check_tput}=${True}     ${mode}=SA
    ...            ${data_transfer_duration}=360    ${check_ul_pcell_tput_type}=peak    ${is_multi_pdu}=${False}
    Log Many    ${expect_tp_percent}    ${is_multi_pdu}
    Log To Console    \n***start to deactivate and reactivate data transfer***
    Comment    \n****** step1:stop data traffic without detach  ******\n
    Stop Traffic With Power UE    is_detach=${False}
    Sleep  10sec
    Comment    \n****** step2:re-start ul/dl data transfer  ******\n
    ${ue_iperf_path}    Set Variable If    '${ue_type}'=='mtk'     /data/local/tmp/iperf    iperf
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=${data_transfer_duration}
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_log_path}
    ...                            ue_iperf_path=${ue_iperf_path}
    ...                            mode=${mode}
    ...                            ue_index=${ue_index}
    Comment    \n****** step3:re-check ul/dl tput  ******\n
    Run Keyword If    ${need_to_check_tput}     Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                         ue_type=${ue_type}
    ...                                         gnb_index=${gnb_index}
    ...                                         duration=${tput_collect_duration}
    ...                                         addition_scell_index_list=${addition_scell_index_list}
    ...                                         check_pcell_tput_type=${check_pcell_tput_type}
    ...                                         check_scell_tput_type=${check_scell_tput_type}
    ...                                         target_DL_avg_percent=${target_DL_avg_percent}
    ...                                         target_UL_avg_percent=${target_UL_avg_percent}
    ...                                         min_DL_percent=${min_DL_percent}
    ...                                         min_UL_percent=${min_UL_percent}
    ...                                         min_scell_percent=${min_scell_percent}
    ...                                         check_ul_pcell_tput_type=${check_ul_pcell_tput_type}

Procedures.CA Basic Handover Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_ca_call_info_dict}
    ...            ${handover_gnb_type}=Intra
    ...            ${frequency_type}=Intra
    ...            ${handover_round}=0
    ...            ${tput_collect_duration}=120
    ...            ${check_pcell_tput_type}=peak
    ...            ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.8
    ...            ${pa_interval}=10
    ...            ${shutdown_interval}=10
    ...            ${range}=10
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${expect_tp_percent}=1
    ...            ${is_pcell_shutdown_ho_case}=${False}
    ...            ${mode}=SA
    ...            ${addition_method}=A1
    ...            ${step}=1
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${need_to_trigger_A1_addition}=${False}
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${update_A1_scell_addition_threshold_value}=100
    ...            ${pre_A1_scell_addition_threshold_value}=60
    ...            ${update_scell_topology}=TDD
    ...            ${auto_required_dl_tput_layers}=${False}
    ...            ${extra_expect_secll_tp_percent}=1
    ...            ${extra_expect_pecll_tp_percent}=1
    ...            ${extra_message_filter}=${None}
    Log Many    ${expect_tp_percent}    ${pre_A1_scell_addition_threshold_value}
    Log To Console    \n****** start to generate handover releated info ******\n
    ${source_gnb_id}    Set Variable    ${attach_ca_call_info_dict['source_gnb_id']}
    ${target_gnb_id}     Set Variable If    '${handover_gnb_type}'=='Intra' and '${source_gnb_id}'=='0'    0
    ...                                     '${handover_gnb_type}'=='Intra' and '${source_gnb_id}'=='1'    1
    ...                                     '${handover_gnb_type}'=='Inter' and '${source_gnb_id}'=='0'    1
    ...                                     '${handover_gnb_type}'=='Inter' and '${source_gnb_id}'=='1'    0
    Run Keyword And Continue On Failure    Generate Handover Pcell And Scell Mapping Info
    ...                                    pcell_index=${attach_ca_call_info_dict['pcell_index']}
    ...                                    source_gnb_id=${source_gnb_id}
    ...                                    frequency_type=${frequency_type}
    ...                                    handover_gnb_type=${handover_gnb_type}
    ${handover_scell_index}    Get Dictionary Keys   ${HANDOVER_SCELL_MAPPING}
    ${source_scell_index}    Get Dictionary Keys   ${SCELL_MAPPING}
    ${common_scell_index}    Evaluate    [x for x in ${handover_scell_index} if x in ${source_scell_index}]
    ${handover_pcell_ru_index}    Set Variable    ${HANDOVER_PCELL_MAPPING['ru_index_mapping']}
    ${handover_scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{handover_scell_index}
        ${handover_scell_ru_index}    Set Variable    ${HANDOVER_SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${handover_scell_ru_index_list}    ${handover_scell_ru_index}
    END

    IF    ${expect_addition_scell_indexs}!=${None}
        ${tmp_scell_index}    Evaluate    int(${expect_addition_scell_indexs}[0])
        ${tmp_handover_scell_ru_index_list}    Create List    ${HANDOVER_SCELL_MAPPING[${tmp_scell_index}]['all_cell_info']['ru_index_mapping']}
    END
#    ${tmp_handover_scell_ru_index_list}    Run Keyword If    '${stream_version}'=='master' and ${expect_addition_scell_indexs}!=${None}
#    ...    Create List    ${HANDOVER_SCELL_MAPPING[${tmp_scell_index}]['all_cell_info']['ru_index_mapping']}
    IF    ${expect_addition_scell_indexs}!=${None}
        ${handover_scell_ru_index_list}    Set Variable    ${tmp_handover_scell_ru_index_list}
    ELSE
        ${handover_scell_ru_index_list}    Set Variable    ${handover_scell_ru_index_list}
    END
#    ${handover_scell_ru_index_list}    Set Variable If    '${stream_version}'=='master' and ${expect_addition_scell_indexs}!=${None}
#    ...    ${tmp_handover_scell_ru_index_list}    ${handover_scell_ru_index_list}
    ${common_scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{common_scell_index}
        ${common_scell_ru_index}    Set Variable    ${HANDOVER_SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${common_scell_ru_index_list}    ${common_scell_ru_index}
    END
    ${handover_ru_index_list_for_ca_group}    Create List    ${handover_pcell_ru_index}     @{handover_scell_ru_index_list}
    ${attach_ru_index_list_for_ca_group}    Create List    @{attach_ca_call_info_dict['scell_ru_index_list']}
    ...                                                    ${attach_ca_call_info_dict['pcell_ru_index']}
    ${attach_ru_index_list_for_ca_group}    Remove Duplicates    ${attach_ru_index_list_for_ca_group}
    Change cellBarred Parameter Value On Gnb    pcell_index=${HANDOVER_PCELL_INDEX}
    ...                                         exp_status=notBarred
    ...                                         connection=GNB_OAM${target_gnb_id}
    ...                                         gnb_id=${target_gnb_id}
    ...                                         timeout=300
    Run Keyword If    ${need_to_trigger_A1_addition}    Procedures.Update A1 Scell Addition Threshold
    ...                                                 pcell_index=${HANDOVER_PCELL_INDEX}
    ...                                                 gnb_id=${target_gnb_id}
    ...                                                 update_A1_scell_addition_threshold_value=${update_A1_scell_addition_threshold_value}
    ...                                                 topology=${update_scell_topology}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${attach_ca_call_info_dict['source_gnb_id']}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...                                                                   cprt_collector_name=cprt_ca_handover_round${handover_round}
    ...                                                                   tcpdump_collector_name=ca_handover_round${handover_round}
    ...                                                                   asik_connection_alias=ASIK Master
    ...                                                                   gnb_index=${attach_ca_call_info_dict['source_gnb_id']}
    ...                                                                   du_index=0
    Run Keyword If    '${handover_gnb_type}'=='Inter'    Run Keyword And Continue On Failure
    ...                                                  Start Container Capture Wireshark Log
    ...                                                  cprt_collector_name=cprt_ca_handover_round${handover_round}_inter_ho_target
    ...                                                  tcpdump_collector_name=ca_handover_round${handover_round}_inter_ho_target
    ...                                                  asik_connection_alias=ASIK Master
    ...                                                  gnb_index=${target_gnb_id}
    ...                                                  du_index=0
    Sleep    60sec
    Run Keyword If    '${is_pcell_shutdown_ho_case}'=='${False}' and '${frequency_type}'=='Intra'
    ...                                                             Modify Handover PA Value By Steps For CA Group
    ...                                                             source_gnb_id=${source_gnb_id}
    ...                                                             target_gnb_id=${target_gnb_id}
    ...                                                             source_ru_index_list=${attach_ru_index_list_for_ca_group}
    ...                                                             target_pcell_ru_index=${handover_pcell_ru_index}
    ...                                                             target_scell_ru_index=${handover_scell_ru_index_list}
    ...                                                             interval=${pa_interval}
    ...                                                             range=${range}
    ...                                                             step=${step}
    ...                                                             common_scell_ru_list=${common_scell_ru_index_list}
    ...    ELSE IF    '${is_pcell_shutdown_ho_case}'=='${False}' and '${frequency_type}'=='Inter'
    ...                                                             Modify Handover PA Value By Steps For Inter Frequency Handover
    ...                                                             source_gnb_id=${source_gnb_id}
    ...                                                             target_gnb_id=${target_gnb_id}
    ...                                                             source_ru_index_list=${attach_ru_index_list_for_ca_group}
    ...                                                             target_pcell_ru_index=${handover_pcell_ru_index}
    ...                                                             target_scell_ru_index=${handover_scell_ru_index_list}
    ...                                                             interval=${pa_interval}
    ...                                                             range=${range}
    ...                                                             step=${step}
    ...                                                             common_scell_ru_list=${common_scell_ru_index_list}
    ...    ELSE    Run Keywords    Initial PA Value Setting For Required RU    modify_ru_id=${handover_pcell_ru_index}   gnb_id=${target_gnb_id}
    ...            AND    Initial PA Value Setting For Required RU    modify_ru_id=${handover_scell_ru_index_list}    gnb_id=${target_gnb_id}
    ...            AND    Modify PA Value For Required RU With Interval    ru_index=${attach_ru_index_list_for_ca_group}
    ...                                                                    gnb_id=${source_gnb_id}
    ...                                                                    interval=${shutdown_interval}
    ...            AND            Procedures.CA Cell Shutdown    attach_ca_call_info_dict=${attach_ca_call_info_dict}    gnb_id=${source_gnb_id}
    ${A1_value}    Set Variable    -10
    Run Keyword If    ${need_to_trigger_A1_addition}   Modify PA Value For Required RU With Interval
    ...                                                ru_index=${handover_pcell_ru_index}
    ...                                                gnb_id=${target_gnb_id}
    ...                                                interval=${A1_value}
    Sleep    30sec
    ${handover_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                             cprt_collector_name=cprt_ca_handover_round${handover_round}
    ...                                                             tcpdump_collector_name=ca_handover_round${handover_round}
    ...                                                             target_dir=${TS_CASE_LOG_PATH}
    ...                                                             gnb_index=${attach_ca_call_info_dict['source_gnb_id']}
    ...                                                             du_index=0
    ${inter_ho_target_handover_wireshark}    Run Keyword If    '${handover_gnb_type}'=='Inter'
    ...                             Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                             cprt_collector_name=cprt_ca_handover_round${handover_round}_inter_ho_target
    ...                             tcpdump_collector_name=ca_handover_round${handover_round}_inter_ho_target
    ...                             target_dir=${TS_CASE_LOG_PATH}
    ...                             gnb_index=${target_gnb_id}
    ...                             du_index=0
    ${check_scell_addition_target_wireshark_path}    Set Variable If    '${handover_gnb_type}'=='Inter'    ${inter_ho_target_handover_wireshark}
    ...                                                                                                    ${handover_wireshark}
    ${handover_addition_scell_index_list}    Run Keyword And Continue On Failure    Check Scell Addition Success
    ...                                      cpif_log_path=${check_scell_addition_target_wireshark_path}
    ...                                      mode=${mode}
    ...                                      addition_method=${addition_method}
    ...                                      scell_mapping=${HANDOVER_SCELL_MAPPING}
    ...                                      expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                      extra_message_filter=${extra_message_filter}
    ${handover_dl_layers_dict}    Get DL Tput Layers From Wireshark    cpif_log_path=${check_scell_addition_target_wireshark_path}
    ...                                                                mode=${mode}
    ...                                                                alias=parser
    ...                                                                addition_method=${addition_method}
    ...                                                                is_handover=${handover_gnb_type}
    Run Keyword If    ${need_to_trigger_A1_addition}    Initial PA Value Setting For Required RU    modify_ru_id=${handover_pcell_ru_index}
    ...                                                 gnb_id=${target_gnb_id}
    Log To Console    \n****** start to check tput after handover ******\n
    ${tupt_output}    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${target_gnb_id}
    ...                                    duration=${tput_collect_duration}
    ...                                    addition_scell_index_list=${handover_addition_scell_index_list}
    ...                                    pcell_mapping=${HANDOVER_PCELL_MAPPING}
    ...                                    scell_mapping=${HANDOVER_SCELL_MAPPING}
    ...                                    check_pcell_tput_type=${check_pcell_tput_type}
    ...                                    check_scell_tput_type=${check_scell_tput_type}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    ...                                    extra_expect_pecll_tp_percent=${extra_expect_pecll_tp_percent}
    ...                                    extra_expect_secll_tp_percent=${extra_expect_secll_tp_percent}
    ${handover_ca_cell_info_dict}    Create Dictionary    pcell_index=${HANDOVER_PCELL_INDEX}
    ...                                                   scell_index_list=${handover_scell_index}
    ...                                                   source_gnb_id=${target_gnb_id}
    ...                                                   pcell_ru_index=${handover_pcell_ru_index}
    ...                                                   scell_ru_index_list=${handover_scell_ru_index_list}
    ...                                                   handover_cpif_log=${handover_wireshark}
    ...                                                   inter_handover_target_cpif_log=${inter_ho_target_handover_wireshark}
    ...                                                   tput_dict=${tupt_output}
    [Return]    ${handover_ca_cell_info_dict}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.CA Fallback Handover Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${pre_handover_ca_call_info_dict}
    ...            ${fallback_handover_gnb_type}=Intra
    ...            ${fallback_frequency_type}=Intra
    ...            ${handover_round}=1
    ...            ${tput_collect_duration}=120
    ...            ${target_DL_avg_percent}=0.9
    ...            ${target_UL_avg_percent}=0.8
    ...            ${pa_interval}=10
    ...            ${range}=10
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${expect_tp_percent}=1
    ...            ${step}=1
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${need_to_trigger_A1_addition}=${False}
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${update_A1_scell_addition_threshold_value}=90
    ...            ${pre_A1_scell_addition_threshold_value}=60
    ...            ${update_scell_topology}=TDD
    ...            ${auto_required_dl_tput_layers}=${False}
    ...            ${extra_expect_secll_tp_percent}=1
    ...            ${extra_expect_pecll_tp_percent}=1
    Log    ${expect_tp_percent}
    Log To Console    \n****** start to generate fallback handover releated info ******\n
    Set Test Variable    ${PCELL_MAPPING}    ${HANDOVER_PCELL_MAPPING}
    Set Test Variable    ${SCELL_MAPPING}    ${HANDOVER_SCELL_MAPPING}
    ${handover_ca_cell_info_dict}    Procedures.CA Basic Handover Test
    ...                              attach_ca_call_info_dict=${pre_handover_ca_call_info_dict}
    ...                              handover_gnb_type=${fallback_handover_gnb_type}
    ...                              frequency_type=${fallback_frequency_type}
    ...                              handover_round=${handover_round}
    ...                              tput_collect_duration=${tput_collect_duration}
    ...                              target_DL_avg_percent=${target_DL_avg_percent}
    ...                              target_UL_avg_percent=${target_UL_avg_percent}
    ...                              pa_interval=${pa_interval}
    ...                              range=${range}
    ...                              min_DL_percent=${min_DL_percent}
    ...                              min_UL_percent=${min_UL_percent}
    ...                              min_scell_percent=${min_scell_percent}
    ...                              step=${step}
    ...                              check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                              need_to_trigger_A1_addition=${need_to_trigger_A1_addition}
    ...                              expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                              update_A1_scell_addition_threshold_value=${update_A1_scell_addition_threshold_value}
    ...                              pre_A1_scell_addition_threshold_value=${pre_A1_scell_addition_threshold_value}
    ...                              update_scell_topology=${update_scell_topology}
    ...                              auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    ...                              extra_expect_pecll_tp_percent=${extra_expect_pecll_tp_percent}
    ...                              extra_expect_secll_tp_percent=${extra_expect_secll_tp_percent}
    [Return]    ${handover_ca_cell_info_dict}

Procedures.CA A2 Release Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_ca_call_info_dict}    ${tput_collect_duration}=90    ${gnb_id}=0
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.8
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85
    ...            ${target_DL_avg_percent_after_a2_release}=0.1    ${target_UL_avg_percent_after_a2_release}=0.1
    ...            ${min_DL_percent_after_a2_release}=0    ${min_UL_percent_after_a2_release}=0    ${min_scell_percent_after_a2_release}=0
    ...            ${A2_release_value}=127    ${check_ul_pcell_tput_type}=peak
    ...            ${auto_required_dl_tput_layers}=${False}
    ${source_gnb_id}    Set Variable    ${attach_ca_call_info_dict['source_gnb_id']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${source_gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=ca_A2_scell_release
    ...                                                                              cprt_collector_name=cprt_ca_A2_scell_release
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${source_gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    Modify PA Value For Required RU With Interval    ru_index=${attach_ca_call_info_dict['pcell_ru_index']}
    ...                                              gnb_id=${source_gnb_id}
    ...                                              interval=35
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['scell_ru_index_list']}
    ...                                         gnb_id=${source_gnb_id}
    ...                                         pa_off_value=${A2_release_value}
    Sleep    30sec
    ${scell_release_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                  cprt_collector_name=cprt_ca_A2_scell_release
    ...                                                                  tcpdump_collector_name=ca_A2_scell_release
    ...                                                                  target_dir=${TS_CASE_LOG_PATH}
    ...                                                                  gnb_index=${source_gnb_id}
    ...                                                                  du_index=0
#    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['pcell_ru_index']}
#    ...                                         gnb_id=${source_gnb_id}
    Run Keyword And Ignore Error           Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_id}
    ...                                    duration=${tput_collect_duration}
    ...                                    check_scell_tput_type=no_data
    ...                                    addition_scell_index_list=${attach_ca_call_info_dict['scell_index_list']}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent_after_a2_release}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent_after_a2_release}
    ...                                    min_DL_percent=${min_DL_percent_after_a2_release}
    ...                                    min_UL_percent=${min_UL_percent_after_a2_release}
    ...                                    min_scell_percent=${min_scell_percent_after_a2_release}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=ca_A2_scell_re_activate
    ...                                                                   cprt_collector_name=cprt_ca_A2_scell_re_activate
    ...                                                                   asik_connection_alias=ASIK Master
    ...                                                                   gnb_index=${attach_ca_call_info_dict['source_gnb_id']}
    ...                                                                   du_index=0
    Sleep    40sec
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['pcell_ru_index']}
    ...                                         gnb_id=${source_gnb_id}
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['scell_ru_index_list']}
    ...                                         gnb_id=${source_gnb_id}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_id}
    ...                                    duration=${tput_collect_duration}
    ...                                    check_scell_tput_type=peak
    ...                                    addition_scell_index_list=${attach_ca_call_info_dict['scell_index_list']}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    ${scell_re_activte_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                     cprt_collector_name=cprt_ca_A2_scell_re_activate
    ...                                                                     tcpdump_collector_name=ca_A2_scell_re_activate
    ...                                                                     target_dir=${TS_CASE_LOG_PATH}
    ...                                                                     gnb_index=${attach_ca_call_info_dict['source_gnb_id']}
    ...                                                                     du_index=0
    [Return]    ${scell_release_wireshark}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.CA RLQ Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_ca_call_info_dict}    ${gnb_id}=0
    ${source_gnb_id}    Set Variable    ${attach_ca_call_info_dict['source_gnb_id']}
    Prepare And Start Aasyslog    gnb_index=${source_gnb_id}    log_name=aasyslog_RLQ_deactivate.txt
    Sleep    30sec
    Modify PA Value By Steps For Required RU     ru_index=${attach_ca_call_info_dict['scell_ru_index_list']}
    ...               gnb_id=${source_gnb_id}    step=2    range=30    sleep_duration=2
    sleep   60sec
    ${aasyslog_log_list}    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog_RLQ_deactivate    gnb_index=${source_gnb_id}
    ${status}    Run Keyword And Return Status    Check RLQ Triggered Success    log_path=${aasyslog_log_list[0]}
    Run Keyword If    '${status}'=='${False}'    Run Keywords    Run Keyword And Continue On Failure
    ...                                          Check Tput For CA Group
    ...                                          ue_type=${ue_type}
    ...                                          gnb_index=${gnb_id}
    ...                                          duration=60
    ...                                          addition_scell_index_list=${attach_ca_call_info_dict['scell_index_list']}    AND
    ...    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['scell_ru_index_list']}    gnb_id=${source_gnb_id}
    ...    AND    Run Keyword And Continue On Failure     Check Tput For CA Group
    ...                                                   ue_type=${ue_type}
    ...                                                   gnb_index=${gnb_id}
    ...                                                   duration=60
    ...                                                   addition_scell_index_list=${attach_ca_call_info_dict['scell_index_list']}
    ...                                                   check_scell_tput_type=no_data
    [Teardown]     Run Keyword And Ignore Error   Stop Aasyslog And Download To TestPC    log_prefix=aasyslog_RLQ_deactivate

Procedures.CA Basic Attach L3 Call Test With MTK
    [Documentation]   Auther:li.su@nokia-sbell.com
    [Arguments]    ${mode}=SA    ${gnb_index}=0    ${coam_connection}=GNB_OAM
    ...            ${tput_collect_duration}=120    ${expect_addition_scell_indexs}=${None}    ${scell_addition_method}=A1
    ...            ${check_pcell_tput_type}=peak   ${check_scell_tput_type}=peak    ${check_ul_pcell_tput_type}=layer1
    ...            ${data_transfer_duration}=2400   ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.8
    ...            ${dl_data_transfer}=3000M       ${ul_data_transfer}=130M   ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85
    ...            ${check_scell_tput_layer}=layer2
    Log To Console    \n****** start to attach with MTK******\n
    ${attach_info}    Start UE Attach With MTK         wireshark_log_prefix=ca_attach
    ...                                                sleep_interval=60 sec
    ...                                                coam_connection=${coam_connection}
    ...                                                gnb_index=${gnb_index}
    ...                                                mode=${mode}
    log to console    ${attach_info}
    Generate Pcell And Scell Mapping Info    pcell_index=${attach_info['attach_cell_index']}    source_gnb_id=${gnb_index}
    ${addition_scell_index_list}    Run Keyword If    '${scell_addition_method}'=='A1'
    ...                                               Message_Flow_Check.A1 Addition Process
    ...                                               addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${mode}
    ...                                               expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...    ELSE    Check Scell Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                            mode=${mode}
    ...                                            expect_addition_scell_indexs=${expect_addition_scell_indexs}
    Log To Console    \n****** start to verify L3 call ******\n
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=${data_transfer_duration}
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=${ue_iperf_path}
    ${check_pcell_tput_type_test}    set Variable if     '${attach_info['attach_cell_index']}'=='1'    layer2    ${check_pcell_tput_type}
    ${check_scell_tput_type_test}    set Variable if     '${addition_scell_index_list[0]}'=='1'        ${check_scell_tput_layer}
    ...                                                                                                ${check_scell_tput_type}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_index}
    ...                                    duration=${tput_collect_duration}
    ...                                    addition_scell_index_list=${addition_scell_index_list}
    ...                                    check_pcell_tput_type=${check_pcell_tput_type_test}
    ...                                    check_scell_tput_type=${check_scell_tput_type_test}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ${attach_ca_cell_info_dict}    Create Dictionary    pcell_index=${attach_info['attach_cell_index']}
    ...                                                 source_gnb_id=${gnb_index}
    ...                                                 attach_cpif_log=${attach_info['cpif_log_path']}
    [Return]    ${attach_ca_cell_info_dict}

Procedures.Vonr Call Setup Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${ue_index}=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=vonr_call_test
    ...                                                                              cprt_collector_name=cprt_vonr_call_test
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${gnb_index}
    ...                                                                              du_index=0
    Sleep    30sec
    Make Vonr Call    ue_index=${ue_index}

Procedures.Vonr Call Release Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${ue_index}=${0}
    Hang Up Vonr Call    ue_index=${ue_index}
    Sleep    30sec
    ${vonr_call_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                              cprt_collector_name=cprt_vonr_call_test
    ...                                                              tcpdump_collector_name=vonr_call_test
    ...                                                              target_dir=${TS_CASE_LOG_PATH}
    ...                                                              gnb_index=${gnb_index}
    ...                                                              du_index=0
    Run Keyword And Ignore Error    Check VoNR Call Success    log_path=${vonr_call_wireshark}

Procedures.CA Cell Shutdown
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_ca_call_info_dict}    ${gnb_id}=0    ${is_pcell_shutdown}=${True}
    Log To Console    \n***start to online modify administrativeState of pcell from Unlocked to Locked***
    ${shutdown_cell_index}    Set Variable If    ${is_pcell_shutdown}    ${attach_ca_call_info_dict['pcell_index']}
    ...                                                                  ${attach_ca_call_info_dict['scell_index_list'][0]}
    ${shutdown_cell_group_index}    Set Variable If    ${is_pcell_shutdown}     ${PCELL_MAPPING['cell_group_id']}
    ...    ${SCELL_MAPPING[${attach_ca_call_info_dict['scell_index_list'][0]}]['all_cell_info']['cell_group_id']}
    ${unlock_cell_index}    Set Variable If    ${is_pcell_shutdown}    ${attach_ca_call_info_dict['scell_index_list'][0]}
    ...                                                                ${attach_ca_call_info_dict['pcell_index']}
    ${unlock_cell_group_index}    Set Variable If    ${is_pcell_shutdown}
    ...    ${SCELL_MAPPING[${attach_ca_call_info_dict['scell_index_list'][0]}]['all_cell_info']['cell_group_id']}
    ...    ${PCELL_MAPPING['cell_group_id']}
    Set Test Variable    ${SHUTDOWN_CELL_INDEX}    ${shutdown_cell_index}
    Set Test Variable    ${SHUTDOWN_CELL_GROUP_INDEX}    ${shutdown_cell_group_index}
    connection_alias_store.Connect to Common Unit Master
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=cell_shutdown
    ...                                                                              cprt_collector_name=cprt_cell_shutdown
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${RUNNING_GNB_ID}
    Common_keywords.Online Cell AdministrativeState Modification    cell_index=${shutdown_cell_index}
    ...                                                             cell_administrativeState=Shutting Down
    Wait Until Keyword Succeeds    5 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${gnb_id}
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Unlocked
    ...    cell_idx=${unlock_cell_index}
    ...    cell_group_idx=${unlock_cell_group_index}
    ...    timeout=10
    ...    connection=GNB_OAM
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${shutdown_cell_index}
    ...                                                                   cell_group_idx=${shutdown_cell_group_index}
    ...                                                                   timeout=10
    ...                                                                   connection=GNB_OAM
    Sleep    10 sec
    ${pcell_shutdown_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=cprt_cell_shutdown
    ...    tcpdump_collector_name=cell_shutdown
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    gnb_index=${RUNNING_GNB_ID}
    [Teardown]    run keywords    Run Keyword And Ignore Error    core.stop_collectors    names=cell_shutdown    AND
    ...    Run Keyword And Ignore Error    core.teardown_collectors    names=cell_shutdown    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master    AND
    ...    Run Keyword And Ignore Error     COAM Teardown gnb connections    connection=GNB_OAM

Procedures.Trigger A2 Release
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${scell_index}
    ...            ${gnb_id}=0
    ...            ${A2_release_value}=127
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=A2_scell_${scell_index}_release
    ...                                                                              cprt_collector_name=cprt_A2_scell_${scell_index}_release
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    Initial PA Value Setting For Required RU    modify_ru_id=${scell_ru_index}
    ...                                         gnb_id=${gnb_id}
    ...                                         pa_off_value=${A2_release_value}
    Sleep    30sec
    ${scell_release_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                  tcpdump_collector_name=A2_scell_${scell_index}_release
    ...                                                                  cprt_collector_name=cprt_A2_scell_${scell_index}_release
    ...                                                                  target_dir=${TS_CASE_LOG_PATH}
    ...                                                                  gnb_index=${gnb_id}
    ...                                                                  du_index=0
    [Return]    ${scell_release_wireshark}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.Update A1 Scell Addition Threshold
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${gnb_id}=0
    ...            ${update_A1_scell_addition_threshold_value}=60
    ...            ${topology}=TDD
    Log To Console    \n***start to update A1 threshold scell addition***
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    ${update_A1_threshold_scell_add}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}', 'parameter':'a1MeasSCellAddSsbRsrp',
    ...    'value':[{'a1ThresholdSCellAddSsbRsrp${topology}':'${update_A1_scell_addition_threshold_value}'}]}
    ${update_A1_threshold_scell_add}     evaluate    [${update_A1_threshold_scell_add}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_A1_threshold_scell_add}    gnb_index=${gnb_id}

Procedures.Update CB008311 Related Parameter
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0
    Log To Console    \n***start to update CB008311 Related Parameter***
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    ${param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}    parameter=actBufferBasedSCellAddition    value=oneShot_Dl_Fr1
    ${param1}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}    parameter=actSCellReleaseForInactiveSCell    value=timer_based_Fr1
    ${param2}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}    parameter=actSCellReleaseBadSCellRlq    value=enabled_Fr1
    @{param_list}    Create List    ${param}    ${param1}    ${param2}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${param_list}    gnb_index=${gnb_id}

Procedures.Scell Change Test
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${attach_cpif_log}
    ...            ${pre_scell_addition_pa_value}
    ...            ${changed_scell_addition_pa_value}
    ...            ${pre_scell_addition_index_list}
    ...            ${changed_scell_addition_index_list}
    ...            ${gnb_id}=0
    ...            ${mode}=SA
    ...            ${is_capture_bip_during_traffic}=${False}
    ...            ${capture_bbmod_slot}=${EMPTY}
    ...            ${nr_phy_cell_ids}=333,411
    Log    ${capture_bbmod_slot}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${gnb_id}
    run keyword and ignore error    Start Container Capture Wireshark Log     tcpdump_collector_name=scell_change
    ...                                                                       cprt_collector_name=cprt_scell_change
    ...                                                                       asik_connection_alias=ASIK Master
    ...                                                                       gnb_index=${gnb_id}
    ...                                                                       du_index=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=before_scell_change
    ...                                                                              cprt_collector_name=cprt_before_scell_change
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    Initial PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}
    ...                                         gnb_id=${gnb_id}
    ...                                         pa_off_value=${pre_scell_addition_pa_value}
    Sleep    30sec
    ${before_scell_change_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        cprt_collector_name=cprt_before_scell_change
    ...                                                                        tcpdump_collector_name=before_scell_change
    ...                                                                        target_dir=${TS_CASE_LOG_PATH}
    ...                                                                        gnb_index=${gnb_id}
    ...                                                                        du_index=0
    ${A1_meas_info_dict}    Run Keyword And Continue On Failure    Check Measurement Report Triggered Success
    ...                                                            rrc_cpif_log=${attach_cpif_log}
    ...                                                            mr_cpif_log=${before_scell_change_wireshark}
    ...                                                            event_type=A1
    ...                                                            rrc_message_filter=${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    ${addition_scell_index_list}    Check Scell Addition Success    cpif_log_path=${before_scell_change_wireshark}
    ...                                                             mode=SA
    ...                                                             expect_addition_scell_indexs=${pre_scell_addition_index_list}
    ...                                                             scell_mapping=${SCELL_MAPPING}
    Run Keyword And Continue On Failure    Procedures.Check Tput    gnb_index=${gnb_id}    check_pcell_tput=${False}
    ...    addition_scell_index_list=${pre_scell_addition_index_list}    check_scell_tput_type=not_peak
    ...    tput_collect_duration=120    min_DL_percent=0    min_UL_percent=0    min_scell_percent=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=after_scell_change
    ...                                                                              cprt_collector_name=cprt_after_scell_change
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    ${scell_ru_index_list}    Create List
    ${scell_index_list}    Get Dictionary Keys    ${scell_mapping}
    FOR  ${scell_index}  IN  @{scell_index_list}
        ${scell_ru_index}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Initial PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}
    ...                                         gnb_id=${gnb_id}
    Sleep    30sec
    Initial PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}
    ...                                         gnb_id=${gnb_id}
    ...                                         pa_off_value=${changed_scell_addition_pa_value}
    Sleep    30sec
    ${after_scell_change_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                       cprt_collector_name=cprt_after_scell_change
    ...                                                                       tcpdump_collector_name=after_scell_change
    ...                                                                       target_dir=${TS_CASE_LOG_PATH}
    ...                                                                       gnb_index=${gnb_id}
    ...                                                                       du_index=0
    ${status}    ${scell_change_wireshark}    run keyword and ignore error    Stop Container Wireshark Log Collection
    ...                                                                       cprt_collector_name=cprt_after_scell_change
    ...                                                                       tcpdump_collector_name=scell_change
    ...                                                                       target_dir=${TS_CASE_LOG_PATH}
    ...                                                                       gnb_index=${gnb_id}
    ...                                                                       du_index=0
    ${A1_meas_info_dict}    Run Keyword And Continue On Failure    Check Measurement Report Triggered Success
    ...                                                            rrc_cpif_log=${before_scell_change_wireshark}
    ...                                                            mr_cpif_log=${after_scell_change_wireshark}
    ...                                                            event_type=A1_after_scell_change
    ...                                                            rrc_message_filter=${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ${addition_scell_index_list}    Check Scell Addition Success    cpif_log_path=${after_scell_change_wireshark}
    ...                                                             mode=SA
    ...                                                             expect_addition_scell_indexs=${changed_scell_addition_index_list}
    ...                                                             scell_mapping=${SCELL_MAPPING}
    Run Keyword And Continue On Failure    Procedures.Check Tput    gnb_index=${gnb_id}    check_pcell_tput=${False}
    ...    addition_scell_index_list=${changed_scell_addition_index_list}    check_scell_tput_type=scell_change_tput
    ...    tput_collect_duration=120    min_DL_percent=0    min_UL_percent=0    min_scell_percent=0
#    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
#    ...    Capture Logs With gNB_logs    bbmod_slots=${capture_bbmod_slot}    duration=6    log_type=BIP    gnb_index=${gnb_id}
#    ${bip_log_path}    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
#    ...    Get Captured BIP File    gnb_index=${gnb_id}
    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
    ...    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${nr_phy_cell_ids}
    Run Keyword If    ${is_capture_bip_during_traffic}    Sleep    6sec
    ${bip_log_path}    Run Keyword If    ${is_capture_bip_during_traffic}    Run Keyword And Continue On Failure
    ...    Get Bip Log Via Interface Mirroring Collector
    ${scell_change_wireshark}    Create Dictionary    before_scell_change=${before_scell_change_wireshark}
    ...                                               after_scell_change=${after_scell_change_wireshark}
    ...                                               bip_log_path=${bip_log_path}
    [Return]    ${scell_change_wireshark}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.CA A6 Scell Swap Test
    [Documentation]   Auther:li.su@nokia-sbell.com
    ...               Modify the expected scell swap source and target PA, trigger the scell swap; the swap scell number is only one;
    ...               And check the CA TP after scell swap.
    [Arguments]    ${attach_ca_call_info_dict}    ${A6_swap_value}    ${tput_collect_duration}=90    ${gnb_index}=0    ${mode}=SA
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.8
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${auto_required_dl_tput_layers}=${False}
    ${source_gnb_id}    Set Variable    ${attach_ca_call_info_dict['source_gnb_id']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${source_gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=ca_scell_swap
    ...                                                                              cprt_collector_name=cprt_ca_scell_swap
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${source_gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    Modify PA Value For Required RU With Interval    ru_index=${attach_ca_call_info_dict['scell_ru_index_list']}
    ...                                              gnb_id=${source_gnb_id}
    ...                                              interval=${A6_swap_value}
    Sleep   5sec
    ${swap_scell_ru_index}    Set Variable    ${scell_mapping[${EXP_TARGET_SWAP_SCELL_INDEX}]['all_cell_info']['ru_index_mapping']}
    Initial PA Value Setting For Required RU    modify_ru_id=${swap_scell_ru_index}
    ...                                         gnb_id=${source_gnb_id}
    Sleep   10sec
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_call_info_dict['scell_ru_index_list']}
    ...                                         gnb_id=${source_gnb_id}
    ...                                         pa_off_value=${127}
    Sleep    30sec
    ${ca_scell_swap_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                  cprt_collector_name=cprt_ca_scell_swap
    ...                                                                  tcpdump_collector_name=ca_scell_swap
    ...                                                                  target_dir=${TS_CASE_LOG_PATH}
    ...                                                                  gnb_index=${source_gnb_id}
    ...                                                                  du_index=0
    ${EXP_SOURCE_SWAP_SCELL_INDEX}    Convert To Integer    ${EXP_SOURCE_SWAP_SCELL_INDEX}
    ${EXP_TARGET_SWAP_SCELL_INDEX}    Convert To Integer    ${EXP_TARGET_SWAP_SCELL_INDEX}
    Remove Values From List    ${attach_ca_call_info_dict['scell_index_list']}    ${EXP_SOURCE_SWAP_SCELL_INDEX}
    Append To List    ${attach_ca_call_info_dict['scell_index_list']}    ${EXP_TARGET_SWAP_SCELL_INDEX}
    Set Test Variable    ${after_swap_scell_index_list}    ${attach_ca_call_info_dict['scell_index_list']}
    ${swap_scell_dl_layers_dict}    Get Swap Scell DL Tput Layers From Wireshark    cpif_log_path=${ca_scell_swap_wireshark}
    ...                                                                             mode=${mode}
    ...                                                                             alias=parser
    FOR   ${key}   IN    @{dl_swap_scell_tput_layers.keys()}
        Set To Dictionary     ${dl_scell_layer}    ${key}    ${dl_swap_scell_tput_layers}[${key}]
    END
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_index}
    ...                                    duration=${tput_collect_duration}
    ...                                    addition_scell_index_list=${after_swap_scell_index_list}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    [Return]    ${ca_scell_swap_wireshark}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.Trigger A6 Scell Swap
    [Documentation]   Auther:li.su@nokia-sbell.com
    ...               Modify the expected scell swap source and target PA,trigger the Specific scell swap;the swap scell number can be more than one
    [Arguments]    ${attach_ca_call_info_dict}
    ...            ${triggered_source_swap_scell_index}=${EXP_SOURCE_SWAP_SCELL_INDEX}
    ...            ${triggered_target_swap_scell_index}=${EXP_TARGET_SWAP_SCELL_INDEX}
    ...            ${swap_scell_index_number}=0
    ...            ${gnb_id}=0
    ...            ${A6_swap_value}=30
    ...            ${After_A6_swap_value}=127
    ${triggered_source_swap_scell_index}    Evaluate    [int(x) for x in ${triggered_source_swap_scell_index}]
    ${triggered_target_swap_scell_index}    Evaluate    [int(x) for x in ${triggered_target_swap_scell_index}]
    ${source_scell_index}    Set Variable    ${triggered_source_swap_scell_index[${swap_scell_index_number}]}
    ${source_scell_ru_index}    Set Variable    ${scell_mapping[${source_scell_index}]['all_cell_info']['ru_index_mapping']}
    ${target_scell_index}    Set Variable    ${triggered_target_swap_scell_index[${swap_scell_index_number}]}
    ${target_scell_ru_index}    Set Variable    ${scell_mapping[${target_scell_index}]['all_cell_info']['ru_index_mapping']}
#    @{all_attach_scell_index_list}    Set Variable       ${attach_ca_call_info_dict['scell_index_list']}
    ${all_attach_scell_ru_index}    Remove Duplicates    ${attach_ca_call_info_dict['scell_ru_index_list']}
    ${all_attach_scell_ru_index_length}    Get Length    ${all_attach_scell_ru_index}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=ca_scell_swap
    ...                                                                              cprt_collector_name=cprt_ca_scell_swap
    ...                                                                              asik_connection_alias=ASIK Master
    ...                                                                              gnb_index=${gnb_id}
    ...                                                                              du_index=0
    Sleep    40sec
    Modify PA Value For Required RU With Interval    ru_index=${source_scell_ru_index}
    ...                                              gnb_id=${gnb_id}
    ...                                              interval=${A6_swap_value}
    Sleep    10sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}
    ...                                         gnb_id=${gnb_id}
    Sleep    10sec
    Initial PA Value Setting For Required RU    modify_ru_id=${source_scell_ru_index}
    ...                                         gnb_id=${gnb_id}
    ...                                         pa_off_value=${After_A6_swap_value}
    Sleep    30sec
    ${ca_scell_swap_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                  cprt_collector_name=cprt_ca_scell_swap
    ...                                                                  tcpdump_collector_name=ca_scell_swap
    ...                                                                  target_dir=${TS_CASE_LOG_PATH}
    ...                                                                  gnb_index=${gnb_id}
    ...                                                                  du_index=0
    Run Keyword If    ${all_attach_scell_ru_index_length}==${1}
    ...               Set Test Variable    ${after_swap_scell_index_list}    ${triggered_target_swap_scell_index}
    ...    ELSE    Run Keywords    Remove Values From List    ${attach_ca_call_info_dict['scell_index_list']}    ${source_scell_index}
    ...     AND    Append To List             ${attach_ca_call_info_dict['scell_index_list']}    ${target_scell_index}
    ...     AND    Set Test Variable          ${after_swap_scell_index_list}    ${attach_ca_call_info_dict['scell_index_list']}
    [Return]    ${ca_scell_swap_wireshark}    ${after_swap_scell_index_list}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Procedures.CA A6 Specific Scell Swap Test
    [Documentation]   Auther:li.su@nokia-sbell.com
    ...               Modify the expected scell swap source and target PA, trigger Specific scell swap; the swap scell number can be more than one;
    ...               And check the CA TP after scell swap.
    [Arguments]    ${attach_ca_call_info_dict}    ${A6_swap_value}=30    ${swap_scell_index_number}=0    ${tput_collect_duration}=90
    ...            ${gnb_index}=0    ${mode}=SA    ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.8
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type}=peak
    ...            ${auto_required_dl_tput_layers}=${False}
    ${ca_scell_swap_wireshark}    ${after_swap_scell_index_list}     Procedures.Trigger A6 Scell Swap
    ...                                                              attach_ca_call_info_dict=${attach_ca_call_info_dict}
    ...                                                              swap_scell_index_number=${swap_scell_index_number}
    ...                                                              gnb_id=${gnb_index}
    ...                                                              A6_swap_value=${A6_swap_value}
    ${dl_swap_scell_tput_layers}    Get Swap Scell DL Tput Layers From Wireshark    cpif_log_path=${ca_scell_swap_wireshark}
    ...                                                                             mode=${mode}
    ...                                                                             alias=parser
    FOR   ${key}   IN    @{dl_swap_scell_tput_layers.keys()}
        Set To Dictionary     ${dl_scell_layer}    ${key}    ${dl_swap_scell_tput_layers}[${key}]
    END
    ${tput_dict}    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    gnb_index=${gnb_index}
    ...                                    duration=${tput_collect_duration}
    ...                                    addition_scell_index_list=${after_swap_scell_index_list}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    ...                                    min_scell_percent=${min_scell_percent}
    ...                                    check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                    auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    [Return]    ${ca_scell_swap_wireshark}     ${after_swap_scell_index_list}    ${tput_dict}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master     AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

#--- Common Checkpoint KW ---#
Message_Flow_Check.A2 Release Process
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${release_cpif_log_path}    ${addition_cpif_log_path}    ${mode}=SA    ${addition_method}=A1    ${scell_index}=1
    ${rrc_message_filter}    Set Variable If    '${mode}'=='SA'    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                            ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${A2_meas_info_dict}    Check Measurement Report Triggered Success    rrc_cpif_log=${addition_cpif_log_path}
    ...                                                                   mr_cpif_log=${release_cpif_log_path}
    ...                                                                   event_type=A2_Release
    ...                                                                   rrc_message_filter=${rrc_message_filter}
    ...                                                                   scell_index=${scell_index}
    Check Event Removed Success    cpif_log_path=${release_cpif_log_path}    remove_meas_info_dict=${A2_meas_info_dict}
    Check Specific Scell Release Success    scell_index=${scell_index}
    ...                                     release_cpif_log_path=${release_cpif_log_path}
    ...                                     addition_cpif_log_path=${addition_cpif_log_path}
    ...                                     mode=${mode}
    ...                                     addition_method=${addition_method}
Message_Flow_Check.A1 Addition Process
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${addition_cpif_log_path}    ${mode}=SA    ${expect_addition_scell_indexs}=${None}
    ...            ${pcell_mapping}=${PCELL_MAPPING}    ${scell_mapping}=${SCELL_MAPPING}
    ${A1_meas_info_dict}    Check Measurement Report Triggered Success    rrc_cpif_log=${addition_cpif_log_path}
    ...                                                                   mr_cpif_log=${addition_cpif_log_path}
    ...                                                                   event_type=A1
    ...                                                                   rrc_message_filter=${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    ...                                                                   pcell_mapping=${pcell_mapping}
    Check Event Removed Success    cpif_log_path=${addition_cpif_log_path}    remove_meas_info_dict=${A1_meas_info_dict}
    ${addition_scell_index_list}    Check Scell Addition Success    cpif_log_path=${addition_cpif_log_path}
    ...                                                             mode=${mode}
    ...                                                             expect_addition_scell_indexs=${expect_addition_scell_indexs}
    ...                                                             scell_mapping=${scell_mapping}
    [Return]    ${addition_scell_index_list}

Message_Flow_Check.A1 Addition Process For 8311
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${addition_cpif_log_path}    ${mode}=SA    ${pcell_mapping}=${PCELL_MAPPING}
    Check Measurement Report Triggered Success    rrc_cpif_log=${addition_cpif_log_path}
    ...                                           mr_cpif_log=${addition_cpif_log_path}
    ...                                           event_type=A1
    ...                                           rrc_message_filter=${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    ...                                           pcell_mapping=${pcell_mapping}

Message_Flow_Check.Inter Frequency Handover Process
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${source_ho_cpif_log_path}
    ...            ${target_ho_cpif_log_path}
    ...            ${addition_cpif_log_path}
    ...            ${mode}=SA
    ...            ${A2_rrc_message_filter}=${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    ...            ${A1_Addition_MR_triggered}=${True}
    ...            ${rrc_reconfigure_message_filter_expression}=${${mode}_RRC_RECONFIGURE_FILTER_HANDOVER}
    ...            ${A1_addition_message_filter_expression}=${${mode}_RRC_RECONFIGURE_FILTER_HANDOVER}
    ${A2_meas_info_dict}    Run Keyword And Continue On Failure    Check Measurement Report Triggered Success
    ...                                                            rrc_cpif_log=${addition_cpif_log_path}
    ...                                                            mr_cpif_log=${source_ho_cpif_log_path}
    ...                                                            event_type=A2_HO
    ...                                                            rrc_message_filter=${A2_rrc_message_filter}
    ${ssbFrequency}    Set Variable    ${HANDOVER_PCELL_MAPPING['ssbfrequency']}
    ${ssbFrequency}    Convert To String    ${ssbFrequency}
    ${message_filter_expression}    Set Variable If    '${mode}'=='SA'
    ...                                                 f1ap.procedureCode == 12 && nr-rrc.ssbFrequency == ${ssbFrequency} && nr-rrc.gapFR1 == 1
    ...                                                 x2ap.procedureCode == 29 && nr-rrc.ssbFrequency == ${ssbFrequency}
    ${status}    ${A3_meas_info_dict}    Run Keyword And Ignore Error     Check Measurement Report Triggered Success
    ...                                                                   rrc_cpif_log=${source_ho_cpif_log_path}
    ...                                                                   mr_cpif_log=${source_ho_cpif_log_path}
    ...                                                                   event_type=A3
    ...                                                                   rrc_message_filter=${message_filter_expression}
    ${A5_meas_info_dict}    Run Keyword If  '${status}'=='FAIL'    Run Keyword And Continue On Failure
    ...                                                            Check Measurement Report Triggered Success
    ...                                                            rrc_cpif_log=${source_ho_cpif_log_path}
    ...                                                            mr_cpif_log=${source_ho_cpif_log_path}
    ...                                                            event_type=A5
    ...                                                            rrc_message_filter=${message_filter_expression}
    ${check_rrc_reconfigure_complete_path}    Set Variable If    '${mode}'=='SA'    ${source_ho_cpif_log_path}    ${target_ho_cpif_log_path}
    Run Keyword And Continue On Failure    Check RRC Reconfigure And RRC Reconfigure Complete For Handover
    ...                                    source_ho_cpif_log_path=${check_rrc_reconfigure_complete_path}
    ...                                    target_ho_cpif_log_path=${target_ho_cpif_log_path}
    ...                                    mode=${mode}
    ...                                    message_filter_expression=${rrc_reconfigure_message_filter_expression}
    Run Keyword And Continue On Failure    Check RRC Reestablishment Request Message     cpif_log_path=${source_ho_cpif_log_path}
    Check RRC Reestablishment Request Message     cpif_log_path=${target_ho_cpif_log_path}
    ${status}    run keyword and return status    Check Measurement Report Triggered Success
    ...                                           rrc_cpif_log=${target_ho_cpif_log_path}
    ...                                           mr_cpif_log=${target_ho_cpif_log_path}
    ...                                           event_type=A1
    ...                                           rrc_message_filter=${A1_addition_message_filter_expression}
    ...                                           is_handover=${True}
    run keyword if    ${A1_Addition_MR_triggered}    should be equal    ${status}    ${True}    msg=A1 MR should be triggered after handover.
    ...     ELSE    should be equal    ${status}    ${False}    msg=A1 MR should not be triggered after handover.

Message_Flow_Check.Intra Frequency Handover Process
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${source_ho_cpif_log_path}
    ...            ${target_ho_cpif_log_path}
    ...            ${mode}=SA
    ...            ${source_pci}=${PCELL_MAPPING['physicalCellId']}
    ...            ${target_pci}=${HANDOVER_PCELL_MAPPING['physicalCellId']}
    ...            ${rrc_reconfigure_message_filter_expression}=${${mode}_INTER_HO_RRC_RECONFIGURE_FILTER}
    ...            ${whether_check_contain}=${False}
#    ${status}    ${A3_meas_info_dict}    Run Keyword And Ignore Error    Check Measurement Report Triggered Success
#    ...                                                                  rrc_cpif_log=${addition_cpif_log_path}
#    ...                                                                  mr_cpif_log=${source_ho_cpif_log_path}
#    ...                                                                  event_type=A3
#    ...                                                                  rrc_message_filter=${rrc_message_filter}
#    ${A5_meas_info_dict}    Run Keyword If  '${status}'=='FAIL'    Run Keyword And Continue On Failure
#    ...                                                            Check Measurement Report Triggered Success
#    ...                                                            rrc_cpif_log=${addition_cpif_log_path}
#    ...                                                            mr_cpif_log=${source_ho_cpif_log_path}
#    ...                                                            event_type=A5
#    ...                                                            rrc_message_filter=${rrc_message_filter}
    ${A3_A5_message_filter_expression}    Set Variable If    '${mode}'=='SA'   f1ap.procedureCode == 13      x2ap.procedureCode == 35
    Run Keyword And Continue On Failure    Check A3 A5 Measurement Report    cpif_log_path=${source_ho_cpif_log_path}
    ...                                                                      source_pci=${source_pci}
    ...                                                                      target_pci=${target_pci}
    ...                                                                      message_filter_expression=${A3_A5_message_filter_expression}
    ...                                                                      whether_check_contain=${whether_check_contain}
    ${check_rrc_reconfigure_complete_path}    Set Variable If    '${mode}'=='SA'    ${source_ho_cpif_log_path}    ${target_ho_cpif_log_path}
    Run Keyword And Continue On Failure    Check RRC Reconfigure And RRC Reconfigure Complete For Handover
    ...                                    source_ho_cpif_log_path=${check_rrc_reconfigure_complete_path}
    ...                                    target_ho_cpif_log_path=${target_ho_cpif_log_path}
    ...                                    mode=${mode}
    ...                                    message_filter_expression=${rrc_reconfigure_message_filter_expression}
    Run Keyword And Continue On Failure    Check RRC Reestablishment Request Message     cpif_log_path=${source_ho_cpif_log_path}
    Check RRC Reestablishment Request Message     cpif_log_path=${target_ho_cpif_log_path}

Message_Flow_Check.CA A6 Scell Swap Process
    [Documentation]   Auther:li.su@nokia-sbell.com
    [Arguments]    ${swap_cpif_log_path}    ${addition_cpif_log_path}    ${mode}=SA    ${addition_method}=A1    ${source_scell_index}=1
    ...            ${target_scell_index}=2    ${A6_MR_config_need_update}=${False}
    ${rrc_message_filter}    Set Variable If    '${mode}'=='SA'    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                            ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${A6_meas_info_dict}    Run Keyword And Continue On Failure           Check Measurement Report Triggered Success
    ...                                                                   rrc_cpif_log=${addition_cpif_log_path}
    ...                                                                   mr_cpif_log=${swap_cpif_log_path}
    ...                                                                   event_type=A6
    ...                                                                   rrc_message_filter=${rrc_message_filter}
    ...                                                                   scell_index=${source_scell_index}
    Run Keyword And Continue On Failure    Check CA Scell Swap Success    addition_cpif_log_path=${addition_cpif_log_path}
    ...                                                                   swap_cpif_log_path=${swap_cpif_log_path}
    ...                                                                   rrc_message_filter=${rrc_message_filter}
    ...                                                                   source_scell_index=${source_scell_index}
    ...                                                                   target_scell_index=${target_scell_index}
    ${A6_MR_update_status}    Run Keyword And Return Status    Check Event Removed Success    cpif_log_path=${swap_cpif_log_path}
    ...                                                                                       remove_meas_info_dict=${A6_meas_info_dict}
    Run Keyword IF     ${A6_MR_config_need_update}    Should Be Equal    ${A6_MR_update_status}    ${True}
    ...     msg=A6 MR should be reconfigured after swap.
    ...     ELSE    Should Be Equal    ${A6_MR_update_status}    ${False}    msg=A6 MR should not be reconfigured after swap.


Message_Flow_Check.CA A6 Two Scells Swap Process
    [Documentation]   Auther:li.su@nokia-sbell.com
    [Arguments]    ${swap_cpif_log_path}    ${addition_cpif_log_path}    ${mode}=SA    ${addition_method}=A1    ${source_scell_index}=1
    ...            ${target_scell_index}=2
    ${rrc_message_filter}    Set Variable If    '${mode}'=='SA'    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                            ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${A6_meas_info_dict1}    Run Keyword And Continue On Failure          Check Measurement Report Triggered Success
    ...                                                                   rrc_cpif_log=${addition_cpif_log_path}
    ...                                                                   mr_cpif_log=${swap_cpif_log_path}
    ...                                                                   event_type=A6
    ...                                                                   rrc_message_filter=${rrc_message_filter}
    ...                                                                   scell_index=${source_scell_index[0]}
    ${A6_meas_info_dict2}    Run Keyword And Continue On Failure          Check Measurement Report Triggered Success
    ...                                                                   rrc_cpif_log=${addition_cpif_log_path}
    ...                                                                   mr_cpif_log=${swap_cpif_log_path}
    ...                                                                   event_type=A6
    ...                                                                   rrc_message_filter=${rrc_message_filter}
    ...                                                                   scell_index=${source_scell_index[1]}
    Run Keyword And Continue On Failure    Check CA Two Scells Swap Success    addition_cpif_log_path=${addition_cpif_log_path}
    ...                                                                        swap_cpif_log_path=${swap_cpif_log_path}
    ...                                                                        rrc_message_filter=${rrc_message_filter}
    ...                                                                        source_scell_index=${source_scell_index}
    ...                                                                        target_scell_index=${target_scell_index}
#    ${A6_MR_update_status}    Run Keyword And Return Status    Check Event Removed Success    cpif_log_path=${swap_cpif_log_path}
#    ...                                                                                       remove_meas_info_dict=${A6_meas_info_dict}
#    Run Keyword IF     ${A6_MR_config_need_update}    Should Be Equal    ${A6_MR_update_status}    ${True}
#    ...     msg=A6 MR should be reconfigured after swap.
#    ...     ELSE    Should Be Equal    ${A6_MR_update_status}    ${False}    msg=A6 MR should not be reconfigured after swap.


#--- Step KW ---#
Connect To Multi gNb Coam
    Connect to gnb coam via ssl    connection=GNB_OAM0
    ${gnb_number}    Get Length    ${tl.gnbs}
    Run Keyword If    ${gnb_number}>${1}    Connect to gnb coam via ssl    connection=GNB_OAM1    gnb_index=1

Teardown Multi gNb Connections
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM1

Generate Pcell And Scell Mapping Info
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Generate Pcell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${source_gnb_id}
    Connect To Multi gNb Coam
    ${scell_mapping}    mbca.get_scell_mapping_for_pcell
    ${tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${scell_mapping}
    ${fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${scell_mapping}
    Set Test Variable    ${SCELL_MAPPING}    ${scell_mapping}
    Set Test Variable    ${TDD_SCELL_MAPPING}    ${tdd_scell_mapping}
    Set Test Variable    ${FDD_SCELL_MAPPING}    ${fdd_scell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Generate Pcell Mapping Info
    [Documentation]   Auther:lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${pcell_mapping}    mbca.get_pcell_mapping
    Set Test Variable    ${PCELL_MAPPING}     ${pcell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Generate Cell Mapping Info
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    Connect To Multi gNb Coam
    ${cell_mapping}    gnbaction.get_cell_mapping
    [Return]    ${cell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Generate Handover Pcell And Scell Mapping Info
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0    ${handover_gnb_type}=Intra    ${frequency_type}=Intra
    Connect To Multi gNb Coam
    ${pcell_index}    Convert To Integer    ${pcell_index}
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${all_neighbor_cell_config_info}    mbca.get_all_neighbor_cell_config_info
    ${configuration_mapping_result}    mbca.get_required_handover_cell_mapping    handover_gnb_type=${handover_gnb_type}
    ...                                                                           frequency_type=${frequency_type}
    ${handover_cell_info}    Set Variable    ${configuration_mapping_result['${pcell_index}']}
    ${random_select_one_mapping}    Evaluate    random.choice(${handover_cell_info})    modules=random
    Log To Console    ${random_select_one_mapping}
    ${handover_pcell_index}    Set Variable    ${random_select_one_mapping['neighbor_cell_id']}
    ${target_gnb_id}     Set Variable If    '${handover_gnb_type}'=='Intra' and '${source_gnb_id}'=='0'    0
    ...                                     '${handover_gnb_type}'=='Intra' and '${source_gnb_id}'=='1'    1
    ...                                     '${handover_gnb_type}'=='Inter' and '${source_gnb_id}'=='0'    1
    ...                                     '${handover_gnb_type}'=='Inter' and '${source_gnb_id}'=='1'    0
    mbca.set_pcell_index    value=${handover_pcell_index}
    mbca.set_gnb_id    value=${target_gnb_id}
    mbca.set_gnb_operation_object
    ${all_neighbor_cell_config_info_ho}    mbca.get_all_neighbor_cell_config_info
    ${handover_pcell_mapping}    mbca.get_pcell_mapping
    ${handover_scell_mapping}    mbca.get_scell_mapping_for_pcell
    Set Test Variable    ${HANDOVER_PCELL_INDEX}    ${handover_pcell_index}
    Set Test Variable    ${HANDOVER_PCELL_MAPPING}    ${handover_pcell_mapping}
    Set Test Variable    ${HANDOVER_SCELL_MAPPING}    ${handover_scell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Check Tput For CA Group
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               If ${whether_collect_tput}=${False}, the parameter ${tput_file_use_collested} must not be ${None}
    ...               Need to collect tput first, then set the vlaue of ${tput_file_use_collested} is the existed file.
    [Arguments]     ${ue_type}
    ...             ${duration}=180
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${ignore_time}=30sec
    ...             ${target_DL_avg_percent}=0.9
    ...             ${target_UL_avg_percent}=0.8
    ...             ${min_DL_percent}=0.85
    ...             ${min_UL_percent}=0.85
    ...             ${min_scell_percent}=0.85
    ...             ${check_pcell_tput_type}=peak
    ...             ${check_scell_tput_type}=peak
    ...             ${check_ul_pcell_tput_type}=peak
    ...             ${pcell_mapping}=${PCELL_MAPPING}
    ...             ${scell_mapping}=${SCELL_MAPPING}
    ...             ${addition_scell_index_list}=${None}
    ...             ${check_pcell_tput}=${True}
    ...             ${check_scell_tput}=${True}
    ...             ${expect_tp_percent}=1
    ...             ${whether_collect_tput}=${True}
    ...             ${tput_file_use_collected}=${None}
    ...             ${check_source}=aasyslog
    ...             ${inactivate_scell_index_list}=@{EMPTY}
    ...             ${auto_required_dl_tput_layers}=${False}
    ...             ${extra_expect_secll_tp_percent}=1
    ...             ${extra_expect_pecll_tp_percent}=1
    ...             ${whether_check_scell_ul_tupt}=${False}
    ...             ${special_scell_index_for_UL}=None
    ...             ${check_scell_ul_tput_type}=layer1
    ${tput_file}    Run Keyword If    ${whether_collect_tput}    power_ue.Collect Tput    ue_type=${ue_type}
    ...                                                                                   gnb_index=${gnb_index}
    ...                                                                                   du_index=${du_index}
    ...                                                                                   duration=${duration}
    ...                                                                                   ignore_time=${ignore_time}
    ...                                                                                   check_source=${check_source}
    ...             ELSE    Set Variable    ${tput_file_use_collected}
    ${pcell_tput_dict}    Run Keyword If    ${check_pcell_tput}    Check Tput For Pcell    ue_type=${ue_type}
    ...                                                              tput_file=${tput_file}
    ...                                                              target_DL_avg_percent=${target_DL_avg_percent}
    ...                                                              target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                              check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                              check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                              pcell_mapping=${pcell_mapping}
    ...                                                              min_DL_percent=${min_DL_percent}
    ...                                                              min_UL_percent=${min_UL_percent}
    ...                                                              expect_tp_percent=${expect_tp_percent}
    ...                                                              check_source=${check_source}
    ...                                                              auto_required_dl_tput_layers=${False}
    ...                                                              extra_expect_pecll_tp_percent=${extra_expect_pecll_tp_percent}
    ${scell_tput_dict}    Run Keyword If    ${check_scell_tput}    Check Tput For Scell    ue_type=${ue_type}
    ...                                                              tput_file=${tput_file}
    ...                                                              target_DL_avg_percent=${target_DL_avg_percent}
    ...                                                              min_scell_percent=${min_scell_percent}
    ...                                                              check_scell_tput_type=${check_scell_tput_type}
    ...                                                              addition_scell_index_list=${addition_scell_index_list}
    ...                                                              scell_mapping=${scell_mapping}
    ...                                                              expect_tp_percent=${expect_tp_percent}
    ...                                                              check_source=${check_source}
    ...                                                              inactivate_scell_index_list=${inactivate_scell_index_list}
    ...                                                              auto_required_dl_tput_layers=${auto_required_dl_tput_layers}
    ...                                                              extra_expect_secll_tp_percent=${extra_expect_secll_tp_percent}
    ...                                                              whether_check_scell_ul_tupt=${whether_check_scell_ul_tupt}
    ...                                                              special_scell_index_for_UL=${special_scell_index_for_UL}
    ...                                                              check_scell_ul_tput_type=${check_scell_ul_tput_type}
    ${tput_dict}    Create Dictionary    pcell=${pcell_tput_dict}    scell=${scell_tput_dict}
    [Return]    ${tput_dict}

Check Tput For Pcell
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ue_type}
    ...             ${tput_file}
    ...             ${target_DL_avg_percent}=0.9
    ...             ${target_UL_avg_percent}=0.8
    ...             ${min_DL_percent}=0.85
    ...             ${min_UL_percent}=0.85
    ...             ${check_pcell_tput_type}=peak
    ...             ${check_ul_pcell_tput_type}=peak
    ...             ${pcell_mapping}=${PCELL_MAPPING}
    ...             ${check_source}=aasyslog
    ...             ${expect_tp_percent}=1
    ...             ${auto_required_dl_tput_layers}=${False}
    ...             ${extra_expect_pecll_tp_percent}=1
    Log Many    ${target_DL_avg_percent}    ${target_UL_avg_percent}    ${min_DL_percent}    ${min_UL_percent}
    Log To Console    \n***start to check tput for pcell***\n
    ${pcell_nr_identity}    Set Variable    ${pcell_mapping['nrCellIdentity']}
    ${pcell_nr_identity}    Convert To String    ${pcell_nr_identity}
    ${pcell_nr_identity}    Create List    ${pcell_nr_identity}
    ${pcell_technology}    Set Variable    ${pcell_mapping['detail_cells_info']['technology']}
    ${pcell_tput_dict}    Create Dictionary
    ${auto_required_dl_tput_layers}    Set Variable If    '${pcell_technology}'=='FDD'    ${False}    ${auto_required_dl_tput_layers}
    FOR  ${direction}  IN   UL  DL
     ${chbw_param_name}    Set Variable If    '${pcell_technology}'=='TDD'    chBw
     ...                                      '${pcell_technology}'=='FDD' and '${direction}'=='UL'    chBwUl
     ...                                      '${pcell_technology}'=='FDD' and '${direction}'=='DL'    chBwDl
     ${pcell_chbw}    Set Variable    ${pcell_mapping['detail_cells_info']['${chbw_param_name}']}
     ${is_dl_pcell_layer_exist}    get_variable_value    ${dl_pcell_layer}
     ${dl_pcell_layer}    Set Variable If   ${is_dl_pcell_layer_exist}==${None}    ${None}    ${dl_pcell_layer}
     ${chbw}    Set Variable If
     ...    ${auto_required_dl_tput_layers} and '${dl_pcell_layer}'=='4' and '${direction}'=='DL'    ${pcell_chbw}
     ...    ${auto_required_dl_tput_layers} and '${dl_pcell_layer}'=='2' and '${direction}'=='DL'    ${pcell_chbw}_layer2
     ...    '${check_pcell_tput_type}'=='peak' and '${direction}'=='DL'     ${pcell_chbw}
     ...    '${check_pcell_tput_type}'=='layer2' and '${direction}'=='DL'    ${pcell_chbw}_layer2
     ...    '${check_pcell_tput_type}'=='layer4' and '${direction}'=='DL'    ${pcell_chbw}_layer4
     ...    '${check_pcell_tput_type}'=='DSS_Phase_3' and '${direction}'=='DL'     ${pcell_chbw}_DSS_Phase_3
     ...    '${check_pcell_tput_type}'!='layer2' and '${check_pcell_tput_type}'!='peak' and '${direction}'=='DL'
     ...     ${check_pcell_tput_type}
     ...    '${check_ul_pcell_tput_type}'=='peak' and '${direction}'=='UL'     ${pcell_chbw}
     ...    '${check_ul_pcell_tput_type}'=='DSS_Phase_3' and '${direction}'=='UL'     ${pcell_chbw}_DSS_Phase_3
     ...    '${check_ul_pcell_tput_type}'=='layer1' and '${direction}'=='UL'    ${pcell_chbw}_layer1
     ...     ${check_ul_pcell_tput_type}
     ${pcell_framestructure}    Set Variable    ${pcell_mapping['framestructure']}
     ${expect_tp_percent}    Set Variable If    '${pcell_framestructure}'=='1070'    0.9    1
     ${expect_tp_percent}    Evaluate    ${expect_tp_percent}*${extra_expect_pecll_tp_percent}
     ${target_throughput}    Evaluate    ${${pcell_technology}_${direction}_EXPECT_TPUT_TABLE['${chbw}']}*${expect_tp_percent}
     ${output}    Run Keyword And Continue On Failure    power_ue.Check Tput
     ...                                    ue_type=${ue_type}
     ...                                    direction=${direction}
     ...                                    log=${tput_file}
     ...                                    cells=${pcell_nr_identity}
     ...                                    target_throughput=${target_throughput}
     ...                                    target_avg_percent=${target_${direction}_avg_percent}
     ...                                    min_percent=${min_${direction}_percent}
     ...                                    check_source=${check_source}
     ${tput_result}    Evaluate    int(${output[0]['average']})
     ${cell_id}    Evaluate    int(${output[0]['cellid']})
     Set To Dictionary    ${pcell_tput_dict}    Tput_${direction}_${cell_id}    ${tput_result}
     Run Keyword If    '${direction}'=='DL'    Set To Dictionary    ${pcell_tput_dict}    Tput_chbw_${cell_id}    ${chbw}
    END
    [Return]    ${pcell_tput_dict}

Check Tput For Scell
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               param ${addition_scell_index_list}:[1,2,3]
    ...               param ${scell_mapping}：return form kw <get_scell_mapping_for_pcell>
    [Arguments]     ${ue_type}
    ...             ${tput_file}
    ...             ${addition_scell_index_list}
    ...             ${target_DL_avg_percent}=0.9
    ...             ${min_scell_percent}=0.85
    ...             ${check_scell_tput_type}=peak
    ...             ${scell_mapping}=${SCELL_MAPPING}
    ...             ${check_source}=aasyslog
    ...             ${expect_tp_percent}=1
    ...             ${inactivate_scell_index_list}=@{EMPTY}
    ...             ${auto_required_dl_tput_layers}=${False}
    ...             ${extra_expect_secll_tp_percent}=1
    ...             ${whether_check_scell_ul_tupt}=${False}
    ...             ${special_scell_index_for_UL}=None
    ...             ${check_scell_ul_tput_type}=layer1
    ${activate_scell_index_list}    Evaluate    list(set(${addition_scell_index_list})-set(${inactivate_scell_index_list}))
    ${scell_tput_dict}    Create Dictionary
    FOR  ${scell_index}  IN  @{activate_scell_index_list}
        ${scell_technology}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['technology']}
        ${scell_pci}    Set Variable   ${scell_mapping[${scell_index}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        ${auto_required_dl_tput_layers}    Set Variable If    '${scell_technology}'=='FDD'    ${False}    ${auto_required_dl_tput_layers}
        ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
        ${scell_chbw}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${is_dl_scell_layer_exist}    get_variable_value    ${dl_scell_layer}
        ${dl_scell_layer}    Set Variable If   ${is_dl_scell_layer_exist}==${None}    ${None}    ${dl_scell_layer}
        ${scell_dl_layer}    Set Variable If    ${dl_scell_layer}!=${None}    ${dl_scell_layer['${scell_pci}']}    ${None}
        ${chbw}    Set Variable If
        ...    ${auto_required_dl_tput_layers} and '${scell_dl_layer}'=='4'    ${scell_chbw}
        ...    ${auto_required_dl_tput_layers} and '${scell_dl_layer}'=='2'    ${scell_chbw}_layer2
        ...    '${check_scell_tput_type}'=='peak'     ${scell_chbw}
        ...    '${check_scell_tput_type}'=='DSS_Phase_3'     ${scell_chbw}_DSS_Phase_3
        ...    '${check_scell_tput_type}'=='layer2'   ${scell_chbw}_layer2
        ...    '${check_scell_tput_type}'=='layer1'   ${scell_chbw}_layer1
        ...    ${check_scell_tput_type}
        ${scell_nr_identity}    Set Variable   ${scell_mapping[${scell_index}]['all_cell_info']['nrCellIdentity']}
        ${scell_nr_identity}    Convert To String    ${scell_nr_identity}
        ${scell_nr_identity}    Create List    ${scell_nr_identity}
        ${tput_result}    ${record}    aastp.Get Aasyslog Throughput     direction=DL
        ...                                                              log=${tput_file}
        ...                                                              cells=${scell_nr_identity}
        ...                                                              actCarrierAggregation=${False}
        ${tput_result}    Evaluate    int(${tput_result[0]['average']})
        ${scell_framestructure}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['framestructure']}
        ${expect_tp_percent}    Set Variable If    '${scell_framestructure}'=='1070'    0.9    1
        ${expect_tp_percent}    Evaluate    ${expect_tp_percent}*${extra_expect_secll_tp_percent}
        ${target_throughput}    Evaluate    ${${scell_technology}_DL_EXPECT_TPUT_TABLE['${chbw}']}*${expect_tp_percent}
        Run Keyword If  '${check_scell_tput_type}'=='no_data'    Run Keyword And Continue On Failure    Should Be Equal
        ...             ${tput_result}    ${0}    msg=scell with index ${scell_index} is still activate, expect result is NO TPUT.
        ...         ELSE    Run Keyword And Continue On Failure    power_ue.Check Tput
        ...                                                        ue_type=${ue_type}
        ...                                                        direction=DL
        ...                                                        log=${tput_file}
        ...                                                        cells=${scell_nr_identity}
        ...                                                        target_throughput=${target_throughput}
        ...                                                        target_avg_percent=${target_DL_avg_percent}
        ...                                                        min_percent=${min_scell_percent}
        ...                                                        check_source=${check_source}
        Set To Dictionary    ${scell_tput_dict}    Tput_${scell_index}    ${tput_result}
        Set To Dictionary    ${scell_tput_dict}    Tput_chbw_${scell_index}    ${chbw}
    END
    FOR  ${scell_index}  IN  @{inactivate_scell_index_list}
        ${scell_nr_identity}    Set Variable   ${scell_mapping[${scell_index}]['all_cell_info']['nrCellIdentity']}
        ${scell_nr_identity}    Convert To String    ${scell_nr_identity}
        ${scell_nr_identity}    Create List    ${scell_nr_identity}
        ${tput_result}    ${record}    aastp.Get Aasyslog Throughput     direction=DL
        ...                                                              log=${tput_file}
        ...                                                              cells=${scell_nr_identity}
        ...                                                              actCarrierAggregation=${False}
        ${tput_result}    Evaluate    int(${tput_result[0]['average']})
        Run Keyword And Continue On Failure    Should Be Equal    ${tput_result}    ${0}
        ...                                    msg=scell with index ${scell_index} is activate, expect result is NO ACTIVATION!
    END
    Run Keyword If    ${whether_check_scell_ul_tupt}     Check UL Tput For Scell
    ...                                                  ue_type=${ue_type}
    ...                                                  tput_file=${tput_file}
    ...                                                  special_scell_index_for_UL=${special_scell_index_for_UL}
    ...                                                  check_scell_ul_tput_type=${check_scell_ul_tput_type}
    [Return]    ${scell_tput_dict}

Check UL Tput For Scell
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ue_type}
    ...             ${tput_file}
    ...             ${special_scell_index_for_UL}=None
    ...             ${target_UL_scell_avg_percent}=0.9
    ...             ${min_UL_scell_percent}=0.85
    ...             ${check_scell_ul_tput_type}=layer1
    ...             ${scell_mapping}=${SCELL_MAPPING}
    ...             ${check_source}=aasyslog
    ...             ${expect_tp_percent}=1
    ...             ${extra_expect_secll_tp_percent}=1
    Log To Console    \n***start to check UL tput for scell***\n
    ${scell_technology}    Set Variable    ${scell_mapping[${special_scell_index_for_UL}]['all_cell_info']['detail_cells_info']['technology']}
    ${scell_pci}    Set Variable   ${scell_mapping[${special_scell_index_for_UL}]['all_cell_info']['physicalCellId']}
    ${scell_pci}    Convert To String    ${scell_pci}
    ${scell_nr_identity}    Set Variable   ${scell_mapping[${special_scell_index_for_UL}]['all_cell_info']['nrCellIdentity']}
    ${scell_nr_identity}    Convert To String    ${scell_nr_identity}
    ${scell_nr_identity}    Create List    ${scell_nr_identity}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw
    ...                                      '${scell_technology}'=='FDD'    chBwUl
    ${scell_chbw}    Set Variable    ${scell_mapping[${special_scell_index_for_UL}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
    ${chbw}    Set Variable If
    ...    '${check_scell_ul_tput_type}'=='peak'      ${scell_chbw}
    ...    '${check_scell_ul_tput_type}'=='layer1'    ${scell_chbw}_layer1
    ...     ${check_scell_ul_tput_type}
    ${scell_framestructure}    Set Variable    ${scell_mapping[${special_scell_index_for_UL}]['all_cell_info']['framestructure']}
    ${expect_tp_percent}    Set Variable If    '${scell_framestructure}'=='1070'    0.9    1
    ${expect_tp_percent}    Evaluate    ${expect_tp_percent}*${extra_expect_secll_tp_percent}
    ${target_UL_scell_throughput}    Evaluate    ${${scell_technology}_UL_EXPECT_TPUT_TABLE['${chbw}']}*${expect_tp_percent}
    Run Keyword And Continue On Failure    power_ue.Check Tput
    ...                                    ue_type=${ue_type}
    ...                                    direction=UL
    ...                                    log=${tput_file}
    ...                                    cells=${scell_nr_identity}
    ...                                    target_throughput=${target_UL_scell_throughput}
    ...                                    target_avg_percent=${target_UL_scell_avg_percent}
    ...                                    min_percent=${min_UL_scell_percent}
    ...                                    check_source=${check_source}

Get Info From Measurement Report
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${meas_id}    ${event_type}=A1    ${alias}=parser
    ${message_filter_expression}    Set Variable    nr-rrc.measurementReport_element && nr-rrc.measId == ${meas_id}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measId    pcap_parser=${alias}
    ${measId_length}    Get Length    ${measId_list}
    Run Keyword If    ${measId_length}==${0}    Fail    msg=Measurement Report For ${event_type} is not triggered.
    ${serving_cell_number}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measResultServingMOList
    ...    pcap_parser=${alias}
    ${pci_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measResultServingCell_element/nr-rrc.physCellId
    ...    pcap_parser=${alias}
    ${neighbor_cell_pci_list}     Run Keyword If    '${event_type}'=='A3' or '${event_type}'=='A5'
    ...                                              pcap.get_field_value_by_xpath
    ...                                              xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ...                                              pcap_parser=${alias}
    ${target_pcell_pci}    Set Variable If    ${neighbor_cell_pci_list} is not ${None}    ${neighbor_cell_pci_list}    ${None}
    ${scell_pci}    Set Variable If    '${serving_cell_number[0]}'!='1'    ${pci_list[1:]}    ${None}
    ${meas_info_dict}    Create dictionary    meas_id=${measId_list[0]}
    ...                                       source_pcell_pci=${pci_list[0]}
    ...                                       source_scell_pci_list=${scell_pci}
    ...                                       target_pcell_pci=${target_pcell_pci}
    [Return]    ${meas_info_dict}

Get Info From RRC Reconfiguration
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${message_filter_expression}=nr-rrc.rrcReconfiguration_element    ${alias}=parser
    #---fileter the required rrc reconfiguration---#
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    #---get IE result from the fileter rrc reconfiguration---#
    ${rrc_transaction_identifier}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.rrc_TransactionIdentifier
    ...    pcap_parser=${alias}
    ${length}    Get Length    ${rrc_transaction_identifier}
    ${error_output}    Catenate    RRC Reconfiguration Message is not filter out, please double confirm the filter expression.
    ...                            If right, then it is a problem,RRC reconfiguration messgae is not triggerd.
    Run Keyword If    ${length}==${0}    Fail    msg=${error_output}
#    Should Be Equal    ${length}    ${1}    msg=more than one rrc reconfiguration message is filter out,it is not valid for result analysis.
    ${measobjectId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasIdToAddMod_element/nr-rrc.measObjectId
    ...    pcap_parser=${alias}
    ${measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasIdToAddMod_element/nr-rrc.measId
    ...    pcap_parser=${alias}
    ${reportConfigId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasIdToAddMod_element/nr-rrc.reportConfigId
    ...    pcap_parser=${alias}
    ${measobjectId_list_2}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasObjectToAddMod_element/nr-rrc.measObjectId
    ...    pcap_parser=${alias}
    ${ssbfrequency_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.ssbFrequency
    ...    pcap_parser=${alias}
    ${reportConfigId_list_2}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.ReportConfigToAddMod_element/nr-rrc.reportConfigId
    ...    pcap_parser=${alias}
    ${reportType_list}     pcap.get_field_value_by_xpath    xpath=.//nr-rrc.reportType    pcap_parser=${alias}
    ${event_id_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId
    ...    pcap_parser=${alias}
    ${remove_measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measIdToRemoveList//nr-rrc.MeasId
    ...    pcap_parser=${alias}
    ${remove_reportConfigId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.reportConfigToRemoveList//nr-rrc.ReportConfigId
    ...    pcap_parser=${alias}
    ${add_scell_index}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellIndex
    ...    pcap_parser=${alias}
    ${add_scell_pci}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ...    pcap_parser=${alias}
    ${release_scell_index}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToReleaseList//nr-rrc.SCellIndex
    ...    pcap_parser=${alias}
    ${target_cell_pci}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.reconfigurationWithSync_element/nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId
    ...    pcap_parser=${alias}
#    ${meas_threshold_rsrp}    run keyword and continue on failure    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.eventId//nr-rrc.rsrp
#    ...    pcap_parser=${alias}
    #---analyza the IE result to readable format---#
    ${add_scell_info_dict}    Create Dictionary    scell_pci=${add_scell_pci}    scell_index=${add_scell_index}
    ${release_scell_info_dict}    Create Dictionary    scell_index=${release_scell_index}
    ${target_cell_info_dict}    Create Dictionary    target_pcell_pci=${target_cell_pci}
    ${add_mesobj_mesId_reportId_pair_mapping}    Evaluate    list(zip(${measobjectId_list},${measId_list},${reportConfigId_list}))
    ${measobj_ssbfrequency_pair_mapping}    Evaluate    list(zip(${measobjectId_list_2},${ssbfrequency_list}))
    ${ssbfrequency_measobj_mapping_dict}    Create Dictionary
    FOR  ${item}  IN  @{measobj_ssbfrequency_pair_mapping}
     Set To Dictionary      ${ssbfrequency_measobj_mapping_dict}     ${item[0]}    ${item[-1]}
    END
    ${not_event_report_id_index}    Evaluate    [index for (index, item) in enumerate(${reportType_list}) if item != '1']
    FOR    ${index}    IN    @{not_event_report_id_index}
        Insert Into List    ${event_id_list}     ${index}      not_event
    END
    ${reportId_event_pair_mapping}    Evaluate    list(zip(${reportConfigId_list_2},${event_id_list}))
    ${mesid_info_dict}     Create Dictionary
    ${message_info_dict}    Create Dictionary
    ${remove_measid_info_dict}    Create Dictionary
    ${remove_measid_length}    Get Length     ${remove_measId_list}
    ${remove_info_dict}     Run Keyword If    ${remove_measid_length}==${0}    Set Variable    ${None}
    ...    ELSE    Create Dictionary    measId=${remove_measId_list}    reportId=${remove_reportConfigId_list}
    ${mesobj_mesId_reportId_pair_mapping}    Create List
    FOR  ${item}  IN  @{reportConfigId_list_2}
     ${filter_mapping}    Evaluate    list(filter(lambda x:x[2]=='${item}',${add_mesobj_mesId_reportId_pair_mapping}))
     ${mesobj_mesId_reportId_pair_mapping}    Combine Lists    ${mesobj_mesId_reportId_pair_mapping}    ${filter_mapping}
    END
#    ${meas_threshold_rsrp_value_index}    Set Variable    ${0}
    FOR  ${meas_info}  IN  @{mesobj_mesId_reportId_pair_mapping}
        ${event_id}    Evaluate    list(filter(lambda x:x[0]=='${meas_info[2]}',${reportId_event_pair_mapping}))
#        ${meas_threshold_rsrp_value}    Set Variable    ${meas_threshold_rsrp[${meas_threshold_rsrp_value_index}]}
#        ${index_add}    Set Variable If    '${event_id[0][1]}'=='4'    2    1
#        ${meas_threshold_rsrp_value_index}    Evaluate    ${meas_threshold_rsrp_value_index}+${index_add}
        ${event_type}    Set Variable    ${EVENT_TYPE_MAPPING['${event_id[0][1]}']}
        ${ssbfrequency_measobj_keys}    get dictionary keys    ${ssbfrequency_measobj_mapping_dict}
        ${ssbfrequency}    Set Variable if    '${meas_info[0]}' in ${ssbfrequency_measobj_keys}
        ...                                    ${ssbfrequency_measobj_mapping_dict['${meas_info[0]}']}
        ...                                    ${None}
        ${mesid_detail_info}    Create Dictionary    measId=${meas_info[1]}
        ...                                          mesObj=${meas_info[0]}
        ...                                          reportId=${meas_info[2]}
        ...                                          event_type=${event_type}
        ...                                          ssbfrequency=${ssbfrequency}
#        ...                                          rsrp_threshold=${meas_threshold_rsrp_value}
        Set To Dictionary    ${mesid_info_dict}    ${meas_info[1]}     ${mesid_detail_info}
        Set To Dictionary    ${message_info_dict}    add_meas_info    ${mesid_info_dict}
    END
    #---Return Items---#
    Set To Dictionary    ${message_info_dict}    add_meas_info    ${mesid_info_dict}
    Set To Dictionary    ${message_info_dict}    remove_meas_info    ${remove_info_dict}
    Set To Dictionary    ${message_info_dict}    ssbfrequency_mesobj_info    ${ssbfrequency_measobj_mapping_dict}
    Set To Dictionary    ${message_info_dict}    add_scell_info    ${add_scell_info_dict}
    Set To Dictionary    ${message_info_dict}    release_scell_info    ${release_scell_info_dict}
    Set To Dictionary    ${message_info_dict}    target_cell_info     ${target_cell_info_dict}
    Set To Dictionary    ${message_info_dict}    rrc_transaction_identifier    ${rrc_transaction_identifier[0]}
    [Return]    ${message_info_dict}

Check RRC Reconfiguration Complete Message
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ...            ${rrc_transaction_identifier}
    ...            ${alias}=parser
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfigurationComplete_element &&
    ...                                         nr-rrc.rrc_TransactionIdentifier==${rrc_transaction_identifier}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${test_value}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rrc_TransactionIdentifier
    ...    pcap_parser=${alias}
    ${exsit_status}    Get Length    ${test_value}
    Should Be True    ${exsit_status}>${0}    msg=Reconfiguration Complete Message is not received.

Check SCELL ADDITIONRRC Reconfiguration Message Not Received
    [Documentation]    Auther:li.su@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ...            ${message_filter_expression}=${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...            ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${test_value}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.rrc_TransactionIdentifier    pcap_parser=${alias}
    ${exsit_status}    Get Length    ${test_value}
    Should Be Equal    ${exsit_status}    ${0}    msg=Reconfiguration Message is received.

Check RRC Reestablishment Request Message
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${message_filter_expression}=nr-rrc.rrcReestablishmentRequest_element
    ...            ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${physCellId}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    ${physCellId_length}    Get Length    ${physCellId}
    Should Be Equal    ${physCellId_length}    ${0}    msg=cell with pci ${physCellId} have RRC Reestablishment happend.

Check Event Removed Success
    [Arguments]    ${cpif_log_path}
    ...            ${remove_meas_info_dict}
    ...            ${alias}=parser
    ${remove_event_type}    Get Dictionary Keys    ${remove_meas_info_dict}
    ${remove_meas_id_list}    Get Dictionary Values    ${remove_meas_info_dict}
    ${message_filter_expression}    Set Variable    nr-rrc.MeasId == ${remove_meas_id_list[0]}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${test_value}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasId    pcap_parser=${alias}
    ${exsit_status}    Get Length    ${test_value}
    Should Be True    ${exsit_status}>${0}    msg=event type ${remove_event_type} is not removed.

Check Measurement Report Triggered Success
    [Arguments]    ${rrc_cpif_log}
    ...            ${mr_cpif_log}
    ...            ${event_type}=A1
    ...            ${rrc_message_filter}=${SA_RRC_RECONFIGURE_FILTER_ATTACH}
    ...            ${scell_index}=1
    ...            ${is_handover}=${False}
    ...            ${pcell_mapping}=${PCELL_MAPPING}
    ${meas_info_in_rrc}    Get Info From RRC Reconfiguration
    ...                    cpif_log_path=${rrc_cpif_log}
    ...                    message_filter_expression=${rrc_message_filter}
    ${pcell_mapping_result}    Set Variable If    ${is_handover}    ${HANDOVER_PCELL_MAPPING}    ${pcell_mapping}
    ${ssbfreq_regex}    Set Variable If    '${event_type}'=='A1' or '${event_type}'=='A2_HO'
    ...                                    x[1]['ssbfrequency']=='${pcell_mapping_result['ssbfrequency']}'
    ...                                    '${event_type}'=='A2_Release' or '${event_type}'=='A6'
    ...                                    x[1]['ssbfrequency']=='${SCELL_MAPPING[${scell_index}]['all_cell_info']['ssbfrequency']}'
    ...                                    '${event_type}'=='A3' or '${event_type}'=='A5'
    ...                                    x[1]['ssbfrequency']=='${HANDOVER_PCELL_MAPPING['ssbfrequency']}'
    ${event_type_new}    Set Variable    ${event_type.split('_')[0]}
    ${event_regex}    Set Variable    x[1]['event_type']=='${event_type_new}'
##    ${meas_info_mapping}    Evaluate    list(filter(lambda x:${ssbfreq_regex} and ${event_regex},${meas_info_in_rrc['add_meas_info']}.items()))
#    ${lambda_expression}    Set Variable If    '${event_type}'!='A2_Release'    x:${ssbfreq_regex} and ${event_regex}
#    ...                                                                         x:${event_regex}
    ${lambda_expression}    Set Variable If    '${event_type}'=='A1_after_scell_change'     x:${event_regex}
    ...                                                                                     x:${ssbfreq_regex} and ${event_regex}
    ${meas_info_mapping}    Evaluate    list(filter(lambda ${lambda_expression},${meas_info_in_rrc['add_meas_info']}.items()))
    ${meas_id_length}    Get Length    ${meas_info_mapping}
    Run Keyword If    ${meas_id_length}==${0}    Fail    msg=event type ${event_type_new} is not configured
    Should Be Equal   ${meas_id_length}    ${1}    msg=more than one measid for event type ${event_type_new} is filter out,not a valid result.
    ${add_meas_id_in_rrc}    Set Variable    ${meas_info_mapping[0][0]}
    ${meas_info_in_mr}    Get Info From Measurement Report    cpif_log_path=${mr_cpif_log}
    ...                                                       meas_id= ${add_meas_id_in_rrc}
    ...                                                       event_type=${event_type_new}
    ${is_handover}    Set Variable If    '${event_type_new}'=='A3' or '${event_type_new}'=='A5'     ${True}    ${False}
    Check Cell Mapping Result Exsit    is_handover=${is_handover}
    ${source_pcell_pci_in_mr}    Set Variable    ${meas_info_in_mr['source_pcell_pci']}
    ${target_pcell_pci_in_mr}    Set Variable    ${meas_info_in_mr['target_pcell_pci']}
    ${source_pcell_pci_in_mr}    Convert To Integer    ${source_pcell_pci_in_mr}
    Should Be Equal    ${source_pcell_pci_in_mr}    ${pcell_mapping_result['physicalCellId']}
    ...                msg=source pcell pci is not correct in ${event_type_new} MR message.
    ${target_pcell_pci_in_mr}    Run Keyword If    '${event_type_new}'=='A3' or '${event_type_new}'=='A5'
    ...                          Convert To Integer    ${target_pcell_pci_in_mr[0]}
    Run Keyword If    '${event_type_new}'=='A3' or '${event_type_new}'=='A5'    Should Be Equal
    ...               ${target_pcell_pci_in_mr}   ${HANDOVER_PCELL_MAPPING['physicalCellId']}
    ...               msg=target pcell pci is not correct in ${event_type_new} MR message.
    ${add_meas_info_dict}    Create Dictionary    ${event_type_new}    ${add_meas_id_in_rrc}
    [Return]    ${add_meas_info_dict}

Check A3 A5 Measurement Report
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${message_filter_expression}=f1ap.procedureCode == 13    ${alias}=parser
    ...            ${source_pci}=${PCELL_MAPPING['physicalCellId']}    ${target_pci}=${HANDOVER_PCELL_MAPPING['physicalCellId']}
    ...            ${whether_check_contain}=${False}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${measId_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measId    pcap_parser=${alias}
    ${measId_length}    Get Length    ${measId_list}
    Run Keyword If    ${measId_length}==${0}    Fail    msg=A3 or A5 Measurement Report For Handover is not triggered.
    ${pci_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.measResultServingCell_element/nr-rrc.physCellId
    ...                                             pcap_parser=${alias}
    ${neighbor_cell_pci_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ...                                                           pcap_parser=${alias}
    ${source_pcell_pci_in_mr}    Convert To Integer    ${pci_list[0]}
    ${target_pcell_pci_in_mr}    Convert To Integer    ${neighbor_cell_pci_list[0]}
    ${target_pci_string}         Convert To String     ${target_pci}
    Should Be Equal    ${source_pcell_pci_in_mr}    ${source_pci}
    ...                msg=source pcell pci is not correct in A3A5 MR message.
    Run Keyword If    ${whether_check_contain}      List Should Contain Value     ${neighbor_cell_pci_list}    ${target_pci_string}
    ...               msg=target pcell pci is not correct in A3A5 MR message.
    ...       ELSE      Should Be Equal    ${target_pcell_pci_in_mr}    ${target_pci}
    ...               msg=target pcell pci is not correct in A3A5 MR message.

Check Scell Addition Success
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                param:${expect_addition_scell_indexs}, if ${None},mean all configured scell will used.
    ...                else input string :${expect_addition_scell_indexs}=1 2,convert it to list by ${expect_addition_scell_indexs.split(' ')}
    [Arguments]    ${cpif_log_path}
    ...            ${mode}=SA
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${need_check_pci}=${True}
    ...            ${addition_method}=A1
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${extra_message_filter}=${None}
    Connect To Multi gNb Coam
    ${message_filter_expression}    Set Variable If    '${mode}'=='SA'    ${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                                   ${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${message_filter_expression}    Set Variable If    '${extra_message_filter}'=='${None}'    ${message_filter_expression}
    ...    ${extra_message_filter}
    ${scell_addition_info}    Get Info From RRC Reconfiguration
    ...                       cpif_log_path=${cpif_log_path}
    ...                       message_filter_expression=${message_filter_expression}
    ${scell_pci_in_rrc}    Set Variable    ${scell_addition_info['add_scell_info']['scell_pci']}
    ${scell_pci_in_rrc}    evaluate  [int(x) for x in ${scell_pci_in_rrc}]
    ${scell_filter_with_rrc}    catenate    scell_index:scell_info for scell_index, scell_info in ${scell_mapping}.items()
    ...                                     if scell_info['all_cell_info']['physicalCellId'] in ${scell_pci_in_rrc}
    ${actual_addition_scell_mapping_dict}    Evaluate    {${scell_filter_with_rrc}}
    ${actual_addition_scell_index_list}    get dictionary keys    ${actual_addition_scell_mapping_dict}
    ${all_scell_list}    get dictionary keys    ${scell_mapping}
    ${status}    ${expect_addition_scell_indexs_type}
    ...    Run Keyword And Ignore Error    Evaluate    isinstance(${expect_addition_scell_indexs},list)
    ${expect_addition_scell_indexs}    Set Variable If    '${status}'=='FAIL'
    ...    ${expect_addition_scell_indexs.split(' ')}    ${expect_addition_scell_indexs}
    ${expect_addition_scell_indexs}    run keyword if    ${expect_addition_scell_indexs} != ${None}
    ...    evaluate    [int(x) for x in ${expect_addition_scell_indexs}]
    ${expect_addition_scell_index_list}    Set Variable If    ${expect_addition_scell_indexs} != ${None}
    ...                                                       ${expect_addition_scell_indexs}
    ...                                                       ${all_scell_list}
    run keyword if    ${expect_addition_scell_index_list} != ${None}    sort list   ${expect_addition_scell_index_list}
    sort list    ${actual_addition_scell_index_list}
    Run Keyword If   ${need_check_pci}   Lists Should Be Equal    ${expect_addition_scell_index_list}   ${actual_addition_scell_index_list}
    ...                                  msg=expect scell is ${expect_addition_scell_index_list},actual is ${actual_addition_scell_index_list}.
    #used for scell release checking
    Set Test Variable    ${ADDITION_SCELL_INDEX_IN_RRC}    ${scell_addition_info['add_scell_info']['scell_index']}
    [Return]    ${actual_addition_scell_index_list}
    [Teardown]    Teardown Multi gNb Connections

Check Scell Release Success
    [Arguments]    ${release_cpif_log_path}    ${addition_cpif_log_path}=${None}    ${mode}=SA
    ${is_addition_scell_index_exist}    get_variable_value    ${ADDITION_SCELL_INDEX_IN_RRC}
    Run Keyword If    ${is_addition_scell_index_exist}==${None}    Check Scell Addition Success
    ...                                                            cpif_log_path=${addition_cpif_log_path}
    ...                                                            mode=${mode}
    ...                                                            need_check_pci=${False}
    ${message_filter_expression}    Set Variable    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_RELEASE}
    ${scell_release_info}    Get Info From RRC Reconfiguration
    ...                      cpif_log_path=${release_cpif_log_path}
    ...                      message_filter_expression=${message_filter_expression}
    Lists Should Be Equal    ${ADDITION_SCELL_INDEX_IN_RRC}    ${scell_release_info['release_scell_info']['scell_index']}
    ...                      msg=scell is not released properly.

Check CA Scell Swap Success
    [Documentation]    Auther: li.su@nokia-sbell.com
    [Arguments]    ${addition_cpif_log_path}    ${swap_cpif_log_path}    ${rrc_message_filter}    ${source_scell_index}    ${target_scell_index}
    ${all_addition_scell_info}    Get Info From RRC Reconfiguration
    ...                           cpif_log_path=${addition_cpif_log_path}
    ...                           message_filter_expression=${rrc_message_filter}
    ${all_swap_scell_info}       Get Info From RRC Reconfiguration
    ...                          cpif_log_path=${swap_cpif_log_path}
    ...                          message_filter_expression=${rrc_message_filter}
    ${expect_source_scell_pci}    Set Variable    ${scell_mapping[${source_scell_index}]['all_cell_info']['physicalCellId']}
    ${expect_target_scell_pci}    Set Variable    ${scell_mapping[${target_scell_index}]['all_cell_info']['physicalCellId']}
    ${all_add_scell_index_in_addition}    Set Variable    ${all_addition_scell_info['add_scell_info']['scell_index']}
    ${all_add_scell_pci_in_addition}      Set Variable    ${all_addition_scell_info['add_scell_info']['scell_pci']}
    ${all_add_scell_pci_in_addition}    Evaluate    [int(x) for x in ${all_add_scell_pci_in_addition}]
    ${swap_scell_pci_in_swap}    Set Variable    ${all_swap_scell_info['add_scell_info']['scell_pci']}
    ${swap_scell_pci_in_swap}    Evaluate    [int(x) for x in ${swap_scell_pci_in_swap}]
    ${release_scell_index_in_swap}    Set Variable    ${all_swap_scell_info['release_scell_info']['scell_index']}
    Run Keyword And Continue On Failure    List Should Contain Value    ${all_add_scell_pci_in_addition}    ${expect_source_scell_pci}
    ...                      msg=scell is not added properly.
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${swap_scell_pci_in_swap[0]}    ${expect_target_scell_pci}
    ...                      msg=scell is not swapped properly.
    Check Specific Scell Release Success    scell_index=${source_scell_index}
    ...                                     release_cpif_log_path=${swap_cpif_log_path}
    ...                                     addition_cpif_log_path=${addition_cpif_log_path}

Check CA Two Scells Swap Success
    [Documentation]    Auther: li.su@nokia-sbell.com
    [Arguments]    ${addition_cpif_log_path}    ${swap_cpif_log_path}    ${rrc_message_filter}    ${source_scell_index}    ${target_scell_index}
    ${all_addition_scell_info}    Get Info From RRC Reconfiguration
    ...                           cpif_log_path=${addition_cpif_log_path}
    ...                           message_filter_expression=${rrc_message_filter}
    ${all_swap_scell_info}       Get Info From RRC Reconfiguration
    ...                          cpif_log_path=${swap_cpif_log_path}
    ...                          message_filter_expression=${rrc_message_filter}
    ${expect_source_scell_pci}    Create List    ${scell_mapping[${source_scell_index}[0]]['all_cell_info']['physicalCellId']}
    ...                                          ${scell_mapping[${source_scell_index}[1]]['all_cell_info']['physicalCellId']}
    ${expect_target_scell_pci}    Create List    ${scell_mapping[${target_scell_index}[0]]['all_cell_info']['physicalCellId']}
    ...                                          ${scell_mapping[${target_scell_index}[1]]['all_cell_info']['physicalCellId']}
    @{all_add_scell_index_in_addition}    Set Variable    ${all_addition_scell_info['add_scell_info']['scell_index']}
    @{all_add_scell_pci_in_addition}      Set Variable    ${all_addition_scell_info['add_scell_info']['scell_pci']}
    ${all_add_scell_pci_in_addition}    Evaluate    [int(x) for x in ${all_add_scell_pci_in_addition}]
    @{swap_scell_pci_in_swap}    Set Variable    ${all_swap_scell_info['add_scell_info']['scell_pci']}
    ${swap_scell_pci_in_swap}    Evaluate    [int(x) for x in ${swap_scell_pci_in_swap}]
    @{release_scell_index_in_swap}    Set Variable    ${all_swap_scell_info['release_scell_info']['scell_index']}
    Run Keyword And Continue On Failure    List Should Contain Sub List    ${all_add_scell_pci_in_addition}    ${expect_source_scell_pci}
    ...                      msg=scell is not all added properly.
    Run Keyword And Continue On Failure   List Should Contain Sub List    ${swap_scell_pci_in_swap}    ${expect_target_scell_pci}
    ...                      msg=scell is not all swapped properly.
    Run Keyword And Continue On Failure   List Should Contain Sub List    ${all_add_scell_index_in_addition}    ${release_scell_index_in_swap}
    ...                      msg=scell is not all release properly.

Check Specific Scell Release Success
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${scell_index}
    ...            ${release_cpif_log_path}
    ...            ${addition_cpif_log_path}=${None}
    ...            ${mode}=SA
    ...            ${scell_mapping}=${SCELL_MAPPING}
    ...            ${addition_method}=A1
    ${addition_message_filter_expression}    Set Variable If   '${mode}'=='SA'  ${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...                                                                         ${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${all_addition_scell_info}    Get Info From RRC Reconfiguration
    ...                           cpif_log_path=${addition_cpif_log_path}
    ...                           message_filter_expression=${addition_message_filter_expression}
    ${expect_scell_pci}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['physicalCellId']}
    ${all_scell_pci_in_rrc}    Set Variable    ${all_addition_scell_info['add_scell_info']['scell_pci']}
    ${all_scell_pci_in_rrc}    evaluate  [int(x) for x in ${all_scell_pci_in_rrc}]
    ${all_scell_index_in_rrc}    Set Variable    ${all_addition_scell_info['add_scell_info']['scell_index']}
    ${all_scell_index_in_rrc}    evaluate  [int(x) for x in ${all_scell_index_in_rrc}]
    ${index}    get index from list    ${all_scell_pci_in_rrc}    ${expect_scell_pci}
    ${expect_scell_index_in_rrc}    Set Variable     ${all_scell_index_in_rrc[${index}]}
    ${release_message_filter_expression}    Set Variable    ${${mode}_RRC_RECONFIGURE_FILTER_SCELL_RELEASE}
    ${release_scell_info}    Get Info From RRC Reconfiguration
    ...                      cpif_log_path=${release_cpif_log_path}
    ...                      message_filter_expression=${release_message_filter_expression}
    Should Be Equal As Integers    ${expect_scell_index_in_rrc}    ${release_scell_info['release_scell_info']['scell_index'][0]}
    ...                            msg=scell-${scell_index} is not released.

#Check RRC Reconfigure And RRC Reconfigure Complete For Handover
#    [Documentation]    author:Stella.lin@nokia-sbell.com
#    [Arguments]    ${cpif_log_path}    ${mode}=SA
#    ${message_filter_expression}    Set Variable If    '${mode}'=='SA'    ${SA_RRC_RECONFIGURE_FILTER_HANDOVER}
#    ...                                                                   ${NSA_RRC_RECONFIGURE_FILTER_HANDOVER}
#    ${ho_success_rrc}    Get Info From RRC Reconfiguration    cpif_log_path=${cpif_log_path}
#    ...                                                       message_filter_expression=${message_filter_expression}
#    ${ho_success_rrc_complete}     Run Keyword And Continue On Failure    Check RRC Reconfiguration Complete Message
#    ...                            cpif_log_path=${cpif_log_path}
#    ...                            rrc_transaction_identifier= ${ho_success_rrc['rrc_transaction_identifier']}


Check RRC Reconfigure And RRC Reconfigure Complete For Handover
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${source_ho_cpif_log_path}    ${target_ho_cpif_log_path}     ${mode}=SA
    ...            ${message_filter_expression}=${${mode}_RRC_RECONFIGURE_FILTER_HANDOVER}
    ${ho_success_rrc}    Get Info From RRC Reconfiguration    cpif_log_path=${source_ho_cpif_log_path}
    ...                                                       message_filter_expression=${message_filter_expression}
    ${ho_success_rrc_complete}     Run Keyword And Continue On Failure    Check RRC Reconfiguration Complete Message
    ...                            cpif_log_path=${target_ho_cpif_log_path}
    ...                            rrc_transaction_identifier=${ho_success_rrc['rrc_transaction_identifier']}

Check Cell Mapping Result Exsit
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${is_secll}=${False}    ${is_handover}=${False}
    ${is_pcell_mapping_exist}    get_variable_value    ${PCELL_MAPPING}
    ${is_handover_pcell_mapping_exist}    get_variable_value    ${HANDOVER_PCELL_MAPPING}
    ${is_scell_mapping_exist}    get_variable_value    ${SCELL_MAPPING}
    ${is_handover_scell_mapping_exist}    get_variable_value    ${HANDOVER_SCELL_MAPPING}
    Should Not Be Equal    ${is_pcell_mapping_exist}    ${None}
    ...                    msg=test variable 'PCELL_MAPPING' is not setting,please set one before use this KW.
    Run Keyword If    ${is_handover}    Should Not Be Equal    ${is_handover_pcell_mapping_exist}    ${None}
    ...                                 msg=test variable 'HANDOVER_PCELL_MAPPING' is not setting,please set one before use this KW.
    Run Keyword If    ${is_secll}    Should Not Be Equal    ${is_scell_mapping_exist}    ${None}
    ...                              msg=test variable 'SCELL_MAPPING' is not setting,please set one before use this KW.
    Run Keyword If    ${is_secll} and ${is_handover}     Should Not Be Equal    ${is_handover_scell_mapping_exist}    ${None}
    ...               msg=test variable 'HANDOVER_SCELL_MAPPING' is not setting,please set one before use this KW.

Check RLQ Triggered Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check RLQ deactivate success via syslog
    [Arguments]    ${log_path}
    ${syslog_filter_pattern}    Create List    RlqAlgorithm prepare sending SCellStatusInd with permanent deactivation
    Check Log Existence On Syslog    log_path=${log_path}    syslog_filter_pattern_list=${syslog_filter_pattern}

Initial PA Port Up For Basic Case
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}
    ...            ${source_gnb_id}=0
    ...            ${initial_pcell_pa_value}=${None}
    ...            ${initial_scell_pa_value}=${None}
    Connect To Multi gNb Coam
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
#    ${all_required_scell_info}    mbca.get_required_scell    band_type=${band_type}    l2rt_type=${l2rt_type}
#    ${required_scell_res}    Evaluate    random.choice(list(${all_required_scell_info}.items()))    modules=random
#    ${pcell_index}    Set Variable    ${required_scell_res[0]}
    mbca.set_pcell_index    value=${pcell_index}
    ${pcell_mapping}    mbca.get_pcell_mapping
    ${scell_mapping}    mbca.get_scell_mapping_for_pcell
    ${pcell_ru_index}    Set Variable    ${pcell_mapping['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    ${scell_index_list}    Get Dictionary Keys    ${scell_mapping}
    FOR  ${scell_index}  IN    @{scell_index_list}
        ${scell_ru_index}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
#    Set Test Variable    ${INITIAL_SCELL_RU_PORT_LIST}    ${scell_ru_index_list}
    Initial PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}
    ...                                         gnb_id=${source_gnb_id}
    ...                                         pa_off_value=${initial_pcell_pa_value}
    Initial PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}
    ...                                         gnb_id=${source_gnb_id}
    ...                                         pa_off_value=${initial_scell_pa_value}

#Initial PA Port Up For Handover Case
#    [Documentation]    author:Stella.lin@nokia-sbell.com
#    [Arguments]    ${source_gnb_id}=0
#    ...            ${handover_gnb_type}=Intra
#    ...            ${frequency_type}=Intra
#    ...            ${band_type}=Intra
#    ...            ${l2rt_type}=Intra
#    ...            ${scell_pa_interval}=60
#    Connect To Multi gNb Coam
#    mbca.set_gnb_id    value=${source_gnb_id}
#    mbca.set_gnb_operation_object
#    ${all_required_scell_info}    mbca.get_required_scell    band_type=${band_type}    l2rt_type=${l2rt_type}
#    ${pcell_index_list_one}    Get Dictionary Keys    ${all_required_scell_info}
#    ${configuration_mapping_res}    mbca.get_required_handover_cell_mapping    handover_gnb_type=${handover_gnb_type}
#    ...                                                                        frequency_type=${frequency_type}
#    ${pcell_index_list_two}    Get Dictionary Keys    ${configuration_mapping_res}
#    ${common_pcell_index_list}    Evaluate    set(${pcell_index_list_one})&set(${pcell_index_list_two})
#    ${pcell_index}    Evaluate     random.choice(list(${common_pcell_index_list}))     modules=random
#    mbca.set_pcell_index    value=${pcell_index}
#    ${pcell_mapping}    mbca.get_pcell_mapping
#    ${scell_mapping}    mbca.get_scell_mapping_for_pcell
#    ${pcell_ru_index}    Set Variable    ${pcell_mapping['ru_index_mapping']}
#    ${scell_ru_index_list}    Create List
#    ${scell_index_list}    Get Dictionary Keys    ${scell_mapping}
#    FOR  ${scell_index}  IN    @{scell_index_list}
#        ${scell_ru_index}    Set Variable    ${scell_mapping[${scell_index}]['all_cell_info']['ru_index_mapping']}
#        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
#    END
#    Set Test Variable    ${INITIAL_SCELL_RU_PORT_LIST}    ${scell_ru_index_list}
#    Initial PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    gnb_id=${source_gnb_id}
##    Initial PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    gnb_id=${source_gnb_id}
#    Modify PA Value For Required RU With Interval    ru_index=${scell_ru_index_list}    gnb_id=${source_gnb_id}    interval=${scell_pa_interval}

#Modify Handover PA Value By Steps For CA Group
#    [Documentation]   stella.lin@nokia-sbell.com
#    [Arguments]    ${source_gnb_id}    ${target_gnb_id}    ${source_ru_index_list}    ${target_pcell_ru_index}    ${target_scell_ru_index}
#    ...            ${interval}=10    ${step}=1    ${range}=10    ${common_scell_ru_list}=${None}
#    Initial PA Value Setting For Required RU    modify_ru_id=${target_pcell_ru_index}
#    ...                                         gnb_id=${target_gnb_id}
#    ${scell_interval}    Evaluate    ${interval}+15
#    ${target_scell_ru_index_type}    Evaluate    type(${target_scell_ru_index}).__name__
#    ${convert_target_scell_ru_index_to_list}    Create List    ${target_scell_ru_index}
#    ${target_scell_ru_index}    Set Variable If    'list' in '${target_scell_ru_index_type}'   ${target_scell_ru_index}
#    ...                                                                                        ${convert_target_scell_ru_index_to_list}
#    ${is_pcell_and_scell_shared_ru}    Run Keyword And Return Status    List Should Contain Value
#    ...                                                                 ${target_scell_ru_index}    ${target_pcell_ru_index}
#    Run Keyword Unless    ${is_pcell_and_scell_shared_ru}     Modify PA Value For Required RU With Interval
#    ...                                                       ru_index=${target_scell_ru_index}
#    ...                                                       gnb_id=${target_gnb_id}
#    ...                                                       interval=${scell_interval}
#    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${interval}
#    ${source_ru_index_list_new}    Run Keyword If    ${common_scell_ru_list}!=${None}    Evaluate
#    ...                                              [x for x in ${source_ru_index_list} if x not in ${common_scell_ru_list}]
#    Run Keyword If    ${common_scell_ru_list}!=${None}    Initial PA Value Setting For Required RU    modify_ru_id=${source_ru_index_list_new}
#    ...                                                   gnb_id=${source_gnb_id}
#    ...                                                   pa_off_value=127
#    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}
#    ...                                         gnb_id=${target_gnb_id}

Procedures.CA Attach L3 Call Test For Peak With QCOM
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${mode}=SA    ${set_value}=${15}
    ...            ${enb_set_value}=${20}    ${attenuator_id}=${0}
    ...            ${gnb_index}=0    ${coam_connection}=GNB_OAM
    ...            ${expect_addition_scell_indexs}=${None}
    ...            ${data_transfer_duration}=3600
    ...            ${ue_index}=${2}
    ...            ${dl_data_transfer}=3000M
    ...            ${ul_data_transfer}=130M
    ...            ${enb_index}=0
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${duration}=5m
    ...            ${ignore_time}=1min
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=aasyslog
    ...            ${ultarget_throughput}=210
    ...            ${dltarget_throughput}=1450
    ...            ${expect_dl_tput_scell_1}=600
    ...            ${expect_dl_tput_scell_2}=200
    ...            ${target_avg_percent}=0.98
    ...            ${min_percent}=0.85
    Log    ${asik_connection_alias}
    Log To Console    \n****** start to attach and verify L3 call ******\n
    Comment    \n****** step1:change ue mode ******\n
    Initial PA Value Setting For All Attenuators
    Procedures.UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    Run Keyword If    '${mode}'=='SA'    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all
    ...                                                                                    exp_status=barred
    ...                                                                                    enb_index=${0}
    Run Keyword If    '${mode}'=='NSA'    Run Keywords
    ...    Change cellBarred Parameter Value On Gnb    pcell_index=all    exp_status=barred   AND
    ...    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=121    exp_status=notBarred    enb_index=${0}
#    Change Network Mode Between SA And NSA    ue_type=${ue_type}
#    ...                                       ue_index=${ue_index}
#    ...                                       is_prepare_ue_needed=${False}
#    ...                                       prefer_5g_nr_mode=${mode}
    Comment    \n****** step2:some additional operations before attach ******\n
    ${channels}    Create List    17    18    19    20
    ${enb_channels}    Run Keyword If    '${mode}'=='NSA'    Create List    5    6
    Modify PA Value For QCOM    set_channel=${channels}    set_value=${set_value}    attenuator_id=${attenuator_id}
    Run Keyword If    '${mode}'=='NSA'    Modify PA Value For QCOM    set_channel=${enb_channels}
    ...                                                               set_value=${enb_set_value}
    ...                                                               attenuator_id=${attenuator_id}
    Comment    \n****** step3:start to attach with specific UE type ******\n
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_mode=${mode}
    ...                                       ue_type=${ue_type}
    ...                                       coam_connection=${coam_connection}
    ...                                       ue_index=${ue_index}
    ...                                       gnb_index=${gnb_index}
    ...                                       enb_wireshark_log_prefix=enb_wireshark_log
    ...                                       enb_index=${enb_index}
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    Log To Console    ${attach_info}
    Sleep    15sec
    ${status}    ${attach_aasyslog_list}    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=5Grach
    Comment    \n****** step4:start ul/dl data transfer   ******\n
    ${cpif_log_path}    Set Variable If    '${mode}'=='NSA'    ${attach_info['enb_wireshark_log_path']}
    ...                                                        ${attach_info['cpif_log_path']}
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=${data_transfer_duration}
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${cpif_log_path}
    ...                            ue_iperf_path=iperf
    ...                            mode=${mode}
    ...                            ue_index=${ue_index}
    Sleep    15sec
    Comment    \n****** step5:check ul/dl tput  ******\n
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}
    ...                                     ue_index=${ue_index}
    ...                                     duration=${duration}
    ...                                     ignore_time=${ignore_time}
    ...                                     check_source=${check_source}
    ${list_pcell}    Get NRCELLID based on CELLID    cellid=${attach_info['attach_cell_index']}
    ...                                              connection=${coam_connection}
    ...                                              list_all_cell_ids=${list_all_cell_ids}
    ${list_scell_1}    Get NRCELLID based on CELLID    cellid=${expect_addition_scell_indexs[0]}
    ...                                              connection=${coam_connection}
    ...                                              list_all_cell_ids=${list_all_cell_ids}
    ${list_scell_2}    Run Keyword If    '${mode}'=='SA'    Get NRCELLID based on CELLID    cellid=${expect_addition_scell_indexs[1]}
    ...                                                                                     connection=${coam_connection}
    ...                                                                                     list_all_cell_ids=${list_all_cell_ids}
    Run Keyword And Continue On Failure    power_ue.Check Bi Tput    ue_type=${ue_type}
    ...                                                              log=${tput_log}
    ...                                                              cells=${list_pcell}
    ...                                                              ue_index=${ue_index}
    ...                                                              ultarget_throughput=${ultarget_throughput}
    ...                                                              dltarget_throughput=${dltarget_throughput}
    ...                                                              target_avg_percent=${target_avg_percent}
    ...                                                              min_percent=${min_percent}
    ...                                                              check_source=${check_source}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}
    ...                                                           direction=DL
    ...                                                           log=${tput_log}
    ...                                                           cells=${list_scell_1}
    ...                                                           ue_index=${ue_index}
    ...                                                           target_throughput=${expect_dl_tput_scell_1}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           min_percent=${min_percent}
    ...                                                           check_source=${check_source}
    Run Keyword If   '${mode}'=='SA'   Run Keyword And Continue On Failure   Power_ue.Check Tput   ue_type=${ue_type}
    ...                                                                                            direction=DL
    ...                                                                                            log=${tput_log}
    ...                                                                                            cells=${list_scell_2}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            target_throughput=${expect_dl_tput_scell_2}
    ...                                                                                            target_avg_percent=${target_avg_percent}
    ...                                                                                            min_percent=${min_percent}
    ...                                                                                            check_source=${check_source}
    Comment    \n****** step6:return detailed pcell and scell related info dict during attach ******\n
    ${attach_ca_cell_info_dict}    Create Dictionary    pcell_index=${attach_info['attach_cell_index']}
    ...                                                 scell_index_list=${expect_addition_scell_indexs}
    ...                                                 source_gnb_id=${gnb_index}
    ...                                                 attach_cpif_log=${attach_info['cpif_log_path']}
    [Return]    ${attach_ca_cell_info_dict}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=cpif_scell_addition    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=cpif_scell_addition    AND
    ...                           Run keyword and ignore error    COAM Teardown gnb connections

Modify PA Value For QCOM
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${set_channel}    ${set_value}    ${attenuator_id}=${0}
    ${attenuator_index}    Set Variable    ${attenuator_id}
    ${value}    Set Variable    ${set_value}
    ${channels}    Set Variable    ${set_channel}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}
    @{ports}    Create List
    ${value}    Evaluate    float(${value})
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To Integer    ${channel}
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify Handover PA Value By Steps For Inter Frequency Handover
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${source_gnb_id}    ${target_gnb_id}    ${source_ru_index_list}    ${target_pcell_ru_index}    ${target_scell_ru_index}
    ...            ${interval}=10    ${step}=1    ${range}=10    ${common_scell_ru_list}=${None}
    Log Many    ${step}    ${range}
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=17
    Sleep    1sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}    pa_off_value=53
    Sleep    1sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}    pa_off_value=53
    Sleep    1sec
    ${status}    ${test_case_id}    Run Keyword And Ignore Error    Evaluate    '_'.join(${TEST NAME.split('_')[1:3]})
    Run Keyword If    '${test_case_id}'=='A_13'    Run Keywords
    ...    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=19    AND
    ...    Sleep   5sec    AND
    ...    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}    pa_off_value=39    AND
    ...    Sleep   5sec
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=22
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${interval}
    ${target_scell_ru_index_type}    Evaluate    type(${target_scell_ru_index}).__name__
    ${convert_target_scell_ru_index_to_list}    Create List    ${target_scell_ru_index}
    ${target_scell_ru_index}    Set Variable If    'list' in '${target_scell_ru_index_type}'   ${target_scell_ru_index}
    ...                                                                                        ${convert_target_scell_ru_index_to_list}
    Sleep    5sec
    Run Keyword If    '${test_case_id}'=='B_B2'    Run Keywords
    ...    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}
    ...    pa_off_value=${25}    AND
    ...    Sleep   1sec    AND
    ...    Initial PA Value Setting For Required RU    modify_ru_id=${target_pcell_ru_index}    gnb_id=${target_gnb_id}
    ...    pa_off_value=${25}    AND
    ...    Sleep   8sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}
    Sleep    1sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_pcell_ru_index}    gnb_id=${target_gnb_id}
    Sleep    10sec
    ${source_ru_index_list_new}    Run Keyword If    ${common_scell_ru_list}!=${None}    Evaluate
    ...                                              [x for x in ${source_ru_index_list} if x not in ${common_scell_ru_list}]
    Run Keyword If    ${common_scell_ru_list}!=${None}    Initial PA Value Setting For Required RU    modify_ru_id=${source_ru_index_list_new}
    ...                                                   gnb_id=${source_gnb_id}
    ...                                                   pa_off_value=127

Modify Handover PA Value By Steps For CA Group
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${source_gnb_id}    ${target_gnb_id}    ${source_ru_index_list}    ${target_pcell_ru_index}    ${target_scell_ru_index}
    ...            ${interval}=10    ${step}=1    ${range}=10    ${common_scell_ru_list}=${None}
    Log Many    ${step}    ${range}
    Initial PA Value Setting For Required RU    modify_ru_id=${target_pcell_ru_index}
    ...                                         gnb_id=${target_gnb_id}
    ${target_scell_ru_index_type}    Evaluate    type(${target_scell_ru_index}).__name__
    ${convert_target_scell_ru_index_to_list}    Create List    ${target_scell_ru_index}
    ${target_scell_ru_index}    Set Variable If    'list' in '${target_scell_ru_index_type}'   ${target_scell_ru_index}
    ...                                                                                        ${convert_target_scell_ru_index_to_list}
    ${is_pcell_and_scell_shared_ru}    Run Keyword And Return Status    List Should Contain Value
    ...                                                                 ${target_scell_ru_index}    ${target_pcell_ru_index}
    run keyword if  not ${is_pcell_and_scell_shared_ru}     Modify PA Value For Required RU With Interval
    ...                                                       ru_index=${target_scell_ru_index}
    ...                                                       gnb_id=${target_gnb_id}
    ...                                                       interval=${10}
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${4}
    Sleep   3sec
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${8}
    Sleep   3sec
    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${interval}
#    Modify PA Value For Required RU With Interval    ru_index=${source_ru_index_list}    gnb_id=${source_gnb_id}    interval=${30}
    Sleep    5sec
    Initial PA Value Setting For Required RU    modify_ru_id=${target_scell_ru_index}    gnb_id=${target_gnb_id}
    Sleep    10sec
    ${source_ru_index_list_new}    Run Keyword If    ${common_scell_ru_list}!=${None}    Evaluate
    ...                                              [x for x in ${source_ru_index_list} if x not in ${common_scell_ru_list}]
    Run Keyword If    ${common_scell_ru_list}!=${None}    Initial PA Value Setting For Required RU    modify_ru_id=${source_ru_index_list_new}
    ...                                                   gnb_id=${source_gnb_id}
    ...                                                   pa_off_value=127

Modify PA Value For Required RU With Interval
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_id}=0    ${interval}=10
    ${ru_index_type}    Evaluate    type(${ru_index}).__name__
    ${convert_ru_index_to_list}    Create List    ${ru_index}
    ${modify_ru_id_list}    Set Variable If    'list' in '${ru_index_type}'    ${ru_index}    ${convert_ru_index_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${tl_prefix}    Set Variable    ${testline_name.split('_')[-1][-4:]}
        ${base_value}    Set Variable    ${${tl_prefix}_PA_BASE_VALUE_MAPPING_TABLE['${gnb_id}']['${ru_index}']}
        ${base_value_type}    Evaluate    type(${base_value}).__name__
        ${modify_value}    Run Keyword If    'list' in '${base_value_type}'    Evaluate    [int(x)+int(${interval}) for x in ${base_value}]
        ...                            ELSE   Evaluate    ${base_value}+${interval}
        gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU   value=${modify_value}   RU_id=${ru_index}   gnb_id=${gnb_id}
    END

Modify PA Value By Steps For Required RU
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_id}=0   ${step}=2    ${range}=15     ${sleep_duration}=1
    FOR    ${round}    IN RANGE    0    ${range}
        ${interval}    Evaluate    ${round}*${step}
        sleep    ${sleep_duration}sec
        Modify PA Value For Required RU With Interval    ru_index=${ru_index}    gnb_id=${gnb_id}    interval=${interval}
    END

Initial PA Value Setting For Required RU
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${gnb_id}=0    ${pa_off_value}=${None}    ${all_ru_need_to_modify}=${False}
    ${all_ru_list_in_init}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus}
    ${length_of_all_ru_list}    Get Length    ${all_ru_list_in_init}
    ${all_ru_list_in_init}     Evaluate      [i for i in range(${length_of_all_ru_list})]
    ${modify_ru_id}    Set Variable If     ${all_ru_need_to_modify}     ${all_ru_list_in_init}    ${modify_ru_id}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}' or 'tuple' in '${modify_ru_id_type}'
    ...      ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${tl_prefix}    Set Variable    ${testline_name.split('_')[-1][-4:]}
        ${base_up_value}    Set Variable    ${${tl_prefix}_PA_BASE_VALUE_MAPPING_TABLE['${gnb_id}']['${ru_index}']}
        ${base_down_value}    Set Variable    ${pa_off_value}
        ${base_value}    Set Variable If    ${pa_off_value}==${None}    ${base_up_value}    ${base_down_value}
        ${attenuation_ports}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${ru_index}].attenuation_ports}
        Run Keyword If    '${attenuation_ports}'!='None'    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...                                                 value=${base_value}   RU_id=${ru_index}    gnb_id=${gnb_id}
    END

Initial PA Value Setting For All Gnb
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${pa_off_value}=127    ${all_ru_need_to_modify}=${True}
    ${gnb_number}    Get Length    ${tl.gnbs}
    FOR  ${gnb_id}  IN RANGE  ${gnb_number}
        Initial PA Value Setting For Required RU    gnb_id=${gnb_id}
        ...                                         pa_off_value=${pa_off_value}
        ...                                         all_ru_need_to_modify=${all_ru_need_to_modify}
    END

Modify PA Value For ENB
    [Documentation]   jun.8.chen@nokia-sbell.com
    ${tl_prefix}    Set Variable    ${testline_name.split('_')[-1][-4:]}
    ${attenuator_index}    Set Variable If    '${tl_prefix}'=='T079'    ${1}    ${0}
    ${value}    Set Variable If    '${tl_prefix}'=='T079'    ${0}    ${20}
    @{channels}    Run Keyword If     '${tl_prefix}'=='T079'     Create List    7    8
    ...            ELSE    Create List    27    28
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}
    @{ports}    Create List
    ${value}    Evaluate    float(${value})
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To Integer    ${channel}
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Initial PA Value Setting For Whole PA
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${value}=${127}    ${attenuator_index}=${0}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    @{ports}    Create List
    ${value}    Evaluate    float(${value})
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To Integer    ${channel}
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Initial PA Value Setting For All Attenuators
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${value}=${127}
    ${attenuator_number}    Get Length    ${tl.attenuators}
    FOR  ${attenuator_index}  IN RANGE  ${attenuator_number}
        Initial PA Value Setting For Whole PA    value=${value}    attenuator_index=${attenuator_index}
    END


Check PCSI Multiplexing Function With CPIF Log
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${message_filter_expression}=nr-rrc.rrcSetup_element    ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${reportSlotConfig_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.reportSlotConfig    pcap_parser=${alias}
    ${pucchResource_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.pucch_Resource    pcap_parser=${alias}
    ${reportQuantity_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.reportQuantity    pcap_parser=${alias}
    ${csi_report_config_info_list}    Evaluate    list(zip(${reportQuantity_list[-2:]},${reportSlotConfig_list[-2:]},${pucchResource_list[-2:]}))
    ${csi_report_config_info_dict}    Create Dictionary
    &{CSI_REPORT_PERIODIC_SLOTS}    Create Dictionary    9=320
    FOR    ${item}    IN    @{csi_report_config_info_list}
        &{CSI_REPORT_QUANTITY_TYPE}    Create Dictionary    7    CSI_Report     6    Beam_Report
        ${csi_report_periodic_slot}    Set Variable    ${CSI_REPORT_PERIODIC_SLOTS['${item[1]}']}
        ${csi_report_quantity_type}    Set Variable    ${CSI_REPORT_QUANTITY_TYPE['${item[0]}']}
        ${report_dict_value}    Create Dictionary    periodic_slot=${csi_report_periodic_slot}     pucch_resource=${item[2]}
        Set To Dictionary    ${csi_report_config_info_dict}    ${csi_report_quantity_type}    ${report_dict_value}
    END
    ${csi_report_periodic_slot}    Set Variable    ${csi_report_config_info_dict['CSI_Report']['periodic_slot']}
    Run Keyword And Continue On Failure    Should Be Equal    ${csi_report_periodic_slot}
    ...                                                       ${csi_report_config_info_dict['Beam_Report']['periodic_slot']}
    ...                                                       msg=periodic slots are not set to same for csi report and beam report.
    Run Keyword And Continue On Failure     Should Be Equal    ${csi_report_config_info_dict['CSI_Report']['pucch_resource']}
    ...                                                        ${csi_report_config_info_dict['Beam_Report']['pucch_resource']}
    ...                                                        msg=pucch resource are not set to same after pcsi multiplexing on.
    ${pucch_resource}     Set Variable    ${csi_report_config_info_dict['Beam_Report']['pucch_resource']}
    ${reportSlotConfigOffset_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.reportSlotConfig/nr-rrc.slots${csi_report_periodic_slot}
    ...    pcap_parser=${alias}
    ${reportSlotConfigOffset_list}    Set Variable       ${reportSlotConfigOffset_list[-2:]}
    ${reportSlotConfigOffset}   Run Keyword And Continue On Failure     Should Be Equal
    ...    ${reportSlotConfigOffset_list[0]}    ${reportSlotConfigOffset_list[1]}
    ...    msg=slot offset value are not set to same for csi report and beam report.
    ${frame_period}    Evaluate    int(${csi_report_periodic_slot}/20)
    ${start_sfn}    Evaluate    int(math.floor(${reportSlotConfigOffset_list[0]}/20))     modules=math
    ${slot}    Evaluate    int(${reportSlotConfigOffset_list[0]}%20)
    ${csi_report_info_dict}     Create Dictionary    frame_period=${frame_period}
    ...                                              start_sfn=${start_sfn}
    ...                                              slot=${slot}
    ...                                              pucch_resource=${pucch_resource}
    Log to console     ${csi_report_info_dict}
    [Return]    ${csi_report_info_dict}

Check PCSI Multiplexing Function With Bip Log
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${bip_log_path}    ${csi_report_info_dict}    ${alias}=parser
    ${selected_slot}    Evaluate    hex(${csi_report_info_dict['slot']})
    ${filter_expression}    Catenate    UlData_PucchReceiveReq.PucchReceiveReq.slot == ${selected_slot}
    Convert Bip Pcap To Pdml    file_path=${bip_log_path}    filter=${filter_expression}    alias=${alias}
    ${nANPucch}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveReq.pucchResources_item_0.nANPucch
    ...                                            pcap_parser=${alias}
    ${numOfBitsOfUciInformation}    pcap.get_field_value_by_name
    ...    field_name=UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation
    ...    pcap_parser=${alias}
    ${PucchReceiveReq_sfn}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveReq.PucchReceiveReq.sfn
    ...                                                       pcap_parser=${alias}
    ${PucchReceiveReq_sfn}    Evaluate    [int(x,16) for x in ${PucchReceiveReq_sfn}]
    ${nANPucch}    Evaluate    [int(x,16) for x in ${nANPucch}]
    ${numOfBitsOfUciInformation}    Evaluate    [int(x,16) for x in ${numOfBitsOfUciInformation}]
    ${PucchReceiveReq_info}    Evaluate    list(zip(${PucchReceiveReq_sfn},${nANPucch},${numOfBitsOfUciInformation}))
    ${PucchReceiveReq_info_filter}    Evaluate    list(filter(lambda x:x[2]>x[1],${PucchReceiveReq_info}))
    ${sfn_lambda_expression}    Catenate    (x[0]-${csi_report_info_dict['start_sfn']})%${csi_report_info_dict['frame_period']}==${0}
    ${PucchReceiveReq_info_match_list}    Evaluate    list(filter(lambda x:${sfn_lambda_expression},${PucchReceiveReq_info_filter}))
    ${PucchReceiveReq_info_selected}    Evaluate     random.choice(${PucchReceiveReq_info_match_list})     modules=random
    ${selected_sfn}    Evaluate     hex(${PucchReceiveReq_info_selected[0]})
    ${pucch_req_filter_expression}    Catenate    UlData_PucchReceiveReq.PucchReceiveReq.slot == ${selected_slot} &&
    ...                                           UlData_PucchReceiveReq.PucchReceiveReq.sfn==${selected_sfn}
    ${pucch_resp_filter_expression}    Catenate    UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn==${selected_sfn} &&
    ...                                            UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot==${csi_report_info_dict['slot']}
    Convert Bip Pcap To Pdml    file_path=${bip_log_path}    filter=${pucch_resp_filter_expression}    alias=${alias}
    ${uciBits_item_0}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_0    pcap_parser=${alias}
    ${uciBits_item_1}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_1    pcap_parser=${alias}
    ${uciBits_item_2}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_2    pcap_parser=${alias}
    ${uciBits_item_3}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_3    pcap_parser=${alias}
    ${uciBits_item_4}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_4    pcap_parser=${alias}
    ${uciBits_item_5}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_5    pcap_parser=${alias}
    ${uciBits_item_6}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_item_6    pcap_parser=${alias}
    ${uciBits_item_7}    pcap.get_field_value_by_name    field_name=UlData_PucchReceiveRespPs.uciBits.uciBits_padding    pcap_parser=${alias}

Get Candidate Cell PCI List Reported By Enb
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ...            ${message_filter_expression}=nr-rrc.candidateCellInfoListMN && nr-rrc.physCellId && x2ap.procedureCode == 27
    ...            ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${candidate_cell_pci_list}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=${alias}
    log to console    candidate cell list reported by enb is :${candidate_cell_pci_list}
    [Return]    ${candidate_cell_pci_list}

# For CB008015 common keywords
Get All TDD-FDD Weighted Scell Bandwidth Value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Return:<list>:refer to keyword 'Sorted Weight Value'
    ...                Example:${all_scell_sorted_list} = [{u'3': {u'technology': u'TDD', u'weight': 80000.0}},
    ...                                               {u'4': {u'technology': u'TDD', u'weight': 40000.0}},
    ...                                               {u'0+2': {u'technology': u'FDD', u'weight': 30000.0}},
    ...                                               {'2': {'technology': 'FDD', 'weight': 20000.0}},
    ...                                               {'0': {'technology': 'FDD', 'weight': 10000.0}}]
    [Arguments]    ${pcell_index}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${tdd_scell_list}    Get Dictionary Keys   ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys   ${FDD_SCELL_MAPPING}
    &{tdd_scell_chbw_weight_dict}    Create Dictionary
    FOR    ${item}    IN    @{tdd_scell_list}
        &{tdd_scell_tech_dict}     Create Dictionary    technology=TDD
        ${chbw}    Set Variable    ${TDD_SCELL_MAPPING[${item}]['all_cell_info']['detail_cells_info']['chBw']}
        ${chbw}    Set Variable    ${chbw.split('M')[0]}
        Set To Dictionary    ${tdd_scell_tech_dict}    chbw   ${chbw}
        ${weightForSCellSelection}    Set Variable    ${TDD_SCELL_MAPPING[${item}]['all_cell_info']['weightForSCellSelection']}
        Set To Dictionary    ${tdd_scell_tech_dict}    weight    ${weightForSCellSelection}
        Set To Dictionary    ${tdd_scell_chbw_weight_dict}    ${item}    ${tdd_scell_tech_dict}
    END
    Set Test Variable   ${tdd_scell_chbw_weight_dict}
    &{fdd_scell_chbw_weight_dict}    Create Dictionary
    FOR    ${item}    IN    @{fdd_scell_list}
        &{fdd_scell_tech_dict}     Create Dictionary    technology=FDD
        ${chBwDl}    Set Variable    ${FDD_SCELL_MAPPING[${item}]['all_cell_info']['detail_cells_info']['chBwDl']}
        ${chBwDl}    Set Variable    ${chBwDl.split('M')[0]}
        Set To Dictionary    ${fdd_scell_tech_dict}    chbw    ${chBwDl}
        ${weightForSCellSelection}    Set Variable    ${FDD_SCELL_MAPPING[${item}]['all_cell_info']['weightForSCellSelection']}
        Set To Dictionary    ${fdd_scell_tech_dict}    weight    ${weightForSCellSelection}
        Set To Dictionary    ${fdd_scell_chbw_weight_dict}    ${item}    ${fdd_scell_tech_dict}
    END
    Set Test Variable   ${fdd_scell_chbw_weight_dict}
    ${all_scell_chbw_weight_dict}     Combine TDD-FDD Parameter    tdd_param_dict=${tdd_scell_chbw_weight_dict}
    ...                                                fdd_param_dict=${fdd_scell_chbw_weight_dict}
    Set Test Variable    ${all_scell_chbw_weight_dict}
    ${all_scell_sorted_list}    Get Weight Value In Sorted For All Scell
    ...                               all_scell_chbw_weight_dict=${all_scell_chbw_weight_dict}
    ...                               fdd_scell_chbw_weight_dict=${fdd_scell_chbw_weight_dict}
    Set Test Variable    ${all_scell_sorted_list}

Combine TDD-FDD Parameter
   [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
   ...                Params:<dict>,${tdd_param_dict},tdd cell info dect,${fdd_param_dict},fdd cell info dect.
   [Arguments]     ${tdd_param_dict}    ${fdd_param_dict}
    &{all_scell_params}    Create Dictionary
    ${tdd_scell_list}     Get Dictionary Keys    ${tdd_param_dict}
    FOR    ${item}    IN    @{tdd_scell_list}
         Set To Dictionary    ${all_scell_params}    ${item}    ${tdd_param_dict[${item}]}
    END
    ${fdd_scell_list}     Get Dictionary Keys    ${fdd_param_dict}
    FOR    ${item}    IN    @{fdd_scell_list}
         Set To Dictionary    ${all_scell_params}    ${item}    ${fdd_param_dict[${item}]}
    END
    [Return]    ${all_scell_params}

Get Weight Value In Sorted For All Scell
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...            Params:<dict>, ${all_scell_chbw_weight_dict}
    ...            Example:${all_scell_chbw_weight_dict} = {1: {'chbw': '15', 'technology': 'FDD', 'weight': b'10'},
    ...                                                     2: {'chbw': '20', 'technology': 'FDD', 'weight': b'30'},
    ...                                                     3: {'chbw': '100', 'technology': 'TDD', 'weight': b'10'},
    ...                                                     4: {'chbw': '40', 'technology': 'TDD', 'weight': b'10'}}
    ...                    ${fdd_scell_chbw_weight_dict} = {1: {'chbw': '15', 'technology': 'FDD', 'weight': b'10'},
    ...                                                     2: {'chbw': '20', 'technology': 'FDD', 'weight': b'30'}}
    ...           Return:<list>:refer to keyword 'Sorted Weight Value'
    ...           Example:${all_scell_sorted_list} = [{u'3': {u'technology': u'TDD', u'weight': 80000.0}},
    ...                                               {u'4': {u'technology': u'TDD', u'weight': 40000.0}},
    ...                                               {u'0+2': {u'technology': u'FDD', u'weight': 30000.0}},
    ...                                               {'2': {'technology': 'FDD', 'weight': 20000.0}},
    ...                                               {'0': {'technology': 'FDD', 'weight': 10000.0}}]
    [Arguments]    ${all_scell_chbw_weight_dict}    ${fdd_scell_chbw_weight_dict}
    ${all_scell_weight_value_dict}    Calculate Weight Value    calculate_params_dict=${all_scell_chbw_weight_dict}
    ${pcell_technology}    Set Variable    ${PCELL_MAPPING['detail_cells_info']['technology']}
    ${fdd_scell_sorted_weight_key}    Get Dictionary Keys    ${fdd_scell_chbw_weight_dict}
    ${fdd_scell_length}     Get Length    ${fdd_scell_sorted_weight_key}
    ${all_evaluate_fdd_scell_weight_value_dict}    Run Keyword If    "${pcell_technology}" == "FDD" and ${fdd_scell_length} != 0
    ...                                            Evaluate FDD Scell Weight Value
    ...                                            all_scell_weight_value_dict=${all_scell_weight_value_dict}
    ...                                            fdd_scell_chbw_weight_dict=${fdd_scell_chbw_weight_dict}
    ${all_scell_weight_value_dict}    Set Variable If    '${pcell_technology}'=='FDD' and ${fdd_scell_length} != 0
    ...    ${all_evaluate_fdd_scell_weight_value_dict}    ${all_scell_weight_value_dict}
    ${all_scell_sorted_list}    Sorted Weight Value    cell_weight_value_dict=${all_scell_weight_value_dict}
    [Return]     ${all_scell_sorted_list}

Evaluate FDD Scell Weight Value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${all_scell_weight_value_dict}    ${fdd_scell_chbw_weight_dict}
    ${fdd_scell_sorted_weight_key}    Get Dictionary Keys    ${fdd_scell_chbw_weight_dict}
    ${fdd_scell_added_index}    Create List
    ${fdd_scell_added_values}    Set variable    0
    FOR    ${item}    IN    @{fdd_scell_sorted_weight_key}
        ${item}    Convert To String    ${item}
        Append To List    ${fdd_scell_added_index}    ${item}
        ${fdd_scell_added_values}    Evaluate   ${fdd_scell_added_values}+${all_scell_weight_value_dict[${item}]['weight']}
    END
    ${fdd_scell_added_index}    Evaluate    "+".join(${fdd_scell_added_index})
    &{fdd_scell_added_dict}    Create Dictionary    technology=FDD    weight=${fdd_scell_added_values}
    Set To Dictionary    ${all_scell_weight_value_dict}    ${fdd_scell_added_index}    ${fdd_scell_added_dict}
    [Return]     ${all_scell_weight_value_dict}

Calculate Weight Value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...            params:<dict>,${calculate_params_dict}
    ...            Exmple:${calculate_params_dict} = {1: {'chbw': '15', 'technology': 'FDD', 'weight': b'10'},
    ...                                              2: {'chbw': '20', 'technology': 'FDD', 'weight': b'30'},
    ...                                              3: {'chbw': '100', 'technology': 'TDD', 'weight': b'10'},
    ...                                              4: {'chbw': '40', 'technology': 'TDD', 'weight': b'10'}}
    ...            Return:<dict>: ${all_cell_weight_value_dict} = {1: {'technology': 'FDD', 'weight': 15000.0},
    ...                                                            2: {'technology': 'FDD', 'weight': 60000.0},
    ...                                                            3: {'technology': 'TDD', 'weight': 100000.0},
    ...                                                            4: {'technology': 'TDD', 'weight': 40000.0}}
    [Arguments]    ${calculate_params_dict}    ${ue_number}=1
    &{all_cell_weight_value_dict}    Create Dictionary
    ${cell_index}    Get Dictionary Keys    ${calculate_params_dict}
    FOR    ${item}    IN    @{cell_index}
        &{cell_weight_value_dict}    Create Dictionary
        ${value}    Evaluate    float((${calculate_params_dict[${item}]['chbw']}*${calculate_params_dict[${item}]['weight']}*100)/(${ue_number}+1))
        Set To Dictionary    ${cell_weight_value_dict}    technology=${calculate_params_dict[${item}]['technology']}    weight=${value}
        Set To Dictionary    ${all_cell_weight_value_dict}    ${item}    ${cell_weight_value_dict}
    END
    [Return]    ${all_cell_weight_value_dict}

Sorted Weight Value
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Params:<dict>,${cell_weight_value_dict}
    ...                Exmple:${cell_weight_value_dict}={1: {'technology': 'FDD', 'weight': 15000.0},
    ...                                                  2: {'technology': 'FDD', 'weight': 20000.0},
    ...                                                  3: {'technology': 'TDD', 'weight': 80000.0},
    ...                                                  4: {'technology': 'TDD', 'weight': 40000.0}}
    ...                Return:<list>,return list in sorted based on 'weight',
    ...                Exmple:${sorted_cell_weight_value_list} =  [{3, {'technology': 'TDD', 'weight': 80000.0}},
    ...                                                            {4, {'technology': 'TDD', 'weight': 40000.0}},
    ...                                                            {2, {'technology': 'FDD', 'weight': 20000.0}},
    ...                                                            {1, {'technology': 'FDD', 'weight': 15000.0}}]
    [Arguments]    ${cell_weight_value_dict}
#    ${sorted_cell_weight_value_tuple_list}    Evaluate    sorted(${cell_weight_value_dict.items()},key=lambda x:x[1]['weight'],reverse=True)
    ${sorted_cell_weight_value_tuple_list}    Evaluate    sorted(${cell_weight_value_dict}.items(),key=lambda x:x[1]['weight'],reverse=True)
    @{sorted_cell_weight_value_list}    Create List
    FOR    ${item}    IN    @{sorted_cell_weight_value_tuple_list}
        ${item_key}    convert to string    ${item[0]}
        ${sorted_cell_weight_value_dict}    Create Dictionary    ${item_key}=${item[1]}
        Append to List    ${sorted_cell_weight_value_list}    ${sorted_cell_weight_value_dict}
    END
    [Return]    ${sorted_cell_weight_value_list}

Get Scell Index List from weighted scell bandwidth list
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${index_in_sorted_scell_weight_list}
     ${current_scell_weight_dict}    set variable    ${all_scell_sorted_list[${index_in_sorted_scell_weight_list}]}
     ${combined_scell_index}    Get Dictionary Keys 	${current_scell_weight_dict}
     ${scell_technology}    set variable    ${current_scell_weight_dict['${combined_scell_index[0]}']['technology']}
     ${scell_index_list}    evaluate    '${combined_scell_index[0]}'.split("+")
     [Return]    ${scell_index_list}    ${scell_technology}

Get Scell PCI List From Scell Index List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${index_in_sorted_scell_weight_list}=0
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${pcell_index}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...    index_in_sorted_scell_weight_list=${index_in_sorted_scell_weight_list}
    @{scell_pci_list}    Create List
    @{scell_index_list_int}    Create List
    FOR    ${item}    IN    @{scell_index_list}
        ${item}    Evaluate    int(${item})
        ${scell_pci}    Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${scell_pci_list}    ${scell_pci}
        Append to List    ${scell_index_list_int}    ${item}
    END
    Set Test Variable    ${SCELL_INDEX_LIST}    ${scell_index_list_int}
    Set Test Variable    ${SCELL_PCI_LIST}    ${scell_pci_list}
    Set Test Variable    ${SCELL_TECHNOLOGY}    ${scell_technology}

Check Scell Activation Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check scell addition success via syslog:btslog or aasyslog
    [Arguments]    ${log_path}
    ${output}    Filter Element On Syslog    log_path=${log_path}    syslog_filter_pattern=handleMacCe\\s+done.*sCellMask:0x6
    Should Not Be Empty    ${output}    msg=scell activation failed
    ${active_time}    Get Regexp Matches   ${output}    <(\\d+-\\d+-\\d+)T(\\d+:\\d+:\\d+).*    1    2
    log to console    scell activation time is ${active_time}

Get DL Tput Layers From Wireshark
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    ...                only valid for 2200 cable connection and tdd cell.
    [Arguments]    ${cpif_log_path}    ${mode}=SA    ${alias}=parser    ${addition_method}=A1    ${is_handover}=${None}
    ...            ${whether_8311_feature_enable}=${False}    ${scell_cpif_log_path}=${None}
    ${dl_tput_layers}    Create Dictionary
    ${pcell_message_filter_expression}    Set Variable If    '${is_handover}'=='${None}'    ${${mode}_RRC_RECONFIGURE_FILTER_ATTACH}
    ...                                                      '${is_handover}'=='Inter'    ${${mode}_INTER_HO_RRC_RECONFIGURE_FILTER}
    ...                                                      '${is_handover}'=='Intra'    ${${mode}_RRC_RECONFIGURE_FILTER_HANDOVER}
    ${scell_message_filter_expression}    Set Variable If    '${mode}'=='SA'    ${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...    ${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    ${scell_cpif_log}    Set Variable If    ${whether_8311_feature_enable}    ${scell_cpif_log_path}    ${cpif_log_path}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${pcell_message_filter_expression}    alias=${alias}
    ${pcell_csirs_ports}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.nrofPorts
    ...    pcap_parser=${alias}
    ${pcell_p8_port_number}    Get Match Count    ${pcell_csirs_ports}    3
    ${pcell_layer}    Set Variable If    ${pcell_p8_port_number}>=${2}    4    2
    Convert CPIF Pcap To Pdml    file_path=${scell_cpif_log}    filter=${scell_message_filter_expression}    alias=${alias}
    ${xpath1}    Set Variable If    ${whether_8311_feature_enable}    .//nr-rrc.physCellId
    ...    .//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ${xpath2}    Set Variable If    ${whether_8311_feature_enable}    .//nr-rrc.nrofPorts
    ...    .//nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.nrofPorts
    ${scell_pci}    pcap.get_field_value_by_xpath    xpath=${xpath1}    pcap_parser=${alias}
    ${scell_resourcetoaddmodList_items}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nzp_CSI_RS_ResourceToAddModList
    ...    pcap_parser=${alias}
    ${scell_csirs_ports}    pcap.get_field_value_by_xpath    xpath=${xpath2}    pcap_parser=${alias}
    ${scell_tput_layers}    Create Dictionary
    ${start_index}    Set Variable    ${0}
    ${scell_number}    Get Length    ${scell_pci}
    FOR    ${index}    IN RANGE    0   ${scell_number}
        ${resource_items}    Set Variable    ${scell_resourcetoaddmodList_items[${index}]}
        ${end_index}    Evaluate    ${start_index}+${resource_items}
        ${scell_csirs_port}    Set Variable    ${scell_csirs_ports[${start_index}:${end_index}]}
        ${start_index}    Evaluate    ${start_index}+${resource_items}
        ${scell_p8_port_number}    Get Match Count   ${scell_csirs_port}    3
        ${scell_layer}    Set Variable If    ${scell_p8_port_number}>=${2}    4    2
        set to dictionary    ${scell_tput_layers}    ${scell_pci[${index}]}    ${scell_layer}
    END
    set to dictionary     ${dl_tput_layers}    pcell=${pcell_layer}    scell=${scell_tput_layers}
    Set Test Variable    ${dl_pcell_layer}    ${dl_tput_layers['pcell']}
    Set Test Variable    ${dl_scell_layer}    ${dl_tput_layers['scell']}
    [Return]    ${dl_tput_layers}

Get Swap Scell DL Tput Layers From Wireshark
    [Documentation]    Auther:li.su@nokia-sbell.com
    ...                only valid for 2200 cable connection and tdd cell.
    [Arguments]    ${cpif_log_path}    ${mode}=SA    ${alias}=parser    ${addition_method}=A1
    ${dl_tput_layers}    Create Dictionary
    ${scell_message_filter_expression}    Set Variable If    '${mode}'=='SA'    ${SA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION}
    ...    ${NSA_RRC_RECONFIGURE_FILTER_SCELL_ADDITION_${addition_method}}
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${scell_message_filter_expression}    alias=${alias}
    ${scell_pci}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ...    pcap_parser=${alias}
    ${scell_resourcetoaddmodList_items}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nzp_CSI_RS_ResourceToAddModList
    ...    pcap_parser=${alias}
    ${scell_csirs_ports}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.nrofPorts
    ...    pcap_parser=${alias}
    ${scell_tput_layers}    Create Dictionary
    ${start_index}    Set Variable    ${0}
    ${scell_number}    Get Length    ${scell_pci}
    FOR    ${index}    IN RANGE    0   ${scell_number}
        ${resource_items}    Set Variable    ${scell_resourcetoaddmodList_items[${index}]}
        ${end_index}    Evaluate    ${start_index}+${resource_items}
        ${scell_csirs_port}    Set Variable    ${scell_csirs_ports[${start_index}:${end_index}]}
        ${start_index}    Evaluate    ${start_index}+${resource_items}
        ${scell_p8_port_number}    Get Match Count   ${scell_csirs_port}    3
        ${scell_layer}    Set Variable If    ${scell_p8_port_number}>=${2}    4    2
        set to dictionary    ${scell_tput_layers}    ${scell_pci[${index}]}    ${scell_layer}
    END
    set to dictionary     ${dl_tput_layers}    scell=${scell_tput_layers}
    Set Test Variable    ${dl_swap_scell_tput_layers}    ${dl_tput_layers['scell']}
    [Return]    ${dl_swap_scell_tput_layers}

Compare Throughput During Handover
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${after_ho_tupt}    ${before_ho_tupt}
    ${pcell_values_before}    Get Dictionary Values    ${before_ho_tupt['tput_dict']['pcell']}
    ${pcell_values_after}    Get Dictionary Values    ${after_ho_tupt['tput_dict']['pcell']}
    ${scell_values_before}    Get Dictionary Values    ${before_ho_tupt['tput_dict']['scell']}
    ${scell_values_after}    Get Dictionary Values    ${after_ho_tupt['tput_dict']['scell']}
    ${pcell_dl_compare}    Evaluate    (${pcell_values_before}[0]-${pcell_values_after}[0])/${pcell_values_before}[0]
    ${pcell_ul_compare}    Evaluate    (${pcell_values_before}[1]-${pcell_values_after}[1])/${pcell_values_before}[1]
    ${scell_compare}    Evaluate    (${scell_values_before}[0]-${scell_values_after}[0])/${scell_values_before}[0]
    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_compare}<=0.10    msg=pcell dl tupt reduced exceed 10%.
    Run Keyword And Continue On Failure    Should Be True    ${pcell_ul_compare}<=0.20    msg=pcell ul tupt reduced exceed 20%.
    Should Be True    ${scell_compare}<=0.10    msg=scell tupt reduced exceed 10%.

Compare Throughput During Handover For DL
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${after_ho_tupt}    ${before_ho_tupt}
    ${pcell_values_before}    Get Dictionary Values    ${before_ho_tupt['tput_dict']['pcell']}
    ${pcell_values_after}    Get Dictionary Values    ${after_ho_tupt['tput_dict']['pcell']}
    ${scell_values_before}    Get Dictionary Values    ${before_ho_tupt['tput_dict']['scell']}
    ${scell_values_after}    Get Dictionary Values    ${after_ho_tupt['tput_dict']['scell']}
    ${pcell_dl_compare}    Evaluate    (${pcell_values_before}[0]-${pcell_values_after}[0])/${pcell_values_before}[0]
    ${scell_compare}    Evaluate    (${scell_values_before}[0]-${scell_values_after}[0])/${scell_values_before}[0]
    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_compare}<=0.10    msg=pcell dl tupt reduced exceed 10%.
    Should Be True    ${scell_compare}<=0.10    msg=scell tupt reduced exceed 10%.

Capture Snapshot If Case Failed
    Connect to gnb coam via ssl    connection=GNB_OAM0  gnb_index=0
    run keyword and ignore error    run keyword if test failed
    ...    COAM Save snapshot via rest api    connection=GNB_OAM0    timeout=30min
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0

Capture Snapshot For Target Gnb
    Connect to gnb coam via ssl    connection=GNB_OAM1  gnb_index=1
    run keyword and ignore error    run keyword if test failed
    ...    COAM Save snapshot via rest api    connection=GNB_OAM1    timeout=30min
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM1
