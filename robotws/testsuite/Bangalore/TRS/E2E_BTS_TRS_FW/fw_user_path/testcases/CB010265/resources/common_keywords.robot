*** Settings ***
Documentation   [Author]        "Shivani Patil"
...             [Maintenance]   "TRS I & V Tools Bangalore Team"

variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
*** Variables ***
${tc_variables}     testcase_variables.json

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

Verify Basic Syslog Error Prints
    [Arguments]     ${alias}
    ${tas_err_count}=   Analyse Syslog      analysis=verify_tas_error_signature     alias=${alias}
    Should Be True  ${tas_err_count}<=10
    ${lfs_err_count}=   Analyse Syslog      analysis=verify_lfs_error_signature     alias=${alias}
    Should Be True  ${lfs_err_count}<=10
    ${wrn_err_count}=   Analyse Syslog      analysis=verify_wrn_error_signature     alias=${alias}
    Should Be True  ${wrn_err_count}<=10
    ${trswsyslog_err_count}=    Analyse Syslog      analysis=verify_trswsyslog_error_signature     alias=${alias}
     Should Be True  ${trswsyslog_err_count}<=10
    ${trs_fatal_err_count}=     Analyse Syslog      analysis=verify_trs_fatal_error_signature     alias=${alias}
    Should Be True  ${trs_fatal_err_count}<1
    ${trswsyslog_wrn_count}=          Analyse Syslog                  analysis=verify_trswsyslog_warning_signature     alias=${alias}
    Should Be True  ${trswsyslog_wrn_count}<10
    ${tem_wrn_count}=          Analyse Syslog                  analysis=verify_tem_warning_signature     alias=${alias}
    Should Be True  ${tem_wrn_count}<1
    ${tem_error_count}=          Analyse Syslog                  analysis=verify_tem_error_signature     alias=${alias}
    Should Be True  ${tem_error_count}<1
    ${tem_wrn_count}=          Analyse Syslog                  analysis=verify_tas_warning_signature     alias=${alias}
    Should Be True  ${tem_wrn_count}<1
    ${tem_error_count}=          Analyse Syslog                  analysis=verify_tas_error_signature     alias=${alias}
    Should Be True  ${tem_error_count}<1

Execute command on gNB
        [Arguments]     ${cmd}
        Setup Remote Access    remote_device=bts
        ${stdout}       Remote Command Execute      command=${cmd}
        Set Suite Variable          ${stdout}
        [Teardown]      Teardown remote Access

Setup Preconditions for vcu_user
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=vcu_user      alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_user     alias=${component}

Triger CMP IR to install certificates on vCU
    [Arguments]     ${keypoolType}
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user     operation=set_certificate_automatic_management
    ...     reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30
     Certificate Configure   dut=vdu_9373_b     operation=set_certificate_automatic_management
     ...    reference_number=14251  preshared_key=this_is_very_secret   key_pool_type=${keypoolType2}   alias=con22
    Sleep   60
    Certificate Configure   dut=vdu_9373_b    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType2}  alias=con22
    Sleep   60
 
Setup Postconditions for vcu_user
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=vcu_user      alias=${component}    AND     Collect Snapshot
    ...     dut=vcu_user    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_user     alias=${component}
