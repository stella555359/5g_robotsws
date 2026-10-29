*** Settings ***
Documentation
...   This ue related keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    ./SISO_Pre.robot
Library     ./lib/verify_throughput_from_GNB_log.py    WITH NAME    verify_tput
Resource    ./0_Deprecated/Qualcomm_Pre.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/qualcomm_cpe_with_power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/common_setup_teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vran40/cloud_gnb.py

*** Variables ***
${IPERF_PROCESS_NUM}    2


*** Keywords ***
UE detach should be successed
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Run keyword if    '${ue_type}'=='qct_dx50'    Verify UE detach successfully for Qualcomm UE    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='inseego'    Log    UE detached in inseego detach keyword
    ...    ELSE IF    '${ue_type}'=='askey'    Log    ue detached by AT command
    ...    ELSE     Verify UE detach successfully for commerical UE    ue_index=${ue_index}

Verify UE detach successfully for commerical UE
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ue_index}=${0}
    Get Commercial UE IP    ue_index=${ue_index}
	${passed}    Run Keyword And Return Status   Should Contain     ${UE_IP}    127.0.0
	Should be true    ${passed}==${True}

Verify UE detach successfully for Qualcomm UE
    [Timeout]    45 sec
    [Documentation]    author: Liu Zheng
    [Arguments]   ${ue_index}=0
    ${status}    Run keyword and return status    Get the UE IP address    ue_index=${ue_index}
    Should be true    ${status}==${False}

Verify summary tput for CA configuration from GNB within duration and record data to csv
    [Documentation]    Author: Liu Zheng
    ...                Description: Check ul and dl peak throughput of all cells
    ...                dl_cell can be 1 or 1,2,3,4,5,6,7,8
    ...                ul_cell can be 1 or 1,2
    ...                :para${duration} is the whole time for checking tput. In this case, 600s will be the total time.
    [Arguments]    ${dl_cell}   ${ul_cell}   ${expected_ul_tput}=${None}   ${expected_dl_tput}=${None}
    ...    ${duration_time_for_once}=30    ${duration}=${DURATION_TIME}    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${is_need_to_capture_log}=${False}    ${data_transfer_direction}=both    ${alias}=ASIK Master
    ${list_dl_cell}    string2list    ${dl_cell}
    ${list_ul_cell}    string2list    ${ul_cell}
    ${start_time}    DateTime.get current date     result_format=epoch    exclude_millis=True
    ${end_time}    Evaluate    ${start_time}+${duration}
    @{list_tput_info}    Create list
    ${current_time_stamp}    set variable    ${start_time}
    FOR    ${i}    IN RANGE    ${start_time}    ${end_time}
        Connect to Common Unit Master    alias=${alias}
        ${Tput_records_dir}    Join path     ${local_log_folder}    Tput_Logs${current_time_stamp}
        Create directory     ${Tput_records_dir}
        @{saved_tput_file_list}    Run keyword and continue on failure    Retry log capturing if file content is empty
        ...    duration=${duration_time_for_once}    asik_alias=${alias}
        &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
        ...    local_log_folder=${Tput_records_dir}    asik_alias=${alias}
        ${ul_tput_avg}   ${ul_tput_max}   ${ul_tput_min}   ${ul_detail_peak_tput_info}
        ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
        ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
        ${dl_tput_avg}   ${dl_tput_max}   ${dl_tput_min}   ${dl_detail_peak_tput_info}
        ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
        ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
        &{dict_tput_info}    Create dictionary
        Set to dictionary    ${dict_tput_info}    timestamp=${current_time_stamp}
        Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_avg=${ul_tput_avg}
        Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_max=${ul_tput_max}
        Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_min=${ul_tput_min}
        Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_avg=${dl_tput_avg}
        Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_max=${dl_tput_max}
        Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_min=${dl_tput_min}
        set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_details=${ul_detail_peak_tput_info}
        set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_details=${dl_detail_peak_tput_info}
        Log to console    tput info: ${dict_tput_info}
        Append to list    ${list_tput_info}    ${dict_tput_info}
        ${status}    Run keyword and return status    verify tput should be successed
        ...    data_transfer_direction=${data_transfer_direction}    expected_ul_tput=${expected_ul_tput}   expected_dl_tput=${expected_dl_tput}
        ...    ul_tput_avg=${ul_tput_avg}    dl_tput_avg=${dl_tput_avg}
        Run keyword and continue on failure    Should be true    ${status}
        Run keyword if  ${status}==${False} and ${is_need_to_capture_log}
        ...    Run keywords    Create directory    ${Tput_records_dir}    AND
        ...    Run keyword and continue on failure    Capture event trace log if tput can not reach the expected value
        ...    local_log_folder=${Tput_records_dir}    asik_alias=${asik_alias}
        ${current_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
        Exit for loop if    ${current_time_stamp}>${end_time}
    END
    ${csv_log_file_path}    Join path    ${local_log_folder}    peak_tput_records_${start_time}.csv
    export_to_csv.write_data_to_csv    input_data=${list_tput_info}    csv_file_path=${csv_log_file_path}
    [Return]    ${dict_tput_info}

Get tput summary from GNB log
    [Documentation]    Author: Wang Yixiang
    ...                Description: get dl and ul cells throughput
    ...                dl_cell can be 1 or 1,2,3,4,5,6,7,8
    ...                ul_cell can be 1 or 1,2
    ...                :para${tput_duration} is the whole time for checking tput.
    ...                return example:
    ...                {b'1': {'dl_avg_tput': 240.98622500000002,
    ...                    'dl_max_tput': 287.23,
    ...                    'dl_min_tput': 192.56,
    ...                    'dl_tput_details': [267.68, 230.183, 287.23, 233.135, 215.104, 246.159, 219.051, 260.728, 242.743, 223.772,
    ...                                        225.867, 253.812, 230.6, 251.168, 267.42, 267.047, 267.75, 264.535, 210.891, 236.267,
    ...                                        ],
    ...                    'ul_avg_tput': 40.6575,
    ...                    'ul_max_tput': 42.805,
    ...                    'ul_min_tput': 39.883,
    ...                    'ul_tput_details': [42.805, 42.11, 40.936, 41.478, 40.591, 40.737, 40.489, 40.831, 40.432, 40.916, 40.26,
    ...                                        40.612, 40.181, 40.224, 39.943, 40.102, 40.729, 40.479, 40.322, 40.591, 40.213,
    ...                                        ]},
    ...                b'2': {'dl_avg_tput': 240.98622500000002,
    ...                    'dl_max_tput': 287.23,
    ...                    'dl_min_tput': 192.56,
    ...                    'dl_tput_details': [267.68, 230.183, 287.23, 233.135, 215.104, 246.159, 219.051, 260.728, 242.743,
    ...                                        223.772, 225.867, 253.812, 230.6, 251.168, 267.42, 267.047, 267.75, 264.535, 210.891,
    ...                                        ]},
    ...                    'dl_tput_peak_all_cells_avg': 372.01599999999996,
    ...                    'dl_tput_peak_all_cells_max': 427.422,
    ...                    'dl_tput_peak_all_cells_min': 230.78199999999998,
    ...                    'ul_tput_peak_all_cells_avg': 40.657,
    ...                    'ul_tput_peak_all_cells_max': 42.805,
    ...                    'ul_tput_peak_all_cells_min': 39.883}
    [Arguments]    ${dl_cell}   ${ul_cell}    ${tput_duration}=60s      ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}
    ...            ${local_log_folder}=${TS_CASE_LOG_PATH}    ${alias}=ASIK Master    ${gnb_index}=${0}
    ${list_dl_cell}    string2list    ${dl_cell}
    ${list_ul_cell}    string2list    ${ul_cell}
    ${current_time_stamp}    DateTime.get current date     result_format=epoch    exclude_millis=True
    run keyword and ignore error    csn.disconnect    connection=${alias}
    Connect to Common Unit Master    alias=${alias}    gnb_index=${gnb_index}

    ${Tput_records_dir}    Join path     ${local_log_folder}    Tput_Logs${current_time_stamp}
    Create directory     ${Tput_records_dir}
    @{saved_tput_file_list}    Run keyword and continue on failure    Retry log capturing if file content is empty
    ...    duration=${tput_duration}    asik_alias=${alias}    gnb_index=${gnb_index}
    &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...    local_log_folder=${Tput_records_dir}    asik_alias=${alias}

    &{dict_tput_for_cells_ul}    verify_tput.get_details_of_tput_all_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
    ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${nr_cell_id_mapping}
    &{dict_tput_for_cells_dl}    verify_tput.get_details_of_tput_all_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
    ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${nr_cell_id_mapping}

    ${dict_tput_info}    verify_tput.combine_dictionary_py    dict1=${dict_tput_for_cells_dl}   dict2=${dict_tput_for_cells_ul}
    ...    sub_dict_key_list=${list_dl_cell}

    [Return]    ${dict_tput_info}

