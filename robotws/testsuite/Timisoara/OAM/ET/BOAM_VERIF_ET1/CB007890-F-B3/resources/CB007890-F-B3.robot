*** Settings ***

Documentation
...    Author: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Maintainer: Alexandru Tancau (alexandru.tancau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_SPIRIT_ET_GMS
...    Feature Description: CB007890-F-B3
...    Sample execution: robot -L TRACE -b debug.log -d results
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007890-F-B3/general.robot


Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  DateTime

*** Variables ***

${VCU}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${VCUSSH}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${SSHPASS}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
${CRANNAME}   ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${path_of_commission_file}   /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007890-F-B3/resources
${plan_name}  Configuration_scf_MRBTS-10948_CRAN8-CU-10948_20220322-1751.xml

${alarms_vCU}   //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...             webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]/i

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

Generate Fault 4695 for CPUE
     Check CPUE pods are running
     Kill CPUE pods
     Check FID 4695 in WebEM
     Delete CPUE pods
     Check FID 4695 is cleared

Generate Fault 4695 for UPUE
     Check UPUE pods are running
     Kill UPUE pods
     Check FID 4695 in WebEM
     Check FID 4695 is cleared

Check CPUE pods are running
    Log To Console  ...Checking all 3 CPUE pods are up and running...
    Login SSH
    Log To Console   Login to vCU successful
    Write  oc get pod po-${CRANNAME}-cpue-0 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod cpue-0 is running.
    Write  oc get pod po-${CRANNAME}-cpue-1 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod cpue-1 is running.
    Write  oc get pod po-${CRANNAME}-cpue-2 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod cpue-2 is running.
#    Log To Console   Aici:${reply}
#    Wait Until Keyword Succeeds    10    2    Should contain  ${reply}  Running

#    SSHLibrary.Write          supervisorctl status all
#     ${reply}  SSHLibrary.Read Until       :/opt/dev#
#
#     Wait Until Keyword Succeeds    30    5    Should not contain  ${reply}  RUNNING
    Log To Console  All 3 CPUE pods are up and running!

Check UPUE pods are running
    Log To Console  ...Checking all 3 UPUE pods are up and running...
    Login SSH
    Log To Console   Login to vCU successful
    Write  oc get pod po-${CRANNAME}-upue-0 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod upue-0 is running.
    Write  oc get pod po-${CRANNAME}-upue-1 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod upue-1 is running.
    Write  oc get pod po-${CRANNAME}-upue-2 -n ${CRANNAME}
    ${reply}  Read Until       Running
    Log To Console   Pod upue-2 is running.
    Log To Console  All 3 UPUE pods are up and running!

Kill CPUE pods
    Log To Console  ...About to kill pods cpue-2 and cpue-1...
    ${pod}          Set variable   cpue
    ${ctr}          Set variable   cpue
    ${img}          Set variable   cpue
    ${cmd1}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-${pod}-1 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
     ...     ${ctr}","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/${img}:0.250.4242-fail"}]}}'
    ${cmd2}=  catenate  SEPARATOR=   kubectl patch pod po-${CRANNAME}-${pod}-2 -n ${CRANNAME} -p '{"spec":{"containers":[{"name":"ctr-${CRANNAME}-
    ...      ${ctr}","image":"image-registry.openshift-image-registry.svc:5000/${CRANNAME}/${img}:0.250.4242-fail"}]}}'
    log to console    ${cmd1}
    log to console    ${cmd2}
    Write  ${cmd1}
#    Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-cpue-2 -n ${CRANNAME} --grace-period=0 &
#    ${reply}  Read Until     nohup.out
    Write  oc get pod po-${CRANNAME}-cpue-2 -n ${CRANNAME}
    ${read_output}     read   delay=15s
    ${condition1}      run keyword and return status  should not contain      ${read_output}   Running
#    ${reply}  Read Until       Terminating
    Run keyword if   ${condition1}==True   Log To Console   Pod cpue-2 is dead.
#    Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-cpue-1 -n ${CRANNAME} --grace-period=0 &
#    ${reply}  Read Until     nohup.out
    Write   ${cmd2}
    Write  oc get pod po-${CRANNAME}-cpue-1 -n ${CRANNAME}
    ${read_output}     read   delay=15s
    ${condition1}      run keyword and return status  should not contain      ${read_output}   Running
#    ${reply}  Read Until       Terminating
    Run keyword if   ${condition1}==True   Log To Console   Pod cpue-1 is dead.
    Log To Console   Now 2 CPUE pods out of 3 are down while CPUE_MIN=2 is configured in aic-vcu-cnf/values.yaml.
    Log To Console   FID 4695 should be visible in WebEM...

Kill UPUE pods
    Log To Console  ...About to kill pods upue-2 and upue-1...
    Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-2 -n ${CRANNAME} --grace-period=0 &
    ${reply}  Read Until     nohup.out
    Write  oc get pod po-${CRANNAME}-upue-2 -n ${CRANNAME}
    ${reply}  Read   delay=15s
    ${condition1}      run keyword and return status  should not contain      ${reply}   Running
    Run keyword if   ${condition1}==True   Log To Console   Pod upue-2 is dead.
    Write  nohup watch -n 0 kubectl delete pod po-${CRANNAME}-upue-1 -n ${CRANNAME} --grace-period=0 &
    ${reply}  Read Until     nohup.out
    Write  oc get pod po-${CRANNAME}-upue-1 -n ${CRANNAME}
    ${reply}  Read   delay=15s
    ${condition1}      run keyword and return status  should not contain      ${reply}   Running
    Run keyword if   ${condition1}==True   Log To Console   Pod upue-1 is dead.
    Log To Console   Now 2 UPUE pods out of 3 are down while UPUE_MIN=2 is configured in aic-vcu-cnf/values.yaml.
    Log To Console   FID 4695 should be visible in WebEM...

Check FID 4695 in WebEM
    Log To Console  ...Checking if FID 4695 occured...
    Login vCU
    Click Element  ${alarms_vCU}
    Wait until page contains  4695  timeout=120
    Log To Console  FID 4695 is present in the active alarm table!

Check FID 4695 is cleared
    Log To Console  ...Waiting for FID 4695 to be cleared in Active Alarms table...
    Write   ps aux | grep -ie "watch -n 0 kubectl" | awk '{print $2}' | xargs kill -9
    Wait until page does not contain  4695  timeout=120
    Log To Console  FID 4695 is cleared from Active Alarms table !

Delete CPUE pods
    Write   oc delete pod po-${CRANNAME}-cpue-1 -n ${CRANNAME}
    Write   oc delete pod po-${CRANNAME}-cpue-2 -n ${CRANNAME}

Load SCF on vCU
#    Load SCF
    CU Full Commssion By Rest  ${path_of_commission_file}   ${plan_name}

Load SCF
    Log To Console  Loading SCF configuration on vCU...
    CU Login
    #Login vCU
    Log To Console  Successfully logged in to vCU via WebEM. Starting plan upload...
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
    log to console   Waiting for plan upload operation successful...
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    ${upload_operation_info["action_id"]}    success
     log to console   Start plan validate operation...
     ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
     log to console   Waiting for plan validate operation successful...
     wait until keyword succeeds    180s   10s  CU Check Plan Validate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
     log to console   Starting plan activate operation...
     ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
     log to console   Waiting for plan activate operation success in 10 mins.
     wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success


