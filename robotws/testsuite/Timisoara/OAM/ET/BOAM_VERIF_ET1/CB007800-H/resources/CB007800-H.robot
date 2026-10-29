*** Settings ***

Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007800-H
...    Sample execution: robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007800-H/general.robot


Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  DateTime

Resource          ../../vduResources/vduSelenium.robot
Resource          ../../vduResources/xpathSelenium.robot
Resource          ../../vduResourcesAIC/aic_common_vcu_resources.robot
Resource          ../../vduResourcesAIC/vdu_oam_cm.robot
Resource          ../../vduResourcesAIC/common_setup_teardown.robot
Resource          ../../vduResourcesAIC/aic_common_resources.robot
Resource          ../../vduResourcesAIC/fm.robot
Resource          ../../vduResourcesAIC/cu_cnf.robot
Resource          ../../vduResourcesAIC/cu_oam_state.robot
Resource          ../../CB007800-H/resources/CB007800-H.robot
Resource          ../../CB007800-H/resources/xpath_7800-H.robot
Resource          ../../TL_SETUP_VCU/resources/keyword.robot

*** Variables ***
${MRBTS_ID}       ${tl.gnbs[0].instance_id}
${NRBTS_ID}       ${tl.gnbs[0].instance_id}
${VCU}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${vCUSSH}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${SSHUSER}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${SSHPASS}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
${CRANNAME}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
@{GREPS} =    cpconfigvcu  trsconfig  run  run  run

*** Keywords ***
Login vCU
#    Open Browser   ${VCU}   Chrome
    CB007800-H.Open Browser for ssh
    Sleep    5
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link
    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep  10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains    DUs Status Summary
    Wait Until Page Contains    Cells Status Summary
    Wait Until Page Contains    X2 Links Summary
    Maximize Browser Window

    Sleep   10

Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VCU}
    Sleep    10 secs

Logout
    Click Element  //*[@id="user-settings"]/button/span[2]
    Sleep  2
    Page Should Contain  Sign out
    Sleep  6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep  3
	SeleniumLibrary.Close Browser

Login SSH
    SSHLibrary.Open Connection  ${VCUSSH}
    SSHLibrary.Login  ${SSHUSER}  ${SSHPASS}
    Sleep  5
#    Write  oc login -u nokiaadmin -p nokiaadmin
    SSHLibrary.Write  oc get pods -n ${CRANNAME}
    Sleep  5
    ${login_output}  SSHLibrary.Read  delay=5s

Kill Process
    [Arguments]   ${process}
    Log To Console  ....Kill Process...
    CB007800-H.Login SSH
    Verify All Pods Are Running
    Sleep  5
    ${pid1}=  Get PID  ${process}
    SSHLibrary.Write  kill -9 ${pid1}
    Sleep  10
    ${kill_output}  Read  delay=5s
    Log To Console   kill output: ${kill_output}
    Sleep  10
    ${pid2}=  Get PID  ${process}
    Should Not Be Equal   ${pid1}  ${pid2}
    Log to console  ...Process restarted successfully...

Get PID
    [Arguments]  ${process}
    ${active_pod}=  Check Active Pod  oamasm
    SSHLibrary.Write  exit
    Sleep  5
    SSHLibrary.Write  oc exec -it ${active_pod} -c ctr-${CRANNAME}-oamasm -n ${CRANNAME} -- bash
    Sleep  15
    SSHLibrary.Write  ps wwaux|grep ${process}
    ${readoutputps}  Read  delay=10s
    Sleep  5
    Log To Console   ${readoutputps}
    ${internaluoam}=  Get Lines Matching Regexp    ${readoutputps}  ^((?!grep).)*$
    ${pid1}=          Fetch From Right  ${internaluoam}  root${SPACE}${SPACE}
    ${pid2}=          Strip String   ${pid1}  mode=left
    ${pid}=           Fetch From Left   ${pid2}  ${SPACE}
    Log To Console    pid= ${pid}
    [Return]    ${pid}

