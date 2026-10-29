*** Settings ***

Documentation     Keywords for tcpdump

Library     OperatingSystem
Library     Collections
Library     String
Library     XML

Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     python/connect.py           WITH NAME   connect_py
Library     ute_tshark

Resource    testline.robot

*** Keywords ***
Start TCPdump On All ENBs
    [Documentation]
    ...    Start tcpdump on all eNBs found in TL config
    ...
    ${enb_num}=     Get Length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Start TCPdump On ENB     enb_id=${enb_id}
    END


Start TCPDump On ENB
    [Documentation]
    ...     Start tcpdump on eNB common unit on interface brl
    ...
    ...     | enb_id | Number of eNB |
    ...
    ...    *Returns*    name of the collector
    ...
    [Arguments]    ${enb_id}=${0}

    ${executor}=   connect_py.Get LMP Connection Details For Collector  ${tl}  ${tl.enbs[${enb_id}]}

    ${collector_name}   Set Variable    enb${enb_id}_s1x2_tcpdump
    tcpdump.Create TCPDump Collector
    ...     name=${collector_name}
    ...     options=-i br1 -s0 sctp or icmp
    ...     executor=${executor}
    tcpdump.Setup Collectors    names=${collector_name}
    tcpdump.Start Collectors    names=${collector_name}
    tcpdump.Set Suite Alias     ${collector_name}
    RETURN  ${collector_name}


Stop TCPDump On All ENBs
    [Documentation]
    ...    Stop tcpdump on all eNBs found in TL config
    ...
    [Arguments]    ${target_dir}=${None}
    ${enb_num}=     Get Length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Stop TCPDump On ENB     enb_id=${enb_id}    target_dir=${target_dir}
    END


Stop TCPdump On ENB
    [Documentation]
    ...     Stop tcpdump on eNB and store logs in Log directory
    ...
    ...     | enb_id     | Number of eNB |
    ...     | target_dir | Directory to store the pcap file |
    ...
    ...     *Returns* Path to tcpdump pcap file incl. filename
    ...
    ...
    [Arguments]    ${enb_id}=${0}    ${target_dir}=${None}
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    tcpdump.Stop Collectors         names=enb${enb_id}_s1x2_tcpdump
    tcpdump.Collect Collectors      names=enb${enb_id}_s1x2_tcpdump   target_dir=${target_dir}
    tcpdump.Teardown Collectors     names=enb${enb_id}_s1x2_tcpdump
    RETURN    ${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap


Start TCPDump On TestPc
    [Documentation]
    ...     Start Tcpdump on test PC
    ...
    ...     | options   | Additional options for tcpdump |
    ...     | collector | Name of collector *Impact on log filename* |
    ...
    ...     *Returns* collector name
    ...
    ...
    ...     *Example:*
    ...
    ...         | Start Tcpdump on TestPc     options=-i eth0   collector=dumpOnTestPc
    ...         | Sleep     10 sec
    ...         | Stop Tcpdump on TestPc      collector=dumpOnTestP
    ...
    [Arguments]     ${options}=${EMPTY}      ${collector}=testpc_tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.Create TCPDump Collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${testpc_ssh_config}
    tcpdump.Setup Collectors    names=${collector}
    tcpdump.Start Collectors    names=${collector}
    tcpdump.Set Suite Alias     ${collector}
    Log     \nTcpdump collector '${collector}' on test pc started successfully with options '${options}'!   console=${P_console}
    RETURN    ${collector}


Stop TCPDump On TestPc
    [Documentation]
    ...     Stop tcpdump on testpc,
    ...     Logs are storred in Testcase Log directory
    ...
    ...     | collector  | collector to be stopped |
    ...     | target_dir | Directory to store the pcap file |
    ...
    ...
    ...     *Returns* Path to tcpdump file incl. filename
    ...
    [Arguments]     ${collector}=testpc_tcpdump    ${target_dir}=${None}
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    tcpdump.Stop Collectors         names=${collector}
    tcpdump.Collect Collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.Teardown Collectors     names=${collector}
    Log    \nTcpdump collector '${collector}' on test pc stopped and collected successfully!   console=${P_console}
    RETURN    ${target_dir}/${collector}/${collector}.pcap


Stop TCPDump
    [Documentation]
    ...     Stop any tpcdump collector
    ...
    ...     | collector  | Collector to be stop |
    ...     | target_dir | Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}==${EMPTY}
    IF   '${target_dir}'=='${EMPTY}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    IF   '${tcpdump_filename}'=='${EMPTY}'
        ${tcpdump_filename}   testline.Get Testcase Log Directory
    END

    tcpdump.Stop Collectors         names=${collector}
    tcpdump.Collect Collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.Teardown Collectors     names=${collector}
    OperatingSystem.Run
    ...     mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${tcpdump_filename}.pcap; rm -rf ${target_dir}/${collector}
    RETURN   ${target_dir}/${tcpdump_filename}.pcap


