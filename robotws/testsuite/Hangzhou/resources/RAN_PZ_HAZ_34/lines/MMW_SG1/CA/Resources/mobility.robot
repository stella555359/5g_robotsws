*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1

Resource    ../../common_resources.robot
Resource    ./CA_keywords.robot
Library    taf.analyzer.pcap    WITH NAME    pcap
Variables   ../TestData/msg_checkpoint.py

*** Keywords ***
Get reportConfigId for special measEvent in cpif log
    [Documentation]    author: Dandan Fang
    ...    try to find each eventId's reportId, which measId is equal.
    ...    Maybe just suitable for "each event just have 1 reportConfig", for example 1 A1 event for 1 cell
    ...    Or 1 A1 event, 1 A3 event.
    [Arguments]     ${measEvent}=None      ${log_path_pcap}=${CPIF_LOG}
    ${filter}    set variable     (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.ReportConfigToAddMod_element)
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}
    ${reportId_xpath}  catenate    SEPARATOR=${EMPTY}     .//*/nr-rrc.${measEvent}_element/ancestor::nr-rrc.reportConfig/
    ...                preceding-sibling::nr-rrc.reportConfigId
    ${report_Id}    pcap.get_field_value_by_xpath        xpath=${reportId_xpath}      attribute_name=show
    [Return]    ${report_Id[${0}]}

Get RSRP in measurment report in cpif log
    [Documentation]    author: Cui Lingxue
    [Arguments]    ${meas_id}    ${log_path_pcap}=${CPIF_LOG}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 13) && (f1ap.F1AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    pcap.setup     infile=${log_path_pcap}    display_filter=${filter}
    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.measResultServingMOList//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
    ...    attribute_name=show
    [Return]    ${rsrp[0]}

Verify A2 measurement report in cpif log
    [Documentation]    author: Cui Lingxue
    [Arguments]    ${a2_rsrp_thres}=${A2_THRES_HO_SSB_RSRP_SA}    ${log_path_pcap}=${CPIF_LOG}   ${meas_id}=${A2_MEAS_ID}
    ${a2_rsrp}    Get RSRP in measurment report in CPIF log    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}
    should be true    ${a2_rsrp} <= ${a2_rsrp_thres}

Verify A1 measurement report in cpif log
    [Documentation]    author: Cui Lingxue
    [Arguments]    ${a1_rsrp_thres}=${A1_THRES_HO_SSB_RSRP_SA}    ${log_path_pcap}=${CPIF_LOG}  ${meas_id}=${A1_MEAS_ID}
    ${a1_rsrp}    Get RSRP in measurment report in CPIF log    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}
    should be true    ${a1_rsrp} >= ${a1_rsrp_thres}

Verify a2 measurement config in cpif log
    [Documentation]    author: Cui Lingxue
    [Arguments]    ${a2_meas_config}    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}

    ${rrcReconfig}    pcap.filter_packets_by_expression
    ...    filter_expression=(f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 1)
    ${ssbFreq}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.measObjectNR_element/nr-rrc.ssbFrequency
    ...    attribute_name=show
    ${a2MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...    attribute_name=showname
    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.measQuantityResults.rsrp
    ...    attribute_name=show

    ${hysteresis}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a2MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${A2_THRES_HO_SSB_RSRP_SA}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${A2_HYS_SSB_RSRP_SA}    ${hysteresis[0]}
    should be equal as strings    ${A2_TIME_TO_TRIGGER}    ${timeToTrigger[0].split()[1]}

Verify a1 measurement config in cpif log
    [Arguments]    ${a1_meas_config}    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 0)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a1MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold
    ...    attribute_name=showname
    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.measQuantityResults.rsrp
    ...    attribute_name=show
    ${hysteresis}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a1MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${A1_THRES_HO_SSB_RSRP_SA}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${A1_HYS_SSB_RSRP_SA}    ${hysteresis[0]}
    should be equal as strings    ${A1_TIME_TO_TRIGGER}    ${timeToTrigger[0].split()[1]}

Verify a3 measurement config in cpif log
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 2)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a3MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.a3_Offset
    ...    attribute_name=showname
#    ${rsrp}    pcap.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.a3_Offset/nr-rrc.rsrp
#    ...    attribute_name=show
    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.a3_Offset/nr-rrc.measTriggerQuantityOffset.rsrp
    ...    attribute_name=show

    ${hysteresis}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a3MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${A3_OFFSET_SSB_RSRP}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${A3_HYS_SSB_RSRP_SA}    ${hysteresis[0]}
    should be equal as strings    ${A3_TIME_TO_TRIGGER}    ${timeToTrigger[0].split()[1]}