Verify All Pods Are Running
    CB007800-H.Login SSH
    Log To Console  ....Verify if all pods are running...
    FOR   ${index1}   IN RANGE  40
        SSHLibrary.Write  oc get pod -n ${CRANNAME}
        Sleep  2
        ${GETPODSTATUS1}=  SSHLibrary.Read  delay=1s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS1}  Running
        ${PodNumber}=      Get Count  ${GETPODSTATUS1}  po-
        Sleep  1
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END

Delete Active Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods...
    ${POD_ACTIV} =  Check Active Pod  ${pod}
    CB007800-H.Login SSH
    SSHLibrary.Write  oc delete pod ${POD_ACTIV} -n ${CRANNAME}
    ${output_delete_pod}  SSHLibrary.Read  delay=5s
    Should Contain    ${output_delete_pod}  deleted

Delete Standby Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods...
    ${POD_STANDBY} =  Check Standby Pod  ${pod}
    CB007800-H.Login SSH
    SSHLibrary.Write  oc delete pod ${POD_STANDBY} -n ${CRANNAME}
    ${output_delete_pod}  SSHLibrary.Read  delay=5s
    Should Contain    ${output_delete_pod}  deleted

Check Active Pod
    [Arguments]  ${pod}
    Log To Console  ....Check Active Pod...
    CB007800-H.Login SSH
    Sleep  15
   # Write  oc exec -it po-${CRANNAME}-oamconfig-0 -c ctr-${CRANNAME}-oamconfig -n ${CRANNAME} -- bash
    SSHLibrary.Write  oc exec -it po-${CRANNAME}-oamasm-0 -c ctr-${CRANNAME}-oamasm -n ${CRANNAME} -- bash
    Sleep  15
    ${output_enter_oamagent_pod}  SSHLibrary.Read  delay=5s
    Should Contain  ${output_enter_oamagent_pod}   [root@po-${CRANNAME}-oamasm-0:/]
