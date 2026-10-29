*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB006114-A feature.

Library          ../../../common_resources/netact/netact_operations.py
Library          taf.sbts.oam.coam.admin  WITH NAME    coam_admin
Library          taf.transport.ssh        WITH NAME    ssh

Resource       ../../../common_resources/netact/netact_operations.robot
Resource       ../../../common_resources/mantaray/mantaray.robot
Resource       ../../../common_resources/admin/admin.robot
Resource       ../../../common_resources/ssh/ssh_operations.robot

*** Variables ***
${udp_unprot_buffer}     13

*** Keywords ***
Check If RU operationalState has expected value
    [Arguments]    ${excpected_value}
    Log    Checking If RU operational state is ${excpected_value}    console=True
    ${admin_connection}=    Connect To Admin
    ${bts_info}=    coam_admin.get_bts_info    connection=${admin_connection}
    ${RU_operationalState}=  Get From Dictionary    ${bts_info['radioModules']['rmod'][0]['status']}    operationalState
    Should Match Regexp    ${RU_operationalState}    ${excpected_value}
    [Teardown]    Disconnect From Admin    ${admin_connection}

Wait Untill RU Will Automatically Reboot
    Wait Until Keyword Succeeds    5min      1min
    ...                            6114_Keywords.Check If RU operationalState has expected value   excpected_value=[Dd]isabled
    Wait Until Keyword Succeeds    15min    1min
    ...                            6114_Keywords.Check If RU operationalState has expected value   excpected_value=[Ee]nabled

Change actEcpriRuMPlaneSecurity Value Using WebEM
    [Arguments]    ${value}
    ${conn}=     Connect To Admin
    Log          Changing actEcpriRuMPlaneSecurity value to ${value}     console=True
    Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actEcpriRuMPlaneSecurity
    ...                                  operation=update
    ...                                  value=${value}
    ...                                  connection=${conn}
    [Teardown]    Disconnect From Admin    ${conn}

Change plainTextConnectionAllowed Value Using WebEM
    [Arguments]    ${value}
    ${conn}=     Connect To Admin
    Log          Changing plainTextConnectionAllowed value to ${value}     console=True
    Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...                                  parameter=plainTextConnectionAllowed
    ...                                  operation=update
    ...                                  value=${value}
    ...                                  connection=${conn}
    [Teardown]    Disconnect From Admin    ${conn}

Change Flag For IPSEC Feature Via Netact Through RuProtect
    [Arguments]    ${value}
    Log            Changing actEcpriRuMPlaneSecurity value for ${value}     console=True
    ${NMS_LAB}    Integrate BTS to MantaRay without TLS   NIDD_CHECK=True
    Start Tcpdump On FHNET via SSH
    Change Parameter with NMS  MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actEcpriRuMPlaneSecurity
    ...                        param_value=${value}
    ...                        LAB_NAME=${NMS_LAB}
    [Teardown]    Wait Until Keyword Succeeds	10x	 30s    Deintegrate BTS from MantaRay    ${NMS_LAB}


Set IPSEC Feature For RuProtectOptional PlainText False
    Change plainTextConnectionAllowed Value Using WebEM     value=false
    Change actEcpriRuMPlaneSecurity Value Using WebEM       value=RuProtectOptional
    Perform RU reset and expect operationalState            state=[Dd]isabled

Set IPSEC Feature For RuProtectOptional PlainText True
    Change plainTextConnectionAllowed Value Using WebEM     value=true
    Change actEcpriRuMPlaneSecurity Value Using WebEM       value=RuProtectOptional
    Perform RU reset and expect operationalState            state=[Ee]nabled

