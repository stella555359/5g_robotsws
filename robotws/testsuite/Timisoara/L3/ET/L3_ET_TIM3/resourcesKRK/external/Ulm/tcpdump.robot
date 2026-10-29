*** Settings ***

Documentation     Keywords for tcpdump

Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     taf.collectors.core         WITH NAME   core
Library     taf.transport.ssh           WITH NAME   ssh
Library     taf.collectors.l1l2bip      WITH NAME   l1l2bip
Library     ./python/tcpdump.py         WITH NAME   tcpdump_helper

Resource    ./testline.robot
Resource    ./connect.robot
Resource    ./gnb.robot

*** Keywords ***

Start TCPdump on all eNBs
    [Documentation]    :Author: Vasileios Papoutsis
    ${enb_num}=     Get length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Start TCPdump on eNB     enb_id=${enb_id}
    END

Start TCPdump on eNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Start tcpdump on eNB common unit on interface brl
    ...
    [Arguments]    ${enb_id}=${0}
    ${oam_ssh_config}=  Create Dictionary
    ...     host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...     user=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.username}
    ...     password=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.password}
    tcpdump.create_tcpdump_collector
    ...     name=enb${enb_id}_s1x2_tcpdump
    ...     options=-i br1 -s0 sctp or icmp
    ...     executor=${oam_ssh_config}
    tcpdump.setup_collectors    names=enb${enb_id}_s1x2_tcpdump
    tcpdump.start_collectors    names=enb${enb_id}_s1x2_tcpdump
    tcpdump.set_suite_alias     enb${enb_id}_s1x2_tcpdump
    [Return]  enb${enb_id}_s1x2_tcpdump


Stop TCPdump on all eNBs
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${target_dir}=None
    ${enb_num}=     Get length     ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${0}    ${enb_num}
       Stop TCPdump on eNB     enb_id=${enb_id}    target_dir=${target_dir}
    END

