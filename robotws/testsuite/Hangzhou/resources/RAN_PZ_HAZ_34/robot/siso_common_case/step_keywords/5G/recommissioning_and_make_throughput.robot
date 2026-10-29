*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library    ../../lib/frame_structure_and_throughput.py
Library    ../../lib/get_case_variables.py
Library    ../../lib/obtain_information.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter
Resource   ./basic/pre_analysis.robot
Resource   ./basic/bts_coam.robot
Resource   ./basic/ue.robot

*** Keywords ***
# Step SiSo keywords
# ${mrbtsID} and ${nrbtsID} set suite variable in SISO Coam Suite Setup
Modify_Band_Frame_Structure_And_Test_Throughput
    [Arguments]  ${ru_index}=${None}     ${band}=${None}    ${frame_structure}=${None}    ${ue_num_each_call}=1   ${cell_id}=${None}
    ...    ${4G_check}=${False}    ${protocol}=udp    ${loop_times}=${2}    ${check_wait_time}=30    ${random_access}=${false}
    ...    ${connection}=GNB_OAM    ${iperf_type}=${None}    ${duration}=${600}    ${ue_ul_layer}=1
    ...    ${use_case_variable}=${false}    ${suite_name}=default    ${test_name}=default
    ...    ${scf_path}=${Case_SCF_Path}    ${upload_tp}=${True}    ${upload_duration}=${True}
    ...    &{kwargs}
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ...    theoretical tput generate by nrdim
    Log    message=\nArgument iperf_type=${iperf_type} is not used and will be removed in the future.
    log to console    \n***Modify_Band_Frame_Structure_And_Test_Throughput***
    ${cell_index}    run keyword if    '${cell_id}'!='${None}'    convert to integer    ${cell_id}
    ${cell_list}    ${release}   ${get_scf_path}    Modify_Band_Frame_Structure    ru_index=${ru_index}    band=${band}
    ...    frame_structure=${frame_structure}    use_case_variable=${use_case_variable}    suite_name=${suite_name}    test_name=${test_name}
    ...    &{kwargs}
    ${delta_file}    run keyword if    ('${gNb_CuType.upper()}'=='SA' or '${gNb_CuType.upper()}'=='BOTH') and '${cell_index}'!='${None}'
    ...    Modify cell maxNumOfRrcSA Via Admin    cell_list=${cell_list}    cell_id=${cell_index}    ue_num_each_call=${ue_num_each_call}
    ...    connection=${connection}
    ${cell_list}    run keyword if    '${cell_index}'!='${None}'    create list    ${cell_index}
    ...    ELSE    set variable    ${cell_list}
    Get UE From Init File and Make call
    ...    cell_list=${cell_list}   ue_num_each_call=${ue_num_each_call}   4G_check=${4G_check}
    ...    random_access=${random_access}   check_wait_time=${check_wait_time}   loop_times=${loop_times}
    ...    with_peak=${True}   connection=${connection}   ue_ul_layer=${ue_ul_layer}
    ...    suite_name=${suite_name}   test_name=${test_name}   upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    scf_path=${scf_path}   protocol=${protocol}    duration=${duration}    check_ue=${True}
    [Teardown]  run keyword if    ('${gNb_CuType.upper()}'=='SA' or '${gNb_CuType.upper()}'=='BOTH') and '${cell_index}'!='${None}'
    ...    run keywords    connect to gnb coam via ssl    connection=${connection}    AND
    ...    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['reverse']}    connection=${connection}

