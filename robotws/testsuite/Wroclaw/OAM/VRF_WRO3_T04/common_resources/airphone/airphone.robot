*** Settings ***
Documentation   Keywords regarding setting airphone on on BTS

Library    SSHLibrary
Library    OperatingSystem
Resource        ../variables/variables_airphone.robot
*** Variables ***
${HOST}    127.0.0.1

*** Keywords ***

################ Main keywords ################
Add all required IP addresses for airphone

    _Add IP address to given interface     10.0.1.21     24     eth3
    _Add IP address to given interface     10.0.1.131    24     eth3
    _Add IP address to given interface     10.0.1.132    24     eth3
    _Add IP address to given interface     10.0.1.133    24     eth3
    _Add IP address to given interface     10.0.1.134    24     eth3
    _Add IP address to given interface     10.0.1.135    24     eth3
    _Add IP address to given interface     10.0.1.136    24     eth3
    _Add IP address to given interface     10.0.1.137    24     eth3

Install Configuration File
    [Arguments]    ${variant}
    ${VM_PASS}=    airphone._Get VM Password
    SSHLibrary.Open Connection   ${HOST}
    SSHLibrary.Login    ${VM_USERNAME}    ${VM_PASS}
    SSHLibrary.Write    source ~/test_repo/bin/activate
    Sleep    5
    SSHLibrary.Read Until    $
    SSHLibrary.Write    python3 /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/resources/airphone/scripts/create_aliases.py
    Sleep    60
    SSHLibrary.Read Until    $
    SSHLibrary.Write    source ~/.bashrc
    Sleep    5
    SSHLibrary.Read Until    $
    SSHLibrary.Write    egate
    Sleep    5
    SSHLibrary.Read Until    EGATE
    SSHLibrary.Write    cfg file=/home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/${variant}/basic.cfg
    Sleep    60
    SSHLibrary.Write    sim_start version_check=off
    SSHLibrary.Write    exit
    [Teardown]    Run Keyword And Ignore Error    Close Connection

Configure X2 Link
    [Arguments]    ${initiator_device}=1     ${complementary_device}=2
    ${VM_PASS}=    airphone._Get VM Password
    SSHLibrary.Open Connection   ${HOST}
    SSHLibrary.Login    ${VM_USERNAME}    ${VM_PASS}
    SSHLibrary.Write    egate
    Sleep    5
    SSHLibrary.Read Until    EGATE
    SSHLibrary.Write    enb_x2_link_up enb=${initiator_device} target=${complementary_device}
    Sleep    120
    SSHLibrary.Read Until    EGATE
    SSHLibrary.Write    sim_start version_check=off
    SSHLibrary.Write    exit
    [Teardown]    Run Keyword And Ignore Error    Close Connection
################ Additional keywords ################
_Add IP address to given interface
    [Arguments]    ${ip_address}    ${mask}    ${iface}
    ${VM_PASS}=    airphone._Get VM Password
    SSHLibrary.Open Connection   ${HOST}
    SSHLibrary.Login    ${VM_USERNAME}    ${VM_PASS}
    SSHLibrary.Write    sudo ip address add ${ip_address}/${mask} dev ${iface}
    [Teardown]    Run Keyword And Ignore Error    Close Connection

_Get VM Password
    ${vm_password}=    Run    sudo cat /etc/ute/vncpasswd
    [Return]           ${vm_password}
