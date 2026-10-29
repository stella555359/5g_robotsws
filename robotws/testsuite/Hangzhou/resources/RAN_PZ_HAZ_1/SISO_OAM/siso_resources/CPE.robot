*** Settings ***
Documentation
...    Author:        qiang.1.zhou@nokia.com
...    Maintainer:    qiang.1.zhou@nokia.com

#Library    ../../../../../../resources/sites/Hangzhou/KISS/python/ta_kiss_files/ta_kiss_files/
Library    ./SISO_CPE.py
Library    ./utils/route.py
Library    ./utils/others.py
Library    ./utils/data_analysis.py
Resource    ./utils/siso_data.robot
#Library    siso_lib/siso_data.py


*** Variables ***
${iperf_server_ip}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${iperf_server_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${iperf_server_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${iperf_server_network_interface}    ${tl.appserver.iperf_details.network_interface_address}
${appserver_log_path}    /home/tdlte-tester/UDP
${ctrl_pc_addr}     ${tl.test_pc.default_ssh_connection_details.addr}
${ctrl_pc_username}   ${tl.test_pc.default_ssh_connection_details.username}

*** Keywords ***
Attach With CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${earfcn}    ${DMZ}=yes
    [Documentation]    Attach with cpe
    #${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}
    ${ip}    Set Variable    ${MATCHED_UE_INFO['IP']}
    ${CPE_type}    Set Variable    ${MATCHED_UE_INFO["MODEL"]}
    ${CPE_LAN_IP}    Set Variable    ${MATCHED_UE_INFO['LAN_IP']}
    ${ue_ip}    CPE Attach    ${bts_id}    ${cell_ids}   ${earfcn}    ${ip}
    ...     ${CPE_LAN_IP}    ${CPE_type}    DMZ=${DMZ}
    [Return]    ${ue_ip}

Release All CPEs
    [Documentation]    Release all CPE
    Release All CPE
#    ${MATCHED_UE_INFO}    Set Variable      ${tl.MATCHED_UE_INFO}
#
#    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}

Run Tput without DMZ
    [Arguments]    ${ip}      ${CPE_type}    ${bts_id}    ${cell_id}    ${ue_ip}
    ...            ${ul}    ${dl}    ${calibration}=no
    [Documentation]    Run udp for ul and dl
    #${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL
    ${timestamp}=    Get Timestamp

    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${cell_id}_udp_ul_${timestamp}.log
    ${local_UL_log_path}    Set Variable   ${appserver_log_path}${/}${cell_id}_udp_ul_${timestamp}.log
    ${DL_log_path}    Set Variable  ${test_logs_dir_path}${/}${cell_id}_udp_dl_${timestamp}.log

    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    #Add route
    Del All Route    ${iperf_server_network_interface}
    Add Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    ${send_ul}    evaluate     int(${ul})+5
    ${send_dl}    evaluate     int(${dl})+10
    siso_data.Start UDP Iperf Client    ${bts_pc_info}    ${iperf_server_network_interface}    ${UL_port}
    ...                                   band_width=${send_ul}M     bind_host=${MATCHED_UE_INFO["LAN_IP"]}
    ...                                   ttl=64     duration=120    alias=ul_client
    siso_data.Start UDP Iperf Client    ${iperf_pc_info}    ${ue_ip}    ${DL_port}
    ...                                    band_width=${send_dl}M     bind_host=${iperf_server_network_interface}
    ...                                    ttl=64     duration=3600    alias=dl_client
#    Sleep    20s
#    siso_data.Stop Iperf Server    ${UL_port}    alias=ul_server
    Sleep    5s
    ${UL_tput}    ${DL_tput}    get_tput_from_web_page    ip=${ip}     bts_id=${bts_id}    cell_id=${cell_id}    during=20
    ...                                               cpe_type=${CPE_type}
#    ${temp}    ${DL_tput}    get_tput_from_web_page    ip=${ip}     bts_id=${bts_id}    cell_id=${cell_id}    during=20
#    ...                                               cpe_type=${CPE_type}
#
#    Sftp Download    ${iperf_server_info["CTRL_IP"]}    ${iperf_server_info["PORT"]}
#    ...              ${iperf_server_info["USERNAME"]}    ${iperf_server_info["PASSWORD"]}
#    ...              ${UL_log_path}    ${local_UL_log_path}
#    Remote Execute Cmd    ${iperf_pc_info}    rm -rf ${UL_log_path}

    #${UL_tput}=    siso_data.Get Iperf Throughput    ${local_UL_log_path}
    Log    ${UL_tput}
    Log    ${DL_tput}

    #Sleep    20s
    #siso_data.Stop Iperf Server      ${DL_port}    alias=dl_server


    #${DL_tput}=    siso_data.Get Iperf Throughput    ${DL_log_path}
    #Log    ${DL_tput}
    siso_data.Stop Iperf Client    ${bts_pc_info}    ${UL_port}    alias=ul_client
    Run Keyword If    '${calibration}'=='yes'     log many    Automated SiSo Calibration
    ...     ELSE     Sleep    5s
    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${DL_port}    alias=dl_client
    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    #Delete route
    #Fetch log
    [Return]    ${UL_tput}    ${DL_tput}
    [Teardown]    Run Keywords
    ...    siso_data.Teardown Iperf    ${bts_pc_info}    port=${UL_port}    alias=ul_client    AND
    ...    siso_data.Teardown Iperf    ${iperf_pc_info}   port=${UL_port}    alias=ul_server    AND
    #...    siso_data.teardown    alias=dl_server     port=${DL_port}    AND
    ...    siso_data.Teardown Iperf    ${iperf_pc_info}     port=${DL_port}    alias=dl_client


Run Tput
    [Arguments]    ${cell_id}    ${ue_ip}    ${ul}    ${dl}        ${calibration}=no
    [Documentation]    Run udp for ul and dl
    ${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}

    ${dl_port}    others.Get Udp Port     DL
    ${ul_port}    others.Get Udp Port     UL
    ${timestamp}=    Get Timestamp

    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${cell_id}_udp_ul_${timestamp}.log
    ${local_UL_log_path}    Set Variable    ${test_logs_dir_path}${/}${cell_id}_udp_ul_${timestamp}.log
    ${DL_log_path}    Set Variable  ${test_logs_dir_path}${/}${cell_id}_udp_dl_${timestamp}.log

    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    #Add route
    Del All Route    ${iperf_server_network_interface}
    Add Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    ${send_ul}    evaluate     int(${ul})+5
    ${send_dl}    evaluate     int(${dl})+10
    siso_data.Start UDP Iperf Client    ${bts_pc_info}    ${iperf_server_network_interface}    ${UL_port}
    ...                                 band_width=${send_ul}M     bind_host=${MATCHED_UE_INFO["LAN_IP"]}
    ...                                 ttl=64   duration=120    alias=ul_client
    siso_data.Start UDP Iperf Server    ${iperf_pc_info}    ${UL_port}    ${UL_log_path}
    ...                                 ${iperf_server_network_interface}
    ...                                 buffer_size=82.0K    alias=ul_server
    Sleep    20s
    siso_data.Stop Iperf Server    ${iperf_pc_info}    ${UL_port}    alias=ul_server
    siso_data.Stop Iperf Client    ${bts_pc_info}    ${UL_port}    alias=ul_client

    Sftp Download    ${iperf_server_ip}    22
    ...              ${iperf_server_username}    ${iperf_server_password}
    ...              ${UL_log_path}    ${local_UL_log_path}
    Remote Execute Cmd    ${iperf_pc_info}    rm -rf ${UL_log_path}

    ${UL_tput}=    Get Iperf Throughput    ${local_UL_log_path}
    Log    ${UL_tput}

    siso_data.Start UDP Iperf Client    ${iperf_pc_info}    ${ue_ip}    ${DL_port}
    ...                                 band_width=${send_dl}M     bind_host=${iperf_server_network_interface}
    ...                                 ttl=64    duration=3600    alias=dl_client
    siso_data.Start UDP Iperf Server    ${bts_pc_info}    ${DL_port}    ${DL_log_path}
    ...                                 buffer_size=82.0K     bind_host=${MATCHED_UE_INFO["LAN_IP"]}    alias=dl_server

    Run Keyword If    '${calibration}'=='yes'     log many    Automated SiSo Calibration
    ...     ELSE     Sleep    20s
    siso_data.Stop Iperf Server    ${bts_pc_info}    ${DL_port}    alias=dl_server
    siso_data.Stop Iperf Client    ${iperf_pc_info}     ${DL_port}    alias=dl_client

    ${DL_tput}=    Get Iperf Throughput    ${DL_log_path}
    Log    ${DL_tput}
    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}

    #Delete route
    #Fetch log
    [Return]    ${UL_tput}    ${DL_tput}
    [Teardown]    Run Keywords
    ...    siso_data.Teardown Iperf    ${bts_pc_info}    port=${UL_port}    alias=ul_client    AND
    ...    siso_data.Teardown Iperf    ${iperf_pc_info}   port=${UL_port}    alias=ul_server    AND
    ...    siso_data.Teardown Iperf    ${bts_pc_info}     port=${DL_port}    alias=dl_server    AND
    ...    siso_data.Teardown Iperf    ${iperf_pc_info}   port=${DL_port}    alias=dl_client

Run Ping
    [Arguments]    ${cell_id}    ${ue_ip}
    [Documentation]    Run udp for ul and dl
    #${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}

    ${timestamp}=    Get Timestamp

    ${local_DL_log_path}    Set Variable  ${appserver_log_path}${/}${cell_id}_ping_dl_${timestamp}.log
    ${DL_log_path}    Set Variable    ${test_logs_dir_path}${/}${cell_id}_ping_dl_${timestamp}.log
    ${UL_log_path}    Set Variable  ${test_logs_dir_path}${/}${cell_id}_ping_ul_${timestamp}.log

    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    #Add route
    Del All Route    ${iperf_server_network_interface}
    Add Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}

    siso_data.Start Ping   ${bts_pc_info}    ip=${iperf_server_network_interface}
    ...                    logfile=${UL_log_path}   alias=ul_client
    Sleep    20s
    siso_data.Stop Ping    ${bts_pc_info}    ip=${iperf_server_network_interface}         alias=ul_client


    ${UL_ping_summary_result}=    Get Ping Summary Data    log_path=${UL_log_path}
    Log    ${UL_ping_summary_result}


    siso_data.Start Ping   ${iperf_pc_info}    ip=${ue_ip}     logfile=${local_DL_log_path}     alias=dl_client
    Sleep    20s
    siso_data.Stop Ping     ${iperf_pc_info}    ip=${ue_ip}         alias=dl_client


    Sftp Download    ${iperf_server_ip}    22
    ...              ${iperf_server_username}    ${iperf_server_password}
    ...              ${local_DL_log_path}    ${DL_log_path}
    Remote Execute Cmd    ${iperf_pc_info}    rm -rf ${local_DL_log_path}


    ${DL_ping_summary_result}=    Get Ping Summary Data    log_path=${DL_log_path}
    Log    ${DL_ping_summary_result}

    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    #Delete route
    #Fetch log
    #[Teardown]    Run Keywords     Log    helloword
    [Return]    ${UL_ping_summary_result}    ${DL_ping_summary_result}
    [Teardown]    Run Keywords
    ...    siso_data.Stop Ping     ${bts_pc_info}   ip=${iperf_server_network_interface}   alias=ul_client    AND
    ...    siso_data.Stop Ping     ${iperf_pc_info}    ip=${ue_ip}     alias=dl_client


