*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1


Resource    ./CA_Common.robot

*** Variables ***
${INIT_PA_F_T}     ${None}
${PA_OUT_PORTS}     ${None}
${PA_ROWS}     ${None}
${HW_SLOT}     ${5}

*** Keywords ***
CA Suite preparation
    [Documentation]  pa_values_mapping: should be in bellow format. { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
    ...              ${INIT_PA_F_T} ${PA_OUT_PORTS} ${PA_ROWS} are defined in init file under commission folder for each test line,
    ...                            you can also input with other values based on your needs
    [Arguments]    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}    ${prepare_ue}=${True}
    ...    ${timeout}=2min    ${ue_index}=${0}    ${swconfig_modify}=${None}
    ...    ${detach_request}=${false}    ${NSA_SA}=SA    ${enb_default_scf_file}=${None}    ${pa_values_mapping}=${INIT_PA_F_T}
    ...    ${attenuator_out_ports}=${PA_OUT_PORTS}    ${attenuator_rows}=${PA_ROWS}
    ...    ${is_pdl_checking_needed}=${False}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}
    Run keyword if    '${tl.attenuators}'!='[None]' and "${attenuator_out_ports}"!="None"
    ...    Block whole attenuator ports for testline    attenuator_out_ports=${attenuator_out_ports}    attenuator_rows=${attenuator_rows}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}

    Suite common setup preparation
    ...    prepare_ue=${prepare_ue}    scf_template_path=${scf_template_path}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    detach_request=${detach_request}    enb_default_scf_file=${enb_default_scf_file}  swconfig_modify=${swconfig_modify}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_modify_parameters=${scf_modify_parameters}
    ...    cluster_start_up_timeout=20min
#    connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}
    ${is_pcell_id_exist}    Get Variable Value    ${PCELL_ID}
    Run keyword if    ${is_pcell_id_exist}!=${None}
    ...    run keyword and ignore error    Switch NSA SA mode via cell bar/unbar nr cells
    ...        pa_values_mapping=${pa_values_mapping}    pcell_id=${PCELL_ID}    timeout=${timeout}
    ...        prefer_5g_nr_mode=${NSA_SA}    ue_index=${ue_index}    is_prepare_ue_needed=${False}    prefer_5g_nr_mode=${NSA_SA}

CA Suite teardown
    [Arguments]    ${is_log_required}=${True}
    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=all
    run keyword and ignore error    Common suite recovery    is_log_required=${is_log_required}

UE attach and check Scell addition in tcpdump log
    [Documentation]    Author: Wang Yixiang
    ...    UE attach to FDD cell and TDD add as scell
    ...    check from CA from cpif log
    [Arguments]    ${ue_type}=${UE_TYPE}    ${4G_check}=${False}      ${scell_addition_method}=blind
    ...    ${check_counter}=${False}    ${CA_enable}=${True}    ${ue_index}=${0}   ${NSA_SA}=SA    ${pcell_id}=${PCELL_ID}    ${connection}=GNB_OAM
    ...    ${tcpdump_log_name}=basic_l3_call
    ${case_start_time_info}    run keyword if    ${check_counter}    Prepare for counter log
    run keyword if   '${NSA_SA}'=='NSA'       Start X2 log capture from eNB    log_name=nsa_x2_debug

    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    ${retry_attach_times}    run keyword and continue on failure
    ...    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${4G_check}    ue_index=${ue_index}
    ...    connection=${connection}    ue_type=${ue_type}
    run keyword if   '${NSA_SA}'=='NSA'      Stop X2 log capture from eNB    log_name=nsa_x2_debug
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
    Run keyword and continue on failure    Verify ue is attached to the expected cell    log_path_f1ap_ute=${ute_log_path}
    ...    cell_id_for_attach=${pcell_id}    connection_alias=${connection}
    run keyword and continue on failure    run keyword if    ${CA_enable}==${True}
    ...    Check Scell addition in tcpdump log    tcpdump_log=${ute_log_path}    scell_addition_method=${scell_addition_method}
    ...    ELSE IF   '${scell_addition_method}'=='covBasedA1'    run keywords
    ...            Check No Scell addition in tcpdump log    tcpdump_log=${ute_log_path}
    ...            AND     Check A1 config in tcpdump log    tcpdump_log=${ute_log_path}
    ...    ELSE    Check No Scell addition in tcpdump log    tcpdump_log=${ute_log_path}
    run keyword if    '${NSA_SA}'=='SA'    run keyword and ignore error    Get Cell Pci And UE Rnti In Tcpdump    tcpdump_log=${ute_log_path}
    run keyword if    ${check_counter}    Download PM files and verify counter value
    ...    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
    ...    retry_attach_times=${retry_attach_times}   NSA_SA=${NSA_SA}
    set test variable    ${attach_f1ap_logpath}    ${ute_log_path}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}    AND
    ...    Stop trace capturing    log_prefix=nsa_x2_debug    connection_alias=ENB    AND
    ...    Delete pdml log file    tcpdump_log_file_path=${ute_log_path}

Verify ue is attached to the expected cell
    [Documentation]  Author: Ding Binmei
    ...    Get pci for pcell and verify it's as expected
    ...    ${log_path_f1ap_ute}: should be the pcap file path on ute
    ...    ${cell_id_for_attach}: like 1, 2
    [Arguments]  ${log_path_f1ap_ute}    ${cell_id_for_attach}    ${connection_alias}=GNB_OAM
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    &{nr_cell_map}    run keyword if  '${has_cbts}'=='${False}'
    ...      coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection_alias}
    ...     ELSE       cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu    connection=${connection_alias}
    ${pci_for_attach_exp}    Set variable    ${nr_cell_map[${cell_id_for_attach}]['physicalCellId']}
    pcap.setup     infile=${log_path_f1ap_ute}    display_filter=f1ap     alias=test0
    ${xpath_get_pci_for_attached_cell}    Catenate    SEPARATOR=    .//*/nr-rrc.spCellConfig_element//*/
    ...    nr-rrc.scramblingID0|nr-rrc.physCellId
    ${pci_from_f1ap}    pcap.get_field_value_by_xpath    xpath=${xpath_get_pci_for_attached_cell}     pcap_parser=test0
    ${pci_from_f1ap}    Set variable    ${pci_from_f1ap[0]}
    Should Be Equal As Strings    ${pci_from_f1ap}    ${pci_for_attach_exp}    msg= Verify attach failed, as UE is not attached to the expected cell

UE attach and verify CA
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${ue_type}=${UE_TYPE}    ${4G_check}=False    ${tcpdump_log_name}=basic_l3_call    ${scell_addition_method}=blind
    ...    ${check_counter}=${False}    ${ue_index}=${0}   ${NSA_SA}=SA
    ${ute_log_path}    UE attach and check Scell addition in tcpdump log    CA_enable=${True}    ue_type=${ue_type}    4G_check=${4G_check}
    ...    tcpdump_log_name=${tcpdump_log_name}    scell_addition_method=${scell_addition_method}
    ...    check_counter=${check_counter}    ue_index=${ue_index}   NSA_SA=${NSA_SA}
    [Return]    ${ute_log_path}

UE attach and verify NO CA
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${ue_type}=${UE_TYPE}    ${4G_check}=False    ${tcpdump_log_name}=basic_l3_call_no_ca    ${ue_index}=${0}  ${NSA_SA}=SA
    ...     ${scell_addition_method}=blind
    ${ute_log_path}    UE attach and check Scell addition in tcpdump log    CA_enable=${False}    ue_type=${ue_type}    4G_check=${4G_check}
    ...    tcpdump_log_name=${tcpdump_log_name}    check_counter=${False}    ue_index=${ue_index}  NSA_SA=${NSA_SA}
    ...    scell_addition_method=${scell_addition_method}
    [Return]    ${ute_log_path}

UE attach to FDD cell and verify CA
    [Documentation]    Author: Wang Yixiang  [Deprecated], replaced by 'UE attach to Pcell and verify CA'
    ...    UE attach to FDD cell and TDD add as scell
    ...    check from CA from cpif log
    [Arguments]    ${tcpdump_log_name}=basic_l3_call    ${scell_addition_method}=blind
    ...    ${check_counter}=${False}    ${ue_index}=${0}  ${NSA_SA}=SA   ${ENB_Cellid}=${4}
    ...  ${FDD_ID}=${PCELL_ID}
    UE attach to Pcell and verify CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...    scell_addition_method=${scell_addition_method}    check_counter=${check_counter}    NSA_SA=${NSA_SA}   ENB_Cellid=${ENB_Cellid}
    ...    pcell_id=${FDD_ID}

UE attach to FDD cell and verify NO CA
    [Documentation]    Author: Wang Yixiang  [Deprecated], replaced by 'UE attach to Pcell and verify NO CA'
    ...    UE attach to FDD cell and TDD add as scell
    ...    check from CA from cpif log
    [Arguments]    ${tcpdump_log_name}=basic_l3_call_no_ca
    ...    ${ue_index}=${0}   ${NSA_SA}=SA   ${ENB_Cellid}=${4}   ${FDD_ID}=${PCELL_ID}
    UE attach to Pcell and verify NO CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...   NSA_SA=${NSA_SA}    ENB_Cellid=${ENB_Cellid}    pcell_id=${FDD_ID}

UE attach to TDD cell and verify NO CA
    [Documentation]    Author: Wang Yixiang
    ...    Set FDD cell barred and attach UE to TDD cell, FDD cell is unbarred afterwards.
    ...    check from cpif log there is no second RRC reconfig msg(this msg is config CA)
    [Arguments]    ${ue_type}=${UE_TYPE}    ${4G_check}=False    ${tcpdump_log_name}=basic_l3_call_no_ca    ${wa_flag}=${False}    ${ue_index}=${0}
    ...   ${NSA_SA}=SA   ${ENB_Cellid}=${4}   ${TDD_ID}=${SCELL_ID}
    run keyword if    ${wa_flag} and '${NSA_SA}'=='SA'     Change status for parameter cellBarred on GNB
    ...    exp_status=notBarred   list_cell_ids=${TDD_ID}
    run keyword if  '${NSA_SA}'=='NSA'     Make SgNBAddition on specific cell   LTE_ID=${ENB_Cellid}   gnb_ps_cell_index=${TDD_ID}
    UE attach and verify NO CA    ue_type=${ue_type}    4G_check=${4G_check}    tcpdump_log_name=${tcpdump_log_name}    ue_index=${ue_index}
    ...   NSA_SA=${NSA_SA}

