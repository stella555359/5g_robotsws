*** Settings ***
Documentation    Author: lily.l.xu@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library    BuiltIn


*** Keywords ***
_get_ue_type
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${tl}
    Return From Keyword If    '${status}'=='FAIL'    airphone
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${tl.ues[0].serial_number}
    Return From Keyword If     '${tl.ues[0].__class__.__name__}'=='dict'      cpe
    Return From Keyword If     '${tl.ues[0].__class__.__name__}'=='Android'    qualcomm
    Return From Keyword If     '${tl.ues[0].__class__.__name__}'=='Airphone'    airphone

_qualcomm_suite_setup
    [Arguments]    ${domain}
    Log    qualcomm suite setup
    Log    ${tl.ues[0].ssh_connection_details.addr}
    Set Suite variable    ${UE_PC_USER}    ${tl.ues[0].ssh_connection_details.username}
    Set Suite variable    ${UE_PC_PASS}    ${tl.ues[0].ssh_connection_details.password}
    Set Suite variable    ${UE_PC_IP}    ${tl.ues[0].ssh_connection_details.addr}
    Set Suite Variable    ${CONFIG_FILE}    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}/ue_config.yml
    Qualcomm Setup    domain=${domain}    config_file=${CONFIG_FILE}

_airphone_suite_setup
    Log    airphone suite setup
    Airphone Setup
    Get Airphone Software Version
    Get WTS Version

_cpe_suite_setup
    ${ue_info}     create dictionary    type=${tl.ues[0]['cpe_type']}     address=${tl.ues[0]['addr']} 
	...    user=${tl.ues[0]['username']}      pwd=${tl.ues[0]['password']}
	Set Suite Variable    ${CONFIG_FILE}    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}/ue_config.yml
	Set Suite variable    ${UE_PC_USER}    ${tl.ues[0]['mcs_username']}
    Set Suite variable    ${UE_PC_PASS}    ${tl.ues[0]['mcs_pwd']}
    Set Suite variable    ${UE_PC_IP}    ${tl.ues[0]['mcs_pc_ip']}
    cpe setup     ${ue_info}      log_path=C:\\TALogfiles\\ 

_cpe_suite_teardown
    cpe teardown

_airphone_test_teardown
    Run Keyword And Ignore Error    Backup Iphy Xml File       ${test_log_directory()}/All/
    Run Keyword And Ignore Error    Backup AP Swconfig File    ${test_log_directory()}/All/