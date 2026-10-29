*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for CBTS WebEM TCs with the old GUI.


*** Keywords ***
Confirm Legal Notice From CBTS
    [Documentation]  This keyword waits for the legal notice and presses the Confirm button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Wait for legal notice  console=true
    Wait Until Element Is Visible  xpath:/html/body/p-dynamicdialog/div/div  30s  Legal notice did not appear in 30 seconds.
    Click Element  //*[contains(text(), 'Confirm')]
    Log  Admin reached!  console=true


Logout From CBTS
    [Documentation]  This keyword is used to disconnect from CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@id="user-settings"]/button/span[2]  60
    Wait Until Element Is Clicked  //*[contains(text(), 'Sign out')]  60
    Log  Sign out from CBTS WebEM was successfully done!  console=true


Open Operator Certificates
    [Documentation]  This keyword is used to open operator certificates from CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${op_certificates}  Catenate  SEPARATOR=  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/webem-page-
    ...  navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[6]/i
    Wait Until Element Is Clicked  ${op_certificates}  120
    Sleep  10s  This sleep is for page to be uploaded.
