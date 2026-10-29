*** Settings ***
Documentation
...   author: jiangrong.wang@nokia-sbell.com
...   squad group: mmw_SG2
...   Feature 5GC000955-C
...   5GC000955-C common keywords
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library    Process
Library    DateTime


Library        taf.transport.ssh    WITH NAME    csn
Library        taf.sbts.oam.coam.admin   WITH NAME   coam_client
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/scf_process.py
Library        scf_process.SCFProcess    WITH NAME    scfpro


*** Variables ****
${bts_ip}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_port}        443
${WEBUI_URL}        https://${bts_ip}
${WEBUI_USER}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}        ${tl.gnbs[0].cu.oam_http_connection_details.password}
${HW_NAME}        ABIL
${cli_daemon_path}        /home/ute/admin-cli/
${cli_daemon}        admin-cli.sh
${nemu_access}=             --bts-username='Nemuadmin' --bts-password='nemuuser'


*** Keywords ***
Commission scf
    [Documentation]
    ...        commission scf
    [Arguments]    ${scf_path}
    coam_client.connect_to    bts_host=${bts_ip}
    coam_client.perform_commissioning    scf_file=${scf_path}
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${true}
    sleep    10m
    coam_client.teardown

Lock sfp lane from webEM
    [Documentation]
    ...        lock sfp'lane
    [Arguments]    ${sfp_port}=S_RF1
    selenium_coam.lock_lane_from_sfp    hw_name=${HW_NAME}    object_name=${sfp_port}    lane_id=LANE-1

unLock sfp lane from webEM
    [Documentation]
    ...        unlock sfp'lane
    [Arguments]    ${sfp_port}=S_RF1
    selenium_coam.unlock_lane_from_sfp    hw_name=${HW_NAME}    object_name=${sfp_port}    lane_id=LANE-1

Lock sfp lane from CLI
    Operate sfp by CLI

unLock sfp lane from CLI
    Operate sfp by CLI    operation=unlock

Operate sfp by CLI
    [Documentation]
    [Arguments]    ${operation}=lock
    ${bts_id}=    selenium_coam.get_bts_id
    ${json_data}=       catenate
    ...                 '{"requestId":1,
    ...                 "parameters":{
    ...                     "name":"${operation}",
    ...                     "parameters": {
    ...                         "distNames": ["MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1"]
    ...                     }
    ...                 }}'
    ${bts_options}=     set variable    --bts-host='${bts_ip}' --bts-port='${bts_port}'
    ${data}=        set variable        --data=${json_data}
    csn.connect to    hostname=127.0.0.1
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE
    ${res}    csn.execute    command=${cli_daemon_path}${cli_daemon} ${bts_options} ${nemu_access} ${data}
    ...    connection=UTE

    Log    ${res}
    should contain    ${res}    "requestId":1
    should contain    ${res}    "requestStatus":"completed"
    should contain    ${res}    "errorCode":0
    csn.disconnect    connection=UTE


WEBEM Login
    run keyword and ignore error  Run   killall firefox
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}   timeout=${120}

WEBEM Logout
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Verify cell status should be setup
    [Arguments]    ${alias}=cOAM    ${cell_id}=1   ${timeout}=30
    [Documentation]  Verify cell status should setup
    ${cell_status}=   selenium_coam.get_cell_info    cell_idx=${cell_id}
    Log    ${cell_status}
    ${cell_status}=   set variable  ${cell_status}[Status]
    should be equal    ${cell_status}[Operational state]    enabled
    should be equal    ${cell_status}[Procedural status]    configured
    #should be equal    ${cell_status}[Availability status]    Online
    should be equal    ${cell_status}[Administrative state]    Unlocked

SFP status Should be disabled
    [Documentation]
    ...        check the SFP's status should be disabled after locked
    [Arguments]    ${physical_port}=1
    ${sfp_port_info}=        selenium_coam.get_physical_ports_info    physical_port=${physical_port}
    ${status}    set variable    ${sfp_port_info}[Status]
    should be equal    ${status}[Operational state]    disabled

SFP status Should be enabled
    [Documentation]
    ...        check the SFP's status should be enbaled after unlocked
    [Arguments]    ${physical_port}=1
    ${sfp_port_info}=        selenium_coam.get_physical_ports_info    physical_port=${physical_port}
    ${status}    set variable    ${sfp_port_info}[Status]
    should be equal    ${status}[Operational state]    enabled

SFP info Should not include Max transmission rate and Transmission distance
    [Documentation]
    ...        check the SFP's info has not included the "max transmission rate" and
    ...        "transmission distance"
    [Arguments]    ${physical_port}=1
    ${sfp_port_info}=        selenium_coam.get_physical_ports_info    physical_port=${physical_port}
    Should contain    ${sfp_port_info}    Nominal transmission rate
    Should not contain    ${sfp_port_info}    Max transmission rate
    Should not contain    ${sfp_port_info}    Transmission distance

case TearDown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
