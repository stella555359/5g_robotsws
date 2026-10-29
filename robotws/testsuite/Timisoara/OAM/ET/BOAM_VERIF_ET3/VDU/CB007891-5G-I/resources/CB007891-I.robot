*** Settings ***
Documentation
...    Author: Fiterau Andreea (andreea.fiterau@nokia.com), Gordan Adelina (adelina.gordan@nokia.com
...    Maintainer: Fiterau Andreea (andreea.fiterau@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_TIM_3_ET_GMS
...    Feature Description: CB007891-B
...    Sample execution: robot -L TRACE -b debug.log -d /home/ute/Desktop/CRT/Results_VDU/CB007891-I 
...      /home/ute/Desktop/CRT/Test_Suite_EIT_VDU/CB007891-I/general.robot

*** Variables ***
${WORKER1_IP}     https://10.5.50.242
${WORKER2_IP}     https://10.5.50.243
${USERNAME}       core
${PASSWORD}       Yt_xk39b@123

${WEBEM_IP}      https://10.15.254.138
${USER}          Nemuadmin
${PASSWORD}      nemuuser

${VDUSHH}  10.15.254.10


*** Keywords ***

Check if OnAir
    Wait Until Page Contains     OnAir        timeout=20
    Sleep      10
    Close Browser

Open Browser for ssh
    [Arguments]   ${VDU}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${VDU}
    Sleep    10 secs

Login To Worker1-242
    Open Browser for ssh    ${WORKER1_IP}
    Maximize Browser Window

    ${condition}=  run keyword and return status  page should contain  Advanced
    run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Sleep   5

    Input Text    id=userid    admin
    Sleep   5
    Input Text    id=password    NokiaAirFrame_20

    Click Element    id=btn-login
    Sleep    25
    Wait Until Page Contains    Threshold Sensor Monitoring     timeout=60

Login To Worker2-243
    Open Browser for ssh    ${WORKER2_IP}
    Maximize Browser Window

    ${condition}=  run keyword and return status  page should contain  Advanced
    run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Sleep   5


    Input Text    id=userid    admin
    Sleep   5
    Input Text    id=password    NokiaAirFrame_20

    Click Element    id=btn-login
    Sleep   25
    Wait Until Page Contains    Threshold Sensor Monitoring     timeout=60

Turn Off Worker-1
    Open Browser for ssh       https://10.5.50.242/#power-control
    Sleep   60
    Click Element       ${BUTON1BMC1}
    Sleep   10
    Click Element       //*[@id="save"]
    Alert Should Be Present
    Sleep   2
    Close Browser

Turn Off Worker-2
    Open Browser for ssh       https://10.5.50.243/#power-control
    Sleep   60
    Click Element       ${BUTON1BMC2}
    Sleep       10
    Click Element       //*[@id="save"]
    Alert Should Be Present
    Sleep   2
    Close Browser

Turn On Worker-1
    Open Browser for ssh       https://10.5.50.242/#power-control
    Sleep   60
    Click Element       ${BUTON2BMC1}
    Sleep   10
    Click Element       //*[@id="save"]
    Sleep   10
    Alert Should Be Present
    Sleep   2
    Close Browser

Turn On Worker-2
    Open Browser for ssh       https://10.5.50.243/#power-control
    Sleep       60
    Click Element       ${BUTON2BMC2}
    Sleep       10
    Click Element       //*[@id="save"]
    Sleep   10
    Alert Should Be Present
    Sleep   2
    Close Browser

Login To WebEM
    Open Browser for ssh    ${WEBEM_IP}    
    Maximize Browser Window

    ${condition}=  run keyword and return status  page should contain  Advanced
    run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Input Text    ${INPUT_NAME_FIELD}  ${USER}
    Input Text    ${INPUT_PASSWORD_FIELD}  ${PASSWORD}
    Click Element  ${LOGIN_BUTTON}

    Sleep    5s
    Wait until page contains   Legal Notice  timeout=600

    ${condition}=  run keyword and return status  page should contain  Legal Notice
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains     Cells Status Summary   timeout=60


Check alarms
    Click Element     ${CHECK_ALARMS1}
    Sleep   2s
    Click Element     ${CHECK_ALARMS2}

    Sleep   2s
    Wait Until Page Contains     Active Alarms      timeout=800

    Wait Until Page Contains     7115       timeout=800
    Wait Until Page Contains     7116       timeout=800
    Wait Until Page Contains     7101       timeout=800
    Wait Until Page Contains     4350       timeout=800
    Close browser


Check if up pods are NOT available
    Click Element       ${UPPODS1}

    Sleep   2s
    Wait Until Page Contains     Infrastructure Status      timeout=120

    Click Element       ${UPPODS2}

    ${up0}=    Get Text    ${UPPODS3}
    #log to console    ${up0}
    Should Be True      "Disabled" in """${up0}"""


    ${up1}=    Get Text    ${UPPODS4}
    #log to console    ${up1}
    Should Be True      "Disabled" in """${up1}"""

Log in SSH
    Open Connection  ${VDUSHH}
    Login  core  system123
    Sleep  5

Verify all NODES are ready
    Log To Console  ....Verify if all nodes are running...
    Write  oc get nodes -n cran1
    Sleep  2
    ${GETNODESTATUS1}=  Read  delay=1s
    ${RunningStatus}=  Get Count  ${GETNODESTATUS1}  Ready
    ${NodeNumber}=      Get Count  ${GETNODESTATUS1}  tm-oe19
    Sleep  1

    Log To Console      ${RunningStatus}
    Log To Console      ${NodeNumber}
    should be true      ${RunningStatus}==5
    Should be true      ${RunningStatus}!=0
    Write   ^C

Verify NODES are NOT ready
    Log To Console  ....Verify if all nodes are running...
    Write  oc get nodes -n cran1
    Sleep  2
    ${GETNODESTATUS1}=  Read  delay=1s
    ${RunningStatus}=  Get Count  ${GETNODESTATUS1}  NotReady
    ${NodeNumber}=      Get Count  ${GETNODESTATUS1}  tm-oe19
    Sleep  1

    Log To Console      ${RunningStatus}
    Log To Console      ${NodeNumber}
    should be true      ${RunningStatus}==2
    Should be true      ${RunningStatus}!=0
    Write   ^C

Verify all PODS are running
    Log To Console  ....Verify if all pods are running...
    Write  oc get pod -n cran1
    Sleep  2
    ${GETNODESTATUS1}=  Read  delay=1s
    ${RunningStatus}=  Get Count  ${GETNODESTATUS1}  Running
    ${NodeNumber}=      Get Count  ${GETNODESTATUS1}  po-
    Sleep  1

    Log To Console      ${RunningStatus}
    Log To Console      ${NodeNumber}
    should be true      ${RunningStatus}==${NodeNumber}
    Should be true      ${RunningStatus}!=0
    Write   ^C

Verify PODS are TERMINATING
    Log To Console  ....Verify pods are TERMINATING...
    Write  oc get pod -n cran1
    Sleep  2
    ${GETNODESTATUS1}=  Read  delay=1s
    ${RunningStatus}=  Get Count  ${GETNODESTATUS1}  Terminating
    ${NodeNumber}=      Get Count  ${GETNODESTATUS1}  po-
    Sleep  1

    Log To Console      ${RunningStatus}
    Log To Console      ${NodeNumber}
    Should be true      2 < ${RunningStatus}
    #Should be true      ${RunningStatus}!=0
    Write   ^C

Check alarm 7115
    Open Browser for ssh      https://10.15.254.138/alarm/historical
    Alert Should Be Present
    Sleep   2s
    Wait Until Page Contains     Active Alarms      timeout=120

    Wait Until Page Contains     7115       timeout=10
    Wait Until Page Contains     BASE STATION INFORMATION
    Wait Until Page Contains     4350
    Wait Until Page Contains        VNFC unavailable

Check alarm 7116
    Open Browser for ssh      https://10.15.254.138/alarm/historical
    Alert Should Be Present
    Sleep   2s
    Wait Until Page Contains     Active Alarms    timeout=120

    Wait Until Page Contains     7116       timeout=10
    Wait Until Page Contains     BASE STATION SERVICE PROBLEM
    Wait Until Page Contains     4350
    Wait Until Page Contains        VNFC unavailable
