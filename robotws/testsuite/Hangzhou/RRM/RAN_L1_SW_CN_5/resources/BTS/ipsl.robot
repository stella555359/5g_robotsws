*** Settings ***
Documentation    This is common keywords for ipsl related operations
...              Author: Cui Lingxue
...              Contact: lingxue.cui@nokia-sbell.com
...              Squard: MMW_SG1

Library     OperatingSystem
Library     String
Library     taf.transport.ssh    WITH NAME    ssh


*** Variables ***
# these are paths on IPSL server(usually control PC)
${IPSL_TOOL_DIR}           c:/IpslTools
${IPSL_COMPILER_FLAGS}      /pDIA05IGX /its /b


*** Keywords ***
IPSL server preparation
    [Documentation]    Author: Cui Lingxue
    ...    prepare IPSL server according to specified configuration, start IPSL server and verify server status.
    [Arguments]    ${ipsl_template_dir}    ${ipsl_config_dir}    ${ipsl_alias}=ipsl    ${ipsl_listen_port}=13868
    ...    ${ipsl_tool_dir}=${IPSL_TOOL_DIR}    ${ipsl_compiler_flags}=${IPSL_COMPILER_FLAGS}
    ...    ${ipsl_srv_ip}=${tl.core.pcf.oam_ssh_connection_details.addr}
    ...    ${ipsl_user}=${tl.core.pcf.oam_ssh_connection_details.username}
    ...    ${ipsl_pw}=${tl.core.pcf.oam_ssh_connection_details.password}
    ...    ${wait_time_for_connection_setup}=5min
    wait until keyword succeeds  2min    2s    connect to IPSL server    ipsl_srv_ip=${ipsl_srv_ip}    ipsl_user=${ipsl_user}    ipsl_pw=${ipsl_pw}
    ...    ipsl_alias=${ipsl_alias}
    Stop IPSL server process    ipsl_alias=${ipsl_alias}
    Replace IPSL config files    ipsl_template_dir=${ipsl_template_dir}    ipsl_config_dir=${ipsl_config_dir}    ipsl_alias=${ipsl_alias}
    compile files and start IPSL server    ipsl_config_dir=${ipsl_config_dir}    ipsl_tool_dir=${ipsl_tool_dir}
    wait until keyword succeeds  2min    3s    Verify IPSL server process is started    ipsl_alias=${ipsl_alias}
    wait until keyword succeeds  ${wait_time_for_connection_setup}    3s
    ...    Verify IPSL server status    ipsl_alias=${ipsl_alias}    ipsl_listen_port=${ipsl_listen_port}
    [Teardown]    disconnect from IPSL server    ipsl_alias=${ipsl_alias}

connect to IPSL server
    [Documentation]    Author: Cui Lingxue
    ...    Setup ssh connection to IPSL server.
    [Arguments]    ${ipsl_srv_ip}=${tl.core.pcf.oam_ssh_connection_details.addr}
    ...    ${ipsl_user}=${tl.core.pcf.oam_ssh_connection_details.username}
    ...    ${ipsl_pw}=${tl.core.pcf.oam_ssh_connection_details.password}
    ...    ${ipsl_alias}=ipsl
    ssh.Connect to     hostname=${ipsl_srv_ip}
    ...                username=${ipsl_user}
    ...                password=${ipsl_pw}
    ...                alias=${ipsl_alias}
    Log to console    \nINFO:connect to IPSL server successfully

disconnect from IPSL server
    [Documentation]    Author: Cui Lingxue
    ...    teardown ssh connection to IPSL server.
    [Arguments]    ${ipsl_alias}=ipsl
    ssh.Disconnect    connection=${ipsl_alias}
    Log to console    \nINFO:disconnect to IPSL server successfully

Stop IPSL server process
    [Documentation]    Author: Cui Lingxue
    ...    Stop IPSL server process
    [Arguments]    ${ipsl_alias}=ipsl
    ${is_ips_started}    ssh_common_commands.is_process_exist    process_name=ips32    connection=${ipsl_alias}    is_checking_on_windows=True
    return from keyword if    '${is_ips_started}'=='${False}'
    ssh.send_command    command=taskkill /IM ips32.exe /F /T    connection=${ipsl_alias}
    ${result}    ssh.read_output    connection=${ipsl_alias}
    ${matches}    String.get_regexp_matches    ${result}    SUCCESS: The process with PID(.*)has been terminated
    should not be empty    ${matches}

Replace IPSL config files
    [Documentation]    Author: Cui Lingxue
    ...    Upload IPSL configurations to IPSL server.
    ...    :param    ipsl_template_dir: store IPSL config template on UTE/TestPC, eg.${CURDIR}/../TestData/IPSL_FILES_COMMON
    ...    :param    ipsl_config_dir: upload IPSL config files to this dir on IPSL server.
    [Arguments]    ${ipsl_config_dir}    ${ipsl_template_dir}    ${ipsl_alias}=ipsl
    ssh.send_command    command=ls ${ipsl_config_dir}    connection=${ipsl_alias}
    ${errors}    ssh.read_error    connection=${ipsl_alias}
    ${errors}    remove_string    ${errors}    '    \n
    run keyword if    '${errors}'!='${EMPTY}'    ssh.send_command    command=mkdir -p ${ipsl_config_dir}    connection=${ipsl_alias}

    @{files}    OperatingSystem.List Files In Directory    ${ipsl_template_dir}
    FOR    ${src_file}    IN    @{files}
           ssh.Upload File  ${ipsl_template_dir}/${src_file}  ${ipsl_config_dir}/${src_file}  connection=${ipsl_alias}
    END

compile files and start IPSL server
    [Documentation]    Author: Cui Lingxue
    ...    :param    ipsl_tool_dir: where ipsl tool is installed, eg c:/IpslTools/
    ...    :param    ipsl_config_dir: where ipsl config files are stored
    [Arguments]    ${ipsl_config_dir}    ${ipsl_tool_dir}=${IPSL_TOOL_DIR}
    ...    ${ipsl_compiler_flags}=${IPSL_COMPILER_FLAGS}    ${ipsl_alias}=ipsl
    ssh.execute    command=${ipsl_tool_dir}/ipslc.exe ${ipsl_compiler_flags} ${ipsl_config_dir}/server.ctl    connection=${ipsl_alias}
    ssh.send_command    command=${ipsl_tool_dir}/ips32.exe ${ipsl_config_dir}/IPS.CFG    connection=${ipsl_alias}

Verify IPSL server process is started
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${ipsl_alias}=ipsl
    ssh.send_command    command=tasklist | findstr ips32    connection=${ipsl_alias}
    ${ips32_process_exist}    ssh.read_output    connection=${ipsl_alias}
    should not be empty    ${ips32_process_exist}

Verify IPSL server status
    [Documentation]    Author: Cui Lingxue
    ...    verify tcp connections for ipsl are established.
    ...    :param    ipsl_listen_port: port to which IPSL server service listen, defined in IPS.CFG
    [Timeout]    10min
    [Arguments]    ${ipsl_listen_port}=13868    ${ipsl_alias}=ipsl
    ssh.send_command    command=netstat -ano | grep -i ESTABLISHED | grep ${ipsl_listen_port} | wc -l   connection=${ipsl_alias}
    ${num_of_ipsl_conn}    ssh.read_output    connection=${ipsl_alias}
    ${num_of_ipsl_conn}    fetch_from_left    ${num_of_ipsl_conn}    \n
    should be true    ${num_of_ipsl_conn} >= 1

