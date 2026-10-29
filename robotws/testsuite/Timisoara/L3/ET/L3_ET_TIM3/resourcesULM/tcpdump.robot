*** Settings ***

Documentation     Keywords for tcpdump

Library     OperatingSystem
Library     String
Library     XML

Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     taf.transport.ssh           WITH NAME   ssh
Library     python/tcpdump.py           WITH NAME   tcpdump_helper
Library     python/connect.py           WITH NAME   connect_py
Library     ute_tshark

Resource    testline.robot
Resource    connect.robot
Resource    gnb.robot

*** Keywords ***
Start TCPdump on all eNBs
    [Documentation]
    ...    Start tcpdump on all eNBs found in TL config
    ...
    ${enb_num}=     Get length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Start TCPdump on eNB     enb_id=${enb_id}
    END


Start TCPdump on eNB
    [Documentation]
    ...     Start tcpdump on eNB common unit on interface brl
    ...
    ...     | enb_id | Number of eNB |
    ...
    ...    *Returns*    name of the collector
    ...
    [Arguments]    ${enb_id}=${0}

    ${executor}=   connect_py.get_lmp_connection_details_for_collector  ${tl}  ${tl.enbs[${enb_id}]}

    ${collector_name}   Set Variable    enb${enb_id}_s1x2_tcpdump
    tcpdump.create_tcpdump_collector
    ...     name=${collector_name}
    ...     options=-i br1 -s0 sctp or icmp
    ...     executor=${executor}
    tcpdump.setup_collectors    names=${collector_name}
    tcpdump.start_collectors    names=${collector_name}
    tcpdump.set_suite_alias     ${collector_name}
    [Return]  ${collector_name}


Stop TCPdump on all eNBs
    [Documentation]
    ...    Stop tcpdump on all eNBs found in TL config
    ...
    [Arguments]    ${target_dir}=${None}
    ${enb_num}=     Get length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Stop TCPdump on eNB     enb_id=${enb_id}    target_dir=${target_dir}
    END


Stop TCPdump on eNB
    [Documentation]
    ...     Stop tcpdump on eNB and store logs in Log directory
    ...
    ...     | enb_id     |  Number of eNB |
    ...     | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to tcpdump pcap file incl. filename
    ...
    ...
    [Arguments]    ${enb_id}=${0}    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=enb${enb_id}_s1x2_tcpdump
    tcpdump.collect_collectors      names=enb${enb_id}_s1x2_tcpdump   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=enb${enb_id}_s1x2_tcpdump
    [RETURN]    ${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap


Start Tcpdump on TestPc
    [Documentation]
    ...     Start Tcpdump on test PC
    ...
    ...     | option |   Addtional options for tcpdump |
    ...     | interface |  Interface where tcpdump is tracing |
    ...     | collector |  Name of collector *Impact on log filename* |
    ...
    ...     *Returns* collector name
    ...
    ...
    ...     *Example:*
    ...
    ...         | Start Tcpdump on TestPc     interface=eth0 
    ...         | BuiltIn.Sleep     10 sec 
    ...         | Stop Tcpdump on TestPc     interface=eth0 
    ...
    [Arguments]     ${interface}  ${option}=${EMPTY}      ${collector}=testpc-${interface}-tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    BuiltIn.Log    \nTcpdump on test pc on interface ${interface} started successfully    console=${P_console}
    [RETURN]    ${collector}


Stop Tcpdump on TestPc
    [Documentation]
    ...     Stop tcpdump on testpc,
    ...     Logs are storred in Testcase Log directory
    ...
    ...     | interface | Interface for tcpdump |
    ...     | target_dir |  Directory to store the pcap file |
    ...
    ...
    ...     *Returns* Path to tcpdump file incl. filename
    ...
    [Arguments]     ${interface}  ${collector}=testpc-${interface}-tcpdump    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    BuiltIn.Log    \nTcpdump on test pc on interface ${interface} stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap

    
    

    




Start TCPdump on gNB OAM VM
    [Documentation]
    ...     Starts TcpDump on gNB OAM on interface (default=fronthaul)
    ...
    ...     | gnb_id |  Id/Number of gNB |
    ...     | option |  Addtional options for tcpdump |
    ...     | interface | Interface of gNB OAM for tcpdump |
    ...     | collector |  Name of collector *Impact on log filename* |
    ...
    [Arguments]     ${gnb_id}=0        ${option}=${EMPTY}    ${interface}=fronthaul  ${collector}=gnb-${gnb_id}-oam-${interface}-tcpdump
    &{oam_ssh_config}=  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${oam_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [Return]    ${collector}


Stop TCPdump on gNB OAM VM
    [Documentation]
    ...     Stop TcpDump on gNB OAM on interface (default=fronthaul)
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | interface |  Interface of gNB OAM for tcpdump |
    ...     | collector |  Name of collector *Must be same as in 'Start TCPdump on gNB OAM VM'* |
    ...     | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]     ${gnb_id}=${0}    ${interface}=fronthaul    ${collector}=gnb-${gnb_id}-oam-${interface}-tcpdump    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start TCPdump on gNB VM
    [Documentation]
    ...     Starts TcpDump on gNB VM on interface
    ...
    ...     | vm_name |  Name of VM where to start tcpdump |
    ...     | gnb_id |  Id/Number of gNB |
    ...     | option |   Addtional options for tcpdump |
    ...     | interface |   Interface of gNB OAM for tcpdump |
    ...
    ...     *Returns* collector name
    ...
    ...     *Example:*
    ...
    ...     | # start tcpdump on upue
    ...     | Start TCPdump on gNB VM     vm_name=upue    option=-s 800   interface=fronthaul
    ...     | # Make some test
    ...     | Stop TCPdump on gNB VM     vm_name=upue    interface=fronthaul
    ...     | # Logs are stored in tc directory
    ...
    [Arguments]     ${vm_name}    ${interface}=fronthaul    ${gnb_id}=${0}    ${option}=${EMPTY}
    ...              ${collector}=gnb-${gnb_id}-${vm_name}-${interface}-tcpdump
    &{oam_ssh_config}=  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_ssh_config}=    Create dictionary
    ...         host=${vm_name}-0.local
    ...         user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}      # same as oam
    ...         password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}  # same as oam
    ...         proxy=${oam_ssh_config}
    ${collector}=    Set Variable    gnb-${gnb_id}-${vm_name}-${interface}-tcpdump
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${vm_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]    ${collector}