Verify measurement gap in cpif log
    [Arguments]    ${meas_gap}    ${log_path_pcap}=${CPIF_LOG}
    ${meas_gap}    Convert scf parameters to dict type    scf_parameter_list=${meas_gap}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 2)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${mgta}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.mgta
    ...    attribute_name=showname
    ${gapOffset}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.gapOffset
    ...    attribute_name=show

    run keyword and continue on failure    run keyword if    '${meas_gap['mgta']}'=='msdot5'
    ...    should be equal as strings    ms0dot5    ${mgta[0].split()[1]}
    ...    ELSE    should be equal as strings    ${meas_gap['mgta']}    ${mgta[0].split()[1]}
    should be equal as strings    ${meas_gap['gapOffset']}    ${gapOffset[0]}

Verify drx config setup in cpif log
    [Documentation]    author: Wang Yixiang
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=f1ap
    ${filter}    set variable    f1ap.procedureCode == 7
    ${UeCxtModResp}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${drx_config}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.CellGroupConfig_element//*//nr-rrc.drx_Config
    ...    attribute_name=showname
    should be equal as strings    ${drx_config[-1]}    drx-Config: setup (1)

Verify drx config release after measurement gap in cpif log
    [Documentation]    author: Wang Yixiang
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    nr-rrc && (f1ap.procedureCode == 12)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${drx_config}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//*//nr-rrc.drx_Config
    ...    attribute_name=showname
    run keyword and continue on failure    should be equal as strings    ${drx_config[-1]}    drx-Config: release (0)

Verify measurement gap release after A1 report
    [Documentation]    author: Wang Yixiang
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    nr-rrc && (f1ap.procedureCode == 12)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${gap_config}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//*//nr-rrc.gapUE
    ...    attribute_name=showname
    run keyword and continue on failure    should be equal as strings    ${gap_config[-1]}    gapUE: release (0)


Trigger A2 and verify config of A1 A3 A5 and drx release and csi report
    [Documentation]    Author: Wang Yixiang
    ...    Trigger A1,A2,A3,A5 measurement report and capture tcpdump log
    ...    ${A2_MEAS_ID}    1
    ...    ${A1_MEAS_ID}    2
    ...    ${A3_MEAS_ID}    3
    ...    ${A5_MEAS_ID}    4
    [Arguments]    ${tcpdump_log_name}=A2_trigger
    ...            ${log_path}=${TS_CASE_LOG_PATH}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A2 measurement report
    Adjust attenuator to trigger A2 measurement report
    sleep    5s    msg=Wait for UE send measurement report.
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    ${is_mea_rep_triggered}    Run keyword and return status   Verify A2 measurement report in cpif log
    ...    log_path_pcap=${ute_log_path}
    should be equal as strings   ${is_mea_rep_triggered}     ${True}

    Bip Capture with gnbMirroring scripts with retry    add_mirror_port=true    bb_slot_1=true    bb_slot_2=true
    sleep   60s
    ${bip_log_pusch_list}   Stop BIP capture on ASIK if needed and download BIP Logs to testPC

    run keyword and continue on failure
    ...            Verify a1 measurement config in cpif log   a1_meas_config=${SCF_PCELL_HO_A1_MEAS_CONFIG}    log_path_pcap=${ute_log_path}
    run keyword and continue on failure
    ...            Verify a3 measurement config in cpif log    log_path_pcap=${ute_log_path}
    run keyword and continue on failure
    ...            Verify measurement gap in cpif log    meas_gap=${SCF_PCELL_MEAS_GAP}    log_path_pcap=${ute_log_path}
    run keyword and continue on failure
    ...            Verify drx config release after measurement gap in cpif log    log_path_pcap=${ute_log_path}
    # todo: temprary ignore error csi checking due to CSI report position changes frequently. Will refactor checking method.
    ${csi_check_result}    run keyword and return status
    ...            Check csi report conflict with meas gap in biplog    tcpdump_log=${bip_log_pusch_list[0]}
    [Return]    ${csi_check_result}

