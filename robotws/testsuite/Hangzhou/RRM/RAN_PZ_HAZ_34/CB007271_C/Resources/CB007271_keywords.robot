*** Settings ***
Resource     CB007271_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init__.py
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_gnb_classical.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot

*** Keywords ***
Set variables for 7271
   [Documentation]    Author: Wu Rong
   Connect to gnb coam via ssl
   ${DICT_Cell_IDS_TECH}    get_cell_ids_based_on_cell_technology
   set suite variable    ${DICT_Cell_IDS_TECH}
   [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

7271 Suite preparation
    [Documentation]    Author: Wu Rong
    [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${ENB_SCF_DEFAULT_FILE_PATH}    ${import_nidd_needed}=${True}
    ...     ${swconfig_modify}=${None}
    Set variables for 7271
    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    ...    NSA_SA=${NSA_SA}
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_7271_BASE}
    Suite common setup preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...   swconfig_modify=${swconfig_modify}
    run keyword if  '${TDD_CELL_ID}'!='None'  Change status for parameter cellBarred on GNB    exp_status=barred
    ...    list_cell_ids=${TDD_CELL_ID}
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}

Attach UE and capture F1AP log
    [Documentation]    Author: Cui Lingxue
    ...    Description: Perform UE attach with 3 times retry.
    ...    Capture F1 log for this procedure, and return log path.
    ...    - ${attach_log_name}: name of F1 attach log.
    ...    - ${network_type}: UE NR network type, NSA or SA.
    ...    - ${connection}: alias of ssl connection.
    ...    - ${cell_id}: nrCellId of the cell to which UE is expected to attach.
    ...    - return: log path on ute which cover the attach procedure.
    [Arguments]   ${attach_log_name}    ${network_type}=${NSA_SA}    ${ue_index}=${0}    ${connection}=GNB_OAM    ${cell_id}=${FDD_CELL_ID}
    Start capture F1AP log     tcpdump_collector_name=${attach_log_name}    options=-i any sctp
    run keyword and continue on failure
    ...    Retry commercial ue attach if failed     prepare_ue_needed=${True}    ue_index=${ue_index}    connection=${connection}
    sleep    10s
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${attach_log_name}

    Run keyword and continue on failure
    ...    Verify ue is attached to the expected cell    log_path_f1ap_ute=${ute_log_path}
    ...    cell_id_for_attach=${cell_id}    connection_alias=${connection}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${attach_log_name}

Start data transfer and verify tput
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${data_transfer_direction}=both    ${tput_duration}=1200s    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${ue_type}=${UE_TYPE}    ${tput_check_duration}=60s    ${ignore_time}=10s    ${filter}=L2Lo
    ...    ${cell_id}=${FDD_CELL_ID}    ${exp_dl}=${FDD_DL_EXP_TPUT_20M}    ${exp_ul}=${FDD_UL_EXP_TPUT_20M}
    ...    ${target_avg_percent}=0.90    ${min_percent}=0.85    ${customized_log_name}=${None}
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${tput_duration}
    ...    data_transfer_direction=${data_transfer_direction}

    ${exp_ul}    set variable if    '${data_transfer_direction}'=='dl'    -1    ${exp_ul}
    ${exp_dl}    set variable if    '${data_transfer_direction}'=='ul'    -1    ${exp_dl}
    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${tput_check_duration}    ignore_time=${ignore_time}   filter=${filter}
    Connect to gnb coam via ssl
    Check tput via power UE    cell_id=${cell_id}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    customized_log_name=${customized_log_name}
    [Teardown]  COAM Teardown gnb connections


Get pCSI config from RRC Reconfiguration
    [Documentation]    Author: Cui Lingxue
    ...    Description: Get periodicity and offset of CSI report from RRC Reconfiguration msg which are captured
    ...    during UE attach procedure.
    ...    - ${attach_log_path}: F1 log path on ute which cover the attach procedure.
    ...    - return: periodicity and offset of pcsi report, eg {'periodicity': '160', 'offset': '5'}
    [Arguments]    ${attach_log_path}
    ${filter_rrcReconf}    set variable    (nr-rrc.c1 == 0) && (f1ap.procedureCode == 12) && (nr-rrc.uplinkBWP_ToAddModList == 1)
    pcap.setup    infile=${attach_log_path}    display_filter=${filter_rrcReconf}
    ${xpath_csiReport}    set variable    //nr-rrc.reportSlotConfig/child::*
    ${csi_periodicity_offset}    pcap.get_field_value_by_xpath    xpath=${xpath_csiReport}        attribute_name=showname
    ${csi_periodicity_offset}    split_string    string=${csi_periodicity_offset[${0}]}    separator=:
    ${csi_periodicity}    get_regexp_matches    string=${csi_periodicity_offset}[${0}]    pattern=[0-9]+
    ${csi_periodicity}    set variable    ${csi_periodicity}[${0}]
    ${csi_offset}    strip_string    ${csi_periodicity_offset}[${1}]
    ${csi_config}    create_dictionary    periodicity=${csi_periodicity}    offset=${csi_offset}
    [Return]    ${csi_config}

