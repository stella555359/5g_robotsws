*** Settings ***
Documentation    The keyword for checking if there is hanging resource or not on gnb
...              Author: Liu Tingting
...              Contact: tingting.1.liu@nokia-sbell.com
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Tool/hanging_resource_lib.py


*** Keywords ***
Check site hanging resource
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ...    Description: check if there is hanging resource or not on gnb
    ...    para server_ip: iperf server ip
    ...    para server_name: iperf server username
    ...    para server_pwd: iperf server password
    ...    para pc_ip: control pc ip
    ...    para pc_name: control pc username
    ...    para pc_pwd: control pc password
    ...    gnb_ip: gnb_ip(type is list) '@{gnb_ips}'
    ...    ue_index: ue id
    ...    ute_log_path: log path on ute
    [Arguments]    ${gnb_ips}    ${ue_index}=${0}    ${server_ip}=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    ${server_name}=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    ${server_pwd}=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    ${pc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${pc_name}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${pc_pwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${ute_log_path}=${TS_CASE_LOG_PATH}    ${timeout}=300
    Change cellBarred Parameter Value On Gnb    pcell_index=all   exp_status=barred
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Wait Until Keyword Succeeds    3x    10s
    ...    download_file_from_server_to_ute    server_ip=${server_ip}    server_name=${server_name}    server_pwd=${server_pwd}
    Wait Until Keyword Succeeds    3x    10s
	...    upload_file_to_ue_pc    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}
    execute_hanging_resource_file_on_ue_pc    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}    gnb_ip=${gnb_ips}
    [Teardown]    Wait Until Keyword Succeeds    3x    10s
    ...    save_hang_resource_result_to_ute    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}    ute_log_path=${ute_log_path}
    ...    timeout=${timeout}