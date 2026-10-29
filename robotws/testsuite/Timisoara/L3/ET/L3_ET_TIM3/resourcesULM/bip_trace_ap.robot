*** Settings ***
Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     taf.transport.ssh           WITH NAME   ssh
Library     python/tcpdump.py           WITH NAME   tcpdump_helper



*** Keywords ***
Start Airphone BIP Traces
    [Documentation]
    ...
    ...    Start Airphone BIP traces.
    ...
    ...    Enable port mirroring and start tcpdump (BIP traces) on capacity unit on interface ethbp1.
    ...
    ...    Command works for the following configurations: ASIK/ABIL.
    ...
    ...    When common unit is ASIK, then tcpdump starts in ASIK slave.
    ...
    ...    | ue_id |  Id/Number of UE |
    ...    | comu_id |   Id/Number of Common Unit |
    ...    | option |   any additional tcpdump options necessary as per user requirements |
    ...    | collector |   Name of collector *Impact on log filename* |
    ...    | syscom_mirroring |  To enable also syscom mirroring |
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${option}=${EMPTY}    ${collector}=ue-${ue_id}-bip-tcpdump
    ...    ${syscom_mirroring}=${False}
    Enable port mirroring for AP BIP traces    ue_id=${ue_id}    comu_id=${comu_id}    syscom_mirroring=${syscom_mirroring}
    ${interface}=    Get Airphone BIP trace capture interface    ue_id=${ue_id}    comu_id=${comu_id}
    ${common_unit_ssh_config}=  Create Dictionary
    ...    host=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.addr}
    ...    user=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.username}
    ...    password=${tl.ues[${ue_id}].l1.common_units[${comu_id}].lmp_connection.password}

    tcpdump.create_tcpdump_collector
    ...    name=${collector}
    ...    options=-i ${interface} ${option}
    ...    executor=${common_unit_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias    ${collector}
    BuiltIn.Log    \nUE${ue_id} BIP traces started successfully    console=${P_console}


Enable port mirroring for AP L1bypass BIP traces
    [Documentation]
    ...
    ...     *Scope*  Internal
    ... 
    ...    | ue_id |   Id/Number of UE |
    ...    | comu_id |  Id/Number of Common Unit |
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${comu_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.send_command    command=dbgrrc mirror sport 20 dport 3 e b && dbgrrc mirror sport 21 dport 3 e b && dbgrrc mirror sport 15 dport 3 e b
    ...   connection=${comu_alias}


Enable port mirroring for AP LOKI BIP Traces
    [Documentation]
    ...
    ...     *Scope*  Internal
    ... 
    [Arguments]    ${connection}
    ${slot}=    ssh.execute    command=chk sysversion | grep -i "slot-id" | cut -d " " -f8 | sed 's/.$//'    connection=${connection}
    ${slot_id} =    Convert To Integer  ${slot}
    ${vertical}=    Set Variable If    ${slot_id} < 4    ${1}    ${2}
    ${asil_commands}=   Get ABIN/O to ASIL Mirror Commands for Slot    slot=${slot_id}   vertical=${vertical}
    ssh.execute    command=${asil_commands}    connection=${connection}
    [Teardown]  ssh.disconnect  connection=${connection}


Get Airphone BIP trace capture interface
    [Documentation]         
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${comu_type}=    testline.Get Airphone Common Unit Type    ue_id=${ue_id}    comu_id=${comu_id}
    ${interface}=    Set variable If
    ...    "${comu_type}"=="ASIK"    etha01
    ...    "${comu_type}"=="ASIL"    nac_eth2
    [Return]    ${interface}


Stop Airphone BIP Traces
    [Documentation]
    ...
    ...    Logs are stored in Testcase Log directory by default
    ...
    ...    | ue_id |   Id/Number of UE |
    ...    | collector |   Name of collector like used in start command |
    ...    | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file incl. filename
    ...
    [Arguments]    ${ue_id}=${0}    ${collector}=ue-${ue_id}-bip-tcpdump    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    # TODO
    # disable Port mirroring
    # Port mirroring for AP BIP Traces   action=d
    BuiltIn.Log    \nUE${ue_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Start Airphone L1bypass BIP Traces
    [Documentation]
    ...    Start Airphone BIP traces.
    ...
    ...    Enable port mirroring and start tcpdump (BIP traces) on ASIK Slave on interface etha01.
    ...
    ...    Command works for the following configurations: ASIK/ABIL.
    ...
    ...    When common unit is ASIK, then tcpdump starts in ABIL slave.
    ...
    ...    The interface to get the BIP traces should be etha01 in ABIL slave.
    ...
    ...    | ue_id |   Id/Number of UE |
    ...    | comu_id | Id/Number of Common Unit |
    ...    | interface |  Interface of ASIK slave for tcpdump |
    ...    | option |   any additional tcpdump options necessary as per user requirements |
    ...    | collector |   Name of collector *Impact on log filename* |
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
    BuiltIn.Log    \nUE${ue_id} BIP traces started successfully    console=${P_console}


Stop Airphone L1bypass BIP Traces
    [Documentation]
    ...    Logs are stored in Testcase Log directory
    ...
    ...    | ue_id |  Id/Number of UE |
    ...    | interface |  Interface of ABIL slave for tcpdump |
    ...    | collector |  Name of collector *Impact on log filename* |
    ...    | target_dir | Directory to store the pcap file |
    ...
    ...     *Returns* bip_trace_path incl. filename
    ...
    [Arguments]    ${ue_id}=${0}    ${interface}=etha01    ${collector}=ue-${ue_id}-${interface}-bip-tcpdump    ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors    names=${collector}
    tcpdump.collect_collectors    names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors    names=${collector}
    BuiltIn.Log    \nUE${ue_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap


Enable port mirroring for AP BIP traces
    [Documentation]         
    ...
    ...     *Scope*  Internal
    ...
    ...    | ue_id |  Id/Number of UE |
    ...    | comu_id |  Id/Number of Common Unit |
    ...    | syscom_mirroring |  To enable also syscom mirroring |
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${syscom_mirroring}=${False}
    ${comu_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ${comu_type}=    testline.Get Airphone Common Unit Type    ue_id=${ue_id}    comu_id=${comu_id}
    Run Keyword if  '${comu_type}' == 'ASIK'
    ...    Enable port mirroring for AP ASIK BIP Traces    connection=${comu_alias}    syscom_mirroring=${syscom_mirroring}
    ...    ELSE    Enable port mirroring for AP LOKI BIP Traces    connection=${comu_alias}


Enable port mirroring for AP ASIK BIP Traces
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...   
    [Arguments]    ${connection}    ${syscom_mirroring}=${False}
    ssh.Upload File    local_path=${CURDIR}/bash/apMirroring.sh    remote_path=/tmp/apMirroring.sh    connection=${connection}
    ssh.Upload File    local_path=${CURDIR}/bash/apMirroringConfig.sh    remote_path=/tmp/apMirroringConfig.sh    connection=${connection}
    ssh.execute    command=chmod 750 /tmp/apMirroring*    connection=${connection}
    ${syscom}=    Set variable if    "${syscom_mirroring}"=="${True}"    --syscom_mirroring='true'    ${EMPTY}
    ssh.execute    command=cd /tmp/ ; ./apMirroring.sh ${syscom}    connection=${connection}


Get ABIN/O to ASIL Mirror Commands for Slot
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]    ${slot}    ${vertical}
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


Get Commands to Mirror Backplane Port for ASIL
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...    *Returns* the commands to mirror backplane port for ASIL
    ...
    [Arguments]     ${backplane_port}   ${slot}
    ${commands}=   Create List
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "${backplane_port}" -s ${slot} -v 303
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "${backplane_port}" -s ${slot} -v 304
    ...   /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "${backplane_port}" -s ${slot} -v 305
    ...   bcicmd -n 3msd -c "/dbg3ms/port 36 set learning 0 0 1"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan add 303 13 untagged"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan remove 303 21"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
    ...   bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"
    ...   dbgnac set port 2 speed 25000
    ...   dbgnac enable port 2
    ...   dbgnac set port 2 loop e t
    ...   dbgnac mirror sport 0 dport 2 e b
    ...   dbgnac mirror sport 2 dport 20 e b
    ...   /usr/bin/netd_uspace_lnk 2 1 25000 1
    ...   ifconfig nac_eth2 up
    ...   ifconfig nac_eth2 promisc

    [Return]   ${commands}
