*** Settings ***

Documentation     Keywords for tshark
...    This resource provides keywords to control tshark

Library           String

Library     taf.collectors.tshark       WITH NAME   tshark
Library     taf.transport.ssh           WITH NAME   ssh

Resource    testline.robot
Resource    connect.robot

*** Keywords ***
Start Tshark on Test PC
    [Documentation]
    ...     Start Tshark on Testpc
    ...
    ...     | collector |  Name of collector. _Impact on log filename!_  |
    ...     | options   |  tshark options |
    ...
    ...     for TCE trace session following option can be used
    ...
    ...     | -i eth3 -o ntrstr.defragment:TRUE -o ntrstr.port:49151 -f "tcp dst port 49151"

    [Arguments]    ${collector}     ${options}=${EMPTY}
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tshark.create_tshark_collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${testpc_ssh_config}
    tshark.setup_collectors    names=${collector}
    tshark.start_collectors    names=${collector}
    tshark.set_suite_alias     ${collector}


Start Tshark on S1 Interface of TestPC
    [Documentation]
    ...     Start Tshark on Testpc for S1 capture
    ...
    ...     | collector | Name of collector. _Impact on log filename!_ |
    ...
    ...     *Returns*  the collector name of the started collector

    [Arguments]    ${collector}=s1_tshark
    ${s1_interface}=        Get S1 Interface on TestPC
    Start Tshark on Test PC    collector=${collector}    options=-i ${s1_interface}
    [Return]    ${collector}


Start Tshark for Trace Session
    [Documentation]
    ...     Start Tshark on given interface of Testpc to collect Cell Trace / PCMD / Subscriber Trace
    ...
    ...     | interface  | Interface tshark |
    ...     | trace_port | configured in scf TCE.tcePortNumber |
    ...     | collector  | Name of collector. _Impact on log filename!_ |
    ...
    ...     *Returns*  the collector name of the started collector

    [Arguments]    ${interface}=eth3  ${trace_port}=49151  ${collector}=trace_session
    Start Tshark on Test PC   collector=${collector}
    ...            options=-i ${interface} -o ntrstr.defragment:TRUE -o ntrstr.port:${trace_port} -f "tcp dst port ${trace_port}"
    [Return]    ${collector}


Stop Tshark on Test PC
    [Documentation]
    ...     Stop the Tshark given by the collector name
    ...
    ...     | collector  | Collector name of the collector to stop |
    ...     | target_dir | Target directory. If not given, the test case log directory will be taken |
    ...
    ...     *Returns* The path to the collected pcap file

    [Arguments]    ${collector}=None    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...                                 ELSE                       Set Variable    ${target_dir}
    tshark.stop_collectors         names=${collector}
    tshark.collect_collectors      names=${collector}  target_dir=${target_dir}
    tshark.teardown_collectors     names=${collector}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Get S1 Interface on TestPC
    [Documentation]
    ...     Keyword to get the S1 interface from the test pc
    ...
    ...     *Scope*   Internal
    ...
    ...     *Returns* The S1 network interface

    ${enb_ip}       Convert To String   ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    ${enb_net_class_c}  ${rest}  Split String From Right     ${enb_ip}    separator=.  max_split=1
    ${output}   OperatingSystem.Run   sudo route | grep '^${enb_net_class_c}' | grep -o '[^ ]*$'
    #  Unclear  "eth1.3010" or  eth1  is needed
    ${s1_interface}     Fetch From Left   ${output}    marker=.
    [Return]    ${s1_interface}
