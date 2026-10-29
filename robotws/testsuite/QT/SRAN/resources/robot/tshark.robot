*** Settings ***

Library  OperatingSystem
Library  ute_tshark

*** Keywords ***

Setup And Start Tshark On VM
    [Arguments]  ${vm_interface}  ${dir}=${OUTPUT_DIR}/L3_Call/TShark/
    Setup Tshark  interface=${vm_interface}  log_dir=${dir}  log_name=${Test NAME}_${vm_interface}_VM_side.pcap
    Start Capturing  #capture_filter=sctp

Stop Tshark On VM
    Stop Capturing
    [Teardown]  Teardown Tshark

Start Tcpdump On Enb
    [Documentation]
    ...  The keyword runs tcpdump on an eNB and collects a pcap file. It can be done using one of a three approaches.
    ...  1. VM interface is specified (eth\\d{1,2}). In this case the keyword maps VM interface on eNB interface,
    ...  for example VM S1 interface (eth2, 10.0.1.1) on eNB s1 interface (br0/br1 for AirScale, eth3 for FSMr3) or
    ...  VM LMP interface (eth1, 192.168.255.126) vs eNB LMP interface (ethlmp0 for AirScale, eth5 for FSMr3).
    ...  That approach is recommended for automation and collecting tcpdumps from LMP or S1 interfaces.
    ...  2. Dedicated eNB interface is specified (eg. ethlmp0, br1, rio0m0, etha01.219).
    ...  3. Collecting pcaps from all interfaces - use "any" value.
    [Arguments]  ${interface}  ${enb_dir}=/user/toor4nsn
    ${vm_eth_specified}=  Run Keyword And Return Status  Should Match Regexp  ${interface}  eth\\d{1,2}
    ${vm_interface_ip}=  Run Keyword If  '${vm_eth_specified}'=='True'  Run  ip addr show ${interface} | grep -oP "inet\\s[\\d.]+" | awk '{print $2}'
    ${enb_interface}=  Run Keyword If  '${vm_eth_specified}'=='True'  Execute Command On Enb  arp -an | grep ${vm_interface_ip} | awk '{print $NF}'
    ...  ELSE  Set Variable  ${interface}
    Set Suite Variable  ${tcpdump_enb_file}  ${enb_dir}/${Test NAME}_${enb_interface}_eNB_side.pcap
    Execute Command On Enb  tcpdump -i ${enb_interface} -w ${tcpdump_enb_file} > /dev/null 2>&1 &

Stop Tcpdump On Enb And Collect Pcap
    [Arguments]  ${interface}  ${vm_dir}=${OUTPUT_DIR}/L3_Call/TShark/  ${enb_dir}=/user/toor4nsn
#    Execute Command On Enb  ps -ef | grep ${enb_dir}/${Test NAME}_${interface}_eNB_side.pcap | grep -v grep | awk '{print $2}' | xargs kill
    Get Enb File  ${tcpdump_enb_file}  ${vm_dir}
    Execute Command On Enb  rm -rfv ${enb_dir}/${Test NAME}_${interface}_eNB_side.pcap

Start Tcpdump On Slave
    [Arguments]  ${interface}  ${enb_dir}=/user/toor4nsn
     Get Remote Host Information And Login  ${tl.host[2]}
#     SSHLibrary.Start Command
#    ...  sshpass -p oZPS0POrRieRtu ssh toor4nsn@${FSM_SLAVE_IP} tcpdump -i ${interface} -w ${enb_dir}/0x2011_${interface}.pcap > /dev/null 2>&1
#    Run Keyword If  ${syslog_processes[1]}==0  Kill Syslog On Remote Host
#    [Teardown]  SSHLibrary.Close Connection

Stop Tcpdump On Slave And Collect Pcap
    [Arguments]  ${interface}  ${vm_dir}=${OUTPUT_DIR}/L3_Call/TShark/  ${enb_dir}=/user/toor4nsn
    Get Remote Host Information And Login  ${tl.host[2]}
#    SSHLibrary.Execute Command  rm -rfv /tmp/0x2011_${interface}.pcap
#    SSHLibrary.Execute Command  sshpass -p oZPS0POrRieRtu scp toor4nsn@${FSM_SLAVE_IP}:${enb_dir}/0x2011_${interface}.pcap /tmp
#    SSHLibrary.Get File  /tmp/0x2011_${interface}.pcap  ${vm_dir}
#    SSHLibrary.Execute Command  sshpass -p oZPS0POrRieRtu ssh toor4nsn@${FSM_SLAVE_IP} rm -rfv ${enb_dir}/0x2011_${interface}.pcap
#    [Teardown]  SSHLibrary.Close Connection