Stop TCPdump on eNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop tcpdump on eNB and store logs in Log directory
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump_path: Path to tcpdump pcap file
    ...
    [Arguments]    ${enb_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=enb${enb_id}_s1x2_tcpdump
    tcpdump.collect_collectors      names=enb${enb_id}_s1x2_tcpdump   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=enb${enb_id}_s1x2_tcpdump
    [RETURN]    ${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap


Start Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Tcpdump on test PC
    ...
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector **Impact on log filename**
    ...
    ...     **Example:**
    ...
    ...         | Start Tcpdump on TestPc     interface=eth0
    ...         | BuiltIn.Sleep     10 sec
    ...         | Stop Tcpdump on TestPc     interface=eth0
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
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} started successfully    console=${P_console}
    [RETURN]    ${collector}


Stop Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop tcpdump on testpc
    ...     Logs are storred in Testcase Log directory
    ...
    ...     :param interface: (default=fronthaul) Interface for tcpdump
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump-file: Path to tcpdump file
    ...
    [Arguments]     ${interface}  ${collector}=testpc-${interface}-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start BIP Traces
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start gNB BIP traces.
    ...    Enable port mirroring and start tcpdump (BIP traces) on common unit.
    ...    Command works for the following configurations: ASOD, ASOE, ASIK/ABIL, ASIL/ABIL, ASIB/ABIL, ASIB/ABIO, ASIL/ABIO.
    ...    More details can be found in https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=CV&title=gNB+Mirroring.
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...    :param capu_id: (default=0) Id/Number of Capacity Unit
    ...    :param option: (default=${EMPTY}) Any additional tcpdump options necessary as per user requirements
    ...    :param collector: (default=gnb-${gnb_id}-${interface}-bip-tcpdump) Name of collector *Impact on log filename*
    ...    :param carrier_aggregation: (default=${FALSE}) To enable mirroring for carrier aggregation
    ...    :param syscom_mirroring: (default=${FALSE}) To enable also syscom mirroring
    ...
    [Arguments]    ${gnb_id}=${0}
    ...            ${du_id}=${0}
    ...            ${comu_id}=${0}
    ...            ${capu_id}=${0}
    ...            ${option}=${EMPTY}
    ...            ${collector}=gnb-${gnb_id}-bip-tcpdump
    ...            ${carrier_aggregation}=${False}
    ...            ${syscom_mirroring}=${False}
    ${capu_type}=    testline.Identify Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    ...    capu_id=${capu_id}
    testline.Get Common Unit Type
    Enable Port Mirroring  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  capu_id=${capu_id}  carrier_aggregation=${carrier_aggregation}
    ...  syscom_mirroring=${syscom_mirroring}
    ${interface}=    Get BIP trace capture interface    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}  capu_type=${capu_type}
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    tcpdump.create_tcpdump_collector
    ...    name=${collector}
    ...    options=-i ${interface} ${option}
    ...    executor=${common_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias    ${collector}
    BuiltIn.Log    gNB${gnb_id} BIP traces started successfully    console=${P_console}


Stop BIP Traces
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Logs are stored in Testcase Log directory
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param collector: (default gnb-${gnb_id}-${interface}-bip-tcpdump) Name of collector *Impact on log filename*
    ...    :param target_dir: Directory to store the pcap file
    ...
    ...    :return bip_trace_path: Path to pcap file
    ...
    [Arguments]    ${gnb_id}=${0}    ${collector}=gnb-${gnb_id}-bip-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    # TODO
    # disable Port mirroring
    # Port mirroring for BIP Traces   action=d
    BuiltIn.Log    gNB${gnb_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start Airphone BIP Traces
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start Airphone BIP traces.
    ...    Enable port mirroring and start tcpdump (BIP traces) on capacity unit on interface ethbp1.
    ...    Command works for the following configurations: ASIK/ABIL.
    ...    When common unit is ASIK, then tcpdump starts in ASIK slave.
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...    :param option: (default=${EMPTY}) any additional tcpdump options necessary as per user requirements
    ...    :param collector: (default ue-${ue_id}-bip-tcpdump) Name of collector *Impact on log filename*
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${option}=${EMPTY}    ${collector}=ue-${ue_id}-bip-tcpdump
    Enable port mirroring for AP BIP traces    ue_id=${ue_id}    comu_id=${comu_id}
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    ${slave_unit_ssh_config}=  Create Dictionary
    ...    host=192.168.253.81
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    ...    proxy=${common_unit_ssh_config}
    tcpdump.create_tcpdump_collector
    ...    name=${collector}
    ...    options=-i pepbp1 ${option}
    ...    executor=${slave_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias    ${collector}
    BuiltIn.Log    UE${ue_id} BIP traces started successfully    console=${P_console}


Stop Airphone BIP Traces
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Logs are stored in Testcase Log directory
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param collector: (default ue-${ue_id}-bip-tcpdump) Name of collector *Impact on log filename*
    ...    :param target_dir: Directory to store the pcap file
    ...
    ...    :return bip_trace_path: Path to pcap file
    ...
    [Arguments]    ${ue_id}=${0}    ${collector}=ue-${ue_id}-bip-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    # TODO
    # disable Port mirroring
    # Port mirroring for AP BIP Traces   action=d
    BuiltIn.Log    UE${ue_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start Airphone L1bypass BIP Traces
    [Documentation]    :Author: Jing Liang
    ...    Start Airphone BIP traces.
    ...    Enable port mirroring and start tcpdump (BIP traces) on ASIK Slave on interface etha01.
    ...    Command works for the following configurations: ASIK/ABIL.
    ...    When common unit is ASIK, then tcpdump starts in ABIL slave.
    ...    The interface to get the BIP traces should be etha01 in ABIL slave.
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...    :param interface: (default=etha01) Interface of ASIK slave for tcpdump
    ...    :param option: (default=${EMPTY}) any additional tcpdump options necessary as per user requirements
    ...    :param collector: (default ue-${ue_id}-${interface}-bip-tcpdump) Name of collector *Impact on log filename*
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${interface}=etha01    ${option}=${EMPTY}
    ...    ${collector}=ue-${ue_id}-${interface}-bip-tcpdump
    Enable port mirroring for AP L1bypass BIP traces    ue_id=${ue_id}    comu_id=${comu_id}
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    ${slave_unit_ssh_config}=  Create Dictionary
    ...    host=192.168.253.81
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}
    ...    proxy=${common_unit_ssh_config}
    tcpdump.create_tcpdump_collector
    ...    name=${collector}
    ...    options=-i ${interface} ${option}
    ...    executor=${slave_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias    ${collector}
    BuiltIn.Log    UE${ue_id} BIP traces started successfully    console=${P_console}


Stop Airphone L1bypass BIP Traces
    [Documentation]    :Author: Jing Liang
    ...    Logs are stored in Testcase Log directory
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param interface: (default=etha01) Interface of ABIL slave for tcpdump
    ...    :param collector: (default ue-${ue_id}-${interface}-bip-tcpdump) Name of collector *Impact on log filename*
    ...    :param target_dir: Directory to store the pcap file
    ...
    ...    :return bip_trace_path: Path to pcap file
    ...
    [Arguments]    ${ue_id}=${0}    ${interface}=etha01    ${collector}=ue-${ue_id}-${interface}-bip-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    BuiltIn.Log    UE${ue_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start TCPdump on gNB OAM VM
    [Documentation]    :Author: Soenke Kullberg
    ...     Starts TcpDump on gNB OAM on interface (default=fronthaul)
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface of gNB OAM for tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector *Impact on log filename*
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
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop TcpDump on gNB OAM on interface (default=fronthaul)
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param interface: (default=fronthaul) Interface of gNB OAM for tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)
    ...                          Name of collector *Must be same as in 'Start TCPdump on gNB OAM VM'*
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump_path: Path to pcap file of tcpdump
    ...
    [Arguments]     ${gnb_id}=${0}    ${interface}=fronthaul    ${collector}=gnb-${gnb_id}-oam-${interface}-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start TCPdump on gNB VM
    [Documentation]    :Author: Soenke Kullberg
    ...     Starts TcpDump on gNB VM on interface
    ...
    ...     :param vm_name: Name of VM where to start tcpdump
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface of gNB OAM for tcpdump
    ...
    ...     **Example:**
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
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop TcpDump on gNB VM on interface
    ...
    ...     :param vm_name: Name of VM where to start tcpdump
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param interface: (default=fronthaul) Interface of gNB OAM for tcpdump
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump_path: Path to pcap file of tcpdump
    ...
    [Arguments]    ${vm_name}    ${interface}=fronthaul    ${gnb_id}=${0}   ${collector}=gnb-${gnb_id}-${vm_name}-${interface}-tcpdump
    ...    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Stop TCPDump
    [Documentation]  :Author: Srihari Janardhan
    ...     Stop any tpcdump colllector
    ...
    ...     :param collector: Collector to be stop
    ...     :param target_dir: Directory to store the pcap file
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}==${EMPTY}
    ${target_dir}=  Run Keyword If  '${target_dir}'=='${EMPTY}'    Get testcase log directory
    ...     ELSE  Set Variable  ${target_dir}
    ${tcpdump_filename}=  Run Keyword If  '${tcpdump_filename}'=='${EMPTY}'    Get testcase log directory
    ...     ELSE  Set Variable  ${tcpdump_filename}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    ${connection_testpc}=  connect.Connect to TestPC
    ssh.execute
    ...     command=mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${tcpdump_filename}.pcap; rm -rf ${target_dir}/${collector}
    ...     connection=${connection_testpc}
    [Teardown]  ssh.disconnect  connection=${connection_testpc}


Start Tcpdump on gNB Common Unit
    [Documentation]  :Author: Srihari Janardhan
    ...     Start Tcpdump on gNB Common Unit
    ...
    ...     :param interface: Name of the interface on the common unit where the tcpdump has to be taken
    ...     :param option: any additional tcpdump options necessary as per user requirements
    ...     :param collector: Custom name for the collector if necessary. Default : common_unit-${interface}-tcpdump
    ...     :param gnb_id:  (default=0) Id/Number of gNB
    ...     :param du_id:   (default=0) Id/Number of DU
    ...     :param comu_id: (default=0) Id/Number of Common Unit
    ...     :param node:  (default=master) Common Unit master / slave
    [Arguments]     ${interface}  ${option}=${EMPTY}  ${collector}=common_unit-${interface}-tcpdump  ${gnb_id}=0  ${du_id}=0  ${comu_id}=0
    ...  ${node}=master
    ${common_unit_ssh_config}=  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...     user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...     password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ${common_unit_slave_ip}=    testline.Get Common Unit Slave IP    gnb_id=${gnb_id}   du_id=${du_id}    comu_id=${comu_id}
    ${common_unit_slave_ssh_config}=  Create Dictionary
    ...    host=${common_unit_slave_ip}
    ...    user=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...    proxy=${common_unit_ssh_config}
    ${executor}=  Set variable if  '${node}'=='slave'  ${common_unit_slave_ssh_config}  ${common_unit_ssh_config}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${executor}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]    ${collector}


Stop Tcpdump on gNB Common Unit
    [Documentation]  :Author: Srihari Janardhan
    ...     Stop Tcpdump on gNB Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     :param collector:   Custom name for the collector defined in 'Start Tcpdump on gNB Common Unit'
    ...     :param target_dir:  Custom directory location where the TCP Dump has to be stored. Default - Stored in Test case log directory
    ...     :param tcpdump_filename:   Custom filename for the TCP Dump. Default - 'userdefined_collectorname.pcap'
    ...
    [Arguments]  ${collector}  ${target_dir}=${EMPTY}  ${tcpdump_filename}=${EMPTY}
    ${target_dir}=  Run Keyword If  '${target_dir}'=='${EMPTY}'    Get testcase log directory
    ...     ELSE  Set Variable  ${target_dir}
    ${tcpdump_filename}=  Set Variable If  '${tcpdump_filename}'=='${EMPTY}'  ${collector}.pcap  ${tcpdump_filename}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    ${connection_testpc}=  connect.Connect to TestPC
    ssh.execute
    ...     command=mv ${target_dir}/${collector}/${collector}.pcap ${target_dir}/${tcpdump_filename}; rm -rf ${target_dir}/${collector}
    ...     connection=${connection_testpc}
    [Return]  ${target_dir}/${tcpdump_filename}
    [Teardown]  ssh.disconnect  connection=${connection_testpc}


Start Tcpdump on AP Common Unit
    [Documentation]  :Author: Vasileios Papoutsis
    ...     Start Tcpdump on AP Common Unit
    ...
    ...     :param interface: Name of the interface on the common unit where the tcpdump has to be taken
    ...     :param option: any additional tcpdump options necessary as per user requirements
    ...     :param collector: Custom name for the collector if necessary. Default : common_unit-${interface}-tcpdump
    ...     :param ue_id:  (default=0) Id/Number of AP
    ...     :param comu_id: (default=0) Id/Number of Common Unit
    ...     :param node:  (default=master) Common Unit master / slave
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


Stop Tcpdump on AP Common Unit
    [Documentation]  :Author: Vasileios Papoutsis
    ...     Stop Tcpdump on AP Common Unit
    ...     Returns the path of the captured tcpdump
    ...
    ...     :param collector:   Custom name for the collector defined in 'Start Tcpdump on AP Common Unit'
    ...     :param target_dir:  Custom directory location where the TCP Dump has to be stored. Default - Stored in Test case log directory
    ...     :param tcpdump_filename:   Custom filename for the TCP Dump. Default - 'userdefined_collectorname.pcap'
    ...
    [Arguments]    ${collector}    ${target_dir}=${EMPTY}    ${tcpdump_filename}=${EMPTY}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${EMPTY}'    Get testcase log directory
    ...    ELSE  Set Variable  ${target_dir}
    ${tcpdump_filename}=    Set Variable If    '${tcpdump_filename}'=='${EMPTY}'    ${collector}.pcap    ${tcpdump_filename}
    tcpdump.stop_collectors        names=${collector}
    tcpdump.collect_collectors     names=${collector}    target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    [Return]  ${target_dir}/${tcpdump_filename}


### Private ###
Enable port mirroring for gNB BIP traces
    [Documentation]     [PRIVATE]
    ...    :Author: Vasileios Papoutsis
    ...
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param du_id: (default=0) Id/Number of DU
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...    :param capu_id: (default=0) Id/Number of Capacity Unit
    ...    :param carrier_aggregation: (default=${FALSE}) Set to true if carrier aggregation is enabled
    ...    :param syscom_mirroring: (default=${FALSE}) To enable also syscom mirroring
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${capu_id}=${0}    ${carrier_aggregation}=${False}
    ...    ${syscom_mirroring}=${False}
    ${comu_alias}=    Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.Upload File    local_path=${CURDIR}/bash/gnbMirroring.sh    remote_path=/tmp/gnbMirroring.sh    connection=${comu_alias}
    ssh.Upload File    local_path=${CURDIR}/bash/gnbMirroringConfig.sh    remote_path=/tmp/gnbMirroringConfig.sh    connection=${comu_alias}
    ssh.execute    command=chmod 750 /tmp/gnbMirroring*    connection=${comu_alias}
    ${mirror_abil_2}    ${mirror_abil_3}=    Run keyword if    "${carrier_aggregation}"=="${False}"    Mirror all available capacity units
    ...    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ...    ELSE    Set variable    ${EMPTY}    ${EMPTY}
    ${ca}=    Set variable if    "${carrier_aggregation}"=="${True}"    --carrier_aggregation='true'    ${EMPTY}
    ${syscom}=    Set variable if    "${syscom_mirroring}"=="${True}"    --syscom_mirroring='true'    ${EMPTY}
    ${capu_type}=    testline.Identify Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    ...    capu_id=${capu_id}
    ${bb_board_type}=    Set variable if    "${capu_type}"=="ABIO"    --bb_board_type='ABIO'    --bb_board_type='ABIL'
    ssh.execute    command=cd /tmp/ ; ./gnbMirroring.sh ${ca} ${syscom} ${mirror_abil_2} ${mirror_abil_3} ${bb_board_type}
    ...    connection=${comu_alias}


Mirror all available capacity units
    [Documentation]     [PRIVATE]
    ...    :Author: Vasileios Papoutsis
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    ${capacity_units_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    ${mirror_abil_2}=    Set variable if    "${capacity_units_num}"=="${2}"    --mirror_abil_2 true    ${EMPTY}
    ${mirror_abil_3}=    Set variable if    "${capacity_units_num}"=="${3}"    --mirror_abil_3 true    ${EMPTY}
    [Return]    ${mirror_abil_2}    ${mirror_abil_3}


Enable port mirroring for AP BIP traces
    [Documentation]     [PRIVATE]
    ...    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${comu_alias}=    Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.Upload File    local_path=${CURDIR}/bash/apMirroring.sh    remote_path=/tmp/apMirroring.sh    connection=${comu_alias}
    ssh.send_command    command=chmod 750 /tmp/apMirroring.sh    connection=${comu_alias}
    ssh.send_command    command=cd /tmp/ ; ./apMirroring.sh    connection=${comu_alias}


Enable port mirroring for AP L1bypass BIP traces
    [Documentation]     [PRIVATE]
    ...    :Author: Jing Liang
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :param comu_id: (default=0) Id/Number of Common Unit
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${comu_alias}=    Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.send_command    command=dbgrrc mirror sport 20 dport 3 e b && dbgrrc mirror sport 21 dport 3 e b && dbgrrc mirror sport 15 dport 3 e b
    ...   connection=${comu_alias}


Get BIP trace capture interface
    [Documentation]     [PRIVATE]
    ...    :Author: Vasileios Papoutsis
    ...
    [Arguments]    ${capu_type}  ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}
    ${comu_type}=    testline.Identify Common Unit Type    gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    ${interface}=    Set variable if
    ...    "${comu_type}"=="ASIK"    pepbp1
    ...    "${comu_type}"=="ASOD"    pepbp1
    ...    "${comu_type}"=="ASIL" and '${capu_type}'=='ABIO'    etha01
    ...    "${comu_type}"=="ASIL" and '${capu_type}'!='ABIO'    eth1
    ...    "${comu_type}"=="ASIB" and '${capu_type}'=='ABIL'    eths2
    ...    "${comu_type}"=="ASIB" and '${capu_type}'=='ABIO'    eths3
    [Return]    ${interface}

# not ready
#Check Dropped Packets on Test PC Interface
#    [Documentation]     [PRIVATE]
#    ...     :Author: Soenke Kullberg
#    ...     KW not usabel at the moment
#    [Arguments]     ${IF}=eth2       ${max_dropped}=2
#    ${testpc_alias}=    connect.Connect to TestPC
#    ${rx_packet}   ssh.execute     command=/sbin/ifconfig ${IF} |grep "RX packets" | tr ":" " " | awk '{print $3}'     connection=${testpc_alias}
#    ${dropped_rx}   ssh.execute     command=/sbin/ifconfig ${IF} |grep "RX packets" | tr ":" " " | awk '{print $7}'     connection=${testpc_alias}
#    ${dropped_rx}=   Convert To Integer     ${dropped_rx}
#    BuiltIn.Log     Received Packets: ${rx_packet} Dropped Packets: ${dropped_rx}
#    Should be True      ${dropped_rx}<${max_dropped}

# probably useless keywork
Start TCPdumps on all gNBs
    [Documentation]     [PRIVATE]   :Author: Vasileios Papoutsis
    ${gnb_num}=     Get length     ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${0}    ${gnb_num}
       Start TCPdumps on gNB     gnb_id=${gnb_id}
    END

Start TCPdumps on gNB
    [Documentation]     [PRIVATE]   :Author: Soenke Kullberg
    ...     Starts TcpDumps on
    ...     gNB OAM interfaces: fronthaul,internal,internal_srv
    ...     on gNB VMs on interfaces: internal,internal_srv
    ...     on gNB upue+cpif on interface: backhaul,fronthaul
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]     ${gnb_id}=0
    ${gnb_type}=    Get gNB type    gnb_id=${gnb_id}
    Run Keyword if      '${gnb_type}'!='cloud'      Fail    msg=works only on cloud
    Start TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=fronthaul
    Start TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=internal
    Start TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=internal_srv
    @{vmList}=      Get gNB VM list     gnb_id=${gnb_id}
    FOR    ${vm}   IN  @{vmList}
       Start TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=internal
       Start TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=internal_srv
    END
    FOR    ${vm}   IN          upue    cpif
       Start TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=backhaul
       Start TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=fronthaul
    END

Stop TCPdumps on all gNBs
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${target_dir}=None
    ${gnb_num}=     Get length     ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${0}    ${gnb_num}
       Stop TCPdumps on gNB     gnb_id=${gnb_id}    target_dir=${target_dir}
    END

Stop TCPdumps on gNB
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop TcpDumps and store logs in log Directory
    ...     gNB OAM interfaces: fronthaul,internal,internal_srv
    ...     on gNB VMs on interfaces: internal,internal_srv
    ...     on gNB upue+cpif on interface: backhaul,fronthaul
    ...
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]     ${gnb_id}=0    ${target_dir}=None
    ${gnb_type}=    Get gNB type    gnb_id=${gnb_id}
    Run Keyword if      '${gnb_type}'!='cloud'      Fail    msg=works only on cloud
    Stop TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=fronthaul    target_dir=${target_dir}
    Stop TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=internal    target_dir=${target_dir}
    Stop TCPdump on gNB OAM VM     gnb_id=${gnb_id}      interface=internal_srv    target_dir=${target_dir}
    @{vmList}=      Get gNB VM list     gnb_id=${gnb_id}
    FOR    ${vm}   IN  @{vmList}
       Stop TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=internal    target_dir=${target_dir}
       Stop TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=internal_srv    target_dir=${target_dir}
    END
    FOR    ${vm}   IN          upue    cpif
       Stop TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=backhaul    target_dir=${target_dir}
       Stop TCPdump on gNB VM     gnb_id=${gnb_id}  vm_name=${vm}   interface=fronthaul    target_dir=${target_dir}
    END


