*** Settings ***

Documentation
...    Author: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library  SeleniumLibrary
Library   SSHLibrary
Library   String


*** Variables ***
${VCU1}     https://10.5.63.204
${VCU2}     https://10.5.63.205
${OCP3IP}    10.5.62.195
${OCP3USER}  core
${OCP3PASS}  Yt_xk39b@123
${vCU1_NAMESPACE}      cran31
${vCU2_NAMESPACE}      cran32

*** Keywords ***
Open Browser for ssh
    [Arguments]   ${VCU}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VCU}
    Sleep    10 secs

Login vCU1
    Open Browser for ssh   ${VCU1}
    Sleep    4
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...  click button  details-button  AND  click link  proceed-link

    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep   10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True   run keyword   Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains    DUs Status Summary
    Wait Until Page Contains    Cells Status Summary
    Wait Until Page Contains    X2 Links Summary
    Maximize Browser Window
    sleep   4

Login vCU2
    Open Browser for ssh   ${VCU2}
    Sleep    4
    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...  click button  details-button  AND  click link  proceed-link

    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep   10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True   run keyword   Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains    DUs Status Summary
    Wait Until Page Contains    Cells Status Summary
    Wait Until Page Contains    X2 Links Summary
    Maximize Browser Window
    sleep   4

Logout vCU
    Click element  //*[@id="user-settings"]/button/span[2]
    Sleep  2
    Page Should Contain       Sign out
    sleep   6
    Click Element  //*[contains(text(),'Sign out')]
    Sleep     3
	Close Browser

Go to CU Status view
    Click Element   ${CUPROPERTIES}
    Click Element    id=/status/cu-properties
    Sleep  2

Check Initial Activity mode vCU1
    Wait Until Page Contains Element  ${MRBTSSTATUS}
    Sleep  2
    Element should contain   ${MRBTSSTATUS}        Active
    Element should contain   ${MRBTSSTATUS}        Redundancy role:
    Element should contain   ${MRBTSSTATUS}        Primary
    ${gnbpropr1}=  Get Element Attribute     ${MRBTSSTATUS}   class
    Should not be equal   ${gnbpropr1}   tile-frame status-red
    Should not be equal   ${gnbpropr1}   tile-frame status-grey
    Sleep   2

Check Initial Activity mode vCU2
    Wait Until Page Contains Element  ${MRBTSSTATUS}
    Sleep  2
    Element should contain   ${MRBTSSTATUS}        Standby
    Element should contain   ${MRBTSSTATUS}        Redundancy role:
    Element should contain   ${MRBTSSTATUS}        Secondary
    ${gnbpropr1}=  Get Element Attribute     ${MRBTSSTATUS}   class
    Should not be equal   ${gnbpropr1}   tile-frame status-red
    Should not be equal   ${gnbpropr1}   tile-frame status-green
    Sleep   2

Check VNF-VNF link
    Page should contain element   id=PEER_VNF_CONNECTOR
    ${link}=  Get Element Attribute     id=PEER_VNF_CONNECTOR   class
    Should not be equal   ${link}   tile-frame status-red

Unforced Switchover on Standby vCU
    Click Element       //*[contains(text(),'Switchover')]
    Sleep   2
    Click Element       //*[contains(text(),'Unforced switchover')]
    Sleep  2
    Click Element       //*[contains(text(),'OK')]
    Wait until page contains   gNB CU VNF switchover started   timeout=20
    Wait until page contains   gNB CU VNF switchover finished   timeout=20
    Logout vCU

Check Primary&Active vCU status
    Login vCU1
    Go to CU Status view
    Check Initial Activity mode vCU1
    Check VNF-VNF link
    Logout vCU

Check Secondary&Standby vCU status
    Login vCU2
    Go to CU Status view
    Check Initial Activity mode vCU2
    Check VNF-VNF link

Check if vCU1 is restarted
    Open Connection  ${OCP3IP}
    Login            ${OCP3USER}  ${OCP3PASS}

#check if vCU is restarting:
      FOR  ${index1}   IN RANGE   120
         Write               oc get pod -n ${vCU1_NAMESPACE}
         ${GETPODSTATUS1}=         Read      delay=1s
         ${FOR}=  Run Keyword And Return Status    Should contain      ${GETPODSTATUS1}         Terminating
         Sleep  5
         Exit FOR loop if  ${FOR}==True
      END
    ${NOTRESTARTING}=  Run Keyword And Return Status  Should not be equal as strings   ${index1}  119
    Run keyword if   ${NOTRESTARTING}==False  log to console  vCU1 is not restarting
        ...                             ELSE  log to console  vCU1_Primary is restarting
    Should not be equal as strings   ${index1}  119

#check if vCU is Running after restart:
      FOR  ${index2}   IN RANGE   999
         Write               oc get pod -n ${vCU1_NAMESPACE}
         Sleep              1
         ${GETPODSTATUS1}=         Read      delay=1s
         ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
         ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
         Sleep              1
         Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=2 and ${RunningStatus}!=3
     END

    ${NOTRUNNING}=  Run Keyword And Return Status  Should not be equal as strings   ${index2}  998
    Run keyword if   ${NOTRESTARTING}==False  log to console  vCU1 is not Running  ELSE  log to console  vCU1 is Running
     Should not be equal as strings   ${index2}  998