Stop TCPdump on gNB VM
    [Documentation]
    ...     Stop TcpDump on gNB VM on interface
    ...
    ...     | vm_name |  Name of VM where to start tcpdump |
    ...     | gnb_id |  Id/Number of gNB |
    ...     | interface |  Interface of gNB OAM for tcpdump |
    ...     | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]    ${vm_name}    ${interface}=fronthaul    ${gnb_id}=${0}   ${collector}=gnb-${gnb_id}-${vm_name}-${interface}-tcpdump
    ...    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Stop TCPDump
    [Documentation]
    ...     Stop any tpcdump collector
    ...
    ...     | collector |  Collector to be stop |
    ...     | target_dir |  Directory to store the pcap file |
    ...
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}==${EMPTY}
    ${target_dir}=  Run Keyword If  '${target_dir}'=='${EMPTY}'    testline.Get testcase log directory
    ...     ELSE  Set Variable  ${target_dir}
    ${tcpdump_filename}=  Run Keyword If  '${tcpdump_filename}'=='${EMPTY}'    testline.Get testcase log directory
    ...     ELSE  Set Variable  ${tcpdump_filename}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    OperatingSystem.Run
    ...     mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${tcpdump_filename}.pcap; rm -rf ${target_dir}/${collector}


Start Tcpdump on gNB Common Unit
    [Documentation]
    ...     Start Tcpdump on gNB Common Unit
    ...
    ...     | interface |  Name of the interface on the common unit where the tcpdump has to be taken |
    ...     | option |  any additional tcpdump options necessary as per user requirements |
    ...     | collector |  Custom name for the collector if necessary.  |
    ...     | gnb_id |  Id/Number of gNB |
    ...     | du_id |   Id/Number of DU |
    ...     | comu_id | Id/Number of Common Unit |
    ...     | node |    Common Unit master / slave |
    ...
    ...     *Returns* collector name
    ...
    [Arguments]     ${interface}  ${option}=${EMPTY}  ${collector}=common_unit-${interface}-tcpdump  ${gnb_id}=0  ${du_id}=0  ${comu_id}=0
    ...  ${node}=master

    Run Keyword if    '${node}'!='slave' and '${node}'!='master'    Fail    Node '${node}' is not supported!

    ${slave_host}=    Run Keyword IF     '${node}'=='slave'     testline.Get Common Unit Slave IP    gnb_id=${gnb_id}
    ...                      du_id=${du_id}    comu_id=${comu_id}

    Run Keyword If   '${slave_host}'=='${None}' and '${node}'=='slave'
    ...    FAIL    Cannot start tcpdump on Common Unit (unable to get the slaves ip address)!  


    ${executor}=   Run Keyword If   '${node}'=='slave'   connect_py.get_slave_connection_details_for_collector   ${tl}
    ...                      nodeb=${tl.gnbs[${gnb_id}]}   slave_ip=${slave_host}   du_id=${du_id}   cu_id=${comu_id}
    ...            ELSE IF   '${node}'=='master'         connect_py.get_lmp_connection_details_for_collector  ${tl}
    ...                      nodeb=${tl.gnbs[${gnb_id}]}   du_id=${du_id}   cu_id=${comu_id}
    ...            ELSE      Fail    "Error in Start Tcpdump on gNB Common Unit: the node must be 'slave' or 'master'"

    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${executor}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]    ${collector}


Start Tcpdump on AP Common Unit
    [Documentation]
    ...     Start Tcpdump on AP Common Unit
    ...
    ...     | interface |  Name of the interface on the common unit where the tcpdump has to be taken |
    ...     | option |  any additional tcpdump options necessary as per user requirements |
    ...     | collector |  Custom name for the collector if necessary.  |
    ...     | ue_id |   Id/Number of AP |
    ...     | comu_id | Id/Number of Common Unit |
    ...
    ...     *Returns* collector name
    ...

    [Arguments]     ${interface}  ${option}=${EMPTY}  ${collector}=common_unit-${interface}-tcpdump  ${ue_id}=0  ${comu_id}=0
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${common_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]    ${collector}


