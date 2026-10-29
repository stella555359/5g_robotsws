*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/obtain_information.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource   ./bip_log.robot

*** Keywords ***
Get UE List for Given Cell List
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1    ${random_access}=${False}
    ...    ${scf_path}=${Case_SCF_Path}
    Log    message=\nArgument random_access=${random_access} is not used and will be removed in the future.
    ${testline_name}    Get Testline Name
    ${ue_index_list}    ${call_cell_list}    get_ue_index_list    testline_name=${testline_name}
    ...    cell_list=${cell_list}    used_ue_num=${ue_num_each_call}    scf_path=${scf_path}
    [Return]    ${ue_index_list}    ${call_cell_list}

Ue Attach and Start DL UL Traffic
    [Arguments]  ${ue_index_list}    ${dl_tp}=300M  ${ul_tp}=100M  ${duration}=${600}  ${cell_and_peak_info}=${None}   ${protocol}=udp
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${check_wait_time}=30    ${iperf_type}=via_command   ${ui_version}=default
    ...    ${4G_check}=${False}    ${bip_log_path}=${SAVE LOG DIRECTORY}  ${bip_log}=${False}    ${reboot_ue}=${False}
    ...    ${scf_path}=${Case_SCF_Path}  ${direction}=BOTH  ${attach_cell_id}=${None}    ${gnb_index}=${0}
    log to console    \nUe Attach and Start DL UL Traffic
    ${ue_number}  get length  ${ue_index_list}
    ${ue_and_cell}    create dictionary
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword if   ${bip_log}   run keyword and ignore error   Start BIP Logs Capture
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}   ui_version=${ui_version}
        Run Keyword If    '${ue_type}'=='nokia_fastmile'    Modify UE Capatibility to Given Params
        ...    ue_index=${ue_index}    mobile_network_system=NR    scf_path=${scf_path}
        ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}    mobile_network_system=NR
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${reboot_ue}    pci=${pci}
    	run keyword if   ${bip_log}   run keyword and ignore error   Stop BIP Logs Capture And DownLoad Logs   bip_log_path=${bip_log_path}
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
        ${attach_cell_id}    get_ue_attached_cell_id_by_pci    pci=${pci}    connection=${connection}
        ${4G_check_input}    set variable    ${4G_check}
        ${4G_check}    run keyword if    '${ue_type}'=='mtk'    set variable    ${4G_check}    ELSE    set variable    ${False}
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
        ${4G_check}    set variable    ${4G_check_input}
        ${cell_id}    Run Keyword If    '${attach_cell_id}'=='${None}'
        ...    Get Cell ID from Aasyslog    alias=${alias}    connection=${connection}    ue_index=${ue_index}
        ...    ELSE    Set Variable    ${attach_cell_id}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
        ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
        ${ul_iperf_process}    Get Ul Iperf Process    scf_name=${scf_name}    ue_index=${ue_index}
        ${dl_iperf_process}    Get Dl Iperf Process    scf_name=${scf_name}    ue_index=${ue_index}
        ${ul_tp_per_process}    Calculate Send Tput with Process    tput=${ul_tp}    iperf_process=${ul_iperf_process}
        ${dl_tp_per_process}    Calculate Send Tput with Process    tput=${dl_tp}    iperf_process=${dl_iperf_process}
        Run Keyword If  ${direction_dl}  power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_per_process}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${dl_iperf_process}
        ...    ELSE IF  ${direction_ul}  power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_per_process}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
        ...    process_num=${ul_iperf_process}
        ...    ELSE  Run Keywords
        ...    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_per_process}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${dl_iperf_process}  AND
        ...    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_per_process}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
        ...    process_num=${ul_iperf_process}
    END
    [Return]  ${ue_and_cell}

Calculate Send Tput with Process
    [Arguments]  ${tput}    ${iperf_process}
    ${tp_value}    Get Regexp Matches     ${tput}    \\d+\.?\\d+
    ${tp_value}    set variable    ${tp_value[0]}
    ${tp_unit}    Remove String    ${tput}    ${tp_value}
    ${tp_value}    evaluate    float(${tp_value})/${iperf_process}
    ${tp}    catenate    SEPARATOR=    ${tp_value}    ${tp_unit}
    [Return]  ${tp}

