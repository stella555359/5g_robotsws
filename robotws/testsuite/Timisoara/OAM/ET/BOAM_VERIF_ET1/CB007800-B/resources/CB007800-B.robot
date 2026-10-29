*** Settings ***

Documentation
...    Author: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Maintainer: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007800-B
...    Sample execution: robot -L TRACE -b debug.log -d results general.robot


Library  SeleniumLibrary
Library  SSHLibrary
Library  String

*** Variables ***
#cran12
#${VCU}         https://10.15.253.205    #cran12
#${vCUSSH}      10.5.62.253
#${SSHUSER}     core
#${SSHPASS}     Yt_xk39b@123
#${CRANNAME}    cran12

#cran25
${VCU}         https://10.5.63.198    #cran25
${vCUSSH}      10.5.62.195
${SSHUSER}     core
${SSHPASS}     Yt_xk39b@123
${CRANNAME}    cran25

#${VCU}        https://10.5.58.199  #smoke6
#${VCUSSH}     10.5.62.179
#${SSHPASS}    system123
#${CRANNAME}   smoke6
#@{GREPS} =    cpconfigvcu  trsconfig  run  run  run
@{PODS} =  oamconfig  oamfm  oamcm  oamasm  oamext  cpif  cpcl  cpnrt  cpnb
#@{PODS} =  oamconfig
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

Find VNFC_R-1
    Click element  ${status}
    Sleep  2
    Click element   /status/vnfc

     ${condition}=  run keyword and return status  page should contain  Table View
        run keyword if   ${condition}==True  Click element  //*[contains(text(),'Table View')]

    sleep  3
    FOR    ${index}    IN RANGE    12
        Log    ${index}
        ${rownumber}=  Evaluate  ${index}+1
        ${outputcell}=  Get Table Cell  ${table}  ${rownumber}   3
        log  ${CRANNAME}
        ${cellmatch}=  Run Keyword And Return Status  Should be equal as strings  po-${CRANNAME}-oampm-0  ${outputcell}
        ${outputcell2}=  Get Table Cell  ${table}  ${rownumber}   3
        ${oampm}=  set variable if   ${cellmatch}==True  ${outputcell2}
        exit for loop if  ${cellmatch}==True
    END
    [return]  ${oampm}

Login SSH
    Open Connection  ${VCUSSH}
    Login  core  ${SSHPASS}
    Sleep  5
#    Write  ssh rack1-ocp-master-1      #cran12_master1
#    Write  ssh tm-ocp-rack02-master-2  #cran25_master2
#    Write  oc login -u nokiaadmin -p nokiaadmin
    Write  oc get pods -n ${CRANNAME}
#    Sleep  5
    ${login_output}  Read  delay=5s
    Log To Console   pod output: ${login_output}


Verify All Pods Are Running
    Login SSH
    Log To Console  ....Verify if all pods are running...
    FOR   ${index1}   IN RANGE  37
        Write  oc get pod -n ${CRANNAME}
        Sleep  2
        ${GETPODSTATUS1}=  Read  delay=1s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS1}  Running
        Log To Console    Pod Running: ${RunningStatus}
        ${PodNumber}=      Get Count  ${GETPODSTATUS1}  po-
        Log To Console    Pod Number: ${PodNumber}
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

Check CPUE pods are running
    Log To Console  ...Check that CPUE pods are up and running...
    Login SSH
    Log To Console   Login to vCU successful
    Write  oc get pod po-${CRANNAME}-cpue-0 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod cpue-0 is running.
    Write  oc get pod po-${CRANNAME}-cpue-1 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod cpue-1 is running.


Kill CPUE-0 pod
    Log To Console  ...About to kill pods cpue-0 ...
    Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-cpue-0 -n ${CRANNAME} --grace-period=0 &
    ${reply}  Read Until     nohup.out
    Write  watch oc get pod po-${CRANNAME}-cpue-0 -n ${CRANNAME}
    Sleep  5
    ${reply}  Read Until       Terminating
    Log To Console   Pod cpue-0 is dead.
    Log To Console   FID 4350 should be visible in WebEM...