Check if vCU2 is restarted
    Open Connection  ${OCP3IP}
    Login            ${OCP3USER}  ${OCP3PASS}

#check if vCU is restarting:
      FOR  ${index1}   IN RANGE   120
         Write               oc get pod -n ${vCU2_NAMESPACE}
         ${GETPODSTATUS1}=         Read      delay=1s
         ${FOR}=  Run Keyword And Return Status    Should contain      ${GETPODSTATUS1}         Terminating
         Sleep  5
         Exit FOR loop if  ${FOR}==True
      END
    ${NOTRESTARTING}=  Run Keyword And Return Status  Should not be equal as strings   ${index1}  119
    Run keyword if   ${NOTRESTARTING}==False  log to console  vCU2 is not restarting
        ...                             ELSE  log to console  vCU2_Secondary is restarting
    Should not be equal as strings   ${index1}  119

#check if vCU is Running after restart:
      FOR  ${index2}   IN RANGE   999
         Write               oc get pod -n ${vCU2_NAMESPACE}
         Sleep              1
         ${GETPODSTATUS1}=         Read      delay=1s
         ${RunningStatus}=  Get Count     ${GETPODSTATUS1}    Running
         ${PodNumber}=      Get Count     ${GETPODSTATUS1}    po-
         Sleep              1
         Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=2 and ${RunningStatus}!=3
     END

    ${NOTRUNNING}=  Run Keyword And Return Status  Should not be equal as strings   ${index2}  998
    Run keyword if   ${NOTRESTARTING}==False  log to console  vCU2 is not Running  ELSE  log to console  vCU2 is Running
    Should not be equal as strings   ${index2}  998

Check Final Activity mode vCU1       #Should be Standby and Primary
    Wait Until Keyword Succeeds  3 min  15 sec  Login vCU1
    Go to CU Status view
    Wait Until Page Contains Element  ${MRBTSSTATUS}
    Sleep  2
    Element should contain   ${MRBTSSTATUS}        Standby
    Element should contain   ${MRBTSSTATUS}        Redundancy role:
    Element should contain   ${MRBTSSTATUS}        Primary
    ${gnbpropr1}=  Get Element Attribute     ${MRBTSSTATUS}   class
    Should not be equal   ${gnbpropr1}   tile-frame status-red
    Should not be equal   ${gnbpropr1}   tile-frame status-green
    Sleep   2

Check Final Activity mode vCU2       #Should be Active and Secondary
    Login vCU2
    Go to CU Status view
    Wait Until Page Contains Element  ${MRBTSSTATUS}
    Sleep  2
    Element should contain   ${MRBTSSTATUS}        Active
    Element should contain   ${MRBTSSTATUS}        Redundancy role:
    Element should contain   ${MRBTSSTATUS}        Secondary
    ${gnbpropr1}=  Get Element Attribute     ${MRBTSSTATUS}   class
    Should not be equal   ${gnbpropr1}   tile-frame status-red
    Should not be equal   ${gnbpropr1}   tile-frame status-grey
    Sleep   2

Check if Primary became Standby
    Check Final Activity mode vCU1
    Logout vcu

Check if Secondary became Active
    Check if vCU1 is restarted
    Sleep   20
    Check Final Activity mode vCU2
    Logout vCU

Forced Switchover on Standby vCU   #this time CNF-1 will be Standby after first TC execution
    Check Final Activity mode vCU1   #this time will be intial status for this TC
    Click Element       //*[contains(text(),'Switchover')]
    Sleep   2
    Click Element       //*[contains(text(),'Forced switchover')]
    Sleep  2
    Click Element       //*[contains(text(),'OK')]
    Wait until page contains   gNB CU VNF switchover started   timeout=20
    Wait until page contains   gNB CU VNF switchover finished   timeout=20
    Sleep  1
    Logout vCU


Check if Primary became Active
    Check if vCU2 is restarted
    Sleep   20
    Check Primary&Active vCU status

Check if Secondary became Standby
    Check Secondary&Standby vCU status
    Logout vCU

Deactivate CNF
    Login vCU1
    Go to CU Status view
    Sleep   10
    Click Element       //*[contains(text(),'Deactivate')]
    Wait Until Page Contains  Do you want to proceed?
    Sleep   2
    #Click Element       //*[contains(text(),'OK')]   #nu merge cu OK
    Click Element       ${OK_button}
    Wait until page contains   gNB CU VNF activity mode change started   timeout=20
    Wait until page contains   gNB CU VNF activity mode change finished   timeout=20
    Sleep  2
    Close Browser

Check if Primary became Standby after Deactivate
    Check if vCU1 is restarted
    Sleep  20
    Check Final Activity mode vCU1
    Logout vCU
