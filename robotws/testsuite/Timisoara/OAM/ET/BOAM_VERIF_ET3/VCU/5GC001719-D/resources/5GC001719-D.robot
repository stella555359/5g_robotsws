*** Settings ***

Documentation
...    Author: Catlan Radu
...    Maintainer: Catlan Radu (radu-vasile.catlan@nokia.com)
...    Group in charge: MN RAN BOAM VERIF Team3
...    References: doors
...    Feature Description: 5GC001719-D

Library  SeleniumLibrary
Library   SSHLibrary
Library   String


*** Variables ***
${VCU1}     https://10.5.63.204
${VCU2}     https://10.5.63.205
${VCUSSH}  10.5.62.195
${USER}  core
${VCU_SSH_PASS}  Yt_xk39b@123
${vCU1_NAMESPACE}      cran31
${vCU2_NAMESPACE}      cran32
${CONFIGURATION_MANAGEMENT}    xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
    ...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[5]
${INPUT_FILTERS}    xpath=//*[@id="filter-input-field-plans-tree"]



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
    Log to console  Login vCU1
    Open Browser for ssh   ${VCU1}
    Sleep    4
    ${condition}=   run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...  click button  details-button  AND  click link  proceed-link

    Input Text    login-username    Nemuadmin
    Input Text    login-password    nemuuser
    Click Button   Login
    sleep   10

    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True   run keyword   Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains    DUs Status Summary  timeout=30s
    Wait Until Page Contains    Cells Status Summary  timeout=30s
    Wait Until Page Contains    X2 Links Summary  timeout=30s
    Maximize Browser Window
    sleep   4

Login vCU2
    Log to console  Login VCU2
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

    Wait Until Page Contains    DUs Status Summary  timeout=30s
    Wait Until Page Contains    Cells Status Summary  timeout=30s
    Wait Until Page Contains    X2 Links Summary  timeout=30s
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
    Log to console  Go to CU Status view
    Click Element   ${CUPROPERTIES}
    Click Element    id=/status/cu-properties
    Sleep  2

Check Initial Activity mode vCU1
    Log to console  Check Initial Activity mode vCU1
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
    Log to console  Check Initial Activity mode vCU2
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
    Log to console  Check VNF-VNF link
    Page should contain element   id=PEER_VNF_CONNECTOR
    ${link}=  Get Element Attribute     id=PEER_VNF_CONNECTOR   class
    Should not be equal   ${link}   tile-frame status-red

Check Primary&Active vCU status
    Log to console  Check Primary&Active vCU status
    Login vCU1
    Go to CU Status view
    Check Initial Activity mode vCU1
    Check VNF-VNF link
    Logout vCU


Check Secondary&Standby vCU status
    Log to console  Check Secondary&Standby vCU status
    Login vCU2
    Go to CU Status view
    Check Initial Activity mode vCU2
    Check VNF-VNF link
    Logout vCU

Config
    Log to console  Config
    Mouse Over    ${CONFIGURATION_MANAGEMENT}
    Click Element    //*[contains(text(),'Configuration Management')]
    Sleep    3s


Create Delta Plan on active vCU to change a parameter
    Log to console  Create Delta Plan on active vCU to change a parameter
    Config
    Click Element    //*[contains(text(),'Create Delta Plan')]
    sleep   5s
    Click Element    //*[contains(text(),'OK')]
    Wait Until Page Contains   Create plan operation finished  timeout=30s
    Wait Until Page Contains   DELTA-PLAN-1  timeout=10s
    Sleep    5s
    Input Text    ${INPUT_FILTERS}    NRCELL-31
    Wait Until Page Contains  NRCELL-31  timeout=10s
    Click Element  //*[contains(text(),'NRCELL-31')]
    Wait Until Page Contains   a1TimeToTriggerhoSsbRsrp   timeout=30s
    Click Element  ${a1TimeToTriggerhoSsbRsrp}
    Sleep  10s
    Click Element  //*[contains(text(),'ms320')]
    Sleep  10s

Validate & Activate Delta Plan on active vCU
    Log to console  Validate & Activate Delta Plan on active vCU
    Click Element  //*[contains(text(),'Validate Plan')]

    ${condition}=  run keyword and return status  Wait Until Page Contains
                                                  ...  Validate plan operation finished  timeout=10s
    run keyword if   ${condition}==False  Click Element    //*[contains(text(),'Validate Plan')]
    run keyword if   ${condition}==True    page should contain    Validate plan operation finished

     Click Element  //*[contains(text(),'Activate Plan')]
    Sleep    2s
     Click Element    //*[contains(text(),'Execute')]
    Sleep    2s

Check from WebEM if standby vCU reboots itself
    Log to console  Check from WebEM if standby vCU reboots itself
    Login vCU2
    Wait until Page Contains  Connection to the server was lost. Reconnecting automatically, but if it does not work,
                              ...  ${SPACE}refresh the page manually.  timeout=180s

Check Delta Plan from active vCU is present on standby vCU
    Log to console  Check Delta Plan from active vCU is present on standby vCU
    Config
    Input Text    ${INPUT_FILTERS}    NRCELL-31
    Wait Until Page Contains  NRCELL-31  timeout=10s
    Click Element  //*[contains(text(),'NRCELL-31')]
    Wait Until Page Contains   a1TimeToTriggerhoSsbRsrp   timeout=30s
    Sleep  10s
    Page Should Contain  ms320

Login SSH
    Open Connection  ${VCUSSH}
    Login  core  ${VCU_SSH_PASS}
    Sleep  5
    Write  oc login -u nokiaadmin -p nokiaadmin
    Sleep  5
    ${login_output}   Read   delay=2s
    log to console   ${login_output}

Verify All Pods Are Running
    Log to console  Verify All Pods Are Running
    Login SSH
    Log To Console  ....Verify if all pods are running...
    FOR   ${index1}   IN RANGE  30
        Write  oc get pod -n ${vCU2_NAMESPACE}
        Sleep  2
        ${GETPODSTATUS1}=  Read  delay=1s
        ${RunningStatus}=  Get Count  ${GETPODSTATUS1}  Running
        ${PodNumber}=      Get Count  ${GETPODSTATUS1}  po-
        Sleep  1
        Exit FOR loop if  ${RunningStatus}==${PodNumber} and ${RunningStatus}!=1 and ${RunningStatus}!=2
    END
