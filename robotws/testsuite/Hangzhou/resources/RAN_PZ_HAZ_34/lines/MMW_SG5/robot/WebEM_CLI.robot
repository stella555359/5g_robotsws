*** Variables ***
# All these variables can be passed as parameters with eclat using --variable option in session manager
${bts_oam_http}=            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${full_bts_http}=           ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_port}=                443
${cli_host}=                ${tl.test_pc.default_ssh_connection_details.addr}
${cli_host_login}=          ${tl.test_pc.default_ssh_connection_details.username}
${cli_host_pwd}=            ${tl.test_pc.default_ssh_connection_details.password}
${cli_home_path}=           /home/ute
${cli_cmd_path}=            ${cli_home_path}/current
${cli_log_path}=            ${cli_home_path}/logs
${cli_daemon}=              admin-cli.sh
${cli_daemon_cmd}=          ${cli_cmd_path}/${cli_daemon}
${cli_daemon_port}=         9001
${cli_cmd}=                 ${cli_cmd_path}/agent-cli/agent-cli.sh
${nemu_access}=             --bts-username='Nemuadmin' --bts-password='nemuuser'
${debug}=                   ${False}
${console}=                 ${False}

*** Settings ***
Library     BuiltIn
Library     Collections
Library     String
Library     OperatingSystem
Library     DateTime
# Library     SSHLibrary                  prompt=REGEXP:ute.*$   timeout=600 seconds
Library     taf.sbts.oam.coam.admin      WITH NAME   coam
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/AdminCli.py  debug=${debug}  console=${console}
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Set Testing Env
    [Documentation]     Environement Setup for Testing
    [Arguments]  ${path}=${cli_log_path}/5GC000915
    ${full_bts_http}=   Get Full HTTP   ${bts_oam_http}
    Set Suite Variable  ${full_bts_http}
    Launch Cli Admin Daemon  path=${path}


Clean Testing Env
    [Documentation]     Clean all
    Kill Cli Admin Daemon

Launch Cli Admin Daemon
    [Arguments]  ${path}=${cli_log_path}/5GC000915
    [Documentation]     Open a connection to cli host and launch the admin cli daemon
    Log                 Connecting to ${cli_host}                               console=True
    ${timestamp}=       Get Current Date    result_format=%Y_%m_%d_%H%M
    set suite variable  ${timestamp}
    ${debug_options}=   set variable        --debug='${path}_${timestamp}'
    ${bts_options}=     set variable        --bts-host='${full_bts_http}' --bts-port='${bts_port}'
    ${cli_options}=     set variable        --cli-port='${cli_daemon_port}'
    Log                 Launching: ${cli_daemon_cmd} ${bts_options} ${cli_options} ${nemu_access} ${debug_options}
    ...                                                                         console=True
    Run                 nohup ${cli_daemon_cmd} ${bts_options} ${cli_options} ${nemu_access} ${debug_options} > stdout.txt 2>&1 &


Kill Cli Admin Daemon
    [Documentation]     Kill the daemon process and exit
    Log                 Stopping ${cli_daemon}                                  console=True
    Run     killall ${cli_daemon}
    Run     killall node

Case Precondition
    coam.connect_to     bts_host=${full_bts_http}           name=coam_admin    

Case Postcondition    
    coam.teardown       connection=coam_admin
    

Download Admin Cli
    [Arguments]  ${swversion}
    ${result}    run keyword and return status    should contain any
    ...    ${swversion}
    ...    12.400    14.400    22R1    22R2    21B    21A    20B
    ${release}    Set Variable If    ${result}    branch    trunk
    Set Suite Variable    ${release} 
    Run Keyword if                     '_9999_' in '${swversion}'    AdminCli.get_file_for_Trunk_Load
    ...    ${swversion}
    Run Keyword if                     '_0000_' in '${swversion}'    AdminCli.get_file_for_21B_Load
    ...    ${swversion}  
    Run Keyword if                     '5G21A' in '${swversion}'    AdminCli.get_file_for_21A_Load
    ...    ${swversion}      
    Run Keyword if                     '5G20B' in '${swversion}'    AdminCli.get_file_for_20B_Load
    ...    ${swversion}
    AdminCli.unzip_file                              
    OperatingSystem.Directory Should Not Be Empty      /home/ute/current
    Run Keyword And Ignore Error       coam.teardown