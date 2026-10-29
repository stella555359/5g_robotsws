*** Settings ***
Documentation
...    Author: Andrada Bugiu / Cristina Nicolae
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library   SeleniumLibrary
Library   SSHLibrary
Library   String
Library   OperatingSystem
Library   DateTime

*** Variables ***
${VCU}          https://10.15.253.201
${VCUSSH}       10.5.62.253
${SSHPASS}      Yt_xk39b@123               
${CRANNAME}     cran2

*** Keywords ***
Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VCU}
    Sleep    10 secs

Login CU
    Open Browser for ssh
    Sleep    4
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...  click button  details-button  AND  click link  proceed-link

    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep   10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains    DUs Status Summary
    Wait Until Page Contains    Cells Status Summary
    Wait Until Page Contains    X2 Links Summary
    Maximize Browser Window
    sleep   4


Logout CU
    Click element  //*[@id="user-settings"]/button/span[2]
    Sleep  2
    Page Should Contain       Sign out
    sleep   6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep     3
	Close Browser


Go to VNFC Status tableview
        Click Element      ${Status_buton}
	    Sleep    6
        Click Element	   /status/vnfc
        Sleep    6
        Click Element      toggle-view-button
		Sleep    6


Go to VNFC Status widgetview
        Click Element      ${Status_buton}
	    Sleep    6
        Click Element	   vm-status
        Sleep    6


Check if the list of pods with their properties and statuses is available as a table
        Element Should Contain     ${PODS_Table}  cpcl-
		Element Should Contain     ${PODS_Table}  oamasm-
		Element Should Contain     ${PODS_Table}  oamcm-
		Element Should Contain     ${PODS_Table}  upue-
		Element Should Contain     ${PODS_Table}  cpif-
		Element Should Contain     ${PODS_Table}  cpnb-
		Element Should Contain     ${PODS_Table}  cpnrt-
		Element Should Contain     ${PODS_Table}  cpue-
		Element Should Contain     ${PODS_Table}  oamext-
		Element Should Contain     ${PODS_Table}  oamfm-
		Element Should Contain     ${PODS_Table}  oamconfig-
		Element Should Contain     ${PODS_Table}  oampm-
		Capture Page Screenshot     filename=5GC007467D_Check_pods_tableview.png


Check details panel
        Click element  ${Details_button}
        sleep  2
        FOR    ${index}    IN RANGE    12

            ${xpath1}=      set variable  //*[@id="webem-root"]/div/div/webem-single-column-layout/
            ${xpath2}=      set variable  webem-page-layout/div/ui-webem-panel-split/as-split/div[2]/
            ${xpath3}=      set variable  div/div/vm-status/div/vm-status-infrastructure-status/
            ${xpath4}=      set variable  infrastructure-status-table-view/ui-webem-table-view/p-table/
            ${xpath5}=      set variable  div/div[1]/div/cdk-virtual-scroll-viewport/div[1]/table/tbody/

            ${pod_name}=      set variable  xpath=${xpath1}${xpath2}${xpath3}${xpath4}${xpath5}tr[${podnumber}]/td[3]
            ${id}=          set variable   xpath=${xpath1}${xpath2}${xpath3}${xpath4}${xpath5}tr[${podnumber}]/td[4]

            Click element   ${xpath1}${xpath2}${xpath3}${xpath4}${xpath5}tr[${podnumber}]

            ${details_podname}=  Get Element Attribute  ${details_panel_pod_xpath}  title
            ${podname}  Get Text  ${pod_name}
            log to console   ...check pod ${podname}
            Should be Equal As Strings  ${details_podname}  ${podname}
            sleep  2

            ${details_R_id}  Get Element Attribute  ${details_id}   title
            ${R_id}  Get Text  ${id}
            Should be Equal As Strings  ${details_R_id}  ${R_id}
            sleep  2

            ${availability_status}  Get Element Attribute  ${details_availability_status}   title
            Should not be Empty  ${availability_status}
            sleep  2

            ${operational_state}  Get Element Attribute  ${details_operational_state}   title
            Should not be Empty  ${operational_state}
            sleep  2

            ${list_ips}=  Get WebElements  ${pod-ip-addresses-table}
            ${cnt}=    Get length    ${list_ips}

        END
        [Return]   ${cnt}

