*** Settings ***
Library    DateTime
Library    Collections
Library    taf.ue.tm500.rci    WITH NAME    rci
Library    taf.transport.ssh   WITH NAME    ssh
Library    ./viavi_yaml.py

Resource   testsuite/Wroclaw/RRM/resources/connections.robot


*** Variables ***
${SCRIPT_DIR}             ${CURDIR}/tma_scripts
${CELL_SEARCH_5G}         FORW 0x00 Ok MTE NRSETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
&{IP dict}
# mapping of ue aliases to their physical IPs recived during attach.

*** Keywords ***
Attach UE
    [Documentation]   Attach UE to viavi using scripts provided in .yaml from testline configuration.
    [Arguments]  ${ue_alias}=UE_1
    ${attach_result}=  rci.Send Script     ${script_paths["${ue_alias}"]["attach"]}
    Should Contain     ${attach_result}    ${attach_validation_pattern}
    [Return]  ${attach_result}

Attach UE and get IP
    [Documentation]   Attach UE and extract its IP from output. Needed in order to run traffic.
    [Arguments]  ${ue_alias}=UE_1
    ${attach_result}=  Attach UE                           ue_alias=${ue_alias}
    ${IP}=             extract_ue_ip_from_attach_output    attach_result_output=${attach_result}
    Sleep    35s   reason=Waiting for PPU UEs session establishment
    Set to dictionary   ${IP dict}    ${ue_alias}    ${IP}
    [Return]  ${IP}

Detach UE
    [Documentation]   Detach UE using scripts from .yaml file.
    [Arguments]  ${ue_alias}=UE_1
    ${detach_result}=  rci.Send Script     ${script_paths["${ue_alias}"]["detach"]}
    Should Contain     ${detach_result}    ${detach_validation_pattern}
    [Return]  ${detach_result}

Create additional PDU session
    [Documentation]   Creates additional PDU session, giving additional IP addres for given UE. This IP can be used later in traffic.
    [Arguments]  ${ue_alias}=UE_1
    ${PDU_result}=  rci.Send Script    ${SCRIPT_DIR}/pdu_session.txt   # uses current ue context
    ${IP}=          extract_ue_ip_from_attach_output    attach_result_output=${PDU_result}
    [Return]  ${IP}

Disconnect from TMA
    [Documentation]   Disconnects from TMA. Needs to be ran at the end of every testcase that used `Connect to TMA` keyword.
    rci.Send Script    ${SCRIPT_DIR}/reset_and_disconnect.txt
    rci.Disconnect

Connect to TMA and initialise
    [Documentation]   Connects to TMA and initialises variables for later use. Nedds to be run before any attach.
    [Arguments]    ${ue_alias}=UE_1
    Run keyword and ignore error    Disconnect from TMA
    __set_synchronization
    __get_TM500 address
    __get_script paths
    __get_shared_variables_with_yaml_config   ${ue_alias}
    __connect_to_TMA
    ${cell_search_result}=    rci.Send Script          ${script_paths["${ue_alias}"]["rc_config"]}
    Should contain            ${cell_search_result}    ${CELL_SEARCH_5G}

Prepare for traffic
    [Documentation]   Sets needed routing for UEs on appserver for traffic.
    ${appserver_alias}=   Connect to Appserver
    ${ip_assignment}=     get_interfaces_from_ip_a_and_route    connection=${appserver_alias}
    Set suite variable    ${ip_assignment}

Start UL and DL traffic on UE list
    [Documentation]  Start traffic for all UEs on alias list.
    [Arguments]  ${ue_names}  ${ul_time}=${40}  ${dl_time}=${40}  ${ul_throughput}=20M  ${dl_throughput}=40M
    ${ips}=    __UE_list_to_ips    ${ue_names}
    Start UL and DL traffic on IP list    ${ips}  ${ul_time}  ${dl_time}  ${ul_throughput}  ${dl_throughput}

