*** Settings ***
Documentation
...    Author: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Maintainer: Andrada Bugiu (andrada.bugiu@nokia.com)

Library   SeleniumLibrary

*** Variables ***
${VDU}         https://10.5.62.58

*** Keywords ***
Login vDU
    Open Browser for ssh
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
    Sleep  5
    Page should contain  Nemuadmin
    Click element  user-settings
    Page should contain  Sign out
    Sleep   5
    Click element  //*[contains(text(),'Sign out')]
    Sleep  4
    Close browser


Modify dlMimoMode parameter
    Sleep    3
    Click Element    ${Configuration_button}
    Sleep    3
    Input Text  xpath=//*[@id="filter-input-field-plans-tree"]    NRCELL
                    #id:filter-input-field-plans-tree  NRCELL
    Sleep  2
    Click Element   xpath=//*[@id="clear-input"]
    Sleep    2
    Click Element  //*[contains(text(),'NRCELL-1')]
    Sleep  2

    Input Text      xpath=//*[@id="filter-input-field-name"]  dlMimoMode
                        #id:filter-input-field-name  dlMimoMode
    Sleep  2
    Click Element  ${Properties_tab}  # open properties tab
    Sleep  2
    Click Element  //*[contains(text(),'dlMimoMode')]
    Page Should contain  Objectlocking
    Sleep  2
    Click Element  ${Properties_tab}  # close properties tab
    Sleep  2

    ${condition}=  run keyword and return status
        ...     Click Element  //*[contains(text(),'2x2 Closed Loop Spatial Multiplexing')]
    run keyword if   ${condition}==True  run keywords
        ...     Set Suite Variable  ${flag}  closed-open  AND
        ...     Sleep  2  AND
        ...     Mouse Down    xpath=//li[contains(.,'2x2 Open Loop Spatial Multiplexing')]  AND
        ...     Click Element  xpath=//li[contains(.,'2x2 Open Loop Spatial Multiplexing')]
        ...     ELSE  run keywords
        ...     Set Suite Variable  ${flag}  open-closed  AND
        ...     Click Element  //*[contains(text(),'2x2 Open Loop Spatial Multiplexing')]  AND
        ...     Sleep  2  AND
        ...     Mouse Down    xpath=//li[contains(.,'2x2 Closed Loop Spatial Multiplexing')]  AND
        ...     Click Element  xpath=//li[contains(.,'2x2 Closed Loop Spatial Multiplexing')]


Modify nrCellType parameter
    Input Text  id:filter-input-field-name  nrCellType
    Sleep  2
    Click Element  ${Properties_tab}  # open properties tab
    Sleep  2
    Click Element  //*[contains(text(),'nrCellType')]
    Page Should contain  Conditional bts restart
    Sleep  2
    Click Element  ${Properties_tab}  # close properties tab
    Sleep  2

    ${condition}=  run keyword and return status  Click Element  //*[contains(text(),'2DL2UL')]
    run keyword if   ${condition}==True  run keywords
        ...     Sleep  2  AND
        ...     Mouse Down    xpath=//li[contains(.,'2DL4UL')]  AND
        ...     Click Element  xpath=//li[contains(.,'2DL4UL')]
        ...     ELSE  run keywords
        ...     Click Element  //*[contains(text(),'2DL4UL')]  AND
        ...     Sleep  2  AND
        ...     Mouse Down    xpath=//li[contains(.,'2DL2UL')]  AND
        ...     Click Element  xpath=//li[contains(.,'2DL2UL')]


Modify parameter with object locking
    Click Element  ${Configuration_button}
    Sleep  2
    Click Element  //*[contains(text(),'Create Delta Plan')]
    Click Element  //*[contains(text(),'OK')]
    Wait until page contains  Create plan operation finished  timeout=20
    Sleep  2

    Modify dlMimoMode parameter

    Sleep  5
    Click Element  //*[contains(text(),'Validate Plan')]
    Wait until page contains  Validate plan operation finished  timeout=20
    Sleep  2
    Click Element  //*[contains(text(),'Activate Plan')]
    Click Element   //*[contains(text(),'Execute')]
    Wait until page contains  The following will be locked  timeout=60
    Click Element  //*[contains(text(),'Continue')]
    Wait until page contains  Activate plan operation finished  timeout=60
    Click Element  //*[contains(text(),'Done')]


