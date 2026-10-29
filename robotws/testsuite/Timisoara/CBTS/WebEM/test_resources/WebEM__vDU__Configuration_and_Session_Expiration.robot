*** Settings ***
Documentation
    ...  This TC is created to verify the Configuration related info and session expiration on vDU WebEM.
    ...  First, an invalid SCF is uploaded to WebEM from API to check if it fails.
    ...  A valid SCF is uploaded next. After that, all services must be operational.
    ...  jwtExpirationTime is set to 10 minutes and pods are checked.
    ...  After 5 minutes a notification appears to let de the user know that the WebEM session will expire in 5 minutes.
    ...  WebEm session is renewed and TC waits once again to expire.
    ...  At the end of the test, jwtExpirationTime parameter is set to 2 hours.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/vdu_WebEM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  15m


*** Keywords ***
TC__WebEM__vDU__Configuration_and_Session_Expiration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25085
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  11.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25085 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB009444-CB006420

    Step 0: TC Preconditions
    Step 1: Load An Invalid SCF To WebEM
    Step 2: Load An Old Version Full SCF To WebEM
    Step 3: Change JwtExpirationTime Parameter
    Step 4: Check BTS Pods
    Step 5: Wait For Expiration Toast Message To Appear And Renew Session
    Step 6: Wait For WebEM Session To Expire Second Time


Step 0: TC Preconditions
    Log  \nStep 0: TC preconditions.  console=true
    ${software_version}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    ${config_path}  Fetch From Right  ${CONFIGURATION}  .
    ${vdu_invalid_scf_path}  Catenate  SEPARATOR=  /home/ute/testline_configuration/${config_path}/node1
    ...  /${TOPOLOGY}_${software_version}_invalid.xml
    Set Test Variable  ${VDU_INVALID_SCF_PATH}


Step 1: Load An Invalid SCF To WebEM
    Log  \nStep 1: Load an invalid SCF to WebEM.  console=true
    ${upload_status}  Run Keyword And Return Status
    ...  vdu.Perform Commissioning  ${VDU_INVALID_SCF_PATH}
    Run Keyword If  ${upload_status}
    ...  Fail  Uploading an invalid SCF didn't fail. [NOK]
    ...  ELSE
    ...  Log  Invalid SCF upload failed. [OK]  console=true


Step 2: Load An Old Version Full SCF To WebEM
    Log  \nStep 2: Load an old version full SCF to WebEM.  console=true
    vdu.Perform Commissioning  ${VDU_SCF_PATH}
    Wait Until Element Is Visible  //*[@id="Close"]/button  300s
    Click Element  //*[@id="Close"]/button
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  operational_state  ${ENABLED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}  administrative_state=${UNLOCKED}
    Log  All services are operational after valid SCF actvation. [OK]  console=true


Step 3: Change JwtExpirationTime Parameter
    Log  \nStep 3: Change jwtExpirationTime parameter.  console=true
    Change Specific Parameter For VDU  jwtExpirationTime  10  MRBTS-1/MNL-1/AMGR-1/LUAC-1
    Reload Page
    Wait Until Keyword Succeeds  60s  2s
    ...  Login On CBTS
    Confirm Legal Notice From CBTS


Step 4: Check BTS Pods
    Log  \nStep 4: Check BTS pods.  console=true
    Check All PODs On VDU To Be On Air And Verify Their Information


Step 5: Wait For Expiration Toast Message To Appear And Renew Session
    Log  \nStep 5: Wait for expiration toast message to appear and renew session.  console=true
    Wait Until Element Is Visible  //*[contains(text(),"Session token will expire in 5 mins")]  6m  Toast message did not appear in WebEM. [NOK]
    Run Keyword If  '${GUI_VERSION}' == 'old'
    ...  Run Keywords
    ...  Click Element  //*[@id="toast-container"]/webem-session-expire-warning-toast/div[1]/button/i
    ...  AND
    ...  Wait Until Element Is Not Visible  //*[contains(text(),"Session token will expire in 5 mins")]  timeout=2s
    ...  AND
    ...  Click Element  //*[@id="notification-center"]/button/div/img
    Wait Until Element Is Visible  //*[contains(text(),"Renew")]  5s  Toast message did not appear in Notification center. [NOK]
    Click Element  //*[contains(text(), "Renew")]
    Input Password  //*[@id="renew-session-password"]  ${VDU_OAM_PASSWORD}
    ${ok_button}  Catenate  SEPARATOR=  xpath:/html/body/p-dynamicdialog/div/div/div[2]/ui-webem-renew-session-dialog
    ...  /form/div[2]/p-footer/ui-webem-button[1]/p-button/button/span
    Click Element  ${ok_button}
    Log  First session renewed sucessfully.  console=true


Step 6: Wait For WebEM Session To Expire Second Time
    Log  \nStep 6: Wait for WebEM session to expire second time.  console=true
    Wait Until Element Is Visible  //*[contains(text(),"Session token will expire in 5 mins")]  6m  Toast message did not appear in WebEM. [NOK]
    Log  Session will expire again in 5 minutes.  console=true
    Wait Until Element Is Visible  //*[@id="login-username"]  6m
    ...  WebEM session did not expire. [NOK]
    Log  WebEM session expired for the second time. [OK]  console=true
    Login On CBTS
    Confirm Legal Notice From CBTS


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Configuration_and_Session_Expiration


TC Teardown
    Change JwtExpirationTime Parameter To Desired Value On VDU  120
    VDU WebEM Teardown
    Common VDU Teardown
