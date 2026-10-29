*** Settings ***
Documentation
...    Author: Adelina Gordan (adelina.gordan@nokia.com)
...    Maintainer: Adelina Gordan (adelina.gordan@nokia.com)

Library  SeleniumLibrary
Library  DateTime
Library  String

*** Variables ***
${VCU}         https://10.15.253.201    #cran2
${vCUSSH}      10.5.62.253             #old: 10.5.62.34
${SSHPASS}     Yt_xk39b@123             #old pass: root
${CRANNAME}    cran2

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
    sleep  3
    ${condition}=  run keyword and return status  page should contain  Confirm
    run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]
    Sleep   10
    Wait Until Page Contains    DUs Status Summary      timeout=20s
    Wait Until Page Contains    Cells Status Summary    timeout=20s
    Wait Until Page Contains    X2 Links Summary        timeout=20s
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

Select counters to display TCP UDP
    Click Element  ${performanceButton}
    Sleep  3
    Click Element  class:select-counters-button
    Sleep  10
    Click Element      ${oam_pm_select_counters}
                        #//*[contains(text(),'IPNO')]
    Sleep  3
    Click Element     //*[contains(text(),'TCP/UDP statistics (TCP_UDP_stats)')]
    Sleep  3
    Click Element     //*[contains(text(),'M51325C0 (tcpInPackets)')]
    Sleep  3
    Click Element     //*[contains(text(),' Select all ')]
    Sleep  3
    Click Element     //*[contains(text(),'M51325C2 (tcpOutPackets)')]
    Sleep  3
    Click Element     //*[contains(text(),' Select all ')]
    Sleep  3
    Click Element     //*[contains(text(),'OK')]
    Sleep  5

Check selected counters
    ${now}  Get Current Date  result_format=%Y-%m-%d
    ${dates}=  Get WebElements  ${dates_table}

    FOR      ${element}     IN       @{dates}
        Mouse Over  ${element}
        Log    ${element.text}
        Should Contain  ${element.text}  ${now}
    END

    ${number}=  Get WebElements  ${valuestabel}
    ${zero}=  Convert to String   0

    FOR   ${row}  IN  @{number}
        Log    ${row.text}
        ${value}=    Split String   ${row.text}  ${SPACE}
        ${condition}=  run keyword and return status  Should Not Be Equal As Strings  ${value}   ${zero}
        run keyword if  ${condition} == False   FAIL
#        FOR   ${valueincell}   IN   @{value}
#            Log  ${valueincell}
#            Should Not Be Equal As Strings  ${valueincell}   ${zero}
#        END
    END

Clear selection
    Click Element  class:select-counters-button
    Sleep  3
    Click Element   ${erasebutton}
    Sleep  3
    Click Element     //*[contains(text(),'OK')]
    Sleep  5

Select counters to display SCTP
    Click Element  class:select-counters-button
    Sleep  10
    Click Element      ${oam_pm_select_counters}
                        #//*[contains(text(),'IPNO')]
    Sleep  3
    Click Element      //*[contains(text(),'SCTP statistics (SCTP_stats)')]
    Sleep  3
    Click Element      //*[contains(text(),'M51326C0 (sctpInPackets)')]
    Sleep  3
    Click Element     //*[contains(text(),' Select all ')]
    Sleep  3
    Click Element      //*[contains(text(),'M51326C2 (sctpOutPackets')]
    Sleep  3
    Click Element     //*[contains(text(),' Select all ')]
    Sleep  3
    Click Element     //*[contains(text(),'OK')]
    Sleep  3