Get Slot Of Baseband Module
    [Documentation]     [PRIVATE]
    ...    :Author: Srihari Janardhan
    ...
    ${oam_alias}=    connect.Setup OAM session
    ${bts_info}=    admin.Get Bts Info    connection=${oam_alias}
    ${baseband_module_distname}=    Set Variable    ${bts_info['basebandModules'][0]['id']['internal']}
    ${fbb_info}=    admin.get parameters   dist_name=${baseband_module_distname}    connection=${oam_alias}
    ${horizontalPosition}=  Set Variable  ${fbb_info['horizontalPosition']}
    ${verticalPosition}=    Set Variable  ${fbb_info['verticalPosition']}
    ${productName}=     Split String   ${fbb_info['productName']}
    ${product}=     Set Variable   ${productName[0]}
    Log    Product is ${product}   console=True

    ${slot}=               Evaluate   (${horizontalPosition}-1)*4 + (${verticalPosition} - 1)
    ${slot_board_mapping}=   Create Dictionary    ${slot}    ${product}
    [Return]  ${slot}   ${verticalPosition}
    [Teardown]    Teardown OAM session    connection=${oam_alias}


Get Commands to Mirror Backplane Port
    [Documentation]     [PRIVATE]
    ...    :Author: Srihari Janardhan
    ...    Returns list of commands to mirror backplane port
    ...
    ...    :param slot: Slot id of baseband module
    ...    :param backplane_port: back plane port
    ...
    [Arguments]     ${backplane_port}   ${slot}
    ${port1}    ${port2}=    Get Port Numbers according to Slot ID    ${slot}
    ${commands}=   Create List
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "${backplane_port}" -s ${slot} -l eths3 -v 303
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "${backplane_port}" -s ${slot} -l eths3 -v 304
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "${backplane_port}" -s ${slot} -l eths3 -v 305
    ...   echo 3 both > /var/run/cpss/ports/${port1}/mirroring_port
    ...   echo 3 both > /var/run/cpss/ports/${port2}/mirroring_port
    ...   ncp_portmirror -p xgmac96 -r
    ...   ncp_portmirror -d netdriver -p xgmac96
    ...   ncp_l2 -p XGMAC96 -I -senableSwitching.false
    ...   ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
    ...   ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
    [Return]   ${commands}