Stop Tcpdump on gNB Common Unit
    [Documentation]
    ...     Stop Tcpdump on gNB Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     | collector |    Custom name for the collector defined in 'Start Tcpdump on gNB Common Unit' |
    ...     | target_dir |   Custom directory location where the TCP Dump has to be stored. |
    ...     | tcpdump_filename |    Custom filename for the TCP Dump. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]    ${collector}    ${target_dir}=${EMPTY}    ${tcpdump_filename}=${EMPTY}
    ${tcpdump_file}=  Stop Tcpdump on Common Unit  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}
    [Return]  ${tcpdump_file}


Stop Tcpdump on AP Common Unit
    [Documentation]
    ...     Stop Tcpdump on AP Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     | collector |    Custom name for the collector defined in 'Start Tcpdump on AP Common Unit' |
    ...     | target_dir |   Custom directory location where the TCP Dump has to be stored. |
    ...     | tcpdump_filename |    Custom filename for the TCP Dump. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]    ${collector}    ${target_dir}=${EMPTY}    ${tcpdump_filename}=${EMPTY}
    ${tcpdump_file}=  Stop Tcpdump on Common Unit  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}
    [Return]  ${tcpdump_file}


Start L2_L3 SYSCOM Trace on ABIO
    [Documentation]
    ...     Start L2_L3 SYSCOM Trace on ABIO
    ...
    ...     | interface |  Name of the interface on the ABIO where the tcpdump has to be taken |
    ...     | collector |  Custom name for the collector if necessary. |
    ...     | gnb_id |   Id/Number of gNB |
    ...     | du_id |    Id/Number of DU |
    ...     | comu_id | Id/Number of Common Unit |
    ...     | capu_id |  Id/Number of Capacity Unit |
    ...
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${capu_id}=${0}  ${interface}=etha01.212  ${collector}=l2_l3_interface_trace
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ${host}=    testline.Get Capacity Slave IP    gnb_id=${gnb_id}   du_id=${du_id}    comu_id=${comu_id}
    ${slave_unit_ssh_config}=  Create Dictionary
    ...    host=${host}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...    proxy=${common_unit_ssh_config}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface}
    ...     executor=${slave_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}


Stop L2_L3 SYSCOM Trace on ABIO
    [Documentation]
    ...     Stop Tcpdump on ABIO
    ...
    ...     | collector |    Custom name for the collector defined in 'Start Tcpdump on gNB/AP Common Unit' |
    ...     | target_dir |   Custom directory location where the TCP Dump has to be stored.  |
    ...     | tcpdump_filename |    Custom filename for the TCP Dump.  |
    [Arguments]  ${collector}=l2_l3_interface_trace  ${target_dir}=${EMPTY}  ${tcpdump_filename}=l2_l3_tcpdump
    Stop TCPDump  collector=${collector}  target_dir=${target_dir}  tcpdump_filename=${tcpdump_filename}


Stop Tcpdump on Common Unit
    [Documentation]
    ...     Stops Tcpdump on gNB/AP Common Unit

    ...
    ...     | collector |    Custom name for the collector defined in 'Start Tcpdump on gNB/AP Common Unit' |
    ...     | target_dir |   Custom directory location where the TCP Dump has to be stored.  |
    ...     | tcpdump_filename |    Custom filename for the TCP Dump. |
    ...
    ...     *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}=${EMPTY}
    ${target_dir}=  Run Keyword If  '${target_dir}'=='${EMPTY}'    testline.Get testcase log directory
    ...     ELSE  Set Variable  ${target_dir}
    ${tcpdump_filename}=  Set Variable If  '${tcpdump_filename}'=='${EMPTY}'  ${collector}.pcap  ${tcpdump_filename}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    OperatingSystem.Run
    ...     command=mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${collector}/${tcpdump_filename}
    [Return]  ${target_dir}/${collector}/${tcpdump_filename}


Get xnap protocol version
    [Documentation]     
    ...
    ...    decodes the input file to pdml, searches for xnap protocol
    ...
    ...    *Returns* xnap protocol string
    ...
    ...   | tshark_file | input file for getting xnap protocol | 
    ...	  | return_value | xnap protocol version |
    ...
    [Arguments]    ${tshark_file}
    ${output}  ute_tshark.read pcap  output_type=pdml  pcap_file_path=${tshark_file}
    ${proto}   XML.Get Elements      ${output}         .//field[@name='frame.protocols']
    FOR  ${i}  IN   @{proto}
         ${showname}  XML.Get Element Attribute  ${i}  showname
         Exit For Loop If  'xnap' in "'${showname}'"
    END
    @{protocol_elements}    String.Split String From Right  ${showname}  :  1
    ${xnap_proto}           Set Variable                    ${protocol_elements}[-1]
    Should Contain          ${xnap_proto}  xnap
    [Return]  ${xnap_proto}