######### Counter
Prepare for counter log
    [Documentation]    Author: Wang Yixiang
    ...    Prepare for counter log
    [Arguments]    ${reporting_interval}=5
    Connect to Common Unit Master
    Wait for next PM counter file is generated    reporting_interval=${reporting_interval}
    ${case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=${reporting_interval}
    [Return]    ${case_start_time_info}

Wait for PM file generated and download
    [Documentation]    Author: Wang Yixiang
    ...    Download counter log to ute
    [Arguments]     ${starting_log_timestamp}    ${local_file_folder}=${TS_CASE_LOG_PATH}    ${reporting_interval}=5
    Connect to Common Unit Master
    Wait for next PM counter file is generated    reporting_interval=${reporting_interval}
    @{local_counter_file_path}    Download PM counter files of a period    starting_log_timestamp=${starting_log_timestamp}
    ...    local_file_folder=${local_file_folder}
    [Return]    ${local_counter_file_path}

Download PM files and verify counter value
    [Documentation]    Author: Wang Yixiang
    ...    Download counter log to ute
    ...    M55118C05505:CELLS/NRCELL-1/NCAC/RRC_RECONF_ADD1DLSCELL_ATT_SA
    ...                 Number of RRC Reconfiguration configuring 1 SCell in DL in SA mode
    ...    M55118C05506:CELLS/NRCELL-1/NCAC/RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...                 Number of successful RRC Reconfiguration configuring 1 SCell in DL in SA mode
    ...    M55118C05507:CELLS/NRCELL-1/NCAC/UE_PCELL_1_CONF_SCELL_DL_SA
    ...                 Number of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
    ...    M55118C05508:CELLS/NRCELL-1/NCAC/UE_SCELL_1_CONF_SCELL_DL_SA
    ...                 Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
    [Arguments]    ${starting_log_timestamp}    ${retry_attach_times}=1   ${NSA_SA}=SA
    ${measurement_ids_SA}    create list     M55118C05505   M55118C05506   M55118C05507   M55118C05508
    ${measurement_ids_NSA}    create list     M55118C02000  M55118C03000  M55118C04000  M55118C05000
    ${measurement_ids}      set variable if   '${NSA_SA}'=='SA'   ${measurement_ids_SA}   ${measurement_ids_NSA}
    ${local_counter_file_path}    Wait for PM file generated and download     starting_log_timestamp=${starting_log_timestamp}
    ${measurement_ids_value}      counter.get_total_counter_from_multiple_files   list_file_path=${local_counter_file_path}
    ...  list_measurement_ids=${measurement_ids}
    log to console    \ncounter info:${measurement_ids_value}
    ${val0}    set variable     ${measurement_ids[0]}
    ${val1}    set variable     ${measurement_ids[1]}
    ${val2}    set variable     ${measurement_ids[2]}
    ${val3}    set variable     ${measurement_ids[3]}
    Run keyword and continue on failure  should be true   1<=${measurement_ids_value}[${val0}]<=${retry_attach_times}
    ...    msg=Number of RRC Reconfiguration configuring 1 SCell in DL in SA mode (${measurement_ids[0]}) is wrong
    Run keyword and continue on failure  should be true  1<=${measurement_ids_value}[${val1}]<=${retry_attach_times}
    ...    msg=Number of successful RRC Reconfiguration configuring 1 SCell in DL in SA mode （${measurement_ids[1]}]) is wrong
    Run keyword and continue on failure  should be true  ${measurement_ids_value}[${val2}]>0
    ...    msg=Number of CA UEs in the current scell configured as a PCell, which have 1 configured SCell in DL (${measurement_ids[2]}) is wrong
    Run keyword and continue on failure  should be true  ${measurement_ids_value}[${val3}]>0
    ...    msg=Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL (${measurement_ids[3]}) is wrong

Prepare and start aasyslog
    [Documentation]     Author: Wang Yixiang
    ...    Prepare and start aasyslog to check scell activation
    ...    sCellActivationMethod=bufferBased
    [Arguments]    ${filter}=L2    ${gnb_path}=/tmp/    ${log_name}=scell_activation.txt
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress    filter=${filter}    gnb_path=${gnb_path}     log_name=${log_name}
    ${remote_aasyslog_path}    Set variable    ${gnb_path}${log_name}
    [Return]    ${remote_aasyslog_path}

Stop aasyslog to check scell activation
    [Documentation]     Author: Wang Yixiang
    ...    Stop aasyslog to check scell activation
    ...    sCellActivationMethod=bufferBased
    [Arguments]    ${timeout}=30s    ${log_name}=scell_activation.txt
    Connect to Common Unit Master
    wait until keyword succeeds    ${timeout}    5 sec    Check scell activation in aasyslog    log_name=${log_name}
    [Teardown]    Teardown the Aasyslog save progress

Check Tput info for each cell
    [Documentation]    Author: Wang Yixiang
    ...    check tput info for each cell
    ...    ${NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ...    Note: ssh connection to asik master will be re-established.
    [Arguments]    ${dl_cell_id}    ${exp_dl}    ${ul_cell_id}    ${exp_ul}    ${tput_duration}=60s    ${gnb_index}=${0}    ${asik_alias}=ASIK Master
    ...      ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${min_tp_check_needed}=${True}
#    run keyword and ignore error    Close all connection
    ${tput_info_cell}   Get tput summary from GNB log    dl_cell=${dl_cell_id}   ul_cell=${ul_cell_id}    tput_duration=${tput_duration}
    ...    gnb_index=${gnb_index}    alias=${asik_alias}    nr_cell_id_mapping=${nr_cell_id_mapping}

    ${dl_cell_id}    string2list    ${dl_cell_id}
    ${ul_cell_id}    string2list    ${ul_cell_id}
    ${exp_ul}    string2list    ${exp_ul}
    ${exp_dl}    string2list    ${exp_dl}

    log to console    \ntput_info_cell:${tput_info_cell}
    FOR    ${index}    ${cell_id}    IN ENUMERATE    @{dl_cell_id}
        ${dl_actual_tput}   set variable    ${tput_info_cell['${cell_id}']['dl_avg_tput']}
        ${dl_actual_min_tput}   set variable    ${tput_info_cell['${cell_id}']['dl_min_tput']}
        ${dl_exp_tput}    set variable   ${exp_dl}[${index}]
        run keyword and continue on failure  run keyword if    '${dl_exp_tput}'=='${0}'
        ...    should be true    ${dl_actual_tput}<1    There should be no dl tput on cell_id ${cell_id}.
        ...    ELSE    should be true    ${dl_actual_tput}>${dl_exp_tput}
        ...    cell_id ${cell_id} dl_actual_tput ${dl_actual_tput} should bigger than dl_exp_tput ${dl_exp_tput}
        run keyword and continue on failure  run keyword if    ${min_tp_check_needed}==${True} and '${dl_exp_tput}'!='${0}'
        ...    should be true    ${dl_actual_min_tput}>${1}    Throughout should not be dropped, please check!
    END

    FOR    ${index}    ${cell_id}    IN ENUMERATE    @{ul_cell_id}
        ${ul_actual_tput}   set variable    ${tput_info_cell['${cell_id}']['ul_avg_tput']}
        ${ul_actual_min_tput}   set variable    ${tput_info_cell['${cell_id}']['ul_min_tput']}
        ${ul_exp_tput}    set variable   ${exp_ul}[${index}]
        run keyword and continue on failure  run keyword if    '${ul_exp_tput}'=='${0}'
        ...    should be true    ${ul_exp_tput}<1    There should be no ul tput on cell_id ${cell_id}.
        ...    ELSE    should be true    ${ul_actual_tput}>${ul_exp_tput}
        ...    cell_id ${cell_id} ul_actual_tput ${ul_actual_tput} should bigger than ul_exp_tput ${ul_exp_tput}
        run keyword and continue on failure  run keyword if    ${min_tp_check_needed}==${True} and '${ul_exp_tput}'!='${0}'
        ...    should be true    ${ul_actual_min_tput}>${1}    Throughout should not be dropped, please check!
    END
    [Return]    ${tput_info_cell}

########## modify SCF or modify nidd via restapi
Activate beam refinement by rest api
    [Documentation]   author: Wang Yixiang
    ...    Active beam refinement by setting nrBtsBeamRefinementP2='true' via rest api
    [Arguments]     ${parameters}=${ACTIVE_BEAM_REFINEMENT_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    log to console    Activate beam refinement by rest api
    Modify NIDD by rest api and wait onair    parameters=${parameters}    timeout=${timeout}

Add NRREL MO by rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}=${ADD_MO_NRREL_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${NSA_SA}=SA
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    COAM add several MOs via rest api     objects_to_add_via_api=${parameters}    timeout=${timeout}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Remove NRREL MO by rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}=${DELETE_MO_NRREL_RESTAPI}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${NSA_SA}=SA
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters}    timeout=${timeout}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_all_cells_checking_needed=${True}

Data transimission on both Pcell and Scell
    [Documentation]    Author: Cui Lingxue
    ...    Check throughput on all cells, the expectation is:
    ...        - DL: data transfer on both PCell and SCell.
    ...        - UL: data transfer only on PCell, tput on SCell is 0.
    [Arguments]    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}
    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ul_cell_id=${ul_cell_id}   exp_ul=${PCELL_EXP_UL},0

Verify PDUSessionResourceReleaseCommand in tcpdump
    [Documentation]    Author: Wang Yixiang
    ...   Verify PDUSessionResourceReleaseCommand in tcpdump
    [Arguments]    ${tcpdump_log}
    ${filtered_packets}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=f1ap||nr-rrc||ngap
    @{pdu_release}    Get field value    packets=${filtered_packets}    field_name=ngap.PDUSessionResourceReleaseCommand_element
    ...    attribute_name=showname
    should be equal as strings    ${pdu_release}[0]    PDUSessionResourceReleaseCommand

Remove NRREL MO by rest api and wait onair and verify performance
    [Documentation]    Author: Wang Yixiang
    ...    21A:  Remove NRREL and data continue transmission on both pcell and scell
    ...    21B and Trunk: Remove NRREL, pcell will lock and unlock, and there is have a msg:PDUSessionResourceReleaseCommand
    ...    Confirmed with manual side, NSA will not verify for lock unlock check point
    [Arguments]   ${NSA_SA}=SA
    ${msg_reason_for_doing_unbarred_on_GNB}    Catenate    Since on later branches after 21A, remove NRREL will cause pcell lock and unlock
    ...    In case UE will attach to other GNBs, so need to unbar our local GNB cells.
    run keyword if    '${PROGRAM}'!='21A'    run keywords    Log to console    ${msg_reason_for_doing_unbarred_on_GNB}    AND
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   AND
    ...    Start capture F1AP log    tcpdump_collector_name=lock_unlock

    Remove NRREL MO by rest api and wait onair
    ${tcpdump_log}    run keyword if    '${PROGRAM}'!='21A'    Stop tcpdump log collection    tcpdump_collector_name=lock_unlock
    run keyword if    '${PROGRAM}'=='21A'   run keyword and continue on failure    Data transimission on both Pcell and Scell
    ...    ELSE IF   '${NSA_SA}'=='SA'   run keywords    Verify PDUSessionResourceReleaseCommand in tcpdump    tcpdump_log=${tcpdump_log}   AND
    ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
    [Teardown]    run keyword if    '${PROGRAM}'!='21A'    run keyword and ignore error
    ...    Stop Tcpdump via collector    tcpdump_collector_name=lock_unlock

