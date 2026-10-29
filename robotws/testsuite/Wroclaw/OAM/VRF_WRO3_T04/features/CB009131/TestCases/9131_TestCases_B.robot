*** Settings ***
Documentation
...              test scenario author: Mariusz Wojcik
...              contact: mariusz.wojcik@nokia.com
...              test automation author: Mariusz Wojcik
...              contact: mariusz.wojcik@nokia.com
...              maintenance: Mariusz Wojcik    contact: mariusz.wojcik@nokia.com

Resource         ../../../common_resources/admin/admin.robot
Resource         ../Resources/9131_Keywords.robot

*** Keywords ***
CB009131_Firewall_configuration_update_for_already_created_X2_link_IPv4_IPv6
    Add New NRX2LINK_TRUST Object    1.1.1.1    2a00:8a00:6000:607c::1:aaaa
    Set ActDynamicFirewall Feature Status    status=true
    @{nrx2link_trust_ipv4_addresses_list}=    Get IPv4 Addresses NRX2LINK_TRUST Objects
    @{nrx2link_trust_ipv6_addresses_list}=    Get IPv6 Addresses NRX2LINK_TRUST Objects
    Log  ${nrx2link_trust_ipv4_addresses_list}  console=${TRUE}
    Log  ${nrx2link_trust_ipv6_addresses_list}  console=${TRUE}

    FOR  ${ipv4_address}  IN  @{nrx2link_trust_ipv4_addresses_list}
        Check If NRX2LINK_TRUST IPv4 Firewall Rule Is Added When ActDynamicFirewall Is True    ${ipv4_address}
    END

    FOR  ${ipv6_address}  IN  @{nrx2link_trust_ipv6_addresses_list}
        Check If NRX2LINK_TRUST IPv6 Firewall Rule Is Added When ActDynamicFirewall Is True    ${ipv6_address}
    END

    [Teardown]    Set ActDynamicFirewall Feature Status    status=false

CB009131_Firewall_configuration_update_for_already_created_X2_link
    ${new_x2link_id}=                         Get Free NRX2LINK_TRUST Object Id
    ${new_x2link_ip}=                         Create New NRX2LINK_TRUST Object    ${new_x2link_id}
    Set ActDynamicFirewall Feature Status
    ${sw_release}=                           Get Software Release Name
    ${regex_x2Cplane}=                       Regex depends on SW   ${sw_release}
    Check If X2 Firewall Rule Is Added        ${new_x2link_ip}      ${regex_x2Cplane}
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Delete Existing NRX2LINK_TRUST Object    ${new_x2link_id}
    ...           AND             Delete All NRADJGNB Objects

CB009131_Firewall_configuration_update_for_already_created_Xn_link
    ${nradjgnb_id}=                               Get Free NRADJGNB Object Id
    ${xnlink_1_id}=                               Get Free XNLINK Object Id
    ${xnlink_1_ip}=                               Create New XNLINK Object    ${xnlink_1_id}
    Create New NRADJGNB Object                    ${nradjgnb_id}              ${xnlink_1_id}    ${xnlink_1_ip}
    Set ActDynamicFirewall Feature Status
    Check If XN Firewall Rule Is Added            ${xnlink_1_ip}
    [Teardown]  Run Keywords  Set actDynamicFirewall Feature Status    status=false
    ...         AND           Run Keyword And Ignore Error             Delete Existing NRADJGNB Object    ${nradjgnb_id}
    ...         AND           Run Keyword And Ignore Error             Delete Existing XNLINK Object      ${xnlink_1_id}
    ...         AND           Delete All NRADJGNB Objects

