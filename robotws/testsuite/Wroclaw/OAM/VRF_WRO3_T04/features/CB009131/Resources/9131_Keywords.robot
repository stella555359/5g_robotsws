*** Settings ***
Documentation
...           author: Jagoda Kubacka
...           maintainer: jagoda.kubacka@nokia.com
...           Robot keywords to test the CB009131 feature

Resource         ../../../common_resources/admin/admin.robot
Resource         ../../../common_resources/commissioning/commissioning.robot
Resource         ../../../common_resources/connections/connections.robot
Resource         ../../../common_resources/ue_operations/ue_operations.robot
Resource         ../../../common_resources/ip_traffic/ip_traffic.robot
Resource         ../../../common_resources/pcap_analysis/pcap_analysis.robot

Library          Collections
Library          taf.sbts.oam.coam.admin  WITH NAME    coam_admin
Library          taf.transport.ssh        WITH NAME    ssh
Library          taf.config.scf           WITH NAME    scf
Library          ./9131_functions.py      WITH NAME    9131
Library          ../../../common_resources/admin/admin_utils.py

*** Variables ***
${NFT_RULESET}=                ${OUTPUT_DIR}/nft_list_ruleset.txt
${UE1_PDU}=                    0
${UE1_ALIAS}=                  UE_1
${UE1_CAPABILITIES}=           OPERATOR3
${UE1_SERIAL}=                 129539da
${UE2_PDU}=                    1
${UE2_ALIAS}=                  UE_2
${UE2_CAPABILITIES}=           OPERATOR5
${ATTENUATION_CHANNEL}=        4
${UE_PC_IP}=                   10.42.22.85
${UE_PC_USERNAME}=             labadmin
${UE_PC_PASSWORD}=             ZAQ!2wsx
${PORT}=                       2138

*** Keywords ***
Set actDynamicFirewall Feature Status
    [Documentation]            Setting feature status parameter with true or false.
    [Arguments]                ${status}=true
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                        param_name=actDynamicFirewall
    ...                        param_value=${status}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set actMultipleDynamicIP Feature Status
    [Documentation]            Setting feature status parameter with true or false
    [Arguments]                ${status}=true
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                        param_name=actMultipleDynamicIP
    ...                        param_value=${status}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set actTrsSepaNSARanSharing Feature Status
    [Documentation]            Setting feature status parameter with true or false
    [Arguments]                ${status}=true
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                        param_name=actTrsSepaNSARanSharing
    ...                        param_value=${status}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set actTrsSepaSARanSharing Feature Status
    [Documentation]            Setting feature status parameter with true or false
    [Arguments]                ${status}=true
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                        param_name=actTrsSepaSARanSharing
    ...                        param_value=${status}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set IPv4 Address For X2 C-plane
    [Arguments]                ${new_ipv4}
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ...                        param_name=localIpAddr
    ...                        param_value=${new_ipv4}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set IPv4 Address For Xn C-plane
    [Arguments]                ${new_ipv4}
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2
    ...                        param_name=localIpAddr
    ...                        param_value=${new_ipv4}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}


Set IPv4 Address For NG C-plane
    [Arguments]                ${new_ipv4}
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-6/IPADDRESSV4-1
    ...                        param_name=localIpAddr
    ...                        param_value=${new_ipv4}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set IPv4 Address For Xn U-plane
    [Arguments]                ${new_ipv4}
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV4-2
    ...                        param_name=localIpAddr
    ...                        param_value=${new_ipv4}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Set IPv4 Address For NG U-plane
    [Arguments]                ${new_ipv4}
    ${connection}=             Connect To ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1
    ...                        param_name=localIpAddr
    ...                        param_value=${new_ipv4}
    ...                        connection=${connection}
    [Teardown]                 Disconnect From ADMIN    connection=${connection}

Create New NRX2LINK_TRUST Object
    [Arguments]    ${object_id}=1    ${ipv4}=1.1.1.1
    ${admin_connection}=    Connect To ADMIN
    ${dist_name}=           Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_id}
    @{parameter_list}=      9131.get_list_of_params_for_nrx2link_trust_object    ${ipv4}    ${object_id}
    Log                                   Creating NRX2LINK_TRUST-${object_id} with IP ${ipv4}    console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                   parameter=${parameter_list}
    ...                                   operation=create
    ...                                   skip_parameter_relation_errors=${False}
    ...                                   should_activate=${True}
    ...                                   connection=${admin_connection}
    Log                                   NRX2LINK_TRUST-${object_id} with IP ${ipv4} created    console=true
    [Return]      ${ipv4}
    [Teardown]    Disconnect From ADMIN   connection=${admin_connection}

Modify Existing NRX2LINK_TRUST Object
    [Arguments]    ${object_id}=1     ${new_ipv4}=1.1.1.2
    ${admin_connection}=                     Connect To ADMIN
    ${dist_name}=                            Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_id}
    Log                                      Modifying NRX2LINK_TRUST-${object_id} with new IP ${new_ipv4}
    ...                                      console=true
    coam_admin.perform_parameter_recommissioning  dist_name=${dist_name}
    ...                                           parameter=ipV4Addr
    ...                                           operation=update
    ...                                           value=${new_ipv4}
    ...                                           skip_parameter_relation_errors=${False}
    ...                                           should_activate=${True}
    ...                                           connection=${admin_connection}
    Log                                      NRX2LINK_TRUST-${object_id} is modified with new IP ${new_ipv4}
    ...                                      console=true
    [Return]      ${new_ipv4}
    [Teardown]    Disconnect From ADMIN      connection=${admin_connection}

Delete Existing NRX2LINK_TRUST Object
    [Arguments]    ${object_id}=1
    ${admin_connection}=                  Connect To ADMIN
    ${dist_name}=                         Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_id}
    @{parameter_list}=                    Create List
    ${ipv4}=                              Get IPv4 Address Of Existing NRX2LINK_TRUST Object      ${object_id}
    ...                                                                                           ${admin_connection}
    Log                                   Removing NRX2LINK_TRUST-${object_id} with IP ${ipv4}    console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                   parameter=${parameter_list}
    ...                                   operation=delete
    ...                                   skip_parameter_relation_errors=${False}
    ...                                   should_activate=${True}
    ...                                   connection=${admin_connection}
    Log                                   NRX2LINK_TRUST-${object_id} with IP ${ipv4} removed    console=true
    [Return]      ${ipv4}
    [Teardown]    Disconnect From ADMIN   connection=${admin_connection}

