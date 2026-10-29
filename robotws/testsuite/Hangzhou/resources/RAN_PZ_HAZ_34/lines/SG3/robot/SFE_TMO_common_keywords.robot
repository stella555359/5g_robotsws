*** Settings ***
Documentation
...    SFE common keywords
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/SFE_TMO_HO_common_keywords.py
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    OperatingSystem

*** Variables ***
${WEBUI_URL}    https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${bts_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${bts_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}


*** Keywords ***
Get record time
    [Arguments]    ${label}=start
    ${record_time}=    record_time    label=${label}
    Run Keyword If    '${label}'=='start'
    ...    Set Suite Variable    ${start_time}    ${record_time}
    ...    ELSE IF    '${label}'=='end'
    ...    Set Suite Variable    ${end_time}    ${record_time}

python handle get record time formate for excel name
    [Arguments]    ${label}=start
    ${test_time}=    python_handle_string     start_time=${start_time}
    Run Keyword If    '${label}'=='start'
    ...    Set Suite Variable    ${formatted_time}    ${test_time}

generate new report and get report id
    [Arguments]
    ...    ${file_path}
    ...    ${report_name}
    ...    ${tl_id}
    ...    ${package_version}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${comments}=${EMPTY}
    ...    ${check_out_entry}=false
    ...    ${gnb_index}=${0}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    Get bts package version    gnb_index=${gnb_index}    host=${host}    username=${username}    password=${password}
    ${report_id}    generate_new_report_on_compass
    ...    file_path=${file_path}
    ...    report_name=${report_name}
    ...    tl_id=${tl_id}
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    comments=${comments}
    ...    check_out_entry=${check_out_entry}
    Set Suite Variable    ${report_id}

Get bts package version
    [Arguments]
    ...    ${gnb_index}=${0}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=version_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=version_info
    ${package_version}     set variable    ${info.split('_', 1)[1].split('.')[0]}
    Set Suite Variable    ${package_version}
    [Teardown]   csn.Disconnect   connection=version_info

Download exe file to ute
    [Arguments]
    ...    ${ute_file_path}
    ...    ${server_file_path}=/home/vrf4_sg3/
    ...    ${filename}=crawling_and_download_kpi_data.exe
    ...    ${server_ip}=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    ${server_name}=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    ${server_pwd}=${tl.appserver.iperf_details.ssh_connection_details.password}
    wait until keyword succeeds    1min   10s
    ...    csn.Connect To   hostname=${server_ip}   username=${server_name}   password=${server_pwd}   alias=server
    csn.download_file   remote_path=${server_file_path}${filename}   local_path=${ute_file_path}${filename}   connection=server
    sleep    3
    ${Rc}    ${output}=    Run And Return Rc And Output    ls -l ${ute_file_path}${filename}
    Should Contain    ${output}    ${filename}
    [Teardown]    csn.disconnect    connection=server

Crawling and download kpi data
    [Arguments]    ${file_path}    ${report_id}    ${file_name}    ${tl_id}
    Download exe file to ute    ute_file_path=${file_path}
    ${Rc}=    Run And Return Rc    command=chmod +x ${file_path}/crawling_and_download_kpi_data.exe
    ${Rc}    ${output}=    Run And Return Rc And Output
    ...    command=wine ${file_path}/crawling_and_download_kpi_data.exe ${report_id} ${file_path} ${file_name} ${tl_id}
    Should Be Equal As Numbers    ${Rc}    0
    Should Contain    ${output}    Data has been written to excel file

Get gnb version for SBTS
    [Arguments]   ${host}=${bts_addr}   ${username}=${bts_username}   ${password}=${bts_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info

start L2 trace collect
    [Documentation]
    ...    ${source_ip}: 10.57.131.118
    ...    ${dscp}: 15
    ...    ${uplane_destination}: 10.57.150.175:55900
    ...    ${cells_list}: ['[PCI: 400][400]NRCELL-400', '[PCI: 644][644]NRCELL-644']
    [Arguments]
    ...    ${source_ip}
    ...    ${dscp}
    ...    ${uplane_destination}
    ...    ${cells_list}
    ...    ${timeout}=${60}
    ${sw_version}=    Get gnb version for SBTS
    selenium_sbts.Login    url=${WEBUI_URL}    username=${WEBUI_NAME}   password=${WEBUI_PWD}    version=${sw_version}
    selenium_sbts.deactivate_internal_trace    timeout=${timeout}
    selenium_sbts.configure_logging_agent     source_ip=${source_ip}    dscp=${dscp}    uplane_destination=${uplane_destination}
	...    timeout=${timeout}
    selenium_sbts.activate_internal_trace     timeout=${timeout}
    selenium_sbts.start_l2_ps_component_trace_and_return_result     cells_list=${cells_list}    timeout=${timeout}
    [Teardown]    selenium_sbts.Logout

stop L2 trace collect
    [Arguments]    ${uplane_component_name}
    ${sw_version}=    Get gnb version for SBTS
    selenium_sbts.Login    url=${WEBUI_URL}    username=${WEBUI_NAME}   password=${WEBUI_PWD}    version=${sw_version}
    selenium_sbts.stop_component_trace    uplane_component_name=${uplane_component_name}
    [Teardown]    selenium_sbts.Logout

get info
    [Arguments]    ${file_path}
    ${data}=    get_required_info    file_path=${file_path}
    Set Suite Variable    ${data}
    Set Suite Variable    ${source_ip}    ${data}[internal_trace][Source_IP]
    Set Suite Variable    ${dscp}    ${data}[internal_trace][dscp]
    Set Suite Variable    ${uplane_destination}    ${data}[internal_trace][uplane_destination]
    Set Suite Variable    ${cells_list}    ${data}[UPlane_Component][L2-PS][Cells]
    Set Suite Variable    ${uplane_component_name}    ${data}[uplane_component_name]
