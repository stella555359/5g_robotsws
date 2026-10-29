*** Settings ***
Library    taf.transport.ssh


*** Keywords ***
Start_tcp_dump
    taf.transport.ssh.Connect To    192.168.255.129    toor4nsn    oZPS0POrRieRtu   alias=tcp
    ${output}=    taf.transport.ssh.Send Command    echo "tcpdump -i rlan0.ecpri -vvv -w tshark.pcap" | lxc-attach -n 0x1018    connection=tcp
    log    ${output}
#    ${contents}=    Execute    exit 1    connection=tcp
#    log	   ${contents}
   
Stop_tcp_dump
    taf.transport.ssh.Connect To    192.168.255.129    toor4nsn    oZPS0POrRieRtu   alias=tcp
    ${output}=    taf.transport.ssh.Execute    pkill -9 tcpdump    connection=tcp
    log    ${output}
    ${contents}=    taf.transport.ssh.Execute    exit 1    connection=tcp
    log	   ${contents
    

Collect_tcp_dump
    taf.transport.ssh.Connect To    192.168.255.129    toor4nsn    oZPS0POrRieRtu   alias=tcp
    ${output}=    taf.transport.ssh.Execute    cd /user/toor4nsn    connection=tcp
    log    ${output}
    taf.transport.ssh.Download File   /user/toor4nsn/tshark.pcap    /home/ute/TCP.pcap    connection=tcp
    ${contents}=    taf.transport.ssh.Execute    get tshark.pcap    connection=tcp
    log	   ${contents
    ${contents}=    taf.transport.ssh.Execute    exit 1    connection=tcp
    log	   ${contents}
