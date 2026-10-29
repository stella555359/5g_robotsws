*** Settings ***
Documentation
...    Author: Andrada Bugiu (andrada.bugiu@nokia.com)
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)

Library  SeleniumLibrary

*** Variables ***
${VDU}          https://10.5.62.66
${VDUSSH}       10.5.26.234

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
    Click Element  //*[contains(text(),'Sign out')]
    Sleep  4
    Close Browser

Check notification doesn`t appear
    Wait Until Page Contains    Radio Modules Status Summary
    Wait Until Page Contains    Cells Status Summary
    Page Should Not Contain     Not supported Google Chrome version.

Check session info appears
    Click Element   //*[@id="user-settings"]/button/span[2]
    Sleep  4

    Page Should Contain  Last login time:
    ${logInTime}=  Get Element Attribute  ${logInTimeInfo}  title
    Should Not Be Empty  ${logInTime}

    Page Should Contain  Token expiration time:
    ${tokenExpirationTime}  Get Element Attribute  ${tokenExpirationTimeInfo}  title
    Should Not Be Empty  ${tokenExpirationTime}

    Page Should Contain  Invalid login attempts:
    ${invalidLogIn}  Get Element Attribute  ${invalidLogInInfo}  title
    Should Not Be Empty  ${invalidLogIn}
