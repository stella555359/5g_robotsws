*** Settings ***
Documentation      author: Vivian Huang
...                Group: HGZ_SG7
...                contact: Vivian.huang@nokia-sbell.com
...                Description
Library            OperatingSystem
Library            Process
Library            String
Library            DateTime
Library            taf.transport.ssh    WITH NAME    ssh
Library            Collections
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource           taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Variables ***
${controllerport}    20401
${DCAP_USER}    dcapuser
${DCAP_PASSWD}    dcapuser123
${DCAP_IP}    10.57.167.46
${dcap_delete_file}  echo dcapuser123 | sudo -S rm -rf /sharedvolume/flowtracer/tmp/5G/*
${collector_controller}  cat /sharedvolume/flowtracer/config/_controller_config.txt |grep ^autoCollectorList=DataCollector@
${data_collector}  cat /sharedvolume/flowtracer/config/_controller_config.txt |grep ^integratedCollector=DataCollector@
#${provider_controller}  cat /sharedvolume/flowtracer/config/_controller_config.txt |grep ^providerControllerAddrList
${RMIpAddr}  cat /sharedvolume/flowtracer/config/_controller_config.txt |grep ^restManagementIpAddr
${delete_files}  docker exec -it flowtracer /bin/bash -c 'rm -rf CheckAndCreateSessionForTA.sh; rm -rf result.txt'
${du_lmp}   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${du_lmpSA}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${du_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${du_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${INGRESS}    nft list ruleset -a | grep L3DC_INGRESS |grep 20401 |wc -l
${zmq_sdp_cmd}    lxc-ls |grep 0x1513
${zmq_givaxi_cmd}    lxc-ls |grep 0x1511
${ext_cmd}    netstat -antp | grep 20401 | grep providercontr |wc -l
${cmd0}    tail -n20 /tmp/startup_RCP_SyscomDataProvider.log
${check_saR}     ip route |grep br0 |grep src |grep via
${cmd_unxz}      xz -edf /tmp/startup_RCP_SyscomDataProvider.log.xz
 

*** Keywords ***
Check route to DCAP SA
    [Documentation]  Author:meiya.cheng
    ...              Description:add route to DCAP Server
	Connect to Cloud DU SA
    ${dcapresult}   ssh.execute   command=ip route |grep ${DCAP_IP}   connection=Cloud_DU
	${cmdaa}    Replace String    ${dcapresult}    \r\n    ${EMPTY}
	Run keyword if    len("${cmdaa}")== 0  
    ...    Run keywords    Get route SA 
	...    AND
    ...    Run keywords    Add route to dcap SA
	
Get route SA
    [Documentation]  Author:meiya.cheng
    ...              Description:get route info to DCAP Server
    #${routegrep}   ssh.execute   command=ip route |grep via |grep fp0 |head -n 1|awk -F 'via' '{print $2}'   connection=Cloud_DU
	${routegrep}   ssh.execute   command=ip route |grep br0 |grep via |head -n 1      connection=Cloud_DU
	set suite variable    ${routegrep}
	
Add route to dcap SA
    [Documentation]  Author:meiya.cheng
    ...              Description:add route info to DCAP Server
    ${cmdr1}    Replace String    ${routegrep}    \r\n    ${EMPTY}
	${cmdr1}    Replace String    ${cmdr1}    default     ${EMPTY}
	${cmdr1}    Replace String    ${cmdr1}    metric 1    ${EMPTY}
    ${cmdr0}    ssh.execute    command=ip route add ${DCAP_IP} ${cmdr1} src ${localIpAddr_value} metric 1    connection=Cloud_DU

Check route to DCAP
    [Documentation]  Author:meiya.cheng
    ...              Description:add route to DCAP Server
	Connect to Cloud DU
    ${dcapresult}   ssh.execute   command=ip route |grep ${DCAP_IP}   connection=Cloud_DU
	${cmdaa}    Replace String    ${dcapresult}    \r\n    ${EMPTY}
	Run keyword if    len("${cmdaa}")== 0  
    ...    Run keywords    Get route  
	...    AND
    ...    Run keywords    Add route to dcap
	
Get route
    [Documentation]  Author:meiya.cheng
    ...              Description:get route info to DCAP Server
    ${routegrep}   ssh.execute   command=ip route |grep via |grep fp0 |head -n 1|awk -F 'via' '{print $2}'   connection=Cloud_DU
	set suite variable    ${routegrep}
	
Add route to dcap
    [Documentation]  Author:meiya.cheng
    ...              Description:add route info to DCAP Server
    ${cmdr1}    Replace String    ${routegrep}    \r\n    ${EMPTY}
    ${cmdr0}    ssh.execute    command=ip route add ${DCAP_IP} via ${cmdr1}    connection=Cloud_DU
	 
Check results while nidd is true
    [Documentation]  Author:Vivian.huang
    ...              Description:Check results while nidd is true
    [Arguments]  ${current_date}
    ${tmp}  ssh.execute  
	...    command=find /sharedvolume/flowtracer/tmp/5G/${current_date}/ -name *${current_date}*.5gm|awk 'END {print}'
	...    connection=DCAP-conn
    ${tracefile_1}    Replace String   ${tmp}   \r\n   ${EMPTY}
    ${file_size1_tmp}   ssh.execute   command=ls -lrt ${tracefile_1}|awk '{print $5}'   connection=DCAP-conn
    ${file_size1}   Replace String    ${file_size1_tmp}   \r\n   ${EMPTY}
    Sleep  10s
    ${tmp2}  ssh.execute  
	...    command=find /sharedvolume/flowtracer/tmp/5G/${current_date}/ -name *${current_date}*.5gm|awk 'END {print}'  
	...    connection=DCAP-conn
    ${tracefile_2}    Replace String   ${tmp2}   \r\n   ${EMPTY}
    ${file_size2_tmp}   ssh.execute   command=ls -lrt ${tracefile_2}|awk '{print $5}'   connection=DCAP-conn
    ${file_size2}    Replace String    ${file_size2_tmp}   \r\n   ${EMPTY}
    ${result}  run keyword if  ${file_size2}>=${file_size1}  set variable  PASS  ELSE  set variable  FAIL
    should contain    ${result}    PASS
	
Check the container running ok
    [Documentation]  Author: meiya.cheng
    ...              Description: Check the container running ok
    Check if containers are up and running
    ${provider_status}    Check if Provider Controller is up and running
    ${provider_status}    Get Line    ${provider_status}    0
    Should not be Equal    '${provider_status}'    '${0}'

Deactivating Trace
    [Documentation]  Author: meiya.cheng
    ...              Description: Deactivating Trace actInternalTrace to false
    Get Filter actInternalTrace
    Run Keyword If    '${actInternalTrace_value}'!='false'
	...    Modify actInternalTrace in webui
    ${result}=    Verify Firewall Rule on gNB DU
    ${output}    Get Line    ${result}    0
    Should be Equal    '${output}'    '0'

Activating Trace
    [Documentation]  Author: meiya.cheng
    ...              Description: activating Trace actInternalTrace to true
    #Du login page via webUI
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    Get Filter actInternalTrace
    Run Keyword If    '${actInternalTrace_value}'!='true'
    ...    Restore actInternalTrace in webui
    ${result}=    Verify Firewall Rule on gNB DU
    ${result}    Get Line    ${result}    0
    Should be Equal    '${result}'    '1'
	
Get Filter actInternalTrace 
    [Documentation]  Author: meiya.cheng
    ...              Description: get activate internal trace value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${actInternalTrace_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...   abbr=actInternalTrace
    ...   filter_param=Activate internal trace
    set suite variable    ${actInternalTrace_value}

Modify actInternalTrace in webui
    [Documentation]  Author: meiya.cheng
    ...              Description: modify activate internal trace value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    abbr=actInternalTrace
    ...    new_value=false
    ...    filter_param=Activate internal trace
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Restore actInternalTrace in webui
    [Documentation]  Author:meiya.cheng
    ...              Description: restore activate internal trace value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    abbr=actInternalTrace
    ...    new_value=true
    ...    filter_param=Activate internal trace
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Check tracing logs on Cloud DU
    [Documentation]  Author:Vivian.huang
    ...              Description: tracing logs on Cloud DU
    Connect to Cloud DU
    ${result}    ssh.execute    command=${cmd0}   connection=Cloud_DU
    Disconnect to Cloud DU
    [Return]    ${result}

Check tracing logs on Cloud DU SA
    [Documentation]  Author:Vivian.huang
    ...              Description: tracing logs on Cloud DU SA
    Connect to Cloud DU SA
    ${result}    ssh.execute    command=${cmd0}   connection=Cloud_DU
    Disconnect to Cloud DU
    [Return]    ${result}
	
Check tracing logs on Cloud DU for ASOD
    [Documentation]  Author:meiya.cheng
    ...              Description: tracing logs on Cloud DU for ASOD
    Connect to Cloud DU
	ssh.execute    command=${cmd_unxz}   connection=Cloud_DU
    ${result}    ssh.execute    command=${cmd0}   connection=Cloud_DU
    Disconnect to Cloud DU
    [Return]    ${result}

Common Suite Setup for 1583
    [Documentation]  Author:Vivian.huang
    ...              Description: Common Suite Setup for 1583
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M
    ${SUITE_LOG_PATH}    Join Path    ${OUTPUT DIR}    ${SUITE_NAME}    ${timestamp}
    Create Directory    ${SUITE_LOG_PATH}
    Set Suite Variable    ${SUITE_LOG_PATH}    
 
Connect to DCAP
    [Documentation]  Author:Vivian.huang
    ...              Description: Connect to DCAP
    ssh.connect_to    hostname=${DCAP_IP}    username=${DCAP_USER}    password=${DCAP_PASSWD}    alias=DCAP-conn

Disconnect from DCAP
    [Documentation]  Author:Vivian.huang
    ...              Description: Disconnect from DCAP
    ssh.disconnect    connection=DCAP-conn

Verify Firewall Rule on gNB DU
    [Documentation]  Author:Vivian.huang
    ...              Description: To check firewall rule setting of internal tracing 
    Connect to Cloud DU
    ${l3dc_ingress}=    ssh.execute  command=${INGRESS}    connection=Cloud_DU 
    [Return]    ${l3dc_ingress}

Verify Firewall Rule on gNB DU SA
    [Documentation]  Author:Vivian.huang
    ...              Description: To check firewall rule setting of internal tracing 
    Connect to Cloud DU SA
    ${l3dc_ingress}=    ssh.execute  command=${INGRESS}    connection=Cloud_DU 
    [Return]    ${l3dc_ingress}
    
Check if containers are up and running
    [Documentation]  Author:Vivian.huang
    ...              Description:Check if containers are up and running
    Connect to Cloud DU
	${zmq_sdp_container}=    ssh.execute    command=${zmq_sdp_cmd}    connection=Cloud_DU
    ${zmq_givaxi_container}=    ssh.execute    command=${zmq_givaxi_cmd}    connection=Cloud_DU
    Should Contain    ${zmq_sdp_container}    0x1513    msg=SysComDataProvider/ZMQ/SCTP Container is not ready!
	#Log to console  \n ${zmq_sdp_container}:${zmq_sdp_container}
	Should Contain    ${zmq_givaxi_container}    0x1511
    Disconnect to Cloud DU 
 
Check if Provider Controller is up and running
    [Documentation]  Author:Vivian.huang
    ...              Description:Check if Provider Controller is up and running
    Connect to Cloud DU
    ${result}=    ssh.execute    command=${ext_cmd}    connection=Cloud_DU
    Disconnect to Cloud DU 
    [Return]    ${result}

Clean previous sessions and create new session
    [Documentation]  Author:Vivian.huang
    ...              Description:Clean previous sessions and create new session
	[Arguments]    ${case_num}=A001
	Connect to DCAP
	${ControllerIp}  ssh.execute  command=${collector_controller}  connection=DCAP-conn  timeout=1s
    ${ConIp}    Replace String    ${ControllerIp}    \r\n    ${EMPTY}
    ${conIp}   Fetch From Right  ${ConIp}  @
    Log to console  \n dcap_ip:${conIp}
    ${CollectorIp}  ssh.execute  command=${data_collector}  connection=DCAP-conn  timeout=1s
    ${ColIp}    Replace String    ${CollectorIp}    \r\n    ${EMPTY}
    ${colIp}   Fetch From Right  ${ColIp}  @
    Log to console  \n dcap_ip:${colIp}
	Get localIpAddr
	${fp0}    Catenate    SEPARATOR=:    ${localIpAddr_value}    ${controllerport}
    Log to console  \n du_fp0_ip:${fp0}
	${RMIp}  ssh.execute  command=${RMIpAddr}  connection=DCAP-conn  timeout=1s
	${fcmd_p}    Replace String    ${RMIp}    \r\n    ${EMPTY}
	${fIp}  Fetch From Right  ${fcmd_p}  =
    Log to console  \n providerControllerAddrList:${fIp}
	ssh.execute    
	...    command=docker exec -it flowtracer /bin/bash -c 'ext/deletesession.sh ${case_num} ${conIp} ${fp0} ${colIp} ${fIp}'
	...    connection=DCAP-conn	
	Disconnect from DCAP
    Clean monitoring session logs on DCAP
    Connect to DCAP
    ssh.execute    
	...    command=docker exec -it flowtracer /bin/bash -c 'ext/CheckAndCreateSessionForTA.sh ${case_num} ${conIp} ${fp0} ${colIp} ${fIp}'
	...    connection=DCAP-conn	
	Disconnect from DCAP

Get localIpAddr
    [Documentation]  Author:meiya.cheng
    ...              Description:get localIpAddr
	Du login page via webUI
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${localIpAddr_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...   abbr=localIpAddr
    ...   filter_param=Local IPv4 address
	Log to console  \n local_ip:${localIpAddr_value}
	set suite variable    ${localIpAddr_value}
	[return]    ${localIpAddr_value}
	DU COAM selenium logout

Clean monitoring session logs on DCAP
    [Documentation]  Author:Vivian.huang
    ...              Description:Clean monitoring session logs on DCAP
    Connect to DCAP
    ssh.execute    command=${dcap_delete_file}    connection=DCAP-conn    timeout=1s
    Disconnect from DCAP

Check results while nidd is false
    [Documentation]  Author:Vivian.huang
    ...              Description:Check results while nidd is false
    [Arguments]  ${current_date}
    ${ret}  ssh.execute    command=ls /sharedvolume/flowtracer/tmp/5G/  connection=DCAP-conn
    Should Be Empty  ${ret}

Check results
    [Documentation]  Author:Vivian.huang
    ...              Description:Check results
    [Arguments]  ${new_value}
    Connect to DCAP
    Sleep  120s
    ${current_date}     Get Current Date    result_format=%Y%m%d
    Run keyword if   '${new_value}'=='true'
    ...  Check results while nidd is true  ${current_date}
    ...  ELSE
    ...  Check results while nidd is false  ${current_date}
    [Teardown]  Disconnect from DCAP

Connect to Cloud DU SA
    [Documentation]  Author:Vivian.huang
    ...              Description: Connect to Cloud DU
    [Arguments]    ${alias}=Cloud_DU    ${proxy}=${null}
    ${connected via robot account}=    Run keyword and return status    ssh.Connect to 
    ...    hostname=${du_lmpSA}    username=${du_username}    password=${du_password}
    ...    alias=${alias}    proxy=${proxy}
    run keyword if  not ${connected via robot account}
    ...    ssh.Connect to    hostname=${du_lmpSA}    username=root    alias=${alias}    proxy=${proxy}
	
Connect to Cloud DU
    [Documentation]  Author:Vivian.huang
    ...              Description: Connect to Cloud DU
    [Arguments]    ${alias}=Cloud_DU    ${proxy}=${null}
    ${connected via robot account}=    Run keyword and return status    ssh.Connect to 
    ...    hostname=${du_lmp}    username=${du_username}    password=${du_password}
    ...    alias=${alias}    proxy=${proxy}
    run keyword if  not ${connected via robot account}
    ...    ssh.Connect to    hostname=${du_lmp}    username=root    alias=${alias}    proxy=${proxy}
   
Disconnect to Cloud DU
    [Documentation]  Author:Vivian.huang
    ...              Description: Disconnect to Cloud DU
    [Arguments]    ${alias}=Cloud_DU
    ssh.Disconnect    connection=${alias}