Trigger A1 and verify config of A2 and measurement gap release and drx setup
    [Documentation]    Author: Wang Yixiang
    ...    Trigger A1,A2,A3,A5 measurement report and capture tcpdump log
    ...    ${A2_MEAS_ID}    1
    ...    ${A1_MEAS_ID}    2
    ...    ${A3_MEAS_ID}    3
    ...    ${A5_MEAS_ID}    4
    [Arguments]    ${tcpdump_log_name}=A1_trigger
    ...            ${log_path}=${TS_CASE_LOG_PATH}
    ...            ${attenuator_index}=${0}
    Connect to Attenuator     attenuator_index=${attenuator_index}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A1 measurement report
    Initialize attenuator for specified RU    exp_pa_value=${INIT_PA_VALUE_${MRBTS_ID}}    ru_index=${PCELL_RU_INDEX}
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    ${is_mea_rep_triggered}   Run keyword and return status   Verify A1 measurement report in cpif log
    ...    log_path_pcap=${ute_log_path}
    should be equal as strings   ${is_mea_rep_triggered}     ${True}
    run keyword and continue on failure
    ...    Verify a2 measurement config in cpif log    a2_meas_config=${SCF_PCELL_HO_A2_MEAS_CONFIG}    log_path_pcap=${ute_log_path}
    run keyword and continue on failure
    ...        Verify measurement gap release after A1 report    log_path_pcap=${ute_log_path}
    run keyword and continue on failure
    ...            Verify drx config setup in cpif log    log_path_pcap=${ute_log_path}

Verify TPUT not change a lot before and after
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${tput_info_before}    ${tput_info_after}    ${offset}=50
    ${ret}   evaluate    abs(${tput_info_before['dl_tput_peak_all_cells_avg']}-${tput_info_after['dl_tput_peak_all_cells_avg']})
    run keyword and continue on failure    should be true   ${ret}<${offset}
    ...    msg=The tput gap of before measurement gap and after measurement gap is too big, pls check.

Verify TPUT change before and after measurement gap
    [Documentation]    Author: Cui Lingxue
    ...    Compare before and after tput info of each cell, the ratio of after_tput/before_tput should be close to an expected ratio with
    ...    ${allowed_error} in percentage unit.
    [Arguments]    ${tput_info_before}    ${tput_info_after}    ${expected_ratio}    ${cell_id}=${PCELL_ID},${SCELL_ID}    ${allowed_error}=5
    ${expected_ratio}    string2list    ${expected_ratio}
    ${cell_id}    string2list    ${cell_id}
    ${number_of_cells}    evaluate    len(${cell_id})

    FOR    ${i}    IN RANGE    ${number_of_cells}
        ${cur_cell_id}    set variable    ${cell_id[${i}]}
        ${cur_expected_ratio}    set variable    ${expected_ratio[${i}]}
        ${actual_ratio}    evaluate   float(${tput_info_after['${cur_cell_id}']['dl_max_tput']}/${tput_info_before['${cur_cell_id}']['dl_max_tput']})
        ${ret}    evaluate    abs(1- ${actual_ratio}/${cur_expected_ratio})*100
        run keyword and continue on failure    should be true    ${ret} <= ${allowed_error}
    END

