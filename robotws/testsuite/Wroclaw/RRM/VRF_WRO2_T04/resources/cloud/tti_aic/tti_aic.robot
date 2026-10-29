*** Settings ***
Documentation    Robot resource for collecting TTI traces AIC

Library    Collections
Library    OperatingSystem
Library    taf.collectors.tcpdump             WITH NAME    tcpdump
Library    taf.collectors.l2stream3           WITH NAME    l2stream3
Library    taf.collectors.core                WITH NAME    core

Library    tti_aic.py

*** Keywords ***
Start To Collect TTI Trace On AIC
    [Documentation]
    ...    ATTENTION : the keyword "Scf.Add TTI Route in SCF for AIC" must be called to update the SCF with the route
    ...                before calling this keyword
    ...    Start to collect TTI traces for AIC
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the IP address where TTI traces are sent to, "10.0.1.1" by default |
    ...    |  up_port            |   the port where TTI traces are sent to, "5678" by default |
    ...    |  interface          |   the network interface where TTI traces are sent to, "eth3" by default |
    ...    |  option             |   options to be passed to tcpdump providing the path where TTI .pcap file is generated |
    ...    Example
    ...    |  @{cellList} =  Create List |  1            |
    ...    |  Start To Collect TTI Trace |  ${cellList}  |
    [Arguments]    ${nrcell_id_list}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=172.16.2.10
    ...            ${up_port}=5678
    ...            ${interface}=eth9
    ...            ${option}=port ${up_port}
    Start Tcpdump on VM AIC           interface=${interface}            option=${option}   collectorAIC=TTItcpdumpAic
    ${tti_active_trace_id}             _Start TTI Trace Via UPTrace AIC       nr_cell_list=${nrcell_id_list}   dscp=${dscp}
    ...                               up_destIpAddr=${up_destIpAddr}    up_port=${up_port}

_Start TTI Trace Via UPTrace AIC
    [Documentation]  INTERNAL USAGE
    ...    Start TTI trace using UPLANE trace on VDU
    ...    |  nrcell_id_list     |   the nr cell id list, ${None} is the default and means the 1st cell |
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |
    [Arguments]    ${nr_cell_list}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=10.0.1.1
    ...            ${up_port}=5678

    ${cell_list}    create list
    FOR   ${cell_id}    IN    @{nr_cell_list}
         ${cell_dn}    set variable   MRBTS-${MRBTS_ID_DU}/NRBTS-${NRBTS_ID_DU}/NRCELL-${cell_id}
         append to list   ${cell_list}    ${cell_dn}
    END
    update_uplane_configuration    uplane_ip_addr=${up_destIpAddr}    uplane_port=${up_port}    dscp=${dscp}
    ${tti_activ_trace_id}=    start_uplane_trace_on_vdu    component=L2Ps     dn_cell_list=${cell_list}    trace_type=Component
    Set Suite Variable        ${tti_activ_trace_id}
    Log To Console            Activated TTI trace Id is: ${tti_activ_trace_id}
    [Return]     ${tti_activ_trace_id}


Start Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Start tcpdump to capture TTI traces on the test line VM
    ...    |  interface     |   network interface where to capture the traces, "eth3" by default |
    ...    |  option        |   option to be used by tcpdump for capturing traces (output filename, ...) |
    ...    |  collectorAIC  |   string representing the name of the collector, "TTItcpdumpAic" by default |
    [Arguments]     ${interface}=eth3
    ...             ${option}=port 5678
    ...             ${collectorAIC}=TTItcpdumpAic
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collectorAIC}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    core.setup_collectors    names=${collectorAIC}
    core.start_collectors    names=${collectorAIC}
    core.set_suite_alias     ${collectorAIC}
    Set Suite Variable           ${collectorAIC}
    [Return]    ${collectorAIC}

Stop Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Stop tcpdump on the test line VM
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    [Arguments]     ${desired_storage_directory}=${EMPTY}
    ...             ${desired_file_name}=ttitrace_streaming
    Log To Console        desired_storage_directory: ${desired_storage_directory}
    Log To Console        desired_file_name: ${desired_file_name}
    ${desired_storage_directory}=                set variable if    '${desired_storage_directory}'=='${EMPTY}'
    ...                                           ${LOG_PATH}                         ${desired_storage_directory}
    core.stop_collectors    names=${collectorAIC}
    core.collect_collectors    names=${collectorAIC}     target_dir=${desired_storage_directory}
    core.teardown_collectors    names=${collectorAIC}
    Move Trace File to Desired Directory AIC    desired_storage_directory=${desired_storage_directory}
    ...                                         desired_file_name=${desired_file_name}    collector=${collectorAIC}

Stop And Download TTI Trace On AIC
    [Documentation]
    ...    Stop tcpdump and Uplane streaming
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    [Arguments]          ${desired_storage_directory}=${OUTPUT_DIR}
    ...                  ${desired_file_name}=ttitrace_streaming
    log to console             Stop L2PS TTI trace(uplane trace stream) in AIC

    stop_uplane_trace_on_vdu
    Stop Tcpdump on VM AIC      desired_storage_directory=${desired_storage_directory}
    ...                         desired_file_name=${desired_file_name}
    [Return]    ${desired_storage_directory}/${desired_file_name}.pcap

Move Trace File to Desired Directory AIC
    [Documentation]     [PRIVATE]
    [Arguments]     ${desired_storage_directory}      ${desired_file_name}        ${collector}
    ${desired_storage_directory}     Set Variable If       '${desired_storage_directory}'=='${EMPTY}'
    ...                              ${OUTPUT_DIR}      ${desired_storage_directory}
    Move file  ${desired_storage_directory}/${collector}/${collector}.pcap
    ...        ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/${collector}/  recursive=True