verify tput should be successed
    [Arguments]    ${expected_ul_tput}     ${expected_dl_tput}    ${ul_tput_avg}    ${dl_tput_avg}    ${data_transfer_direction}=both
     ${expected_ul_tput}    set variable if    '${expected_ul_tput}' != '${None}'    ${expected_ul_tput}    ${None}
     ${expected_dl_tput}    set variable if    '${expected_dl_tput}' != '${None}'    ${expected_dl_tput}    ${None}
     ${ul_tput_avg}    set variable if    '${ul_tput_avg}' != '${None}'    ${ul_tput_avg}    ${None}
     ${dl_tput_avg}    set variable if    '${dl_tput_avg}' != '${None}'    ${dl_tput_avg}    ${None}
     run keyword and continue on failure    run keyword if  not '${data_transfer_direction}'=='dl'
     ...    should be true    ${ul_tput_avg}>=${expected_ul_tput}
     run keyword and continue on failure    run keyword if  not '${data_transfer_direction}'=='ul'
     ...    Should be true    ${dl_tput_avg}>=${expected_dl_tput}

_Get tput value and unit based on the input tput value
    [Documentation]    Author: Ding Binmei
    ...    split input tput value to value and unit
    ...    E.G: 100M then return with 100  and M
    [Arguments]    ${input_tput}
    ${tput_value}    Get Regexp Matches    ${input_tput}   (\\d+\\.*\\d*)    1
    ${tput_unit}    Get Regexp Matches    ${input_tput}   (\\D+)$    1
    ${len_unit}    Get Length    ${tput_unit}
    ${tput_unit}    Set variable if    ${len_unit}==0    ${EMPTY}    ${tput_unit[0]}
    [Return]    ${tput_value[0]}    ${tput_unit}

Start data transfer based on direction
    [Documentation]  Author: Ding Binmei
    ...              Description: Start data transfer based on direction
    ...                           data_transfer_direction: supported values are both, ul, dl
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...    ${dl_tput}/${ul_tput}: refers to the total tput which is expected to start regardless of process_number.
    ...        tput used in command is calculated inside this keyword.
    ...        E.G input format: 100Mbit/sec (huawei_sigspark UE must use such format, for qct_dx50, format like 100M is also OK)
    ...    ${process_num}: For DL: both TCP and UDP are used; for UL: only tcp is used
    ...    :param apn_address: Only huawei_sigspark ue is needed. should get rid of dot, e.g.:'wap1.nokia.com' should be set as 'wap1nokiacom'
    ...    :param ue_mode: Only huawei_sigspark ue is needed. Values: SA, LTE, MultiUE_SA;
    ...    :param duration: for huewei_sigspark ue, input value should convert to seconds unit like 300, 300s is not supported in spark API
    [Arguments]    ${dl_tput}    ${ul_tput}    ${duration}    ${protocol}=udp    ${process_num}=${IPERF_PROCESS_NUM}
    ...    ${data_transfer_direction}=both    ${ue_index}=${0}      ${seg_size}=1350
    ...    ${ue_alias}=UE_${ue_index}    ${iperf_ul}=${None}    ${iperf_dl}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M    ${apn_address}=dtdata2    ${ue_mode}=MultiUE_SA
    ${process_num}    run keyword if
    ...               '${process_num}'!='default'    set variable    ${process_num}
    ...               ELSE                           set variable if
    ...                                              '${protocol}'=='udp'    ${1}
    ...                                                                      ${3}
    ${dl_tput_value}    ${dl_tput_unit}    _Get tput value and unit based on the input tput value    input_tput=${dl_tput}
    ${ul_tput_value}    ${ul_tput_unit}    _Get tput value and unit based on the input tput value    input_tput=${ul_tput}
    ${dl_tput_value}    run keyword if    ${process_num}>1    Evaluate    math.ceil(${dl_tput_value}/${process_num})    math
    ...    ELSE    Set variable    ${dl_tput_value}
    ${ul_tput_value}    run keyword if    ${process_num}>1 and '${protocol}'=='tcp'    Evaluate    math.ceil(${ul_tput_value}/${process_num})    math
    ...    ELSE    Set variable    ${ul_tput_value}
    ${dl_tput}    Catenate    SEPARATOR=${EMPTY}    ${dl_tput_value}    ${dl_tput_unit}
    ${ul_tput}    Catenate    SEPARATOR=${EMPTY}    ${ul_tput_value}    ${ul_tput_unit}
    ${data_transfer_direction}=    Convert To Lowercase    ${data_transfer_direction}
    ${iperf_ul}    Set variable if    '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'  ${iperf_ul}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' == 'qualcomm' or '${UE_TYPE}' == 'samsung_ue'   ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if   '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'   ${iperf_dl}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' == 'qualcomm' or '${UE_TYPE}' == 'samsung_ue'   ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[1]}
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'  ${tl.ues[${ue_index}].iperf_details.port}
    ${iperf_type_ul}    Set variable if    '${UE_TYPE}' == 'samsung'
    ...    ${iperf_type_ul}    via_app
    Run keyword if    '${data_transfer_direction}'=='both'
    ...        Run keywords     power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul   throughput=${ul_tput}    duration=${duration}
    ...        dt_name=dt_ul_${ue_index}    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    buffer_size=${buffer_size}    window=${window}
    ...        iperf_type=${iperf_type_ul}     protocol=${protocol}    process_num=${process_num}     seg_size=${seg_size}
    ...        apn_address=${apn_address}    ue_mode=${ue_mode}    AND
    ...        sleep    2s      AND
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl   throughput=${dl_tput}    duration=${duration}
    ...        dt_name=dt_dl_${ue_index}    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    buffer_size=${buffer_size}
    ...        protocol=${protocol}    process_num=${process_num}     seg_size=${seg_size}    window=${window}
    ...        apn_address=${apn_address}    ue_mode=${ue_mode}

    ...    ELSE IF  '${data_transfer_direction}'=='dl'
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl   throughput=${dl_tput}    duration=${duration}
    ...            dt_name=dt_dl_${ue_index}    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    buffer_size=${buffer_size}     protocol=${protocol}
    ...            process_num=${process_num}     seg_size=${seg_size}    window=${window}    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ELSE IF  '${data_transfer_direction}'=='ul'
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul   throughput=${ul_tput}    duration=${duration}
    ...            dt_name=dt_ul_${ue_index}    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    buffer_size=${buffer_size}    window=${window}
    ...            iperf_type=${iperf_type_ul}     protocol=${protocol}     process_num=${process_num}     seg_size=${seg_size}
    ...            apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl

Stop data transfer and detach UE
    [Documentation]  Author: Wang Yixiang
    ...              Description: Stop data transfer and detach UE
    [Arguments]    ${protocol}=udp    ${data_transfer_direction}=both    ${iperf_ul}=${None}    ${iperf_dl}=${None}    ${ue_index}=${0}
    ...    ${iperf_type_ul}=via_command    ${ue_type}=${UE_TYPE}
    Stop data transfer based on direction    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}    iperf_ul=${iperf_ul}
    ...    iperf_dl=${iperf_dl}    ue_index=${ue_index}    iperf_type_ul=${iperf_type_ul}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Stop data transfer based on direction
    [Documentation]  Author: Ding Binmei
    ...              Description: Stop data transfer
    ...                           data_transfer_direction: supported values are both, ul, dl
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...              ${protocol} is not needed for QCOM when stop data transfer
    ...    :param apn_address: Only huawei_sigspark ue is needed. should get rid of dot, e.g.:'wap1.nokia.com' should be set as 'wap1nokiacom'
    ...    :param ue_mode: Only huawei_sigspark ue is needed. Values: SA, LTE, MultiUE_SA;
    [Arguments]    ${protocol}=udp    ${data_transfer_direction}=both    ${iperf_ul}=${None}    ${iperf_dl}=${None}    ${ue_index}=${0}
    ...    ${iperf_type_ul}=via_command    ${apn_address}=dtdata2    ${ue_mode}=MultiUE_SA
    run keyword if     '${UE_TYPE}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP

    ${iperf_ul}    Set variable if    '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'  ${iperf_ul}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' == 'qualcomm' or '${UE_TYPE}' == 'samsung_ue'    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if   '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'   ${iperf_dl}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' == 'qualcomm' or '${UE_TYPE}' == 'samsung_ue'    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[1]}
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'  ${tl.ues[${ue_index}].iperf_details.port}
    ${iperf_type_ul}    Set variable if    '${UE_TYPE}' == 'samsung'
    ...    ${iperf_type_ul}    via_app

    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords     power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    dt_name=dt_ul_${ue_index}    iperf_port=${iperf_ul}
    ...    iperf_type=${iperf_type_ul}     protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}    AND
    ...                     power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    dt_name=dt_dl_${ue_index}    iperf_port=${iperf_dl}
    ...                         protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}    AND
    # close ul traffic tcp iperf on appserver
    ...                     run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    dt_name=dt_dl_${ue_index}
    ...    iperf_port=${iperf_ul}    iperf_type=${iperf_type_ul}     protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    AND
    # close dl traffic tcp iperf on UEPC
    ...                     run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...            dt_name=dt_ul_${ue_index}    iperf_port=${iperf_dl}     protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...        Run keywords    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}_${ue_index}    iperf_port=${iperf_ul}    iperf_type=${iperf_type_ul}
    ...             protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}    AND
    # close ul traffic tcp iperf on appserver
    ...                    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    dt_name=dt_dl_${ue_index}
    ...    iperf_port=${iperf_ul}    iperf_type=${iperf_type_ul}     protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...        Run keywords    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}_${ue_index}    iperf_port=${iperf_dl}    ue_index=${ue_index}
    ...             protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}    AND
    # close dl traffic tcp iperf on UEPC
    ...                    run keyword and ignore error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...            dt_name=dt_ul_${ue_index}    iperf_port=${iperf_dl}     protocol=${protocol}    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl

WA Kill vysor process on ue pc if exists
    [Documentation]  Author: Ding Binmei
    ...    Description: Kill vysor process on ue pc, as when vysor pops up, it will reset cmd windows,
    ...    if there are existing iperf process started on ue pc, the process will be interrupted
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${is_vysor_process_exits}    ssh_common_commands.is_process_exist    process_name=Vysor.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_vysor_process}    Set variable    taskkill /f /im Vysor.exe
    Run keyword if    ${is_vysor_process_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_vysor_process}    connection=${cpc_alias}
    ...    ELSE   Log to console    No need to kill vysor as process is not started
    ${is_vysor_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=Vysor.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_vysor_process_exits_after_kill}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Retry commercial ue attach if failed
    [Timeout]    25 min
    [Documentation]    Author: Ren Biyao
    ...   Description: Attach UE by power UE, include all types of power UE(Qualcom, Samsung,
    ...   Huawei, Inseego, askey, LG, xiaomi)
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...   ${attach_check_type}=GNB_log, check ue attach by GNB log
    ...   ${attach_check_type}=ADB_log, check ue attach by adb log
    ...   ${attach_check_type}=PROXY_log, check ue attach by ue proxy log(only for qualcomm cpe)
    ...    ${is_ue_reboot} is valid for QCOM UE, if set to ${True}, then reboot ue will be done as a WA for retry ue attach
    ...    ${connection}: For cloud, refers to cu connection:OAM_CU${gnb_index}; For classical: GNB_OAM
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=2    ${ue_index}=${0}    ${prepare_ue_needed}=${True}    ${4G_check}=${None}
    ...    ${attach_check_type}=GNB_log    ${duration}=5s    ${detach_request}=${False}    ${connection}=GNB_OAM    ${is_ue_reboot}=${False}
    ...    ${gnb_index}=${0}    ${du_index}=${0}   ${cell_id}=${None}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${gnb_type}        run keyword if    '${has_cbts}'=='${True}'     Get gNbType SA or NSA via vCU rest api
    ...                                gnb_index=${gnb_index}    connection=${connection}
    ...   ELSE    Get gNbType SA or NSA via rest api    connection=${connection}
    ${4G_check} 	Set Variable If	  '${gnb_type}'=='SA'  	False    ${4G_check}
    ${4G_check} 	Set Variable If	  '${gnb_type}'=='NSA'   True    ${4G_check}
    Run Keyword And Ignore Error    run keyword if  not '${ue_type}'=='qualcomm'   WA Kill vysor process on ue pc if exists   ue_index=${ue_index}

    ${retry_time_GNB_log}    run keyword if    '${attach_check_type}'=='GNB_log'
    ...    _Sub retry commercial ue attach if failed
    ...    ue_type=${ue_type}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}
    ...    detach_request=${detach_request}    is_ue_reboot=${is_ue_reboot}    du_index=${du_index}

    ${retry_time_ADB_log}    run keyword if    '${attach_check_type}'=='ADB_log'    Power UE attach ADB check
    ...    ue_index=${ue_index}    ue_type=${ue_type}    retry_time=${retry_time}    prepare_ue_needed=${prepare_ue_needed}    duration=${duration}
    ${retry_time_PROXY_log}    run keyword if    '${attach_check_type}'=='PROXY_log'     attach UE for qualcomm CPE with retry
    ...    ue_type=${ue_type}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    is_ue_reboot=${is_ue_reboot}    cell_id=${cell_id}
    ${retry_time_ret}    Set variable if    '${attach_check_type}'=='GNB_log'    ${retry_time_GNB_log}
    ...    '${attach_check_type}'=='ADB_log'    ${retry_time_ADB_log}
    ...     ${retry_time_PROXY_log}
    [Return]    ${retry_time_ret}

UE attach with at command
    [Documentation]    Author: Wang Yixiang
    ...   Description: Attach UE by at command
    ...   first copy ATcommand.py to UE PC's path C:/tools/AT
    ...   ${COM_port}  means atcommand used com port
    ...   ${network}   can be 4G or 5G
    ...   ${AT_script_path}   script path of ATcommand.py
    ...   for example:
    ...   ${mcc}    Get NIDD value via rest api   parameter=mcc    dist_name=MRBTS-1170/NRBTS-1170
    ...   ${mnc}    Get NIDD value via rest api   parameter=mnc    dist_name=MRBTS-1170/NRBTS-1170
    ...   UE attach with at command    COM_port=11   mcc=${mcc}   mnc=${mnc}   network=5G
    [Arguments]    ${COM_port}    ${mcc}   ${mnc}   ${network}=4G   ${AT_script_path}=C:/tools/AT    ${ue_index}=${0}
    # 7:E-UTRAN   12:NG-RAN
    ${nat}   set variable if    '${network}'=='4G'    7    12
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=taskkill /f /im ATCom.exe    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command   command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cfun=0"    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command   command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cfun=1"    connection=cpc_${ue_index}
    sleep    3s
    csn.send command    command=cmd /c python ${AT_script_path}/ATcommand.py -p com${COM_port} -c "at+cops=1,2,${mcc}${mnc},${nat}"
    ...    connection=cpc_${ue_index}
    sleep    30s

_Sub retry commercial ue attach if failed
    [Timeout]    25 min
    [Documentation]    Author: Ren Biyao
    ...   Description: Attach UE by power UE, include all types of power UE(Qualcom, Samsung,
    ...   Huawei, Inseego, askey, LG, xiaomi)
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...    ${is_ue_reboot} is valid for QCOM UE, if set to ${True}, then reboot ue will be done as a WA for retry ue attach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=2    ${ue_index}=${0}    ${prepare_ue_needed}=${True}    ${4G_check}=True
    ...    ${detach_request}=${False}    ${is_ue_reboot}=${False}    ${gnb_index}=${0}    ${du_index}=${0}

    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    detach_request=${detach_request}
    ${detach_time}    Set variable    ${0}
    ${attach_retry_time}    Set variable    ${0}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}     ${ue_ip_status}    run keyword if    '${has_cbts}'=='${True}'
        ...    Cloud UE Attach and Verify Attach
        ...            ue_type=${ue_type}   ue_index=${ue_index}  gnb_index=${gnb_index}    vdu_index=${du_index}   4G_check=${4G_check}
        ...    ELSE    Classical UE Attach and Verify Attach
        ...            ue_type=${ue_type}   ue_index=${ue_index}  gnb_index=${gnb_index}    du_index=${du_index}   4G_check=${4G_check}
        Exit for loop if    ${attach_status} and ${ue_ip_status}
        run keyword and continue on failure    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console   UE_${ue_index} attached failed, retry detach time ${detach_time}
        Exit for loop if    '${detach_time}' == '${retry_time}'
        #solve at command at+cfun=0 cannot attach via automation issue
        run keyword if    '${ue_type}'=='qct_dx50' and ('${ue_ip_status}'=='${False}' or '${attach_status}'=='${False}' or ${is_ue_reboot})
        ...    Run keywords    android_common_keyword.UE reboot via taf method    ue_index=${ue_index}    detach_request=${True}    AND
        ...    Sleep    5s    Waiting for UE to reboot...
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed
    ${attach_retry_time}    Evaluate    ${i}+1
    [Return]     ${attach_retry_time}