Get SR config from RRC Reconfiguration
    [Documentation]    Author: Cui Lingxue
    ...    Description: Get periodicity and offset of SR report from RRC Reconfiguration msg which are captured
    ...    during UE attach procedure.
    ...    - ${attach_log_path}: F1 log path on ute which cover the attach procedure.
    ...    - return: periodicity and offset of pcsi report, eg {'periodicity': '80', 'offset': '5'}
    [Arguments]    ${attach_log_path}
    ${filter_rrcReconf}    set variable    (nr-rrc.c1 == 0) && (f1ap.procedureCode == 12) && (nr-rrc.uplinkBWP_ToAddModList == 1)
    pcap.setup    infile=${attach_log_path}    display_filter=${filter_rrcReconf}

    ${xpath_SR}    set variable    //nr-rrc.schedulingRequestResourceToAddModList//..//nr-rrc.periodicityAndOffset/child::*
    ${SR_periodicity_offset}    pcap.get_field_value_by_xpath    xpath=${xpath_SR}        attribute_name=showname
    ${SR_periodicity_offset}    split_string    string=${SR_periodicity_offset[${0}]}    separator=:
    ${SR_periodicity}    get_regexp_matches    string=${SR_periodicity_offset}[${0}]    pattern=[0-9]+
    ${SR_periodicity}    set variable    ${SR_periodicity}[${0}]
    ${SR_offset}    strip_string    ${SR_periodicity_offset}[${1}]
    ${SR_config}    create_dictionary    periodicity=${SR_periodicity}    offset=${SR_offset}
    [Return]    ${SR_config}

Verify multiplex of pCSI SR and HARQ D on PUCCH
    [Documentation]    Author: Cui Lingxue
    ...    Verify pCSI report with SR and HARQ_D received on PUCCH format 3 resource.
    ...    Always 1 PRB is allocated for a PUCCH Format 3 resource except if the code rate is set to 0.08 and the modulation scheme
    ...    Pi/2-BPSK is selected.
    ...    - ${bip_log_path}: log path of bip file on ute.
    [Arguments]    ${bip_log_path}
    ${filter}    set variable    uci.cqi&&uci.an&&uci.sr
    pcap.setup    infile=${bip_log_path}    display_filter=${filter}
    ${pucch_format}    pcap.get_field_value_by_name    field_name=UlData_pucchReceiveRespPsPucchResource_t.pucchFormat    attribute_name=show
    ${pucch_numOfPrb}    pcap.get_field_value_by_name    field_name=UlData_pucchReceiveRespPsPucchResource_t.numOfPrb    attribute_name=show
    run keyword and continue on failure    should not be empty     ${pucch_format}

    FOR    ${i}    IN RANGE    len(${pucch_format})
        run keyword and continue on failure    should be equal as integers    ${pucch_format}[${i}]    3
        run keyword and continue on failure    should be equal as integers    ${pucch_numOfPrb}[${i}]    1
    END

Verify multiplex of pCSI and HARQ D on PUSCH
    [Documentation]    Author: Cui Lingxue
    ...    Verify HARQ feedbacks and(or) pCSI are received via PUSCH if the UE’s PUCCH would overlap with its PUSCH in time.
    ...    - ${bip_log_path}: log path of bip file on ute.
    ...    - ${harq_d_check}: whether check harq d.
    [Arguments]    ${bip_log_path}    ${harq_d_check}=${True}
    ${filter}    set variable    uci.cqi&&uldata_puschreceiverespps
    pcap.setup    infile=${bip_log_path}    display_filter=${filter}    alias=csi_report
    ${sfn_values}    pcap.get_field_value_by_name    field_name=_3gpp.sfn    attribute_name=show    pcap_parser=csi_report
    ${slot_values}    pcap.get_field_value_by_name    field_name=_3gpp.slot    attribute_name=show    pcap_parser=csi_report
    ${cqi_values}    pcap.get_field_value_by_name    field_name=uci.cqi    attribute_name=show    pcap_parser=csi_report
    run keyword and continue on failure    should not be empty     ${cqi_values}
    return_from_keyword_if    '${harq_d_check}'=='${False}'

    ${filter}    set variable    uldata_puschreceiverespharqd
    FOR    ${i}    IN RANGE    len(${sfn_values})
        pcap.setup    infile=${bip_log_path}
        ...    display_filter=3gpp.sfn==${sfn_values}[${i}]&&3gpp.slot==${slot_values}[${i}]&&uldata_puschreceiverespharqd
        ...    alias=harq_d
        run keyword and continue on failure    pcap.get_packets
        ...    filter=UlData_puschReceiveRespHarqDGrants_t.ackNack1BitUci
        ...    pcap_parser=harq_d
    END

