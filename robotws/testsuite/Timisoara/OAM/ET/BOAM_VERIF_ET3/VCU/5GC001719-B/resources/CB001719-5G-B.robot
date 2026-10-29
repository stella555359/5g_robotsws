*** Settings ***
Documentation
...    Author: Adrian Cretu / Oana Ciuculescu (adrian.1.cretu@nokia.com / oana.ciuculescu@nokia.com)
...    Maintainer: Adrian Cretu / Oana Ciuculescu (adrian.1.cretu@nokia.com / oana.ciuculescu@nokia.com)


Library   SeleniumLibrary
Library   SSHLibrary
Library   String


*** Variables ***
${VCU}         https://10.15.253.195    #cran2


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

Logout vCU
    Click element    ${userSettings}
    Sleep  3
    Page Should Contain  Sign out
    sleep   6
    Click Element  ${signOut}
    Sleep  3
    Close Browser

Check Xn Link buttons
    Page Should Contain Element    ${lockbutton}
    Page Should Contain Element    ${unlockbutton}

Verify Xn Link state
    Click Element    ${lockbutton}
    Sleep  3
    ${condition}=  Run Keyword And Return Status  Page Should Contain   None of elements match the operation
    IF  ${condition} == True
        Click Element   ${cancelbutton}
        ${state}=  Set Variable  Locked
        Log   ${state}
    ELSE
        Click Element   ${cancelbutton}
        Click Element   ${unlockbutton}
        Sleep  3
        Page Should Contain   None of elements match the operation
        ${state}=  Set Variable  Unlocked
        Log   ${state}
        Click Element   ${cancelbutton}
    END
    #[Return]  ${state}

Change Xn Links
    [Arguments]  ${button1}  ${button2}
    Click Element    ${button1}
    Sleep  3
    ${condition}=  Run Keyword And Return Status  Page Should Contain   None of elements match the operation
    IF  ${condition} == True
        Click Element   ${cancelbutton}
        Click Element   ${button2}
        Sleep  3
        Page Should Contain    ${filter1}
        Click Element   ${xnlink1}
        Click Element   ${xnlink2}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   operation started
        Wait Until Element Contains    ${statuspopup}   operation finished   timeout=60
        Sleep  5
        Click Element   ${button2}
        Sleep  3
        Page Should Contain   None of elements match the operation
        Click Element   ${cancelbutton}
    ELSE
        Page Should Contain    ${filter1}
        Click Element   ${xnlink1}
        Click Element   ${xnlink2}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   operation started
        Wait Until Element Contains    ${statuspopup}   operation finished   timeout=60
        Sleep  5
        Click Element   ${button1}
        Sleep  3
        Page Should Contain   None of elements match the operation
        Click Element   ${cancelbutton}
    END

Change one Xn Link using filter
    Click Element    ${lockbutton}
    Sleep  3
    ${condition}=  Run Keyword And Return Status  Page Should Contain   None of elements match the operation
    IF  ${condition} == True
        Click Element   ${cancelbutton}
        Click Element   ${unlockbutton}
        Sleep  3
        Page Should Contain    ${filter2}
        Input Text    ${filtertab}    ${filter1}
        Sleep  3
        Page Should Not Contain    ${filter2}
        Click Element   ${xnlink1}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   Xn link unlock
        Wait Until Element Contains    ${statuspopup}   Xn link unlock   timeout=60
        Sleep  15
        Click Element   ${lockbutton}
        Sleep  5
        Page Should Contain   ${filter1}
        Click Element   ${xnlink1}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   Xn link lock
        Wait Until Element Contains    ${statuspopup}   Xn link lock    timeout=60
    ELSE
        Page Should Contain    ${filter2}
        Input Text    ${filtertab}    ${filter1}
        Sleep  3
        Page Should Not Contain    ${filter2}
        Click Element   ${xnlink1}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   Xn link lock
        Wait Until Element Contains    ${statuspopup}   Xn link lock    timeout=60
        Sleep  15
        Click Element   ${unlockbutton}
        Sleep  5
        Page Should Contain   ${filter1}
        Click Element   ${xnlink1}
        Sleep  3
        Click Element   ${okbutton}
        Sleep  1
        Element Should Contain    ${statuspopup}   Xn link unlock
        Wait Until Element Contains    ${statuspopup}   Xn link unlock   timeout=60
    END