Modify_Band_Frame_Structure
    [Documentation]
    ...    2020/3/11 Jia Lei: add documentation.
    ...    &{kwargs}: prach_index='97', beamset='2 beams', dl_ul_layer='4DL2UL', dl_modulation='dl_256QAM' for default
    ...    for keyword "Modify_Band_Frame_Structure", use it in this way:
    ...    Modify_Band_Frame_Structure  frame_structure=1116_0ms_GP1_B8    band=60    prach_index=156    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    ...    ${frame_structure} will be selected in 16 options, 8 A and 8 B.
    ...                       the difference between 'A' and 'B' lies in timingAdvanceOffset:
    ...                       if 'A', value='n25600'. if 'B', value='n39936'
    ...                       optionA_1: 1208_GP1_A1(guardperiodlength: 2),     optionA_2: 1208_GP2_A2(guardperiodlength: 4),
    ...                       optionA_3: 1070_GP1_A3(guardperiodlength: 2),     optionA_4: 1070_GP2_A4(guardperiodlength: 4),
    ...                       optionA_5: 1116_3ms_GP1_A5(guardperiodlength: 4), optionA_6: 1116_3ms_GP2_A6(guardperiodlength: 6),
    ...                       optionA_7: 1116_0ms_GP2_A7(guardperiodlength: 6), optionA_8: 1116_0ms_GP1_A8(guardperiodlength: 4),
    ...                       optionB_1: 1208_GP1_B1(guBrdperiodlength: 2),     optionB_2: 1208_GP2_B2(guBrdperiodlength: 4),
    ...                       optionB_3: 1070_GP1_B3(guBrdperiodlength: 2),     optionB_4: 1070_GP2_B4(guBrdperiodlength: 4),
    ...                       optionB_5: 1116_3ms_GP1_B5(guBrdperiodlength: 4), optionB_6: 1116_3ms_GP2_B6(guBrdperiodlength: 6),
    ...                       optionB_7: 1116_0ms_GP2_B7(guBrdperiodlength: 6), optionB_8: 1116_0ms_GP1_B8(guBrdperiodlength: 4)
    ...    ${band}: the value of chbw
    ...    ${prach_index}: the value of prachConfigurationIndex.
    ...    ${beamset_num}: the value of numberOfTransmittedSsBlocks.
    ...    ${dl_ul_layer}: the value of nrCellType
    ...    ${dl_modulation}: "dl_256QAM" or "dl_64QAM".
    [Arguments]  ${ru_index}=${None}    ${band}=${None}    ${frame_structure}=${None}    ${connection}=GNB_OAM
    ...    ${use_case_variable}=${false}    ${suite_name}=default    ${test_name}=default
    ...    &{kwargs}
    log to console    \nModify_Band_Frame_Structure
    connect to gnb coam via ssl    connection=${connection}
    ${status}    ${frame_structure_info}    run keyword and ignore error    get_frame_structure_info
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${cell_list}    get all cell id    ru_index=${ru_index}
    IF    '${status}'=='PASS' and ${use_case_variable}
        ${case_specified_cell_list}    get dictionary keys    ${frame_structure_info}
        ${cell_list}    set variable    ${{list(set($cell_list) & set($case_specified_cell_list))}}
    END
    ${release}    Get program version based on gNB active version
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${cell_band_frame_structure_list}    create list
    ${final_commission_flag}    set variable    ${False}
    FOR    ${cell_id}    IN    @{cell_list}
        ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
        ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
        ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
        ${ru_index}    get ru index from cell id via admin    cell_id=${cell_id}
        ${assembly_type}    get ru assembly type via admin    ru_index=${ru_index}
        ${modify_msg1frequencystart}    Get Modify Msg1frequencystart Flag    cell_id=${cell_id}    connection=${connection}
        ${commission_flag}    ${new_scf_path}    run keyword if    '${status}'=='PASS' and ${use_case_variable}
        ...    Generate Modify Parameters and Return Commission Flag   release=${release}   scf_path=${scf_path}
        ...    cell_id=${cell_id}    frame_structure_info=${frame_structure_info}
        ...    nband=${nband}    productName=${bbname}
        ...    modify_msg1frequencystart=${modify_msg1frequencystart}    assembly_type=${assembly_type}
        ...    ELSE    generate_real_modify_params_then_modify_scf    release=${release}   scf_path=${scf_path}
        ...    cell_id=${cell_id}    band=${band}    frame_structure=${frame_structure}
        ...    nband=${nband}    productName=${bbname}    modify_msg1frequencystart=${modify_msg1frequencystart}
        ...    &{kwargs}
        ${final_commission_flag}    set variable if    ${commission_flag}   ${commission_flag}    ${final_commission_flag}
    END
    ${skip_parameter_relation_errors}    Set Variable if    ${if_pdl_check}    ${False}    ${True}
    run keyword if    ${final_commission_flag}    run keywords
    ...    COAM Commission with scf file    scf_file_path=${new_scf_path}    timeout=600
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}        AND
    ...    sleep  200s  reason=sleep 200s after scf commission!
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Return]    ${cell_list}    ${release}    ${scf_path}

