*** Settings ***
Documentation    ...
#Documentation     author: suhou contact: susie.hou@nokia-sbell.com
#Test Timeout      25 minutes
#Resource          ./../../CUDU_L2/common_setup_teardown.robot
##Library           ../../../Resource/python/interface.py
##Resource          ../../../Resource/robot/interface.robot
#Library            taf.transport.ssh    WITH NAME    ssh
##Variables          cu_parameters.py
#Suite Setup       Run Keywords
#...               Prepare DCAP Env
#...               Suite Setup Update GNB
#Suite Teardown    Recover TL
#
#*** Variables ***
#${wts_ip}         10.57.207.15
#${wts_username}   ute
#${wts_password}   ute
#&{AP}             hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
#&{GNB}            hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
#&{GNB_CU}         hostname=10.57.207.14    username=robot    password=rastre1
#${set_filter}     sudo echo -e "{\n    \\"5gNBCpFilter\\":[\n    {\\"component\\":\\"5G-CP-NRT\\",
#...               \\"interfaces\\":[\\"E1-C\\"]}\n    ]\n}">/sharedvolume/flowtracer/5gfilter-e001.txt
#${DCAP_IP}        192.168.5.123
#${COLLECTOR_IP}   192.168.5.123:9999
#${PROVIDER_IP}    192.168.5.101:20401
#${TRACER_PATH}    /sharedvolume/flowtracer/
#${CPNRT}          tl288-5gbts-1-cpnrt-000
#${CPNB}           tl288-5gbts-1-cpnb-000
#${GNB_NAME}       tl288-5gbts-1
#${ImageDir}       /sharedvolume/flowtracer/images
#${Image}          flowtracer_RHEL7_20.08.482_docker.img
#${DCAP_CFG_PATH}  /sharedvolume/flowtracer/config/
#${TRACER_LOG}     /sharedvolume/flowtracer/tmp/5G/
#${GNBCUTYPE}      NSA
#${SCF_PATH}       ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#${LOG_PATH}       /sharedvolume/flowtracer/tmp/5G/
#@{log_name_list}    #btslog    tcpdump
#
##${runprocess}     cd /home/tracer/FlowTracer;nohup ./FlowTracer>procss.file 2>&1 &
#
#*** Test Cases ***
#5GC001681_E001_Verify_capturing_and_streaming_of_SCTP_messages_exchanged_between_CP-NRT_in_CU-UP_and_CP-IF_in_CU-CP_in_the_Cloud_gNB
#    [Documentation]    This case's purpose is aim at capturing and streaming of SCTP messages exchanged between CP-NRT in CU-UP and
#    ...    CP-IF in CU-CP in the Cloud gNB
#    [Tags]    Cloud    CRT_HNZ    5GC001681    FR1    FR2    QCD_MN_5G    QCP_5G
#    ...    IPV4    Owner_susie    PRI-Medium    CN1    5G20B
#    [Timeout]   23 min
#    #Add tracing network
#    Verify BTS Is OnAir
#    Delete Old Logfile
#    Start Cplane Session    session_name=T37
#    Reboot cloud gnb and check its status
#    wait until keyword succeeds    5min    10sec    Check Log Exist
#    Check Log
#    Stop DCAP Monitor Session    session_name=T37
#
#*** Keywords ***
#Add tracing network
#    BuiltIn.Log To Console    Add tracing network
#    #${delret}    unified_deltia_commission    ${DELTA_DEL_PARAS}    CU
#    ${addret}    unified_delta_commission    ${DELTA_ADD_PARAS2}    CU
#
#Check control connections between OAM and DCAP
#    wait until keyword succeeds  20s    1s   Check if address is visible
#    wait until keyword succeeds  20s    1s   Check if status is authenticated
#
#Check if address is visible
#    SSH.send_command    command=sudo dataprovidercli show |grep ${DCAP_IP}    connection=CU
#    ${output_address}=  SSH.read output   connection=CU
#    should contain      ${output_address}       ${DCAP_IP}
#
#Check if status is authenticated
#    SSH.send_command    command=sudo dataprovidercli show |grep Status    connection=CU
#    ${output_status}=   SSH.read output    connection=CU
#    should contain      ${output_status}    Status:Authenticated
#
#Add DCAP IP address on CU
#    SSH.connect_to    hostname=${GNB_CU.hostname}    username=${GNB_CU.username}    password=${GNB_CU.password}    alias=CU
#    SSH.send_command   sudo dataprovidercli add -u ${DCAP_IP}    connection=CU
#    sleep  3s
#    SSH.write_input     data=y    connection=CU
#    Check control connections between OAM and DCAP
#    SSH.disconnect   connection=CU
#
#Kill egate and edaemon process
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#
#Check and Recover gNB State
#    Login Page Via WebUI
#    ${bts_state}    selenium_coam.Get Bts Status
#    Run Keyword If    ${bts_state}!=On air   Reboot TL and setup x2
#    [Teardown]    run keyword and ignore error    coam.logout
#
#Reboot TL and setup x2
#    Kill egate and edaemon process
#    Reboot and check Cloud TL
#    Suite Setup Copy WTS Config Files From QT
#    Suite Setup Start WTS And Check OnAir
#
#Reboot and check Cloud TL
#    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
#    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
#    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
#    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}
#         Log To Console    ===============Reboot Time: ${index}==============
#         Reboot Cloud Testline Via SSH
#         ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
#         Exit For Loop If    '${res}'=='True'
#
#    END
#Reboot Cloud Testline Via SSH
#    [Documentation]    This keyword is to reboot gNB and Airphone with reboot command
#    Log To Console    Reboot cloud testline via ssh...
#    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} 'reboot'
#    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${GNB_CU.password} ssh ${GNB_CU.username}@${GNB_CU.ip} 'sudo reboot'
#    Sleep    2s
#    #OperatingSystem.Run And Return Rc And Output
#    #...    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} 'reboot'
#
#Prepare DCAP Env
#    Log to console  Start to prepare DCAP Env
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#    ${no_flowtracer_container_flag}=    Run Keyword And Return Status    Should Not Contain    ${output}    flowtracer
#    ${Flowtracer_state}=    Run Keyword And Return Status    Should Not Contain    ${output}    Exited
#    Set Suite Variable    ${Flowtracer_state}
#    Run Keyword If    ${no_flowtracer_container_flag}==True    Install and start DCAP
#    ...    ELSE    Run Keywords   Check If Tracer Is UP
#
#Check If Tracer Is UP
#    Run Keyword If    ${Flowtracer_state}!=True    Config and start DCAP Env
#    ...    ELSE
#    ...    Log    Don't need start flowtracer.
#
#Install and start DCAP
#    Install DCAP Package
#    Add DCAP IP address on CU
#    Config DCAP Env
#    Start DCAP Env
#
#Install DCAP Package
#    [Documentation]    Deploy DCAP related files to ute/wts
#    OperatingSystem.Run And Return Rc And Output   sudo sshpass -p dcapuser123 scp -r dcapuser@10.57.205.43:/sharedvolume/ /
#    ${cmd}=    Catenate    sudo docker load -i
#    ...    ${ImageDir}/${Image}
#    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
#
#Config DCAP Env
#    [Documentation]    Config DCAP and gnb,for their communication.
#    ${cmd}=    Catenate   sudo sed -i
#    ...    's/collectorIpAddress=[0-9]*.[0-9]*.[0-9]*.[0-9]*:9999/collectorIpAddress=${COLLECTOR_IP}/'
#    ...    /sharedvolume/flowtracer/config/_collector_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd}=    Catenate   sudo sed -i
#    ...    's/providerControllerAddrList = [0-9]*.[0-9]*.[0-9]*.[0-9]*:20401/providerControllerAddrList = ${PROVIDER_IP}/'
#    ...    /sharedvolume/flowtracer/config/_controller_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${cmd}=    Catenate   sudo sed -i
#    ...    's/autoCollectorList=DataCollector@[0-9]*.[0-9]*.[0-9]*.[0-9]*:9999/autoCollectorList=IntegratedCollector@${COLLECTOR_IP}/'
#    ...    /sharedvolume/flowtracer/config/_controller_config.txt
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#
#Start DCAP Env
#    ${cmd_start_docker}=    Catenate    sudo docker run -d --network host --name flowtracer
#    ...    -v /sharedvolume/flowtracer/:/home/tracer/FlowTracer/ext flowtracer:latest
#    OperatingSystem.Run And Return Rc And Output    ${cmd_start_docker}
#    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#    ${rc}     ${flag}    OperatingSystem.Run And Return Rc And Output     ps -ef|grep "FlowTracer"|grep -v "grep"|wc -l
#    Run keyword if   ${flag}==1   BuiltIn.Log    First Start DCAP Env success.
#    ...   ELSE
#    ...   BuiltIn.Log    First Start DCAP Env fail.
#
#Config and start DCAP Env
#    #Config DCAP Env
#    Start Flowtracer
#
#Start Flowtracer
#    OperatingSystem.Run And Return Rc And Output    sudo docker start flowtracer
#    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#    ${rc}    ${ret}    OperatingSystem.Run And Return Rc And Output     ps -ef|grep "FlowTracer"|grep -v "grep"|wc -l
#    Run keyword if   ${ret}==1    BuiltIn.Log    Start Flowtracer success.
#    ...   ELSE
#    ...   BuiltIn.Log   Start FlowTracer fail.
#
#Delete Old Logfile
#    OperatingSystem.Run And Return Rc And Output   sudo rm -rf /sharedvolume/flowtracer/tmp/5G/*
#
#Start Cplane Session
#    [Arguments]    ${session_name}
#    OperatingSystem.Run And Return Rc And Output   sudo /bin/bash -c '${set_filter}'
#    ${cmd0}=    Catenate    SEPARATOR=    './fcmd 127.0.0.1:55001 cm n=${session_name} p=AutoProvider d=IntegratedCollector\\\@${COLLECTOR_IP} m=
#    ...    [f5c:@ext/5gfilter-e001.txt][sh:${CPNRT}][gnb:${GNB_NAME}] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.conf][s:1]'
#    ${cmd}=    Catenate    sudo docker exec -it flowtracer bash -c    ${cmd0}
#    OperatingSystem.Run And Return Rc And Output    ${cmd}
#
#Reboot cloud gnb and check its status
#    [Timeout]   10 min
#    Log To Console    Reboot cloud gnb via ssh...
#    SSH.connect_to     hostname=${GNB_CU.hostname}    username=${GNB_CU.username}    password=${GNB_CU.password}
#    SSH.execute    sudo reboot
#    wait until keyword succeeds    5min    10sec    Verify BTS Is OnAir
#    wait until keyword succeeds    5min    10sec    Check Connection Status
#    SSH.disconnect
#
#Check Connection Status
#    ${rc}    ${connect_state}    OperatingSystem.Run And Return Rc And Output    sudo netstat -pantu|grep 9999
#    should contain    ${connect_state}    ESTABLISHED
#
#Connect to DCAP
#    SSH.connect_to    hostname=${wts_ip}    username=${wts_username}    password=${wts_password}    alias=DCAP-conn
#
#Close connect of DCAP
#    SSH.disconnect    connection=DCAP-conn
#
#Stop DCAP Monitor Session
#    [Arguments]    ${session_name}
#    OperatingSystem.Run And Return Rc And Output    sudo docker exec -it flowtracer bash -c './fcmd 127.0.0.1:55001 dm ${session_name}'
#
#Check Log Exist
#    Sleep  20s
#    OperatingSystem.Directory Should Not Be Empty   /sharedvolume/flowtracer/tmp/5G/
#
#Check Log
#    [Timeout]   5 min
#    ${current_date}    Get Current Date    result_format=%Y%m%d
#    ${rc}    ${tmp}    OperatingSystem.Run And Return Rc And Output    find ${LOG_PATH}/${current_date}/ -name *.5gm|awk 'END {print}'
#    ${file_size1}    OperatingSystem.Run    ls -lrt ${tmp}|awk '{print $5}'
#    Sleep    10s
#    ${rc}    ${tmp}    OperatingSystem.Run And Return Rc And Output    find ${LOG_PATH}/${current_date}/ -name *.5gm|awk 'END {print}'
#    ${file_size2}    OperatingSystem.Run    ls -lrt ${tmp}|awk '{print $5}'
#    ${result}    run keyword if    ${file_size2}>=${file_size1}    set variable    PASS
#    ...    ELSE    set variable    FAIL
#    should contain    ${result}    PASS
#
#Stop flowtracer
#    OperatingSystem.Run And Return Rc And Output    sudo  docker stop flowtracer
#    OperatingSystem.Run And Return Rc And Output    sudo docker ps -a
#
#Recover TL
#    Log to console    Recover TL is ongoing.
#    OperatingSystem.Run And Return Rc And Output    sudo rm -rf /sharedvolume/flowtracer/5gfilter-e001.txt
#