Start UL and DL traffic on single UE
    [Documentation]  Start traffic for single provided UE.
    [Arguments]  ${ue}  ${ul_time}=${40}  ${dl_time}=${40}  ${ul_throughput}=20M  ${dl_throughput}=40M
    @{ue_names}=    Create list    ${ue}
    ${ips}=    __UE_list_to_ips    ${ue_names}
    Start UL and DL traffic on IP list    ${ips}  ${ul_time}  ${dl_time}  ${ul_throughput}  ${dl_throughput}

Start UL and DL traffic on IP list
    [Documentation]  Starts uplink/downlink traffic for every IP on list with given parameters, exits after starting
    [Arguments]  ${pdu_ips}  ${ul_time}=${40}  ${dl_time}=${40}  ${ul_throughput}=20M  ${dl_throughput}=40M
    ${range}=    Get Length    ${pdu_ips}
    ${pdu_ips_len}=    Get Length    ${ip_assignment}
    Should be True    ${range} == ${pdu_ips_len}    msg=Wrong ppdu ip session established - expected ${range}, got ${pdu_ips_len}
    :FOR    ${ip}    IN    @{pdu_ips}
    \   __start_DL_and_UL_traffic_on_IP  pdu_ip=${ip}  ul_time=${ul_time}  dl_time=${dl_time}
    ...                                      ul_throughput=${ul_throughput}  dl_throughput=${dl_throughput}
    ${traffic_start}=    Get Current Date     UTC
    Set test variable    ${traffic_start}
    ${status}=   Evaluate    ${dl_time} < ${ul_time}
    Run keyword if    ${status} == True
    ...   Set test variable    ${traffic_duration}    ${dl_time}
    Run keyword if    ${status} == False
    ...   Set test variable    ${traffic_duration}    ${ul_time}
    Set test variable    ${used_ips}             ${pdu_ips}
    Set test variable    ${set_ul_throughput}    ${ul_throughput}
    Set test variable    ${set_dl_throughput}    ${dl_throughput}

Verify UL and DL speeds
    [Documentation]  Uses saved arguments during starting dl and ul traffic to wait for tput end and validate its output (min 20% of target).
    ${current_time}=    Get Current Date     UTC
    ${time_passed}=    Subtract date from date    ${current_time}    ${traffic_start}
    ${time_left}=    Evaluate    ${traffic_duration} - ${time_passed} + 1
    Run keyword if    ${time_left} > 0
    ...      Sleep    ${time_left}    reason=Waiting for tput to end
    __verify_UL_and_DL_speeds_on_list    ${used_ips}  ${set_ul_throughput}  ${set_dl_throughput}

Run and verify traffic on single UE
    [Documentation]  Starts and verifies uplink/downlink traffic for single UE
    [Arguments]  ${ue}  ${time}=${40}  ${ul_throughput}=25M  ${dl_throughput}=40M
    @{ue_names}=    Create list   ${ue}
    ${ips}=    __UE_list_to_ips    ${ue_names}
    Run and verify traffic on IP list    ${ips}  ${time}  ${ul_throughput}  ${dl_throughput}

Run and verify traffic on UE list
    [Documentation]  Starts and verifies uplink/downlink traffic for UE list
    [Arguments]  ${ue_names}  ${time}=${40}  ${ul_throughput}=25M  ${dl_throughput}=40M
    ${ips}=    __UE_list_to_ips    ${ue_names}
    Run and verify traffic on IP list    ${ips}  ${time}  ${ul_throughput}  ${dl_throughput}

Run and verify traffic on IP list
    [Documentation]  Starts and verifies uplink/downlink traffic for every IP on list with given parameters, exits after completion
    [Arguments]  ${pdu_ips}  ${time}=${40}  ${ul_throughput}=25M  ${dl_throughput}=40M
    Start UL and DL traffic on IP list  pdu_ips=${pdu_ips}  ul_time=${time}  dl_time=${time}
    ...                              ul_throughput=${ul_throughput}  dl_throughput=${dl_throughput}
    Verify UL and DL speeds