Create Max Amount Of NRX2LINK_TRUST Objects
    ${existing_objects}=              Get All Existing NRX2LINK_TRUST Objects
    ${existing_objects_ids}=          Get Dictionary Keys                      ${existing_objects}
    ${amount_of_existing_objects}=    Get Length                               ${existing_objects_ids}
    ${existing_objects_ipv4}=         Get Dictionary Values                    ${existing_objects}
    ${new_objects_ids}=               create_id_list_of_new_objects            ${existing_objects_ids}
    ${NRX2LINK_TRUST_IP_list}=        Generate IP Addresses For Max Objects    ${amount_of_existing_objects}
    ${nrx2link_list}=                 Create List
    ${position_of_new_ip}=            Convert To Integer               0
    Log                               Creating max amount of NRX2LINK_TRUST objects          console=true
    FOR  ${object_id}  IN  @{new_objects_ids}
        ${nrx2link_dict}=         Create Dictionary For New NRX2LINK_TRUST Object
        ...                       ${NRX2LINK_TRUST_IP_list[${position_of_new_ip}]}
        ...                       ${object_id}
        Append To List            ${nrx2link_list}    ${nrx2link_dict}
        ${position_of_new_ip}=    Evaluate            ${position_of_new_ip} + 1
    END
    ${all_NRX2LINK_TRUST_IP_list}=                    Combine Lists    ${NRX2LINK_TRUST_IP_list}
    ...                                                                ${existing_objects_ipv4}
    Change State Of Objects By Delta                  ${nrx2link_list}
    Log                                               All NRX2LINK_TRUST objects created      console=true
    [Return]      ${all_NRX2LINK_TRUST_IP_list}

Modify Max Amount Of NRX2LINK_TRUST Objects
    ${modified_NRX2LINK_TRUST_IP_list}=          Generate 512 IP Addresses To Modify
    ${object_ID}=                                Convert To Integer  1
    ${nrx2link_list}=                            Create List
    Log                                          Modifying all NRX2LINK_TRUST objects     console=true
    FOR  ${modified_IP}  IN  @{modified_NRX2LINK_TRUST_IP_list}
         ${nrx2link_dict}=                       Create Dictionary For Modified NRX2LINK_TRUST Object
         ...                                     ${modified_IP}
         ...                                     ${object_ID}
         Append To List       ${nrx2link_list}   ${nrx2link_dict}
         ${object_ID}=        Evaluate           ${object_ID} + 1
    END
    Change State Of Objects By Delta             ${nrx2link_list}
    Log                                          All NRX2LINK_TRUST objects modified      console=true
    [Return]      ${modified_NRX2LINK_TRUST_IP_list}

Remove Max Amount Of NRX2LINK_TRUST Objects
    ${nrx2link_list}=      Create List
    Log                    Removing all NRX2LINK_TRUST objects     console=true
    FOR  ${object_ID}  IN RANGE  1  513
         ${nrx2link_dict}=                       Create Dictionary For Removed NRX2LINK_TRUST Object
         ...                                     ${object_ID}
         Append To List       ${nrx2link_list}   ${nrx2link_dict}
    END
    Change State Of Objects By Delta             ${nrx2link_list}
    Log                                          All NRX2LINK_TRUST objects removed    console=true

Create Dictionary For New NRX2LINK_TRUST Object
    [Arguments]    ${ipv4}    ${object_ID}
    ${dist_name}=          Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_ID}
    ${object_ID}=          Convert To String                                    ${object_ID}
    @{parameter_list}=     9131.get_list_of_params_for_nrx2link_trust_object    ${ipv4}    ${object_ID}
    &{nrx2link_dict}=      Create Dictionary                                    distName=${dist_name}
    ...                                                                         operation=create
    ...                                                                         parameters=@{parameter_list}
    [Return]    ${nrx2link_dict}

Create Dictionary For Modified NRX2LINK_TRUST Object
    [Arguments]    ${ipv4}    ${object_ID}
    ${dist_name}=          Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_ID}
    @{parameter_list}=     9131.get_list_of_params_for_modified_nrx2link_trust_object    ${ipv4}
    &{nrx2link_dict}=      Create Dictionary                                             distName=${dist_name}
    ...                                                                                  operation=update
    ...                                                                                  parameters=@{parameter_list}
    [Return]    ${nrx2link_dict}

Create Dictionary For Removed NRX2LINK_TRUST Object
    [Arguments]    ${object_ID}
    ${dist_name}=          Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_ID}
    @{parameter_list}=     Create List
    &{nrx2link_dict}=      Create Dictionary                         distName=${dist_name}
    ...                                                              operation=delete
    ...                                                              parameters=@{parameter_list}
    [Return]    ${nrx2link_dict}

Generate IP Addresses For Max Objects
    [Arguments]    ${already_existing_objects}
    ${IP_list}=    Create List
    ${objects_to_create}=    Set Variable    ${${512} - ${already_existing_objects}}
    FOR  ${loop_nr}  IN RANGE  ${objects_to_create}
        Run Keyword If    ${loop_nr} <= 255         Append To List    ${IP_list}    1.1.2.${loop_nr}
        ...               ELSE                      Append To List    ${IP_list}    1.1.3.${loop_nr-256}
    END
    [Return]    ${IP_list}

Generate 512 IP Addresses To Modify
    ${IP_list}=  Create List
    FOR  ${loop_nr}  IN RANGE  ${256}
         Append To List    ${IP_list}    1.1.5.${loop_nr}
    END
    FOR  ${loop_nr}  IN RANGE  ${256}
         Append To List    ${IP_list}    1.1.6.${loop_nr}
    END
    [Return]    ${IP_list}