Start TCPDump On GNB Common Unit
    [Documentation]
    ...     Start Tcpdump on gNB Common Unit
    ...
    ...     | options   | any additional tcpdump options necessary as per user requirements, e.g. '-i any sctp' |
    ...     | collector | Custom name for the collector if necessary. |
    ...     | gnb_id    | Id/Number of gNB |
    ...     | du_id     | Id/Number of DU |
    ...     | comu_id   | Id/Number of Common Unit |
    ...
    ...     *Returns* collector name
    ...
    [Arguments]   @{}   ${options}=${EMPTY}  ${collector}=common_unit-tcpdump  ${gnb_id}=0  ${du_id}=0  ${comu_id}=0

    ${executor}     connect_py.Get LMP Connection Details For Collector  ${tl}
    ...                      nodeb=${tl.gnbs[${gnb_id}]}   du_id=${du_id}   cu_id=${comu_id}

    tcpdump.Create TCPDump Collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${executor}
    tcpdump.Setup Collectors    names=${collector}
    tcpdump.Start Collectors    names=${collector}
    tcpdump.Set Suite Alias     ${collector}
    RETURN    ${collector}


Start TCPDump On AP Common Unit
    [Documentation]
    ...     Start Tcpdump on AP Common Unit
    ...
    ...     | options   | any additional tcpdump options necessary as per user requirements, e.g. to define the interface '-i eth0' |
    ...     | collector | Custom name for the collector if necessary.  |
    ...     | ue_id     | Id/Number of AP |
    ...     | comu_id   | Id/Number of Common Unit |
    ...
    ...     *Returns* collector name
    ...

    [Arguments]     ${options}=${EMPTY}  ${collector}=common_unit-ap-tcpdump  ${ue_id}=0  ${comu_id}=0
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    tcpdump.Create TCPDump Collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${common_unit_ssh_config}
    tcpdump.Setup Collectors    names=${collector}
    tcpdump.Start Collectors    names=${collector}
    tcpdump.Set Suite Alias     ${collector}
    RETURN    ${collector}


Stop TCPDump On GNB Common Unit
    [Documentation]
    ...     Stop Tcpdump on gNB Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     | collector        | Custom name for the collector defined in 'Start Tcpdump on gNB Common Unit' |
    ...     | target_dir       | Custom directory location where the TCP Dump has to be stored. |
    ...     | ...              | If target_dir isn't used traces will be stored in test case log directory. |
    ...     | tcpdump_filename | Custom filename for the TCP Dump. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]    ${collector}    ${target_dir}=${EMPTY}    ${tcpdump_filename}=${EMPTY}
    ${tcpdump_file}=  Stop TCPDump On Common Unit  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}
    RETURN  ${tcpdump_file}


Stop TCPDump On AP Common Unit
    [Documentation]
    ...     Stop Tcpdump on AP Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     | collector        | Custom name for the collector defined in 'Start Tcpdump on AP Common Unit' |
    ...     | target_dir       | Custom directory location where the TCP Dump has to be stored. |
    ...     | ...              | If target_dir isn't used traces will be stored in test case log directory. |
    ...     | tcpdump_filename | Custom filename for the TCP Dump. |
    ...     | ...              | If tcpdump_filename isn't used file will named '${collector}.pcap'. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]    ${collector}    ${target_dir}=${EMPTY}    ${tcpdump_filename}=${EMPTY}
    ${tcpdump_file}=  Stop TCPDump On Common Unit  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}
    RETURN  ${tcpdump_file}


