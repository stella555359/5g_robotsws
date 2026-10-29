*** Settings ***
Documentation  WebEM Common Resource

*** Keywords ***

Login On CBTS
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    [Arguments]  ${username}  ${password}

    Input Text  //*[@id="login-username"]  ${username}
    Input Password  //*[@id="login-password"]  ${password}
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //*[@id="login-button"]/button/span

Logout From CBTS
    [Documentation]  This keyword is used to disconnect from CBTS.

    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //span[@class='otx-product-user-account-subicon mdi mdi-chevron-down']
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //*[contains(text(), 'Logout')]
    Log  Logout from CBTS WebEM was successfully done!  console=true

Check Private Connection From BTS
    [Documentation]  This keyword checks if private connection page appears and proceed the link.

    Log  Check private connection  console=true
    ${status}=  Run Keyword And Return Status
    ...  Get Text  //*[@id="main-message"]/h1
    IF  ${status}
        Wait Until Keyword Succeeds  60  5
        ...  Click Element  //*[@id="details-button"]
        Wait Until Keyword Succeeds  60  5
        ...  Click Element  //*[@id="proceed-link"]
    END

Confirm Legal Notice From CBTS
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[@id="laf-component"]/ot-dialog/p-dialog/div/div/div[1]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //span[normalize-space()='Accept']
    Log  Admin reached!  console=true

Capture BTS Page Screenshot
    [Arguments]    ${screenshot_name}
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    Capture Page Screenshot  ${screenshot_name}_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.png

Login On SBTS
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    [Arguments]  ${username}  ${password}

    Input Text  //*[@id="login-username"]  ${username}
    Input Password  //*[@id="login-password"]  ${password}
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //*[contains(text(), 'Login')]

Logout From SBTS
    [Documentation]  This keyword is used to disconnect from SBTS.

    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //span[@class='otx-product-user-account-subicon mdi mdi-chevron-down']
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //div[contains(text(),'Logout')]
    Log  Logout from SBTS WebEM was successfully done!  console=true

Confirm Legal Notice From SBTS
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Legal Notice')]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Keyword Succeeds  60  5
    ...  Click Element  //span[normalize-space()='Accept']
    Log  Admin reached!  console=true
