*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com

*** Variables ***

${BTS_ADDRESS} =           192.168.255.129
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${oran_alias}=             rusim
${ORU_SIM_IP}=             10.45.150.73
${BTS_path}=               /home/ute/Logs
${value_true}=            true
${value_false}=           false
${connection}=            default
${BTS_ADDRESS_iphy} =      192.168.200.1
${Docker_username}=        inbabtslabuser
${Docker_password}=        BT5l@bus3rl0g1n
${netconf_password}=       netconf
${Netconf_Login_cmd}=      connect --ssh --login netconf --host 127.0.0.1 --port 830
${Backdoor_cmd_docker}=           /opt/UE_APP_OAM/service/oran/xml/backdoor
${backupfile_path}=                /home/inbabtslabuser/AutomationCB009196backup
${docker_name}=              SG02
${source_orusw}=             /home/inbabtslabuser/AutomationCB009196backup/RU01_orusw.log
${source_sup}=               /home/inbabtslabuser/AutomationCB009196backup/RU01_supervisor_rusim.log
${logfileorusw}=                 RU01_supervisor_rusim.log
${logfilesup}=                   RU01_orusw.log

*** Keywords ***

Send Cmd By Netopeer Cli xranuser
    [Arguments]    ${cmd}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read    delay=3s
    SSHLibrary.write   netopeer2-cli
    SSHLibrary.Read    delay=3s
    SSHLibrary.write   connect --ssh --login netconf --host 127.0.0.1 --port 830\r\n
    ${output}=    SSHLibrary.Read     delay=2s
    Log   ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}    Are you sure you want to continue connecting
    Run Keyword if    '${contains}' == 'True'    SSHLibrary.write   yes\r\n
    SSHLibrary.Read    delay=3s
    SSHLibrary.write   netconf\r\n
    SSHLibrary.Read    delay=3s
    SSHLibrary.write    user-rpc --content ${cmd}\r\n
    SSHLibrary.Read    delay=10s

    [Teardown]  Clear SSH Session To Docker

Copy_Backdoor_files_docker
    SSHLibrary.Open Connection    host=${ORU_SIM_IP}
    SSHLibrary.Login   username=${Docker_username}     password=${Docker_password}    delay=10
    SSHLibrary.write    sudo su
    SSHLibrary.read     delay=3s
    SSHLibrary.write    cd ${backupfile_path}
    SSHLibrary.read     delay=3s
    SSHLibrary.write    docker cp ${setEditFailurexml} ${Docker_Name}:${fail_editconfig_counterActivation}
    SSHLibrary.read     delay=3s
    SSHLibrary.write    docker cp ${getRejectxml} ${Docker_Name}:${fail_getCapabilityMessage}
    SSHLibrary.read     delay=3s
    SSHLibrary.Close Connection

Copy_snapshot_configFile_docker
    [Arguments]   ${Samji_Snap_version}    ${orusim_config_version}
    SSHLibrary.Open Connection    host=${ORU_SIM_IP}
    SSHLibrary.Login    ${Docker_username}     password=${Docker_password}    delay=10
    SSHLibrary.write    sudo su
    SSHLibrary.read    delay=3s
    SSHLibrary.write    docker exec -it ${Docker_Name} /bin/bash
    SSHLibrary.read    delay=3s
    SSHLibrary.write    cd ${snapshot_default_path}
    SSHLibrary.read    delay=3s
    SSHLibrary.write    pwd
    SSHLibrary.read    delay=3s
    SSHLibrary.write    mkdir ${Samji_Snap_version}
    SSHLibrary.read    delay=3s
    SSHLibrary.write    chmod 777 ${Samji_Snap_version}
    SSHLibrary.read    delay=3s
    SSHLibrary.write    exit
    SSHLibrary.read    delay=5s
    SSHLibrary.write    cd ${backupfile_path}
    SSHLibrary.read     delay=3s
    SSHLibrary.write     docker cp ${Samji_Snap_version}.xml SG02:/rom/simmode/${Samji_Snap_version}/${Samji_Snap_version_v7}.xml
    SSHLibrary.read    delay=3s
    SSHLibrary.write    docker cp ${orusim_config_version} ${Docker_Name}:/tmp/orusim-config.xml
    SSHLibrary.read    delay=3s
    SSHLibrary.Close Connection

ORU_Log_Collection
    SSHLibrary.Open Connection    host=${ORU_SIM_IP}
    SSHLibrary.Login    username=${Docker_username}     password=${Docker_password}    delay=10
    SSHLibrary.write    sudo su
    SSHLibrary.read     delay=3s
    SSHLibrary.write    cd AutomationCB009196backup/
    SSHLibrary.read     delay=1s
    SSHLibrary.write    rm -rf ${logfileorusw}
    SSHLibrary.write    rm -rf ${logfilesup}
    SSHLibrary.read     delay=1s
    SSHLibrary.write    docker cp ${docker_name}:/workspace/${logfilesup} .
    SSHLibrary.read     delay=3s
    SSHLibrary.write    docker cp ${docker_name}:/workspace/${logfileorusw} .
    SSHLibrary.read     delay=3s
    SSHLibrary.write     ls -lrt
    SSHLibrary.read     delay=3s
    SSHLibrary.Get File
	...     source=${source_orusw}
	...     destination=${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/${logfileorusw}    scp=scp
    SSHLibrary.Get File
	...     source=${source_sup}
	...     destination=${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/${logfilesup}   scp=scp
    SSHLibrary.Close Connection

Create SSH Session To Docker
    [Arguments]    ${oran_sim_host_ip}=${ORU_SIM_IP}
    ...            ${alias}=${oran_alias}
    ...            ${timeout}=120
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    SSHLibrary.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   ${timeout}=120
    SSHLibrary.Login
    ...   username=${Docker_username}
    ...   password=${Docker_password}
    SSHLibrary.Switch Connection     ${oran_alias}

Clear SSH Session To Docker
    [Arguments]    ${alias}=${oran_alias}
    run keyword and ignore error  SSHLibrary.Switch Connection  ${alias}
    run keyword and ignore error  SSHLibrary.Close Connection