Basic Call With CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${earfcn}
    [Documentation]    make l3call with CPE

    ${DMZ}     Is Set DMZ
    ${out_ue_ip}    Attach With CPE    ${bts_id}    ${cell_ids}   ${earfcn}    DMZ=${DMZ}

    [Return]    ${out_ue_ip}

L3call With CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${earfcn}
    [Documentation]    attach and run tput
    ${DMZ}     Is Set DMZ
    ${out_ue_ip}    Attach With CPE    ${bts_id}    ${cell_ids}   ${earfcn}    DMZ=${DMZ}
    ${out_ul_ping_result}    ${out_dl_ping_result}    Run Ping       ${cell_ids}    ${out_ue_ip}
    check_ping_result     ${out_ul_ping_result}
    check_ping_result     ${out_dl_ping_result}

#    ${out_UL_tput}    ${out_DL_tput}    Run Tput    ${cell_ids}    ${out_ue_ip}    ${ul}   ${dl}
#
#
#    SISO_CPE.Check Tput    ${out_UL_tput}    ${out_DL_tput}   ${ul}    ${dl}    ${MATCHED_UE_INFO["MODEL"]}
    [Return]    ${out_ul_ping_result}    ${out_dl_ping_result}

Is Set DMZ
    #${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}
    ${has_DMZ}     Run Keyword And Return Status     Dictionary Should Contain Key    ${MATCHED_UE_INFO}     DMZ

    ${DMZ}     Set Variable If     ${has_DMZ}     ${MATCHED_UE_INFO['DMZ']}    yes
    [Return]    ${DMZ}