Get Cell ID from Aasyslog
    [Arguments]  ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${ue_index}=${0}
    Connect to Common Unit Master  alias=${alias}
    connect to gnb coam via ssl    connection=${connection}
    ${time}  get time  epoch
    ${attach_log}    set variable    /tmp/5Grach.txt
    ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
    run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
    ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
    ...    alias=${alias}    connection=${connection}
    run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
    [Return]  ${cell_id}

UE Verify Peak Throughput
    [Documentation]  ue_and_cell:{'0': '1', '1' : '2'}
    [Arguments]  ${ue_index_list}  ${ue_and_cell}  ${dl_exp}=300  ${ul_exp}=100  ${interval}=10s  ${duration}=${600}
    ...    ${actual_rate}=0.1      ${du_index}=0    ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    ...    ${cell_and_peak_info}=${None}    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${scf_path}=${Case_SCF_Path}   ${direction}=BOTH     ${gnb_index}=${0}
    ${unused_arguments_list}    Create List    interval=${interval}    actual_rate=${actual_rate}
    ...    du_index=${du_index}   is_need_to_capture_log=${is_need_to_capture_log}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    log to console    \nUE Verify Peak Throughput
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    upload_duration=${upload_duration}
    ...    check_source=Aasyslog    gnb_index=${gnb_index}
    ${path}    ${scf_name}    split path    path=${scf_path}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${testline_name}    Get Testline Name
        ${peak_percent}    get_ue_peak_percent_from_ue_mapping_file    testline_name=${testline_name}    ue_index=${ue_index}
        ...    scf_name=${scf_name}
        run keyword if    ${peak_percent}!=1
        ...    log to console    \nupdate target_avg_percent and min_expect_rate to value multiply by ${peak_percent}
        ${cell_id}    get from dictionary    ${ue_and_cell}    ${ue_index}
        ${dl_exp}  ${ul_exp}  ${avg_expect_rate}  ${min_expect_rate}  ${duration}    get_verify_traffic_information  cell_id=${cell_id}
        ...    dl_exp=${dl_exp}  ul_exp=${ul_exp}   duration=${duration}    avg_expect_rate=${target_avg_percent}
        ...    min_expect_rate=${min_percent}    cell_and_peak_info=${cell_and_peak_info}
        ${avg_expect_rate}    evaluate    ${avg_expect_rate}*${peak_percent}
        ${min_expect_rate}    evaluate    ${min_expect_rate}*${peak_percent}
        TRY
            ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    gnb_index=${gnb_index}
        ...    connection_alias=${gnb_ssl_connection}
        EXCEPT
            ${cell_mapping}    Get Mapping Between Cell Index And NrCellIdentity Via WebEM    cell_id=${cell_id}   gnb_index=${gnb_index}
        END
        ${nrCellIdentity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
        ${cells}    Create List    ${nrCellIdentity}
        ${tput_exp}    Set Variable If    ${direction_dl}    ${dl_exp}    ${ul_exp}
        ${all_tput}   Run Keyword If  ${direction_dl} or ${direction_ul}  power_ue.Check Tput  ue_type=nokia_fastmile  direction=${direction}
        ...    target_throughput=${tput_exp}    log=${log_path}  cells=${cells}  target_avg_percent=${avg_expect_rate}
        ...     min_percent=${min_expect_rate}  check_source=Aasyslog   ue_index=${ue_index}  upload_tp=${upload_tp}
        ...    ELSE   power_ue.Check Bi Tput   ue_type=nokia_fastmile    cells=${cells}    ultarget_throughput=${ul_exp}
        ...    dltarget_throughput=${dl_exp}    target_avg_percent=${avg_expect_rate}    min_percent=${min_expect_rate}    upload_tp=${upload_tp}
        ...    ue_index=${ue_index}    log=${log_path}
    END
    [Return]  ${all_tput}

Ue Stop DL UL Traffic and Detach
    [Arguments]  ${ue_index_list}    ${iperf_type}=via_command    ${protocol}=udp    ${reboot_ue}=${False}    ${reboot_limit_time}=${1}
    ...  ${direction}=BOTH
    log to console    \nUe Stop DL UL Traffic and Detach
    ${direction_dl}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   DL   ignore_case=${True}
    ${direction_ul}   Run Keyword And Return Status   Should Be Equal As Strings   ${direction}   UL   ignore_case=${True}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Run Keyword If  ${direction_dl}
        ...    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}
        ...    ELSE IF  ${direction_ul}   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}
        ...    direction=ul    ue_index=${ue_index}  iperf_type=${iperf_type}    protocol=${protocol}
        ...   ELSE  Run Keywords
        ...   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}  AND
        ...   run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        ...    iperf_type=${iperf_type}    protocol=${protocol}
        ${reboot_ue_flag}    ${reboot_time}    Get Ue Reboot Flag    ue_index=${ue_index}    reboot_ue=${reboot_ue}
        ...    reboot_limit_time=${reboot_limit_time}
        ${status}    run keyword and return status    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
        ...    power_reset=${reboot_ue_flag}
        ${reboot_time}   run keyword if    ${reboot_ue_flag} and ${status}    evaluate    ${reboot_time}+${1}
        ...    ELSE    set variable    ${reboot_time}
        set to dictionary    ${ue_reboot_dict}    UE_${ue_index}=${reboot_time}
    END