Get Modify Msg1frequencystart Flag
    [Arguments]  ${cell_id}    ${connection}=GNB_OAM
    ${not_modify_msg1frequencystart_ru}    create list    AZHA    AZNA
    ${ru_index}    get_ru_index_from_cell_id_via_admin    cell_id=${cell_id}    connection=${connection}
    ${productName}    get_ru_product_name_via_admin    ru_index=${ru_index}    connection=${connection}
    ${modify_msg1frequencystart}    run keyword and return status    should not contain    ${not_modify_msg1frequencystart_ru}    ${productName}
    [Return]  ${modify_msg1frequencystart}

Modify cell maxNumOfRrcSA Via Admin
    [Arguments]  ${cell_list}  ${cell_id}  ${ue_num_each_call}=1    ${connection}=GNB_OAM
    log to console    \nModify cell maxNumOfRrcSA Via Admin
    ${modify_params}  create list
    FOR    ${id}    IN    @{cell_list}
        ${new_value}    set variable if    '${id}'=='${cell_id}'    ${ue_num_each_call}    0
        ${dist_name}    set variable   MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${id}
        ${new_item}  create dictionary  dist_name=${dist_name}
        ...    parameter=maxNumOfRrcSA    value=${new_value}
        append to list  ${modify_params}  ${new_item}
    END
    ${delta_file}     coam_parameter.create_update_parameters_delta    parameters=${modify_params}    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['updated']}    connection=${connection}
    [Return]     ${delta_file}

Generate Peak Information
    [Arguments]  ${cell_list}    ${connection}=GNB_OAM    ${ue_dl_layer}=4    ${ue_ul_layer}=1    ${duration}=${600}
    ...    ${l3_avg_rate}=${None}    ${l3_min_rate}=${None}    ${suite_name}=default    ${test_name}=default
    ${release}    Get program version based on gNB active version
    ${avg_expect_rate}    get_l3_avg_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_avg_rate=${l3_avg_rate}
    ${min_expect_rate}    get_l3_min_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_min_rate=${l3_min_rate}
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${cell_and_peak_info}    create dictionary
    FOR    ${cell_id}    IN    @{cell_list}
        ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
        ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
        ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
        ${peak_info}    generate_real_peak_info    cell_id=${cell_id}    scf_path=${scf_path}    ue_dl_layer=${ue_dl_layer}
        ...    ue_ul_layer=${ue_ul_layer}    avg_expect_rate=${avg_expect_rate}    min_expect_rate=${min_expect_rate}
        ...    duration=${duration}    nband=${nband}    productName=${bbname}    release=${release}
        ${cell_id}    convert to string    ${cell_id}
        set to dictionary    ${cell_and_peak_info}    ${cell_id}    ${peak_info}
    END
    log to console    ${cell_and_peak_info}
    [Return]    ${cell_and_peak_info}

L3 call with Check Throughput
    [Arguments]  ${ue_index_list}=${None}  ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${600}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${protocol}=udp    ${upload_tp}=${True}
    ...    ${loop_times}=${2}    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}    ${direction}=BOTH
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85   ${bip_log_path}=${SAVE LOG DIRECTORY}    ${upload_duration}=${True}
    ...    ${reboot_limit_time}=${1}    ${scf_path}=${Case_SCF_Path}   ${gnb_index}=${0}   ${connection}=GNB_OAM
    [Documentation]  If reboot_ue is True, ue will reboot in detach ue, at most once reboot in one case.
    log to console    \n***L3 call with Check Throughput***
    ${status}    set variable    PASS
    FOR    ${i}    IN RANGE    ${loop_times}
        ${bip_log}   set variable if    '${status}'=='PASS'    ${False}    ${True}
        ${status}    ${repr}    run keyword and ignore error    UE L3 Call And Throughput  dl_tp=${dl_tp}  ul_tp=${ul_tp}
        ...        duration=${duration}  dl_exp=${dl_exp}  ul_exp=${ul_exp}   actual_rate=${actual_rate}    direction=${direction}
        ...        ue_index_list=${ue_index_list}  cell_list=${cell_list}  4G_check=${4G_check}    protocol=${protocol}
        ...        random_access=${random_access}  cell_and_peak_info=${cell_and_peak_info}    iperf_type=${iperf_type}
        ...        target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   bip_log=${bip_log}
        ...        bip_log_path=${bip_log_path}    reboot_limit_time=${reboot_limit_time}    check_wait_time=${check_wait_time}
        ...        upload_tp=${upload_tp}    upload_duration=${upload_duration}    scf_path=${scf_path}   gnb_index=${gnb_index}
        ...        connection=${connection}
        exit for loop if    '${status}'=='PASS'
    END
    should be true    '${status}'=='PASS'    msg=${repr}

