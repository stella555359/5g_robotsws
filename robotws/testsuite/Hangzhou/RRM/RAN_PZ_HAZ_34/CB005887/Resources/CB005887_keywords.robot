*** Settings ***
Resource    ../Resources/CB005887_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_other.robot
Variables   ../TestData/CB005887_SCF_modify.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001596_D/Resources/5GC001596_D_Keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001596_F/Resources/5GC001596_F_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot


*** Variables ***

${PATH_COMMON}          nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.uplinkConfigCommon_element

*** Keywords ***
########## NIDD online modification
Set 5GC001120 deactive without CA and check alarm
    [Documentation]   author: Zhang Ningning
    Modify nidd parameters on WebUI via rest api    Deactive_1120_NIDD_para_disabled_CA=${Deactive_1120_NIDD_para_disabled_CA}
    Wait Until Keyword Succeeds    15min    30sec    get alarms 1868

Set maxNumScellsUl to 2
    [Documentation]   author: Zhang Ningning
    [Arguments]    ${modify_set_maxNumScellsUl_2}    ${timeout_restapi}=5 min
    ...    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_set_maxNumScellsUl_2}  timeout=${timeout_restapi}
    ...    connection=${connection}
    Verify all cells should be onair

Set maxNumScellsUl to 3
    [Documentation]   author: Zhang Ningning
    [Arguments]    ${modify_set_maxNumScellsUl_3}    ${timeout_restapi}=5 min
    ...    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_set_maxNumScellsUl_3}  timeout=${timeout_restapi}
    ...    connection=${connection}
    Verify all cells should be onair

Modify nidd parameters on WebUI via rest api
    [Documentation]    Author: Zhang Ningning
    ...    Use this keyword to update nidd paramter related to 1120 via rest api and verify alarms.
    [Arguments]    ${Deactive_1120_NIDD_para_disabled_CA}     ${timeout_restapi}=5 min
    ...    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${Deactive_1120_NIDD_para_disabled_CA}   timeout=${timeout_restapi}
    ...    connection=${connection}

get alarms 1868
    [Documentation]    Author: Zhang Ningning
    ...                Description: Collect active alarms and write the alarms to file
    [Arguments]      ${connection}=GNB_OAM
    @{output_alarms}    coam_gnb_classical.COAM Get active alarms    connection=${connection}
    ${alarm_number}    set variable    ${0}
    FOR    ${element}    IN    @{output_alarms}
        ${alarm_number}    Run keyword if    ${element['faultId']} == ${1868}    Evaluate    ${alarm_number}+1
    ...    ELSE    set variable    ${alarm_number}
    END
    Should be true   ${alarm_number}==${2}

Call case with QCOM UE and record throughput info on specific cell with protocal
    [Documentation]    Author: fang ludan
    [Arguments]     ${gnb_ps_cell_index}   ${para_update_timeout}=6 min
    ...    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${exp_tput_percentage}=1    ${verify_duration}=${60}
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}

    ...    ${ignore_time}=30s    ${data_transfer_direction}=both    ${traffic_duration}=3000s
    ...    ${seg_size}=1350    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M   ${protocol}=udp
    ...    ${ue_type}=${UE_TYPE}    ${retry_time}=3    ${ue_index}=${0}    ${prepare_ue_needed}=${False}
    ...    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}

    ${cell_mapping_gnb_rnb}    run keyword if    ${gnb_ps_cell_index}<=8    set variable    ${gnb_ps_cell_index}
    ...    ELSE IF    8<${gnb_ps_cell_index}<=16    evaluate   ${gnb_ps_cell_index}-6
    ...    ELSE IF    16<${gnb_ps_cell_index}<=24   evaluate   ${gnb_ps_cell_index}-12
    ...    ELSE    Fail    msg=for feature 1596, there should no cells whose cell id is larger than 24
    run keyword if    ${sgnb_addition_on_spec_cell_needed}    Make SgNBAddition on specific cell
    ...     gnb_ps_cell_index=${cell_mapping_gnb_rnb}    para_update_timeout=${para_update_timeout}    alias=enblte
    ${status}    Run keyword and return status    5887 L3 call check tput via power UE     cell_id=${gnb_ps_cell_index}
    ...    dl_tput=${DL_THROUGHPUT}    ul_tput=${UL_THROUGHPUT}  protocol=${protocol}
    ...    exp_ul=${ul_exp_tput}    exp_dl=${dl_exp_tput}    tput_check_duration=${verify_duration}
    ...    ignore_time=${ignore_time}    actCarrierAggregation=${False}    data_transfer_direction=${data_transfer_direction}
    ...    traffic_duration=${traffic_duration}    seg_size=${seg_size}
    ...    iperf_ul_port=${iperf_ul_port}    iperf_dl_port=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    iperf_type_ul=${iperf_type_ul}    window=${window}
    ...    ue_type=${ue_type}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    detach_request=${detach_request}    connection=${connection}    is_ue_reboot=${is_ue_reboot}
    ...    target_avg_percent=${exp_tput_percentage}
    Should be true    '${status}' == '${True}'



