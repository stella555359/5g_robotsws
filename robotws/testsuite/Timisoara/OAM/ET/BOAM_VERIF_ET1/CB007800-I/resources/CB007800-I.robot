*** Settings ***

Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007808-I
...    Sample execution: robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007800-I/general.robot


Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  DateTime

*** Variables ***
#smoke6
#${VCU}         https://10.5.58.199
#${vCUSSH}      10.5.62.179
#${SSHUSER}     core
#${SSHPASS}     system123
#${CRANNAME}    smoke6

#cran25
#${VCU}         https://10.5.63.198    #cran25
#${vCUSSH}      10.5.62.195
#${SSHUSER}     core
#${SSHPASS}     Yt_xk39b@123
#${CRANNAME}    cran25

${MRBTS_ID}       ${tl.gnbs[0].instance_id}
${NRBTS_ID}       ${tl.gnbs[0].instance_id}
${VCU}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${vCUSSH}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${SSHUSER}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${SSHPASS}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
${CRANNAME}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}

#cran12
#${VCU}        https://10.15.253.205
#${VCUSSH}     10.5.62.253
#${SSHPASS}    Yt_xk39b@123
#${CRANNAME}   cran12
#@{GREPS} =    cpconfigvcu  trsconfig  run  run  run

*** Keywords ***

Login SSH
    Open Connection  ${VCUSSH}
    Login  core  ${SSHPASS}
    Sleep  5
#    Write  oc login -u nokiaadmin -p nokiaadmin
    Write  oc get pods -n ${CRANNAME}
    Sleep  5
    ${login_output}  Read  delay=5s
    Log To Console  ${login_output}

Kill Process
    [Arguments]   ${process}
    Log To Console  ....Kill Process...
#    Login SSH
    Verify All Pods Are Running
    Sleep  5
    ${pid1}=  Get PID  ${process}
    Log To Console   ${pid1}
    Write  kill -9 ${pid1}
    Sleep  10
    ${kill_output}  Read  delay=5s
    Log To Console   kill output: ${kill_output}
    Sleep  60
    ${pid2}=  Get PID  ${process}
    Log To Console   ${pid2}
    Should Not Be Equal   ${pid1}  ${pid2}
    Log to console  ...Process restarted successfully...

Get PID
    [Arguments]  ${process}
    ${active_pod}=  Check Active Pod  oamasm
    Write  exit
    Sleep  5
    Write  oc exec -it ${active_pod} -c ctr-${CRANNAME}-oamasm -n ${CRANNAME} -- bash
    Sleep  15
    Write  ps wwaux|grep ${process}
    ${readoutputps}  Read  delay=10s
    Sleep  5
    Log To Console   ${readoutputps}
    ${internaluoam}=  Get Lines Matching Regexp    ${readoutputps}  ^((?!grep).)*$
    ${pid1}=          Fetch From Right  ${internaluoam}  9999${SPACE}${SPACE}
    ${pid2}=          Strip String   ${pid1}  mode=left
    ${pid}=           Fetch From Left   ${pid2}  ${SPACE}
    Log To Console    pid= ${pid}
    [Return]    ${pid}

Verify All Pods Are Running
    Login SSH
    Log To Console  ....Verify if all pods are running...
    FOR   ${index1}   IN RANGE  37
        Write  oc get pod -n ${CRANNAME}
        Sleep  2
        ${GETPODSTATUS1}=  Read  delay=1s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS1}  Running
        ${PodNumber}=      Get Count  ${GETPODSTATUS1}  po-
        Sleep  1
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END
#    Log To Console  ${GETPODSTATUS1}


#
##    Close connection
####   ### delete after
##    Sleep  30
##    Login SSH
##    Write  kubectl get pods -n cran25
##    Read Until  ~]$
##    Sleep  15
###    Write  whoami
###    ${output}  Read Until  ~]$
###    log to console  ${output}
##    Write  ps aux | grep -ie "watch -n 0 kubectl" | awk '{print $2}' | xargs kill -9
##    Read Until  period=0
###    sleep  30
###    Write  oc get pod -n ${CRANNAME} | grep healing-controller
###     ${HEALINGPODSTATUS1}  Read  delay=1s
###   Should Contain    ${HEALINGPODSTATUS1}  Running
###   Log To Console  ${HEALINGPODSTATUS1}
#
#Verify pods
#    [Arguments]  ${pod}
#    Log To Console  ....Verify Pods ${pod} ...
#    Login SSH
#    Write  oc get pod -n ${CRANNAME} | grep ${pod}
#     ${HEALINGPODSTATUS1}  Read  delay=1s
#   Should Contain    ${HEALINGPODSTATUS1}  Running
#   Log To Console  ${HEALINGPODSTATUS1}
#
Check Active Pod
    [Arguments]  ${pod}
    Log To Console  ....Check Active Pod...
    Login SSH
    Sleep  15
   # Write  oc exec -it po-${CRANNAME}-oamconfig-0 -c ctr-${CRANNAME}-oamconfig -n ${CRANNAME} -- bash
    Write  oc exec -it po-${CRANNAME}-oamasm-0 -c ctr-${CRANNAME}-oamasm -n ${CRANNAME} -- bash
#    Sleep  15
    ${output_enter_oamagent_pod}  Read  delay=10
#    Should Contain  ${output_enter_oamagent_pod}  bash-5.1$  # for cran12
#    Should Contain  ${output_enter_oamagent_pod}  #
#  [root@po-${CRANNAME}-oamasm-0:/]
    ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs |grep -o -F -e
    ${cmd2}=  set variable   '{"name":"po-${CRANNAME}-${pod}-0","hostname":"po-${CRANNAME}-${pod}-0","state":{"admin":
    ${cmd3}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"active"' -e
    ${cmd4}=  set variable   '{"name":"po-${CRANNAME}-${pod}-1","hostname":"po-${CRANNAME}-${pod}-1","state":{"admin":
    ${cmd5}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"active"'
    ${cmd}=   set variable  ${cmd1}${cmd2}${cmd3}${cmd4}${cmd5}
    Write  ${cmd}
    Sleep  15
    ${curl_output}  Read  delay=5s
    Sleep  2
    ${status_active_pod}=  Run Keyword And Return Status  Should Contain   ${curl_output}   active
    ${active_pod_name}=    Run Keyword If   ${status_active_pod} == True   Fetch From Right  ${curl_output}  {"name":"
    ${active_pod_name}=    Fetch From Left  ${active_pod_name}   ","hostname"
    Log To Console  active pod name: ${active_pod_name}
    [Return]    ${active_pod_name}