UE attach check CA and DRX
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${4G_check}=False    ${tcpdump_log_name}=ue_attach
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${4G_check}
    ${ue_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and ignore error    Get Cell Pci And UE Rnti In Tcpdump    tcpdump_log=${ue_attach_log}
    run keyword and continue on failure    Verify drx config setup in cpif log    log_path_pcap=${ue_attach_log}
    run keyword and continue on failure    Check Scell addition in tcpdump log    tcpdump_log=${ue_attach_log}

Check csi report conflict with meas gap in biplog
    [Documentation]    Author: Wang Yixiang
    ...    on slot 5 => csi report for Pcell, slot5 conflict with measurement gap, should not report
    ...    on slot6 => csi report Scell, slot 6 no conlict with measurement gap, should report
    [Arguments]    ${tcpdump_log}
    ${slot_list_ret}    create list
    ${sfn_list_slot6}    create list

    # set up filters for pusch/pucch uci ie
    ${filter_pucch_pusch}   set variable    uldata_puschreceiverespps || uldata_pucchreceiverespps
    ${filter_uci_item0}   create list    UlData_PuschReceiveRespPs.uciCsiPart1Bits.uciCsiPart1Bits_item_0  # leading 2 digits of uci
    ...    UlData_PucchReceiveRespPs.uciBits.uciBits_item_0
    ${filter_uci_item1}   create list    UlData_PuschReceiveRespPs.uciCsiPart1Bits.uciCsiPart1Bits_item_1  # the sec 2 digits of uci
    ...    UlData_PucchReceiveRespPs.uciBits.uciBits_item_1
    ${filter_slot}   create list    UlData_PuschReceiveRespPs.PuschReceiveRespPs.slot    UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot
    ${filter_sfn}    create list    UlData_PuschReceiveRespPs.PuschReceiveRespPs.sfn     UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn

    # get list of all uci bits, sfn/slot
    ${pdml_list}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     lua_script=${LUA_SCRIPT_PATH}
    ...    filter=${filter_pucch_pusch}
    ${uci_item0_list}    create list
    ${uci_item1_list}    create list
    ${slot_list}         create list
    ${sfn_list}          create list
    FOR    ${i}    IN RANGE    ${2}
        ${cur_uci_item0_list}    pcap.get_field_value_by_xpath
        ...    xpath=.//${filter_uci_item0[${i}]}   attribute_name=show
        ${cur_uci_item1_list}    pcap.get_field_value_by_xpath
        ...    xpath=.//${filter_uci_item1[${i}]}   attribute_name=show
        ${cur_slot_list}    pcap.get_field_value_by_xpath
        ...    xpath=.//${filter_slot[${i}]}   attribute_name=show
        ${cur_sfn_list}    pcap.get_field_value_by_xpath
        ...    xpath=.//${filter_sfn[${i}]}   attribute_name=show
         ${uci_item0_list}   combine lists    ${uci_item0_list}    ${cur_uci_item0_list}
         ${uci_item1_list}   combine lists    ${uci_item1_list}    ${cur_uci_item1_list}
        ${slot_list}         combine lists    ${slot_list}         ${cur_slot_list}
        ${sfn_list}          combine lists    ${sfn_list}          ${cur_sfn_list}
    END

    # convert hex data to binary data
    ${uci_item0_list}    Evaluate    map(lambda x: bin(int(x, 16)), ${uci_item0_list})
    ${uci_item1_list}    Evaluate    map(lambda x: bin(int(x, 16)), ${uci_item1_list})
    ${slot_list}    Evaluate    map(lambda x: str(int(x, 16)), ${slot_list})
    ${sfn_list}    Evaluate    map(lambda x: str(int(x, 16)), ${sfn_list})

    # verify if uci contain CSI, if yes, log CSI report slot to list
    FOR    ${index}    ${slot_num}    IN ENUMERATE    @{slot_list}
        ${sfn_slot_dict}    create dictionary    # not used?
        ${uci_item0_value}    set variable    ${uci_item0_list}[${index}]
        ${uci_item0_value}    strip_string    string=${uci_item0_value}    mode=left    characters=0b
        ${uci_item1_value}    set variable    ${uci_item1_list}[${index}]
        ${uci_item1_value}    strip_string    string=${uci_item1_value}    mode=left    characters=0b
        ${sfn_value}    set variable    ${sfn_list}[${index}]
        ${slot_num}     set variable    ${slot_list}[${index}]
        ${uci_bit_str}    set variable    ${uci_item0_value}${uci_item1_value}
        ${uci_bit_str}    Get Substring    ${uci_bit_str}    3    -1
        ${uci_bits_count}    Get Count    ${uci_bit_str}    1    # if more than 1 bit is non-zero, then this packet is taken as CSI/Beam report.
        continue for loop if    ${uci_bits_count}==0
        run keyword if    '${slot_num}'=='6'    append to list    ${sfn_list_slot6}    ${sfn_value}   # mark slot6 for calculate csi cycle.
        append to list    ${slot_list_ret}    ${slot_num}
    END

    run keyword and continue on failure
    ...    List Should Contain Value     ${slot_list_ret}    6    msg=CSI slot6 not conflict with meas gap, should report
    run keyword and continue on failure
    ...    List Should Contain Value     ${slot_list_ret}    5    msg=CSI slot5 not conflict with meas gap, should report


Modify maxNumOfUsers to 0 on target gNB
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${connection}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${delta_file_list_reverse}    Modification of NIDD parameters via restapi    param_to_upd=${RESTAPI_maxNumOfUsersPerCell}
    ...    timeout=${timeout}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}    connection=${connection}
    ...    is_need_to_setup_gnb_connection=${False}
    ...    is_enb_status_check_needed=${False}
    ...    is_x2_check_from_enb_needed=${False}
    ...    is_all_cells_checking_needed=${True}
    [Return]    ${delta_file_list_reverse}