Create New NRADJGNB Object
    [Arguments]    ${object_id}    ${xnlink_id}    ${xnlink_ipv4}
    ${admin_connection}=    Connect To ADMIN
    ${dist_name}=           Set Variable       MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
    @{parameter_list}=      9131.get_list_of_params_for_nradjgnb_object  ${xnlink_ID}  ${BTS_ID}
    Log                                        Creating NRADJGNB-${object_id} with XNLINK ID ${xnlink_id}
    ...                                        console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                        parameter=${parameter_list}
    ...                                        operation=create
    ...                                        skip_parameter_relation_errors=${False}
    ...                                        should_activate=${True}
    ...                                        connection=${admin_connection}
    Log                                        NRADJGNB-${object_id} with XNLINK ID ${xnlink_id} created
    ...                                        console=true
    [Return]      ${xnlink_ipv4}
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Create New XNLINK Object
    [Arguments]    ${object_id}=1    ${ipv4}=2.2.2.2
    ${admin_connection}=    Connect To ADMIN
    ${dist_name}=           Set Variable       MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK-${object_id}
    ${actTrsSepaSARanSharing_value_list}=      Check Current Parameter Value
    ...                                        dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                                        param_name=actTrsSepaSARanSharing
    ${actTrsSepaSARanSharing_value}=           Set Variable              ${actTrsSepaSARanSharing_value_list[0]}
    @{parameter_list}=      9131.get_list_of_params_for_xnlink_object    ${ipv4}    ${object_id}
    ...                                        is_actTrsSepaSARanSharing=${actTrsSepaSARanSharing_value}
    Log                                        Creating XNLINK-${object_id} with IP ${ipv4}    console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                        parameter=${parameter_list}
    ...                                        operation=create
    ...                                        skip_parameter_relation_errors=${False}
    ...                                        should_activate=${True}
    ...                                        connection=${admin_connection}
    Log                                        XNLINK-${object_id} with IP ${ipv4} created    console=true
    [Return]      ${ipv4}
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Delete Existing XNLINK Object
    [Arguments]    ${object_id}
    ${admin_connection}=    Connect To ADMIN
    ${dist_name}=           Set Variable       MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK-${object_id}
    @{parameter_list}=      Create List
    Log                                        Removing XNLINK-${object_id}    console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                        parameter=${parameter_list}
    ...                                        operation=delete
    ...                                        skip_parameter_relation_errors=${False}
    ...                                        should_activate=${True}
    ...                                        connection=${admin_connection}
    Log                                        XNLINK-${object_id} removed    console=true
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Modify Existing NRADJGNB Object
    [Arguments]    ${object_id}    ${xnlink_id}    ${xnlink_ipv4}
    ${admin_connection}=                          Connect To ADMIN
    ${dist_name}=  Set Variable                   MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
    Log                                           Modifying NRADJGNB-${object_id} with new XNLINK ID ${xnlink_id}
    ...                                           console=true
    coam_admin.perform_parameter_recommissioning  dist_name=${dist_name}
    ...                                           parameter=xnLinkRef
    ...                                           operation=update
    ...                                           value=${xnlink_id}
    ...                                           skip_parameter_relation_errors=${False}
    ...                                           should_activate=${True}
    ...                                           connection=${admin_connection}
    Log                                           NRADJGNB-${object_id} is modified with new XNLINK ID ${xnlink_id}
    ...                                           console=true
    [Return]      ${xnlink_ipv4}
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Delete Existing NRADJGNB Object
    [Arguments]    ${object_id}
    ${admin_connection}=                       Connect To ADMIN
    ${dist_name}=       Set Variable           MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
    @{parameter_list}=  Create List
    Log                                        Removing NRADJGNB-${object_id}    console=true
    coam_admin.perform_object_recommissioning  dist_name=${dist_name}
    ...                                        parameter=${parameter_list}
    ...                                        operation=delete
    ...                                        skip_parameter_relation_errors=${False}
    ...                                        should_activate=${True}
    ...                                        connection=${admin_connection}
    Log                                        NRADJGNB-${object_id} removed    console=true
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Set NRADJGNB AdministrativeState To Locked
    [Arguments]    ${object_id}
    ${admin_connection}=                          Connect To ADMIN
    ${dist_name}=  Set Variable                   MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
    Log                                           Modifying NRADJGNB-${object_id}
    ...                                           console=true
    coam_admin.perform_parameter_recommissioning  dist_name=${dist_name}
    ...                                           parameter=administrativeState
    ...                                           operation=update
    ...                                           value=Locked
    ...                                           skip_parameter_relation_errors=${False}
    ...                                           should_activate=${True}
    ...                                           connection=${admin_connection}
    Log                                           NRADJGNB-${object_id} administrativeState is change to Locked
    ...                                           console=true
    [Teardown]    Disconnect From ADMIN        connection=${admin_connection}

Check If All NRX2LINK_TRUST Objects Are Added To Firewall
    [Arguments]                           ${XRX2LINK_TRUST_IP_list}
    ${bts_connection}=                    Connect To BTS
    Log                                   Checking if all NRX2LINK_TRUST IP addresses are added to X2 firewall rules
    ...                                   console=true
    ssh.execute                           command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                   connection=${bts_connection}
    ${output}=                            ssh.execute    command=cat ruleset.txt    connection=${bts_connection}
    ${x2link_addresses}=                  Should Match Regexp    ${output}
    ...                                                          x2Cplane5gRemoteIpAddrList.*\n.*ipv4[^}]*
    FOR  ${item}  IN  @{XRX2LINK_TRUST_IP_list}
        Should Contain  ${x2link_addresses}  ${item}
    END
    [Teardown]                            Disconnect From BTS    ${bts_connection}

Check If Firewall Has No Rules For Old NRX2LINK_TRUST Objects
    [Arguments]                           ${NRX2LINK_TRUST_IP_list}
    ${bts_connection}=                    Connect To BTS
    Log                                   Checking if all NRX2LINK_TRUST IP addresses are removed from X2 firewall rules
    ...                                   console=true
    ssh.execute                           command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                   connection=${bts_connection}
    ${output}=                            ssh.execute  command=cat ruleset.txt
    ...                                   connection=${bts_connection}
    ${is_section_available}=              Run Keyword And Return Status    Should Match Regexp
    ...                                                                    ${output}
    ...                                                                    x2Cplane5gRemoteIpAddrList.*\n.*ipv4
    ${x2link_addresses}=                  Run Keyword If                   '${is_section_available}' == 'False'
    ...                                   Create List
    ...    ELSE                           Should Match Regexp              ${output}
    ...                                                                    x2Cplane5gRemoteIpAddrList.*\n.*ipv4[^}]*
    FOR  ${item}  IN  @{NRX2LINK_TRUST_IP_list}
        Should Not Contain    ${x2link_addresses}    ${item}
    END
    [Teardown]                            Disconnect From BTS    ${bts_connection}