Start L2_L3 SYSCOM Trace On ABIO
    [Documentation]
    ...     Start L2_L3 SYSCOM Trace on ABIO
    ...
    ...     | options   | any additional tcpdump options necessary as per user requirements, e.g. to define the interface '-i eth0' |
    ...     | collector | Custom name for the collector if necessary. |
    ...     | gnb_id    | Id/Number of gNB |
    ...     | du_id     | Id/Number of DU |
    ...     | comu_id   | Id/Number of Common Unit |
    ...     | capu_id   | Id/Number of Capacity Unit |
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}  ${options}=-i etha01.212  ${collector}=l2_l3_interface_trace
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ${host}=   testline.Get Capacity Slave IP   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}   capu_id=${capu_id}
    ${slave_unit_ssh_config}=  Create Dictionary
    ...    host=${host}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...    proxy=${common_unit_ssh_config}
    tcpdump.Create TCPDump Collector
    ...     name=${collector}
    ...     options=${options}
    ...     executor=${slave_unit_ssh_config}
    tcpdump.Setup Collectors    names=${collector}
    tcpdump.Start Collectors    names=${collector}
    tcpdump.Set Suite Alias     ${collector}
    RETURN   ${collector}


Stop L2_L3 SYSCOM Trace On ABIO
    [Documentation]
    ...     Stop Tcpdump on ABIO
    ...
    ...     | collector        | Custom name for the collector defined in 'Start Tcpdump on gNB/AP Common Unit' |
    ...     | target_dir       | Custom directory location where the TCP Dump has to be stored.  |
    ...     | tcpdump_filename | Custom filename for the TCP Dump.  |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]  ${collector}=l2_l3_interface_trace  ${target_dir}=${EMPTY}  ${tcpdump_filename}=l2_l3_tcpdump
    ${trace_path}   Stop TCPDump  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}
    RETURN   ${trace_path}


Stop TCPDump On Common Unit
    [Documentation]
    ...     Stops Tcpdump on gNB/AP Common Unit

    ...
    ...     | collector        | Custom name for the collector defined in 'Start Tcpdump on gNB/AP Common Unit' |
    ...     | target_dir       | Custom directory location where the TCP Dump has to be stored.  |
    ...     | tcpdump_filename | Custom filename for the TCP Dump. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}=${EMPTY}
    IF   '${target_dir}'=='${EMPTY}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    ${tcpdump_filename}=  Set Variable If  '${tcpdump_filename}'=='${EMPTY}'  ${collector}.pcap  ${tcpdump_filename}
    tcpdump.Stop Collectors         names=${collector}
    tcpdump.Collect Collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.Teardown Collectors     names=${collector}
    OperatingSystem.Run
    ...     command=mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${collector}/${tcpdump_filename}
    RETURN  ${target_dir}/${collector}/${tcpdump_filename}


Get Xnap Protocol Version
    [Documentation]
    ...
    ...    decodes the input file to pdml, searches for xnap protocol
    ...
    ...    *Returns* xnap protocol string
    ...
    ...   | tshark_file  | input file for getting xnap protocol |
    ...	  | return_value | xnap protocol version |
    ...
    [Arguments]    ${tshark_file}
    ${output}  ute_tshark.Read PCAP  output_type=pdml  pcap_file_path=${tshark_file}
    ${proto}   XML.Get Elements      ${output}         .//field[@name='frame.protocols']
    FOR  ${i}  IN   @{proto}
         ${showname}  XML.Get Element Attribute  ${i}  showname
         IF  'xnap' in "'${showname}'"   BREAK
    END
    @{protocol_elements}    String.Split String  ${showname}  :
    ${xnap_proto_list}   Collections.Get Matches   ${protocol_elements}  *xnap*
    ${xnap_proto}        Set Variable    ${xnap_proto_list}[0]
    Should Contain       ${xnap_proto}   xnap
    RETURN  ${xnap_proto}
