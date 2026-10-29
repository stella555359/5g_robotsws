*** Settings ***
Documentation
...		[Author]     	"Nupur"

Variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        packet_generation_verification_common_keywords.robot
Library    taf.sw.scout    WITH NAME    scout

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
    Get Hostname
#    Link SCOUT SCF to Configuration ID for Reporting        ${Hostname}

Suite Teardown Postconditions
    Run Keyword And Ignore Error    Setup Oamops
    Collect Im Snapshot     timeout=300
    Collect Snapshot        timeout=1200
    [Teardown]  Run Keywords    Verify Basic Syslog Error Prints     collect_syslog   AND  Stop Syslog   alias=collect_syslog

Get Hostname
    [Documentation]    Get hosename of test machine
    ${output}      Run      hostname
    ${Hostname}    Replace String   string=${output}     search_for=-     replace_with=_
    Set Suite variable  ${Hostname}

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]    ${tl_name_only}

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
#    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable      ute:id:${external_scf_id}
    Set Suite Variable  ${external_scf_id}
    Set Tags  ${TC_ID}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    RETURN   ${external_scf_id}

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

Execute command on Airphone
        [Arguments]     ${cmd}
        Setup Remote Access    remote_device=AP
        ${stdout}       Remote Command Execute      command=${cmd}
        Set Suite Variable          ${stdout}
        [Teardown]      Teardown remote Access

Install DNS package
    [Arguments]         ${zone_file_name}           ${DNS_zone_file_name}
    Create source_list file
    Run     sudo cp ${EXECDIR}/Source_list.txt /etc/apt/sources.list
    Create shell script
    Run     chmod +x ${EXECDIR}/bind9_install.sh
    Create expect script
    Run     expect ${EXECDIR}/bind9_install.exp
    Run     sudo apt-get install -y bind9 bind9utils bind9-doc dnsutils
    Run     sudo cp ${named_conf} /etc/bind/named.conf.local
    Run     sudo cp ${zone_file_name} /etc/bind/${DNS_zone_file_name}
    Run     sudo systemctl restart bind9
    Run     sudo systemctl enable bind9
    Run     sudo systemctl status bind9


Create source_list file
	${Source_list_Content}=       Catenate         deb http://repo.wroclaw.nsn-rdnet.net/debian stretch main contrib non-free${\n}
    ...     deb http://repo.wroclaw.nsn-rdnet.net/debian stretch-updates main contrib non-free${\n}
    ...     deb http://repo.wroclaw.nsn-rdnet.net/debian_security stretch/updates main contrib non-free${\n}
    ...     deb http://repo.wroclaw.nsn-rdnet.net/debian stretch-backports main contrib non-free
	Create File      ${EXECDIR}/Source_list.txt    ${Source_list_Content}

Create shell script
    ${shell_script_content}=       Catenate       \#!/bin/bash${\n}
    ...     sudo apt-get update${\n}
    ...     sleep      10${\n}
    ...     sudo apt-get install bind9${\n}
    ...     read $REPLY
    Create File      ${EXECDIR}/bind9_install.sh    ${shell_script_content}


Create expect script
    ${expect_script_content}=       Catenate        \#!/usr/bin/expect -f${\n}
    ...     spawn ./bind9_install.sh${\n}
    ...     expect  "\\[Y/n\\] "${\n}
    ...     send -- "y\\r"${\n}
    ...     set timeout 120${\n}
    ...     send -- "^C"${\n}
    ...     expect eof
    Create File      ${EXECDIR}/bind9_install.exp    ${expect_script_content}


Setup Preconditions for cbts
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=cbts      alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=cbts     alias=${component}

Setup Postconditions for cbts
    [Arguments]     ${component}
    Run Keywords    Setup Oamops    dut=cbts      alias=${component}    AND     Collect Snapshot
    ...     dut=cbts    operation_timeout=300     alias=${component}   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=cbts     alias=${component}
