*** Settings ***
Documentation
...              test scenario author: Mariusz Wojcik
...              contact: mariusz.wojcik@nokia.com
...              test automation author: Mariusz Wojcik
...              contact: mariusz.wojcik@nokia.com
...              maintenance: Mariusz Wojcik    contact: mariusz.wojcik@nokia.com

Resource         ../Resources/9131_Keywords.robot

*** Variables ***
${LOC_XN_CTNL1_V4}=    10.44.91.174
${REM_XN_CTNL1_V4}=    10.44.64.98
${LOC_NG_CTNL1_V6}=    2a00:8a00:6000:607c::1:c21e
${REM_NG_CTNL1_V6}=    2222:2222:2222:2222::2222

*** Keywords ***
CB009131_Add_modify_remove_trusted_eNB_neighbor_in_firewall_configuration
    Set actDynamicFirewall Feature Status
    ${new_x2link_id}=                             Get Free NRX2LINK_TRUST Object Id
    ${new_x2link_ip}=                             Create New NRX2LINK_TRUST Object         ${new_x2link_id}
    ${sw_release}=                                Get Software Release Name
    ${regex_x2Cplane}=                            Regex depends on SW   ${sw_release}
    Check If X2 Firewall Rule Is Added            ${new_x2link_ip}    ${regex_x2Cplane}
    ${modified_x2link_ip}=                        Modify Existing NRX2LINK_TRUST Object    ${new_x2link_id}
    Check If X2 Firewall Rule Is Added            ${modified_x2link_ip}    ${regex_x2Cplane}
    Check If X2 Firewall Rule Is Removed          ${new_x2link_ip}
    Check If Firewall Rule Is Removed Globally    ${new_x2link_ip}
    ${removed_x2link_ip}=                         Delete Existing NRX2LINK_TRUST Object    ${new_x2link_id}
    Check If X2 Firewall Rule Is Removed          ${removed_x2link_ip}
    Check If Firewall Rule Is Removed Globally    ${removed_x2link_ip}
    [Teardown]  Run Keywords    Set actDynamicFirewall Feature Status    status=false
    ...         AND             Run Keyword And Ignore Error    Delete Existing NRX2LINK_TRUST Object  ${new_x2link_id}
    ...         AND             Delete All NRADJGNB Objects

CB009131_Add_modify_remove_max_trusted_eNB_neighbor_in_firewall_configuration
    ${excess_address}=                                                Set Variable    1.2.3.4
    Set actDynamicFirewall Feature Status
    ${NRX2LINK_TRUST_IP_list}=                                        Create Max Amount Of NRX2LINK_TRUST Objects
    Check If All NRX2LINK_TRUST Objects Are Added To Firewall         ${NRX2LINK_TRUST_IP_list}
    Log    Checking if too much objects can't be added                console=true
    Run Keyword And Expect Error    *VALUE_IS_TOO_BIG*                Create New NRX2LINK_TRUST Object
    ...                                                               object_id=513
    ...                                                               ipv4=${excess_address}
    Check If X2 Firewall Rule Is Removed                              ${excess_address}
    Check If Firewall Rule Is Removed Globally                        ${excess_address}
    ${modified_NRX2LINK_TRUST_IP_list}=                               Modify Max Amount Of NRX2LINK_TRUST Objects
    Check If All NRX2LINK_TRUST Objects Are Added To Firewall         ${modified_NRX2LINK_TRUST_IP_list}
    Check If Firewall Has No Rules For Old NRX2LINK_TRUST Objects     ${NRX2LINK_TRUST_IP_list}
    Remove Max Amount Of NRX2LINK_TRUST Objects
    Check If Firewall Has No Rules For Old NRX2LINK_TRUST Objects     ${modified_NRX2LINK_TRUST_IP_list}
    [Teardown]  Run Keywords    Set actDynamicFirewall Feature Status    status=false
    ...         AND             Run Keyword And Ignore Error             Remove Max Amount Of NRX2LINK_TRUST Objects
    ...         AND             Delete All NRADJGNB Objects

CB009131_Add_modify_remove_trusted_gNB_neighbor_in_firewall_configuration
    Set actDynamicFirewall Feature Status
    ${nradjgnb_id}=                               Get Free NRADJGNB Object Id
    ${xnlink_1_id}=                               Get Free XNLINK Object Id
    ${xnlink_1_ip}=                               Create New XNLINK Object    ${xnlink_1_id}
    Create New NRADJGNB Object                    ${nradjgnb_id}              ${xnlink_1_id}    ${xnlink_1_ip}
    Check If XN Firewall Rule Is Added            ${xnlink_1_ip}
    ${xnlink_2_id}=                               Get Free XNLINK Object Id
    ${xnlink_2_ip}=                               Create New XNLINK Object    ${xnlink_2_id}    2.2.2.3
    ${current_sw_version}=    Get Software Release Name
    ${current_sw_trunk_status}=  Check If Sw Release Is 24Rx  ${current_sw_version}
    Run Keyword If    ${current_sw_trunk_status} == True
    ...    Set NRADJGNB AdministrativeState To Locked    ${nradjgnb_id}
    Modify Existing NRADJGNB Object               ${nradjgnb_id}              ${xnlink_2_id}    ${xnlink_2_ip}
    Delete Existing XNLINK Object                 ${xnlink_1_id}
    Check If XN Firewall Rule Is Added            ${xnlink_2_ip}
    Check If XN Firewall Rule Is Removed          ${xnlink_1_ip}
    Delete Existing NRADJGNB Object               ${nradjgnb_id}
    Delete Existing XNLINK Object                 ${xnlink_2_id}
    Check If XN Firewall Rule Is Removed          ${xnlink_2_ip}
    Check If Firewall Rule Is Removed Globally    ${xnlink_1_ip}
    Check If Firewall Rule Is Removed Globally    ${xnlink_2_ip}
    [Teardown]  Run Keywords  Set actDynamicFirewall Feature Status    status=false
    ...         AND           Run Keyword And Ignore Error             Delete Existing NRADJGNB Object    ${nradjgnb_id}
    ...         AND           Run Keyword And Ignore Error             Delete Existing XNLINK Object      ${xnlink_1_id}
    ...         AND           Run Keyword And Ignore Error             Delete Existing XNLINK Object      ${xnlink_2_id}
    ...         AND           Delete All NRADJGNB Objects

