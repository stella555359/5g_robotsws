*** Settings ***
Documentation
...    Author: Cristina Nicolae, Andreea Fiterau, Andora Carja, Cristian Dragoescu
...    Maintainer: Cristina Nicolae (cristina.nicolae@nokia.com), Andreea Fiterau (andreea.fiterau@nokia.com),
...                Andora Carja (andora.carja@nokia.com), Cristian Dragoescu (cristian.dragoescu@nokia.com)
...    Group in charge: VERIF_TIM_3_ET_GMS
...    References: DOORS
...    Feature Description: CB007120-A
...    Sample execution: robot -v cranName:cran2 -L TRACE -b debug.log -d results/7120-A general.robot

Library   SeleniumLibrary

*** Variables ***
${VDUSSH}    https://10.15.254
${VDU}       https://10.15.255.162

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
    Sleep  5
    Maximize Browser Window

    ${condition}=  run keyword and return status  page should contain  Advanced
        run keyword if   ${condition}==True  run keywords
        ...     click button  details-button  AND  click link  proceed-link

    Input Text   login-username  Nemuadmin
    Input Text   login-password  nemuuser
    Click Element  login-button

    Sleep    5
    Wait until page contains   Legal Notice  timeout=10s

     ${condition}=  run keyword and return status  page should contain  Legal Notice
        run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]

    Wait Until Page Contains   Radio Modules Status Summary  timeout=10s
    Wait Until Page Contains   Cells Status Summary  timeout=10s
    Wait Until Page Contains   Network Slicing Summary  timeout=10s

OnAir
    ${condition}=  run keyword and return status  wait until page contains  OnAir          #OnAir
        run keyword if   ${condition}==False  Close Browser

Config
    Mouse Over    ${CONFIGURATION_MANAGEMENT}
    Click Element    //*[contains(text(),'Configuration Management')]
    Sleep    3


Delete DeltaPlan
    Wait until element is visible  configuration-plans-dropdown  timeout=30s
    Click Element  configuration-plans-dropdown
    Sleep  10
    ${condition}=  run keyword and return status  Page should contain  DELTA-PLAN-1
    run keyword if  ${condition}==True  run keywords
        ...     Click Element  //*[contains(text(),'DELTA-PLAN-1')]  AND
        ...     Sleep  2  AND
        ...     Click Element  //*[contains(text(),'Delete Plan')]  AND
        ...     Sleep  2  AND
        ...     Click Element  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]  AND
        ...     Wait until page contains  Delete plan operation finished  timeout=60

CreatePlan
    Delete DeltaPlan
    Click Element    //*[contains(text(),'Create Delta Plan')]
    Click Element    //*[contains(text(),'OK')]
    Wait Until Page Contains   Create plan operation finished  timeout=30s
    Wait Until Page Contains   DELTA-PLAN-1  timeout=10s
    Sleep    2
#    Click Element   ${CREATE_PLAN1234}

DeleteSWRESETREQ-
    Click element  ${INPUT_FILTERS}
    Input text     ${INPUT_FILTERS}   SWRESETREQ-1
    Sleep  5
    ${SWRESETREQ}=  Run keyword and return status  Page should contain  SWRESETREQ-1
    Sleep  10
    Run keyword if  ${SWRESETREQ} == True
        ...  Run keywords  Wait until element is visible  //*[contains(text(),'SWRESETREQ-1')]  timeout=30s  AND
        ...  Click Element  //*[contains(text(),'SWRESETREQ-1')]
        ...  ELSE
        ...  Run keywords   Input text     ${INPUT_FILTERS}   SWRESETREQ-2  AND
        ...  Wait until element is visible  //*[contains(text(),'SWRESETREQ-2')]  timeout=30s  AND
        ...  Click Element    //*[contains(text(),'SWRESETREQ-2')]
    Wait until element is visible  ${REMOVE_OBJECT}  timeout=50s
    Click Element    ${REMOVE_OBJECT}
    Wait until element is visible  ${OK_REMOVE_OBJ}  timeout=50s
    Click Element    ${OK_REMOVE_OBJ}
    Wait Until Page Contains   Remove object operation finished  timeout=50s

CreateNewSWRESETREQ
    Click Element    //*[contains(text(),'CMD-1')]
    Click Element    ${PLUS}
    Click Element    //*[contains(text(),'Select class name')]
    Input Text    ${INPUT_SYSREQ}    SWRESETREQ
    Click Element    ${SWRESETREQ}
    Click Element   ${OK_PLUS}
    Wait Until Page Contains   SWRESETREQ-  timeout=10s