Modify NIDD by rest api and wait onair
    [Documentation]   Private   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    ...    2021-10-19 Ding Binmei: update enb, x2 check to ${True} to support for NSA
    [Arguments]     ${parameters}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${NSA_SA}=SA    ${connection}=GNB_OAM
    ...    ${is_enb_status_check_needed}=${True}    ${is_x2_check_from_enb_needed}=${True}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters}    timeout=${timeout}    connection=${connection}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_enb_status_check_needed}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${is_x2_check_from_enb_needed}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_all_cells_checking_needed=${True}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}
    ...    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    is_need_to_setup_gnb_connection=${False}
    ...    connection=${connection}

Modify cDRX status on PCell by rest api
    [Documentation]   author: Dandan Fang
    ...    Change cDRX status on Pcell
    ...    Update parameter list:sss
    ...        MRBTS-564/NRBTS-564/NRCELL-1/actCDrx=false or true
    ...        MRBTS-564/NRBTS-564/NRCELL-1/drxProfile1 (default value used):
    ...            drxInactivityTimer=80ms
    ...            drxLongCycle=160ms
    ...            drxOnDurationTimer=10ms
    ...            drxRetransTimerDl=0slot
    ...            drxRetransTimerUl=0slot
    [Arguments]    ${pcell_index}=${1}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ...    ${actCDrx_status}=true    ${drxInactivityTimer}=80ms  ${drxLongCycle}=160ms   ${drxOnDurationTimer}=10ms
    ...    ${drxRetransTimerDl}=0slot      ${drxRetransTimerUl}=0slot

    ${actCDrx_dict}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}', parameter='actCDrx', value='${actCDrx_status}')

    ${params_to_upd}    create list    ${actCDrx_dict}

    ${drxInactivityTimer}    set variable     drxInactivityTimer='${drxInactivityTimer}'
    ${drxLongCycle}     set variable      drxLongCycle='${drxLongCycle}'
    ${drxOnDurationTimer}    set variable     drxOnDurationTimer='${drxOnDurationTimer}'
    ${drxRetransTimerDl}    set variable     drxRetransTimerDl='${drxRetransTimerDl}'
    ${drxRetransTimerUl}    set variable     drxRetransTimerUl='${drxRetransTimerUl}'

    ${drxProfile1_value}    evaluate
    ...        [dict(${drxInactivityTimer}, ${drxLongCycle}, ${drxOnDurationTimer}, ${drxRetransTimerDl}, ${drxRetransTimerUl})]

    ${drxProfile1_profile}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}', parameter='drxProfile1', value=${drxProfile1_value})

    run keyword if    '${actCDrx_status}'=='true'  Append To List  ${params_to_upd}  ${drxProfile1_profile}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}

Modify sCell addition method to covBasedA1
    [Documentation]   author: Cui Lingxue
    ...    Online modify NIDD parameters to configure scell addition method to covBasedA1.
    ...    Update parameter list:
    ...        MRBTS-564/NRBTS-564/NRCELL-1/NRREL-1/sCellAdditionMethod=covBasedA1
    ...        MRBTS-564/NRBTS-564/actMeasBasedSCellAddition=true
    ...    New parameter list:
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a1MeasSCellAddEnabled=rsrp
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a1MeasSCellAddSsbRsrp:
    ...            a1HysteresisSCellAddSsbRsrp=0
    ...            a1ThresholdSCellAddSsbRsrpTDD=80
    ...            a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...    2023.05.12 Ding Binmei. Add argument is_to_skip_sCellAdditionMethod_none_rel: ${True}/${False}
    ...        If set to true, then NRREL with sCellAdditionMethod value None will not be filtered out
    [Arguments]    ${cell_index}=${1}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${program}=${PROGRAM}
    ...    ${a1HysteresisSCellAddSsbRsrp}=${0}
    ...    ${a1ThresholdSCellAddSsbRsrp_TDD}=${None}
    ...    ${a1ThresholdSCellAddSsbRsrp_FDD}=${None}
    ...    ${a1TimeToTriggerSCellAddSsbRsrp}=320ms
    ...    ${NSA_SA}=SA    ${connection}=GNB_OAM
    ...    ${is_to_skip_sCellAdditionMethod_none_rel}=${False}
    ${nrrel_info}    coam_gnb_classical.get_nrrel_under_specific_cell    source_cell_id=${cell_index}    connection_alias_source=${connection}
    ...    is_to_skip_sCellAdditionMethod_none_rel=${is_to_skip_sCellAdditionMethod_none_rel}
    ${list_nrrel_id}    set variable    ${nrrel_info['nrrel_ids']}
    ${params_to_upd}    create list

    FOR    ${nrrel_id}    IN    @{list_nrrel_id}
        ${sCellAdditionMethod}    evaluate
        ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL-${nrrel_id}', parameter='sCellAdditionMethod', value='covBasedA1')
        append to list    ${params_to_upd}    ${sCellAdditionMethod}
    END

    ${actMeasBasedSCellAddition_legacy}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAddition', value='true')

    ${measBased_list}    create list    A1-based
    ${actMeasBasedSCellAdditionSA}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAdditionSa', value=${measBased_list})

    ${actMeasBasedSCellAddition}   set variable if    '${program}'=='24R1' or '${program}'=='23R3' or '${program}'=='23R4' or '${program}'=='23R2'
    ...    ${actMeasBasedSCellAddition_legacy}     ${actMeasBasedSCellAdditionSA}

    append to list    ${params_to_upd}    ${actMeasBasedSCellAddition}

    ${a1Hysteresis}    set variable     a1HysteresisSCellAddSsbRsrp='${a1HysteresisSCellAddSsbRsrp}'
    ${a1RsrpThreshold_TDD}     set variable     a1ThresholdSCellAddSsbRsrpTDD='${a1ThresholdSCellAddSsbRsrp_TDD}'
    ${a1TimeToTrigger}    set variable     a1TimeToTriggerSCellAddSsbRsrp='${a1TimeToTriggerSCellAddSsbRsrp}'
    ${a1RsrpThreshold_FDD}     set variable      a1ThresholdSCellAddSsbRsrpFDD='${a1ThresholdSCellAddSsbRsrp_FDD}'

    ${value}   run keyword if   ${a1ThresholdSCellAddSsbRsrp_TDD}==${None} and ${a1ThresholdSCellAddSsbRsrp_FDD}!=${None}  evaluate
    ...    [dict(${a1Hysteresis}, ${a1TimeToTrigger}, ${a1RsrpThreshold_FDD} )]
    ...    ELSE IF   ${a1ThresholdSCellAddSsbRsrp_FDD}==${None} and ${a1ThresholdSCellAddSsbRsrp_TDD}!=${None}  evaluate
    ...    [dict(${a1Hysteresis}, ${a1RsrpThreshold_TDD}, ${a1TimeToTrigger} )]
    ...    ELSE  evaluate
    ...    [dict(${a1Hysteresis}, ${a1RsrpThreshold_TDD}, ${a1TimeToTrigger}, ${a1RsrpThreshold_FDD} )]



    ${a1MeasSCellAddEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='a1MeasSCellAddEnabled', value='rsrp')
    ${a1MeasSCellAddSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='a1MeasSCellAddSsbRsrp', value=${value})
    ${params_to_add}    create list    ${a1MeasSCellAddEnabled}    ${a1MeasSCellAddSsbRsrp}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    COAM add several parameters via rest api    parameters_to_add_via_api=${params_to_add}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

Configure A1 Meas Pcell Switch
    [Documentation]   author: Dandan Fang
    ...    Online modify NIDD parameters to configure Pcell Switch between CA
    ...    Update parameter list(Pcell):
    ...        MRBTS-564/NRBTS-564/NRCELL-1/NRHOIF/a1BasedPCellSwitchEnabled=true
    ...    New parameter list(Scell):
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a1MeasPCellSwitchEnabled=rsrp
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a1MeasPCellSwitchSsbRsrp:
    ...            a1HysteresisPCellSwitchSsbRsrp=0
    ...            a1ThresholdPCellSwitchSsbRsrp=80
    ...            a1TimeToTriggerPCellSwitchSsbRsrp=480ms
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ...    ${a1HysteresisPCellSwitchSsbRsrp}=${0}
    ...    ${a1ThresholdPCellSwitchSsbRsrp}=${80}
    ...    ${a1TimeToTriggerPCellSwitchSsbRsrp}=480ms
    #following parameters need to be configured on Pcell
    ${actMeasBasedSCellAddition}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAddition', value='true')
    ${a1BasedPCellSwitchEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}/NRHOIF-1', parameter='a1BasedPCellSwitchEnabled', value='true')
    ${params_to_upd}    create list    ${a1BasedPCellSwitchEnabled}      ${actMeasBasedSCellAddition}

    ${a1PcellHysteresis}    set variable     a1HysteresisPCellSwitchSsbRsrp='${a1HysteresisPCellSwitchSsbRsrp}'
    ${a1PcellRsrpThreshold}     set variable      a1ThresholdPCellSwitchSsbRsrp='${a1ThresholdPCellSwitchSsbRsrp}'
    ${a1PcellTimeToTrigger}    set variable     a1TimeToTriggerPCellSwitchSsbRsrp='${a1TimeToTriggerPCellSwitchSsbRsrp}'

    ${value}    evaluate    [dict(${a1PcellHysteresis}, ${a1PcellRsrpThreshold}, ${a1PcellTimeToTrigger})]

    #following parameters need to be configured on Scell
    ${a1MeasPCellSwitchEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${SCELL_ID}', parameter='a1MeasPCellSwitchEnabled', value='rsrp')
    ${a1MeasPCellSwitchSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${SCELL_ID}', parameter='a1MeasPCellSwitchSsbRsrp', value=${value})
    ${params_to_add}    create list    ${a1MeasPCellSwitchEnabled}    ${a1MeasPCellSwitchSsbRsrp}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    COAM add several parameters via rest api    parameters_to_add_via_api=${params_to_add}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}

Configure A2 Meas Pcell Switch
    [Documentation]   author: journey.jin@nokia.com
    ...    Online modify NIDD parameters to configure Pcell Switch between CA
    ...    Update parameter list(Pcell):
    ...        MRBTS-564/NRBTS-564/NRCELL-1/NRHOIF/a2BasedPCellSwitchEnabled=true
    ...    New parameter list(pcell):
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a2MeasPCellSwitchEnabled=rsrp
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a2MeasPCellSwitchSsbRsrp:
    ...            a2HysteresisPCellSwitchSsbRsrp=0
    ...            a2ThresholdPCellSwitchSsbRsrp=80
    ...            a2TimeToTriggerPCellSwitchSsbRsrp=480ms
    ...            pCellSwitchOffsetSsbRsrp=0
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}    ${program}=${PROGRAM}
    ...    ${a2HysteresisPCellSwitchSsbRsrp}=${0}
    ...    ${a2ThresholdPCellSwitchSsbRsrp}=${80}
    ...    ${a2TimeToTriggerPCellSwitchSsbRsrp}=480ms
    ...    ${pCellSwitchOffsetSsbRsrp}=${0}
    ...    ${NSA_SA}=SA

