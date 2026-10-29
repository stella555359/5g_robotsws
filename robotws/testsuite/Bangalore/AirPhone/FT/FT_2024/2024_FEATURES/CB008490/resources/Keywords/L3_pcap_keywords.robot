*** Settings ***
Documentation   This library shall contain the keywords that are needed specifically for gnb related operation
Library      python_keywords.py
Library      String
Library      OperatingSystem
Library      DateTime
Library      Telnet
Library      XML    use_lxml=true
Library      Collections
Library      ta5g_admin_operations
Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark
Library      ta5g_tshark
Library      ute_wtssim
Library      ta5g_egate
Library      ta5g_commissioning
Library      taf.transport.ssh            WITH NAME    ssh
Library      ta5g_ue_mobility
Library      taf.hw.pdu
Library    Process

Variables       ta5g_global_var

*** Keywords ***
Start pcap collection in gNB
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0 -p    ${gnb_id}=0
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop pcap collection in gNB
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Start Tcpdump on wts
    [Arguments]    ${name}
    ${command}=     Set Variable    sudo tcpdump -i any -w ${name}.pcap > /dev/null 2>&1 &
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    [Return]       ${name}.pcap

Stop Tcpdump on wts
    [Arguments]    ${name}     ${Log_Path}
    ${command}=    Set Variable    sudo pkill tcpdump
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    Run      cp ${name}.pcap ${Log_Path}/${name}.pcap