Classical UE Attach and Verify Attach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0   ${4G_check}=${True}
    # if know return status, rcp error fron naa will cause keyword fail directly
    ${5Grach_ed}    Run keyword if    '${ue_type}'=='qualcomm'    run keyword and ignore error
    ...    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE     power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    gnb_index=${gnb_index}   du_index=${du_index}
    ${attach_status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    4G_check=${4G_check}    ue_index=${ue_index}   gnb_index=${gnb_index}   du_index=${du_index}
    ${ue_ip_status}    run keyword and return status
    ...    Run keyword if    '${ue_type}'=='qct_dx50'    wait until keyword succeeds  2 min    5 sec
    ...        android_common_keyword.Get the UE Ip address    ue_index=${ue_index}
    [Return]     ${attach_status}     ${ue_ip_status}

Retry commercial ue detach if failed
    [Timeout]    5 min
    [Documentation]    Author: Wang Yixiang
    ...   Detach UE by power UE, include all types of power UE(Qualcom, Samsung,
    ...   Huawei, Inseego, askey, LG, xiaomi)
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=20s    ${ue_index}=${0}
    log to console    \nUE detach and verify.
    wait until keyword succeeds    ${retry_time}    2s    UE detach should be successed    ue_index=${ue_index}    ue_type=${ue_type}

Call case with Commercial UE and record throughput info
    [Documentation]  Author: Ren Biyao
    ...              Description:
    ...              ${duration_time}: is the duration time for calculating average tput in one capturing
    ...              ${total_time}: is the duration time in which the throughput need to be checked. The time unit is second.
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...              ${iperf_type}  can be via_app or via_command, via_command first should install iperf3 in /data/local/tmp/iperf3
    [Arguments]    ${duration_time}    ${interval_time}    ${total_time}    ${ul_exp_tput}=${UL_EXPECT}    ${ue_type}=${UE_TYPE}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${tput_percentage}=${EXP_TPUT_PERCENTAGE}    ${retry_time}=3    ${iperf_ul}=${None}    ${iperf_dl}=${None}
    ...    ${ul_buffer_size}=1400    ${dl_buffer_size}=1400    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}
    ...    ${is_need_to_capture_log}=${True}
    ...    ${data_transfer_direction}=both    ${prepare_ue_needed}=${True}    ${4G_check}=True
    ...    ${iperf_type}=via_app
    Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}
    ...                                     prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}
    ${traffic_time}    Evaluate    ${total_time}*10

    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_ul}    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_dl}    ${tl.ues[${ue_index}].iperf_details.port}

    run keyword if  not '${data_transfer_direction}'=='dl'    Wait until keyword succeeds    5X    3 s    power_ue.Start traffic
    ...    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    iperf_type=${iperf_type}
    ...   duration=${traffic_time}    buffer_size=${ul_buffer_size}    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    dt_name=dt_ul
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${traffic_time}    buffer_size=${dl_buffer_size}
    ...    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    dt_name=dt_dl    iperf_type=${iperf_type}
    sleep   10s
    ${NRCELLIDENTITY}    Get nrCellIdentity for specific cell    cell_id=1
    Set test variable    ${NRCELLIDENTITY}
    Verify tput from GNB within duration and record data to csv    total_time=${total_time}    exp_dl_tput=${dl_exp_tput}
    ...    exp_ul_tput=${ul_exp_tput}    interval=${interval_time}    duration_time_for_once=${duration_time}
    ...    tput_percentage=${tput_percentage}    is_need_to_capture_log=${is_need_to_capture_log}

Call case with power UE and start traffic
    [Documentation]  Author: Wang Yixiang
    ...              Description:
    ...              ${duration_time}: is the duration time for calculating average tput in one capturing
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...              ${iperf_type}  can be via_app or via_command, via_command first should install iperf3 in /data/local/tmp/iperf3
    [Arguments]    ${duration_time}    ${ue_type}=${UE_TYPE}
    ...    ${retry_time}=3    ${iperf_ul}=${None}    ${iperf_dl}=${None}
    ...    ${ul_buffer_size}=1400    ${dl_buffer_size}=1400    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${ul_throughput}=${UL_THROUGHPUT}    ${dl_throughput}=${DL_THROUGHPUT}
    ...    ${data_transfer_direction}=both    ${prepare_ue_needed}=${True}
    ...    ${iperf_type}=via_app
    Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    prepare_ue_needed=${prepare_ue_needed}
    ${traffic_time}    Evaluate    ${duration_time}*10

    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_ul}    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_dl}    ${tl.ues[${ue_index}].iperf_details.port}
    run keyword if  not '${data_transfer_direction}'=='dl'    Wait until keyword succeeds    5X    3 s    power_ue.Start traffic
    ...    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    iperf_type=${iperf_type}
    ...   duration=${traffic_time}    buffer_size=${ul_buffer_size}    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    dt_name=dt_ul
    run keyword if  not '${data_transfer_direction}'=='ul'    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${traffic_time}    buffer_size=${dl_buffer_size}
    ...    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    dt_name=dt_dl    iperf_type=${iperf_type}

