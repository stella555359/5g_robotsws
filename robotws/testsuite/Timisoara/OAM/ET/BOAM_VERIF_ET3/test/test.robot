*** Settings ***
Library  SeleniumLibrary
Library  SSHLibrary

*** Keywords ***

Login vDU
#    Open Browser  https://10.5.62.58/  chrome
#        ${condition}=  run keyword and return status  page should contain  Advanced
#        run keyword if   ${condition}==True  run keywords
#        ...     click button  details-button  AND  click link  proceed-link
#    Input Text   login-username  Nemuadmin
#    Input Text   login-password  nemuuser
#    Click Element  login-button
#    wait until page contains   Legal Notice  timeout=10s
#     ${condition}=  run keyword and return status  page should contain  Legal Notice
#        run keyword if   ${condition}==True  Click Element  //*[contains(text(),'Confirm')]
#    Maximize Browser Window
#    Wait Until Page Contains   Radio Modules Status Summary  timeout=10s
#    Wait Until Page Contains   Cells Status Summary  timeout=10s
#    Wait Until Page Contains   Network Slicing Summary  timeout=10s
    Open Connection   10.5.62.253
    Login  core  Yt_xk39b@123
    ${variabila}  Read  delay=10s
    Log to console  ${variabila}
    Close Connection
#    Close Browser

*** Test Cases ***
1. Login vDU
    Login vDU


