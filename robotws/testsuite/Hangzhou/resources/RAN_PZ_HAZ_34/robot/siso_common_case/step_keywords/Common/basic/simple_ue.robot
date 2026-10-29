*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/obtain_information.py
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Keywords ***
Simple Get UE List for Given Cell
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${ue_num_for_call_per_cell}=1    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=LTE
    ...    &{kwargs}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${ue_index_list}    get_ue_for_cell_with_condition_from_ue_mapping_file    testline_name=${testline_name}
    ...    cell_id=${cell_id}    ue_num=${ue_num_for_call_per_cell}    scf_name=${scf_name}
    ...    mobile_network_system=${mobile_network_system}
    [Return]    ${ue_index_list}

Obtain UE List for Given Cell List
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_list}    ${ue_num_for_call_per_cell}=1    ${scf_path}=${Golden_SCF_Path}
    ...    ${mobile_network_system}=LTE
    ${ue_index_list}    create list
    ${get_cell_list}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${tmp_ue_index_list}    Simple Get UE List for Given Cell    cell_id=${cell_id}    ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
        ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}    ext_ue_index_ist=${ue_index_list}
        ${status}    run keyword and return status    should not be empty    ${tmp_ue_index_list}
        Continue For Loop If   not ${status}
        ${ue_index_list}    combine lists    ${ue_index_list}    ${tmp_ue_index_list}
        append to list    ${get_cell_list}    ${cell_id}
    END
    [Return]    ${ue_index_list}    ${get_cell_list}

Get Ue should attached pci
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=LTE
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${pci}    get_pci_from_ue_mapping_file    testline_name=${testline_name}
    ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
    [Return]    ${pci}

Get Ue should locked arfcn
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=LTE
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${arfcn}    get_arfcn_from_ue_mapping_file    testline_name=${testline_name}
    ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
    [Return]    ${arfcn}

Get Ue should locked band
    [Documentation]  Auther: shifu.lan@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=NR
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${band}    get_band_from_ue_mapping_file    testline_name=${testline_name}
    ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
    [Return]    ${band}

Get Ue should locked scs
    [Documentation]  Auther: shifu.lan@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=NR
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${scs}    get_scs_from_ue_mapping_file    testline_name=${testline_name}
    ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
    [Return]    ${scs}

Modify UE Capatibility to Given Params
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${mobile_network_system}=LTE     ${scf_path}=${Golden_SCF_Path}
    ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}
    ...    mobile_network_system=${mobile_network_system}
    ${arfcn}    Get Ue should locked arfcn    ue_index=${ue_index}    scf_path=${scf_path}
    ...    mobile_network_system=${mobile_network_system}
    ${band}    Get Ue should locked band    ue_index=${ue_index}    scf_path=${scf_path}
    ...    mobile_network_system=${mobile_network_system}
    ${scs}    Get Ue should locked scs    ue_index=${ue_index}    scf_path=${scf_path}
    ...    mobile_network_system=${mobile_network_system}
    run keyword if    '${mobile_network_system}'=='LTE' and ('${pci}'=='${0}' or '${arfcn}'=='${0}')    return from keyword
    run keyword if    '${mobile_network_system}'=='NR' and ('${arfcn}'=='${0}' or ('${pci}'=='${0}' and '${scs}'=='${0}'))    return from keyword
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='nokia_fastmile'    nokia_fastmile.Modify UE Capatibility    ue_index=${ue_index}
    ...    mobile_network_system=${mobile_network_system}    pci=${pci}    arfcn=${arfcn}    band=${band}    scs=${scs}

Simple Ue Prepare
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${mobile_network_system}=LTE     ${scf_path}=${Golden_SCF_Path}
    log to console    \nUe Prepare
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        Modify UE Capatibility to Given Params    ue_index=${ue_index}    mobile_network_system=${mobile_network_system}
        ...    scf_path=${scf_path}
    END

Simple Ue Attach
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${log_type}=Iperf    ${scf_path}=${Golden_SCF_Path}    ${power_reset}=${False}
    ...    ${mobile_network_system}=LTE
    log to console    \nUe Attach
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
        ${status}    run keyword and return status      power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ...    log_type=${log_type}    pci=${pci}    power_reset=${power_reset}
        run keyword if    not ${status}      power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ...    log_type=${log_type}    pci=${pci}    power_reset=${False}
    END

Simple Ue Start DL UL Traffic
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${dl_tp}=300    ${ul_tp}=10    ${duration}=${300}    ${protocol}=udp
    ...    ${apn}=${None}    &{kwargs}
    log to console    \nUe Start DL UL Traffic
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    apn=${apn}
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    apn=${apn}
    END