L3 call and check tput for each cell
    [Documentation]    Author: Jin Journey
    [Arguments]    ${cell_id}    ${dl_throughput}    ${exp_dl}    ${ul_throughput}    ${exp_ul}    ${duration_time}=1200    ${tput_duration}=60s
    ...      ${data_transfer_direction}=both
    Retry commercial ue attach if failed
    Start data transfer based on direction    dl_tput=${dl_throughput}    ul_tput=${ul_throughput}    duration=${duration_time}
    Sleep    10 sec
    ${tput_info}    run keyword and continue on failure    Check Tput info for each cell
    ...    dl_cell_id=${cell_id}    exp_dl=${exp_dl}    ul_cell_id=${cell_id}    exp_ul=${exp_ul}    tput_duration=${tput_duration}
    [Return]    ${tput_info}


Get ssb in bip log
    [Documentation]    Author: Jin Journey
    ...    First filter message:dldata_ssblocksendreq || dldata_pdschsendreq, if last message is ssb, then not select this message
    ...    Then record ssb message sfn and slot, return ssb message list,format:[{'sfn': 'xxx', 'slot': 'xxx'}]
    [Arguments]    ${log_path}
    ${last_meaasge}    ${last_message_sfn}    Get last message with filter ssb and pdsch in bip log    log_path=${log_path}
    ${filter}    set variable if    '${last_meaasge}' == '0x0000e10f'    (dldata_ssblocksendreq) && !(3gpp.sfn == ${last_message_sfn})
    ...    dldata_ssblocksendreq

    pcap.setup    infile=${log_path}    display_filter=${filter}
    ${ssb_sfn_values}    pcap.get_field_value_by_name    field_name=_3gpp.sfn    attribute_name=show
    ${ssb_slot_values}    pcap.get_field_value_by_name    field_name=_3gpp.slot    attribute_name=show
    ${ssb_slot_list}    create list

    FOR    ${i}    IN RANGE    len(${ssb_sfn_values})
        ${cur_ssb}    create dictionary    sfn=${ssb_sfn_values[${i}]}    slot=${ssb_slot_values[${i}]}
        append_to_list    ${ssb_slot_list}    ${cur_ssb}
    END
    [Return]    ${ssb_slot_list}


Get last message with filter ssb and pdsch in bip log
    [Documentation]    Author: Jin Journey
    ...    purpose to get the last message with filter dldata_ssblocksendreq || dldata_pdschsendreq in bip log
    ...    distinguish message with message id,and returned last message id and related sfn,
    ...    e.g. ${last_meaasge}=0x0000e118,${last_message_sfn}=839 meams last message is dldata_pdschsendreq,sfn is 839
    ...    ssb message id:0x0000e10f
    ...    pdsch message id:0x0000e118
    [Arguments]    ${log_path}
    ${filter}    set variable    dldata_ssblocksendreq || dldata_pdschsendreq

    pcap.setup    infile=${log_path}    display_filter=${filter}
    ${ssb_and_pdsch_message_id}    pcap.get_field_value_by_name    field_name=swe.MessageID    attribute_name=show
    ${ssb_and_pdsch_sfn_values}    pcap.get_field_value_by_name    field_name=_3gpp.sfn    attribute_name=show
    ${last_message_id}    set variable    ${ssb_and_pdsch_message_id[-1]}
    ${last_sfn_value}    set variable    ${ssb_and_pdsch_sfn_values[-1]}

    [Return]    ${last_message_id}    ${last_sfn_value}