Check If Firewall Rule Is Added Globally
    [Arguments]    ${IP_address}
    ${bts_connection}=                  Connect To BTS
    Log                                 Checking if ${IP_address} is globally added to firewall    console=true
    ssh.execute                         command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                 connection=${bts_connection}
    ${output}=                          ssh.execute  command=cat ruleset.txt
    ...                                 connection=${bts_connection}
    Should Contain                      ${output}  ${IP_address}
    [Teardown]                          Disconnect From BTS    ${bts_connection}

Check If Firewall Rule Is Removed Globally
    [Arguments]    ${IP_address}
    ${bts_connection}=                  Connect To BTS
    Log                                 Checking if ${IP_address} is globally removed from firewall    console=true
    ssh.execute                         command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                 connection=${bts_connection}
    ${output}=                          ssh.execute  command=cat ruleset.txt
    ...                                 connection=${bts_connection}
    Should Not Contain                  ${output}  ${IP_address}
    [Teardown]                          Disconnect From BTS    ${bts_connection}

Check If X2 Firewall Rule Is Added
    [Arguments]                                ${x2link_ip}    ${regex_x2Cplane}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_ip} is added to X2 firewall rule    console=true
    ssh.execute                                command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                        connection=${bts_connection}
    ${output}=                                 ssh.execute  command=cat ruleset.txt    connection=${bts_connection}
    ${x2link_addresses}=                       Should Match Regexp    ${output}    ${regex_x2Cplane}
    Should Contain                             ${x2link_addresses}    ${x2link_ip}
    [Teardown]                                 Disconnect From BTS    ${bts_connection}

Check If X2 Firewall Rule Is Removed
    [Arguments]                                ${x2link_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_ip} is removed from X2 firewall rule    console=true
    ssh.execute                                command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                        connection=${bts_connection}
    ${output}=                                 ssh.execute  command=cat ruleset.txt    connection=${bts_connection}
    ${is_section_available}=                   Run Keyword And Return Status    Should Match Regexp
    ...                                                                         ${output}
    ...                                                                         x2Cplane5gRemoteIpAddrList.*\n.*ipv4
    ${x2link_addresses}=                       Run Keyword If            '${is_section_available}' == 'False'
    ...                                        Create List
    ...    ELSE                                Should Match Regexp       ${output}
    ...                                                                  x2Cplane5gRemoteIpAddrList.*\n.*ipv4[^}]*
    Should Not Contain                         ${x2link_addresses}       ${x2link_ip}
    [Teardown]                                 Disconnect From BTS       ${bts_connection}

Check If XN Firewall Rule Is Added
    [Arguments]                                ${xnlink_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${xnlink_ip} is added to Xn firewall rule    console=true
    ssh.execute                                command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                        connection=${bts_connection}
    ${output}=                                 ssh.execute  command=cat ruleset.txt    connection=${bts_connection}
    ${xnlink_addresses}=                       Should Match Regexp    ${output}
    ...                                                               xnCplaneRemoteIpAddrList.*\n.*ipv4[^}]*
    Should Contain                             ${xnlink_addresses}    ${xnlink_ip}
    [Teardown]                                 Disconnect From BTS    ${bts_connection}

Check If XN Firewall Rule Is Removed
    [Arguments]                                ${xnlink_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${xnlink_ip} is removed from Xn firewall rule    console=true
    ssh.execute                                command=nft list ruleset > /user/toor4nsn/ruleset.txt
    ...                                        connection=${bts_connection}
    ${output}=                                 ssh.execute  command=cat ruleset.txt    connection=${bts_connection}
    ${is_section_available}=                   Run Keyword And Return Status    Should Match Regexp
    ...                                                                         ${output}
    ...                                                                         xnCplaneRemoteIpAddrList.*\n.*ipv4
    ${xnlink_addresses}=                       Run Keyword If            '${is_section_available}' == 'False'
    ...                                        Create List
    ...    ELSE                                Should Match Regexp       ${output}
    ...                                                                  xnCplaneRemoteIpAddrList.*\n.*ipv4[^}]*
    Should Not Contain                         ${xnlink_addresses}       ${xnlink_ip}
    [Teardown]                                 Disconnect From BTS       ${bts_connection}