Test Tput With CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${earfcn}    ${ul}    ${dl}
    ...          ${calibration}=no
    [Documentation]    attach and run tput
    ${DMZ}     Is Set DMZ

    ${out_ue_ip}    Attach With CPE    ${bts_id}    ${cell_ids}   ${earfcn}    DMZ=${DMZ}
    FOR    ${index}    IN RANGE    3
        ${out_UL_tput}    ${out_DL_tput}    Run Keyword If      '${DMZ}'=='yes'
        ...     Run Tput    ${cell_ids}    ${out_ue_ip}    ${ul}   ${dl}        ${calibration}
        ...     ELSE      Run Tput without DMZ      ${MATCHED_UE_INFO["IP"]}      ${MATCHED_UE_INFO["MODEL"]}
        ...     ${bts_id}    ${cell_ids}    ${out_ue_ip}    ${ul}    ${dl}    ${calibration}
        ${status}=    Run Keyword And Return Status
        ...     SISO_CPE.Check Tput    ${out_UL_tput}    ${out_DL_tput}   ${ul}    ${dl}    ${MATCHED_UE_INFO["MODEL"]}
        Run Keyword If    '${status}' == 'True'    exit for loop
    END
    Run Keyword If    '${status}'=='False'    Fail    SISO_CPE.Check Tput failed!!!
    [Return]    ${out_UL_tput}    ${out_DL_tput}