Verify pdsch at ssb in bip log
    [Documentation]    Author: Jin Journey
    [Arguments]    ${log_path}
    ${ssb_list}    Get ssb in bip log  log_path=${log_path}
    ${pdsch_at_ssb_slot_list}    create list
    FOR    ${i}    IN RANGE    len(${ssb_list})
        ${filter}    set variable    (dldata_pdschsendreq) && (3gpp.sfn == ${ssb_list[${i}]['sfn']}) && (3gpp.slot == ${ssb_list[${i}]['slot']})
        pcap.setup    infile=${log_path}    display_filter=${filter}
        ${pdsch_at_ssb_sfn_values}    pcap.get_field_value_by_name    field_name=_3gpp.sfn    attribute_name=show
        ${pdsch_at_ssb_slot_values}    pcap.get_field_value_by_name    field_name=_3gpp.slot    attribute_name=show
        run keyword and continue on failure    should not be empty    ${pdsch_at_ssb_sfn_values}
        run keyword and continue on failure    should not be empty    ${pdsch_at_ssb_slot_values}
    END


Capture bip log and verify pdsch at ssb slot
    [Documentation]    Author: Jin Journey
    [Arguments]    ${asil_interface}=nac_eth2
    Connect to Common Unit Master
    Start Bip Capture for different program
    Sleep    5 sec
    ${bip_log}    Stop Bip Capture and Collect logs for different program    asil_interface=${asil_interface}    is_return_original_file=${True}
    run keyword and continue on failure    Verify pdsch at ssb in bip log    log_path=${bip_log[0]}

Capture bip log
    [Documentation]    Author: Meng Xiaxian
    [Arguments]    ${asil_interface}=nac_eth2    ${target_file_name}=l1l2bip_log
    Connect to Common Unit Master
    Start Bip Capture for different program    target_file_name=${target_file_name}
    Sleep    2 sec
    ${bip_log}    Stop Bip Capture and Collect logs for different program
    ...    asil_interface=${asil_interface}    is_return_original_file=${True}    target_file_name=${target_file_name}
    [Return]    ${bip_log}

Check PM counter M55308C00015 M55308C00016 M55308C00005 M55308C00008
    [Documentation]    author: journey.jin@nokia-sbell.com
    ...    M55308C00015:SS Burst slot with PDSCH
    ...    M55308C00016:SS Burst slot with PDSCH - Time(microsecond)
    ...    M55308C00005:Data slot with PDSCH
    ...    M55308C00016:Data slot with PDSCH - Time(microsecond)
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}    hw_slot=${HW_SLOT}
    ${cell_check_list}    create list     ${FDD_CELL_ID}
    ${list_measurement_ids}    create list    M55308C00015    M55308C00016    M55308C00005    M55308C00008
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    ${M55308C00015}    set variable    ${dict_measurements_value['${fdd_cell_id}']['M55308C00015']}
    ${M55308C00016}    set variable    ${dict_measurements_value['${fdd_cell_id}']['M55308C00016']}
    ${M55308C00005}    set variable    ${dict_measurements_value['${fdd_cell_id}']['M55308C00005']}
    ${M55308C00008}    set variable    ${dict_measurements_value['${fdd_cell_id}']['M55308C00008']}
    run keyword and continue on failure     should be true      ${M55308C00015}>=15000
    run keyword and continue on failure     should be true      ${M55308C00016}>=15000000
    run keyword and continue on failure     should be true      ${M55308C00005}>=${M55308C00015}
    run keyword and continue on failure     should be true      ${M55308C00008}>=${M55308C00016}


Disable 2534 and check tput
    [Documentation]    Author: Jin Journey
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${RESTAPI_DISABLE_2534}    timeout=300
    ${tput_info}    L3 call and check tput for each cell    cell_id=${FDD_CELL_ID}    dl_throughput=${DL_TPUT}
    ...    ul_throughput=${UL_TPUT}    exp_dl=${FDD_DL_EXP_TPUT_20M_2534}    exp_ul=${FDD_UL_EXP_TPUT_20M}
    run keyword and continue on failure    Stop data transfer based on direction
    [Return]    ${tput_info}


Verify dl avg tput of feature enable is bigger than feature disable
    [Documentation]    Author: Jin Journey
    [Arguments]    ${tput_feature_enable}    ${tput_feature_disable}
    ${dl_avg_tput_feature_enable}    set variable    ${tput_feature_enable['${fdd_cell_id}']['dl_avg_tput']}
    ${dl_avg_tput_feature_disable}    set variable    ${tput_feature_disable['${fdd_cell_id}']['dl_avg_tput']}
    run keyword and continue on failure     should be true      ${dl_avg_tput_feature_enable}>${dl_avg_tput_feature_disable}