Restore maxNumOfUsers on target gNB
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${delta_file_list_reverse}    ${connection}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    Restore NIDD parameters to original value via restapi    delta_file_list_reverse=${delta_file_list_reverse}    connection=${connection}
    ...    timeout=${timeout}

Adjust attenuator to trigger A2 measurement report
    [Documentation]    Author: Cui Lingxue
    ...    ${A2_MEAS_PA_VALUE_${MRBTS_ID}} and ${PCELL_RU_INDEX_${MRBTS_ID}} are defined in CA_variables.robot
    [Arguments]    ${gnb_index}=${0}    ${ru_index}=${PCELL_RU_INDEX}
    log to console    Start to trigger A2 measure report......
    _set attenuator ports of specified RU to same value    exp_pa_value=${A2_MEAS_PA_VALUE_${MRBTS_ID}}
    ...    gnb_index=${gnb_index}    ru_index=${ru_index}

Verify inter-gNB handover
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${log_path_source}    ${log_path_target}    ${intra_freq}    ${ca_enabled}=${True}
    ${msg_checkpoint_src}    set variable if    '${intra_freq}'=='${True}'    ${SA_INTRA_FREQ_INTER_GNB_HO_SRC}  ${SA_INTER_FREQ_INTER_GNB_HO_SRC}
    ${msg_checkpoint_tgt}    set variable if    '${intra_freq}'=='${True}'    ${SA_INTRA_FREQ_INTER_GNB_HO_TGT}  ${SA_INTER_FREQ_INTER_GNB_HO_TGT}

    run keyword and continue on failure    Verify msgs type and detail IEs in sequence in tcpdump log
    ...    msg_checkpoint=${msg_checkpoint_src}    log_path_pcap=${log_path_source}    detail_ie_filters=${None}
    Verify msgs type and detail IEs in sequence in tcpdump log  msg_checkpoint=${msg_checkpoint_tgt}  log_path_pcap=${log_path_target}
    ...    detail_ie_filters=${None}

    run keyword and continue on failure    Check msg item in tcpdump    tcpdump_log=${log_path_source}    msg_file=${CURDIR}/DRX_release.txt
    run keyword if    '${ca_enabled}'=='${True}'
    ...    Check msg item in tcpdump    tcpdump_log=${log_path_source}    msg_file=${CURDIR}/Scell_release.txt


Enable cplane debug log on gNB
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    ${cmd_enable_debug_log}  set variable  echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini; chmod a+r /ffs/run/cp_runtime.ini
    ssh.send_command    command=${cmd_enable_debug_log}    connection=${asik_alias}
    ssh.send_command    command=cat /ffs/run/cp_runtime.ini    connection=${asik_alias}
    ${is_trace_enabled}    ssh.read_output    connection=${asik_alias}
    [Teardown]     ssh.disconnect    ${asik_alias}

Turn off cplane debug log on gNB
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    ${cmd_disable_debug_log}  set variable  rm /ffs/run/cp_runtime.ini
    ssh.send_command    command=${cmd_disable_debug_log}    connection=${asik_alias}
    ssh.send_command    command=ls -l /ffs/run/cp_runtime.ini    connection=${asik_alias}
    ${is_trace_enabled}    ssh.read_output    connection=${asik_alias}
    [Teardown]     ssh.disconnect    ${asik_alias}

Verify Link Reset during Lock Cell operation
    [Documentation]    Author: Cui Lingxue
    ...    Verify E1Reset/ACK, F1Reset/ACK, NGReset/ACK in tcpdump log.
    [Arguments]    ${log_path_pcap}    ${filter}=f1ap||ngap||e1ap
#    Load pcap file with filter     log_path_pcap=${log_path_pcap}     filter=${filter}
    ${log_path_pdml}    Get pdml log    tcpdump_log=${log_path_pcap}    filter=${filter}
    run keyword and continue on failure    check_msg_item_tcpdump   tcpdump_pdml=${log_path_pdml}    msg_file=${CURDIR}/E1Reset.txt
    run keyword and continue on failure    check_msg_item_tcpdump   tcpdump_pdml=${log_path_pdml}    msg_file=${CURDIR}/E1Reset.txt
    run keyword and continue on failure    check_msg_item_tcpdump   tcpdump_pdml=${log_path_pdml}    msg_file=${CURDIR}/E1Reset.txt
