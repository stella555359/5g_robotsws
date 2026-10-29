*** Settings ***
Library     taf.rfrl.common_resources.python.check_cap.CapPacket    WITH NAME   cap
Library         taf.collectors.core         WITH NAME       core
Library         taf.collectors.tcpdump      WITH NAME       tcpdump

*** Keywords ***
Start to collect wireshark log for ASIB
    [Arguments]    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    ${name}=SCTP    ${options}=-i any proto 0x84
    ${gNB_ASIK_collector_config}=   create dictionary   host=${host}
    ...                                                 user=${username}
    ...                                                 password=${password}
    tcpdump.create_tcpdump_collector                name=${name}
    ...                                             options=${options}
    ...                                             executor=${gNB_ASIK_collector_config}
    core.setup_collectors       names=${name}
    core.start_collectors       names=${name}
    core.Set Suite Alias     ${name}
    log                         \nStarting tcpdump

Set collecting for slave Xeon on ASIK
    [Arguments]  ${ip_addr_b} 
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    ${name}=SCTP    ${options}=-i any proto 0x84
    ${gNB_ASIK_collector_config}=   create dictionary   host=${host}
    ...                                                 user=${username}
    ...                                                 password=${password}
    ${gNB_XEONB_collector_config}=   create dictionary   host=${ip_addr_b}
    ...                                                  user=toor4nsn
    ...                                                  password=oZPS0POrRieRtu
    ...                                                  proxy=${gNB_ASIK_collector_config}
    mytcpdump.create_tcpdump_collector              name=${name}
    ...                                             options=${options}
    ...                                             executor=${gNB_XEONB_collector_config}
    mycore.setup_collectors       name=${name}
    mycore.start_collectors       name=${name}
    core.Set Suite Alias     ${name}
    log                         \nStarting tcpdump



Stop collecting wireshark log
    [Arguments]    ${target_dir}    ${name}=SCTP
    core.stop_collectors        names=${name}
    log                         \Stop tcpdump
    core.collect_collectors     names=${name}          target_dir=${target_dir}
    sleep       5s
    core.teardown_collectors    names=${name}
    