#    ${actMeasBasedSCellAddition}    evaluate
#    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAddition', value='true')
    ${actMeasBasedSCellAdditionNsa}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAdditionNsa', value='true')
    ${a2BasedPCellSwitchEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}/NRHOIF-1', parameter='a2BasedPCellSwitchEnabled', value='true')
    ${params_to_upd}    create list    ${a2BasedPCellSwitchEnabled}    ${actMeasBasedSCellAdditionNsa}

    ${actMeasBasedSCellAddition_legacy}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAddition', value='true')

    ${measBased_list}    create list    A1-based
    ${actMeasBasedSCellAdditionSA}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAdditionSa', value=${measBased_list})

    ${actMeasBasedSCellAddition}   set variable if    '${program}'=='24R1' or '${program}'=='23R3' or '${program}'=='23R4' or '${program}'=='23R2'
    ...    ${actMeasBasedSCellAddition_legacy}     ${actMeasBasedSCellAdditionSA}

    append to list    ${params_to_upd}    ${actMeasBasedSCellAddition}

    ${a2PcellHysteresis}    set variable     a2HysteresisPCellSwitchSsbRsrp='${a2HysteresisPCellSwitchSsbRsrp}'
    ${a2PcellRsrpThreshold}     set variable      a2ThresholdPCellSwitchSsbRsrp='${a2ThresholdPCellSwitchSsbRsrp}'
    ${a2PcellTimeToTrigger}    set variable     a2TimeToTriggerPCellSwitchSsbRsrp='${a2TimeToTriggerPCellSwitchSsbRsrp}'
    ${a2PcellRsrpOffset}    set variable     pCellSwitchOffsetSsbRsrp='${pCellSwitchOffsetSsbRsrp}'

    ${value}    evaluate    [dict(${a2PcellHysteresis}, ${a2PcellRsrpThreshold}, ${a2PcellTimeToTrigger}, ${a2PcellRsrpOffset})]

    ${a2MeasPCellSwitchEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}', parameter='a2MeasPCellSwitchEnabled', value='rsrp')
    ${a2MeasPCellSwitchSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}', parameter='a2MeasPCellSwitchSsbRsrp', value=${value})
    ${params_to_add}    create list    ${a2MeasPCellSwitchEnabled}    ${a2MeasPCellSwitchSsbRsrp}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    COAM add several parameters via rest api    parameters_to_add_via_api=${params_to_add}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}


Configure A2 Measurement For SCell Release Enabled
    [Documentation]   author: Dandan Fang
    ...    Online modify NIDD parameters to configure event A2 for Scell release
    ...    Need to configure on Scell
    ...    New parameter list:
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a2MeasSCellRelEnabled=rsrp
    ...        MRBTS-564/NRBTS-564/NRCELL-1/a2MeasSCellRelSsbRsrp:
    ...            a2HysteresisSCellRelSsbRsrp=0
    ...            a2ThresholdSCellRelSsbRsrp=60
    ...            a2TimeToTriggerSCellRelSsbRsrp=480ms
    [Arguments]    ${cell_index}=${SCELL_ID}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ...    ${a2HysteresisSCellRelSsbRsrp}=${0}
    ...    ${a2ThresholdSCellRelSsbRsrp}=${60}
    ...    ${a2TimeToTriggerSCellRelSsbRsrp}=480ms
    ${a2Hysteresis}    set variable     a2HysteresisSCellRelSsbRsrp='${a2HysteresisSCellRelSsbRsrp}'
    ${a2RsrpThreshold}     set variable      a2ThresholdSCellRelSsbRsrp='${a2ThresholdSCellRelSsbRsrp}'
    ${a2TimeToTrigger}    set variable     a2TimeToTriggerSCellRelSsbRsrp='${a2TimeToTriggerSCellRelSsbRsrp}'

    ${value}    evaluate    [dict(${a2Hysteresis}, ${a2RsrpThreshold}, ${a2TimeToTrigger} )]

    ${a2MeasSCellRelEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='a2MeasSCellRelEnabled', value='rsrp')
    ${a2MeasSCellRelSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='a2MeasSCellRelSsbRsrp', value=${value})
    ${params_to_add}    create list    ${a2MeasSCellRelEnabled}    ${a2MeasSCellRelSsbRsrp}

    COAM add several parameters via rest api    parameters_to_add_via_api=${params_to_add}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}

Modify radio link monitoring parameters work on scell
    [Documentation]   author: Dandan Fang
    ...    Online modify NIDD parameters to configure RLQ monitoring parameters on Scell.
    ...    Update parameter list:
    ...        MRBTS-10359/NRBTS-10359/NRCELL-1/sCellGoodChannelQualityThreshold=16
    ...        MRBTS-10359/NRBTS-10359/NRCELL-1/sCellBadChannelQualityThreshold=15
    ...        MRBTS-10359/NRBTS-10359/NRCELL-1/sCellDeactivationBadRlqCount=80
    ...        MRBTS-10359/NRBTS-10359/NRCELL-1/sCellChannelEstimationPeriod=2000
    [Arguments]    ${cell_index}=${SCELL_ID}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ...    ${badrlqcount}=${0}      ${period}=${2000}  ${goodthreshold}=${20}  ${badthreshold}=${15}
    ${sCellGoodChannelQualityThreshold}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='sCellGoodChannelQualityThreshold', value='${goodthreshold}')
    ${sCellBadChannelQualityThreshold}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='sCellBadChannelQualityThreshold', value='${badthreshold}')
    ${sCellChannelEstimationPeriod}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', parameter='sCellChannelEstimationPeriod', value='${period}')
        ${sCellDeactivationBadRlqCount}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='sCellDeactivationBadRlqCount', value='${badrlqcount}')

    ${params_to_upd}    create list    ${sCellGoodChannelQualityThreshold}    ${sCellBadChannelQualityThreshold}
    ...    ${sCellDeactivationBadRlqCount}       ${sCellChannelEstimationPeriod}

    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}

Verify A2 measurement config for scell released in cpif log
    [Documentation]    author: Dandan Fang
    ...           nr-rrc.measCycleSCell is related with Scell
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${filter}       set variable     (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.measCycleSCell)
    ${rrcReconfig}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}

    ${a2MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a2MeasType[0].split()[1]}

Verify A2 report for special cell in cpif log
    [Documentation]    author: Dandan Fang
    ...        procedureCode: id-ULRRCMessageTransfer  13
    [Arguments]    ${a2_rsrp_thres}=${60}    ${log_path_pcap}=${CPIF_LOG}   ${meas_id}=${2}
    ...           ${cellId}=${PCELL_ID}
    ${filter}       set variable     (f1ap.procedureCode == 13) && (f1ap.F1AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}

    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}

    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${a2_rsrp}  pcap.get_field_value_by_xpath
    ...    xpath=${xpath}      attribute_name=show

    should be true    ${a2_rsrp[0]} <= ${a2_rsrp_thres}

Get pcell list
    [Documentation]    Author: Liu Zheng
    ...    the ${SCELL_LIST} is set from ./../TestData/NODD_modify.py
    ...    this file is imported in suite setup in CA cases
    ${pcell_id_list}    create list
    FOR    ${pcell_info}    IN    @{PCELL_LIST}
        ${pcell_id}    set variable    ${pcell_info['nrCellId']}
        append to list    ${pcell_id_list}    ${pcell_id}
    END
    [Return]    ${pcell_id_list}

Get scell list
    [Documentation]    Author: Liu Zheng
    ...    the ${SCELL_LIST} is set from ./../TestData/NODD_modify.py
    ...    this file is imported in suite setup in CA cases
    ${scell_id_list}    create list
    FOR    ${scell_info}    IN    @{SCELL_LIST}
        ${scell_id}    set variable    ${scell_info['nrCellId']}
        append to list    ${scell_id_list}    ${scell_id}
    END
    ${scell_id_list}    remove_duplicates    ${scell_id_list}
    [Return]    ${scell_id_list}

############ log analysisl
Get cell pci and UE rnti in tcpdump
    [Documentation]   author: Wang Yixiang
    ...    Get attached cell id and rnti from f1ap log
    ...    1. get cell mapping relation(physical cell id and nrCellIdentity)from testline.
    ...    2. get NRCellIdentity from tcpdump
    ...    3. according to the mapping relation to get the physical cell id corresponding to NRCellIdentity from tcpdump
    ...    2021/08/30 Cui Lingxue: if ${cell_id} is given, use cell id to obtain pci and cell technology; otherwise, get cell id from ${PCELL_LIST}
    ...    and ${SCELL_LIST}.
    [Arguments]    ${tcpdump_log}    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${cell_id}=${None}
    ${return_dict}     create dictionary
    ${pcell_id_list}    Get pcell list
    ${scell_id_list}    Get scell list
    ${cell_id_list}    run keyword if    '${cell_id}'=='${None}'    combine lists    ${pcell_id_list}    ${scell_id_list}
    ...    ELSE    string2list    ${cell_id}
    &{physCellId_nrCellIdentity}    create dictionary
    &{physCellId_cellTechnology}    create dictionary
    FOR    ${cell}    IN   @{cell_id_list}
        ${nrCellIdentity}   Get SCF single Value from current xml file
        ...   parameter=nrCellIdentity   list_name=${None}   dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell}   p_index=${0}
        ...   alias=${connection}    config_type=configurationAndRuntimeObjects
        ${physCellId}   Get SCF single Value from current xml file
        ...   parameter=physCellId   list_name=${None}   dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell}   p_index=${0}
        ...   alias=${connection}    config_type=configurationAndRuntimeObjects
        ${cellTechnology}   Get SCF single Value from current xml file
        ...   parameter=cellTechnology   list_name=${None}   dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell}   p_index=${0}
        ...   alias=${connection}    config_type=configurationAndRuntimeObjects
        Set To Dictionary    ${physCellId_nrCellIdentity}    ${nrCellIdentity}    ${physCellId}
        Set To Dictionary    ${physCellId_cellTechnology}    ${physCellId}    ${cellTechnology}
    END
    ${pdml_list}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=nr-rrc||ngap
    ${nr_cell_identity_list}    pcap.get_field_value_by_name    field_name=ngap.NRCellIdentity    attribute_name=show
    ${rnti_list}    pcap.get_field_value_by_name    field_name=f1ap.C_RNTI    attribute_name=show
    ${scell_pci_list}    pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.sCellToAddModList//*//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ...      attribute_name=show
    ${scell_pci}    Remove Duplicates    ${scell_pci_list}
    ${nr_cell_identity}    Remove Duplicates    ${nr_cell_identity_list}
    ${count_nr_cell_identity}    get length    ${nr_cell_identity}
    ${rnti_list}    Remove Duplicates    ${rnti_list}
    ${nr_cell_identity}    Convert To Integer    ${nr_cell_identity}[-1]    16
    ${rnti}    set variable    ${rnti_list}[-1]
    ${pcell_pci}    set variable    ${physCellId_nrCellIdentity['${nr_cell_identity}']}
    log to console    \nUE attach to cell:${pcell_pci}, scell:${scell_pci}, rnti:${rnti}
    log to console    \nCell technology info:${physCellId_cellTechnology}\n
    Set To Dictionary	${return_dict}	  pcell=${pcell_pci}
    Set To Dictionary	${return_dict}	  rnti=${rnti}
    Set To Dictionary   ${return_dict}    scell=${scell_pci[0]}
    run keyword and continue on failure    should be true    '${count_nr_cell_identity}'=='1'
    [Return]    ${return_dict}