##               ##
###################
# Private members #
###################
##               ##

__set_synchronization
    [Documentation]   Starts synchronisation on ASIK
    ${asik_alias}=   Connect to ASIK
    ${command}=  Set Variable  ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_10M_INTERNAL DDAL_CLK_IO_PORT_SINGLE_ENDED_OUT_1
    ssh.Execute   command=${command}  connection=${asik_alias}

__get_TM500_address
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'dict'
    ...        __get_TM500_address_with_yaml_cfg
    ...    ELSE
    ...        __get_TM500_address_without_yaml_cfg

__get_script_paths
    [Arguments]   ${ue_count}=1
    Run Keyword If   '${tl.ues[0].__class__.__name__}' == 'dict'
    ...        __get_viavi_script_paths_with_yaml_cfg
    ...    ELSE
    ...        __get_viavi_script_paths_without_yaml_cfg

__get_TM500_address_with_yaml_cfg
    ${ue}=   Get From Dictionary   ${tl.ues[0]['UE_POOLS']['ViaviUePool']}   UE_1
    Set suite variable    ${tma_ip}      ${ue['CONSTRUCTOR_PARAMETERS']['hostname']}
    Set suite variable    ${tma_port}    ${ue['CONSTRUCTOR_PARAMETERS']['port']}

__get_TM500_address_without_yaml_cfg
    Should be equal   ${tl.ues[0].__class__.__name__}   TM500
    Set suite variable    ${tma_ip}      ${tl.ues[0].tma_host.addr}
    Set suite variable    ${tma_port}    ${tl.ues[0].tma_command_port}

__get_viavi_script_paths_with_yaml_cfg
    ${script_paths}=   get_script_path_dictionary    ue_dict=${tl.ues[0]['UE_POOLS']['ViaviUePool']}
    Set suite variable    ${script_paths}

__get_viavi_script_paths_without_yaml_cfg
    Set suite variable    ${script_paths}    ${viavi_scripts}

__get_shared_variables_with_yaml_config
    [Arguments]   ${ue_alias}=UE_1
    ${constructor_parameters}=  Set Variable  ${tl.ues[0]['UE_POOLS']['ViaviUePool']['${ue_alias}']['CONSTRUCTOR_PARAMETERS']}
    Set suite variable    ${attach_validation_pattern}
    ...                   ${constructor_parameters['attach_validation']}
    Set suite variable    ${detach_validation_pattern}
    ...                   ${constructor_parameters['detach_validation']}
    Set suite variable    ${network_interface_address}
    ...                   ${constructor_parameters['data_transfer']['core_appserver']['network_interface_address']}

__connect_to_TMA
    rci.Connect To   ${tma_ip}   ${tma_port}

__start_downlink_traffic
    [Arguments]   ${pdu_ip}   ${time}=${20}   ${throughput}=30M
    ${realcore_app_alias}=  Connect to RealCore
    ${viavi_app_alias}=     Connect to Appserver
    ${interface}=           Get From Dictionary   dictionary=${ip_assignment}    key=${pdu_ip}
    ${port}=                generate_next_port

    ${server_command}=   generate_iperf3_server   port=${port}  bind=${interface}
    ${client_command}=   generate_iperf3_client   ip=${interface}  port=${port}  bind=${pdu_ip}  time=${time}
    ...                                           bitrate=${throughput}  log=${pdu_ip}_dl.log  reverse=True
    Log    Generated command server: ${server_command}
    Log    Generated command client: ${client_command}

    ssh.Send Command     command=${server_command}     connection=${realcore_app_alias}
    ssh.Send Command     command=${client_command}     connection=${viavi_app_alias}

