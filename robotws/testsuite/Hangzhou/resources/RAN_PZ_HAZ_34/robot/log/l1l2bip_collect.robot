*** Settings ***
Documentation    This is common keywords for l1l2bip via interface mirroring.
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6
Library    Collections
Library    OperatingSystem
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core       WITH NAME    core


*** Keywords ***
Collect Interface Mirroring Bip Collector
    [Documentation]    jun.8.chen@nokia-sbell.com
    ...                :param target_file_name: (str) – name of collector
    ...                :param interface: (str) – L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str) – Local or Remote
    ...                :param webservice: (dict) – Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,) – (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51, (Select max 8 cells), if nr_phy_cell_ids set as "None", means collect the logs of all cells.
    ...                :param mirroring_filter (str) – Optional, [“Default” | “AllMessages” | “SpecificL1L2Messages”]. Only supported when
    ...                                             interface is ‘L1-L2’ and destination is ‘Local’. Only available from SBTS24R1 onwards.
    ...                :param specific_message_ids (str) – Optional, only supported when mirroring_filter is ‘SpecificL1L2Messages’.
    ...                                             string using comma separate. Must be in hex format. e.g : ‘0xE3F3,0x0A00’
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    ...            ${gnb_index}=0
    ...            ${timeout}=600
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${mirroring_filter}=${None}
    ...            ${specific_message_ids}=${None}
    ${webservice}=  Create Dictionary    host=${host_ip}
    ...                                  user=${username}
    ...                                  password=${password}
    ...                                  port=443
    run keyword if     '${mirroring_filter}'=='${None}'
    ...                 l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                                         webservice=${webservice}
    ...                                                                         interface=${interface}
    ...                                                                         destination=${destination}
    ...                                                                         nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                                         target_file_name=${target_file_name}
    ...                                                                         timeout=${timeout}
    ...         ELSE    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                                         webservice=${webservice}
    ...                                                                         interface=${interface}
    ...                                                                         destination=${destination}
    ...                                                                         nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                                         target_file_name=${target_file_name}
    ...                                                                         timeout=${timeout}
    ...                                                                         mirroring_filter=${mirroring_filter}
    ...                                                                         specific_message_ids=${specific_message_ids}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    l1l2bip.set_suite_alias    ${target_file_name}

Get Bip Log Via Interface Mirroring Collector
    [Documentation]    jun.8.chen@nokia-sbell.com
    ...                keyword is used to collect the log files to default path
    ...                journey.jin@nokia-sbell.com update:
    ...                if ${is_return_original_file}=${False},will return one merged bip log,
    ...                if ${is_return_original_file}=${True},will return original collected bip logs
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}    ${is_return_original_file}=${False}
    core.stop_collectors        names=${target_file_name}
    core.collect_collectors   names=${target_file_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${target_file_name}
    @{log_file}   List Files In Directory    path=${target_dir}${/}${target_file_name}    pattern=${pattern}
    Sort List    ${log_file}
    ${log_path_list}    Run Keyword If    '${is_return_original_file}'=='${True}'    Get original bip log path
    ...    log_file=${log_file}    target_file_name=${target_file_name}
    Return From Keyword if    '${is_return_original_file}'=='${True}'    ${log_path_list}
    FOR  ${log}  IN  @{log_file}
        ${index}    Get Index From List    ${log_file}    ${log}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};touch test_${index}.pcap
        OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${log}
    END
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};rm test*.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${/}${target_file_name};rm BTS*.pcap
    ${full_log_path}    Create List    ${target_dir}${/}${target_file_name}${/}${target_file_name}.pcap
    [Return]    ${full_log_path}
    [Teardown]    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

Stop Bip Log Via Interface Mirroring Collector
    [Documentation]    jun.8.chen@nokia-sbell.com
    ...                keyword is used to stop collect bip log
    [Arguments]      ${target_file_name}=l1l2bip_log
    core.stop_collectors        names=${target_file_name}
    core.teardown_collectors    names=${target_file_name}

Get original bip log path
    [Documentation]    journey.jin@nokia-sbell.com
    ...                keyword is used to get the original bip with the log path
    [Arguments]    ${target_file_name}=l1l2bip_log    ${target_dir}=${TS_CASE_LOG_PATH}    ${log_file}=${log_file}
    ${log_path_list}    Create List
    FOR    ${i}    IN RANGE    len(${log_file})
        Append to List  ${log_path_list}    ${target_dir}${/}${target_file_name}${/}${log_file[${i}]}
    END
    [Return]    ${log_path_list}