Check No Scell addition in tcpdump log
    [Documentation]    Private    Author: Wang Yixiang
    ...    The second RRC reconfig means CA addition, NO ca can check by there is no item "sCellToAddModList: 1 item"
    [Arguments]    ${tcpdump_log}
    Check msg item in tcpdump    tcpdump_log=${tcpdump_log}    msg_file=${CURDIR}/NO_CA.txt

Check Scell addition in tcpdump log
    [Documentation]    Private    Author: Wang Yixiang
    ...    The second RRC reconfig means CA addition, check item exist "sCellToAddModList: 1 item"
    ...    :param ${scell_addition_method}: blind or covBasedA1.
    [Arguments]    ${tcpdump_log}    ${scell_addition_method}=blind
    ${msg_file}    set variable if    '${scell_addition_method}'=='blind'    CA_exist.txt
    ...    '${scell_addition_method}'=='covBasedA1'    ScellAdd_covBasedA1.txt
    Check msg item in tcpdump    tcpdump_log=${tcpdump_log}    msg_file=${CURDIR}/${msg_file}

Check Scell release in tcpdump log
    [Documentation]    Private    Author: Dandan Fang
    ...    A2 report and trigger Scell released, "sCellToReleaseList: 1 item" will be included in rrc-reconfigured
    [Arguments]    ${tcpdump_log}
    Check msg item in tcpdump    tcpdump_log=${tcpdump_log}    msg_file=${CURDIR}/Scell_release.txt

Check A1 config in tcpdump log
    [Documentation]    Private    Author: Dandan Fang
    ...    When scell addition method as covBasedA1, A1 info should be configured with first rrc-reconfig.
    [Arguments]    ${tcpdump_log}
    Check msg item in tcpdump    tcpdump_log=${tcpdump_log}    msg_file=${CURDIR}/A1_configured_After-Attach.txt

Check scell activation in aasyslog
    [Documentation]     Author: Wang Yixiang
    ...    Check scell activation in aasyslog
    [Arguments]    ${log_name}=scell_activation.txt
    ${scell_activate_logs_trunk}     set variable    "handleActivateMacCe"
    ${scell_activate_logs_old}       set variable    "handleMacCe activation done"

    ${scell_activate_logs}   set variable if    '${PROGRAM}'=='25R1' or '${PROGRAM}'=='25R2' or '${PROGRAM}'=='25R3' or '${PROGRAM}'=='24R3'
    ...   ${scell_activate_logs_old}    ${scell_activate_logs_trunk}

    ${Aal2lo_cmd}=    catenate    cat /tmp/${log_name}| grep -a ${scell_activate_logs} | grep -av grep
    ${output}    csn.execute    command=${Aal2lo_cmd}    connection=ASIK Master
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    should be true    ${len}>0    Scell activation msg ${scell_activate_logs} not found in aasyslog

Get CSI slot in rrc msg
    [Documentation]    Author: Wang Yixiang
    ...    Get CSI slot in rrc msg
    [Arguments]    ${tcpdump_log}
    @{ret_csi_slot}    create list
    ${filtered_packets}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=f1ap||nr-rrc||ngap
    ${csi_slot_list}     pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.reportSlotConfig/nr-rrc.slots80
    ...     attribute_name=show
    @{csi_slot_list}    Remove Duplicates    ${csi_slot_list}
    FOR    ${csi_slot}    IN    @{csi_slot_list}
        ${csi_slot}    evaluate    ${csi_slot}%10
        append to list    ${ret_csi_slot}    ${csi_slot}
    END
    [Return]    ${ret_csi_slot}

Check csi beam report in biplog
    [Documentation]   author: Wang Yixiang
    ...    Check message item in tcpdump
    ...    numOfUciBitsInformation which shall be higher than 3bits for Csi/Beam report
    ...        ( 3 is the highest num of HARQ bits which can be reported on Pucch/Pusch in 1390)
    ...    on slot 5 => csi report for Pcell
    ...    on slot6 => csi report Scell
    ...    on slot7 => Beam report for Scell
    ...    check csi cycle: csiReportPeriodicity equals to csi send period(scell using pcell period)
    ...    itf_l2_ps_peerctrl_scellpucchreceiveindps means send csi report, beam report to scell from pcell
    ...    if pucchModeSelect=longPucch  => CSI can report via pucch and pusch
    ...    if pucchModeSelect=shortPucch  => CSI report only via pucch
    [Arguments]    ${tcpdump_log}    ${csi_slot_list}
    ${slot_list_ret}    create list
    ${beam_report_list}    create list
    ${scell_csi_report_list}    create list
    ${sfn_list_pcellslot}    create list
    ${pcell_slot}    set variable    ${csi_slot_list}[0]
    ${scell_slot}    set variable    ${csi_slot_list}[1]
    ${beam_slot}    set variable    ${csi_slot_list}[2]

    # >192 mens filter out 80,40,C0.  !=224 mean filter out E0
    # without beam refinement
    ${filter}   Catenate    uldata_pucchreceiverespps||uldata_puschreceiverespps

    # filter beam report
    ${filter_beam_item0}  Catenate  UlData_PucchReceiveRespPs.uciBits.uciBits_item_0
    ${filter_beam_item1}  Catenate  UlData_PucchReceiveRespPs.uciBits.uciBits_item_1
    ${filter_beam}  Catenate  UlData_PucchReceiveRespPs.PucchReceiveRespPs

    ${filter_pusch_uci}    set variable    UlData_PuschReceiveRespPs
    ${filter_pusch_slot}    set variable    PuschReceiveRespPs
    ${filter_pucch_uci}    set variable    UlData_PucchReceiveRespPs
    ${filter_pucch_slot}    set variable    PucchReceiveRespPs
    ${filter_pusch_peerctrl}    set variable    itf_l2_ps_peerctrl_ScellPuschReceiveIndPs

    ${pdml_list}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     lua_script=${LUA_SCRIPT_PATH}
    ...    filter=${filter}
    ${uci_item0_list_pusch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pusch_uci}.uciCsiPart1Bits.uciCsiPart1Bits_item_0
    ...    attribute_name=show
    ${uci_item1_list_pusch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pusch_uci}.uciCsiPart1Bits.uciCsiPart1Bits_item_1
    ...    attribute_name=show
    ${slot_list_pusch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pusch_uci}.${filter_pusch_slot}.slot
    ...    attribute_name=show
    ${uci_item0_list_pucch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pucch_uci}.uciBits.uciBits_item_0
    ...    attribute_name=show
    ${uci_item1_list_pucch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pucch_uci}.uciBits.uciBits_item_1
    ...    attribute_name=show
    ${slot_list_pucch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pucch_uci}.${filter_pucch_slot}.slot
    ...    attribute_name=show
    ${sfn_list_pusch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pusch_uci}.${filter_pusch_slot}.sfn
    ...    attribute_name=show
    ${sfn_list_pucch}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_pucch_uci}.${filter_pucch_slot}.sfn
    ...    attribute_name=show
    ${beam_item0_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_beam_item0}
    ...    attribute_name=show
    ${beam_item1_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_beam_item1}
    ...    attribute_name=show
    ${beam_slot_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_beam}.slot
    ...    attribute_name=show
    ${beam_sfn_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//${filter_beam}.sfn
    ...    attribute_name=show

    ${len_uci_pusch}    Get Length    ${uci_item0_list_pusch}
    ${len_slot_pusch}    Get Length    ${slot_list_pusch}
    ${len_uci_pucch}    Get Length    ${uci_item0_list_pucch}
    ${len_slot_pucch}    Get Length    ${slot_list_pucch}
    ${len_uci}    evaluate    ${len_uci_pusch}+${len_uci_pucch}
    ${len_slot}    evaluate    ${len_slot_pusch}+${len_slot_pucch}

    ${uci_item0_list_pusch}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${uci_item0_list_pusch}))
    ${uci_item1_list_pusch}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${uci_item1_list_pusch}))
    ${slot_list_pusch}    Evaluate    list(map(lambda x: str(int(x, 16)), ${slot_list_pusch}))
    ${uci_item0_list_pucch}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${uci_item0_list_pucch}))
    ${uci_item1_list_pucch}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${uci_item1_list_pucch}))
    ${slot_list_pucch}    Evaluate    list(map(lambda x: str(int(x, 16)), ${slot_list_pucch}))
    ${beam_item0_list}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${beam_item0_list}))
    ${beam_item1_list}    Evaluate    list(map(lambda x: bin(int(x, 16)), ${beam_item1_list}))
    ${beam_slot_list}    Evaluate    list(map(lambda x: str(int(x, 16)), ${beam_slot_list}))
    ${beam_sfn_list}    Evaluate    list(map(lambda x: str(int(x, 16)), ${beam_sfn_list}))
    ${sfn_list_pusch}    Evaluate    list(map(lambda x: str(int(x, 16)), ${sfn_list_pusch}))
    ${sfn_list_pucch}    Evaluate    list(map(lambda x: str(int(x, 16)), ${sfn_list_pucch}))

    # CSI report on pusch
    FOR    ${index}    ${slot_num}    IN ENUMERATE    @{slot_list_pusch}
        ${uci_item0_value}    set variable    ${uci_item0_list_pusch}[${index}]
        ${uci_item1_value}    set variable    ${uci_item1_list_pusch}[${index}]
        ${sfn_value}    set variable    ${sfn_list_pusch}[${index}]
        ${slot_num}     set variable    ${slot_list_pusch}[${index}]
        ${uci_bit_str}    set variable    ${uci_item0_value}${uci_item1_value}
        ${uci_bit_str}    Get Substring    ${uci_bit_str}    3    -1
        ${uci_bits_count}    Get Count    ${uci_bit_str}    1
        continue for loop if    ${uci_bits_count}==0
        run keyword if    '${slot_num}'=='${pcell_slot}'    append to list    ${sfn_list_pcellslot}    ${sfn_value}
        append to list    ${slot_list_ret}    ${slot_num}
    END

    # CSI report on pucch
    FOR    ${index}    ${slot_num}    IN ENUMERATE    @{slot_list_pucch}
        ${uci_item0_value}    set variable    ${uci_item0_list_pucch}[${index}]
        ${uci_item1_value}    set variable    ${uci_item1_list_pucch}[${index}]
        ${sfn_value}    set variable    ${sfn_list_pucch}[${index}]
        ${slot_num}     set variable    ${slot_list_pucch}[${index}]
        ${uci_bit_str}    set variable    ${uci_item0_value}${uci_item1_value}
        ${uci_bit_str}    Get Substring    ${uci_bit_str}    3    -1
        ${uci_bits_count}    Get Count    ${uci_bit_str}    1
        continue for loop if    ${uci_bits_count}==0
        run keyword if    '${slot_num}'=='${pcell_slot}'    append to list    ${sfn_list_pcellslot}    ${sfn_value}
        append to list    ${slot_list_ret}    ${slot_num}
    END

    # beam report on pucch
    FOR    ${index}    ${slot_num}    IN ENUMERATE    @{beam_slot_list}
        ${beam_item0_value}    set variable    ${beam_item0_list}[${index}]
        ${beam_item1_value}    set variable    ${beam_item1_list}[${index}]
        ${beam_slot_num}     set variable    ${beam_slot_list}[${index}]
        ${beam_bit_str}    set variable    ${beam_item0_value}${beam_item1_value}
        ${beam_bit_str}    Get Substring    ${beam_bit_str}    3    -1
        ${beam_bits_count}    Get Count    ${beam_bit_str}    1
        continue for loop if    ${beam_bits_count}==0
        append to list    ${slot_list_ret}    ${beam_slot_num}
    END

    ${pcell_slot}    evaluate    str(${pcell_slot})
    ${scell_slot}    evaluate    str(${scell_slot})
    ${beam_slot}    evaluate    str(${beam_slot})

    run keyword and continue on failure
    ...    should be true    ${len_uci}==${len_slot}     msg=UCI and slot should be match
    run keyword and continue on failure
    ...    List Should Contain Value    ${slot_list_ret}     ${pcell_slot}     msg=should contain slot ${pcell_slot}, csi report for Pcell
    run keyword and continue on failure
    ...    List Should Contain Value    ${slot_list_ret}     ${scell_slot}     msg=should contain slot ${scell_slot}, csi report for Scell
    run keyword and continue on failure
    ...    List Should Contain Value    ${slot_list_ret}     ${beam_slot}    msg=should contain slot ${beam_slot}, Beam report for Scell

    log     sfn_list_pcellslot:${sfn_list_pcellslot}
    ${cell1_csi_period}    Get NIDD value via rest api     parameter=csiReportPeriodicity    dist_name=${DN_PCELL_LIST[0]}
    ${slot_per_frame}    set variable    10
    ${actual_period}    evaluate    (${sfn_list_pcellslot}[1]+1024-${sfn_list_pcellslot}[0])%1024*${slot_per_frame}
    ${config_period}    Get Regexp Matches	 ${cell1_csi_period}	slots(\\d+)    1
    run keyword and continue on failure   should be true    '${actual_period}'=='${config_period}[0]'    msg=CSI period is not right