SelectValue
    Click Element    xpath=//*[@id="clear-input"]
    Sleep    2
    ${SWRESETREQ}=  Run keyword and return status  Page should contain  SWRESETREQ-1
    Run keyword if  ${SWRESETREQ} == True
        ...  Run keywords  Wait until element is visible  //*[contains(text(),'SWRESETREQ-1')]  timeout=30s  AND
        ...  Click Element  //*[@class='mdi mdi-pencil icon-mo-lite-edited ng-star-inserted']
        ...  ELSE
        ...  Run keywords   Input text     ${INPUT_FILTERS}   SWRESETREQ-2  AND
        ...  Wait until element is visible  //*[contains(text(),'SWRESETREQ-1')]  timeout=30s  AND
        ...  Click Element     //*[@class='mdi mdi-pencil icon-mo-lite-edited ng-star-inserted']

    Sleep    2
    wait until element is visible    //*[contains(text(),'<Select Value>')]    timeout=10s
    Click Element     //*[contains(text(),'<Select Value>')]
    Sleep    3
    Press Keys    NONE    r
    Sleep    3
    ${SWRESETREQ}=  Run keyword and return status  Page should contain  SWRESETREQ-1
    Run keyword if  ${SWRESETREQ} == True   Click Element    //*[contains(text(),'SWRESETREQ-1')]
        ...  ELSE  Click Element    //*[contains(text(),'SWRESETREQ-2')]

Validate
    Click Element    //*[contains(text(),'Validate Plan')]

    ${condition}=  run keyword and return status  Wait Until Page Contains   Validate plan operation finished
         ...    timeout=10s
        run keyword if   ${condition}==False  Click Element    //*[contains(text(),'Validate Plan')]
        run keyword if   ${condition}==True    page should contain    Validate plan operation finished
    Sleep    1

DeletePlan
    Sleep    3
    Click Element    //*[contains(text(),'Delete Plan')]
    Sleep    5
    Click Element    ${OKDELETE}
    Sleep    5

Activate
    Click Element    //*[contains(text(),'Activate Plan')]
    Sleep    2s
    Click Element    ${CHECKBOX1}
    Sleep    2s
    Click Element    ${CHECKBOX2}
    Sleep    2s
    Click Element    //*[contains(text(),'Execute')]
    Sleep    3s
    wait until element is visible    //*[contains(text(),'Activate plan operation finished')]    timeout=1800s
    Click Element    //*[contains(text(),'Done')]
    Sleep    3

TDS
    Logout
    Login vDU
    Sleep   10
    wait until element is visible    //*[contains(text(),'TDS')]    timeout=1800s

Status
    Sleep   20
    Click element    ${STATUS}
    wait until element is visible    //*[contains(text(),'vDU-gNB Properties')]    timeout=20s
    Click Element    //*[contains(text(),'Radio Modules Status')]
    Sleep   5
    Mouse over  ${RADIOMODULES}
    wait until element is visible    //*[contains(text(),'RMOD-')]    timeout=10s
    Sleep    2
     ${RM1}=    Run keyword and return status    page should contain    Enabled
    Sleep    2
     ${RM2}=    Run keyword and return status    page should contain    On line
    Sleep    2
     ${RM3}=    Run keyword and return status    page should contain    Unlocked
    Sleep    2
    Click Element    //*[contains(text(),'Cells Status')]
    Sleep   5
    Mouse over    ${CELLS}
    Sleep    2
    wait until element is visible    //*[contains(text(),'NRCELL-')]    timeout=10s
    Sleep    2
     ${RM4}=    Run keyword and return status    page should contain    Disabled
    Sleep    2
     ${RM5}=    Run keyword and return status    page should contain    Off line
    Sleep    2
     ${RM6}=    Run keyword and return status    page should contain    Unlocked
    Sleep    2
    run keyword if  ${RM1} and ${RM2} and ${RM3} and ${RM4} and ${RM5} and ${RM6}   Reset

Reset
    Sleep    3
    Click Element    ${WEBEM_HOME}
    Wait Until Page Contains   Radio Modules Status Summary  timeout=10s
    Wait Until Page Contains   Cells Status Summary  timeout=10s
    Wait Until Page Contains   Network Slicing Summary  timeout=10s
    Log to Console      before reset sleep10
    Click Element       ${RESETVDU}
    Log to Console      reset success
    Run keyword and ignore error  Click Element    ${OKRESET}
    Log to Console      clicked okreset
    Wait Until Page Contains   Connection to the server was lost.  timeout=1800s


Logout
    Click Element    //*[contains(text(),'Nemuadmin')]
    wait until element is visible    //*[contains(text(),'Sign out')]    timeout=10s
    Click Element    //*[contains(text(),'Sign out')]
    Sleep    3s
    Close Browser