Run Dl Tput Strat
    [Arguments]    ${bts_id}    ${cell_id}    ${band}    ${technology}    ${earfcn}    ${dl}
    Get Matched Ue Info     ${band}    ${technology}    ${EMPTY}
    ${DMZ}     Is Set DMZ
    ${out_ue_ip}    Attach With CPE    ${bts_id}    ${cell_id}   ${earfcn}    DMZ=${DMZ}
    ${dl_port}    others.Get Udp Port     DL
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}   ${iperf_server_password}    22
    Del All Route    ${iperf_server_network_interface}
    Add Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    ${send_dl}    evaluate     int(${dl})+10
    siso_data.Start UDP Iperf Client    ${iperf_pc_info}    ${out_ue_ip}    ${dl_port}
    ...                                    band_width=${send_dl}M     bind_host=${iperf_server_network_interface}
    ...                                    ttl=64     duration=3600    alias=dl_client

Run Dl Tput Stop
    ${DL_port}=    others.Get UDP Port    DL
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}    ${iperf_server_password}    22
    Run Keyword And Continue On Failure    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${DL_port}
    ...    alias=dl_client
    Run Keyword And Continue On Failure    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    Run Keyword And Continue On Failure    siso_data.Teardown Iperf    ${iperf_pc_info}     port=${DL_port}
    ...    alias=dl_client

