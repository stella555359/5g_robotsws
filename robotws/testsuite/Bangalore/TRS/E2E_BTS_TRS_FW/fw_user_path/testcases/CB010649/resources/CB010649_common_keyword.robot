*** Settings ***
Documentation
...     [Author]        "Sushma"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Check Ipsec tunnel status in vDU for Cplane
    ${Status}=   Get Ipsec Associations     policy_id=${policy_id_1}      tnl_pod_hostname=${pod_hostname_vdu}
    ...     dut=vdu_user    timeout=60    alias=vdu
    ${Values}=   Get Dictionary Values   ${Status}
    ${string}=  Convert To String   ${Values}
    Should Contain Any  ${string}   Established

Check Ipsec tunnel status in vDU for Uplane
    ${Status}=   Get Ipsec Associations     policy_id=${policy_id_2}      tnl_pod_hostname=${pod_hostname_vdu_1}
    ...     dut=vdu_user    timeout=60    alias=vdu
    ${Values}=   Get Dictionary Values   ${Status}
    ${string}=  Convert To String   ${Values}
    Should Contain Any  ${string}   Established

Restore default certificates
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Sleep   30

Triger CMP IR to install certificates on vDU
    [Arguments]     ${keypoolType}
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user     operation=set_certificate_automatic_management
    ...     reference_number=${refnum}  preshared_key=${psk}   key_pool_type=${keypoolType}   alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vdu
    Sleep   30