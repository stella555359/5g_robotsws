*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB010506 feature.

Library        keywords.py

*** Variables ***
${LMP_IP}           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LMP_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${LMP_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MPLANE_IP}        ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${MPLANE_IPV6}      ${tl.gnbs[0].cu.backhaul_site_oam_ip.v6}
${BTS_ID}           ${tl.gnbs[0].global_bts_id}

*** Keywords ***
CB010506_B_SR_ICMP_response_parameter_multiple_enabling_IPv4
    ${number_of_executions}    Set Variable    100
	:FOR    ${i}    IN RANGE    ${number_of_executions}
    \    Set Icmp Parameter    ${False}
    \    ${ping_status}=    Send Ping    ${MPLANE_IP}
    \    Check Ping Status    ${ping_status}    ${False}
    \    Set Icmp Parameter    ${True}
    \    ${ping_status}=    Send Ping    ${MPLANE_IP}
    \    Check Ping Status    ${ping_status}    ${True}

CB010506_B_SR_ICMP_response_parameter_multiple_enabling_IPv6
    ${number_of_executions}    Set Variable    100
	:FOR    ${i}    IN RANGE    ${number_of_executions}
    \    Set Icmp Parameter    ${False}
    \    ${ping_status}=    Send Ping Ipv6    ${MPLANE_IPV6}
    \    Check Ping Status    ${ping_status}    ${False}
    \    Set Icmp Parameter    ${True}
    \    ${ping_status}=    Send Ping Ipv6    ${MPLANE_IPV6}
    \    Check Ping Status    ${ping_status}    ${True}

CB010506_B_SR_Firewall_Rules_Inventory_Exploratory_IPv4
    [Documentation]    It should be execeuted in 2 variants:
    ...                -1st with legacy firewall (swconfig R&D flag 0x1A002C=0 (default value) in /ffs/run/swconfig.txt)
    ...                -2nd with new firewall harmonization (swconfig R&D flag 0x1A002C=1 in /ffs/run/swconfig.txt)
    ...                Swconfig should be singed with cmd: "crasign /ffs/run/swconfig.txt" and SMOD rebooted.
    ...                The goal of this exploratory test is to compare firewall configuration from both firewall
    ...                variants (legacy and after harmonization) - it needs to be done manually.
    ${nft_file_directory_at_smod}    Set Variable    /tmp
    ${nft_file_name_at_smod}    Set Variable    nft_rules_dump.txt
    ${nft_file_path_at_smod}    Set Variable    ${nft_file_directory_at_smod}/${nft_file_name_at_smod}
    ${smod_ssh_connection_alias}    Set Variable    sshenb
    Connect To Smod    ${smod_ssh_connection_alias}
    Print Swconfig Content    ${smod_ssh_connection_alias}
    Save Smod Firewall Rules    ${smod_ssh_connection_alias}    ${nft_file_path_at_smod}
    Copy Firewall Rules From Smod To Vm    ${smod_ssh_connection_alias}    ${nft_file_path_at_smod}    ${nft_file_name_at_smod}

Connect To Smod
    [Arguments]    ${smod_ssh_connection_alias}
    ssh.Connect To    ${LMP_IP}    ${LMP_USERNAME}    ${LMP_PASSWORD}    alias=${smod_ssh_connection_alias}

Print Swconfig Content
    [Arguments]    ${smod_ssh_connection_alias}
    ssh.Send Command    command=cat /ffs/run/swconfig.txt    connection=${smod_ssh_connection_alias}
    ${output}           ssh.Read Output    connection=${smod_ssh_connection_alias}
    Log To Console   \n\nThis is content of swconfig file:\n${output}\n

Save Smod Firewall Rules
    [Arguments]    ${smod_ssh_connection_alias}     ${nft_file_path_at_smod}
    ssh.Send Command    command=nft -a list ruleset > ${nft_file_path_at_smod}   connection=${smod_ssh_connection_alias}

Copy Firewall Rules From Smod To Vm
    [Arguments]    ${nft_file_path_at_smod}    ${nft_file_name_at_smod}
    Run     sshpass -p ${LMP_PASSWORD} scp ${LMP_USERNAME}@${LMP_IP}:${nft_file_path_at_smod} ${OUTPUT_DIR}/
    Log To Console    File with firewall rules is available at the path ${OUTPUT_DIR}/${nft_file_name_at_smod}

Set Icmp Parameter
    [Arguments]    ${value}
    Change Parameter on BTS                            dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1
    ...                                                param_name=icmpResponseEnabled
    ...                                                param_value=${value}