UE L3 Call And Throughput
    [Arguments]    ${ue_index_list}=${None}    ${cell_list}=${None}   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M
    ...    ${duration}=${600}    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1    ${protocol}=udp    ${random_access}=${False}
    ...    ${interval}=10s    ${du_index}=0    ${connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...    ${cell_and_peak_info}=${None}    ${check_wait_time}=30    ${iperf_type}=${None}    ${upload_tp}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85  ${bip_log}=${False}   ${bip_log_path}=${SAVE LOG DIRECTORY}
    ...    ${reboot_limit_time}=${1}    ${upload_duration}=${True}    ${scf_path}=${Case_SCF_Path}   ${gnb_index}=${0}    ${direction}=BOTH
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}    scf_name=${scf_name}
    ${ui_version}    Get UE UI Version    scf_name=${scf_name}
    ${ue_index_list}    run keyword if    '${ue_index_list}'=='${None}'    create list    ${0}
    ...    ELSE    set variable    ${ue_index_list}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${status}    ${ue_and_cell}    run keyword and ignore error    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}    direction=${direction}
    ...    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}    protocol=${protocol}    connection=${connection}
    ...    check_wait_time=${check_wait_time}    iperf_type=${iperf_type}   ui_version=${ui_version}    4G_check=${4G_check}
    ...    bip_log_path=${bip_log_path}   bip_log=${bip_log}    reboot_ue=${false}    gnb_index=${gnb_index}
    ...    scf_path=${scf_path}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${False}    ${True}
    should be equal as strings    ${status}    PASS    msg=attach failed
    teardown the aasyslog save progress
    ${cell_number}  get length  ${cell_list}
    ${ue_number}  get length  ${ue_index_list}
    run keyword if  ${random_access}  should be true  ${cell_number}>=${ue_number}
    sleep    ${check_wait_time}
    ${status}    ${all_tput}    run keyword and ignore error    UE Verify Peak Throughput    ue_index_list=${ue_index_list}
    ...    ue_and_cell=${ue_and_cell}    dl_exp=${dl_exp}    ul_exp=${ul_exp}    direction=${direction}    gnb_index=${gnb_index}
    ...    interval=${interval}    duration=${duration}    actual_rate=${actual_rate}    du_index=${du_index}
    ...    gnb_ssl_connection=${connection}    is_need_to_capture_log=${is_need_to_capture_log}
    ...    cell_and_peak_info=${cell_and_peak_info}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    upload_tp=${upload_tp}    upload_duration=${upload_duration}    scf_path=${scf_path}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${ue_reboot_flag}    ${True}
    should be equal as strings    ${status}    PASS    msg=verify throughput failed
    [Return]  ${all_tput}
    [Teardown]    run keywords  run keyword and ignore error  csn.disconnect    connection=ASIK Master  AND  Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}    protocol=${protocol}    reboot_ue=${ue_reboot_flag}
    ...    reboot_limit_time=${reboot_limit_time}

