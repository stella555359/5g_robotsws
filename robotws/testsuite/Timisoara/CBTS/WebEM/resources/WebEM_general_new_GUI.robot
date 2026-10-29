*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for CBTS WebEM TCs with the new GUI.


*** Keywords ***
Confirm Legal Notice From CBTS
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  //*[@id="laf-component"]/ot-dialog/p-dialog/div/div/div[1]  30s  Legal notice did not appear in 30 seconds.
    Wait Until Element Is Clicked  //*[@id="laf-component"]/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button/span  60
    Log  Admin reached!  console=true


Logout From CBTS
    [Documentation]  This keyword is used to disconnect from CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@class="otx-product-user-account"]/span[2]  60
    Wait Until Element Is Clicked  //*[contains(text(), 'Logout')]  60
    Log  Logout from CBTS WebEM was successfully done!  console=true


Open Operator Certificates
    [Documentation]  This keyword is used to open operator certificates from CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@data-menu-header, "Security")]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Certificate Management')]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Operator Certificates')]
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Operator Certificates')]
    Sleep  10s  This sleep is for page to be uploaded.