Remove All Existing NRX2LINK_TRUST Objects
    ${admin_connection}=             Connect To ADMIN
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    @{nrx2link_trust_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRX2LINK_TRUST
    @{EMPTY_LIST}=    Create List
    FOR  ${nrx2link_trust_dist}    IN     @{nrx2link_trust_dists_list}
        coam_admin.Perform Object Recommissioning    dist_name=${nrx2link_trust_dist}
        ...                               parameter=${EMPTY_LIST}
        ...                               operation=delete
        ...                               connection=${admin_connection}
        Sleep    30sec
    END
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    @{nrx2link_trust_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRX2LINK_TRUST
    ${nrx2link_trust_dists_list_length} =	Get Length	${nrx2link_trust_dists_list}
    Should Be Equal As Integers	   ${nrx2link_trust_dists_list_length}    0
    Log    All previous NRX2LINK_TRUST Objects removed correctly    console=${TRUE}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Create All Necessary NRX2LINK_TRUST Objects
    ${admin_connection}=             Connect To ADMIN
    @{nrx2link_trust_ipV4_addresses_list}=    Create List    10.44.79.47    10.44.79.48
    @{nrx2link_trust_ipV6_addresses_list}=    Create List    2a00:8a00:6000:607c::1:9e06    2a00:8a00:6000:607c::1:b523
    ${index}=  Set Variable  0
    FOR  ${object_number}    IN RANGE    257  259  1
        ${nrx2link_trust_string}=  Catenate
        ...     [{'parameterName': 'ipV4Addr', 'operation': 'update', 'value': '${nrx2link_trust_ipV4_addresses_list[${index}]}'},
        ...     {'parameterName': 'ipV6Addr', 'operation': 'update', 'value': '${nrx2link_trust_ipV6_addresses_list[${index}]}'},
        ...     {'parameterName': 'x2LinkTrustCtrl', 'operation': 'update', 'value': 'gnbControlled'}]
        ${nrx2link_trust}=  Evaluate    ${nrx2link_trust_string}
        coam_admin.Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_number}
        ...                               parameter=${nrx2link_trust}
        ...                               operation=create
        ...                               connection=${admin_connection}
        ${index}=    Evaluate  ${index}+1
    END
    Log    All new NRX2LINK_TRUST Objects added correctly    console=${TRUE}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get IPv4 Addresses NRX2LINK_TRUST Objects
    ${admin_connection}=             Connect To ADMIN
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    @{nrx2link_trust_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRX2LINK_TRUST
    @{ipv4_addresses_list}=  Create List
    FOR  ${nrx2link_trust_dist}    IN     @{nrx2link_trust_dists_list}
            ${ipv4_values}=          admin.Check Current Parameter Value    param_name=ipV4Addr
            ...                                                             dist_name=${nrx2link_trust_dist}
            ...                                                             connection=${admin_connection}
            ${nrx2link_trust_ip}=    Set Variable    ${ipv4_values[0]}
            Append To List    ${ipv4_addresses_list}    ${nrx2link_trust_ip}
    END
    [Return]    ${ipv4_addresses_list}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get IPv6 Addresses NRX2LINK_TRUST Objects
    ${admin_connection}=             Connect To ADMIN
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    @{nrx2link_trust_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRX2LINK_TRUST
    @{ipv6_addresses_list}=  Create List
    FOR  ${nrx2link_trust_dist}    IN     @{nrx2link_trust_dists_list}
            ${ipv6_values}=          admin.Check Current Parameter Value    param_name=ipV6Addr
            ...                                                             dist_name=${nrx2link_trust_dist}
            ...                                                             connection=${admin_connection}
            ${EMPTY_LIST}=    Create List
            ${status}=  Run Keyword And Return Status    Lists Should Be Equal   ${EMPTY_LIST}    ${ipv6_values}
            Continue For Loop If  "${status}"=="True"
            ${nrx2link_trust_ip}=    Set Variable    ${ipv6_values[0]}
            Append To List    ${ipv6_addresses_list}    ${nrx2link_trust_ip}
    END
    [Return]    ${ipv6_addresses_list}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Check If NRX2LINK_TRUST IPv4 Firewall Rule Is Added When actDynamicFirewall Is True
    [Arguments]                                ${x2link_trust_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_trust_ip} is added to NRX2LINK_TRUST firewall rule    console=${TRUE}
    ${set_name_ipv4}=           ssh.Execute    command=nft list sets table "ip filter" | grep -o 'set x2[^ ]*' | awk '{print $2}'
    ...                                        connection=${bts_connection}
    ${set_name_ipv4}=           Strip String   ${set_name_ipv4}
    ${set_content_ipv4}=        ssh.Execute    command=nft list set "ip filter" "${set_name_ipv4}"
    ...                                        connection=${bts_connection}
    Should Contain                             ${set_content_ipv4}    ${x2link_trust_ip}

    ${chain_content_ipv4}=      ssh.Execute    command= nft list chain "ip filter" CP_TRAFFIC_5G
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv4}    NGXN_CHAIN

    ${chain_content_ipv4}=      ssh.Execute    command= nft list chain "ip filter" NGXN_CHAIN
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv4}    ${set_name_ipv4}

    Log                                        [OK] Rule (IPv4: ${x2link_trust_ip}) added properly    console=${TRUE}
    [Teardown]                                 Disconnect From BTS    connection=${bts_connection}

Check If NRX2LINK_TRUST IPv4 Firewall Rule Is Added When actDynamicFirewall Is False
    [Arguments]                                ${x2link_trust_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_trust_ip} is added to NRX2LINK_TRUST firewall rule    console=${TRUE}
    ${set_name_ipv4}=           ssh.Execute    command=nft list sets table "ip filter" | grep -o 'set x2[^ ]*' | awk '{print $2}'
    ...                                        connection=${bts_connection}
    ${set_name_ipv4}=           Strip String   ${set_name_ipv4}
    ${set_content_ipv4}=        ssh.Execute    command=nft list set "ip filter" "${set_name_ipv4}"
    ...                                        connection=${bts_connection}
    Should Contain                             ${set_content_ipv4}    ${x2link_trust_ip}

    ${chain_content_ipv4}=      ssh.Execute    command= nft list chain "ip filter" CP_TRAFFIC_5G
    ...                                        connection=${bts_connection}
    Should Not Contain                         ${chain_content_ipv4}    NGXN_CHAIN

    ${chain_content_ipv4}=      ssh.Execute    command= nft list chain "ip filter" NGXN_CHAIN
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv4}    ${set_name_ipv4}

    Log                                        [OK] Rule (IPv4: ${x2link_trust_ip}) added properly    console=${TRUE}
    [Teardown]                                 Disconnect From BTS    connection=${bts_connection}

Check If NRX2LINK_TRUST IPv6 Firewall Rule Is Added When actDynamicFirewall Is True
    [Arguments]                                ${x2link_trust_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_trust_ip} is added to NRX2LINK_TRUST firewall rule    console=${TRUE}
    ${set_name_ipv6}=           ssh.Execute    command=nft list sets table "ip6 filter" | grep -o 'set x2[^ ]*' | awk '{print $2}'
    ...                                        connection=${bts_connection}
    ${set_name_ipv6}=           Strip String   ${set_name_ipv6}
    ${set_content_ipv6}=        ssh.Execute    command=nft list set "ip6 filter" "${set_name_ipv6}"
    ...                                        connection=${bts_connection}
    Should Contain                             ${set_content_ipv6}    ${x2link_trust_ip}

    ${chain_content_ipv6}=      ssh.Execute    command= nft list chain "ip6 filter" CP_TRAFFIC_5G
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv6}    NGXN_CHAIN

    ${chain_content_ipv6}=      ssh.Execute    command= nft list chain "ip6 filter" NGXN_CHAIN
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv6}    ${set_name_ipv6}

    Log                                        [OK] Rule (IPv6: ${x2link_trust_ip}) added properly    console=${TRUE}
    [Teardown]                                 Disconnect From BTS    connection=${bts_connection}

Check If NRX2LINK_TRUST IPv6 Firewall Rule Is Added When actDynamicFirewall Is False
    [Arguments]                                ${x2link_trust_ip}
    ${bts_connection}=                         Connect To BTS
    Log                                        Checking if ${x2link_trust_ip} is added to NRX2LINK_TRUST firewall rule    console=${TRUE}
    ${set_name_ipv6}=           ssh.Execute    command=nft list sets table "ip6 filter" | grep -o 'set x2[^ ]*' | awk '{print $2}'
    ...                                        connection=${bts_connection}
    ${set_name_ipv6}=           Strip String   ${set_name_ipv6}
    ${set_content_ipv6}=        ssh.Execute    command=nft list set "ip6 filter" "${set_name_ipv6}"
    ...                                        connection=${bts_connection}
    Should Contain                             ${set_content_ipv6}    ${x2link_trust_ip}

    ${chain_content_ipv6}=      ssh.Execute    command= nft list chain "ip6 filter" CP_TRAFFIC_5G
    ...                                        connection=${bts_connection}
    Should Not Contain                         ${chain_content_ipv6}    NGXN_CHAIN

    ${chain_content_ipv6}=      ssh.Execute    command= nft list chain "ip6 filter" NGXN_CHAIN
    ...                                        connection=${bts_connection}
    Should Contain                             ${chain_content_ipv6}    ${set_name_ipv6}

    Log                                        [OK] Rule (IPv6: ${x2link_trust_ip}) added properly    console=${TRUE}
    [Teardown]                                 Disconnect From BTS    connection=${bts_connection}