Generate Modify Parameters and Return Commission Flag
    [Arguments]    ${release}    ${scf_path}    ${cell_id}    ${frame_structure_info}    ${nband}    ${productName}
    ...    ${assembly_type}    ${modify_msg1frequencystart}=${True}
    ${band}    get from dictionary    ${frame_structure_info[${cell_id}]}     band
    ${frame_structure}    get from dictionary    ${frame_structure_info[${cell_id}]}     frame_structure
    ${status}    ${prach_index}    run keyword and ignore error    get from dictionary
    ...    ${frame_structure_info[${cell_id}]}    prach
    ${prach_index}    set variable if    '${status}'=='PASS'    ${prach_index}    ${None}
    ${status}    ${beamset}    run keyword and ignore error    get from dictionary
    ...    ${frame_structure_info[${cell_id}]}       beamset
    ${beamset}    set variable if    '${status}'=='PASS'    ${beamset}    ${None}
    ${status}    ${basicBeamSet}    run keyword and ignore error    get from dictionary
    ...    ${frame_structure_info[${cell_id}]}       basicBeamSet
    ${basicBeamSet}    set variable if    '${status}'=='PASS'    ${basicBeamSet}    ${None}
    ${commission_flag}    ${new_scf_path}    generate_real_modify_params_then_modify_scf    release=${release}   scf_path=${scf_path}
    ...    cell_id=${cell_id}    band=${band}    frame_structure=${frame_structure}
    ...    prach_index=${prach_index}    beamset=${beamset}    basicBeamSet=${basicBeamSet}
    ...    nband=${nband}    productName=${productName}
    ...    modify_msg1frequencystart=${modify_msg1frequencystart}    assembly_type=${assembly_type}
    [Return]  ${commission_flag}    ${new_scf_path}

Get UE From Init File and Make call
    [Documentation]  cell_list: [1] or [1,2],
    ...              if cell list not mapping ue in init file, ue_index=0
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=${60}
    ...    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1    ${random_access}=${False}    ${check_wait_time}=30    ${direction}=BOTH
    ...    ${loop_times}=${2}    ${with_peak}=${False}    ${target_avg_percent}=0.1    ${min_percent}=0.05    ${connection}=GNB_OAM
    ...    ${ue_dl_layer}=4    ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${scf_path}=${Case_SCF_Path}    ${protocol}=udp    ${check_ue}=${False}    ${gnb_index}=${0}
    ${ue_index_list}    ${get_cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ...    scf_path=${scf_path}
    ${ue_num}    get length    ${ue_index_list}
    run keyword if    ${ue_num}==${0}    log to console  \nno ue on ${cell_list}!!!
    ...    ELSE    log to console  \ue ${ue_index_list} on ${cell_list}!!!
    return from keyword if    ${ue_num}==${0} and not ${check_ue}
    should be equal as integers    ${ue_num}    ${ue_num_each_call}
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${ue_dl_layer}    get_ue_dl_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_dl_layer=${ue_dl_layer}
    ...    scf_name=${scf_name}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ...    scf_name=${scf_name}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    ${protocol}    get_protocol_from_ue_mapping_file    testline_name=${testline_name}    protocol=${protocol}
    ...    scf_name=${scf_name}
    L3 call with Check Throughput    ue_index_list=${ue_index_list}  cell_list=${get_cell_list}
    ...    4G_check=${4G_check}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}    direction=${direction}
    ...    dl_exp=${dl_exp}    ul_exp=${ul_exp}    actual_rate=${actual_rate}    random_access=${random_access}
    ...    loop_times=${loop_times}    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    scf_path=${scf_path}   connection=${connection}     gnb_index=${gnb_index}