#    bash-5.1$
    ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs | grep -o -F -e ${space}
    ${cmd2}=  set variable  '{"name":"po-${CRANNAME}-${pod}-0","hostname":"po-${CRANNAME}-${pod}-0","state":{"admin":
    ${cmd3}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"active"' -e ${space}
    ${cmd4}=  set variable  '{"name":"po-${CRANNAME}-${pod}-1","hostname":"po-${CRANNAME}-${pod}-1","state":{"admin":
    ${cmd5}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"active"'
    ${cmd}=   set variable  ${cmd1}${cmd2}${cmd3}${cmd4}${cmd5}
    SSHLibrary.Write  ${cmd}
    Sleep  15
    ${curl_output}  SSHLibrary.Read  delay=5s
    Sleep  2
    ${status_active_pod}=  Run Keyword And Return Status  Should Contain   ${curl_output}   active
    ${active_pod_name}=    Run Keyword If   ${status_active_pod} == True   Fetch From Right  ${curl_output}  {"name":"
    ${active_pod_name}=    Fetch From Left  ${active_pod_name}   ","hostname"
    Log To Console  active pod name: ${active_pod_name}
    [Return]    ${active_pod_name}

Check Standby Pod
    [Arguments]  ${pod}
    Log To Console  ....Check Standby Pod...
    CB007800-H.Login SSH
   # Write  oc exec -it po-${CRANNAME}-oamconfig-0 -c ctr-${CRANNAME}-oamconfig -n ${CRANNAME} -- bash
    SSHLibrary.Write  oc exec -it po-${CRANNAME}-oampm-0 -c ctr-${CRANNAME}-oampm -n ${CRANNAME} -- bash
    Sleep  15
    ${output_enter_oamagent_pod}  SSHLibrary.Read  delay=5s
    Should Contain  ${output_enter_oamagent_pod}  [root@po-${CRANNAME}-oampm-0:/]
    ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs | grep -o -F -e ${space}
    ${cmd2}=  set variable  '{"name":"po-${CRANNAME}-${pod}-0","hostname":"po-${CRANNAME}-${pod}-0","state":{"admin":
    ${cmd3}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"standby"' -e ${space}
    ${cmd4}=  set variable  '{"name":"po-${CRANNAME}-${pod}-1","hostname":"po-${CRANNAME}-${pod}-1","state":{"admin":
    ${cmd5}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"standby"'
    ${cmd}=  set variable   ${cmd1}${cmd2}${cmd3}${cmd4}${cmd5}
    SSHLibrary.Write  ${cmd}
    Sleep  15
    ${curl_output}  SSHLibrary.Read  delay=5s
    Sleep  2
    ${status_standby_pod}=  Run Keyword And Return Status  Should Contain   ${curl_output}   standby
    ${standby_pod_name}=    Run Keyword If   ${status_standby_pod} == True   Fetch From Right  ${curl_output}  {"name":"
    ${standby_pod_name}=    Fetch From Left  ${standby_pod_name}   ","hostname"
    Log To Console  standby pod name: ${standby_pod_name}
    [Return]    ${standby_pod_name}

Generate Fault 4592
    Reset reason reconfiguration change when SCF full commissioning is executed
    Reset reason reconfiguration change when Delta Plan commissioning is executed
    Reset reason user request
    Reset reason unknown
    Reset reason OAM recovery
    Reset reason platform recovery
#    Login vCU Webem
#    ${out}   cu.get_vnfcs_states
#    ${vnfc}   Get From Dictionary   ${out}  dist_names
#    Log to console  ${vnfc}

Reset reason reconfiguration change when SCF full commissioning is executed
    [Arguments]     ${gnb_index}=0
    log to console  \n Load SCF file
    Branch or Trunk Jenkins
    SCF FILE
#    scf.Save_Scf  file_path=${scf_updated}
    ${scf_path}   OperatingSystem.Join Path    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}   ${SCF_FILE}
    Recommission vCU with new SCF     ${scf_path}   ${SCF_FILE}
#    vCU Full Commission
#    vCU Cluster Login With Admin
#    ${workspace}    Create Workspace
#    set test variable   ${workspace}
#    ${new_kuafu_dir}    vCU Get Kuafu   workspace_dir=${workspace}  kuafu_version=master  # config_file=${NEW_KUAFU_FILE}
#    set test variable   ${new_kuafu_dir}
#    VCU Load And Active SCF By Kuafu    ${new_kuafu_dir}    ${SCF_FILE}
    SCF full commission check fault 4592 was triggered   reconfiguration change


Reset reason reconfiguration change when Delta Plan commissioning is executed

    ${NRBTS_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${gNbIdLength_value}    CU Get Online Parameter Value   ${NRBTS_dn}    gNbIdLength
    Log to console   gNbIdLength value is ${gNbIdLength_value}

    Log to console   change the value of gNbIdLength parameter
    Change gNbIdLength value   23
    Check fault 4592 was triggered  reconfiguration change

    Log to console   Revert the value of gNbIdLength to ${gNbIdLength_value}
    Change gNbIdLength value   ${gNbIdLength_value}


Change gNbIdLength value
    [Arguments]   ${value}
    Check vCU Maximum Plan Number And Delete One If Reach Maximum Number
    CU Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

    ${NRBTS_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
	&{gNbIdLength}  create dictionary  operation_type=replace    parameter_path=/gNbIdLength    value=${value}
    @{gNbIdLength_Para_list}=    Create List  ${gNbIdLength}
	CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${NRBTS_dn}
	...  parameter_change_list=${gNbIdLength_Para_list}

	CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    wait until keyword succeeds    3min    30s     Verify all CU containers are running  #Verify All Pods Are Running
    [Teardown]  Run keyword and ignore error   CU Logout


Reset reason user request
    Log to console  \n ...Perform vCU site reset...
    Login vCU Webem
    Reset CU By REST
    Verify all CU containers are running

#    Click Element  ${reset_vCU}
#    Sleep  2
#    ${condition}=  run keyword and return status  page should contain  OK
#    run keyword if   ${condition}==True  Click Element  ${confirm_dialog}
#    Wait until page contains  CU reset operation finished  timeout=600
    Check fault 4592 was triggered  user request

Reset reason unknown
    Log To Console  \n ...Trigger vCU reset from a POD...
    CB007800-H.Login SSH
    SSHLibrary.Write  oc exec -it po-${CRANNAME}-oampm-0 -c ctr-${CRANNAME}-oampm -n ${CRANNAME} -- bash
    SSHLibrary.Write  curl -fsSX POST http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs?operation=restart
    Sleep  15s
    Verify if pods are Terminating
    Verify all CU containers are running
    Check fault 4592 was triggered  unknown

Check fault 4350 with recovery
#    wait until keyword succeeds  2min  5s   VCU Check Active Alarm Should Contain Fault   4350
    ${alarm_list}    VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '4350'
    should contain    '@{alarm_list}'    'alarm_id': 7101
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION'
    should contain    '@{alarm_list}'    'fault_name': 'BTS site autonomous reset as recovery action'
    should not contain    '@{alarm_list}'    'alarming_object': 'VNFC_R-23'

Reset reason OAM recovery
    Log To Console  \n ...Trigger OAM recovery reset...
    Login vCU Webem
    Crash all UPUE pods
    wait until keyword succeeds  2min  5s    Check fault 4350 with recovery
    Verify if pods are Terminating
    Verify all CU containers are running  #Verify All Pods Are Running
    Check fault 4592 was triggered  oam recovery reset

Reset reason platform recovery
    Log to Console  ...Trigger Platform recovery...
    CB007800-H.Login SSH
    start command  oc get pods -n ${CRANNAME} | grep trsconfig | awk '{print $1}'
    ${output_trsconfig_pod}  Read Command Output  delay=5s
    SSHLibrary.Write  oc delete pod ${output_trsconfig_pod} -n ${CRANNAME}
    Sleep  60s
    Verify all CU containers are running  #Verify All Pods Are Running
    Sleep  120s
    Check fault 4592 was triggered  platform recovery reset

Check fault 4592 was triggered
    [Arguments]     ${last_reset_reason}
    log to console  \n Check fault 4592 was triggered
#    Click Element  ${alarms_vCU}
#    Click Element  //*[@id="/alarm/historical"]/span
    Login vCU Webem
#    ${output_alarms}=  CU Get Historical Alarms
#    log to console    alarm=@{output_alarms}
    Check last BTS restart from HC
    wait until keyword succeeds  2min  30s    VCU Check Historical Alarm Should Contain Fault  4592
    ${alarm_list}    VCU Get Historical Alarm Fault by REST API
    should contain    '@{alarm_list}'    'alarm_id': 7115
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should contain    '@{alarm_list}'    'fault_name': 'BTS Reset Cause'
    should contain    '@{alarm_list}'    'alarming_object': 'MRBTS-1'
    should contain    '@{alarm_list}'
    ...               'additional_info': 'supplAlarmInfo=BTS booted at ${RST_TIMESTAMP} due to ${last_reset_reason}; affected_cells=NR:unknown;'
#    wait until keyword succeeds  2min  30s   CU Alarm Should Exist In Historical Alarms
#        ...               fault_id=4592  fault_name=BTS Reset Cause
#        ...               alarm_id=7115   alarm_name=BASE STATION INFORMATION
    log to console    Fault ${4592} was successfully raised after vCU site reset due to ${last_reset_reason}

SCF full commission check fault 4592 was triggered
    [Arguments]     ${last_reset_reason}
    log to console  \n Check fault 4592 was triggered
#    Click Element  ${alarms_vCU}
#    Click Element  //*[@id="/alarm/historical"]/span
    Login vCU Webem
#    ${output_alarms}=  CU Get Historical Alarms
#    log to console    alarm=@{output_alarms}
    Check last BTS restart from HC
    wait until keyword succeeds  2min  30s    VCU Check Historical Alarm Should Contain Fault  4592
    ${alarm_list}    VCU Get Historical Alarm Fault by REST API
    should contain    '@{alarm_list}'    'alarm_id': 7115
    should contain    '@{alarm_list}'    'alarm_name': 'BASE STATION INFORMATION'
    should contain    '@{alarm_list}'    'fault_name': 'BTS Reset Cause'
    should contain    '@{alarm_list}'    'alarming_object': 'MRBTS'
    should contain    '@{alarm_list}'
    ...               'additional_info': 'supplAlarmInfo=BTS booted at ${RST_TIMESTAMP} due to ${last_reset_reason}; affected_cells=NR:unknown;'
#    wait until keyword succeeds  2min  30s   CU Alarm Should Exist In Historical Alarms
#        ...               fault_id=4592  fault_name=BTS Reset Cause
#        ...               alarm_id=7115   alarm_name=BASE STATION INFORMATION
    log to console    Fault ${4592} was successfully raised after vCU site reset due to ${last_reset_reason}

Check last BTS restart from HC
    Log to console  \n Check last vCU restart timestamp
    ${command}=  catenate  SEPARATOR=     kubectl -n ${CRANNAME} -it exec po-${CRANNAME}-oamext-0 -c ctr-${CRANNAME}-oamagent -- bash
    CB007800-H.Login SSH
    Sleep  5s
    SSHLibrary.Write  ${command}
    ${output_enter_oamagent_pod}  SSHLibrary.Read  delay=5s
    Log to console   ${output_enter_oamagent_pod}
    Should Not Contain  ${output_enter_oamagent_pod}   core
    ${command}=  catenate  SEPARATOR=   curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/events/lastvnfrestart
    SSHLibrary.Write   ${command}
    Sleep  7s
    ${output_last_restart}  SSHLibrary.Read
    ${prompt}=  Get line   ${output_last_restart}  -1
    Set Client Configuration  prompt=${prompt}
    SSHLibrary.Write   ${command}
    ${output_last_restart}  SSHLibrary.Read Until Prompt  strip_prompt=True
    Log to console  output_last_restart=  ${output_last_restart}
    SSHLibrary.Close Connection
    OperatingSystem.Create File   ~/restart.json     ${output_last_restart}
    ${timestamp}    Run  command=jq '. | .trigger.timestamp' ~/restart.json
    ${timestamp}=       Split String
    ...                 string=${timestamp}
    ...                 separator="
    ...                 max_split=3
    ${RST_TIMESTAMP}  Get from List  ${timestamp}  1
    Set Global Variable  ${RST_TIMESTAMP}
    Log to console  Last restart at ${RST_TIMESTAMP}
#    ${now}  Get Current Date  result_format=%Y-%m-%d
#    Sleep  10s
#    #Click Element   ${alarms_table}
#    ${alarms}=  Get WebElements  ${alarms_table}
#    #${table_columns}=  split string  ${alarms.text}
#    #log  columns: ${table_columns}
#    FOR  ${element}  IN  100   #@{alarms}
#        Log    ${element.text}
#        ${result}=  Run Keyword And Return Status    Should Contain  ${element.text}  4592
#        Continue For Loop If  $result == False
#        Run Keyword If  ${result}==True   Get date from table  ${element.text}      ELSE    Fail   Cannot extract alarm timestamp
#    END
#    Check alarm timestamp   ${curent_DateAndTime}

Crash all UPUE pods
    Log to console   \n Crash all UPUE pods
    ${cmd1}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-upue-0 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
     ...     l2hicu","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/l2hi:0.250.4242-fail"}]}}'
    ${cmd2}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-upue-1 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
    ...     l2hicu","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/l2hi:0.250.4242-fail"}]}}'
    ${cmd3}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-upue-2 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
     ...     l2hicu","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/l2hi:0.250.4242-fail"}]}}'
    log to console    ${cmd1}
    log to console    ${cmd2}
    log to console    ${cmd3}
    vCU Cluster Login With Admin
    tafssh.Execute    command=${cmd1}
    tafssh.Execute    command=${cmd2}
    tafssh.Execute    command=${cmd3}
#    CB007800-H.Login SSH
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-0 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-1 -n ${CRANNAME} --grace-period=0 &
#    SSHLibrary.Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-2 -n ${CRANNAME} --grace-period=0 &
    [Teardown]    helm.helm_master_close