Add New NRX2LINK_TRUST Object
    [Arguments]    ${ipv4}    ${ipv6}
    ${admin_connection}=             Connect To ADMIN
    Log    Adding new NRX2LINK_TRUST Object    console=${TRUE}
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    @{nrx2link_trust_dists_list}=    scf.get_all_dist_names_of_specific_class     com.nokia.srbts.nrbts:NRX2LINK_TRUST
    ${max_id_nrx2link_trust_dist}=    Evaluate  max(${nrx2link_trust_dists_list})
    ${rest}    ${max_id_nrx2link_trust}=         Split String From Right    ${max_id_nrx2link_trust_dist}    -    1
    ${new_max_id_nrx2link_trust}=     Evaluate    int(${max_id_nrx2link_trust})+1
    Log  New dist name: "MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${new_max_id_nrx2link_trust}"    console=${TRUE}
    ${nrx2link_trust_string}=  Catenate
    ...     [{'parameterName': 'ipV4Addr', 'operation': 'update', 'value': '${ipv4}'},
    ...     {'parameterName': 'ipV6Addr', 'operation': 'update', 'value': '${ipv6}'},
    ...     {'parameterName': 'x2LinkTrustCtrl', 'operation': 'update', 'value': 'gnbControlled'}]
    ${nrx2link_trust}=  Evaluate    ${nrx2link_trust_string}
    coam_admin.Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${new_max_id_nrx2link_trust}
    ...                               parameter=${nrx2link_trust}
    ...                               operation=create
    ...                               connection=${admin_connection}
    Log    NRX2LINK_TRUST (MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${new_max_id_nrx2link_trust}) Object added    console=${TRUE}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get All Existing NRX2LINK_TRUST Objects
    ${admin_connection}=             Connect To ADMIN
    coam_admin.get_current_scf_file  local_dir_path=/tmp/
    ...                              file_name=full_scf.xml
    ...                              export_type=configurationAndRuntimeObjects
    ...                              connection=${admin_connection}
    ...                              timeout=90
    scf.load_scf                     /tmp/full_scf.xml
    &{object_dict}=                  Create Dictionary
    FOR  ${object_id}  IN RANGE  1  513
        ${dist_name}=             Set Variable            MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_id}
        ${is_object_exist}=       scf.is_object_in_scf    ${dist_name}
        ${object_ipv4}=           Run Keyword If          ${is_object_exist}
        ...                       Get IPv4 Address Of Existing NRX2LINK_TRUST Object    ${object_id}
        ...                                                                             ${admin_connection}
        Run Keyword If            ${is_object_exist}      Set To Dictionary             ${object_dict}
        ...                                                                             ${object_id}
        ...                                                                             ${object_ipv4}
    END
    [Return]      ${object_dict}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get All Existing XNLINK Objects
    ${admin_connection}=          Connect To ADMIN
    coam_admin.get_current_scf_file    local_dir_path=/tmp/
    ...                           file_name=full_scf.xml
    ...                           export_type=configurationAndRuntimeObjects
    ...                           connection=${admin_connection}
    ...                           timeout=90
    scf.load_scf                  /tmp/full_scf.xml
    &{object_dict}=               Create Dictionary
    FOR  ${object_id}  IN RANGE  1  257
        ${dist_name}=             Set Variable            MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK-${object_id}
        ${is_object_exist}=       scf.is_object_in_scf    ${dist_name}
        ${object_ipv4}=           Run Keyword If          ${is_object_exist}
        ...                       Get IPv4 Address Of Existing XNLINK Object            ${object_id}
        ...                                                                             ${admin_connection}
        Run Keyword If            ${is_object_exist}      Set To Dictionary             ${object_dict}
        ...                                                                             ${object_id}
        ...                                                                             ${object_ipv4}
    END
    [Return]      ${object_dict}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get All Existing NRADJGNB Objects
    ${admin_connection}=          Connect To ADMIN
    coam_admin.get_current_scf_file    local_dir_path=/tmp/
    ...                                file_name=full_scf.xml
    ...                                export_type=configurationAndRuntimeObjects
    ...                                connection=${admin_connection}
    ...                                timeout=90
    scf.load_scf                       /tmp/full_scf.xml
    @{object_list}=               Create List
    FOR  ${object_id}  IN RANGE  1  257
        ${dist_name}=             Set Variable            MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
        ${is_object_exist}=       scf.is_object_in_scf    ${dist_name}
        Run Keyword If            ${is_object_exist}      Append To List    ${object_list}    ${object_id}
    END
    [Return]      ${object_list}
    [Teardown]    Disconnect From ADMIN    connection=${admin_connection}

Get IPv4 Address Of Existing NRX2LINK_TRUST Object
    [Arguments]              ${object_id}    ${admin_connection}
    ${dist_name}=            Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRX2LINK_TRUST-${object_id}
    ${ipv4_values}=          admin.Check Current Parameter Value    param_name=ipV4Addr
    ...                                                             dist_name=${dist_name}
    ...                                                             connection=${admin_connection}
    ${nrx2link_trust_ip}=    Set Variable                           ${ipv4_values[0]}
    [Return]                 ${nrx2link_trust_ip}

Get IPv4 Address Of Existing XNLINK Object
    [Arguments]              ${object_id}    ${admin_connection}
    ${dist_name}=            Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK-${object_id}
    ${ipv4_values}=          admin.Check Current Parameter Value    param_name=cPlaneIpAddr
    ...                                                             dist_name=${dist_name}
    ...                                                             connection=${admin_connection}
    ${xnlink_ip}=            Set Variable                           ${ipv4_values[0]}
    [Return]                 ${xnlink_ip}