Modify_Band_Frame_Structure_And_Test_Throughput_multi_cc_with_different_bandwith
    [Arguments]  ${frames_info}    ${ue_num_each_call}=1   ${cell_id}=${None}
    ...    ${4G_check}=${False}    ${protocol}=udp    ${loop_times}=${2}    ${check_wait_time}=30    ${random_access}=${false}
    ...    ${connection}=GNB_OAM    ${duration}=${300}    ${ue_ul_layer}=1    &{kwargs}
    ${cell_index}    run keyword if    '${cell_id}'!='${None}'    convert to integer    ${cell_id}
    ${cell_list}    ${release}   ${scf_path}    Modify_Band_Frame_Structure_multi_cc_with_different_bandwith
    ...    frames_info=${frames_info}    cell_id=${cell_id}    &{kwargs}
    ${delta_file}    run keyword if    ('${gNb_CuType.upper()}'=='SA' or '${gNb_CuType.upper()}'=='BOTH') and '${cell_index}'!='${None}'
    ...    Modify cell maxNumOfRrcSA Via Admin    cell_list=${cell_list}    cell_id=${cell_index}    ue_num_each_call=${ue_num_each_call}
    ...    connection=${connection}
    ${cell_list}    run keyword if    '${cell_index}'!='${None}'    create list    ${cell_index}
    ...    ELSE    set variable    ${cell_list}
    ${ue_index_list}  ${cell_list}  Get UE List for Given Cell List  cell_list=${cell_list}  ue_num_each_call=${ue_num_each_call}
    ...    random_access=${random_access}
    ${cell_and_peak_info}    generate peak information    cell_list=${cell_list}    duration=${duration}    ue_ul_layer=${ue_ul_layer}    &{kwargs}
    L3 call with Check Throughput    ue_index_list=${ue_index_list}  cell_list=${cell_list}
    ...    4G_check=${4G_check}    protocol=${protocol}    loop_times=${loop_times}    duration=${duration}
    ...    check_wait_time=${check_wait_time}    cell_and_peak_info=${cell_and_peak_info}
    [Teardown]  run keyword if    ('${gNb_CuType.upper()}'=='SA' or '${gNb_CuType.upper()}'=='BOTH') and '${cell_index}'!='${None}'
    ...    run keywords    connect to gnb coam via ssl    connection=${connection}    AND
    ...    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['reverse']}    connection=${connection}

Modify_Band_Frame_Structure_multi_cc_with_different_bandwith
    [Documentation]
    ...    2020/3/11 Jia Lei: add documentation.
    ...    &{kwargs}: prach_index='97', beamset='2 beams', dl_ul_layer='4DL2UL', dl_modulation='dl_256QAM' for default
    ...    for keyword "Modify_Band_Frame_Structure", use it in this way:
    ...    Modify_Band_Frame_Structure  frame_structure=1116_0ms_GP1_B8    band=60    prach_index=156    beamset=4 beams
    ...    dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    ...    ${frame_structure} will be selected in 16 options, 8 A and 8 B.
    ...                       the difference between 'A' and 'B' lies in timingAdvanceOffset:
    ...                       if 'A', value='n25600'. if 'B', value='n39936'
    ...                       optionA_1: 1208_GP1_A1(guardperiodlength: 2),     optionA_2: 1208_GP2_A2(guardperiodlength: 4),
    ...                       optionA_3: 1070_GP1_A3(guardperiodlength: 2),     optionA_4: 1070_GP2_A4(guardperiodlength: 4),
    ...                       optionA_5: 1116_3ms_GP1_A5(guardperiodlength: 4), optionA_6: 1116_3ms_GP2_A6(guardperiodlength: 6),
    ...                       optionA_7: 1116_0ms_GP2_A7(guardperiodlength: 6), optionA_8: 1116_0ms_GP1_A8(guardperiodlength: 4),
    ...                       optionB_1: 1208_GP1_B1(guBrdperiodlength: 2),     optionB_2: 1208_GP2_B2(guBrdperiodlength: 4),
    ...                       optionB_3: 1070_GP1_B3(guBrdperiodlength: 2),     optionB_4: 1070_GP2_B4(guBrdperiodlength: 4),
    ...                       optionB_5: 1116_3ms_GP1_B5(guBrdperiodlength: 4), optionB_6: 1116_3ms_GP2_B6(guBrdperiodlength: 6),
    ...                       optionB_7: 1116_0ms_GP2_B7(guBrdperiodlength: 6), optionB_8: 1116_0ms_GP1_B8(guBrdperiodlength: 4)
    ...    ${band}: the value of chbw
    ...    ${prach_index}: the value of prachConfigurationIndex.
    ...    ${beamset_num}: the value of numberOfTransmittedSsBlocks.
    ...    ${dl_ul_layer}: the value of nrCellType
    ...    ${dl_modulation}: "dl_256QAM" or "dl_64QAM".
    [Arguments]    ${frames_info}    ${cell_id}=${None}    ${connection}=GNB_OAM    &{kwargs}
    log to console    \nModify_Band_Frame_Structure
    ${cell_list}    create list
    FOR    ${item}    IN    @{frames_info}
       append to list    ${cell_list}    ${item}[cellid]
    END
    ${release}    Get program version based on gNB active version
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    connect to gnb coam via ssl    connection=${connection}
    ${cell_band_frame_structure_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${tmp_index}    Evaluate       ${cell_id} - 1
        ${commission_flag}    ${new_scf_path}    generate_real_modify_params_then_modify_scf    release=${release}   scf_path=${scf_path}
        ...    cell_id=${cell_id}    band=${frames_info[${tmp_index}]}[band]    frame_structure=${frames_info[${tmp_index}]}[frame]
        ...    prach_index=${frames_info[${tmp_index}]}[prach_index]    beamset=${frames_info[${tmp_index}]}[beamset]
        ...    dl_ul_layer=${frames_info[${tmp_index}]}[dl_ul_layer]    dl_modulation=${frames_info[${tmp_index}]}[dl_modulation]
        append to list    ${cell_band_frame_structure_list}    ${cell_id}-${frames_info[${tmp_index}]}[band]-${frames_info[${tmp_index}]}[frame]
    END
    run keyword if    ${commission_flag}    run keywords
    ...    COAM Commission with scf file    scf_file_path=${new_scf_path}    timeout=600    AND
    ...    sleep  200s  reason=sleep 200s after scf commission!
    run keyword if    ${commission_flag}    COAM Commission with scf file    scf_file_path=${new_scf_path}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Return]    ${cell_list}    ${release}    ${scf_path}

