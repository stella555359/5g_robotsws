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

Input correct Psk and Refnum vCU
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


Input Incorrect Psk and Refnum vCU
    [Arguments]     ${keypoolType}      ${keypoolType2}
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user     operation=set_certificate_automatic_management
    ...     reference_number=${refnum_incorrect}  preshared_key=${psk_incorrect}   key_pool_type=${keypoolType}   alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user     operation=set_certificate_automatic_management
    ...    reference_number=${refnum_incorrect}  preshared_key=${psk_incorrect}   key_pool_type=${keypoolType2}   alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=vcu
    Sleep   30


Verify operator certificate retrieval alarms should not exist in vCU
    Verify Alarm    alias=vcu    faultid=61510    should_exist=${False}    dut=vcu_user     occurrences=0


Verify operator certificate retrieval alarms should exist in vCU
    Verify Alarm    alias=vcu    faultid=61510    should_exist=${True}    dut=vcu_user     occurrences=2


Setup Postconditions for vcu_user
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=vcu_user      alias=${component}    AND     Collect Snapshot
    ...     dut=vcu_user    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_user     alias=${component}

Perform delta config and add cmp parameters
    Perform Recommissioning     dut=vcu_user     type=delta      delta_file=${Add_RSA_ECDSA_Mandatory_paramters}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vcu
    Sleep   30

Verify cmp about to expire alarms should not exist in vCU
    Verify Alarm    alias=vcu    faultid=61011    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vcu    faultid=61618    should_exist=${False}    dut=vcu_user

Restore default certificates
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Sleep   30

Perform Recommissioning with necertificateupdatetime to morethan cert validity time
    Perform Commissioning      scf_file=${change_necert_to_morethan_cert_validity}      timeout=300      dut=vcu_user
    ...     alias=vcu
    Sleep   30

Install cmp certificate trigger IR
   Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30

Verify cmp necert about to expire alarms should exist in vCU after changing necert parameter
    Verify Alarm    alias=vcu    faultid=61011    should_exist=${True}    dut=vcu_user      occurrences=2
    Verify Alarm    alias=vcu    faultid=61618    should_exist=${True}    dut=vcu_user      occurrences=3

Perform Recommissioning with cacertificateupdatetime to morethan cert validity time
    Perform Commissioning      scf_file=${Change_cacert_to_morethan_cert_validity}      timeout=300      dut=vcu_user
    ...     alias=vcu

    Sleep   30

Verify cmp cacert about to expire alarms should exist in vCu after changing cacert parameter
    Verify Alarm    alias=vcu    faultid=61011    should_exist=${True}    dut=vcu_user     occurrences=2
    Verify Alarm    alias=vcu    faultid=61618    should_exist=${True}    dut=vcu_user     occurrences=4

Revert cacert and necert values to lessthan cert validity time
    Perform Commissioning      scf_file=${vcu_CB010265_base_scf}      timeout=300      dut=vcu_user    alias=vcu
    Sleep   30

Perform Recommissioning of cacert and necert update time
    Perform Commissioning      scf_file=${Change_cacert_to_morethan_cert_validity}      timeout=300      dut=vcu_user
    ...     alias=vcu
    Sleep   30

Verify cmp necert and cacert about to expire alarms should exist in vCu after changing cacert and necert parameter
    Verify Alarm    alias=vcu    faultid=61011    should_exist=${True}    dut=vcu_user     occurrences=2
    Verify Alarm    alias=vcu    faultid=61618    should_exist=${True}    dut=vcu_user     occurrences=4

Verify cmp about to expiry alarms should exist in vCU after reboot
    Setup Oamops    dut=vcu_user        alias=vcu
    Verify Alarm    alias=vcu    faultid=61011    should_exist=${True}    dut=vcu_user     occurrences=2
    Verify Alarm    alias=vcu    faultid=61618    should_exist=${True}    dut=vcu_user     occurrences=4
    Teardown Oamops    dut=vcu_user      alias=vcu

Perform vCU reset
    Login vCU
    Reset    operation=reset_bts    rat=5g    dut=vcu_user    alias=vcu    should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vCU

Login vCU
    Setup Oamops    dut=vcu_user        timeout=100      alias=vcu

Logout vCU
    Teardown Oamops    dut=vcu_user      timeout=100      alias=vcu