Simple Ue Attach and Start Traffic
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${dl_tp}=300    ${ul_tp}=10    ${duration}=${300}    ${check_wait_time}=${60}    ${protocol}=udp
    ...    ${scf_path}=${Golden_SCF_Path}    ${mobile_network_system}=NR    ${cell_and_peak_info}=${None}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${ue_number}    get length    ${ue_index_list}
    ${ue_and_cell}    create dictionary
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        log to console    \nUe ${ue_index} Attach
        power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Cloud
        # WA for ue and cell mapping, will mapping with get ue info later
        ${cell_id_list}    get_cell_id_list_from_ue_mapping_file    testline_name=${testline_name}
        ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
        ${cell_id}    set variable    ${cell_id_list[0]}
        ${ue_index}    convert to string    ${ue_index}
        set to dictionary    ${ue_and_cell}    ${ue_index}=${cell_id}
        ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
        log to console    \nUe ${ue_index} Start traffic
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}
        ${ul_iperf_process}    Simple Get Ul Iperf Process    scf_name=${scf_name}
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${ul_iperf_process}
    END
    [Return]  ${ue_and_cell}

Simple Get Ul Iperf Process
    [Arguments]    ${scf_name}=${None}
    ${testline_name}    Get Testline Name
    ${ul_iperf_process}    get_ul_iperf_process_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}
    [Return]    ${ul_iperf_process}

Simple UE Verify Peak Throughput
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${dl_tp}=100    ${ul_tp}=10    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${log}=${CASE_LOG_PATH}    ${check_source}=Iperf    ${cells}=${None}   ${scf_path}=${None}    ${mobile_network_system}=LTE
    log to console    \nUE Verify Peak Throughput
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${get_cells}    Get CellIdentity    ue_index=${ue_index}    cells=${cells}    scf_path=${scf_path}
        ...    mobile_network_system=${mobile_network_system}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword if    '${check_source.lower()}'=='aasyslog'    run keywords
        ...    power_ue.Check Bi Tput   ue_type=nokia_fastmile    log=${log}    cells=${get_cells}   ultarget_throughput=${ul_tp}
        ...    dltarget_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    AND
        ...    return from keyword
        run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    target_throughput=${dl_tp}
        ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    check_source=${check_source}    cells=${get_cells}
        run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=ul    target_throughput=${ul_tp}
        ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    check_source=${check_source}    cells=${get_cells}
    END

Get CellIdentity
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${cells}=${None}    ${scf_path}=${None}    ${mobile_network_system}=LTE
    ${status1}    run keyword and return status    Should Not Be Equal As Strings    ${cells}    ${None}
    ${status2}    run keyword and return status    Should Be Equal As Strings    ${scf_path}    ${None}
    return from keyword if    ${status1} or ${status2}    ${cells}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${testline_name}    Get Testline Name
    ${cell_id_list}    get_cell_id_list_from_ue_mapping_file    testline_name=${testline_name}
    ...    ue_index=${ue_index}    scf_name=${scf_name}    mobile_network_system=${mobile_network_system}
    ${cell_id}    set variable    ${cell_id_list[0]}
    ${cell_details_list}    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation.get_lte_cell_data_via_admin
    FOR    ${cell_details}    IN    @{cell_details_list}
        ${cells}    run keyword if    '${cell_details}[globalCellId]'=='${cell_id}'    create list    ${cell_details}[cell_id]
        ${status}    run keyword and return status    Should Not Be Equal As Strings    ${cells}    ${None}
        return from keyword if    ${status}    ${cells}
    END
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${nrCellIdentity}    Convert To String    ${cell_mapping['cell_id']['nrCellIdentity']}
    ${cells}    Create List    ${nrCellIdentity}
    [Return]    ${cells}

Simple Ue Stop DL UL Traffic
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic and Detach
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        ...    protocol=${protocol}
    END

Simple Ue Detach
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}
    log to console    \nUe Detach
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

Simple Ue Collect Tput
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index_list}    ${duration}=60    ${ignore_time}=60    ${check_source}=Iperf
    log to console    \nCollect Tput
    run keyword if    '${check_source.lower()}'=='aasyslog'    run keywords
    ...    power_ue.Collect Tput    ue_type=nokia_fastmile    check_source=${check_source}    duration=${duration}    ignore_time=${ignore_time}
    ...    check_source=Aasyslog    AND
    ...    return from keyword
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index_list}[0]
        ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    check_source=${check_source}    duration=${duration}
        ...    ignore_time=${ignore_time}
    END
    [Return]  ${log_path}

