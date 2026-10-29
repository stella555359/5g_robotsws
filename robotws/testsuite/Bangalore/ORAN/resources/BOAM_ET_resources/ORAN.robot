*** Settings ***
Library        SSHLibrary
Library        String
Library        BuiltIn
Library        taf.transport.ssh    WITH NAME    ssh
Resource       admin.robot
Resource       system.robot

*** Variables ***
${oran_alias}                         oran_sim
${DOCKER_PATH}                        /home
${NETCONF_TRACE_REMOTE_PATH}          /tmp/node_FHNET00/tmp/RMOD_L-1_NetconfRpcMessageTrace.log
${NETCONF_TRACE_LOCAL_PATH}           /home/ute/Downloads/RMOD_L-1_NetconfRpcMessageTrace.log
${XML_DOCKER_PATH}                    /home
${user}                               ${Docker_user_name}@
${SUPERVISORD_PATH}                   /var/log/supervisord.log
${RPC_CMD}                            user-rpc --content /home/
${Airphone_build_path}				  airphone-docker-local.artifactory-espoo1.int.net.nokia.com/orusim
${APOABIO_IP}					      192.168.200.1    
${APOABIO_user}					      toor4nsn
${APOABIO_pass}					      oZPS0POrRieRtu

*** Keywords ***
Send Cmd To Docker Shell
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write    ${cmd}
    ${output}           SSHLibrary.Read Until         root@
    SSHLibrary.Read Until        root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Docker Container Setup
    [Arguments]    ${Docker_script}=${Start_Docker}
    Create SSH Session To Docker
	SSHLibrary.write    sudo chmod 777 ${Docker_script_path}/${Docker_script}
    SSHLibrary.write    
    ...     sudo ${Docker_script_path}/${Docker_script} ${Airphone_build_path}:${Airphone_version} -i=${Docker_interface} -n=${Docker_instance}
    SSHLibrary.Read Until         root@
	Clear SSH Session To Docker
	Send Cmd To Docker Shell    oranrestart 1 ${oran_version}
	${output}	Send Cmd To Docker Shell	supervisorctl status
	${status}    BuiltIn.Run keyword and return status    Should not Contain		${output}		FATAL
	Run Keyword If 		'${status}' == 'False' 		Send Cmd To Docker Shell    oranrestart 1 ${oran_version}	
    Log To Console      ${\n}Container created
    [Teardown]  Clear SSH Session To Docker

Docker Container Kill
    [Arguments]    ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker kill ${docker_name}
    SSHLibrary.Read Until         ${user}
    #SSHLibrary.Write    sudo systemctl start firewalld
    #SSHLibrary.Read Until		${user}         
    Log To Console      ${\n}Container killed
    [Teardown]  Clear SSH Session To Docker

Create SSH Session To Docker
    [Arguments]    ${oran_sim_host_ip}=${ORU_SIM_IP}
    ...            ${alias}=${oran_alias}   
    ...            ${timeout}=100
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    SSHLibrary.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   timeout=120
    SSHLibrary.Login
    ...   username=${Docker_user_name}
    ...   password=${Docker_password}
    SSHLibrary.Switch Connection     ${oran_alias}

Clear SSH Session To Docker
    [Arguments]    ${alias}=${oran_alias}
    run keyword and ignore error  SSHLibrary.Switch Connection  ${alias}
    run keyword and ignore error  SSHLibrary.Close Connection
	
Copy files to Docker
	[Arguments]    ${alias}=${oran_alias}
	ssh.Connect_to    ${ORU_SIM_IP}   ${Docker_user_name}    ${Docker_password}    alias=${alias}
	Create SSH Session To Docker
	SSHLibrary.Write    mkdir ${Docker_script_path}
	Clear SSH Session To Docker
	${files}    OperatingSystem.List Files In Directory    ${Docker_files}
    FOR    ${file}    IN    @{files}
		ssh.upload_file    local_path=${Docker_files}/${file}	   remote_path=${Docker_script_path}/${file}	connection=${alias}
	END
	ssh.Disconnect		connection=${alias}