############ operation
Lock cell with graceful cell shutdown
    [Documentation]   author: Cui Lingxue
    ...    Lock cell using graceful shutdown method. In this way gNB perform DL power reduction for UE to re-select or handover to other cell
    ...    within a configured shutdownWindow.
    ...    Cell admin state will be 'ShuttingDown' for a while, will change to 'Locked' after configured shutdownWindow + 10sec.
    [Arguments]    ${cell_idx}=${PCELL_ID}    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${NRBTS_ID}    set variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    ${nidd_modify_via_api}    evaluate
    ...    [dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}', parameter='administrativeState', value='Shutting Down')]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${nidd_modify_via_api}  connection=${connection}  timeout=${timeout}

Verify cell administrative status
    [Documentation]   author: Cui Lingxue
    [Arguments]    ${expect_status}    ${cell_idx}=${1}    ${cell_group_idx}=${0}    ${connection}=GNB_OAM
    ${cell_status}    Get Cell Status    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}    connection=${connection}
    should_be_equal_as_strings    ${cell_status['administrativeState']}    ${expect_status}

WA force UE attach to FDD cell
    [Documentation]    Author: Wang Yixiang
    ...    Set TDD cell status to barred to force UE attach to FDD cell.
    ...    Unbar TDD cell in teardown.
    [Arguments]    ${un_barred_cell}=${PCELL_ID}
    _Force UE attach to cell    un_barred_cell=${un_barred_cell}

_Force UE attach to cell
    [Documentation]    Author: Wang Yixiang
    ...    Set cell status to barred to force UE attach to another cell.
    ...    Unbar cell in teardown.
    [Arguments]    ${un_barred_cell}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${un_barred_cell}
    run keyword and ignore error    Retry commercial ue detach if failed
    run keyword and ignore error    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=False   retry_time=2
    run keyword and ignore error    Retry commercial ue detach if failed
    [Teardown]     run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred

WA disable neighbour gnb cells
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to set all cells to barred status on specific gNB to avoid UE attach.
    [Arguments]    ${gnb_index}=${1}    ${number_of_cells}=${2}    ${connection}=GNB_OAM_1    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${param_list}    create list
    FOR    ${cell_index}    IN RANGE    ${number_of_cells}
        ${cell_index}    evaluate    ${cell_index}+1
        ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=barred
        append to list    ${param_list}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}  timeout=${timeout}

WA disable all neighbour gnb cells
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to disable all neighbour cells on all neighbour gNB by setting cell status to 'barred'.
    ...    Hence UE will not attach to those cells.
    ${gnb_numbers}    get length    ${tl.gnbs}
    ${connection_list}    create list
    FOR    ${gnb_index}    IN RANGE    ${gnb_numbers}
        continue_for_loop_if    ${gnb_index}==${0}
        Connect to gnb coam via ssl
        ...    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
        ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
        ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
        ...    connection=GNB_OAM_${gnb_index}
        append to list    ${connection_list}    GNB_OAM_${gnb_index}
        ${cells_info_list}    coam.get_cells_info    connection=GNB_OAM_${gnb_index}
        ${cell_numbers}    get length    ${cells_info_list}
        WA disable neighbour gnb cells    gnb_index=${gnb_index}    number_of_cells=${cell_numbers}    connection=GNB_OAM_${gnb_index}
    END
    [Teardown]    run keyword and ignore error    COAM Teardown multiple gnb connections    connection_list=${connection_list}

Enable neighbour gnb cells
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${gnb_index}=${1}    ${number_of_cells}=${2}    ${connection}=GNB_OAM_1    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${param_list}    create list
    FOR    ${cell_index}    IN RANGE    ${number_of_cells}
        ${cell_index}    evaluate    ${cell_index}+1
        ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=notBarred
        append to list    ${param_list}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}

Enable all neighbour gnb cells
    ${gnb_numbers}    get length    ${tl.gnbs}
    ${connection_list}    create list
    FOR    ${gnb_index}    IN RANGE    ${gnb_numbers}
        continue_for_loop_if    ${gnb_index}==${0}
        Connect to gnb coam via ssl
        ...    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
        ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
        ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
        ...    connection=GNB_OAM_${gnb_index}
        append to list    ${connection_list}    GNB_OAM_${gnb_index}
        ${cells_info_list}    coam.get_cells_info    connection=GNB_OAM_${gnb_index}
        ${cell_numbers}    get length    ${cells_info_list}
        Enable neighbour gnb cells    gnb_index=${gnb_index}    number_of_cells=${cell_numbers}    connection=GNB_OAM_${gnb_index}
    END
    [Teardown]    run keyword and ignore error    COAM Teardown multiple gnb connections    connection_list=${connection_list}

Start UL data transfer and verify NO Scell is activated
    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    Prepare and start aasyslog
    Start data transfer based on direction    data_transfer_direction=ul    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${duration}
    sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should not be true    ${is_scell_activated}
    [Teardown]    Teardown the Aasyslog save progress

Start DL data transfer and verify Scell is activated
    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    Prepare and start aasyslog
    Start data transfer based on direction    data_transfer_direction=dl    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${duration}
    sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should be true    ${is_scell_activated}
    [Teardown]    Teardown the Aasyslog save progress

Start Small DL data transfer and verify Scell is inactivated For Bufferbased
    [Documentation]    Private    Author: Dandan Fang
    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    Prepare and start aasyslog
    Start data transfer based on direction    data_transfer_direction=dl    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${duration}
    sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should not be true    ${is_scell_activated}
    [Teardown]    Teardown the Aasyslog save progress

Import NIDD variables
    [Documentation]  Author: Wang Yixiang
    ...              This keyword is to set several variables by program.
    [Arguments]    ${if_vonr_conf_needed}=${False}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    connect to gnb coam via ssl
    import variables    commissionings/HGZ/${testline_name}/__init__.py
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_1390.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_restapi.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_WebUI.py
    import resource     ${CURDIR}/../Resources/CA_variables.robot
    run keyword if    ${if_vonr_conf_needed}==${True}    import variables   ${CURDIR}/../TestData/vonr_nidd_add_or_modify.py


check Scell deactivated
    [Documentation]   author: fang ludan
    ...     stop data transfer and check scell deactivated form syslog
    ...     wait sCellDeactivationTimerGNB expire, and scell deactive msg print in aasyslog
    ...     just for bufferbased
    ...    ${scell_id}: scell id, can be 1 or 1,2
    ...    ${scell_operator_mode}: scell operational mode, can be dl_only or dl_only,dlAndUl
    [Arguments]    ${scell_operator_mode}=dl_only    ${scell_id}=${SCELL_ID}
    Prepare and start aasyslog   log_name=scell_deactivation.txt
    Stop data transfer based on direction
    Run keyword and continue on failure    Stop aasyslog to check scell deactivation    scell_id=${scell_id}
    ...      scell_operator_mode=${scell_operator_mode}

Stop aasyslog to check scell deactivation
    [Documentation]   author: fang ludan
    ...      check scell deactivated form syslog
    ...      support bufferbased and qualitybased
    ...    ${scell_id}: scell id, can be 1 or 1,2
    ...    ${scell_operator_mode}: scell operational mode, can be dl_only or dl_only,dlAndUl
    ...    ${sCelldeactivationMethod}: can be bufferbased or qualitybased.
    [Arguments]    ${timeout}=40s    ${log_name}=scell_deactivation.txt
    ...    ${sCelldeactivationMethod}=bufferbased     ${scell_operator_mode}=dl_only    ${scell_id}=${SCELL_ID}
    ...    ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}
    Connect to Common Unit Master
    ${scell_id}    string2list    ${scell_id}
    ${scell_operator_mode}    string2list    ${scell_operator_mode}
    ${len_scell_id}    evaluate    len(${scell_id})
    ${len_scell_operator_mode}    evaluate    len(${scell_operator_mode})
    should be equal    ${len_scell_id}    ${len_scell_operator_mode}    msg=The number of scell and scell operational type should be the same!

    FOR    ${index}    ${sCellOperationalMode}    IN ENUMERATE    @{scell_operator_mode}
        ${scell_NrCellId}    set variable    ${scell_id[${index}]}
        wait until keyword succeeds    ${timeout}    2 sec    Check scell deactivation in aasyslog    log_name=${log_name}
        ...    sCelldeactivationMethod=${sCelldeactivationMethod}    scell_operator_mode=${sCellOperationalMode}    scell_id=${scell_NrCellId}
        ...    nr_cell_id_mapping=${nr_cell_id_mapping}    timeout=${timeout}
    END
    [Teardown]    Teardown the Aasyslog save progress