Modify parameter with vDU reset
    Click Element  ${Configuration_button}
    Sleep  2
    Click Element  //*[contains(text(),'Create Delta Plan')]
    Click Element  //*[contains(text(),'OK')]
    Wait until page contains  Create plan operation finished  timeout=20
    Sleep  2

    Modify dlMimoMode parameter
    Modify nrCellType parameter

    Sleep  5

    Click Element  //*[contains(text(),'Validate Plan')]
    Wait until page contains  Validate plan operation finished  timeout=20
    Sleep  2
    Click Element  //*[contains(text(),'Activate Plan')]
    Click Element   //*[contains(text(),'Execute')]
    Wait until page contains  Continue  timeout=120
    Sleep  20
    Click Element  //*[contains(text(),'Continue')]
    Wait until page contains  Activate plan operation finished  timeout=660
    Click Element  //*[contains(text(),'Done')]


Check object locking
    Sleep  10
    Page should not contain  Connection to the server was lost.
    Wait until page contains  Integrated to RAN  timeout=200
    Page should contain  Integrated to RAN
    Check cell status
    Click Element  ${Configuration_button}
    Check dlMimoMode parameter


Check vdu reset
    #Wait until page contains element  ${connection_lost_message}  timeout=60
    Wait until page contains  Activate plan operation finished  timeout=60
    #Wait until element is visible   //*[contains(text(),'Done')]   timeout=10
    #Click Element  //*[contains(text(),'Done')]
    Check dlMimoMode parameter

    Input Text  id:filter-input-field-name  nrCellType
    Sleep  2
    Click Element  //*[contains(text(),'nrCellType')]
    ${condition}=  run keyword and return status  Page Should contain  2DL4UL
    run keyword if   ${condition}==False  Page Should contain  2DL2UL

    log to console  ...Wait until vDU is OnAir...
    Wait until page contains  OnAir  timeout=600


Check cell status
    Click Element  ${Status_button}
    Sleep  2
    Click Element  //*[contains(text(),'Cells Status')]
    Sleep  2
    Click Element  ${Properties_tab}  # open properties tab
    Sleep  2
    Click Element  ${Cell}
    Page Should contain  Disabled
    Sleep  2
    log to console  ...Wait until vDU is OnAir...
    Wait until page contains  OnAir  timeout=600
    Sleep  2
    Page Should contain  Enabled
    Click Element  ${Properties_tab}  # close properties tab
    Sleep  2


Check dlMimoMode parameter
    Sleep  2
    Click Element  id:filter-input-field-plans-tree
    Input Text  id:filter-input-field-plans-tree  NRCELL
    Sleep  2
    Click Element  xpath=//*[@id="clear-input"]
    Sleep  1
    Click Element  //*[contains(text(),'NRCELL-1')]
    Sleep  4
    Input Text  id:filter-input-field-name  dlMimoMode
    Sleep  2
    Click Element  //*[contains(text(),'dlMimoMode')]

    ${condition}=  run keyword and return status  Should be equal as strings  ${flag}  closed-open
    run keyword if  ${condition}==True  Page Should contain  2x2 Open Loop Spatial Multiplexing
    ...     ELSE  Page Should contain  2x2 Closed Loop Spatial Multiplexing


Delete DeltaPlan
    Click Element   ${Configuration_button}
    Sleep  2
    Click Element   ${ConfigPlans_list}
    ${condition}=  run keyword and return status  Page Should Contain  DELTA-PLAN-1
    IF  ${condition} == True
        Click Element   ${Configuration_button}
        Sleep  2
        Click Element   ${ConfigPlans_list}
        Click Element   //*[contains(text(),'DELTA-PLAN-1')]
        Sleep  2
        Click Element  //*[contains(text(),'Delete Plan')]
        Sleep  2
        Click Element  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]
        Wait until page contains  Delete plan operation finished  timeout=60
    ELSE
        Log   No DELTA PLAN Available
    END