Send Cmd By Netopeer Cli
    [Arguments]    ${cmd}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until         root@
    SSHLibrary.write   rm -f /home/cmd.txt
    SSHLibrary.write   echo connect --ssh --login netconf --host 127.0.0.1 --port 830 > /home/cmd.txt
    SSHLibrary.write   echo ${cmd} >> /home/cmd.txt
    SSHLibrary.write   netopeer2-cli < /home/cmd.txt
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     netconf@127.0.0.1 password
    Run Keyword If     '${res}' == 'PASS'
    ...                SSHLibrary.write          netconf
    ...  ELSE IF       '${res}' == 'FAIL'        Run Keywords
    ...                SSHLibrary.write          yes
    ...  AND           SSHLibrary.Read Until     netconf@127.0.0.1 password
    ...  AND           SSHLibrary.write          netconf
    ${res}  ${outp}    Run Keyword And Ignore Error
    ...                SSHLibrary.Read Until     root@
    Return From Keyword If  '${res}' == 'PASS'   ${outp}
    SSHLibrary.write   yes
    ${output}          SSHLibrary.Read Until     root@
    [Return]  ${output}
    [Teardown]  Clear SSH Session To Docker

Get Parameters
    [Arguments]    ${parameter}
    ...            ${dist_name}
	...			   ${alias}=admin_1
    ${out_parameters_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    alias=${alias}
    ...    timeout=20
    [Return]    ${out_parameters_dict}

Get Rmod Id
	[Arguments]    ${alias}=${ADMIN_ALIAS}
    ${rmod_id}    ADMIN Get Id For Current    RMOD		alias=${alias}
    ${dist_name_string}    Convert To String    ${rmod_id}
    ${dist_name}    Get Substring    ${dist_name_string}    2    -2
    set global variable    ${dist_name}

Check MPlaneLink Status
	[Arguments]    ${alias}=${ADMIN_ALIAS}
    ${act_mPlane}   Check Parameter Under Rmod    mPlaneLinkStatus		alias=${alias}
    [Return]    ${act_mPlane}

Check Parameter Under Rmod
    [Arguments]    ${parameter}		${alias}=${ADMIN_ALIAS}
    ${out_parameters_dict}    Get Parameters    ${parameter}    ${dist_name}	alias=${alias}
    ${parameter_status}   set variable    ${out_parameters_dict['${parameter}']}
    [Return]    ${parameter_status}

Wait Until Mplane Is Connected
    [Arguments]    ${timeout}=200	${alias}=${ADMIN_ALIAS}
    ADMIN Assert All Rmods Are In Expected Operational State    regex"Enabled|enabled"    timeout=${timeout}	
    Get Rmod Id		alias=${alias}
    wait until keyword succeeds
    ...                           ${timeout}
    ...                           5
    ...                           Assert Mplane Connected	alias=${alias}
    wait until keyword succeeds
    ...                           100
    ...                           5
    ...                           Assert Mrbts Is In Onair State	alias=${alias}		
    Log    \n+ MPlane is Connected    console=yes

Assert Mplane Connected
	[Arguments]    ${alias}=${ADMIN_ALIAS}
    ${mplane_status}     Check MPlaneLink Status	alias=${alias}	
    should be equal as strings    ${mplane_status}
    ...                           Connected

Wait Until Mplane Is Link Down
    [Arguments]    ${timeout}=200
    Get Rmod Id
    wait until keyword succeeds
    ...                           ${timeout}
    ...                           5
    ...                           Assert Mplane Link Down
    Log    \n+ MPlane is Link Down    console=yes

Assert Mplane Link Down
    ${mplane_status}     Check MPlaneLink Status
    should be equal as strings    ${mplane_status}
    ...                           Link Down

Check Message In Netconf Trace File
    [Arguments]    ${message_to_grep}
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path}
    [Return]    ${output}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Copy Xml To Container
    [Arguments]  ${local_path_to_file}
    ...          ${file_name}
    ...          ${destination_path}=${XML_DOCKER_PATH}
    ...          ${docker_name}=${DOCKER_NAME}
    ${xml_file}    Run    cat ${local_path_to_file}/${file_name}
    Create SSH Session To Docker
    #comment SSHLibrary.Read Until    plwr
    SSHLibrary.write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write     ls ${destination_path}
    ${files_in_directory}    SSHLibrary.Read Until    root@
    ${is_file_exist}    BuiltIn.Run keyword and return status    Should Contain
    ...    ${files_in_directory}
    ...    ${file_name}
    Run Keyword If     ${is_file_exist}
    ...              SSHLibrary.write    rm ${destination_path}/${file_name}
    SSHLibrary.write    touch ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    SSHLibrary.write    echo '${xml_file}' >> ${destination_path}/${file_name}
    SSHLibrary.Read Until    root@
    [Teardown]  Clear SSH Session To Docker

