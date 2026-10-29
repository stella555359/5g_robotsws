*** Settings ***
Documentation
    ...  This TC is created to change password for toor4nsn and serviceuser.
    ...  Activate BTS Security Administrator user role with Security as user and Nokia02! as password.
    ...  Connect on WebEM with Security user.
    ...  Change password for toor4nsn and serviceuser from Service Account Management tab.
    ...  New password: Nokia02!
    ...  Check if Process completed text is visible.
    ...  Verify if the new password was changed correctly for both users.
    ...  Change with wrong password for both users from Service Account Management tab.
    ...  New password: Nokia
    ...  Check if New password is invalid text is visible.
    ...  Execute configuration reset to restore all accounts as default.
    ...  Upload the initial SCF and wait until all cells are onAir.
    ...  Verify if the default passwords are changed correctly for both users.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${AFTER_COMMISSIONING_TIMEOUT}  1200s  # Timeout for cells to be onAir after commissioning!
${BTS_RESCUE_CONSOLE_TIMEOUT}  600s  # Timeout for BTS Rescue Console to appear!
${CONFIG_RESET_OPTION}  6  # Number of configuration reset option from BTS Rescue Console


*** Keywords ***
TC__WebEM__Password_change_for_toor4nsn_serviceuser
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27621
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27621 - Initial TAT creation
    ...  - 15.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29778 - Change xpath for 'Process completed' message

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24

    Step1: Activate BTS Security Administrator User Role
    Step2: Connect On WebEM With Security
    Step3: Change Password For Toor4nsn And Serviceuser
    Step4: Check That Password Was Changed Correctly
    Step5: Change With Wrong Password For Both Users
    Step6: Restore Accounts As Default


Step1: Activate BTS Security Administrator User Role
    Log  \nStep1: Activate BTS Security Administrator user role  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  //span[contains(@title, 'Choose account you want to update')]
    Wait Until Element Is Visible  //*[contains(@data-value, 'BTS Security Administrator')]  10
    Log  BTS Security Administrator is visible![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(@data-value, 'BTS Security Administrator')]
    Log  BTS Security Administrator user is opened!  console=true
    Input Text  //*[@id="uam-local-alias"]/div/input  Security
    Log  Alias Security is provided!  console=true
    Input Password  //*[@id="uam-local-password"]/div/input  Nokia02!
    Log  Password Nokia02! is provided!  console=true
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  Nokia02!
    Log  Password Nokia02! is confirmed!  console=true
    Wait Until Element Is Clicked  //span[contains(@title, 'Inactive')]
    Wait Until Element Is Clicked  //*[contains(@data-value, 'Active')]
    Wait Until Element Is Clicked  //button[@ui-tooltip='Save']
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Wait Until Element Is Visible  //*[contains(text()," Process completed.")]  timeout=300
    ELSE
        Wait Until Element Is Visible  //*[contains(text(),"Process completed.")]  timeout=300
    END
    Log  Account was activated![OK]  console=true
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[3]/div/modal-footer/uam-modal-footer/ui-button[2]/button  120


Step2: Connect On WebEM With Security
    Log  \nStep2: Connect on WebEM with Security  console=true
    Log  Logout from SBTS will be performed!  console=true
    Logout From SBTS
    Wait Until Element Is Visible  xpath=//*[contains(text(), 'Login')]  60
    Input Text  //*[@id="login-username"]  Security
    Input Password  //*[@id="login-password"]  Nokia02!
    Wait Until Element Is Clicked  //*[contains(text(), 'Login')]
    Log  Login on SBTS with username Security!  console=true
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[2]/div[1]/div/div  200s
    ...  WebElement is not fully loaded in 200s seconds.
    Capture Page Screenshot  WebEM_SBTS_Security_account.png
    Log  Screenshot was performed and saved in ${BTS_FILES}/selenium_screenshot_${TEST_NAME}!  console=true