Power UE attach ADB check
    [Documentation]    Author: Wang Yixiang
    ...   Description: try attach and check 5G attach status by adb log
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}    ${retry_time}=2     ${prepare_ue_needed}=${True}    ${duration}=5s
    should be equal as strings    first=${ue_type}   second=samsung   msg=Only support samsung
    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${detach_time}    Set variable    ${0}
    ${attach_retry_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        l3call.Start Catch UE ADB logs    ue_index=${ue_index}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        sleep    ${duration}    reason=Wait for ADB log print out.
        ${log_path}   l3call.Stop catch UE ADB logs and save it    ue_index=${ue_index}
        ${5G_status}    Veirfy 5G setup successfully via adb log    ue_type=${ue_type}   log_path=${log_path}
        Exit for loop if    ${5G_status}
        #solve at command at+cfun=0 cannot attach via automation issue
        run keyword if    '${ue_type}'=='qct_dx50' and '${attach_status}'=='${False}'    UE soft reboot
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console   UE_${ue_index} attached failed, retry detach time ${detach_time}
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed
    ${attach_retry_time}    Evaluate    ${i}+1
    [Return]     ${attach_retry_time}

Veirfy 5G setup successfully via adb log
    [Arguments]    ${log_path}    ${ue_type}=${UE_TYPE}
    [Documentation]  Verify 5G attach status by adb log
    ${samsung_5G}    run keyword and return status    run keyword if    '${ue_type}'=='samsung'    S20 verify 5G setup sucessfully
    ...    log_path=${log_path}
    [Return]    ${samsung_5G}

Start Catch UE ADB logs
    [Arguments]     ${ue_index}=${0}
    [Documentation]  Catch the UE adb log.
    ...    author: yixiang.x.wang@nokia-sbell.com
    Connect to control pc enhanced    ue_index=${ue_index}
    ${serial_number} =    set variable    ${tl.ues[${ue_index}].serial_number}
    csn.send_command  command=rm /tmp/*ADB*  connection=cpc_${ue_index}    timeout=5
    sleep   5s
    csn.read_output    connection=cpc_${ue_index}
    csn.send_command  command=adb -s ${serial_number} logcat -c  connection=cpc_${ue_index}    timeout=5
    Sleep  3s
    csn.read_output    connection=cpc_${ue_index}
    csn.send_command
    ...   command=nohup adb -s ${serial_number} logcat -b all > /tmp/ADB.log &
    ...   connection=cpc_${ue_index}    timeout=5
    Log  INFO:Start to catch UE ADB logs  console=true
    [Teardown]    csn.disconnect   connection=cpc_${ue_index}

Stop catch UE ADB logs and save it
    [Arguments]     ${ue_index}=${0}    ${log_local_dir}=${TS_CASE_LOG_PATH}
    [Documentation]  Stop catch UE ADB log and save it.
    ...    author: yixiang.x.wang@nokia-sbell.com
    Connect to control pc enhanced    ue_index=${ue_index}
    ${time_stamp}=  Get Time   epoch
    ${local_file_path}=    set variable    ${log_local_dir}/ADB_attach_${time_stamp}.log
    csn.send_command  command=adb kill-server logcat  connection=cpc_${ue_index}    timeout=5
    sleep   3s
    csn.read_output    connection=cpc_${ue_index}
    sleep   3s
    csn.download_file    /tmp/ADB.log  ${local_file_path}  connection=cpc_${ue_index}
    Log  INFO:Stop to catch UE ADB logs  console=true
    [Return]  ${local_file_path}
    [Teardown]    csn.disconnect   connection=cpc_${ue_index}

S20 verify 5G setup sucessfully
    [Arguments]     ${log_path}
    [Documentation]      This keyword is to verify Samsung 5G setup successfully via ADB log.
    ...    author: yixiang.x.wang@nokia-sbell.com
    ${grep}=    Set Variable    getServiceStateForSubscriber
    &{lte_attach_confirm}=    Create Dictionary
    ...    reg1    mDataRegState\=0(IN_SERVICE)
    ...    reg2    MobileDataRat\=LTE
    &{nr_attach_confirm}=    Create Dictionary
#    ...    bearer    NrBearerStatus\=1
    ...    nractive    5gStatus\=1
    ...    rrc    RRCState\=1
    Run       cat ${log_path} | grep -ia ${grep} > adb_grep_5G.log
    ${result}=     Run    tail -n 1 adb_grep_5G.log
    Run       rm -rf adb_grep_5G.log
    FOR    ${key}    IN    @{lte_attach_confirm.keys()}
        Should Contain    ${result}    ${lte_attach_confirm.${key}}
    END
    Log To Console       --> INFO: 4G UE setup successfully
    FOR    ${key}    IN    @{nr_attach_confirm.keys()}
        Should Contain    ${result}    ${nr_attach_confirm.${key}}
    END
    Log To Console       --> INFO: 5G UE setup successfully

Get UP IP and set as suite variable
    [Documentation]    Author: Cui Lingxue
    ...    Query UE IP address and set as suite variable.
    ...    If ue type is qct_dx50, UE attach or UE detach is precondition.
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}
    ${UE_IP}    Run keyword if    '${ue_type}'=='qct_dx50'    android_common_keyword.Get the UE Ip address    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='askey'    ute_ue.Get Ue Info    UE_${ue_index}    IP
    run keyword if    '${ue_type}'=='samsung' or '${ue_type}'=='Huawei'    Get Commercial UE IP    ue_index=${ue_index}
    set suite variable    ${UE_IP}

Check tput via power UE optimized
    [Documentation]    Author: Ding Binmei
    ...   use TPUT check keyword of power ue, and it will draw a tput picture
    ...   :param cell_index: global cell id, can be 1 or 1,2
    ...   :param tput_log_path: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param direction: supported values are: both, ul, dl
    ...   :param exp_ul/exp_dl: expected tput of UL/DL, Can only be single value.
    ...        If actCarrierAggregation=True, it's the expected UL tput for all cells
    ...        If actCarrierAggregation=False, then each cell should reach with this expected tput
    ...   :param exp_ul_indiv/exp_dl_indiv: only valid when actCarrierAggregation is set to ${True}.
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...   :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...   :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword. For cloud, refers to VDU ssl connection
    ...   :param cell_mapping: If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   :param customized_log_name: For generated tput image file name
    ...   :param is_analysis_log_captured: ${True} / ${False}
    ...   :param is_need_to_fail_keyword: ${True} / ${False}, if set as false, you will need to set is_analysis_log_captured as True,
    ...      then you will need to add verification for returned bip log path
    ...   e.g: Check tput via power UE optimized    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=50    exp_dl=100
    ...            actCarrierAggregation=${False}
    ...        -- Check each cell should reach the expected same ul/dl tput value
    ...        Check tput via power UE optimized    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=100    exp_dl=100
    ...            actCarrierAggregation=${True}
    ...        -- Check CA total tput should reach the expected value
    ...        Check tput via power UE optimized    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=130    exp_dl=1200
    ...            exp_ul_indiv=0,130    exp_dl_indiv=800,1400    actCarrierAggregation=${True}
    ...        -- Check CA total tput should reach the expected value and aslo each cell should reach the expected value
    [Arguments]     ${cell_index}     ${tput_log_path}    ${direction}    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${None}    ${exp_dl_indiv}=${None}    ${actCarrierAggregation}=${True}    ${connection}=GNB_OAM
    ...    ${customized_log_name}=${None}    ${is_need_to_fail_keyword}=${True}
    ...    ${is_analysis_log_captured}=${False}    ${bip_log_name}=tput_validation_failed
    ...    ${bip_capture_time}=10s
    ...    ${cell_mapping}=${None}    ${check_source}=Aasyslog
    ...    ${gnb_index}=${0}    ${du_index}=${0}    #Valid for cloud snapshot collect
    ${direction}    Convert to lower case    ${direction}
    ${list_cell_index}    string2list    ${cell_index}
    @{list_nrCellIdentity}    _Get nrCellIdentity based on cell index    list_cell_index=${list_cell_index}    connection=${connection}
    ...    cell_mapping=${cell_mapping}

    ${exp_ul}    _Convert expected tput value for checking    exp_tput_value=${exp_ul}
    ${exp_dl}    _Convert expected tput value for checking    exp_tput_value=${exp_dl}
    Run keyword if    '${direction}'!='ul' and '${exp_dl}'=='${None}'
    ...    Fail    msg=Invalid input. exp_dl should not be none if direction is dl or both
    ...    ELSE IF    '${direction}'!='dl' and '${exp_ul}'=='${None}'
    ...    Fail    msg=Invalid input. exp_ul should not be none if direction is ul or both

    ${list_exp_ul}    Run keyword if    ${exp_ul_indiv}    string2list    ${exp_ul_indiv}
    ...    ELSE    Set variable    ${None}
    ${list_exp_dl}    Run keyword if    ${exp_dl_indiv}    string2list    ${exp_dl_indiv}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_ul}    Run keyword if    ${exp_ul_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_ul}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_dl}    Run keyword if    ${exp_dl_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_dl}
    ...    ELSE    Set variable    ${None}

    ${Check_tput_result}    Run keyword and return status    Run keyword if    '${direction}'=='both'    Run keywords
    ...    Run keyword and continue on failure   power_ue.Check Tput    direction=ul    ue_type=${ue_type}   log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}   target_throughput=${exp_ul}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}    check_source=${check_source}
    ...        cell_indiv_tput=${dict_exp_indv_tput_ul}    AND
    ...    Run keyword and continue on failure   power_ue.Check Tput    direction=dl    ue_type=${ue_type}   log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_dl}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}    check_source=${check_source}
    ...        cell_indiv_tput=${dict_exp_indv_tput_dl}
    ...    ELSE IF    '${direction}'=='ul'    power_ue.Check Tput    direction=ul    ue_type=${ue_type}   log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_ul}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}    check_source=${check_source}
    ...        cell_indiv_tput=${dict_exp_indv_tput_ul}
    ...    ELSE IF    '${direction}'=='dl'    power_ue.Check Tput    direction=dl    ue_type=${ue_type}   log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_dl}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}    check_source=${check_source}
    ...        cell_indiv_tput=${dict_exp_indv_tput_dl}
    ...    ELSE    Fail    msg=Invalid input for direction, supported values are: both, ul, dl
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${bip_log_file_path}    Run keyword if    ${Check_tput_result}==${False} and '${is_analysis_log_captured}'=='${True}' and ${has_cbts}==${False}
    ...    collect bip log for some time on webui   bip_capture_time=${bip_capture_time}    target_file_name=${bip_log_name}
    ...    ELSE    Create list
    Run keyword if    ${Check_tput_result}==${False} and '${is_analysis_log_captured}'=='${True}' and ${has_cbts}
    ...    Get snapshot logs on CU and DUs
    ...        gnb_index=${gnb_index}   du_index_list=${du_index}    is_called_in_test_case_level=${True}
    ...    ELSE IF    ${Check_tput_result}==${False} and '${is_analysis_log_captured}'=='${True}' and ${has_cbts}==${False}
    ...            COAM Save snapshot via webUI
    Run keyword if    '${is_need_to_fail_keyword}'=='True' and ${Check_tput_result}==${False}    Fail    msg=Validation failed for tput checking
    [Return]  ${bip_log_file_path}

collect bip log for some time on webui
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    ...            ${gnb_index}=0
    ...            ${timeout}=600
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${bip_capture_time}=5s
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=${interface}    host_ip=${host_ip}
    ...    username=${username}    password=${password}    nr_phy_cell_ids=${nr_phy_cell_ids}    timeout=${timeout}    destination=${destination}
    Log To Console    Start collect BIP log \n
    sleep    ${bip_capture_time}
    Log To Console    Stop and collect BIP log \n
    ${bip_log_file_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${target_dir}
     [Return]    ${bip_log_file_path}

_Convert expected tput value for checking
    [Documentation]  Author: Ding Binmei
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput, will return as ${None}
    ...        0: Means tput should < 2M,  will return as -2
    ...       Negative value: Means tput should < exp_value, will keep the original value
    ...       Positive value: Means tput should >= exp_value, will keep the original value
    [Arguments]  ${exp_tput_value}
    ${exp_tput_value_convert}    Set variable if    '${exp_tput_value}'=='-1'    ${None}
    ...    '${exp_tput_value}'=='0'    ${-2}
    ...    ${exp_tput_value}
    [Return]  ${exp_tput_value_convert}

_Get individual expected tput value for cells
    [Documentation]  Author: Ding Binmei
    ...    Return a dict value like: {nrcellIdentity1: exp_tput1, nrcellIdentity2: exp_tput2}
    [Arguments]     ${list_nrCellIdentity}     ${list_exp_tput}
    ${len_nrCellIdentity}    Get length    ${list_nrCellIdentity}
    ${len_exp_tput}    Get length    ${list_exp_tput}
    Should be True    ${len_nrCellIdentity}==${len_exp_tput}
    ...    msg=Invalid input for ${list_exp_tput}, if need to check tput for individual cells, then expeted tput value should be set to each cell
    &{dict_cell_indiv_tput}    Create dictionary
    FOR    ${index}    ${nrCellIdentity}    IN ENUMERATE    @{list_nrCellIdentity}
        ${exp_tput}    _Convert expected tput value for checking    exp_tput_value=${list_exp_tput[${index}]}
        Run keyword if    ${exp_tput}!=${None}
        ...     Set to dictionary    ${dict_cell_indiv_tput}    ${nrCellIdentity}=${exp_tput}
    END
    [Return]    ${dict_cell_indiv_tput}

_Get nrCellIdentity based on cell index
    [Documentation]  Author: Ding Binmei
    ...    :param ${list_cell_index}: should be in list format
    ...    If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...    Return the nrCellIdentity value as a list based on cell index
    [Arguments]    ${list_cell_index}    ${connection}=GNB_OAM    ${cell_mapping}=${None}
    @{list_nrCellIdentity}    Create List
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    &{cell_mapping}    Run keyword if    ${cell_mapping}    Set variable    ${cell_mapping}
    ...    ELSE IF    ${has_cbts}    cloud_gnb.get_relation_mapping_between_cell_and_others    vdu_connection=${connection}
    ...    ELSE    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    FOR    ${cell_index}    IN    @{list_cell_index}
        ${nrCellIdentity}    Evaluate    str(${cell_mapping[${cell_index}]['nrCellIdentity']})
        ${is_nrCellIdentity_a_digit}    Evaluate    str(${nrCellIdentity}).isdigit()
        Should be True    ${is_nrCellIdentity_a_digit}    msg=Invalid nrCellIdentity value
        Append to list    ${list_nrCellIdentity}    ${nrCellIdentity}
    END
    [Return]  ${list_nrCellIdentity}

Check tput via power UE
    [Documentation]    Author: Wang Yixiang
    ...   use TPUT check keyword of pwoer ue, and it will draw a tput picture
    ...   if specific cell tput not need to check, please set exp tput to -1
    ...   :param cell_id: global cell id, can be 1 or 1,2
    ...   :param exp_ul: expected tput of UL, can be 50 or 50,100. Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, can be 50 or 50,100. Unit in Mbps.
    ...   :param log: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...   :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...                   If you want to check cell TPUT one by one, please set it to ${False}
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   e.g: Check tput via power UE    cell_id=1,2    exp_ul=50,-1    exp_dl=100,500    log=${tput_log}
    [Arguments]     ${cell_id}    ${exp_ul}    ${exp_dl}     ${log}
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${actCarrierAggregation}=${False}    ${connection}=GNB_OAM    ${customized_log_name}=${None}
    ${list_cell_id}    string2list    ${cell_id}
    ${list_exp_ul}    string2list    ${exp_ul}
    ${list_exp_dl}    string2list    ${exp_dl}
    &{cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    FOR    ${index}    ${cell_id}    IN ENUMERATE    @{list_cell_id}
        ${nrCellIdentity}    Evaluate    str(${cell_mapping[${cell_id}]['nrCellIdentity']})
        @{list_nr_cell_ids}    Create list    ${nrCellIdentity}
        ${dl_exp_tput}    set variable   ${list_exp_dl}[${index}]
        ${ul_exp_tput}    set variable   ${list_exp_ul}[${index}]
        run keyword if    '${dl_exp_tput}'=='${-1}'    run keyword and continue on failure
        ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        target_throughput=${ul_exp_tput}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${ul_exp_tput}'=='${-1}'    run keyword and continue on failure
        ...        power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        target_throughput=${dl_exp_tput}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${dl_exp_tput}'=='${0}' and '${ul_exp_tput}'=='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=both
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=1    dltarget_throughput=1    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${dl_exp_tput}'=='${0}' and '${ul_exp_tput}'!='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=DL
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=${ul_exp_tput}    dltarget_throughput=1    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE IF    '${ul_exp_tput}'=='${0}' and '${dl_exp_tput}'!='${0}'    run keyword and continue on failure
        ...        sub check no tput for specify direction    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}   direction=UL
        ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
        ...        ultarget_throughput=1   dltarget_throughput=${dl_exp_tput}    min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
        ...    ELSE    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${log}    cells=${list_nr_cell_ids}
        ...        ultarget_throughput=${ul_exp_tput}   dltarget_throughput=${dl_exp_tput}     target_avg_percent=${target_avg_percent}
        ...        actCarrierAggregation=${actCarrierAggregation}   min_percent=${min_percent}
        ...        customized_log_name=${customized_log_name}
    END

sub check no tput for specify direction
    [Documentation]    Author: Wang Yixiang
    ...   the keyword is used to verify there is no tput for specify direction
    ...   :param cells: global cell id, can be 1 or 1,2
    ...   :param direction: specify direction which check no tput
    ...   :param ultarget_throughput: expected tput of UL, can be 50 or 50,100. Unit in Mbps.
    ...   :param dltarget_throughput: expected tput of DL, can be 50 or 50,100. Unit in Mbps.
    ...   :param log: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...   :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...                   If you want to check cell TPUT one by one, please set it to ${False}
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    [Arguments]     ${cells}    ${log}    ${direction}    ${ultarget_throughput}=1    ${dltarget_throughput}=1
    ...    ${ue_type}=${UE_TYPE}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${actCarrierAggregation}=${False}    ${customized_log_name}=${None}
    # check no tput for specified direction
    ${status}    run keyword if    '${direction}'=='UL'
    ...    run keyword and return status    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}
    ...         cells=${cells}   target_throughput=${ultarget_throughput}     target_avg_percent=${target_avg_percent}
    ...         customized_log_name=${customized_log_name}
    ...    ELSE IF    '${direction}'=='DL'
    ...    run keyword and return status    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}
    ...         cells=${cells}   target_throughput=${dltarget_throughput}     target_avg_percent=${target_avg_percent}
    ...         customized_log_name=${customized_log_name}
    ...    ELSE IF    '${direction}'=='both'
    ...    run keyword and return status    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${log}    cells=${cells}
    ...        ultarget_throughput=${ultarget_throughput}   dltarget_throughput=${dltarget_throughput}
    ...        target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...         customized_log_name=${customized_log_name}
    ...    ELSE    fail    the direction should be DL,UL or both

    # check good tput for other direction
    run keyword if    '${direction}'=='UL'
    ...    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}    min_percent=${min_percent}
    ...         cells=${cells}   target_throughput=${dltarget_throughput}     target_avg_percent=${target_avg_percent}
    ...         customized_log_name=${customized_log_name}
    ...    ELSE IF    '${direction}'=='DL'
    ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}    min_percent=${min_percent}
    ...         cells=${cells}   target_throughput=${ultarget_throughput}     target_avg_percent=${target_avg_percent}
    ...         customized_log_name=${customized_log_name}

    should be string    '${status}'=='${False}'     should be no ${direction} TPUT on cell:${cells}

L3 call check tput via power UE
    [Documentation]     Author: Wang Yixiang
    ...    compare with keyword "Call case with Commercial UE and record throughput info", this keyword check tput via power ue
    ...    1. attach ue
    ...    2. start traffic
    ...    3. check throughput
    ...   :param cell_id: global cell id, can be 1
    ...   :param dl_tput: Start traffic of DL, Unit in Mbps.
    ...   :param ul_tput: Start traffic of UL, Unit in Mbps.
    ...   :param exp_ul: expected tput of UL, Unit in Mbps.
    ...   :param exp_dl: expected tput of DL, Unit in Mbps.
    [Arguments]     ${cell_id}=1    ${dl_tput}=50M    ${ul_tput}=50M    ${exp_ul}=1    ${exp_dl}=1    ${tput_check_duration}=60s
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
    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=${tput_check_duration}    ignore_time=${ignore_time}   filter=${filter}
    Check tput via power UE    cell_id=${cell_id}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}

clean threads before do UE attach
    [Documentation]    Author: Zhang Ningning
    ...   Close UE task before UE attach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${Home_button}=${Home_button}   ${close_task}=${close_task}   ${ue_index}=${0}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${clean_threads_needed}=${clean_threads_needed}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword and Ignore Error    run keyword if    ${clean_threads_needed}==${True} and '${ue_type}'=='huawei'
    ...    Run Keywords    Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin   AND
    ...    sleep   2s    AND
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin    AND
    ...    sleep    4s     AND
    ...    csn.send_command   command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin    AND
    ...    sleep    4s     AND
    ...    csn.send_command   command=adb -s ${serial_number} shell input tap ${close_task}  connection=cygwin    AND
    ...    sleep    4s
    [Teardown]    csn.disconnect      connection=cygwin

Restart UE proxy service with nssm on CPC
    [Documentation]  Author: Catherine.cheng
    ...    Restart UE proxy service which triggered with nssm.exe on CPC
    ...    sc stop "UE_PROXY_RUNNER"
    ...    sc start "UE_PROXY_RUNNER"
    ...    sc query "UE_PROXY_RUNNER"
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}     ${UE_PROXY_service_name}=UE_PROXY_RUNNER
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${cmd_stop_proxy_service}    Set variable    sc stop "${UE_PROXY_service_name}"
    ${cmd_start_proxy_service}    Set variable    sc start "${UE_PROXY_service_name}"
    ${cmd_query_proxy_service}    Set variable    sc query ${UE_PROXY_service_name} | findstr "RUNNING"
    ${is_nssm_process_exits}    ssh_common_commands.is_process_exist    process_name=nssm.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}

    run keyword if    ${is_nssm_process_exits}    csn.Execute   command=${cmd_stop_proxy_service}    connection=${cpc_alias}
    sleep   1s
    run keyword if    ${is_nssm_process_exits}    csn.Execute   command=${cmd_start_proxy_service}    connection=${cpc_alias}
    sleep   1s
    run keyword if    ${is_nssm_process_exits}    csn.Execute   command=${cmd_query_proxy_service}    connection=${cpc_alias}
    ${is_nssm_process_exits_after_restart}    ssh_common_commands.is_process_exist    process_name=nssm.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    run keyword if    ${is_nssm_process_exits}    Should be true    ${is_nssm_process_exits_after_restart}
    ...    msg=UE proxy service is not running after restart
    sleep   30s    wait for NAA to reconnected with socket after UE proxy service restarted