Copy Xml And Send Cmd By Netopeer Cli
    [Arguments]    ${file_name}
    ...            ${path}
    ...            ${cli_cmd}=${RPC_CMD}
    Copy Xml To Container   ${path}
    ...                     ${file_name}
    Send Cmd By Netopeer Cli    ${cli_cmd}${file_name}

Edit Orusim Config
    [Arguments]    ${line_to_change}
    ...            ${new_line}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo sed -i 's;${line_to_change};${new_line};g' ${oru_config_path}
    SSHLibrary.Read Until    ${user}
    SSHLibrary.Write    cat ${oru_config_path}
    ${orusim_config_output}    SSHLibrary.Read Until    ${user}
    should contain    ${orusim_config_output}    ${new_line}
    [Teardown]  Clear SSH Session To Docker

TL Preparation
    ADMIN Setup Admin
    ADMIN Reset Site
    Docker Container Kill
    Assert All Bbmods Are In Enabled State    timeout=150
    Docker Container Setup
    Get Rmod Id
    Wait Until Mplane Is Connected
    ADMIN Teardown Admin

Assert All Bbmods Are In Enabled State
    [Arguments]    ${timeout}=100
    wait until keyword succeeds
    ...    ${timeout}
    ...    5
    ...    Check If BBU Is In Enabled State

Check If BBU Is In Enabled State
    ${operational_state}    Get Parameters    operationalState    ${BTS_L_PATH}/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1
    Should Match Regexp    ${operational_state['stateInfo']['operationalState']}    Enabled

ORAN Preconditions
    Test Preconditions Without WTSSIM S1
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Set Path In Infomodel

