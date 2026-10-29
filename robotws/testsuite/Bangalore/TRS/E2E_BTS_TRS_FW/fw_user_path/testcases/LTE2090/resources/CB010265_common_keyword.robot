*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Feature_ID]            "CB010265"

variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
*** Variables ***
${keypoolType}      RSA
${keypoolType2}     ECDSA

*** Keywords ***
Pre-conditions for testsuite
    Suite Setup Preconditions
    Setup Oamops

Post-conditions for testteardown
    Teardown Oamops
    Suite Teardown Postconditions

Suite Setup Preconditions
    Start Syslog    log_dir=${EXECDIR}/execution_logs       log_name=background_syslog.txt      file_limit=50000000     alias=collect_syslog

Suite Teardown Postconditions
    Run Keyword And Ignore Error    Setup Oamops
    Collect Im Snapshot     timeout=300
    Collect Snapshot        timeout=1200
    [Teardown]  Run Keywords    Verify Basic Syslog Error Prints     collect_syslog   AND  Stop Syslog   alias=collect_syslog
#    Stop Syslog   alias=collect_syslog


Triger CMP IR to install certificates on vCU
    [Arguments]     ${keypoolType}      ${keypoolType2}
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user     operation=set_certificate_automatic_management
    ...     reference_number=${refnum}  preshared_key=${psk}   key_pool_type=${keypoolType}   alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user     operation=set_certificate_automatic_management
    ...    reference_number=${refnum}  preshared_key=${psk}   key_pool_type=${keypoolType2}   alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=vcu
    Sleep   30


Setup Postconditions for vcu_user
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=vcu_user      alias=${component}    AND     Collect Snapshot
    ...     dut=vcu_user    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_user     alias=${component}

Perform delta config and enbale ipsec and add cmp parameters
     Perform Recommissioning     dut=vcu_user     type=delta      delta_file=${Enable_ipsec_and_add_cmp_parameters_vcu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vcu

Restore default certificates and check ipsec status
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Sleep   30
#    Check Ipsec tunnel status in vCU after restore vendor cert

Check Ipsec tunnel status in vCU after restore vendor cert
    ${Status4}=   Get Ipsec Associations     policy_id=${policy_id}    tnl_pod_hostname=${pod_hostname}     dut=vcu_user    timeout=60    alias=vcu
    ${Values4}=   Get Dictionary Values   ${Status4}
    ${string4}=  Convert To String   ${Values4}
    Should Contain Any  ${string4}   Connecting


Check Ipsec tunnel status in vCU
    ${Status}=   Get Ipsec Associations     policy_id=${policy_id}    tnl_pod_hostname=${pod_hostname}     dut=vcu_user    timeout=60    alias=vcu
    ${Values}=   Get Dictionary Values   ${Status}
    ${string}=  Convert To String   ${Values}
    Should Contain Any  ${string}   Established

Verify alarms should not exist in vCU
    Verify Alarm    alias=vcu    faultid=61645    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user

Restore default certificates and configure different cert
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
#    Perform Recommissioning     dut=vcu_user     type=delta      delta_file=${Configure_wrong_certificate}
#    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
#    ...     alias=vcu
    Perform Commissioning      scf_file=${Configure_wrong_certificate}      timeout=300      dut=vcu_user
    ...     alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30
#    IPerform vCU reset

Verify alarms should exist in vCU after differetn delta cert
    Login vCU
    Verify Alarm    alias=vcu    faultid=61645    should_exist=${False}    dut=vcu_user
    Sleep   60
    Logout vCU
    Login vCU
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${True}    dut=vcu_user
    Sleep   30
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user


Check Ipsec tunnel status in vCU after differetn delta cert
    ${Status1}=     Get Ipsec Associations     policy_id=${policy_id}    tnl_pod_hostname=${pod_hostname}      dut=vcu_user    timeout=60    alias=vcu
    ${Values1}=   Get Dictionary Values   ${Status1}
    ${string1}=  Convert To String   ${Values1}
    Should Contain Any  ${string1}   Connecting

Restore default certificates and configure correct cert
     Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
#    Perform Recommissioning     dut=vcu_user     type=delta      delta_file=${Configure_correct_certificate}
#    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
#    ...     alias=vcu
#    Sleep   30
    Perform Commissioning      scf_file=${vcu_CB010265_base_scf_1}      timeout=300      dut=vcu_user    alias=vcu
    Sleep   30
    Run Keyword And Ignore Error    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate
    ...     timeout=120     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30

Verify alarms should not exist in vCU after correct delat cert
    Verify Alarm    alias=vcu    faultid=61645    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user


 Check Ipsec tunnel status in vCU after correct delat cert
    ${Status2}=     Get Ipsec Associations     policy_id=${policy_id}    tnl_pod_hostname=${pod_hostname}     dut=vcu_user    timeout=60    alias=vcu
    ${Values2}=   Get Dictionary Values   ${Status2}
    ${string2}=  Convert To String   ${Values2}
    Should Contain Any  ${string2}   Established

Perform vCU reset
    Login vCU
    Reset    operation=reset_bts    rat=5g    dut=vcu_user    alias=vcu    should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vCU

Login vCU
    Setup Oamops    dut=vcu_user        timeout=100      alias=vcu

Logout vCU
    Teardown Oamops    dut=vcu_user      timeout=100      alias=vcu

Check Ipsec tunnel status in vCU after reboot
    Setup Oamops    dut=vcu_user    alias=vcu
    ${Status3}=   Get Ipsec Associations     policy_id=${policy_id}    tnl_pod_hostname=${pod_hostname}     dut=vcu_user    timeout=60    alias=vcu
    ${Values3}=   Get Dictionary Values   ${Status3}
    ${string3}=  Convert To String   ${Values3}
    Should Contain Any  ${string3}   Established
    Teardown Oamops    dut=vcu_user      alias=vcu

Verify alarms should not exist in vCU after reboot
    Setup Oamops    dut=vcu_user    alias=vcu
    Verify Alarm    alias=vcu    faultid=61645    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user
    Teardown Oamops    dut=vcu_user      alias=vcu

