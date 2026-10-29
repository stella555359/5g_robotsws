*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)

Library  SeleniumLibrary
Library  SSHLibrary
Library  String
Library  OperatingSystem
Library  DateTime
Library  Collections

Resource    xpathSelenium.robot

*** Variables ***
# VDU4
#${VDU}          https://10.5.62.58
#${VDUSSH}       10.5.26.194
#${VDUFHGW}      10.15.217.209
#${VDUNCIR}      10.5.26.194
# VDU5
#${VDU}          https://10.5.62.82
#${VDUSSH}       10.5.26.202
#${VDUFHGW}      10.15.217.211
#${VDUNCIR}      10.5.26.202

#VDU15
${VDU}          https://10.15.254.234
${VDUSSH}       10.15.254.37
${VDUFHGW}      10.15.217.211
${VDUNCIR}      10.15.254.37

# VDU6
#${VDU}          https://10.5.62.66
#${VDUSSH}       10.5.26.234
#${VDUFHGW}      10.15.217.213
#${VDUNCIR}      10.5.26.234
#${NCIRPASS}     root
##VDU5
${NCIRPASS}     systeM!23
${OCPUSERVDU15}     core
${OCPPASSVDU15}     Yt_xk39b@123
##vdu6
#${FHGWPASS}     root

${RU}           root@169.254.1.2
${RU-PROXY}     ruproxy-1-0
${EITUSER1PASS}     systeM!23
${alarms_count}     0
${FIRST_RU_MODULE}  RMOD-1/AHCA

*** Keywords ***
Lock first RU module
    Log  Lock the first RU module
    Wait Until Keyword Succeeds  40  10  Extract first RU module name
    Look RU   ${FIRST_RU_MODULE}

Look RU
    [Arguments]    ${RU_module}
    Click Element   ${Dashboard}
    sleep  2s
    Click Element  ${Lock_radio}
    Wait Until Page Contains  ${RU_module}
    Click Element   //*[contains(text(),'${RU_module}')]
    sleep  5s
    Click Element   //*[contains(text(),'OK')]
    sleep  20s

Extract first RU module name
    ${RU_MODULE}  Extract RU Type
    Set Global Variable  ${FIRST_RU_MODULE}  ${RU_MODULE}
    Log to console  ${RU_MODULE}

Check first RU Administrative status
    [Documentation]  Read Administrative status of first RU
    [Arguments]  ${status}
    Log to console  Check RU administrative status to be ${status}
    Click Element   ${Dashboard}
    Wait Until Keyword Succeeds  90  30
    ...  Verify Webem element states  ${statusItem}  ${status}  ${selectCellinStatusMenu}  ${administrativeStateitemCell}
    Click Element   ${Dashboard}

Check first cell Availability status
    [Documentation]  Read Availability status of first cell
    [Arguments]  ${status}
    Log to console  Check RU Availability status to be ${status}
    Click Element   ${Dashboard}
    Wait Until Keyword Succeeds  240  30
    ...  Verify Webem element states  ${CellsStatusMenuXpath}  ${status}  ${FirstCellSelectXpath}  ${AvailabilityCellStatusXpath}
    Click Element   ${Dashboard}


Extract RU Type
    Click Element   ${Dashboard}
    Sleep   2
    Click Element  ${Status_buton}
    Sleep   2
    Click Element  ${statusItem}
    Sleep   2
    Wait Until Page Contains Element  ${selectCellinStatusMenu}  timeout=5min
    Sleep   2
    Click Element  ${selectCellinStatusMenu}
    Sleep   2
#    Click Element  ${detailsMenuitem}
    Click Button  open-detail-panel-button
    #    Click Element   //*[contains(text(),'RMOD-1/AHBCC')]
    ${typeRU}  Get Element Attribute  ${TypeRUpath}  title
    ${RmodID}  Get Element Attribute  ${RMOD_IDpath}  title
    Log   ${RmodID}/${typeRU}
