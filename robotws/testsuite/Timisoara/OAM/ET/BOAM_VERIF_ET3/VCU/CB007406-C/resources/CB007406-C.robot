*** Settings ***

Documentation
...    Author: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Maintainer: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_TIM_3_ET_GMS
...    Feature Description: CB007406-C
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot
Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  Collections

*** Variables ***

${VCU}        https://10.15.253.195
${VCUSSH}     10.5.62.195
${SSHPASS}    Yt_xk39b@123
${CRANNAME}   cran31
@{GREPS} =    cpconfigvcu  trsconfig  run  run  run

*** Keywords ***

Login SSH
    Open Connection  ${VCUSSH}
    Login  core  ${SSHPASS}
    Sleep  5
    Write  oc login -u nokiaadmin -p nokiaadmin
    Sleep  5
    ${login_output}  Read  delay=2s
    log to console  ${login_output}

Kill Process
    [Arguments]   ${process}
    Log To Console  ....Kill Process...
    Login SSH
    Verify All Pods Are Running
    Sleep  5
    ${pid1}=  Get PID  ${process}
    Write  kill -9 ${pid1}
    Sleep  10
    ${kill_output}  Read  delay=5s
    Log To Console   kill output: ${kill_output}
    Sleep  10
    ${pid2}=  Get PID  ${process}
    Should Not Be Equal   ${pid1}  ${pid2}
    Log to console  ...Process restarted successfully...

Get PID
    [Arguments]  ${process}
    ${active_pod}=  Check Active Pod  oamconfig
    sleep  15
    write  exit
    sleep  5
    Write  oc exec -it ${active_pod} -c ctr-${CRANNAME}-oamconfig /bin/bash -n ${CRANNAME}
    Sleep  15
    Write  ps wwaux | grep ${process}
    ${readoutputps}  Read  delay=10s
    Sleep  5
    Log To Console   ${readoutputps}
    ${internaluoam}=  Get Lines Matching Regexp    ${readoutputps}  ^((?!grep).)*$
    ${pid1}=          Fetch From Right  ${internaluoam}  9999${SPACE}${SPACE}           #root -> 9999
    ${pid2}=          Strip String   ${pid1}  mode=left
    ${pid}=           Fetch From Left   ${pid2}  ${SPACE}
    Log To Console    pid= ${pid}
    [Return]    ${pid}

Verify All Pods Are Running
    Login SSH
    Log To Console  ....Verify if all pods are running...
    FOR   ${index1}   IN RANGE  30
        Write  oc get pod -n ${CRANNAME}
        Sleep  2
        ${GETPODSTATUS1}=  Read  delay=1s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS1}  Running
        ${PodNumber}=      Get Count  ${GETPODSTATUS1}  po-
        Sleep  1
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END

Delete Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods...
    ${POD_ACTIV} =  Check Active Pod  ${pod}
    Login SSH
    Write  oc delete pod ${POD_ACTIV} -n ${CRANNAME}
    ${output_delete_pod}  Read  delay=5s
    Should Contain    ${output_delete_pod}  deleted

Check Active Pod
    [Arguments]  ${pod}
    Log To Console  ....Check Active Pod...
    Login SSH
    Write  oc exec -it po-${CRANNAME}-oampm-0 -c ctr-${CRANNAME}-oampm /bin/bash -n ${CRANNAME}
    Sleep  15
    ${output_enter_oamagent_pod}  Read  delay=5s
    Should Contain  ${output_enter_oamagent_pod}  bash-5.1$
    ${curl1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs |${SPACE}
    ${curl2}=  set variable  grep -o -F -e '{"name":"po-${CRANNAME}-${pod}-0","hostname":"po-${CRANNAME}-${pod}-0",
    ${curl3}=  set variable  "state":{"admin":"unlocked","opera":"enabled","proce":"empty","avail":"empty"},
    ${curl4}=  set variable  "redundantRole":"active"' -e '{"name":"po-${CRANNAME}-${pod}-1","hostname":
    ${curl5}=  set variable  "po-${CRANNAME}-${pod}-1","state":{"admin":"unlocked","opera":"enabled","proce":"empty",
    ${curl6}=  set variable  "avail":"empty"},"redundantRole":"active"'
    ${curl}=  set variable  ${curl1}${curl2}${curl3}${curl4}${curl5}${curl6}
    Write  ${curl}
    Sleep  15

    ${curl_output}  Read  delay=5s
    Sleep  2
    ${status_active_pod}=  Run Keyword And Return Status  Should Contain   ${curl_output}   active
    ${active_pod_name}=    Run Keyword If   ${status_active_pod} == True   Fetch From Right  ${curl_output}  {"name":"
    ${active_pod_name}=    Fetch From Left  ${active_pod_name}   ","hostname"
    Log To Console  active pod name: ${active_pod_name}
    [Return]    ${active_pod_name}
