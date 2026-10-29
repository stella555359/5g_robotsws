*** Settings ***
Documentation
...    Author: Andrada Bugiu / Cristina Nicolae
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library   SeleniumLibrary
Library   SSHLibrary
Library   Collections
Library   String

*** Variables ***
${VDUSSH}       10.5.26.220
${SSHPASS}      system123
${CRANNAME}     cran1
@{PROCESSES}=  &{process_oamagent}  &{process_cpconfig}  &{process_trsconfig}  &{process_tas}
...             &{process_nts}  &{process_ims}  &{process_ctp}  &{process_eaxc}  &{process_oamfh}
@{PROCESSES_to_kill}=  &{process_fm}  &{process_pm}

&{process_oamagent}     pod=oamext          container=oamagent      process=/opt/nokia/SS_OAM/OAMAGENT/agent_oam.json
&{process_cpconfig}     pod=oamconfig       container=oamconfig     process=/opt/nokia/SS_OAM/CPCONFIG/cpconfigvdu.json
&{process_trsconfig}    pod=oamconfig       container=oamconfig     process=/opt/nokia/SS_OAM/TRSCONFIG/trsconfig.json
&{process_tas}          pod=oamconfig       container=oamconfig     process=/opt/nokia/SS_OAM/TAS/run.sh
&{process_nts}          pod=oamconfig       container=oamconfig     process=/opt/nokia/SS_OAM/NTS/run.sh
&{process_ims}          pod=oamconfig       container=oamconfig     process=/opt/ims/run.sh
&{process_ctp}          pod=oamctp          container=oamctp        process=/opt/nokia/SS_OAM/CTP/ctpvdu.json
&{process_eaxc}         pod=oamfh           container=oamfh         process=/opt/nokia/SS_OAM/EAXC/eaxcfhvdu.json
&{process_oamfh}        pod=oamfh           container=oamfh         process=/opt/nokia/SS_OAM/OAMFH/oamfh.json
&{process_fm}           pod=oamfm           container=oamfm         process=/opt/nokia/SS_OAM/FM/fmvdu.json
&{process_pm}           pod=oampm           container=oampm         process=/opt/nokia/SS_OAM/PM/pmvdu.json


*** Keywords ***
Login SSH
    Open Connection  ${VDUSSH}
    Login  core  ${SSHPASS}
    Write  oc login -u nokiaadmin -p nokiaadmin
    ${login_output}  Read  delay=5s


Verify All Pods Are Running
    Log To Console  ...Verify if all pods are running...
    FOR  ${index}  IN RANGE  200
        Write  oc get pod -n ${CRANNAME}
        ${GETPODSTATUS}=   Read  delay=2s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS}  Running
        ${PodNumber}=      Get Count  ${GETPODSTATUS}  po-
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END


Check container status
    [Arguments]  ${pod}  ${container}
    Verify All Pods Are Running
    Log to console  ...Check container ${container} status...
    Write  oc describe pod -n ${CRANNAME} po-${CRANNAME}-${pod}-0
    Sleep  1
    ${CTR}=  Read
    ${CTR}=  Fetch From Right  ${CTR}  ctr-${CRANNAME}-${container}:
    ${CTR}=  Fetch From Left  ${CTR}  Liveness
    Should contain  ${CTR}  Running
    ${startedTimeCTR}=  Get Lines Containing String  ${CTR}  Started:
    Log to console  startedTimeCTR=${startedTimeCTR}
    [Return]  ${startedTimeCTR}


Verify process inside container
     Login SSH
     FOR  ${process_info}  IN  @{PROCESSES}
         ${process_pod}=          Get From Dictionary  ${process_info}   pod
         ${process_container}=    Get From Dictionary  ${process_info}   container
         ${process}=              Get From Dictionary  ${process_info}   process
         Check process status  ${process_pod}  ${process_container}  ${process}
         Write  exit
         ${output}=  Read  delay=5s
     END
     Close Connection


Kill process
    Login SSH
    FOR  ${process_info}  IN  @{PROCESSES_to_kill}
        ${process_pod}=          Get From Dictionary  ${process_info}   pod
        ${process_container}=    Get From Dictionary  ${process_info}   container
        ${process}=              Get From Dictionary  ${process_info}   process
        ${startedTimeCTRinit}=  Check container status  ${process_pod}  ${process_container}
        ${pid1}  ${startTimeProcess_init}=  Check process status  ${process_pod}  ${process_container}  ${process}
        Log to console   ...Kill process...
        Write  kill -9 ${pid1}
        ${kill_output}=  Read  delay=5s
        Sleep  10
        ${pid2}  ${startTimeProcess_final}=  Check process status  ${process_pod}  ${process_container}  ${process}
        Should not be equal   ${startTimeProcess_init}  ${startTimeProcess_final}
        Write  exit
        ${output}=  Read  delay=5s
        ${startedTimeCTRfinal}=  Check container status  ${process_pod}  ${process_container}
        Should not be equal  ${startedTimeCTRinit}  ${startedTimeCTRfinal}
    END
    Verify All Pods Are Running
    Close Connection


Check process status
    [Arguments]  ${pod}  ${container}  ${process}
    Verify All Pods Are Running
    Log to console  ...Verify process ${process}...
    Write  oc exec -it po-${CRANNAME}-${pod}-0 -c ctr-${CRANNAME}-${container} -n ${CRANNAME} bin/bash
    ${output}=  Read  delay=2s
    Write  ps wwaux | grep ${process}
    ${readoutputps}=  Read  delay=5s
    Sleep  5
    ${internaluoam}=  Get Lines Matching Regexp    ${readoutputps}  ^((?!grep).)*$
    ${internaluoam}=  Get Lines Matching Regexp    ${internaluoam}  ^((?!pipefail).)*$
    Should Contain  ${internaluoam}  ${process}
    ${internaluoam}=  Split String  ${internaluoam}
    ${pid}=  Get From List  ${internaluoam}  1
    ${startTimeProcess}=  Get From List  ${internaluoam}  8
    Log to console  pid=${pid} startTimeProcess=${startTimeProcess}
    [Return]  ${pid}  ${startTimeProcess}