Step3: Change Password For Toor4nsn And Serviceuser
    Log  \nStep3: Change password for toor4nsn and serviceuser  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body/wf-tabs/ul/li[2]/a
    Log  Service Account Management tab is visible![OK]  console=true
    Change Password For A Specific Service Account  toor4nsn  oZPS0POrRieRtu  Nokia02!  Process completed
    Change Password For A Specific Service Account  serviceuser  Pl(FzaYj5~c5;q  Nokia02!  Process completed
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step4: Check That Password Was Changed Correctly
    Log  \nStep4: Check that password was changed correctly  console=true
    ${status_toor4nsn}  Run Keyword And Return Status
    ...  ssh.Connect To  ${OAM_BTS_IP}  toor4nsn  Nokia02!  alias=toor4nsn
    Run Keyword If  ${status_toor4nsn}
    ...  Log  Password for toor4nsn was changed correctly![OK]  console=true
    ...  ELSE
    ...  Fail  Password for toor4nsn was not changed correctly![NOK]
    ssh.Disconnect  connection=toor4nsn
    ${status_serviceuser}  Run Keyword And Return Status
    ...  ssh.Connect To  ${OAM_BTS_IP}  serviceuser  Nokia02!  alias=serviceuser
    Run Keyword If  ${status_serviceuser}
    ...  Log  Password for serviceuser was changed correctly![OK]  console=true
    ...  ELSE
    ...  Fail  Password for serviceuser was not changed correctly![NOK]
    ssh.Disconnect  connection=serviceuser


Step5: Change With Wrong Password For Both Users
    Log  \nStep5: Change with wrong password for both users  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body/wf-tabs/ul/li[2]/a
    Log  Service Account Management tab is visible![OK]  console=true
    Change Password For A Specific Service Account  toor4nsn  Nokia02!  Nokia  New password is invalid
    Change Password For A Specific Service Account  serviceuser  Nokia02!  Nokia  New password is invalid
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step6: Restore Accounts As Default
    Log  \nStep6: Restore accounts as default  console=true
    Restore The Account And The Passwords As Default


Change Password For A Specific Service Account
    [Arguments]  ${username}  ${old_password}  ${new_password}  ${message}

    Input Text  //*[@id="uam-service-user-name"]  ${username}
    Input Password  //*[@id="uam-service-old-password"]  ${old_password}
    Input Password  //*[@id="uam-service-new-password"]  ${new_password}
    Input Password  //*[@id="uam-service-confirm-password"]  ${new_password}
    Wait Until Element Is Clicked  //button[@ui-tooltip='Save']
    Log  Saving changes![OK]  console=true
    Wait Until Element Is Visible  //*[contains(text(),"${message}")]  timeout=300
    Log  ${message} is visible![OK]  console=true


Restore The Account And The Passwords As Default
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120
    Log  Logout from SBTS will be performed!  console=true
    Logout From SBTS
    Wait Until Element Is Visible  xpath=//*[contains(text(), 'Login')]  60
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  120  WebElement is not fully loaded in 120 seconds.
    Performing Configuration Reset And Verify SBTS To Be Not Commissioned  ${BTS_RESCUE_CONSOLE_TIMEOUT}  ${CONFIG_RESET_OPTION}
    Sleep  180s  Time for all modules to be visible!
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close Startup View If Visible
    Wait Until Keyword Succeeds  ${AFTER_COMMISSIONING_TIMEOUT}  30s
    ...  Check All Cells
    ${status_toor4nsn}  Run Keyword And Return Status
    ...  ssh.Connect To  ${OAM_BTS_IP}  toor4nsn  oZPS0POrRieRtu  alias=toor4nsn
    Run Keyword If  ${status_toor4nsn}
    ...  Log  Password for toor4nsn was restored to default![OK]  console=true
    ...  ELSE
    ...  Fail  Password for toor4nsn was not restored to default![NOK]
    ssh.Disconnect  connection=toor4nsn
    ${status_serviceuser}  Run Keyword And Return Status
    ...  ssh.Connect To  ${OAM_BTS_IP}  serviceuser  Pl(FzaYj5~c5;q  alias=serviceuser
    Run Keyword If  ${status_serviceuser}
    ...  Log  Password for serviceuser was restored to default![OK]  console=true
    ...  ELSE
    ...  Fail  Password for serviceuser was not restored to default![NOK]
    ssh.Disconnect  connection=serviceuser


TC Setup
    Common Test Setup  tc_name=WebEM__Password_change_for_toor4nsn_serviceuser
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore The Account And The Passwords As Default
    WebEM Teardown
    Common Test Teardown
