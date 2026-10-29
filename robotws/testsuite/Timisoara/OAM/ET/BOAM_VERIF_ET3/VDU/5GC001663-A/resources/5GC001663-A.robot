*** Settings ***
Documentation
...    Author: Adelina Gordan (adelina.gordan@nokia.com)
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  OperatingSystem
Library  DateTime

*** Variables ***
${VDU}        https://10.5.62.58/
${VDUSSH}     10.5.26.222
${VDUFHGW}      10.15.217.209
${FHGWPASS}     root
${RU}           root@169.254.1.2
${RU-PROXY}     ruproxy-1-0
${SSHPASS}       Yt_xk39b@123
${vDUnr}          4


*** Keywords ***

Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VDU}
    Sleep    10 secs

Login vDU
    Open Browser for ssh
#    Open browser  ${VDU}  chrome
    Sleep   4
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Input Text      login-username    Nemuadmin
    Input Text      login-password    nemuuser
    Click Button    Login
    Sleep  3

    ${condition}=  run keyword and return status  page should contain  Confirm
        run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Maximize Browser Window
    Sleep  4
    Wait Until Page Contains    Radio Modules Status Summary
    Wait Until Page Contains    Cells Status Summary

Generate fault 4527
     log to console  ....generate fault 4527
     Open Connection                     ${VDUFHGW}
     Login            _nokfhgwoperator   ${FHGWPASS}
     Write  root
     ${readtest}    Read     delay=2s
     Log  ${readtest}
     Write            kubectl exec -it ${RU-PROXY} bash
     sleep  2
     Write  ssh -o StrictHostKeyChecking=no ${RU}
     sleep  5
     ${readRSA}    Read     delay=2s
     sleep  5
     Write   ps | grep -i uoam
     ${readoutputps}    Read     delay=2s
     ${internaluoam}=            Get Lines Containing String    ${readoutputps}    uoamapp
     log to console  ${internaluoam}
     ${pid}=      Fetch From Left                ${internaluoam}    root
     log to console  kill ${pid}
     Write               kill ${pid}
     Sleep                       3
     Close Connection

Check fault 4527 is raised
    log to console  ....check fault 4527 is raised
	Sleep  10
	Click Element  ${alarm}
    Wait Until Page Contains  4527  timeout=500
    Sleep  10

Collect logs in snapshot
     log to console  ....collect logs
     Wait until page contains   OnAir  timeout=900
     Click Element  ${diagnostic_menu}
     sleep   2
     Click Element   user-settings
     sleep   2
     Click Button   Collect Snapshot
     sleep   2
     Wait Until Page Contains   Session token renewal
     Input Text     renew-session-password   nemuuser
     Click Element   ${check_box}
     Click Button  OK

Calculate time
   ${StartTime}=  Get Current Date  result_format=%H:%M:%S
   ${StartTimeSec}=  Convert Time  ${StartTime}
   Wait Until Page Contains   Snapshot collection succeeded     timeout=900
   Sleep  20
   ${collectiontime}=   Get Text    ${finistime}
   ${collectiontime}=   Fetch From Right  ${collectiontime}   Elapsed time:
   ${collectiontime}=   Strip String   ${SPACE}${collectiontime}
   ${collectiontime}=   Fetch from Left  ${collectiontime}  .
   ${ProcessTimeSec}=  Convert Time  ${collectiontime}
   ${TotalTimeSec}=  Evaluate  int(${StartTimeSec})+int(${ProcessTimeSec})
   ${FinishTime}=  Convert Time  ${TotalTimeSec}  result_format=timer  exclude_millis=true
   ${ora}=  Remove String  ${FinishTime}  :
   ${ora}=  Get Substring  ${ora}  0  4
   [return]  ${ora}

Create log name
   [Arguments]    ${ora}
   ${softwareversionstring}=  Get Element Attribute  ${sw}  title
   ${softwareversion}=      Fetch From Right               ${softwareversionstring}    :
   ${softwareversion}=    Strip String   ${SPACE}${softwareversion}
   ${date}=   Get Current Date  result_format=%Y%m%d
   ${filename}=  Catenate  SEPARATOR=  Snapshot_MRBTS-2003_5gvDU-${vDUnr}_  ${softwareversion}
   ${filename}=  Catenate  SEPARATOR=_   ${filename}  ${date}
   ${filename}=  Catenate  SEPARATOR=-   ${filename}  ${ora}
   ${filename}=  Catenate  SEPARATOR=    ${filename}  .zip
   ${filepath}=  Catenate  SEPARATOR=//  ${path}   ${filename}
   [return]    ${filepath}

Check logs are collected
   log to console  ....check logs are collected
   ${ora}=  Calculate time
   ${filepath}=  Create log name    ${ora}
#   OperatingSystem.File Should Exist   ${filepath}
    OperatingSystem.File Should Exist   Snapshot*.zip
   sleep  5
   Remove File  ${filepath}

Check final webem status
    log to console  Wait until vDU is OnAir...
#    wait until page contains   OnAir   timeout=600s
    page should not contain  4527
    page should not contain  BASE STATION INFORMATION
    #page should contain  No Alarms to display

Check initial OAM container status
    Open Connection     ${VDUSSH}
    Login               core   ${SSHPASS}

    Log to console  Verify if all pods are running
    FOR  ${index1}   IN RANGE   999
         Write               oc get pods -n cran1
         Sleep              1
         ${GETPODSTATUS1}=         Read      delay=1s
         ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
         ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
         Sleep              1
         Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END

Reset vDU
    log to console  ....reset vdu
    sleep  2
    click element  ${dashboard}
    click element  ${reset_vDU}
    sleep  5
    click button  OK
    sleep  3
    close browser
    sleep  10
    Check initial OAM container status
    sleep  10
    Login vDU
    Check final webem status

Logout vDU
     Click Element   user-settings
     Page Should Contain       Sign out
     sleep   6
     Click Element  //*[contains(text(),'Sign out')]
     Sleep  4
     Close Browser