Get framestructinfo
    [Arguments]    ${framelistname}    ${frameindex}
    ${result}    create list
    ${len}    Get length    ${framelistname}
    FOR    ${index}    IN RANGE    ${len}
        ${frame_info_dict}    copy dictionary    ${framelistname}[${index}]
        set to dictionary    ${frame_info_dict}    frame    ${framelistname}[${index}][frame][${frameindex}]
        set to dictionary    ${frame_info_dict}    prach_index    ${framelistname}[${index}][prach_index][${frameindex}]
        append to list    ${result}    ${frame_info_dict}
    END
    [Return]    ${result}

start traffic all cells sa
    [Documentation]
    ...    *****************
    ...    Owner_zhenzhen.ren@nokia-sbell.com
    ...    ******************
    [Arguments]    ${cell_list}    ${ue_num}    ${4G_check}=${False}
    log to console    \n***start traffic all cells sa***
    Get UE From Init File and Make call    cell_list=${cell_list}    random_access=${True}
    ...    ue_num_each_call=${ue_num}    duration=100    4G_check=${4G_check}

start traffic all cells nsa
    [Arguments]    ${cell_list}    ${4G_check}=${False}
    FOR    ${cell_id}  IN  @{cell_list}
        ${cell_id_list}    create list    ${cell_id}
        Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=${4G_check}
    END

Get Tput ue Number
    [Arguments]    ${given_num}    ${scf_commission_path}=${Case_SCF_Path}
    ${given_num}    convert to integer    ${given_num}
    ${result}    split string    ${scf_commission_path}    /
    ${file}    replace string    ${scf_commission_path}    ${result[-1]}    __init__.py
    ${status}    run keyword and return status    file should exist    ${file}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${scf_commission_path}
    ${ue_num}    run keyword if    ${status}    get_tput_ue_num_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}
    ...    ELSE    get length    ${tl.ues}
    ${return_num}    set variable if    ${ue_num}<${given_num}    ${ue_num}    ${given_num}
    [Return]  ${return_num}