Verify IP not empty
    ${cnt}=  Check details panel
     FOR   ${index}   IN RANGE   ${cnt}
        ${elem_nr}=   Evaluate  ${index}+1
         ${ip}  Get Element Attribute
                ...  //*[@id="pod-ip-addresses-table"]/ui-webem-detail-data-row[${elem_nr}]/div/div[2]   title
         Should not be Empty  ${ip}
         sleep  2
     END

Kill process
    log to console  ${CRANNAME}
    log to console  ....check restarted process
    Open Connection  ${VCUSSH}
    Sleep  2
    Login            core   ${SSHPASS}
    sleep  2
    Log to console  Verify if all pods are running
    FOR   ${index1}   IN RANGE   20
        Write               oc get pod -n ${CRANNAME}
        ${GETPODSTATUS1}=         Read      delay=3s
        ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
        ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
        Sleep              1
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END

    sleep  5

    ${pid1}=  Get PID
    Write  kill -9 ${pid1}
    Sleep  10
    ${kill_output}  Read  delay=5s
    log  ${kill_output}
    log to console  .....Sleeping 200s
    Sleep   200
    ${pid2}=  Get PID
    should not be equal   ${pid1}  ${pid2}
    Log to console  Process restarted successfully...
    Close Connection


Get PID
    Write              oc get pod -n ${CRANNAME}
    ${GETPOD1}=         Read      delay=1s
    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oamconfig
    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
    Write               oc exec -it ${OAMPODNAME} -c ctr-${CRANNAME}-oamconfig bash -n ${CRANNAME}
    Sleep               15
    Write  ps wwaux|grep cpconfig
    ${readoutputps}    Read     delay=10s
    sleep  5
    log  ${readoutputps}
    ${internaluoam}=            Get Lines Containing String    ${readoutputps}     /opt/nokia/SS_OAM/CPCONFIG/CPCONFIG
    ${pid1}=      Fetch From Right  ${internaluoam}     9999                     #root -> 9999
    ${pid2}=      strip string   ${pid1}  mode=left
    ${pid}=      Fetch From Left   ${pid2}  ${SPACE}
    log to console   pid=${pid}
    [Return]    ${pid}


Generate fault 4473
   Open Connection  ${VCUSSH}
   Login            core   ${SSHPASS}
   ${readtest}    Read     delay=2s
   Log  ${readtest}
   Write            cd ${CRANNAME}
   Write               oc get pod -n ${CRANNAME}
   ${GETPOD1}=         Read      delay=1s
   ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oamext
   ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
   Write               oc exec -it ${OAMPODNAME} -c ctr-${CRANNAME}-oamagent bash -n ${CRANNAME}
   Sleep               15
   Write               ${SPACE}
   ${cmd1}=  set variable   curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
   ${cmd2}=  set variable   --header 'content-type: application/json' --data "{\\"faultId\\":4473,\\"state\\":
   ${cmd3}=  set variable   ,\\"severity\\":2,\\"source\\":\\"MRBTS-1/NRBTS-1\\",\\"sourceType\\":1,
   ${cmd4}=  set variable   \\"extraInfo\\":\\"192.168.23.33\\"}"
   ${cmd}=   set variable    ${cmd1}${cmd2}1${cmd3}${cmd4}
   Log                       ${cmd}
   Log to console  .......trigger 4473
   Write                     ${cmd}
   ${cmd_output}    Read  delay=2s
   should contain    ${cmd_output}   4473   #   "faultId" : 4473
   log to console  ${cmd_output}
   CLose connection


Check VCU recovery
	sleep  10
	click element   ${alarm_active}
#    wait until page contains  4473  timeout=600s
#    wait until page contains  7101  timeout=600s
    log to console  ....waiting for recovery
    wait until page contains  Connection to the server was lost.  timeout=600s
