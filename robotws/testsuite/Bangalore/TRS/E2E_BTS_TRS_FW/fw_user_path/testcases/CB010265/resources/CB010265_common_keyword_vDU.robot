*** Settings ***
Documentation   [Author]        "Shivani Patil"
...             [Maintenance]   "TRS I & V Tools Bangalore Team"

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
    Stop Syslog   alias=collect_syslog

Triger CMP IR to install certificates on vDU
    [Arguments]     ${keypoolType}      ${keypoolType2}
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user     operation=set_certificate_automatic_management
    ...     reference_number=${refnum}  preshared_key=${psk}   key_pool_type=${keypoolType}   alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user     operation=set_certificate_automatic_management
    ...    reference_number=${refnum}  preshared_key=${psk}   key_pool_type=${keypoolType2}   alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=vdu
    Sleep   30
 
Setup Postconditions for vdu_user
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=vcu_user      alias=${component}    AND     Collect Snapshot
    ...     dut=vcu_user    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_user     alias=${component}

Perform delta config and enbale ipsec and add cmp parameters
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${Enable_ipsec_and_add_cmp_parameters_vdu}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu

Restore default certificates and check ipsec status
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Sleep   30

Check Ipsec tunnel status in vDU after restore vendor cert
    ${Status4}=   Get Ipsec Associations     policy_id=${policy_id_1}    tnl_pod_hostname=${pod_hostname_vdu}     dut=vdu_user
    ...		timeout=60    alias=vdu
    ${Values4}=   Get Dictionary Values   ${Status4}
    ${string4}=  Convert To String   ${Values4}
    Should Contain Any  ${string4}   Connecting

Check Ipsec tunnel status in vDU
    ${Status}=   Get Ipsec Associations     policy_id=${policy_id_1}      tnl_pod_hostname=${pod_hostname_vdu}     dut=vdu_user
    ...		timeout=60    alias=vdu
    ${Values}=   Get Dictionary Values   ${Status}
    ${string}=  Convert To String   ${Values}
    Should Contain Any  ${string}   Established

Verify alarms should not exist in vDU
    Verify Alarm    alias=vdu    faultid=61645    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61644    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61030    should_exist=${False}    dut=vdu_user

Restore default certificates and configure different cert
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${Configure_wrong_certificate_vDU_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   30
    Run Keyword And Ignore Error    Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vdu
    Sleep   30

Verify alarms should exist in vDU after differetn delta cert
    Login vDU    
    Verify Alarm    alias=vdu    faultid=61645    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61644    should_exist=${True}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61030    should_exist=${False}    dut=vdu_user
    Logout vDU

Check Ipsec tunnel status in vDU after differetn delta cert
    ${Status1}=     Get Ipsec Associations     policy_id=${policy_id_1}     tnl_pod_hostname=${pod_hostname_vdu}     dut=vdu_user
    ...		timeout=60    alias=vdu
    ${Values1}=   Get Dictionary Values   ${Status1}
    ${string1}=  Convert To String   ${Values1}
    Should Contain Any  ${string1}   Connecting

Restore default certificates and configure correct cert
    Login vDU
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${Configure_correct_certificate_vDU}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   30
    Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vdu
    Sleep   30

Verify alarms should not exist in vDU after correct delat cert
    Verify Alarm    alias=vdu    faultid=61645    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61644    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61030    should_exist=${False}    dut=vdu_user


 Check Ipsec tunnel status in vDU after correct delat cert
    ${Status2}=     Get Ipsec Associations     policy_id=${policy_id_1}   tnl_pod_hostname=${pod_hostname_vdu}     dut=vdu_user
    ...		timeout=60    alias=vdu
    ${Values2}=   Get Dictionary Values   ${Status2}
    ${string2}=  Convert To String   ${Values2}
    Should Contain Any  ${string2}   Established

Perform vDU reset
    Login vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_user    alias=vdu    should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vDU

Login vDU
    Setup Oamops    dut=vdu_user        timeout=100      alias=vdu

Logout vDU
    Teardown Oamops    dut=vdu_user      timeout=100      alias=vdu

Check Ipsec tunnel status in vDU after reboot
    Setup Oamops    dut=vdu_user    alias=vdu
    ${Status3}=   Get Ipsec Associations     policy_id=${policy_id_1}    tnl_pod_hostname=${pod_hostname_vdu}
    ...		dut=vdu_user    timeout=60    alias=vdu
    ${Values3}=   Get Dictionary Values   ${Status3}
    ${string3}=  Convert To String   ${Values3}
    Should Contain Any  ${string3}   Established
    Teardown Oamops    dut=vdu_user      alias=vdu

Verify alarms should not exist in vDU after reboot
    Setup Oamops    dut=vdu_user    alias=vdu
    Verify Alarm    alias=vdu   faultid=61645    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu   faultid=61644    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu   faultid=61030    should_exist=${False}    dut=vdu_user
    Teardown Oamops    dut=vdu_user      alias=vdu