Get Port Numbers according to Slot ID
    [Documentation]     [PRIVATE]
    ...    :Author: Jeissel Flores
    ...    Returns the corresponding mirroring port numbers 
    ...    according to the input slot ID of baseband module
    ...
    ...    :param slot: Slot id of baseband module
    ...
    [Arguments]     ${slot}
    ${port1}=    Set Variable If
    ...    '${slot}' == '1' or '${slot}' == '5'    ${5}
    ...    '${slot}' == '2' or '${slot}' == '6'    ${9}
    ...    '${slot}' == '3' or '${slot}' == '7'    ${13}
    
    ${port2}=    Set Variable   ${port1+1}
    [Return]    ${port1}    ${port2}

Get Commands to Mirror Backplane Port for ASIL
    [Arguments]     ${backplane_port}   ${slot}
    ${commands}=   Create List
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "${backplane_port}" -s ${slot} -v 303
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "${backplane_port}" -s ${slot} -v 304
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "${backplane_port}" -s ${slot} -v 305
    ...   CPRT_L2RT	bcicmd -n 3msd -c '/dbg3ms/mirror set 35 21 both'
    [Return]   ${commands}


Get ABIO to ASIB Mirror Commands for Slot
    [Documentation]     [PRIVATE]
    ...    :Author: Srihari Janardhan
    ...
    ${slot}   ${vertical}=   Get Slot Of Baseband Module
    &{port_backplane_map}=   Create Dictionary    1   C${vertical}B1(2)
    ...                                           2   C${vertical}B2(2)
    ...                                           3   C${vertical}B3(2)
    ...                                           5   C${vertical}B4(2)
    ...                                           6   C${vertical}B5(2)
    ...                                           7   C${vertical}B6(2)
    Log Dictionary   ${port_backplane_map}
    ${commands}=    Get Commands to Mirror Backplane Port   ${port_backplane_map['${slot}']}   ${slot}
    ${command_str}=  tcpdump_helper.generate_command  list_of_commands=${commands}
    [Return]    ${command_str}