#    Click Element  ${detailsMenuitemClose}
    Click Button  open-detail-panel-button
    Click Element   ${Dashboard}
    [Return]  ${RmodID}/${typeRU}

Extract number of RUs
    Click Element   ${Dashboard}
    Sleep   4
    ${NumberRUs}  Get Text  ${Number_RU_xpath}
    [Return]    ${NumberRUs}

Login vDU
#    Open Browser   ${VDU}   ${BROWSER}
    vduSelenium.Open Browser for ssh
    Sleep   4
    Maximize Browser Window
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Input Text      login-username    Nemuadmin
    Input Text      login-password    nemuuser
    Click Button    Login
    Wait Until Page Contains  Legal Notice
    Sleep  2
    Click Element  //*[contains(text(),'Confirm')]
    Sleep  4
    Wait Until Page Contains    Radio Modules Status Summary
    Wait Until Page Contains    Cells Status Summary
    ${SWver}  Get Text  ${SW_version_xpath}
    Log to console  ${SWver}

Open Browser for ssh
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VDU}
    Sleep    10 secs

Logout vDU
     Click Element   user-settings
     Page Should Contain       Sign out
     sleep   6
     Click Element  //*[contains(text(),'Sign out')]
     Sleep  4
     Close Browser

Restart Browser
    Close Browser
    Login vDU


Connection OAM_pod
    log to console  ....Connecting to vDU ssh...
    open connection  ${VDUNCIR}
    login  ${OCPUSERVDU15}   ${OCPPASSVDU15}
#    login  root   ${NCIRPASS}
    sleep  10
    log to console  ....connect to oam pod
#    Wait Until Keyword Succeeds  120 sec  5 sec
    Open Oam Bash Console

Open Oam Bash Console
#    write   kubectl -it exec po-eit1-oam-0 -c ctr-eit1-oam bash
#    write   kubectl exec -it po-cran1-cprt-0 -c ctr-cran1-cprt -n cran1 -- /bin/bash
    write  kubectl -n cran1 -it exec po-cran1-oamfm-0 -c ctr-cran1-oamfm -- bash
    ${readOutput}    Read     delay=20s
    Log to console    ${readOutput}
    Should contain  ${readOutput}  bash-

Exit Oam Bash Console
    write  exit
    ${readOutput}    Read     delay=3s
    Log to console    ${readOutput}
    Should contain  ${readOutput}  exit

Generate Fault 4298           # generate fault 4298
    Connection OAM_pod
    ${cmd1}=  set variable    curl --request POST "http://oam-faultmanagement:9004/api/fm/v1/faults" ${space}${space}
    ${cmd2}=  set variable    --header 'Content-type: application/json' ${space}${space}--data "{\\"faultId\\":4298,
    ${cmd3}=  set variable   \\"state\\":1,\\"severity\\":1,\\"source\\":\\"MRBTS-0\\",\\"sourceType\\":1,
    ${cmd}=   set variable  ${cmd1}${cmd2}${cmd3}\\"extraInfo\\":\\"57360\\"}"
    Log to console     ${cmd}
    Write  ${cmd}
    ${readOutput}    Read     delay=15s
    Log to console     output...._${readOutput}
    Exit Oam Bash Console
    close connection

Generate Fault 4298 NO recovery         # generate fault 4298 but no recovery option enabled
    Connection OAM_pod
    write     ${OAM_pod1}
    sleep  2s
    ${readOutput}    Read     delay=5s
    Log     ${readOutput}
    close connection

Check fault
    [Arguments]  ${fault}  ${wait}=20
    log to console  ....check fault ${fault} is raised
#	Sleep  10
	Click Element    ${alarm}
    Wait Until Page Contains     ${fault}  timeout=${wait}
    Sleep  3

Check final webem status
    log to console  Wait until vDU is OnAir...
    wait until page contains    OnAir   timeout=600s
    page should not contain     4527