Check scell deactivation in aasyslog
    [Documentation]     Author: fang ludan
    ...    Check scell deactivation in aasyslog
    ...    ${scell_id}: scell id, str or int
    ...    ${scell_operator_mode}: scell operational mode, str, can be dl_only or dlAndUl
    ...    ${sCelldeactivationMethod}: can be bufferbased or qualitybased.
    [Arguments]    ${log_name}=scell_deactivation.txt   ${sCelldeactivationMethod}=bufferbased
    ...            ${scell_operator_mode}=dl_only    ${scell_id}=${SCELL_ID}    ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${timeout}=40s
    ${bufferbase_deactive_dl_only}     set variable    DL_ONLY deact-timer expiry.
    ${bufferbase_deactive_dl_ul}       set variable    scell was deactivated.
    ${bufferbase_deactive_info}   set variable if    '${scell_operator_mode}'=='dl_only'  ${bufferbase_deactive_dl_only}
    ...   ${bufferbase_deactive_dl_ul}
    ${qualitybased_deactive_info}   set variable        RlqAlgorithm prepare sending SCellStatusInd with permanent deactivation for rnti
    ${deactive_info}   set variable if    '${sCelldeactivationMethod}'=='bufferbased'  ${bufferbase_deactive_info}
    ...   ${qualitybased_deactive_info}

    ${scell_index_prefix}    set variable if    '${scell_operator_mode}'=='dl_only'    sCellIndex:    servCellIndex=
    ${scell_NrCellIdentity}    set variable    ${nr_cell_id_mapping[${scell_id}]['nrCellIdentity']}
    ${scell_index}    wait until keyword succeeds    ${timeout}    2 sec    Get scellIndex by NrCellIdentity in aasyslog    log_name=${log_name}
    ...    NrCellIdentity=${scell_NrCellIdentity}

    ${Aal2lo_cmd}=    run keyword if    '${sCelldeactivationMethod}'=='bufferbased'
    ...    catenate    cat /tmp/${log_name}| grep -a "${deactive_info}" | grep  -a "${scell_index_prefix}${scell_index}" | grep -av grep
    ...    ELSE IF    '${sCelldeactivationMethod}'=='qualitybased'    catenate    cat /tmp/${log_name}| grep -a "${deactive_info}" |grep -av grep
    ...    ELSE    fail    msg=sCelldeactivationMethod can only be 'bufferbased' or 'qualitybased', other value is invalid.
    ${output}    csn.execute    command=${Aal2lo_cmd}    connection=ASIK Master
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    run keyword and continue on failure    should be true    ${len}>0
    ...    Scell ${scell_index}(NrCellIdentity: ${scell_NrCellIdentity}) deactivation msg not found in aasyslog

Get scellIndex by NrCellIdentity in aasyslog
    [Documentation]     Author: Lingxue Cui
    ...    By given NrCellIdentity of scell, get the scellIndex in return.
    ...    The mapping relation is printed in aasyslog when scell is deactivated.
    ...    eg. 920180-EQ_L2_PS_DL_CA_ INF/L2-PS/src/dl/sch/ca/RemoteDlSCellActivationManager.cpp[1069] updateDeactRespStatus  DeactResp for UE 33012
    ...        sCellId:161013 sCellIndex:2
    [Arguments]    ${NrCellIdentity}    ${log_name}=scell_deactivation.txt
    ${cmd_get_scell_index_old}    catenate  cat /tmp/${log_name}| grep -a "RemoteDlSCellActivationManager" |
    ...    grep -aE "[sCellId|nrCellIdentity]:${NrCellIdentity}" | grep -aoE "sCellIndex:[0-9]+" | grep -oE "[0-9]+" | grep -av grep

    ${cmd_get_scell_index_trunk}     catenate    cat /tmp/${log_name}| grep -a "RemoteDlSCellActivationManager" |
    ...    grep -aE "[sCellId|nrCellIdentity]=${NrCellIdentity}" | grep -aoE "sCellIndex=[0-9]+" | grep -oE "[0-9]+" | grep -av grep

    ${cmd_get_scell_index}   set variable if    '${PROGRAM}'=='25R1' or '${PROGRAM}'=='25R2' or '${PROGRAM}'=='25R3' or '${PROGRAM}'=='24R3'
    ...   ${cmd_get_scell_index_old}    ${cmd_get_scell_index_trunk}

    ${output}    csn.execute    command=${cmd_get_scell_index}    connection=ASIK Master

    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${list}    remove_duplicates    ${list}
    ${len}    Get Length    ${list}
    should be true    ${len}>0    Scell ${NrCellIdentity} deactivation msg not found in aasyslog
    ${scell_index}    fetch_from_right    ${list[${0}]}    marker=:
    ${scell_index}    strip string    ${scell_index}
    [Return]    ${scell_index}

Disable cDRX via restapi
    [Documentation]   author: Cui Lingxue
    [Arguments]    ${NSA_SA}=SA    ${connection}=GNB_OAM
    log to console    Disable cDRX function via restapi...
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}

    ${delta_file_list_reverse}   Modification of NIDD parameters via restapi    param_to_upd=${RESTAPI_DISABLE_DRX}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    connection=${connection}    is_need_to_setup_gnb_connection=${False}
    ...    is_all_cells_checking_needed=${True}
    [Return]    ${delta_file_list_reverse}

Enable cDRX and configure DRX profile
    [Documentation]   author: Cui Lingxue
    [Arguments]    ${is_drx_cycle_above_80ms}=${True}   ${NSA_SA}=SA    ${connection}=GNB_OAM
    log to console    Enable cDRX function via restapi...
    ${parameters_to_update_via_api}    set variable if    ${is_drx_cycle_above_80ms}    ${RESTAPI_ENABLE_DRX}    ${RESTAPI_ENABLE_DRX_BELOW80}
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}

    ${delta_file_list_reverse}   Modification of NIDD parameters via restapi    param_to_upd=${parameters_to_update_via_api}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}
    ...    connection=${connection}    is_need_to_setup_gnb_connection=${False}
    ...    is_all_cells_checking_needed=${True}
    [Return]    ${delta_file_list_reverse}

Verify ping latency within allowed range
    [Documentation]    Author: Cui Lingxue
    ...    The max ping latency should be less than 'background ping latency' + 'DRX sleep duration' + 'SR period'.
    ...    ${sr_period} unit is ms.
    [Arguments]    ${ping_latency_wi_drx}    ${ping_latency_wo_drx}    ${retry_time}=${5}    ${is_drx_cycle_above_80ms}=${True}
    ...    ${sr_period}=80
    ${drx_sleep_duration}    set variable if    '${is_drx_cycle_above_80ms}'=='${True}'    150    70
    ${max_latency}    evaluate    ${drx_sleep_duration}+${sr_period}
    run keyword and continue on failure    should be true    ${ping_latency_wi_drx['avg']}>${ping_latency_wo_drx['avg']}
    ...    msg=Average ping latency with cDRX on should be larger than without cDRX.
    FOR    ${i}    IN RANGE    ${retry_time}
        ${ping_latency}    set variable    ${ping_latency_wi_drx['details'][${i}]}
        ${result}    run keyword and return status
        ...    should be true    ${ping_latency} - ${ping_latency_wo_drx['max']} < ${max_latency}
        exit_for_loop_if   '${result}'=='True'
    END
    should be true    ${result}    msg=Max ping latency with cDRX on should be larger than without cDRX.