Call case with QCOM UE and record throughput info for many cells many times with protocal
    [Documentation]    Author: Fang ludan
    ...    ${GNB_PS_CELL_INDEX_LIST} is the cell list which can do attach. it is set in variables.robot.
    [Arguments]   ${para_update_timeout}=6 min    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${duration_time}=${3000}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${cell_index_list}=${CELL_INDEX_LIST}    ${exp_tput_percentage}=1
    ...    ${verify_duration}=${60}   ${protocal}=udp   ${data_transfer_direction}=both
    ...    ${sgnb_addition_on_spec_cell_needed}=${True}
    FOR    ${cell_index}    IN    @{cell_index_list}
        run keyword if   '${cell_index}' in @{GNB_PS_CELL_INDEX_LIST}
        ...    run keywords    Retry commercial ue detach if failed    AND
        ...    Call case with QCOM UE and record throughput info on specific cell with protocal
        ...    gnb_ps_cell_index=${cell_index}    traffic_duration=${duration_time}
        ...    data_transfer_direction=${data_transfer_direction}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}   protocol=${protocal}
        ...    exp_tput_percentage=${exp_tput_percentage}    verify_duration=${verify_duration}
        ...    sgnb_addition_on_spec_cell_needed=${sgnb_addition_on_spec_cell_needed}
        ...    ELSE    log to console    ${cell_index} not in \${GNB_PS_CELL_INDEX_LIST} [${GNB_PS_CELL_INDEX_LIST}], no need to do traffic test.
    END

5887 L3 call check tput via power UE
    [Documentation]     Author: Zhang Ningning
    ...    compare with keyword "Call case with Commercial UE and record throughput info", this keyword check tput via power ue
    ...    1. attach ue
    ...    2. start traffic
    ...    3. check throughput
    ...   :param cell_id: global cell id, can be 1
    ...   :param dl_tput: Start traffic of DL, Unit in Mbps.
    ...   :param ul_tput: Start traffic of UL, Unit in Mbps.
    ...   :param exp_ul: expected tput of UL, Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, Unit in Mbps.
    [Arguments]     ${cell_id}=1    ${dl_tput}=150M    ${ul_tput}=50M    ${exp_ul}=1    ${exp_dl}=1    ${tput_check_duration}=60s
    ...    ${ignore_time}=1min    ${actCarrierAggregation}=${False}    ${data_transfer_direction}=both
    ...    ${traffic_duration}=3000s    ${protocol}=udp    ${process_num}=${3}    ${seg_size}=1350
    ...    ${iperf_ul_port}=${None}    ${iperf_dl_port}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M

    ...    ${ue_type}=${UE_TYPE}    ${retry_time}=3    ${ue_index}=${0}    ${prepare_ue_needed}=${False}    ${4G_check}=${None}
    ...    ${attach_check_type}=GNB_log    ${duration}=5s    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}
    ...    ${target_avg_percent}=0.95    ${filter}=L2Lo

    Run keyword and continue on failure    Retry commercial ue attach if failed     ue_type=${ue_type}    retry_time=${retry_time}
    ...    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}    attach_check_type=${attach_check_type}
    ...    duration=${duration}   detach_request=${detach_request}    connection=${connection}    is_ue_reboot=${is_ue_reboot}

    Start data transfer based on direction    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${traffic_duration}    protocol=${protocol}
    ...    process_num=${process_num}    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}    seg_size=${seg_size}
    ...    iperf_ul=${iperf_ul_port}    iperf_dl=${iperf_dl_port}    buffer_size=${buffer_size}
    ...    iperf_type_ul=${iperf_type_ul}    window=${window}
    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${tput_check_duration}
    ...    ignore_time=${ignore_time}   filter=${filter}
    Check Tput for all cells   exp_ul_tput=${exp_ul}    exp_dl_tput=${exp_dl}    log=${tput_log}
    ...    protocol=${protocol}
    ...    data_transfer_direction=${data_transfer_direction}
    [Teardown]  run keyword and ignore error  Stop data transfer based on direction