Get Free NRX2LINK_TRUST Object Id
    ${existing_objects}=        Get All Existing NRX2LINK_TRUST Objects
    ${existing_objects_ids}=    Get Dictionary Keys    ${existing_objects}
    ${free_object_id}=          Set Variable           ${NONE}
    FOR  ${object_id}  IN RANGE  1  513
        ${status}=            Run Keyword And Return Status    List Should Not Contain Value    ${existing_objects_ids}
        ...                                                                                     ${object_id}
        ${free_object_id}=    Set Variable If                  '${status}' == 'True'            ${object_id}
        Exit For Loop If      '${status}' == 'True'
    END
    Run Keyword If    '${free_object_id}' == '${NONE}'    Fail
    ...                                                   Max amount of NRX2LINK_TRUST objects already exist on BTS
    [Return]           ${free_object_id}

Get Free XNLINK Object Id
    ${existing_objects}=        Get All Existing XNLINK Objects
    ${existing_objects_ids}=    Get Dictionary Keys    ${existing_objects}
    ${free_object_id}=          Set Variable           ${NONE}
    FOR  ${object_id}  IN RANGE  1  257
        ${status}=            Run Keyword And Return Status    List Should Not Contain Value    ${existing_objects_ids}
        ...                                                                                     ${object_id}
        ${free_object_id}=    Set Variable If                  '${status}' == 'True'            ${object_id}
        Exit For Loop If      '${status}' == 'True'
    END
    Run Keyword If    '${free_object_id}' == '${NONE}'    Fail
    ...                                                   Max amount of XNLINK objects already exist on BTS
    [Return]           ${free_object_id}

Get Free NRADJGNB Object Id
    ${existing_objects_ids}=    Get All Existing NRADJGNB Objects
    ${free_object_id}=          Set Variable           ${NONE}
    FOR  ${object_id}  IN RANGE  1  257
        ${status}=            Run Keyword And Return Status    List Should Not Contain Value    ${existing_objects_ids}
        ...                                                                                     ${object_id}
        ${free_object_id}=    Set Variable If                  '${status}' == 'True'            ${object_id}
        Exit For Loop If      '${status}' == 'True'
    END
    Run Keyword If    '${free_object_id}' == '${NONE}'    Fail
    ...                                                   Max amount of NRADJGNB objects already exist on BTS
    [Return]           ${free_object_id}

Delete All NRADJGNB Objects
    ${existing_objects_ids}=    Get All Existing NRADJGNB Objects
    ${parameter}=               Create List
    ${conn}=    Connect to ADMIN
    FOR   ${object_id}   IN   @{existing_objects_ids}
        coam_admin.Perform Object Recommissioning
        ...         dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-${object_id}
        ...         parameter=${parameter}
        ...         operation=delete
        ...         connection=${conn}
    END
    [Teardown]    Disconnect from ADMIN    connection=${conn}

Change State Of Objects By Delta
    [Arguments]    ${objects_delta}
    ${admin_connection}=                              Connect To ADMIN
    Recommission Parameters By Delta                  delta=${objects_delta}    connection=${admin_connection}
    Wait Until BTS Reach Configured Or OnAir State    connection=${admin_connection}
    Sleep    2m   reason=Waiting until ruleset file will be updated
    [Teardown]    Disconnect From ADMIN               connection=${admin_connection}

Check UE Traffic From UE Shell
    Start Tcpdump
    Prepare And Attach UE    ${UE1_PDU}    ${UE1_ALIAS}    ${UE1_CAPABILITIES}
    Prepare And Attach UE    ${UE2_PDU}    ${UE2_ALIAS}    ${UE2_CAPABILITIES}
    ${ue1_ip_address}=            Get UE IP Address     ${UE1_ALIAS}
    ${ue2_ip_address}=            Get UE IP Address     ${UE2_ALIAS}
    Send Packets From UE Shell    ${UE_PC_IP}           ${UE_PC_USERNAME}     ${UE_PC_PASSWORD}
    ...                           ${UE1_SERIAL}         ${PORT}               ${ue2_ip_address}
    ${full_pcap_path}=            Stop Tcpdump And Download Pcap     tcpdump_filename=traffic.pcap
    PCAP Should Contain Address   ${ue1_ip_address}     ${full_pcap_path}
    [Teardown]    Run Keywords    Release UE    ${UE1_ALIAS}    ${UE1_PDU}
    ...           AND             Release UE    ${UE2_ALIAS}    ${UE2_PDU}
    ...           AND             Run Keyword And Ignore Error    TCPDump Teardown

