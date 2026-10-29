*** Settings ***
Documentation      This file contains keywords related to setup of EPCSim.

Library    OperatingSystem
Library    String
Library    taf.transport.ssh   WITH NAME    ssh
Library    ta_emss
Library    Telnet

*** Keywords ***
Get EMSSim JSON Port From Local User
    [Arguments]         ${emssim_user}
    ${file}=       Set Variable    /home/${emssim_user}/start
    ${content}=    OperatingSystem.Get File    ${file}
    ${port}=    Get Regexp Matches    ${content}    JSON_PORT\\s*(\\d+)    1

    [return]    ${port[0]}

Prepare gNB EMSSim Setup
    [Documentation]  This keyword is to prepare emssim env and start emssim.
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ...                 ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 ${json_port}=${0}

    ${macrouser}=        Set Variable    macro${bts_id}
    Run    sudo /opt/emssim/util/add_user.pl -u ${macrouser} -ip ${mplane_ip}
    Sleep    5s
    Run    cd /home/asir${bts_id}
    Telnet.Open Connection    host=0    port=8061
    Telnet.Set Prompt     FBOX>
    Telnet.Set Timeout    3 seconds
    Telnet.Write          reload
    Telnet.Close Connection

    Log To Console    \n start emssim
    ${default_port}=    Get EMSSim JSON Port From Local User    emssim_user=${macrouser}
    ${port}=    Set Variable If    ${json_port}==${0}    ${default_port}
    Log To Console    \nbts_id=${bts_id} host=${host} port=${port} user=${macrouser}
    Setup Emss    bts_id=${bts_id}    host=${host}    port=${port}    user=${macrouser}    wait_connected=False    alias=macroCM
    Log To Console    setup gNB emssim successfully on host  ${host}_${macrouser}

Prepare ASiR EMSSim Setup
    [Documentation]  This keyword is to prepare emssim env and start emssim.
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ...                 ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 ${json_port}=${0}

    ${asiruser}=        Set Variable    asir${bts_id}
    Run    sudo /opt/emssim/util/add_user.pl -u ${asiruser} -ip ${mplane_ip}
    Sleep    5s
    Run    cd /home/asir${bts_id}
    Telnet.Open Connection    host=0    port=8061
    Telnet.Set Prompt     FBOX>
    Telnet.Set Timeout    3 seconds
    Telnet.Write          reload
    Telnet.Close Connection

    Log To Console    \n start emssim
    ${default_port}=    Get EMSSim JSON Port From Local User    emssim_user=${asiruser}
    ${port}=    Set Variable If    ${json_port}==${0}    ${default_port}
    Log To Console    \nbts_id=${bts_id} host=${host} port=${port} user=${asiruser}
    Setup Emss    bts_id=${bts_id}    host=${host}    port=${port}    user=${asiruser}    wait_connected=False    alias=asirAC
    Log To Console    setup ASiR emssim successfully on host  ${host}_${asiruser}

Prepare gNB EMSSim Setup with IPV6
    [Documentation]  This keyword is to prepare emssim env and start emssim.
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
	...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v6}
    ...                 ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 ${json_port}=${0}

    ${macrouser}=        Set Variable    macro${bts_id}
    Run    sudo /opt/emssim/util/add_user.pl -u ${macrouser} -ip ${mplane_ip}
    Sleep    5s
    Run    cd /home/macro${bts_id}
    Telnet.Open Connection    host=0    port=8061
    Telnet.Set Prompt     FBOX>
    Telnet.Set Timeout    3 seconds
    Telnet.Write          reload
    Telnet.Close Connection
    Sleep    30s

    Log To Console    \n start emssim
    ${default_port}=    Get EMSSim JSON Port From Local User    emssim_user=${macrouser}
    ${port}=    Set Variable If    ${json_port}==${0}    ${default_port}
    Log To Console    \nbts_id=${bts_id} host=${host} port=${port} user=${macrouser}
    Setup Emss    bts_id=${bts_id}    host=${host}    port=${port}    user=${macrouser}    wait_connected=False    alias=macroCM
    Log To Console    setup gNB emssim successfully on host  ${host}_${macrouser}

Prepare ASiR EMSSim Setup with IPV6
    [Documentation]  This keyword is to prepare emssim env and start emssim.
    [Arguments]        ${bts_id}=${tl.gnbs[0].global_bts_id}
    ...                 ${mplane_ip}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v6}
    ...                 ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 ${json_port}=${0}

    ${asiruser}=        Set Variable    asir${bts_id}
    Run    sudo /opt/emssim/util/add_user.pl -u ${asiruser} -ip ${mplane_ip}
    Sleep    5s
    Run    cd /home/asir${bts_id}
    Telnet.Open Connection    host=0    port=8061
    Telnet.Set Prompt     FBOX>
    Telnet.Set Timeout    3 seconds
    Telnet.Write          reload
    Telnet.Close Connection
    Sleep    30s

    Log To Console    \n start emssim
    ${default_port}=    Get EMSSim JSON Port From Local User    emssim_user=${asiruser}
    ${port}=    Set Variable If    ${json_port}==${0}    ${default_port}
    Log To Console    \nbts_id=${bts_id} host=${host} port=${port} user=${asiruser}
    Setup Emss    bts_id=${bts_id}    host=${host}    port=${port}    user=${asiruser}    wait_connected=False    alias=asirAC
    Log To Console    setup ASiR emssim successfully on host  ${host}_${asiruser}

Change EMSSIM dataserver to IPV6
    [Documentation]  This keyword is to change EMSSIM dataserver to IPV6 address.
    [Arguments]        ${host_ipv6}
    Run    sudo sed -i 's/^data_server =.\\+$/data_server = ${host_ipv6}/g' /etc/emssim.conf

Recover EMSSIM dataserver to IPV4
    [Documentation]  This keyword is to recover EMSSIM dataserver to IPV4 address.
    [Arguments]        ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    Run    sudo sed -i 's/^data_server =.\\+$/data_server = ${host}/g' /etc/emssim.conf