#    page should not contain     BASE STATION INFORMATION
    #page should contain  No Alarms to display



UnLook RU
    [Arguments]    ${RU_module}
    log to console  Unlock Radio ${RU_module}
    Click Element   ${Dashboard}
    sleep  5s
    Click Element  ${RU_Unlock}
    sleep  2s
    Click Element   //*[contains(text(),'${RU_module}')]
    sleep  2s
    Click Element   //*[contains(text(),'OK')]

Check alarm erased
    [Arguments]    ${AlarmNumber}
    Click Element    ${alarm}
    Wait Until Page Does Not Contain  ${AlarmNumber}  timeout=600

Check NO alarm
    [Arguments]    ${AlarmNumber}
    Click Element    ${alarm}
    page should not contain  ${AlarmNumber}

Generate alarm 7102
    [Arguments]    ${RU_module}
    Click Element   ${Dashboard}
    log to console  ....Generate alarm 7102
    Sleep  10
    Look RU     ${RU_module}

Check fault 7102 is raised
    log to console  ....check fault 7102 is raised
	Sleep  10
	Click Element   ${alarm}
    Wait Until Page Contains  7102  timeout=25
    Sleep  3

Check fault 52 is raised
    log to console  ....check fault is raised
	Sleep  10
	Click Element  ${alarm}
    Wait Until Page Contains  52  timeout=25
    Sleep  3

Filter Alarm By Faulty Degraded Affected
    log to console  ....filter fault 7102:
    log to console  ....Impacted cells as "Faulty cells":
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep  5
    Click Element   //*[contains(text(),'Faulty cells')]
    Sleep  1
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep  5

    log to console  ....Impacted cells as "Degraded cells":
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep   5
    Click Element   //*[contains(text(),'Degraded cells')]
    Sleep  1
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep   5

    log to console  ....Impacted cells as "Affected cells":
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep  5
    Click Element   //*[contains(text(),'Affected cells')]
    Sleep  1
    Click Element   //*[contains(text(),'Impacted Cells')]
    Sleep  5

Extract Fault
    [Arguments]    ${fault}
    ${result}   Set Variable    ${true}
    Click Element   ${alarm_button}
    Sleep  2s
    ${alarms}=  Get WebElements  ${alarms_table}
    ${LenghtAlarms}=    Get Length  ${alarms}
    IF   ${LenghtAlarms}==0
        ${result}=      ${false}
    ELSE
        FOR  ${element}  IN  @{alarms}
            Log    ${element.text}
            ${result}=  Run Keyword And Return Status    Should Contain  ${element.text}  ${fault}
        END
    END
    [return]    ${result}

Extract Alarm 7102 fault 1931 Date
    Click Element   ${alarm_button}
    ${now}  Get Current Date  result_format=%Y-%m-%d
    Sleep  10s
    #Click Element   ${alarms_table}
    ${alarms}=  Get WebElements  ${alarms_table}

    #${table_columns}=  split string  ${alarms.text}
    #log  columns: ${table_columns}
    FOR  ${element}  IN  @{alarms}
        Log    ${element.text}
        ${result}=  Run Keyword And Return Status    Should Contain  ${element.text}  1931
        Continue For Loop If  $result == False
        Run Keyword If  ${result}==True   Get date from table  ${element.text}      ELSE    Fail   Cannot extract alarm timestamp
    END

Get date from table
   [Arguments]    ${Tabel_lines}
   ${date_time}=  Split String  ${Tabel_lines}
   ${alarm_DateAndTime}=    Get Slice From List  ${date_time}   0   2      #ia primele 2 elemente din lista
   ${date}=  Get From List  ${alarm_DateAndTime}  0
   ${time}=  Get From List  ${alarm_DateAndTime}  1
   ${finalStrDate}=   Catenate  ${date}  ${time}
