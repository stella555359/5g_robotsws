*** Settings ***
Documentation
...    Author: Nicolae Cristina (cristina.nicolae@nokia.conm)
...    Maintainer: Nicolae Cristina (cristina.nicolae@nokia.conm)


Library   SeleniumLibrary
Library   SSHLibrary
Library   String


*** Variables ***
${VCU}         https://10.5.63.204/    #cran2
${vCUSSH}      10.5.62.195
${SSHPASS}     Yt_xk39b@123         #old pass: system123
${CRANNAME}    cran31

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

Login vCU
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

Find VNFC_R-1
    Click element  ${status}
    Sleep  2
    Click element   /status/vnfc

    sleep  10
     ${condition}=  run keyword and return status  Element Should Be Visible    ${table}
     run keyword if   ${condition}==False   Click Element   toggle-view-button
    sleep  10
    FOR    ${index}    IN RANGE    24
        Log    ${index}
        ${rownumber}=  Evaluate  ${index}+1
        Wait Until Element Is Visible     ${table}       timeout=20s
        ${outputcell}=  Get Table Cell  ${table}  ${rownumber}   3
        log  ${CRANNAME}
        ${cellmatch}=  Run Keyword And Return Status   Should be equal as strings  po-${CRANNAME}-oampm-0  ${outputcell}
        ${outputcell2}=  Get Table Cell  ${table}  ${rownumber}   4
        ${oampm}=  set variable if   ${cellmatch}==True  ${outputcell2}
        exit for loop if  ${cellmatch}==True
    END
    [return]  ${oampm}

Check fault 7702 active
    Click element   ${alarms}
    Sleep    5
    Page Should Contain    7702
    Page Should Contain    E1 Setup Failure Response after retries

Check fault 7702 deactive
    Click element   ${alarms}
    Sleep    5
    Wait Until Page Does Not Contain    7702
    Wait Until Page Does Not Contain    E1 Setup Failure Response after retries

Alarm 7702
    ${oampm}=  Find VNFC_R-1
    Open Connection     ${vCUSSH}
    Login               core   ${SSHPASS}
    ${readtest}    Read     delay=2s
    Log  ${readtest}
    Write            cd ${CRANNAME}
    sleep  2
    Write               oc get pod -n ${CRANNAME}
    ${GETPOD1}=         Read      delay=1s
    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oampm
    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
    Write               oc exec -it ${OAMPODNAME} -c ctr-${CRANNAME}-oampm /bin/bash -n ${CRANNAME}
    Sleep               15
    Write               ${SPACE}
    ${cmd1}=  set variable   curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
    ${cmd2}=  set variable   --header 'content-type: application/json' --data "{\\"faultId\\":7702,\\"state\\":
    ${cmd3}=  set variable   ,\\"severity\\":2,\\"source\\":\\"MRBTS-2003/EQM_R-1/${oampm}\\",\\"sourceType\\":1,
    ${cmd4}=  set variable   ${SPACE}\\"extraInfo\\":\\"192.168.23.33\\"}"
    ${cmd}=   set variable    ${cmd1}${cmd2}1${cmd3}${cmd4}
    Log                       ${cmd}
    Log to console  .......trigger 7022
    Write                     ${cmd}
    ${cmd_output}    Read  delay=2s
    should contain    ${cmd_output}   "faultId" : 7702
    log to console    ${cmd_output}
    Check fault 7702 active
    ${cmd}=   set variable    ${cmd1}${cmd2}0${cmd3}${cmd4}
    Write                     ${cmd}
    Check fault 7702 deactive
    Close connection

Historical Alarm View

    Mouse Over  ${historicalAlarms}

    Click element    //*[contains(text(),'Historical Alarms')]
    Sleep    5
    Page Should Contain  Severity
     Page Should Contain  Appeared
      Page Should Contain  Cleared
       Page Should Contain  Alarm name
        Page Should Contain  Fault ID
         Page Should Contain   Fault name
          Page Should Contain  Alarming object

    Capture Page Screenshot    historical_alarms=selenium-screenshot-1.png

Alarm Filtering
    Click element    ${majorAlarm}
    Sleep    5
    Page Should Contain    7702
    Page Should Contain    E1 Setup Failure Response after retries
    Capture Page Screenshot    major_alarms=selenium-screenshot-3.png

Alarm 4350
    ${oampm}=  Find VNFC_R-1
    Open Connection     ${vCUSSH}
    Login               core  ${SSHPASS}
    ${readtest}    Read     delay=2s
    Log  ${readtest}
    sleep  2
    Write               oc get pod -n ${CRANNAME}
    ${GETPOD1}=         Read      delay=1s
    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oampm
    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
    Write               oc exec -it ${OAMPODNAME} -c ctr-${CRANNAME}-oampm /bin/bash -n ${CRANNAME}
    Sleep               15
    Write               ${SPACE}
    ${cmd1}=  set variable   curl --request POST --url http://oam-faultmanagement:9004/api/fm/v1/faults${SPACE}
    ${cmd2}=  set variable   --header 'content-type: application/json' --data "{\\"faultId\\":4350,\\"state\\":
    ${cmd3}=  set variable   ,\\"severity\\":2,\\"source\\":\\"MRBTS-2003/EQM_R-1/${oampm}\\",\\"sourceType\\":1,
    ${cmd4}=  set variable   ${SPACE}\\"extraInfo\\":\\"192.168.23.33\\"}"
    ${cmd}=   set variable    ${cmd1}${cmd2}1${cmd3}${cmd4}
    Log                       ${cmd}
    Log to console  .......trigger 4350
    Write                     ${cmd}
    ${cmd_output}    Read  delay=2s
    should contain    ${cmd_output}   "faultId" : 4350
    log to console    ${cmd_output}
    Close connection

Check VM status Widget
	 Wait Until Page Contains Element  ${VNFCStatus}

Check Alarm details view Widget
	 Wait Until Page Contains Element  ${alarmWidget}

Logout vCU
    Click element    ${userSettings}
    Sleep  3
    Page Should Contain  Sign out
    sleep   6
    Click Element  ${signOut}
    Sleep  3
    Close Browser
