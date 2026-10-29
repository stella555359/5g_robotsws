*** Settings ***
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
    Run Keywords    Setup Oamops    dut=vdu_user      alias=${component}    AND     Collect Snapshot
    ...     dut=vdu_user    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vdu_user     alias=${component}

Perform delta config and add cmp parameters
    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${Add_RSA_ECDSA_Mandatory_paramters_vDU}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu
    Sleep   30

Verify cmp about to expire alarms should not exist in vDU
    Verify Alarm    alias=vdu    faultid=61011    should_exist=${False}    dut=vdu_user
    Verify Alarm    alias=vdu    faultid=61618    should_exist=${False}    dut=vdu_user

Restore default certificates
    Certificate Configure   dut=vdu_user     operation=restore_vendor_certificate      alias=vdu
    Sleep   30

Perform Recommissioning with necertificateupdatetime to morethan cert validity time
    Perform Commissioning      scf_file=${25R3_change_necert_to_morethan_cert_validity_vDU}      timeout=300      dut=vdu_user
    ...     alias=vdu
    Sleep   30

Install cmp certificate trigger IR
   Certificate Configure   dut=vdu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vdu
    Sleep   30

Verify cmp necert about to expire alarms should exist in vDU after changing necert parameter
    Verify Alarm    alias=vdu    faultid=61011    should_exist=${True}    dut=vdu_user      occurrences=2
    Verify Alarm    alias=vdu    faultid=61618    should_exist=${True}    dut=vdu_user      occurrences=2

Perform Recommissioning with cacertificateupdatetime to morethan cert validity time
    Perform Commissioning      scf_file=${25R3_Change_cacert_to_morethan_cert_validity_vDU}      timeout=300      dut=vdu_user
    ...     alias=vdu
    Sleep   30

Verify cmp cacert about to expire alarms should exist in vDu after changing cacert parameter
    Verify Alarm    alias=vdu    faultid=61011    should_exist=${True}    dut=vdu_user     occurrences=2
    Verify Alarm    alias=vdu    faultid=61618    should_exist=${True}    dut=vdu_user     occurrences=4

Revert cacert and necert values to lessthan cert validity time
    Perform Commissioning      scf_file=${25R3_revert_necert_and_cacert_to_lessthan_cert_validity_vDU}      timeout=300      dut=vdu_user
    ...     alias=vdu
    Sleep   30

Perform Recommissioning of cacert and necert update time
    Perform Commissioning      scf_file=${25R3_change_necert_and_cacert_to_morethan_cert_validity_vDU}      timeout=300      dut=vdu_user
    ...     alias=vdu
    Sleep   30

Verify cmp necert and cacert about to expire alarms should exist in vDu after changing cacert and necert parameter
    Verify Alarm    alias=vdu    faultid=61011    should_exist=${True}    dut=vdu_user     occurrences=2
    Verify Alarm    alias=vdu    faultid=61618    should_exist=${True}    dut=vdu_user     occurrences=4

Verify cmp about to expiry alarms should exist in vDU after reboot
    Setup Oamops    dut=vdu_user        alias=vdu
    Verify Alarm    alias=vdu    faultid=61011    should_exist=${True}    dut=vdu_user     occurrences=2
    Verify Alarm    alias=vdu    faultid=61618    should_exist=${True}    dut=vdu_user     occurrences=4
    Teardown Oamops    dut=vdu_user      alias=vdu

Perform vDU reset
    Login vDU
    Reset    operation=reset_bts    rat=nr    dut=vdu_user    alias=vdu    should_be_onair=${False}
    ...     verify_bts=${True}
    Sleep   300
    Logout vDU

Login vDU
    Setup Oamops    dut=vdu_user        timeout=100      alias=vdu

Logout vDU
    Teardown Oamops    dut=vdu_user      timeout=100      alias=vdu