Set Path In Infomodel
    ${position}=    ADMIN Get Smod Position
    Run Keyword If    '${position}' == 'left'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-1
    ...    ELSE IF    '${position}' == 'right'    Run Keywords
        ...    Set Global Variable    ${EQM_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4    AND
        ...    Set Global Variable    ${MRBTS_PATH}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4    AND
        ...    Set Global Variable    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-4

Check Message Id
    [Arguments]    ${message_to_grep}
    ...            ${grep_option}=head -n 1
    ...            ${remote_file_path}=${NETCONF_TRACE_REMOTE_PATH}
    ...            ${local_file_path}=${NETCONF_TRACE_LOCAL_PATH}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Get File From Enb Over Ssh    ${remote_file_path}
    ...                                  ${local_file_path}
    ${output}   Run    grep -n '${message_to_grep}' ${local_file_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${message_id}    Fetch From Right    ${output_1}    message-id="
    [Return]    ${message_id}
    [Teardown]    SYSTEM Close SSH Connection To Enb

Check Message Id In Oru
    [Arguments]    ${message_to_grep}
    ...            ${supervisord_path}=${OUTPUT_DIR}/${TEST_NAME}/supervisor.log
    ...            ${grep_option}=head -n 1
	Download supervisor logs	${supervisord_path}=${SUPERVISORD_PATH}
    ${output}	RUN		grep -n '${message_to_grep}' ${supervisord_path} | ${grep_option}
    ${output_1}    Fetch From Left    ${output}    "><
    ${message_id}    Fetch From Right    ${output_1}    message-id="
    [Return]    ${message_id}
	
Download supervisor logs
	[Arguments]    ${alias}=${oran_alias}
	...            ${supervisord_path}=${SUPERVISORD_PATH}
	...            ${docker_name}=${DOCKER_NAME}
	ssh.Connect_to    ${ORU_SIM_IP}   ${Docker_user_name}    ${Docker_password}    alias=${alias}
	${output}		ssh.Execute     command=sudo docker ps -aqf "name=${DOCKER_NAME}"      connection=${alias}		timeout=10s
	${Container_ID}		Strip String	${output}	characters=\r\n
	ssh.Execute     command=sudo docker cp ${Container_ID}:${supervisord_path} ${Docker_file_path}/Supervisor.log	connection=${alias}	timeout=60s
	ssh.download_file    remote_path=${Docker_file_path}/Supervisor.log		local_path=${OUTPUT_DIR}/${TEST_NAME}/supervisor.log      
	...		connection=${alias}
	ssh.Execute     command=rm -rf ${Docker_file_path}/Supervisor.log	connection=${alias}		timeout=10s
	[Teardown]		ssh.Disconnect		connection=${alias}

Check Message In Logs On Oru
    [Arguments]    ${message_to_grep}
    ...            ${supervisord_path}=${OUTPUT_DIR}/${TEST_NAME}/supervisor.log
    ...            ${docker_name}=${DOCKER_NAME}
	Download supervisor logs	${supervisord_path}=${SUPERVISORD_PATH}
    ${output}	RUN    grep -n '${message_to_grep}' ${supervisord_path}
    #Should contain     ${output}	${message_to_grep}
    [Return]    ${output}

Clear Logs In Oru
    [Arguments]    ${supervisord_path}=${SUPERVISORD_PATH}
    ...            ${docker_name}=${DOCKER_NAME}
    Create SSH Session To Docker
    SSHLibrary.Write    sudo docker exec -it ${docker_name} /bin/bash
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    > ${supervisord_path}
    SSHLibrary.Read Until    root@
    [Teardown]  Clear SSH Session To Docker

Clear Netconf Traces
    [Arguments]    ${remote_file_path}=/tmp/node_FHNET00/tmp/RMOD_L-1_NetconfRpcMessageTrace.log
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    > ${remote_file_path}
    SSHLibrary.Read Until    root@
    [Teardown]    SYSTEM Close SSH Connection To Enb

Parameter Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}=update
    ...            ${skip_parameter_relation_errors}=true
    ...            ${should_activate}=true
    ...            ${timeout}=60
    ...            ${alias}=admin_1
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    value=${value}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    alias=${alias}

Prepare Orusim Config For Timeout
    Edit Orusim Config    <supervision_no_kill>0</supervision_no_kill>
    ...                   <supervision_no_kill>1</supervision_no_kill>

Edit Orusim Config After Timeout
    Edit Orusim Config    <supervision_no_kill>1</supervision_no_kill>
    ...                   <supervision_no_kill>0</supervision_no_kill>

Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=NRCEL

Assert Mrbts Is In Onair State
    [Arguments]    ${timeout}=50
    ...            ${alias}=admin_1
    ${mrbts_state}    taf.sbts.oam.coam.admin.Get Mrbts State    timeout=${timeout}
    ...                                        alias=${alias}
    Should Contain    ${mrbts_state}    OnAir

Check If Gnb Is In On Air State And If Cell Is Enabled
    Assert All NRCells Are In Expected State    operationalState    regex"Enabled|enabled"     timeout=50
    Assert Mrbts Is In Onair State

Send Cmd By Netopeer Cli to APOABIO
    [Arguments]		${cmd}      ${ORU_board}=${ORU_board_id}	${ORU}=${ORU_ID}
    Create SSH Session To APOABIO	timeout=10
    SSHLibrary.write    lxc-attach -n ${ORU_board}
    SSHLibrary.Read Until   root@${ORU}:~ >  
    SSHLibrary.write	rm -f /tmp/cmd.txt
    SSHLibrary.write	echo connect --ssh --login netconf --host 127.0.0.1 > /tmp/cmd.txt
    SSHLibrary.write	echo ${cmd} >> /tmp/cmd.txt
    SSHLibrary.write	ip netns exec ${ORU} /opt/UE-APP-OAM-oru/service/netopeer2/netopeer2-cli < /tmp/cmd.txt
    ${status}       Run keyword and return status      SSHLibrary.Read Until        password:
    Run keyword if      '${status}'=='False'     Run keywords   SSHLibrary.write       yes      AND
    ...     SSHLibrary.Read Until        password:
    SSHLibrary.write   netconf
    SSHLibrary.Read Until   root@${ORU}:~ >
    [Teardown]  Clear SSH Session To APOABIO
	
Create SSH Session To APOABIO
	[Arguments]    ${oran_sim_host_ip}=${APOABIO_IP}
    ...            ${alias}=APOABIO	
    ...            ${timeout}=100
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    SSHLibrary.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   timeout=${timeout}
    SSHLibrary.Login
    ...   username=${APOABIO_user}
    ...   password=${APOABIO_pass}
	SSHLibrary.Switch Connection     ${alias}
	
Clear SSH Session To APOABIO
    [Arguments]    ${alias}=APOABIO
    run keyword and ignore error  SSHLibrary.Switch Connection  ${alias}
    run keyword and ignore error  SSHLibrary.Close Connection
	
Copy files to APOABIO
	[Arguments]		${local_path}	
	...				${remote_path}
    ...             ${alias}=APOABIO
	ssh.Connect_to    ${APOABIO_IP}    ${APOABIO_user}    ${APOABIO_pass}    alias=${alias}
	ssh.upload_file    local_path=${local_path}   remote_path=${remote_path}		connection=${alias}
	[Teardown]  ssh.Disconnect		connection=${alias}
	
Send command to APOABIO
	[Arguments]		${command}      ${alias}=APOABIO
	ssh.Connect_to    ${APOABIO_IP}    ${APOABIO_user}    ${APOABIO_pass}    alias=${alias}
	${output}	ssh.Execute     command=${command}	connection=${alias}
	LOG		${output}
	[Return]  	${output}
	[Teardown]  ssh.Disconnect		connection=${alias}
	
Restart APOABIO
	[Arguments]     ${ORU_board_id}=${lxc_id}		${ORU}=${ORU_ID}
    Create SSH Session To APOABIO
    SSHLibrary.write    lxc-attach -n ${ORU_board_id}
    SSHLibrary.Read Until   root@${ORU}:~ >  
    SSHLibrary.write	oranrestart
    [Teardown]  Clear SSH Session To APOABIO

Copy Xml And Send Cmd By Netopeer Cli to APOABIO
	[Arguments]    ${file_name}
    ...            ${path}
    ...            ${ORU_board_id}=${lxc_id}
    ...            ${cli_cmd}=${ABIO_RPC_cmd}
    ...            ${ORU_path}=${ORU_container_path}
	Copy files to APOABIO		${path}/${file_name}	${ORU_path}/tmp/${file_name}
	Send Cmd By Netopeer Cli to APOABIO		${cli_cmd}${file_name}     ${ORU_board_id}