Check UE Traffic From Appserv
    Start Tcpdump
    ${ue_ip}=             Perform UE Traffic By Appserv     ${UE1_PDU}
    ...                                                     ${UE1_ALIAS}
    ...                                                     ${UE1_CAPABILITIES}
    ${full_pcap_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=traffic.pcap
    PCAP Should Contain Address                             ${ue_ip}    ${full_pcap_path}
    ...           AND             Run Keyword And Ignore Error    TCPDump Teardown

Get New IPv4 Address
    [Arguments]     ${ipv4}
    ${new_ipv4_address}=    9131.modify_ipv4_address    ${ipv4}
    [Return]    ${new_ipv4_address}

Get New IPv6 Address
    [Arguments]    ${ipv6}
    ${new_ipv6_address}=    9131.modify_ipv6_address    ${ipv6}
    [Return]    ${new_ipv6_address}

Check If IP Address Is Correct
    [Arguments]    ${address}
    ${status}=    9131.check_if_ruleset_contains_address    ${NFT_RULESET}    ${address}    True
    [Return]    ${status}

Check If IP Address Is Not Correct
    [Arguments]    ${address}
    ${status}=    9131.check_if_ruleset_contains_address    ${NFT_RULESET}    ${address}    False
    [Return]    ${status}

Check If Object Exist On BTS
    [Arguments]    ${object_name}
    Connect to ADMIN     alias=check_object_exist
    ${object_status}     commissioning.Check if Object Exists in Scf File
    ...                  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/
    ...                  object_name=${object_name}
    ...                  timeout=900
    ...                  connection=check_object_exist
    Should Be True       ${object_status}
    [Teardown]    Disconnect from ADMIN    connection=check_object_exist

Insert nft Rule
    [Arguments]    ${ip_ver}    ${remote_addr}    ${local_addr}    ${sport}    ${dport}
    &{values}=  CREATE DICTIONARY
    ...         ipv4=ip
    ...         ipv6=ip6
    ${base_command}=    Set Variable    nft insert rule ${values["${ip_ver}"]} filter NGXN_CHAIN sctp sport { ${sport} } sctp dport { ${dport} }
    ${ssh_conn}=    Connect to BTS
    ${full_command}=   SSH.Execute
    ...  command=${base_command} ${values["${ip_ver}"]} saddr { ${remote_addr} } ${values["${ip_ver}"]} daddr { ${local_addr} } counter accept
    ...  connection=${ssh_conn}
    [Teardown]    Disconnect from BTS

Get Firewall Rule Handle ID Number
    [Arguments]    ${ip_ver}    ${remote_addr}    ${local_addr}
    &{values}=    CREATE DICTIONARY
    ...           ipv4=ip
    ...           ipv6=ip6
    ${ip_val}=    Set Variable    ${values["${ip_ver}"]}
    ${ssh_conn}=       Connect to BTS
    ${active_rules}=   SSH.Execute
    ...  command=nft list table ${ip_val} filter -a | grep "${ip_val} saddr { ${remote_addr} } ${ip_val} daddr { ${local_addr} }"
    ...  connection=${ssh_conn}
    Log    Active ${ip_val} firewall rules: \n${active_rules}    console=True
    @{words}=                 Split String         ${active_rules}    ${SPACE}
    ${last_element}=          Set Variable      ${words}[-1]
    ${last_element_clear}=    Replace String    ${last_element}    \r\n    ${EMPTY}
    [Return]      ${last_element_clear}
    [Teardown]    Disconnect from BTS

Delete Firewall Rule By Handle ID Number
    [Arguments]    ${ip_ver}    ${rule_id}
    &{values}=    CREATE DICTIONARY
    ...           ipv4=ip
    ...           ipv6=ip6
    ${ip_val}=    Set Variable    ${values["${ip_ver}"]}
    ${ssh_conn}=       Connect to BTS
    ${active_rules}=   SSH.Execute
    ...  command=nft delete rule ${ip_val} filter NGXN_CHAIN handle ${rule_id}
    ...  connection=${ssh_conn}
    Log    Deleted ${ip_val} firewall rule id: ${rule_id}    console=True
    [Teardown]    Disconnect from BTS

Manage Firewall Rules By ID Number
    [Arguments]    ${locXnCTnl1v4}    ${locNgCTnl1v6}    ${remXnCTnl1v4}    ${remNgCTnl1v6}
    Insert nft Rule    ip_ver=ipv4    remote_addr=${remXnCTnl1v4}
    ...                local_addr=${locXnCTnl1v4}    sport=38422    dport=38422
    Insert nft Rule    ip_ver=ipv6    remote_addr=${remNgCTnl1v6}
    ...                local_addr=${locNgCTnl1v6}    sport=38412    dport=38412
    ${rule_v4_id}=    Get Firewall Rule Handle ID Number       ip_ver=ipv4
    ...                                                        remote_addr=${remXnCTnl1v4}
    ...                                                        local_addr=${locXNCTnl1v4}
    ${rule_v6_id}=    Get Firewall Rule Handle ID Number       ip_ver=ipv6
    ...                                                        remote_addr=${remNgCTnl1v6}
    ...                                                        local_addr=${locNgCTnl1v6}
    Delete Firewall Rule By Handle ID Number    ip_ver=ipv4    rule_id=${rule_v4_id}
    Delete Firewall Rule By Handle ID Number    ip_ver=ipv6    rule_id=${rule_v6_id}

Verify If Firewall Process Is Running
    ${ssh_conn}=       Connect to BTS
    ${firewall_running}=   SSH.Execute
    ...                        command=ps -ef | grep opt/trs/bin/trs-vpp
    ...                        connection=${ssh_conn}
    Should Contain    ${firewall_running}    opt/trs/bin/trs-vpp
    [Teardown]    Disconnect from BTS

Verify If XNLINK And NRADJGNB Objects Exists On BTS
    ${robustness_verify_conn}=    Connect to ADMIN    alias=robustness_verify_conn
    Check If Object Exist On BTS    object_name=XNLINK
    ${xnlink}=    Check current parameter value
    ...                 dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/XNLINK
    ...                 param_name=xnLinkStatus    connection=${robustness_verify_conn}
    Check If Object Exist On BTS    object_name=SERVEDAMF
    ${nglink}=    Check current parameter value
    ...                 dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/SERVEDAMF
    ...                 param_name=ngLinkStatus    connection=${robustness_verify_conn}
    [Teardown]    Disconnect from ADMIN    connection=${robustness_verify_conn}

Get nft List Ruleset Output To File
    ${ssh_conn}=    Connect to BTS
    SSH.Execute     command=nft list ruleset > /user/toor4nsn/nft_list_ruleset.txt    connection=${ssh_conn}
    [Teardown]    Disconnect from BTS

Download nft List Ruleset Output File
    [Documentation]    The file is downloaded from SMOD to VM so that it can be placed in the log folder.
    ...                This file can be useful in troubleshooting while maintenance the test in regression.
    Run    sshpass -p "oZPS0POrRieRtu" scp toor4nsn@192.168.255.129:/user/toor4nsn/nft_list_ruleset.txt ${OUTPUT_DIR}/nft_list_ruleset.txt

Remove nft List Ruleset Output File From SMOD
    ${ssh_conn}=    Connect to BTS
    SSH.Execute     command=rm /user/toor4nsn/nft_list_ruleset.txt    connection=${ssh_conn}
    [Teardown]    Disconnect from BTS

Manage nft List Ruleset Output File
    Get nft List Ruleset Output To File
    Download nft List Ruleset Output File
    Remove nft List Ruleset Output File From SMOD

Regex depends on SW
    [Arguments]    ${sw_release}
    ${regex_x2Cplane}=   Run Keyword If  '${sw_release}'=='SBTS24R1' or '${sw_release}'=='SBTS24R2'
    ...                  Set Variable   x2CplaneRemoteIpAddrList.*\n.*ipv4[^}]*
    ...                  ELSE    Set Variable    x2Cplane5gRemoteIpAddrList.*\n.*ipv4[^}]*
    [Return]    ${regex_x2Cplane}

Check If Sw Release Is 24Rx
    [Arguments]    ${sw_release}
    ${is_not_24Rx}=   Evaluate    not re.match(r'^SBTS24R[1-3]$', '''${sw_release}''')    modules=re
    [Return]    ${is_not_24Rx}
