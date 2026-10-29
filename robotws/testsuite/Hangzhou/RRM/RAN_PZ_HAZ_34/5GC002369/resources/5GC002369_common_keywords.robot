*** Settings ***
Documentation
...    author: Wu Fangmin
...    contact: fangmin.wu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Library     Emil_processing_keywords.py
Library    taf.transport.ssh    WITH NAME    ssh
Library            DateTime

*** Variables ***

${DCAP_IP}=                                              10.57.167.48
${DCAP_USER}=                                            dcapuser
${DCAP_PASSWD}=                                          dcapuser123
${gNB_IP}                                                ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gNB_username}                                          ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gNB_password}                                          ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${gNB_name}                                              gNBsg3
${filelocation}                                          /home/ute/Logs
${labpcip}                                               ${tl.ues[0].ssh_connection_details.addr}
${labpcname}                                             ${tl.ues[0].ssh_connection_details.username}
${labpcpass}                                             ${tl.ues[0].ssh_connection_details.password}
${sourceProfile}=                                        ${CURDIR}/SourceProfile.ini
${Emil_keywords}=                                        ${CURDIR}/Emil_processing_keywords.py
${tes_emil}=                                             ${CURDIR}/test_emil.robot
${profile_path}                                          C:/tool/Emil/profiles/5G
${log_path_DCAP}                              /sharedvolume/flowtracer/traces/5G_TA_SG3

*** Keywords ***

Connect to DCAP
    ssh.connect_to    hostname=${DCAP_IP}    username=${DCAP_USER}   password=${DCAP_PASSWD}    alias=DCAP

Close connect of DCAP
    ssh.disconnect    connection=DCAP

Prepare Test
    log    \n Prepare Test    console=true
    Stop monitoring VMs
    Delete gNB IP address from FlowTracer
    Delet FlowTracer logs on DCAP
    sleep    5s

Recover TL
    log   \n Recover TL    console=yes
    Stop monitoring VMs
    Delete gNB IP address from FlowTracer
    Delet FlowTracer logs on DCAP
    Copy logs and remove items
    run keyword and ignore error  Delete FlowTracer logs on local


Add gNB IP address to FlowTracer
    log    \n Add gNB IP address to FlowTracer    console=true
    Connect to DCAP
    ${output}    ssh.execute
    ...   command=docker exec -it flowtracer bash -c './fcmd ${DCAP_IP}:55001 cp ${gNB_name} ${gNB_IP}:20401'    connection=DCAP
    should contain      container=${output}    item=Create provider controller : success
    [Teardown]  Close connect of DCAP

Reboot gnb and check its status
    log    \n Reboot gnb and check its status    console=true
    ssh.connect_to    hostname=${gNB_ip}   username=${gNB_username}   password=${gNB_password}   alias=gNB-conn
    ssh.execute    command=reboot     connection=gNB-conn
    Wait until cluster is on cell on air status
    [Teardown]    ssh.Disconnect    connection=gNB-conn

Delete gNB IP address from FlowTracer
    Connect to DCAP
    ${delete_result}    ssh.execute
    ...    command=docker exec -it flowtracer bash -c './fcmd ${DCAP_IP}:55001 dp ${gNB_name}'    connection=DCAP
    [Teardown]  Close connect of DCAP

Start monitoring VMs for SCTP and ZMQ messages
    log   \n Start monitoring VMs    console=yes
    Connect to DCAP
    Set monitoring command    Session_name=${Session_name}   Filter=f5c:@ext/config/5gfilter_SG3.txt    Vm=su:GIVAXI-0
    ${output_status}    ssh.execute   command=docker exec -it flowtracer bash -c '${monitoring_command}'   connection=DCAP
    should contain      ${output_status}    Create monitoring session : success
    [Teardown]  Close connect of DCAP

Set monitoring command
    [Arguments]    ${Session_name}    ${Filter}    ${Vm}
    Set Suite Variable   ${a}     ./fcmd ${DCAP_IP}:55001 cm n=${Session_name} p=${gNB_name}
    Set Suite Variable   ${b}    d=DataCollector\@${DCAP_IP}:9999 m=[${filter}][${vm}][gnb:gNB5G]
    Set Suite Variable   ${c}    pl=[n:flowdiskwriter][c:@ext/config/_diskwriter_TA_SG3.conf][s:1]
    ${command}=   Remove String Using Regexp    ${a} ${b} ${c}   '
    Set Suite Variable    ${monitoring_command}    ${command}

Stop monitoring VMs
    log   \n Start monitoring VMs    console=yes
    Connect to DCAP
    ssh.execute    command=docker exec -it flowtracer bash -c './fcmd ${DCAP_IP}:55001 dm ${Session_name}'    connection=DCAP
    [Teardown]  Close connect of DCAP

Copy FlowTracer logs to local
    log     Copy FlowTracer logs    console=true
    ${current_date}     Get Current Date    result_format=%Y%m%d
    ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
    run    command=mkdir ${filelocation}/${current_time}
    run    command=export no_proxy=localhost,127.0.0.0/8
    set Suite variable    ${log_path_local}    ${filelocation}/${current_time}
    run    command=sudo sshpass -p ${DCAP_PASSWD} scp ${DCAP_USER}@${DCAP_IP}:${log_path_DCAP}/${current_date}/*.5gm ${log_path_local}/

Delete FlowTracer logs on local
    run    command=rm -rf ${log_path_local}

Delet FlowTracer logs on DCAP
    Connect to DCAP
    ssh.execute  command=echo ${DCAP_PASSWD} | sudo -S rm -rf ${log_path_DCAP}/*  connection=DCAP   timeout=1s
    [Teardown]  Close connect of DCAP

Mkdir for EMil script and logs
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ssh.send_command    command=mkdir C:/robot_script     connection=LabPC
    ssh.send_command    command=mkdir C:/Emil_logs     connection=LabPC
    ssh.send_command    command=mkdir C:/Logs_after_test     connection=LabPC
    [Teardown]  ssh.Disconnect    connection=LabPC

Send Emil script and logs
    log to console     message=copy log and scrips to labpc
    Run   command=sshpass -p '${labpcpass}' scp ${sourceProfile} ${labpcname}@${labpcip}:${profile_path}
    Run   command=sshpass -p '${labpcpass}' scp ${Emil_keywords} ${labpcname}@${labpcip}:C:/robot_script
    Run   command=sshpass -p '${labpcpass}' scp ${tes_emil} ${labpcname}@${labpcip}:C:/robot_script
    Run   command=sshpass -p '${labpcpass}' scp ${log_path_local}/*.5gm ${labpcname}@${labpcip}:C:/Emil_logs

Check emil log
    [Arguments]    ${end_file}
    log    \n start checking emil logs    console= yes
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    set test variable    ${emil_out}    ${FALSE}
    ${execute}=  ssh.execute
    ...    command=pybot.bat -L trace -v end_file:*.${end_file} C:/robot_script/test_emil.robot    connection=LabPC
    Log to console    message=${execute}
    ${emil_out}=  Run keyword and return status    Should Contain    ${execute}    PASS
    run keyword if   ${emil_out}
    ...   Log to console    message=All msg are scrambled!
    ...   ELSE
    ...   Log to console    message=Some msg are not scrambled.
    run keyword if  not ${emil_out}   fail
    set suite variable    ${emil_out}
    [Teardown]  ssh.Disconnect    connection=LabPC


Copy logs and remove items
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ssh.send_command    command=cd c:/ && mv -v Emil_logs/* Logs_after_test/     connection=LabPC
    [Teardown]  ssh.Disconnect    connection=LabPC
