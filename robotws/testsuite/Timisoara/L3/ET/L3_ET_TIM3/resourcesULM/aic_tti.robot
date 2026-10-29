*** Settings ***
Documentation     Keywords related to collection of TTI Traces on AIC TL
...  Description: This is an intermediate WA to enable TTI Traces in Streaming mode
...               on AIC/VRAN2.0 TL until TAF provides collectors for that

Library     taf.gnb.oam.coam.cu         WITH NAME  coam_cu
Library     taf.gnb.oam.coam.vdu        WITH NAME  coam_vdu
Resource    tcpdump.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# AIC Keywords
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

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
    [Arguments]    ${nrcell_id_list}=${None}
    ...            ${dscp}=0
    ...            ${up_destIpAddr}=10.0.1.13
    ...            ${up_port}=5678
    ...            ${interface}=eth3
    ...            ${option}=port ${up_port}
    Create Tcpdump on VM AIC           interface=${interface}            option=${option}   collectorAIC=TTItcpdumpAic
    Start Tcpdump on VM AIC
#-#    ${default_nrcell_id_list}         get slice from list               ${NRCELL_ID_LIST_DU}   end=1
#-#    ${tmp_nrcell_id_list}             set variable if                   ${nrcell_id_list} is ${None}
#-#    ...                               ${default_nrcell_id_list}         ${nrcell_id_list}
    ${tmp_nrcell_id_list}    create list   1
    ${tti_activ_trace_id}             _Start TTI Trace Via UPTrace AIC       nr_cell_list=${tmp_nrcell_id_list}   dscp=${dscp}
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
         ${cell_dn}    set variable   MRBTS-5465/NRBTS-5465/NRCELL-${cell_id}
         append to list   ${cell_list}    ${cell_dn}
    END
    _Update User Plane Trace Configuration For vDU AIC    uplane_ip_addr=${up_destIpAddr}    uplane_port=${up_port}    dscp=${dscp}
    ${tti_activ_trace_id}=    _Start Uplane Trace For vDU AIC    target_component=L2Ps     nr_cell_dn_list=${cell_list}    trace_type=Component
    Set Suite Variable        ${tti_activ_trace_id}
    Log            Activated TTI trace Id is: ${tti_activ_trace_id}
    [Return]     ${tti_activ_trace_id}

_Update User Plane Trace Configuration For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Update user plane configuration
    ...    |  dscp               |   the dscp value,  "0" by default |
    ...    |  up_destIpAddr      |   the destination IP address, "10.0.1.1" by default |
    ...    |  up_port            |   the UP port, "5678" by default |    
    [Arguments]   ${uplane_ip_addr}=10.0.1.1
    ...           ${uplane_port}=5678
    ...           ${dscp}=0
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}

    ${session}  Connect to OAM DU   gnb_id=${0}
    ${res1}      coam_vdu . update_uplane_configuration
    ...                                uplane_ip_addr=${uplane_ip_addr}
    ...                                uplane_port=${uplane_port_1}
    ...                                dscp=${dscp_1}
    ...                                vdu_connection=${session}
    sleep    10s
    ${res2}      coam_vdu . get_trs_api_operation_status  operation_id=${res1}  vdu_connection=${session}
    Disconnect from OAM DU    ${session}
    [Return]    ${res2}

_Start Uplane Trace For vDU AIC
    [Documentation]  INTERNAL USAGE
    ...    Start Uplane TTI stream inside GNB
    ...    |  target_component   |   the component who generates the traces, "L2Ps" by default |
    ...    |  nr_cell_dn_list    |   list of cells which are monitored, 1st cell in the configured cells list by default |
    ...    |  trace_type         |   "Component" by default |  
    [Arguments]    ${target_component}=L2Ps
    ...            ${nr_cell_dn_list}=${None}
    ...            ${trace_type}=Component
    ${session}  Connect to OAM DU   gnb_id=${0}
    ${res1}      coam_vdu . start_uplane_trace_stream
    ...                                target_component=${target_component}
    ...                                nr_cell_dn_list=${nr_cell_dn_list}
    ...                                trace_type=${trace_type}
    ...                                vdu_connection=${session}
    Log To Console    ${res1}
    sleep    3s
    ${res2}      coam_vdu . get_active_trace_streams   vdu_connection=${session}
    Log To Console             TTI active_trace_streams: ${res2[0]['trace_id']}
    Disconnect from OAM DU    ${session}
    [Return]    ${res2[0]['trace_id']}

Create Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Create tcpdump collector to capture TTI traces on the test line VM
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
    core.set_suite_alias     ${collectorAIC}
    Set Suite Variable           ${collectorAIC}
    [Return]    ${collectorAIC}
    
Start Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Start tcpdump to capture TTI traces on the test line VM
    ...    collector has to be created first with "Create Tcpdump on VM AIC" !! 
    core.start_collectors    names=${collectorAIC}

Stop Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    Stop tcpdump on the test line VM

    core.stop_collectors    names=${collectorAIC}

Collect Tcpdump on VM AIC
    [Documentation]  INTERNAL USAGE
    ...    collect and teardown tcpdump collectors on the test line VM
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    ...    tcpdump has to be stopped before with "Stop Tcpdump on VM AIC" !!
    
    [Arguments]     ${desired_storage_directory}
    ...             ${desired_file_name}=ttitrace_streaming
    Log        desired_storage_directory: ${desired_storage_directory}
    Log        desired_file_name: ${desired_file_name}
    core.collect_collectors    names=${collectorAIC}     target_dir=${desired_storage_directory}
    core.teardown_collectors    names=${collectorAIC}
    Move Trace File to Desired Directory AIC    desired_storage_directory=${desired_storage_directory}
    ...                                         desired_file_name=${desired_file_name}    collector=${collectorAIC}
    
Move Trace File to Desired Directory AIC
    [Documentation]     [PRIVATE]
    [Arguments]     ${desired_storage_directory}      ${desired_file_name}        ${collector}
    Move file  ${desired_storage_directory}/${collector}/${collector}.pcap
    ...        ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/${collector}/  recursive=True

Stop And Download TTI Trace On AIC
    [Documentation]
    ...    Stop tcpdump and Uplane streaming
    ...    |  desired_storage_directory     |   path where to store TTI traces, test path by default |
    ...    |  desired_file_name             |   TTI trace filename, "ttitrace_streaming" by default |
    [Arguments]          ${desired_storage_directory}
    ...                  ${desired_file_name}=ttitrace_streaming
    log to console             Stop L2PS TTI trace(uplane trace stream) in AIC
    ${session}  Connect to OAM DU   gnb_id=${0}
    ${res2}      coam_vdu . get_active_trace_streams   vdu_connection=${session}
    Log To Console    Active trace is: ${res2[0]['trace_id']}
    ${res1}      coam_vdu . stop_uplane_trace_stream    trace_id=${res2[0]['trace_id']}   vdu_connection=${session}
    Stop Tcpdump on VM AIC
    Collect Tcpdump on VM AIC      desired_storage_directory=${desired_storage_directory}
    ...                         desired_file_name=${desired_file_name}
    Disconnect from OAM DU    ${session}
    [Return]   ${desired_storage_directory}/${desired_file_name}.pcap

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