Get ABIO to ASIL Mirror Commands for Slot
    ${slot}   ${vertical}=   Get Slot Of Baseband Module
    &{port_backplane_map}=   Create Dictionary    1   C${vertical}B1(6)
    ...                                           2   C${vertical}B2(6)
    ...                                           3   C${vertical}B3(6)
    ...                                           5   C${vertical}B4(6)
    ...                                           6   C${vertical}B5(6)
    ...                                           7   C${vertical}B6(6)
    Log Dictionary   ${port_backplane_map}
    ${commands}=    Get Commands to Mirror Backplane Port for ASIL  ${port_backplane_map['${slot}']}   ${slot}
    ${command_str}=  tcpdump_helper.generate_command  list_of_commands=${commands}
    [Return]    ${command_str}


Stop Bip Trace on ABIO
    [Arguments]    ${collector}  ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}


Run ABIO Mirroring script
    [Arguments]  ${cmd_string}  ${gnb_id}  ${du_id}  ${comu_id}
    ${comu_alias}=    Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.execute    command=${cmd_string}    connection=${comu_alias}
    [Teardown]  ssh.disconnect  connection=${comu_alias}


Enable Port Mirroring
    [Arguments]  ${gnb_id}  ${du_id}  ${comu_id}  ${capu_id}  ${carrier_aggregation}  ${syscom_mirroring}
    ${capu_type}=    testline.Identify Capacity Unit Type   gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    ${comu_type}=    testline.Identify Common Unit Type     gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    Run Keyword if  '${capu_type}' == 'ABIO' and '${comu_type}' == 'ASIL'
    ...    Run Port Mirroring script on ASIL for ABIO BIP Mirroring
    ...    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    Run Keyword if  '${capu_type}' == 'ABIO' and '${comu_type}' != 'ASIL'
    ...    Run Port Mirroring script on ASIB for ABIO BIP Mirroring
    ...    gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    Run Keyword if  '${capu_type}' == 'ABIL'  Enable port mirroring for gNB BIP traces    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ...    capu_id=${capu_id}  carrier_aggregation=${carrier_aggregation}    syscom_mirroring=${syscom_mirroring}


Run Port Mirroring script on ASIB for ABIO BIP Mirroring
    [Arguments]  ${gnb_id}  ${du_id}  ${comu_id}
    ${asib_commands}=   Get ABIO to ASIB Mirror Commands for Slot
    Run ABIO Mirroring script  cmd_string=${asib_commands}  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}


Run Port Mirroring script on ASIL for ABIO BIP Mirroring
    [Arguments]  ${gnb_id}  ${du_id}  ${comu_id}
    ${asil_commands}=   Get ABIO to ASIL Mirror Commands for Slot
    Run ABIO Mirroring script  cmd_string=${asil_commands}  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