CB009131_Activation_and_deactivation_feature_at_runtime_IPv4_IPv6
    Remove All Existing NRX2LINK_TRUST Objects
    Create All Necessary NRX2LINK_TRUST Objects
    @{nrx2link_trust_ipv4_addresses_list}=    Get IPv4 Addresses NRX2LINK_TRUST Objects
    @{nrx2link_trust_ipv6_addresses_list}=    Get IPv6 Addresses NRX2LINK_TRUST Objects
    Log  ${nrx2link_trust_ipv4_addresses_list}  console=${TRUE}
    Log  ${nrx2link_trust_ipv6_addresses_list}  console=${TRUE}
    Set ActDynamicFirewall Feature Status  status=true

    FOR  ${ipv4_address}  IN  @{nrx2link_trust_ipv4_addresses_list}
        Check If NRX2LINK_TRUST IPv4 Firewall Rule Is Added When ActDynamicFirewall Is True    ${ipv4_address}
    END

    FOR  ${ipv6_address}  IN  @{nrx2link_trust_ipv6_addresses_list}
        Check If NRX2LINK_TRUST IPv6 Firewall Rule Is Added When ActDynamicFirewall Is True    ${ipv6_address}
    END

    Set ActDynamicFirewall Feature Status  status=false

    FOR  ${ipv4_address}  IN  @{nrx2link_trust_ipv4_addresses_list}
        Check If NRX2LINK_TRUST IPv4 Firewall Rule Is Added When ActDynamicFirewall Is False    ${ipv4_address}
    END

    FOR  ${ipv6_address}  IN  @{nrx2link_trust_ipv6_addresses_list}
        Check If NRX2LINK_TRUST IPv6 Firewall Rule Is Added When ActDynamicFirewall Is False    ${ipv6_address}
    END

    [Teardown]    Set ActDynamicFirewall Feature Status  status=false

CB009131_Activation_and_deactivation_feature_at_runtime
    ${existing_objects}=                  Get All Existing NRX2LINK_TRUST Objects
    ${existing_objects_ipv4}=             Get Dictionary Values    ${existing_objects}
    Set ActDynamicFirewall Feature Status
    ${sw_release}=                           Get Software Release Name
    FOR  ${ipv4}  IN  @{existing_objects_ipv4}
        ${regex_x2Cplane}=                       Regex depends on SW   ${sw_release}
        Check If X2 Firewall Rule Is Added       ${ipv4}    ${regex_x2Cplane}
    END
    Set ActDynamicFirewall Feature Status    status=false
    FOR  ${ipv4}  IN  @{existing_objects_ipv4}
        ${regex_x2Cplane}=                       Regex depends on SW   ${sw_release}
        Check If X2 Firewall Rule Is Added       ${ipv4}    ${regex_x2Cplane}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Set actDynamicFirewall Feature Status    status=false
    ...           AND             Delete All NRADJGNB Objects

CB009131_Robustness_Frequent_addition_removal_of_firewall_rules
    Set actDynamicFirewall Feature Status
    ${nradjgnb_id}=                               Get Free NRADJGNB Object Id
    ${xnlink_1_id}=                               Get Free XNLINK Object Id
    ${xnlink_1_ip}=                               Create New XNLINK Object    ${xnlink_1_id}
    Create New NRADJGNB Object                    ${nradjgnb_id}              ${xnlink_1_id}    ${xnlink_1_ip}
    FOR    ${index}    IN RANGE    50
        Log   Iteration ${index} of robustness test start!      console=True
        Manage Firewall Rules By ID Number    locXnCTnl1v4=${LOC_XN_CTNL1_V4}    locNgCTnl1v6=${LOC_NG_CTNL1_V6}
        ...                                   remXnCTnl1v4=${REM_XN_CTNL1_V4}    remNgCTnl1v6=${REM_NG_CTNL1_V6}
        Log   Iteration ${index} of robustness test done!       console=True
    END
    Verify If Firewall Process Is Running
    Verify If XNLINK And NRADJGNB Objects Exists On BTS
    [Teardown]  Run Keywords  Set actDynamicFirewall Feature Status    status=false
    ...         AND           Run Keyword And Ignore Error             Delete Existing NRADJGNB Object    ${nradjgnb_id}
    ...         AND           Run Keyword And Ignore Error             Delete Existing XNLINK Object      ${xnlink_1_id}
    ...         AND           Delete All NRADJGNB Objects