Pcell id and scell id redefined in order to match with different pcell
    [Documentation]    Author: Dandan Fang
    ...    Support Pcell change between 1390 and 2329, Just support 1 FDD 1 TDD environment
    ...    Happened when A1 based or A2 based on Pcell , trigger PCell change
    ...    parameters 2329_enable: when 2329_enable as false, Pcell as FDD, Scell as TDD, else Pcell as TDD, Scell as FDD
    [Arguments]    ${ca_group_type}=F+T
    run keyword if    '${ca_group_type}'=='T+F'   Run Keywords
    ...       set test variable   ${PCELL_ID}    ${TDD_CELLS[0]['nrCellId']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${TDD_CELLS[0]['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_ID}    ${FDD_CELLS[0]['nrCellId']}
    ...       AND    set test variable   ${SCELL_RU_INDEX}    ${FDD_CELLS[0]['ru_index_in_testline_file']}
    ...       AND    set test variable   ${PCELL_EXP_DL}    1200
    ...       AND    set test variable   ${PCELL_EXP_UL}    100
    ...       AND    set test variable   ${SCELL_EXP_DL}    150
    ...       AND    set test variable   ${CA_GROUP_TYPE}    T+F
    ...       ELSE    Run Keywords
    ...       set test variable   ${PCELL_ID}    ${FDD_CELLS[0]['nrCellId']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${FDD_CELLS[0]['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_ID}    ${TDD_CELLS[0]['nrCellId']}
    ...       AND    set test variable   ${SCELL_RU_INDEX}    ${TDD_CELLS[0]['ru_index_in_testline_file']}
    ...       AND    set test variable   ${PCELL_EXP_DL}    150
    ...       AND    set test variable   ${PCELL_EXP_UL}    50
    ...       AND    set test variable   ${SCELL_EXP_DL}    1200
    ...       AND    set test variable   ${CA_GROUP_TYPE}    F+T

Get scell info under specific cell
    [Documentation]    Author: Cui Lingxue
    ...    Get all the scells info including lcrid/nrrel_id/sCellOperationalMode under specific pcell, eg.
    ...    {1: {'lcrid': 1, 'nrrel_id': '1', 'sCellOperationalMode': 'dlAndUl'},
    ...     5: {'lcrid': 5, 'nrrel_id': '2', 'sCellOperationalMode': 'dlOnly'}}
    [Arguments]    ${pcell_id}    ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${connection}=GNB_OAM
    ${nrrel_info}    coam_gnb_classical.get_nrrel_under_specific_cell    source_cell_id=${pcell_id}    connection_alias_source=${connection}

    ${list_nrrel_id}    set variable    ${nrrel_info['nrrel_ids']}
    &{dict_lcrid}    create dictionary
    FOR    ${index}    IN RANGE    len(@{list_nrrel_id})
        ${nrrel_id}    set variable    ${nrrel_info['nrrel_mo_info'][${index}]['nrrel_id']}
        ${lcrid}    set variable    ${nrrel_info['nrrel_mo_info'][${index}]['parameters']['lcrId']}
        ${sCellOperationalMode}    set variable    ${nrrel_info['nrrel_mo_info'][${index}]['parameters']['sCellOperationalMode']}
        &{dict_info}    create dictionary    lcrid=${lcrid}    nrrel_id=${nrrel_id}    sCellOperationalMode=${sCellOperationalMode}
        Set To Dictionary    ${dict_lcrid}    ${lcrid}    ${dict_info}
    END

    &{dict_scell_nrrel}    create dictionary
    ${list_cell_id}    get_dictionary_keys    ${nr_cell_id_mapping}
    FOR    ${cell_id}    IN    @{list_cell_id}
        ${lcrid}    set variable    ${nr_cell_id_mapping[${cell_id}]['lcrId']}
        ${status}    run keyword and return status    dictionary_should_contain_key    ${dict_lcrid}    ${lcrid}
        continue for loop if  '${status}'=='${False}'
        set to dictionary    ${dict_scell_nrrel}    ${cell_id}    ${dict_lcrid[${lcrid}]}
    END
    [Return]    ${dict_scell_nrrel}

Get operational mode by scell id
    [Documentation]    Author: Cui Lingxue
    ...    By given the scell id, return with scell's operational mode.
    ...    eg. scell_id: [1, 5], return: ['dlAndUl', 'dl_only']
    [Arguments]    ${pcell_id}=${PCELL_ID}    ${scell_id}=${SCELL_ID_DL_ADD}    ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${connection}=GNB_OAM
    ${list_scell_id}    string2list    ${scell_id}

    &{dict_scell_nrrel}    Get scell info under specific cell    pcell_id=${pcell_id}    nr_cell_id_mapping=${nr_cell_id_mapping}
    ...    connection=${connection}

    ${list_scellOperationalMode}    create list
    FOR    ${scell_id}    IN    @{list_scell_id}
        ${scellOperationalMode}    set variable    ${dict_scell_nrrel[${scell_id}]['sCellOperationalMode']}
        ${scellOperationalMode}    set variable if    '${scellOperationalMode}'=='dlOnly'    dl_only    ${scellOperationalMode}
        append to list    ${list_scellOperationalMode}    ${scellOperationalMode}
    END
    [Return]    ${list_scellOperationalMode}

Get scell OperatorMode info base on Scell DL List
    [Documentation]    Author: Dandan Fang
    ...    Input Parameters
    ...    dl_scell_list : all Scell ID which includs DL. Same with SCELL_ID_DL_ADD, value [1, 3, 5]
    ...    ca_group_mapping : Suite or test variable CA_GROUP_MAPPING, denifed in __init_XX__init.py
    ...    connection : which gnb nrrel checked, maybe consider 8140 interGNB CA. If no , use default GNB_OAM.
    ...    OutPut Result
    ...    {dl_scellOperationalMode} = ['dlAndUl', 'dl_only', 'dl_only']
    [Arguments]    ${ca_group_mapping}     ${dl_scell_list}=${1}       ${connection}=GNB_OAM
    Should Not Be Empty    ${ca_group_mapping}

    #first get gnb index which nrrel config related.
    ${ca_nrrelinfo}    create list
    ${ca_nrrelinfo}    set variable      ${ca_group_mapping['nrrel_info']}
    ${gnb_index}   set variable  ${0}
    FOR    ${index}    IN RANGE    len(@{ca_nrrelinfo})
         ${gnb_index}      set variable  ${index}
         Exit for loop if     '${ca_nrrelinfo[${index}]['gnb_connection_alias']}' == '${connection}'
    END
    #use gnb index to get nrrel config ,1 to 1 mapping
    ${dict_ca_nrrel_config_gnb}  copy dictionary   ${ca_nrrelinfo[${gnb_index}]['nrrel_config']}   deepcopy=${TRUE}
    ${list_scellOperationalMode}    create list
    FOR    ${scell_id}    IN    @{dl_scell_list}
        ${sCellOperationalMode_init}    set variable    ${dict_ca_nrrel_config_gnb[${scell_id}]['sCellOperationalMode']}
        ${scellOperationalMode}    set variable if    '${sCellOperationalMode_init}'=='dlOnly'    dl_only    ${sCellOperationalMode_init}
        append to list    ${list_scellOperationalMode}    ${scellOperationalMode}
    END
    [Return]    ${list_scellOperationalMode}

Get CC num base UE type from testline config
    [Documentation]  Author: Dandan Fang
    ...    exp_cc_num_in_use: 3CC, 4CC, 5CC ${None}
    ...    if set as 3CC or 4CC will return the input value directly, otherwise will judge based on ue type.
    ...    sdx65: 3CC
    ...    sdx70: 4CC
    ...    sdx75: 5CC
    ...    return: 3CC / 4CC  /5CC
    ...    Original define in 6137 keywords. name is Get CC num in use based on UE type from test line config file
    [Arguments]  ${exp_cc_num_in_use}=${None}
    @{supported_cc_num}    Create List    3CC    4CC     5CC     6CC
    ${act_cc_num_in_use}    Run keyword if    '${exp_cc_num_in_use}' in @{supported_cc_num}
    ...    Set variable    ${exp_cc_num_in_use}
    ...    ELSE IF    'sdx80' in @{tl.ues[0].capabilities}    Set variable    6CC
    ...    ELSE IF    'sdx75' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx70_dlonly' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx65' in @{tl.ues[0].capabilities}    Set variable    3CC
    ...    ELSE    Set variable    3CC
    [Return]  ${act_cc_num_in_use}

_generate individual tput value for cells when no CA exist based on ca group mapping
    [Documentation]  Author: Ding Binmei
    ...    Note: For UL CA: only 1 layer when with UL CA. If without UL CA, ul tput has 2 layers
    ...    if exp_ul_indiv_no_ca / exp_dl_indiv_no_ca is defined in ${ca_group_mapping}, then will use values in ${ca_group_mapping}
    ...    Otherwise, will auto generate expected result for exp_ul_indiv_no_ca / exp_dl_indiv_no_ca.
    ...    use tput value for pcell in ${ca_group_mapping['exp_ul_indiv']}/${ca_group_mapping['exp_dl_indiv']} and set scell values as 0
    ...    Example output: [[148, 0], [1469, '0', '0', '0']]
    [Arguments]    ${ca_group_mapping}
    ${exp_ul_indiv}       Set variable    ${ca_group_mapping['exp_ul_indiv']}
    ${exp_dl_indiv}       Set variable    ${ca_group_mapping['exp_dl_indiv']}
    ${cc_num}    Get length    ${exp_ul_indiv}
    ${exp_ul_indiv_no_ca}    Create list
    ${exp_dl_indiv_no_ca}    Create list
    FOR    ${index}    ${tput_for_cells}    IN ENUMERATE    @{exp_ul_indiv}
        Run keyword if  ${index}==0 or ${tput_for_cells}==-1    Append to list    ${exp_ul_indiv_no_ca}    ${tput_for_cells}
        ...    ELSE    Append to list    ${exp_ul_indiv_no_ca}    ${0}
        Run keyword if  ${index}==0    Append to list    ${exp_dl_indiv_no_ca}    ${exp_dl_indiv[${index}]}
        ...    ELSE    Append to list    ${exp_dl_indiv_no_ca}    ${0}
    END
    ${keys_for_ca_group_mapping}    Get dictionary keys    ${ca_group_mapping}
    ${exp_ul_indiv_no_ca}    Set variable if    'exp_ul_indiv_no_ca' in @{keys_for_ca_group_mapping}    ${ca_group_mapping["exp_ul_indiv_no_ca"]}
    ...    ${exp_ul_indiv_no_ca}
    ${exp_dl_indiv_no_ca}    Set variable if    'exp_dl_indiv_no_ca' in @{keys_for_ca_group_mapping}    ${ca_group_mapping["exp_dl_indiv_no_ca"]}
    ...    ${exp_dl_indiv_no_ca}
    [Return]  ${exp_ul_indiv_no_ca}  ${exp_dl_indiv_no_ca}

Decode CA group mapping and set CA Cell variable
    [Documentation]  Author: Fang Dandan
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    Original define in 6137 keywords. name is Get CC num in use based on UE type from test line config file
    [Arguments]  ${exp_cc_num_in_use}=${None}    ${ca_group_mapping_3cc}=${None}    ${ca_group_mapping_4cc}=${None}
    ...    ${ca_group_mapping_5cc}=${None}    ${ca_group_mapping_6cc}=${None}  ${is_called_in_suite_level}=${False}
    ${CC_NUM}    Get CC num base UE type from testline config    exp_cc_num_in_use=${exp_cc_num_in_use}
    ${ca_group_mapping_in_use}     run keyword if   '${CC_NUM}'=='3CC'
    ...     Set variable     ${ca_group_mapping_3cc}
    ...     ELSE IF   '${CC_NUM}'=='4CC'        Set variable     ${ca_group_mapping_4cc}
    ...     ELSE IF   '${CC_NUM}'=='5CC'        Set variable     ${ca_group_mapping_5cc}
    ...     ELSE IF   '${CC_NUM}'=='6CC'        Set variable     ${ca_group_mapping_6cc}

    ${pcell_id_list}    create list    ${ca_group_mapping_in_use['pcell_id']}
    ${CELL_INDEX_LIST}    combine lists    ${pcell_id_list}    ${ca_group_mapping_in_use['verify_scell_add_dl']}

    ${INIT_PA_VALUE}   Set variable    ${ca_group_mapping_in_use['init_pa_value']}
    ${EXP_UL_INDIV_NO_CA}  ${EXP_DL_INDIV_NO_CA}    _generate individual tput value for cells when no CA exist based on ca group mapping
    ...    ca_group_mapping=${ca_group_mapping_in_use}

    run keyword if    ${is_called_in_suite_level}    Run keywords
    ...    Set suite variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set suite variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set suite variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set suite variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set suite variable    ${CELL_INDEX_LIST}    AND
    ...    Set suite variable    ${CC_NUM}             AND
    ...    Set suite variable    ${EXP_DL_INDIV}       ${ca_group_mapping_in_use['exp_dl_indiv']}       AND
    ...    Set suite variable    ${EXP_UL_INDIV}        ${ca_group_mapping_in_use['exp_ul_indiv']}     AND
    ...    Set suite variable    ${INIT_PA_VALUE}    AND
    ...    Set suite variable    ${EXP_UL_INDIV_NO_CA}    AND
    ...    Set suite variable    ${EXP_DL_INDIV_NO_CA}
    ...    ELSE    Run keywords
    ...    Set test variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set test variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set test variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set test variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set test variable    ${CELL_INDEX_LIST}    AND
    ...    Set test variable    ${CC_NUM}             AND
    ...    Set test variable    ${EXP_DL_INDIV}       ${ca_group_mapping_in_use['exp_dl_indiv']}     AND
    ...    Set test variable    ${EXP_UL_INDIV}       ${ca_group_mapping_in_use['exp_ul_indiv']}    AND
    ...    Set test variable    ${INIT_PA_VALUE}    AND
    ...    Set test variable    ${EXP_UL_INDIV_NO_CA}    AND
    ...    Set test variable    ${EXP_DL_INDIV_NO_CA}