__start_uplink_traffic
    [Arguments]   ${pdu_ip}   ${time}=${20}   ${throughput}=30M
    ${realcore_app_alias}=  Connect to RealCore
    ${viavi_app_alias}=     Connect to Appserver
    ${interface}=           Get From Dictionary   dictionary=${ip_assignment}    key=${pdu_ip}
    ${port}=                generate_next_port

    ${server_command}=   generate_iperf3_server  port=${port}  bind=${interface}  log=${pdu_ip}_ul.log
    ${client_command}=   generate_iperf3_client  ip=${interface}  port=${port}  bind=${pdu_ip}  time=${time}  bitrate=${throughput}
    Log    Generated command server: ${server_command}
    Log    Generated command client: ${client_command}

    ssh.Send Command     command=${server_command}     connection=${realcore_app_alias}
    ssh.Send Command     command=${client_command}     connection=${viavi_app_alias}

__UE_list_to_ips
    [Arguments]   ${ue_names}
    @{ip_list}=    Create List
    :FOR    ${ue}    IN    @{ue_names}
    \   ${ip}    Get from dictionary    ${IP dict}    ${ue}
    \   Append to list    ${ip_list}    ${ip}
    [Return]  ${ip_list}

__start_DL_and_UL_traffic_on_IP
    [Documentation]  Starts uplink/downlink traffic for one PDU IP with given parameters, exits after starting
    [Arguments]  ${pdu_ip}  ${ul_time}=${20}  ${dl_time}=${20}  ${ul_throughput}=30M  ${dl_throughput}=30M
    __Start downlink traffic    pdu_ip=${pdu_ip}   time=${dl_time}   throughput=${dl_throughput}
    __Start uplink traffic      pdu_ip=${pdu_ip}   time=${ul_time}   throughput=${ul_throughput}

__download_DL_file
    [Arguments]  ${pdu_ip}
    ${viavi_app_alias}=     Connect to Appserver
    ssh.Download File          ${pdu_ip}_dl.log    ${LOG_PATH}/${test_name}_${pdu_ip}_dl.log    connection=${viavi_app_alias}
    ssh.Send Command     command=pkill iperf3     connection=${viavi_app_alias}

__download_UL_file
    [Arguments]  ${pdu_ip}
    ${realcore_app_alias}=  Connect to RealCore
    ssh.Download File          ${pdu_ip}_ul.log    ${LOG_PATH}/${test_name}_${pdu_ip}_ul.log    connection=${realcore_app_alias}

__verify_UL_and_DL_speeds_single_IP
    [Documentation]  Downloads log files and verifies uplink/downlink speeds are within 20% of target for single IP
    [Arguments]  ${pdu_ip}  ${ul_throughput}=30M  ${dl_throughput}=30M
    Download UL file    ${pdu_ip}
    Download DL file    ${pdu_ip}
    Verify throughput file     file_location=${test_name}_${pdu_ip}_dl.log    target=${dl_throughput}
    Verify throughput file     file_location=${test_name}_${pdu_ip}_ul.log    target=${ul_throughput}

__verify_UL_and_DL_speeds_on_list
    [Documentation]  Downloads log files and verifies uplink/downlink speeds are within 20% of target for all given IPs
    [Arguments]  ${pdu_ips}  ${ul_throughput}=30M  ${dl_throughput}=30M
    ${range}=    Get Length    ${pdu_ips}
    :FOR    ${index}    IN RANGE    ${range}
    \   ${ip}=      Set variable    @{pdu_ips}[${index}]
    \   Download UL file    ${ip}
    \   Download DL file    ${ip}
    :FOR    ${index}    IN RANGE    ${range}
    \   ${ip}=      Set variable    @{pdu_ips}[${index}]
    \   Verify throughput file     file_location=${test_name}_${ip}_dl.log    target=${dl_throughput}
    \   Verify throughput file     file_location=${test_name}_${ip}_ul.log    target=${ul_throughput}
    ${realcore_app_alias}=  Connect to RealCore
    ${viavi_app_alias}=     Connect to Appserver
    ssh.Execute             command=rm *_ul.log   connection=${realcore_app_alias}
    ssh.Execute             command=rm *_dl.log   connection=${viavi_app_alias}
    ssh.Execute             command=pkill iperf3  connection=${realcore_app_alias}