Simple UE L3 Call And Throughput
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ...    should add ue mapping in commissionings/HGZ/{testline_name}}/__init__.py
    [Arguments]    ${cell_list}=${None}    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=60    ${protocol}=udp    ${check_wait_time}=60    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${scf_path}=${Golden_SCF_Path}
    ...    ${allowed_no_ue}=${False}    ${mobile_network_system}=LTE    ${loop_times}=${2}
    ...    ${with_peak}=${False}    ${suite_name}=default    ${test_name}=default    ${apn}=${None}    &{kwargs}
    ${cell_list}    run keyword if    '${cell_list}'=='${None}'    create list    ${1}
    ...    ELSE    set variable    ${cell_list}
    ${ue_index_list}    ${cell_id_list}    Obtain UE List for Given Cell List    cell_list=${cell_list}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    ${ue_num}    get length    ${ue_index_list}
    run keyword if    not ${allowed_no_ue}    should not be empty    ${ue_index_list}
    ...    msg=Please add ue mapping in __init__.py under robotws/commissionings/HGZ/{testline_name}}, refer to 7_5_UTE5G402T319
    ...    ELSE IF    ${allowed_no_ue} and ${ue_num}==0    run keywords    log to console    no ue on cell ${cell_list}!!!    AND
    ...    return from keyword
    ${release}    Get program version based on gNB active version
    ${target_avg_percent}    set variable if    ${with_peak}    ${None}     ${target_avg_percent}
    ${min_percent}    set variable if    ${with_peak}    ${None}     ${min_percent}
    ${release}    Get program version based on gNB active version
    ${target_avg_percent}    get_l3_avg_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_avg_rate=${target_avg_percent}
    ${min_percent}    get_l3_min_rate    suite_name=${suite_name}    test_name=${test_name}    release=${release}
    ...    l3_min_rate=${min_percent}
    wait until keyword succeeds    ${loop_times}x    30sec     UE L3 CAll Procedure    ue_index_list=${ue_index_list}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    duration=${duration}   protocol=${protocol}    check_wait_time=${check_wait_time}    log=${log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${scf_path}
    ...    mobile_network_system=${mobile_network_system}    apn=${apn}

UE L3 CAll Procedure
    [Arguments]    ${ue_index_list}    ${dl_tp}=128  ${ul_tp}=12
    ...    ${duration}=60    ${protocol}=udp    ${check_wait_time}=60    ${log}=${CASE_LOG_PATH}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${scf_path}=${Golden_SCF_Path}
    ...    ${mobile_network_system}=LTE    ${apn}=${None}
    Simple Ue Prepare    ue_index_list=${ue_index_list}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    ${ue_num}    get length    ${ue_index_list}
    ${start_traffic_duration}    evaluate    ${duration}+${ue_num}*240
    ${start_traffic_dl}    evaluate    ${dl_tp}*1.25
    ${start_traffic_ul}    evaluate    ${ul_tp}*1.5
    Simple Ue Attach    ue_index_list=${ue_index_list}    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    Simple Ue Start DL UL Traffic    ue_index_list=${ue_index_list}    dl_tp=${start_traffic_dl}    ul_tp=${start_traffic_ul}
    ...    duration=${start_traffic_duration}     protocol=${protocol}    scf_path=${scf_path}    apn=${apn}
    Simple Ue Collect Tput    ue_index_list=${ue_index_list}    duration=${duration}    ignore_time=${check_wait_time}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}    protocol=${protocol}
    Simple UE Verify Peak Throughput    ue_index_list=${ue_index_list}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log=${log}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    [Teardown]  Simple Ue Detach    ue_index_list=${ue_index_list}

UE L3 Call for Designated cell
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=${None}  ${cell_id}=${None}
    ...    ${ue_num_for_call_per_cell}=1    ${dl_tp}=100  ${ul_tp}=10
    ...    ${duration}=${200}    ${protocol}=udp    ${check_wait_time}=60
    ...    ${target_avg_percent}=0.5    ${min_percent}=0.1    ${scf_path}=${Golden_SCF_Path}
    ...    ${with_peak}=${False}    ${suite_name}=default    ${test_name}=default
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    ${cell_list}    run keyword if    '${cell_id}'=='${None}'    set variable    ${cell_id_list}
    ...    ELSE    create list    ${cell_id}
    Simple UE L3 Call And Throughput    cell_list=${cell_list}
    ...                                 ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
    ...                                 dl_tp=${dl_tp}
    ...                                 ul_tp=${ul_tp}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 check_wait_time=${check_wait_time}
    ...                                 target_avg_percent=${target_avg_percent}
    ...                                 min_percent=${min_percent}
    ...                                 scf_path=${scf_path}
    ...                                 with_peak=${with_peak}
    ...                                 suite_name=${suite_name}
    ...                                 test_name=${test_name}