CB009131_Robustness_multiple_X2_link_stability_during_site_reset
    ${new_x2link_id}=                         Get Free NRX2LINK_TRUST Object Id
    ${new_x2link_ip}=                         Create New NRX2LINK_TRUST Object    ${new_x2link_id}
    FOR    ${loop_nr}    IN RANGE    10
        Log      Loop number ${loop_nr+1} started                   console=True
        Set ActDynamicFirewall Feature Status
        Reboot BTS and wait until available
        Wait Until BTS Reach Configured Or OnAir State
        Sleep    1m   reason=Waiting until ruleset file will be updated
        ${sw_release}=                           Get Software Release Name
        ${regex_x2Cplane}=                       Regex depends on SW   ${sw_release}
        Check If X2 Firewall Rule Is Added            ${new_x2link_ip}    ${regex_x2Cplane}
        Set ActDynamicFirewall Feature Status                       status=false
        Log      Loop number ${loop_nr+1} successfully completed    console=True
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Delete Existing NRX2LINK_TRUST Object    ${new_x2link_id}
    ...           AND             Delete All NRADJGNB Objects

CB009131_X2_C_plane_address_change_detection_after_site_reset
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${X2C}
    Set IPv4 Address For X2 C-plane                 ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${X2C}
    Check UE Traffic From UE Shell
    Reset Site And Reconnect
    Wait Until BTS Reach Configured Or OnAir State
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${X2C}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For X2 C-plane          ${X2C}
    ...           AND             Delete All NRADJGNB Objects

CB009131_Xn_C_plane_address_change_detection_after_site_reset
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${XNC}
    Set IPv4 Address For XN C-plane                 ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${XNC}
    Check UE Traffic From UE Shell
    Reset Site And Reconnect
    Wait Until BTS Reach Configured Or OnAir State
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${XNC}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For XN C-plane          ${XNC}
    ...           AND             Delete All NRADJGNB Objects

CB009131_NG_C_plane_address_change_detection_after_site_reset
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${NGC}
    Set IPv4 Address For NG C-plane                 ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${NGC}
    Check UE Traffic From UE Shell
    Reset Site And Reconnect
    Wait Until BTS Reach Configured Or OnAir State
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${NGC}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For NG C-plane          ${NGC}
    ...           AND             Delete All NRADJGNB Objects

CB009131_U_plane_address_change_detection_after_site_reset
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=    Get New IPv4 Address    ${NGU}
    Set IPv4 Address For NG U-plane                 ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${NGU}
    Check UE Traffic From UE Shell
    Reset Site And Reconnect
    Wait Until BTS Reach Configured Or OnAir State
    Check If Firewall Rule Is Added Globally        ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally      ${NGU}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For NG U-plane          ${NGU}
    ...           AND             Delete All NRADJGNB Objects

[1]CB009131_U_plane_address_change_detection
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=         Get New IPv4 Address    ${NGU}
    Set IPv4 Address For NG U-plane                      ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally             ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally           ${NGU}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For NG U-plane          ${NGU}
    ...           AND             Delete All NRADJGNB Objects

[1]CB009131_X2_C_plane_address_change_detection
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=         Get New IPv4 Address    ${X2C}
    Set IPv4 Address For X2 C-plane                      ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally             ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally           ${X2C}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For X2 C-plane          ${X2C}
    ...           AND             Delete All NRADJGNB Objects

[1]CB009131_NG_C_plane_address_change_detection
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=         Get New IPv4 Address    ${NGC}
    Set IPv4 Address For NG C-plane                      ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally             ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally           ${NGC}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For X2 C-plane          ${NGCNGC}
    ...           AND             Delete All NRADJGNB Objects

[1]CB009131_Xn_C_plane_address_change_detection
    Set ActDynamicFirewall Feature Status
    ${new_ipv4_address}=         Get New IPv4 Address    ${XNC}
    Set IPv4 Address For XN C-plane                      ${new_ipv4_address}
    Check If Firewall Rule Is Added Globally             ${new_ipv4_address}
    Check If Firewall Rule Is Removed Globally           ${XNC}
    Check UE Traffic From UE Shell
    [Teardown]    Run Keywords    Set ActDynamicFirewall Feature Status    status=false
    ...           AND             Set IPv4 Address For X2 C-plane          ${XNC}
    ...           AND             Delete All NRADJGNB Objects