#   ${date}=  Get Slice From List  ${date_time}   0  1  #ia primele 2 elemente din lista
#   ${time}=  Get Slice From List  ${date_time}   1  2  # ora din tabel de tip string
#   ${curent date}=  Get Current Date  result_format=%H:%M:%S  exclude_millis=true
#   ${CurentTimeSec}=  Convert Time  ${curent date}
#   ${time}=  Get From List  ${time}  0
#   ${Alarm_timeSec}=  Convert Time   ${time}
    [return]  ${finalStrDate}


Get BTS current time
    ${curent_DateAndTime}=  Get Current Date    exclude_millis=true
    [return]  ${curent_DateAndTime}

Check alarm timestamp
    [Arguments]    ${initialTime}
    ${curent date2}=  Get Current Date      exclude_millis=yes
    IF  '${initialTime}' < '${curent date2}'
        Log To Console      Alarm generated while RU was locked
    ELSE
        Fail    NO Alarm generated while RU was locked
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
#    Check initial OAM container status
#    sleep  10
    Login vDU
    Check final webem status

Verify Webem element states
    [Arguments]  ${statusItem}  ${admin_state}  ${selectInStatusMenu}  ${administrativeStateitem}
    Sleep  5
    Click Element  ${Status_buton}
    Click Element  ${statusItem}
    Sleep  5
#    Wait Until Keyword Succeeds  20  5  Click on item box in items status menu  ${selectInStatusMenu}
    Click Element  ${selectInStatusMenu}
    Sleep  5
#    Click Element  ${detailsMenuitem}
    Click Button  open-detail-panel-button
    Sleep  5
    ${admin_current_state}  Get Element Attribute  ${administrativeStateitem}  title
#    Click Element  ${detailsMenuitemClose}
    Click Button  open-detail-panel-button
    Sleep  1
    Should be Equal As Strings  ${admin_current_state}  ${admin_state}
#    Sleep  5


Click on item box in items status menu
    [Arguments]  ${selectInStatusMenu}
    Click Element  ${Status_buton}
    Click Element  ${statusItem}
#    Wait Until Page Contains Element  ${selectInStatusMenu}  timeout=5
    Wait Until Page Contains  NRCELL-1  [timeout]  5 sec


Check if OAMEXT container was restarted
    Open Connection     ${VDUSSH}
    Login               ${OCPUSERVDU15}   ${OCPPASSVDU15}
    FOR  ${index}   IN RANGE   100
         Write               kubectl get pod
         ${GETPODSTATUS1}=         Read      delay=1s
         Sleep    3s
         ${FOR}=  Run Keyword And Return Status    Should contain      ${GETPODSTATUS1}         Terminating
         Exit FOR loop if  ${FOR}==True
    END
    FOR  ${index1}   IN RANGE   999
         Write               kubectl get pod
         Sleep              1
         ${GETPODSTATUS1}=         Read      delay=1s
         ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
         ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
         Sleep              1
         Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END
#    Write               kubectl get pod
#    ${GETPOD1}=         Read      delay=1s
#    ${OAMPOD2}=         Get Lines Containing String    ${GETPOD1}    oam
#    ${OAMPODNAME}=      Fetch FROM Left                ${OAMPOD2}    ${SPACE}
#    Log                 ${OAMPODNAME}
#    ${NAMESPACE1}=      Fetch FROM Left                ${OAMPODNAME}    -oam
#    ${NAMESPACE}=       Fetch FROM Right               ${NAMESPACE1}    -
#    Write               kubectl describe pod ${OAMPODNAME}
#    ${CTR1}=            Read      delay=1s
#    ${CTR2}=            Fetch From Right              ${CTR1}       ctr-${NAMESPACE}-oam:
#    ${CTR3}=            Fetch From Left               ${CTR2}       Liveness
#    Should contain      ${CTR3}               Running
#
#    ${STARTEDTIMECTRfinal}=  Get Lines Containing String   ${CTR3}       Started:
#    Should not be equal      ${STARTEDTIMECTRinit}    ${STARTEDTIMECTRfinal}
    Close Connection