UE L3 Call And Get Avg Tput
    [Documentation]  UE L3 Call And Get Avg Tput  [{CELL_ID:1,UL:24.333,DL:300.3333}]
    ...   Author:kaihui.fan@nokia-sbell.com
    ...   Date:2024/5/27
    [Arguments]    ${cell_id_list}=${None}   ${with_peak}=${True}  ${ue_num_each_call}=1  ${flag}=average
    ...   ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M  ${connection}=GNB_OAM
    ...    ${duration}=${120}    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1    ${protocol}=udp    ${random_access}=${False}
    ...    ${interval}=10s    ${du_index}=0   ${is_need_to_capture_log}=${False}
    ...   ${check_wait_time}=30    ${iperf_type}=${None}    ${upload_tp}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85  ${bip_log}=${False}   ${bip_log_path}=${SAVE LOG DIRECTORY}
    ...    ${reboot_limit_time}=${1}    ${upload_duration}=${True}    ${scf_path}=${Case_SCF_Path}    ${ue_dl_layer}=4
    ...   ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ${ue_index_list}    ${get_cell_list}    Get UE List for Given Cell List    cell_list=${cell_id_list}    ue_num_each_call=${ue_num_each_call}
    ...    scf_path=${scf_path}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${ue_dl_layer}    get_ue_dl_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_dl_layer=${ue_dl_layer}
    ...    scf_name=${scf_name}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ...    scf_name=${scf_name}
    ${cell_and_peak_info}    run keyword if    ${with_peak}    generate peak information     cell_list=${cell_id_list}
    ...    connection=${connection}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ...    l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}    suite_name=${suite_name}    test_name=${test_name}
    ...    ELSE    set variable    ${None}
    ${all_tput}   UE L3 Call And Throughput    cell_list=${get_cell_list}  ue_index_list=${ue_index_list}
    ...   dl_tp=${dl_tp}  ul_tp=${ul_tp}  target_avg_percent=${target_avg_percent}    min_percent=${min_percent}  upload_duration=${upload_duration}
    ...   reboot_limit_time=${reboot_limit_time}   4G_check=${4G_check}  dl_exp=${dl_exp}  ul_exp=${ul_exp}  actual_rate=${actual_rate}
    ...   duration=${duration}    cell_and_peak_info=${cell_and_peak_info}  iperf_type=${iperf_type}
    ...   bip_log_path=${bip_log_path}   bip_log=${bip_log}     protocol=${protocol}  random_access=${random_access}
    ...    scf_path=${scf_path}  interval=${interval}  du_index=${du_index}  is_need_to_capture_log=${is_need_to_capture_log}  upload_tp=${upload_tp}
    ...    check_wait_time=${check_wait_time}   connection=${connection}
    @{cells_avg_tput}  Create List
    FOR    ${cell_id}    IN    @{get_cell_list}
        &{cell_avg_tp_dict}  Create Dictionary
        ${cell_id}    convert to string    ${cell_id}
        ${ul_average}  ${dl_average}  Get UL and DL Average For Every Cell    all_tp=${all_tput}  cell_id=${cell_id}  flag=${flag}
        ...  connection=${connection}
        set to dictionary  ${cell_avg_tp_dict}  UL_AVG  ${ul_average}
        set to dictionary  ${cell_avg_tp_dict}  DL_AVG  ${dl_average}
        set to dictionary  ${cell_avg_tp_dict}  CELL_ID  ${cell_id}
        append to list  ${cells_avg_tput}  ${cell_avg_tp_dict}
        Log to console   The cell ${cell_id} DL average result is ${dl_average}
        Log to console   The cell ${cell_id} UL average result is ${ul_average}
    END
    [Return]  ${cells_avg_tput}

Get UL and DL Average For Every Cell
    [Documentation]     Get average number and print
    [Arguments]  ${all_tp}  ${cell_id}  ${flag}=average  ${connection}=GNB_OAM
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${nrCellIdentity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    @{ul_dl_average_tp}    create list
    FOR  ${item}  IN  @{all_tp}
        ${cid}=  Get From Dictionary  ${item[0]}  cellid
        ${average_tp}  Run Keyword If  '${cid}'=='${nrCellIdentity}'  Get From Dictionary  ${item[0]}  ${flag}
        Run Keyword If  '${cid}'=='${nrCellIdentity}'  append to list  ${ul_dl_average_tp}  ${average_tp}
    END
    ${ul_avg_tp}=  Get From List  ${ul_dl_average_tp}  0
    ${dl_avg_tp}=  Get From List  ${ul_dl_average_tp}  1
    Log to console   The DL ${flag} result is ${ul_avg_tp}
    Log to console   The DL ${flag} result is ${dl_avg_tp}
   [Return]  ${ul_avg_tp}  ${dl_avg_tp}