ESP Packets Should Be Present On BTS
    ${node}=    Get NodeId For Your Airscale
    ssh.Connect to    hostname=${SSH_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${response}=      ssh.Execute    command=lxc-attach -n ${node} -- timeout -s 9 90s tcpdump -i rlan0
    ...                              connection=bts_connection
    Should Contain    ${response}    ESP
    [Teardown]    ssh.Disconnect     connection=bts_connection

ESP Packets Should Not Be Present On BTS
    ${node}=    Get NodeId For Your Airscale
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${response}=    ssh.Execute     command=lxc-attach -n ${node} -- timeout -s 9 90s tcpdump -i rlan0
    ...                             connection=bts_connection
    Should Not Contain    ${response}    ESP
    [Teardown]    ssh.Disconnect    connection=bts_connection

UDP Packets From RU Should Not Be Present On BTS
    Log               Looking for undesired UDP packets from RU for 5 minutes      console=True
    ${node}=          Get NodeId For Your Airscale
    ssh.Connect to    hostname=${LMP_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${response}=      ssh.Execute   command=lxc-attach -n ${node} -- timeout -s 9 300s tcpdump -i rlan0 src port 13001
    ...                             connection=bts_connection
    ${udps}=          Get Lines Containing String    ${response}    UDP
    ${udps_count}=    Get Line Count                 ${udps}
    Should Be True    ${udps_count} < ${udp_unprot_buffer}
    [Teardown]    ssh.Disconnect    connection=bts_connection

Create nft Rule To Break Link To RU
    ${node}=          Get NodeId For Your Airscale
    ${radio_ip}=      Get IP Address For All RUs
    ssh.Connect to    hostname=${SSH_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${nft_table}  Set Variable  nft add table ip table1
    ${nft_chain}  Set Variable  nft add chain ip table1 chain1 '{ type filter hook input priority 10; policy accept; }'
    ${nft_rule}  Set Variable  nft insert rule ip table1 chain1 iifname rlan0.ecpri ip saddr ${radio_ip[0]} counter drop
    Log    Create nft rule    console=True
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_table}
    ...               connection=bts_connection
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_chain}
    ...               connection=bts_connection
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_rule}
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Delete nft Rule to Unbreak Link to RU
    ${node}=          Get NodeId For Your Airscale
    ssh.Connect to    hostname=${SSH_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${nft_table_list}    Set Variable    nft -a list table table1
    Log    Get Handle ID    console=False
    ${output}=    ssh.Execute    command=lxc-attach -n ${node} -- ${nft_table_list}
    ...                          connection=bts_connection
    ${output}=    Convert To String    ${output}
    ${chain_number}=    Get Regexp Matches     ${output}    handle (\\d+)    1
    Log    Delete nft rule    console=True
    ${conn}=          Connect to ADMIN
    ${sw_version}=    admin.get_sw_version    connection=${conn}
    ${if_branch}       Run Keyword And Return Status    Should Contain    ${sw_version}    25R3
    ${number_of_chain}   Set Variable If   '${if_branch}'=='True'   0   2
    ${nft_handle}=    Set Variable    nft delete rule table1 chain1 handle ${chain_number[${number_of_chain}]}
    ssh.Execute       command=lxc-attach -n ${node} -- ${nft_handle}
    ...               connection=bts_connection
    [Teardown]        Run Keywords   ssh.Disconnect    connection=bts_connection
    ...               AND   Disconnect from ADMIN    connection=${conn}

ISAKMP Packets Should Be Present On BTS
    [Arguments]    ${pcap_file}
    ssh.Connect to    hostname=${SSH_IP}
    ...               username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ...               alias=bts_connection
    ${radio_ip}=      Get IP Address For All RUs
    ${output}=    Run  tshark -r ${pcap_file} -Y 'ip.src==${radio_ip[0]} && isakmp.exchangetype == 34'
    Should Contain    ${output}    IKE_SA_INIT
    [Teardown]    ssh.Disconnect    connection=bts_connection

Perform RU reset and expect operationalState
    [Arguments]    ${state}
    ${conn}=       Connect To Admin
    ${ru_dns}=     coam_admin.get_ids_for_all  class_name=RMOD  connection=${conn}
    FOR  ${ru_dn}  IN  @{ru_dns}
      Run Keyword And Ignore Error  coam_admin.reset_unit  dist_name=${ru_dn}  timeout=2  connection=${conn}
    END
    Log            Wait 4 minutes for RU to reboot    console=True
    Sleep          4 minutes
    Check If RU operationalState has expected value   excpected_value=${state}

#Unused Keywords
#Change plainTextConnectionAllowed Value Using Netact
#    [Arguments]    ${value}    ${connection}
#    Log            Changing plainTextConnectionAllowed value for ${value}     console=True
#    &{param}=      Create Dictionary  plainTextConnectionAllowed  ${value}
#    Set Parameter Using Netact  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1
#    ...                         param_changes=${param}
#    ...                         path_to_scf=${scf_filepath}
#    ...                         na_instance=${connection}
#    [Teardown]    Disconnect From NetAct    ${connection}