Check Active Pod
    [Arguments]  ${pod}
    Log To Console  ....Check Active Pod...
    Login SSH
    Sleep  15
   # Write  oc exec -it po-${CRANNAME}-oamconfig-0 -c ctr-${CRANNAME}-oamconfig -n ${CRANNAME} -- bash
    Write  oc exec -it po-${CRANNAME}-oamasm-0 -c ctr-${CRANNAME}-oamasm -n ${CRANNAME} -- bash
    Sleep  15
    ${output_enter_oamagent_pod}  Read  delay=5s
#    Should Contain  ${output_enter_oamagent_pod}  [root@po-${CRANNAME}-oamasm-0:/]
    ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs | grep -o -F -e
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

Check Redundant Pod
#    [Arguments]  ${pod}
    Log To Console  ....Check Active Pod and Standby Pod...
    Login SSH
    Sleep  15
   # Write  oc exec -it po-${CRANNAME}-oamconfig-0 -c ctr-${CRANNAME}-oamconfig /bin/bash -n ${CRANNAME}
    Write  oc exec -it po-${CRANNAME}-oamasm-0 -c ctr-${CRANNAME}-oamasm /bin/bash -n ${CRANNAME}
    Sleep  15
    ${output_enter_oamagent_pod}  Read  delay=5s
#    Should Contain  ${output_enter_oamagent_pod}  [root@po-${CRANNAME}-oamasm-0:/]
    FOR  ${pod}  IN  @{PODS}
     ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs | grep -o -F -e
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
        ${active_pod_name}=    Run Keyword If  ${status_active_pod} == True  Fetch From Right  ${curl_output}  {"name":"
        ${active_pod_name}=    Fetch From Left  ${active_pod_name}   ","hostname"
        Log To Console  active pod name: ${active_pod_name} "redundantRole":"active"
     ${cmd1}=  set variable  curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs | grep -o -F -e
     ${cmd2}=  set variable   '{"name":"po-${CRANNAME}-${pod}-0","hostname":"po-${CRANNAME}-${pod}-0","state":{"admin":
     ${cmd3}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"standby"' -e
     ${cmd4}=  set variable   '{"name":"po-${CRANNAME}-${pod}-1","hostname":"po-${CRANNAME}-${pod}-1","state":{"admin":
     ${cmd5}=  set variable  "unlocked","opera":"enabled","proce":"empty","avail":"empty"},"redundantRole":"standby"'
     ${cmd}=  set variable   ${cmd1}${cmd2}${cmd3}${cmd4}${cmd5}
     Write  ${cmd}
        Sleep  15
        ${curl_output}  Read  delay=5s
        Sleep  2
        ${status_standby_pod}=  Run Keyword And Return Status  Should Contain   ${curl_output}   standby
        ${standby_pod_name}=  Run Keyword If  ${status_standby_pod} == True  Fetch From Right  ${curl_output}  {"name":"
        ${standby_pod_name}=    Fetch From Left  ${standby_pod_name}   ","hostname"
        Log To Console  standby pod name: ${standby_pod_name} "redundantRole":"standby"
    END
    [Return]    ${active_pod_name}

Robustness 4350
    Log To Console  ....Delete cpue pod and check fault 4350...

    Verify All Pods Are Running
#    Check Redundant Pod
#   Check Active Pod   cpue
    Delete Active Pods  cpue
#    Check Fault 4350
     Check Active Pod   cpue
   Logout

Check Fault 4350
    Login vCU
     ${alarm1}=  set variable  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
     ${alarm2}=  set variable  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i
     ${alarm}=   set variable  ${alarm1}${alarm2}
    Click Element   ${alarm}
    Wait until page contains  4350  timeout=350
    Log To Console  FID 4350 is present in the active alarm table!