Attach With Nokia CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${band}    ${earfcn}    ${network_type}    ${DMZ}=yes
    [Documentation]    Attach with nokie cpe
    ${ip}    Set Variable    ${MATCHED_UE_INFO['IP']}
    ${CPE_type}    Set Variable    ${MATCHED_UE_INFO["MODEL"]}
    ${CPE_LAN_IP}    Set Variable    ${MATCHED_UE_INFO['LAN_IP']}
    ${cpe_root_password}    Set Variable    ${MATCHED_UE_INFO['ROOT_PASSWORD']}
    ${ue_ip}    Nokia CPE Attach    ${bts_id}    ${cell_ids}   ${band}    ${earfcn}    ${ip}
    ...     ${CPE_LAN_IP}    ${cpe_root_password}    ${network_type}    ${CPE_type}    DMZ=${DMZ}
    [Return]    ${ue_ip}

Basic Call With Nokia CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${band}    ${earfcn}    ${network_type}
    [Documentation]    make l3call with CPE

    ${DMZ}     Is Set DMZ
    ${out_ue_ip}    Attach With Nokia CPE    ${bts_id}    ${cell_ids}   ${band}    ${earfcn}    ${network_type}    DMZ=${DMZ}

    [Return]    ${out_ue_ip}

Test Tput With Nokia CPE
    [Arguments]    ${bts_id}    ${cell_ids}    ${earfcn}    ${band}    ${network_type}    ${ul}    ${dl}
    ...          ${calibration}=no
    [Documentation]    attach and run tput
    ${DMZ}     Is Set DMZ

    ${out_ue_ip}    Attach With Nokia CPE    ${bts_id}    ${cell_ids}   ${band}    ${earfcn}    ${network_type}    DMZ=${DMZ}
    FOR    ${index}    IN RANGE    3
        ${out_UL_tput}    ${out_DL_tput}    Run Keyword If      '${DMZ}'=='yes'
        ...     Run Tput    ${cell_ids}    ${out_ue_ip}    ${ul}   ${dl}        ${calibration}
        ...     ELSE      Run Tput without DMZ      ${MATCHED_UE_INFO["IP"]}      ${MATCHED_UE_INFO["MODEL"]}
        ...     ${bts_id}    ${cell_ids}    ${out_ue_ip}    ${ul}    ${dl}    ${calibration}
        ${status}=    Run Keyword And Return Status
        ...     SISO_CPE.Check Tput    ${out_UL_tput}    ${out_DL_tput}   ${ul}    ${dl}    ${MATCHED_UE_INFO["MODEL"]}
        Run Keyword If    '${status}' == 'True'    exit for loop
    END
    Run Keyword If    '${status}'=='False'    Fail    SISO_CPE.Check Tput failed!!!
    [Return]    ${out_UL_tput}    ${out_DL_tput}

Start Run DL Tput
    [Arguments]    ${cell_id}    ${ue_ip}    ${dl}    ${tag}    ${duration}=3600
    [Documentation]    Run udp for ul and dl
    ${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}

    ${dl_port}    others.Get Udp Port     DL

    ${DL_log_path}    Set Variable  ${test_logs_dir_path}${/}${cell_id}_udp_dl_${tag}.log

    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22
    #Add route
    Del All Route    ${iperf_server_network_interface}
    Add Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    ${send_dl}    evaluate     int(${dl})+10
    siso_data.Start UDP Iperf Client    ${iperf_pc_info}    ${ue_ip}    ${DL_port}
    ...                                 band_width=${send_dl}M     bind_host=${iperf_server_network_interface}
    ...                                 ttl=64    duration=${duration}    alias=dl_client
    siso_data.Start UDP Iperf Server    ${bts_pc_info}    ${DL_port}    ${DL_log_path}
    ...                                 buffer_size=82.0K     bind_host=${MATCHED_UE_INFO["LAN_IP"]}    alias=dl_server

