*** Settings ***
Library     taf.collectors.tcpdump      WITH NAME   tcpdump_collector


*** Keywords ***
Start Tcpdump on TestPc
    [Arguments]     ${interface}  ${option}=${EMPTY}      ${collector}=testpc_${interface}_tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump_collector.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    tcpdump_collector.setup_collectors    names=${collector}
    tcpdump_collector.start_collectors    names=${collector}
    tcpdump_collector.set_suite_alias     ${collector}
    [Return]    ${collector}


Stop Tcpdump on TestPc
    [Arguments]     ${interface}  ${collector}=testpc_${interface}_tcpdump    ${target_dir}=tcpdump
    tcpdump_collector.stop_collectors         names=${collector}
    tcpdump_collector.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump_collector.teardown_collectors     names=${collector}
    [Return]    ${target_dir}/${collector}/${collector}.pcap