Check Tput for all cells
    [Documentation]    Author: fang ludan
    ...    check all cells tput
    [Arguments]     ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${data_transfer_direction}=both    ${ue_type}=${UE_TYPE}
    ...          ${exp_ul_tput}=200    ${exp_dl_tput}=1950    ${protocol}=udp
    ...            ${target_avg_percent}=1.0    ${actCarrierAggregation}=${True}     ${log}=${TPUT_LOG}

    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    ${ul_tput}    run keyword if    '${data_transfer_direction}'=='ul'   run keyword and continue on failure
    ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            target_throughput=${exp_ul_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}
    ${dl_tput}    run keyword if    '${data_transfer_direction}'=='dl'    run keyword and continue on failure
    ...    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            target_throughput=${exp_dl_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}
    ${ul_tput}   ${dl_tput}    run keyword if    '${data_transfer_direction}'=='both'
    ...    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            ultarget_throughput=${exp_ul_tput}   dltarget_throughput=${exp_dl_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}


check counter 2005
    [Documentation]    Author: fang ludan
    ...  ${local_counter_file_path} is PM_counter_file
    ...  ${attach_counter_list}  is which counter want to check, it is a list
    [Arguments]   ${local_counter_file_path}  ${attach_counter_list}    ${list_cell}=${GNB_PS_CELL_INDEX_LIST}
    ${counter_every_cell}      get_cell_counters_from_file   file_path=${local_counter_file_path}
    ...  list_measurement_ids=${attach_counter_list}   list_cell=${list_cell}
    #M55118C02005
    Run keyword and continue on failure  should be equal as numbers  ${1}   ${counter_every_cell['1']['M55118C02005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['2']['M55118C02005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['3']['M55118C02005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['4']['M55118C02005']}

    #M55118C03005
    Run keyword and continue on failure  should be equal as numbers  ${1}   ${counter_every_cell['1']['M55118C03005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['2']['M55118C03005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['3']['M55118C03005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['4']['M55118C03005']}

Check Log for UL 3CC configuration
    [Documentation]    author: Zhang Ningning
    [Timeout]    20 min
    [Arguments]  ${log_name}=x2ap
    #catch X2-AP log
    Start X2 log capture from eNB    log_name=${log_name}
    Connect to gnb coam via ssl
    Retry Commercial Ue Attach If Failed    retry_time=${3}  ue_type=${ue_type}
    ...     prepare_ue_needed=${False}  4G_check=${True}
    ${enb_x2_log}    Stop X2 log capture from eNB    log_name=${log_name}
    cap.load_pcap_file    pcap_file=${enb_x2_log}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
    ...    tshark_path=${TSHARK_PATH}    alias=ul3cc
    ${rrcReconfig}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.procedureCode == 27    pcap_parser=ul3cc
    ${uplinkConfigCommon_cell1}    cap.get_field_value_by_xpath    pcap_parser=ul3cc
    ...    xpath=.//nr-rrc.sCellToAddModList/*[@show="Item 0"]/${PATH_COMMON}
    ...    attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${uplinkConfigCommon_cell1}[0]    uplinkConfigCommon
    ${uplinkConfigCommon_cell2}    cap.get_field_value_by_xpath    pcap_parser=ul3cc
    ...    xpath=.//nr-rrc.sCellToAddModList/*[@show="Item 1"]/${PATH_COMMON}
    ...    attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${uplinkConfigCommon_cell2}[0]    uplinkConfigCommon
    ${uplinkConfigCommon_cell2}    cap.get_field_value_by_xpath    pcap_parser=ul3cc
    ...    xpath=.//nr-rrc.sCellToAddModList/*[@show="Item 3"]/${PATH_COMMON}
    ...    attribute_name=showname
    ${status}    run keyword and return status  should be equal as strings     ${uplinkConfigCommon_cell2}[0]    uplinkConfigCommon
    Should be true   ${status}==False

check counter 4005
    [Documentation]    Author: fang ludan
    ...  ${local_counter_file_path} is PM_counter_file
    ...  ${attach_counter_list}  is which counter want to check, it is a list
    [Arguments]   ${local_counter_file_path}  ${attach_counter_list}    ${list_cell}=${GNB_PS_CELL_INDEX_LIST}
    ${counter_every_cell}      get_cell_counters_from_file   file_path=${local_counter_file_path}
    ...  list_measurement_ids=${attach_counter_list}   list_cell=${list_cell}
    #M55118C04005
    Run keyword and continue on failure  should be equal as numbers  ${300}   ${counter_every_cell['1']['M55118C04005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['2']['M55118C04005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['3']['M55118C04005']}
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['4']['M55118C04005']}

    #M55118C05005
    Run keyword and continue on failure  should be equal as numbers  ${0}   ${counter_every_cell['1']['M55118C05005']}
    Run keyword and continue on failure  should be equal as numbers  ${300}   ${counter_every_cell['2']['M55118C05005']}
    Run keyword and continue on failure  should be equal as numbers  ${300}   ${counter_every_cell['3']['M55118C05005']}
    Run keyword and continue on failure  should be equal as numbers  ${300}   ${counter_every_cell['4']['M55118C05005']}


Suite preparation for 5887
    [Documentation]    author: Zhang Ningning
    [Timeout]    25 min
    set suite variable     ${PARAMS_TO_DELETE}    ${ABIO_DEL}
    set suite variable    ${PARAMS_TO_MODIFY}    ${PARAMS_TO_MODIFY_FOR_CA}
    Suite common setup preparation    is_pdl_checking_needed=${False}
    ...    scf_template_path=${SCF_DEFAULT_FILE_PATH_8CC_CA}
    ...    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...    prepare_ue=${True}
    Get the ru index list and cell index list and cell group index list and set to suite variable

creating special test case directory
    [Documentation]   Author: Zhang Ningning
    ...    COAM Create log directory will not be used because if the name contains [1] the convert of pdml will have some issue.
    ${test_case_name} =    replace string    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${test_case_name} =     remove string    ${test_case_name}    [1]
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    ${test_case_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}

common case teardown with recovery ul3cc
    [Documentation]   Author: Zhang Ningning
    ...    recovery ul 4cc configuration
    Stop X2 log capture from eNB
    Set maxNumScellsUl to 3    modify_set_maxNumScellsUl_3=${modify_set_maxNumScellsUl_3}
    common case teardown with recovery gnbindex

common case teardown with recovery gnbindex
    [Documentation]   Author: Zhang Nining
    ...    recovery gnbindex to 1
    [Arguments]     ${para_update_timeout}=6 min
    Stop X2 log capture from eNB
    Make SgNBAddition on specific cell
    ...     gnb_ps_cell_index=${1}   para_update_timeout=${para_update_timeout}    alias=enblte
    Common case teardown    is_log_required=${True}    detach_ue=${True}

Set 5GC001120 active with CA
    [Documentation]   author: Zhang Ningning
    Modify nidd parameters on WebUI via rest api to enabled 4UL   Active_1120_NIDD_para=${Active_1120_NIDD_para}

Modify nidd parameters on WebUI via rest api to enabled 4UL
    [Documentation]    Author: Zhang Ningning
    ...    Use this keyword to update nidd paramter related to 1120 via rest api and verify alarms.
    [Arguments]    ${Active_1120_NIDD_para}     ${timeout_restapi}=5 min
    ...    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${Active_1120_NIDD_para}   timeout=${timeout_restapi}
    ...    connection=${connection}

Common case teardown with recovery 4UL
    [Documentation]   Author: Zhang Ningning
    ...    recovery env for 4ul
    Set 5GC001120 active with CA
    Common case teardown    is_log_required=${True}    detach_ue=${True}
