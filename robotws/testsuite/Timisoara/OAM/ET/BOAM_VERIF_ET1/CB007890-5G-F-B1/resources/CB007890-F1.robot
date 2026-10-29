*** Settings ***

Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007890-F1
...    Sample execution: robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007800-H/general.robot


Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  DateTime


*** Variables ***
${VCU}         https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${vCUSSH}      ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${SSHUSER}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${SSHPASS}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
${CRANNAME}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}

#@{GREPS} =    cpconfigvcu  trsconfig  run  run  run

*** Keywords ***
Login vCU
#    Open Browser   ${VCU}   Chrome
    Open Browser for ssh
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
	Close Browser

Login SSH
    Open Connection  ${VCUSSH}
    Login  core  ${SSHPASS}
    Sleep  5
#    Write  oc login -u nokiaadmin -p nokiaadmin
    Write  oc get pods -n ${CRANNAME}
    Sleep  5
    ${login_output}  Read  delay=5s
    Log To Console  ${login_output}

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

Delete Active Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods...
    ${POD_ACTIV} =  Check Active Pod  ${pod}
    Login SSH
    Write  oc delete pod ${POD_ACTIV} -n ${CRANNAME}
    ${output_delete_pod}  Read  delay=5s
    Should Contain    ${output_delete_pod}  deleted

Delete Standby Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods...
    ${POD_STANDBY} =  Check Standby Pod  ${pod}
    Login SSH
    Write  oc delete pod ${POD_STANDBY} -n ${CRANNAME}
    ${output_delete_pod}  Read  delay=5s
    Should Contain    ${output_delete_pod}  deleted

Delete
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods healing-controller...
    Login vCU
    Click Element  ${alarms_vCU}
    Login SSH
    Write  nohup watch -n 0 oc delete pod po-${CRANNAME}-${pod}-0 -n ${CRANNAME} --grace-period=0 &
    Write  nohup watch -n 0 oc delete pod po-${CRANNAME}-${pod}-1 -n ${CRANNAME} --grace-period=0 &
     Sleep  15
    Write  oc get pod -n ${CRANNAME} | grep healing-controller
     ${HEALINGPODSTATUS1}  Read  delay=1s
    Should Contain    ${HEALINGPODSTATUS1}  Terminating
    Log To Console  ${HEALINGPODSTATUS1}
    Wait until page contains  4393 timeout=70
    Close connection
    Login SSH
    Reset reason unknown
    wait until keyword succeeds  10min 30sec Verify All Pods Are Running

Delete Pods
    [Arguments]  ${pod}
    Log To Console  ....Delete Pods healing-controller...
    Login SSH
    Write  nohup watch -n 0 oc delete pod po-${CRANNAME}-${pod}-0 -n ${CRANNAME} --grace-period=0 &
    Write  nohup watch -n 0 oc delete pod po-${CRANNAME}-${pod}-1 -n ${CRANNAME} --grace-period=0 &

#    Close connection
###   ### delete after
#    Sleep  30
#    Login SSH
#    Write  kubectl get pods -n cran25
#    Read Until  ~]$
#    Sleep  15
##    Write  whoami
##    ${output}  Read Until  ~]$
##    log to console  ${output}
#    Write  ps aux | grep -ie "watch -n 0 kubectl" | awk '{print $2}' | xargs kill -9
#    Read Until  period=0
##    sleep  30
##    Write  oc get pod -n ${CRANNAME} | grep healing-controller
##     ${HEALINGPODSTATUS1}  Read  delay=1s
##   Should Contain    ${HEALINGPODSTATUS1}  Running
##   Log To Console  ${HEALINGPODSTATUS1}

Restart Pods
    [Arguments]  ${pod}
    Log To Console  ....Restart Pods ${pod}...
    Login SSH
    Write  oc get pod -n ${CRANNAME} | grep healing-controller
    ${HEALINGPODSTATUS1}  Read  delay=1s
    Should Contain    ${HEALINGPODSTATUS1}  Running
    Log To Console  ${HEALINGPODSTATUS1}

Verify pods
    [Arguments]  ${pod}
    Log To Console  ....Verify Pods ${pod} ...
    Login SSH
    Write  oc get pod -n ${CRANNAME} | grep ${pod}
     ${HEALINGPODSTATUS1}  Read  delay=1s
   Should Contain    ${HEALINGPODSTATUS1}  Running
   Log To Console  ${HEALINGPODSTATUS1}

Generate Fault 4693
    Login vCU
    Click Element  ${alarms_vCU}
#    Click Element  //*[@id="/alarm/historical"]/span
    Wait until page contains  4693  timeout=70
    Close connection
    Login SSH
#    Reset reason unknown
#    wait until keyword succeeds  10min 30sec Verify All Pods Are Running
    Click Element  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/webem-page-header/button/div  #DASHBOARD VCU
    Sleep  2
    Click Element  ${reset_vCU}
    Sleep  2
    ${condition}=  run keyword and return status  page should contain  OK
    run keyword if   ${condition}==True  Click Element  ${confirm_dialog}
    Wait until page contains  CU reset operation finished  timeout=600
    Verify All Pods Are Running
    Logout
Reset reason unknown
    Log To Console  ...Trigger vCU reset from a POD...
    Login SSH
    Write  oc exec -it po-${CRANNAME}-oampm-0 -c ctr-${CRANNAME}-oampm -n ${CRANNAME} -- bash
    Write  curl -fsSX POST http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs?operation=restart
