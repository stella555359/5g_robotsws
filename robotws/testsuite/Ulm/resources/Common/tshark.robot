*** Settings ***

Documentation     Keywords for tshark
...    This resource provides keywords to control tshark on the local Test VM only.

Library     String

Library     taf.collectors.tshark   WITH NAME   tshark

Resource    testline.robot

*** Keywords ***
Start Tshark For Trace Session
    [Documentation]
    ...     Start Tshark on given interface of Testpc to collect Cell Trace / PCMD / Subscriber Trace
    ...
    ...     | interface  | Interface tshark |
    ...     | trace_port | configured in scf TCE.tcePortNumber |
    ...     | collector  | Name of collector. _Impact on log filename!_ |
    ...
    ...     *Returns*  the collector name of the started collector

    [Arguments]    ${interface}=eth3  ${trace_port}=49151  ${collector}=trace_session
    Start Tshark On Test PC   collector=${collector}
    ...            options=-i ${interface} -o ntrstr.defragment:TRUE -o ntrstr.port:${trace_port} -f "tcp dst port ${trace_port}"
    RETURN    ${collector}


Stop Tshark On Test PC
    [Documentation]
    ...     Stop the Tshark given by the collector name
    ...
    ...     | collector  | Collector name of the collector to stop |
    ...     | target_dir | Target directory. If not given, the test case log directory will be taken |
    ...
    ...     *Returns* The path to the collected pcap file

    [Arguments]    ${collector}=None    ${target_dir}=None

    IF   '${target_dir}'=='None'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    tshark.Stop Collectors         names=${collector}
    tshark.Collect Collectors      names=${collector}  target_dir=${target_dir}
    tshark.Teardown Collectors     names=${collector}
    RETURN    ${target_dir}/${collector}/${collector}.pcap


Start Tshark On Test PC
    [Documentation]
    ...     Start Tshark on Testpc
    ...
    ...     | collector |  Name of collector. _Impact on log filename!_  |
    ...     | options   |  tshark options |
    ...
    ...     for TCE trace session following option can be used
    ...
    ...     | -i eth3 -o ntrstr.defragment:TRUE -o ntrstr.port:49151 -f "tcp dst port 49151"
    ...
    ...     *Scope*   Internal
    ...

    [Arguments]    ${collector}     ${options}=${EMPTY}
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tshark.Create Tshark Collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${testpc_ssh_config}
    tshark.Setup Collectors    names=${collector}
    tshark.Start Collectors    names=${collector}
    tshark.Set Suite Alias     ${collector}

