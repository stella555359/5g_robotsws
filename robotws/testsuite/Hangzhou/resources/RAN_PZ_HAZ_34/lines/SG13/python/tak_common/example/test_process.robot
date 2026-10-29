*** Settings ***
Resource     ../../../robot/common_resource.robot

*** Test Cases ***
test
    ${remote info}    Create Dictionary      host=192.168.255.1    user=toor4nsn     password=oZPS0POrRieRtu 
    ${ap info}    Create Dictionary      host=192.168.200.1    user=toor4nsn     password=oZPS0POrRieRtu
    nohup_bg_start_process     tcpdump -w /tmp/cellsetup.pcap -i any -C 50M       ${remote info}   alias=enb
    nohup_bg_start_process     tcpdump -w /tmp/ap.pcap -i any -C 50M       ${ap info}   alias=ap
    nohup_bg_start_process     tshark -w ${CURDIR}/pc.pcap -i any           alias=pc
    sleep     2
    nohup_bg_stop_process    ${CURDIR}   alias=enb
    nohup_bg_stop_process    ${CURDIR}/logs/  alias=ap
    nohup_bg_stop_process       alias=pc


    Start Tcpdump      enb2      tcpdump -w /tmp/cellsetup.pcap -i any -C 50M       ${remote info} 
    Start Tcpdump      pc2      tshark -w ${CURDIR}/pcs.pcap -i any        
    sleep   2
    Stop Tcpdump       enb2     ${CURDIR}
    Stop Tcpdump       pc2     ${CURDIR}

test ping
    ${remote info}    Create Dictionary      host=127.0.0.1         user=ute           password=ute
    nohup_bg_start_process    ping 192.168.255.1 -s 128       ${remote info}   alias=iperf
    sleep    3
    nohup_bg_stop_process    alias=iperf