Get Ue Reboot Flag
    [Arguments]  ${ue_index}=${0}    ${reboot_ue}=${False}    ${reboot_limit_time}=${1}
    ${status}    run keyword and return status    variable should exist   ${ue_reboot_dict}
    return from keyword if    '${status}'=='FAIL'    ${reboot_ue}
    ${status}    ${value}    run keyword and ignore error    get from dictionary    ${ue_reboot_dict}    UE_${ue_index}
    ${reboot_time}    set variable if    '${status}'=='FAIL'    ${0}    ${value}
    ${reboot_ue_flag}    set variable if   ${reboot_time}<${reboot_limit_time} and ${reboot_ue}    ${True}    ${False}
    [Return]  ${reboot_ue_flag}    ${reboot_time}

Get Iperf Type
    [Arguments]    ${iperf_type}=via_command    ${protocol}=udp    ${scf_name}=${None}
    Return From Keyword If    '${iperf_type}'!='${None}'    ${iperf_type}
    ${testline_name}    Get Testline Name
    ${iperf_type}    get_iperf_type_from_ue_mapping_file    testline_name=${testline_name}    iperf_type=${iperf_type}
    ...    scf_name=${scf_name}
    Return From Keyword If    '${iperf_type}'!='${None}'    ${iperf_type}
    ${iperf_type}    set variable if    '${protocol}'=='udp'    via_app    via_command
    [Return]    ${iperf_type}

Get UE UI Version
    [Arguments]    ${scf_name}=${None}
    ${testline_name}    Get Testline Name
    ${ui_version}    get_ui_version_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}
    [Return]    ${ui_version}

Get Ul Iperf Process
    [Arguments]    ${scf_name}=${None}    ${ue_index}=${0}
    ${testline_name}    Get Testline Name
    ${ul_iperf_process}    get_ul_iperf_process_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}    ue_index=${ue_index}
    [Return]    ${ul_iperf_process}

Get Dl Iperf Process
    [Arguments]    ${scf_name}=${None}    ${ue_index}=${0}
    ${testline_name}    Get Testline Name
    ${dl_iperf_process}    get_dl_iperf_process_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}    ue_index=${ue_index}
    [Return]    ${dl_iperf_process}

Get Ues Attached Cell
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]
    ...    ${ue_num_each_call}=2
    ...    ${connection}=GNB_OAM
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_id_list}    create list    ${cell_id}
        ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_id_list}    ue_num_each_call=${ue_num_each_call}
        ${len}    run keyword if    '${ue_index_list}'!='${None}'    get length    ${ue_index_list}
        ...    ELSE    set variable    ${0}
        return from keyword if    '${len}'=='${ue_num_each_call}'    ${cell_id}
    END
    should be true    '${len}'=='${ue_num_each_call}'    msg=get ${ue_num_each_call} ues attached cell failed!!!

UE Attach And Detach
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]    run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Teardown UEs
    [Arguments]    ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        ul_power_ue.teardown ue    ue=UE_${ue_index}
    END