Start Run UL Tput
    [Arguments]    ${cell_id}    ${ul}    ${tag}    ${duration}=120
    [Documentation]    Run udp for ul and dl
    ${MATCHED_UE_INFO}    Set Variable      ${matched_ue_info}

    ${ul_port}    others.Get Udp Port     UL
    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${cell_id}_udp_ul_${tag}.log

    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

    ${send_ul}    evaluate     int(${ul})+5
    siso_data.Start UDP Iperf Client    ${bts_pc_info}    ${iperf_server_network_interface}    ${UL_port}
    ...                                 band_width=${send_ul}M     bind_host=${MATCHED_UE_INFO["LAN_IP"]}
    ...                                 ttl=64   duration=${duration}    alias=ul_client
    siso_data.Start UDP Iperf Server    ${iperf_pc_info}    ${UL_port}    ${UL_log_path}
    ...                                 ${iperf_server_network_interface}
    ...                                 buffer_size=82.0K    alias=ul_server

Stop Run DL Tput
    ${DL_port}=    others.Get UDP Port    DL
    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}    ${iperf_server_password}    22
    Run Keyword And Continue On Failure    siso_data.Stop Iperf Server    ${bts_pc_info}    ${DL_port}    alias=dl_server
    Run Keyword And Continue On Failure    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${DL_port}
    ...    alias=dl_client
    Run Keyword And Continue On Failure    Del Route      ${iperf_server_network_interface}    ${MATCHED_UE_INFO['IP']}
    Run Keyword And Continue On Failure    siso_data.Teardown Iperf    ${bts_pc_info}     port=${DL_port}    alias=dl_server
    Run Keyword And Continue On Failure    siso_data.Teardown Iperf    ${iperf_pc_info}     port=${DL_port}
    ...    alias=dl_client

Stop Run UL Tput
    ${UL_port}=    others.Get UDP Port    UL
    ${bts_pc_info}=    Create List    ${ctrl_pc_addr}    ute    ute    22
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}    ${iperf_server_password}    22
    Run Keyword And Continue On Failure    siso_data.Stop Iperf Server    ${iperf_pc_info}    ${UL_port}    alias=ul_server
    Run Keyword And Continue On Failure    siso_data.Stop Iperf Client    ${bts_pc_info}    ${UL_port}    alias=ul_client
    Run Keyword And Continue On Failure    siso_data.Teardown Iperf    ${bts_pc_info}     port=${DL_port}    alias=dl_server
    Run Keyword And Continue On Failure    siso_data.Teardown Iperf    ${iperf_pc_info}     port=${DL_port}
    ...    alias=dl_client

Check Throughput
    [Arguments]    ${cell_id}    ${tag}    ${exp_dl_tput}    ${exp_ul_tput}    ${exp_min_ul}=1    ${exp_min_dl}=1
    ${UL_log_path}    Set Variable  ${appserver_log_path}${/}${cell_id}_udp_ul_${tag}.log
    ${local_UL_log_path}    Set Variable    ${test_logs_dir_path}${/}${cell_id}_udp_ul_${tag}.log
    ${DL_log_path}    Set Variable  ${test_logs_dir_path}${/}${cell_id}_udp_dl_${tag}.log
    Sftp Download    ${iperf_server_ip}    22
    ...              ${iperf_server_username}    ${iperf_server_password}
    ...              ${UL_log_path}    ${local_UL_log_path}

    ${ul_max_tput}    ${ul_min_tput}    ${UL_tput}    Get Iperf Throughput    ${local_UL_log_path}    allvalue=${True}
    Log    ${UL_tput}
    Log    ${ul_min_tput}
    ${dl_max_tput}    ${dl_min_tput}    ${DL_tput}=    Get Iperf Throughput    ${DL_log_path}    allvalue=${True}
    Log    ${DL_tput}
    Log    ${dl_min_tput}
    SISO_CPE.Check Tput    ${UL_tput}    ${DL_tput}   ${exp_ul_tput}    ${exp_dl_tput}    ${MATCHED_UE_INFO["MODEL"]}
    Should Be True    ${ul_min_tput} > ${exp_min_ul}
    Should Be True    ${dl_min_tput} > ${exp_min_dl}
