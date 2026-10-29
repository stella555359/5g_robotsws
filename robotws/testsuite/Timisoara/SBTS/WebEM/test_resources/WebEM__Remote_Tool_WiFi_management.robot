*** Settings ***
Documentation
    ...  This TC shall support command 'getSSDWifiInfo','setSSDWifiUser' and 'getWifiConnectedClients'
    ...  Change parameter actCli to be true.
    ...  Change parameter ShowWifiEnableAlarm to be true.
    ...  Check if 'getSSDWifiInfo' command via ADMIN CLI is sent with error code 0 and check default users.
    ...  Check if 'setSSDWifiUser' command via ADMIN CLI is sent with error code 0.
    ...  Check if 'getSSDWifiInfo' command via ADMIN CLI is sent with error code 0 and check if users are set after sending command.
    ...  Check if 'getWifiConnectedClients' command via ADMIN CLI is sent with error code 0 and check if wifi user exists.
    ...  Change parameter showWifiEnableAlarm to be false.
    ...  Change parameter actCli to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${FILE_WITH_USERS}  #Mandatory! Path to file with users that should be set. Should exist in testline_configuration.
${PASSPHRASE_FIRST_USER}  FaqOXLgv7az5ZTTUo1NFaASZOMTUb9a+JCTIa67b3WVCr9XCJB$  #Default passphrase for first user
${PASSPHRASE_SECOND_USER}  %fL3I17stIdscj5HaxdBPN4Y5V7LxA25ht0PsPf2Nd3OAu/EBL8  #Default passphrase for second user
${PASSPHRASE_THIRD_USER}  ^HOlwRev0A/0uwZXSOokJFAONS+WxBgJm2ttKDe5v8QFnnWrwnj  #Default passphrase for third user

*** Keywords ***
TC__WebEM__Remote_Tool_WiFi_management
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26875
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  07.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-26875 - Initial TAT creation
    ...  25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30575 - Set passphrases as test variables

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS26
    ...  FEATURE-CB009233

    Step1: Change ShowWifiEnableAlarm Parameter To Be true
    Step2: Sending Command GetSSDWifiInfo Via ADMIN CLI
    Step3: Sending Command SetSSDWifiUser Via ADMIN CLI
    Step4: Sending Command GetSSDWifiInfo Via ADMIN CLI
    Step5: Sending Command GetWifiConnectedClients Via ADMIN CLI
    Step6: Change ShowWifiEnableAlarm Parameter To Be false


Step${index}: Change ShowWifiEnableAlarm Parameter To Be ${value}
    Log  \nStep${index}: Change ShowWifiEnableAlarm Parameter To Be ${value}  console=true
    ${status}  Run Keyword And Return Status  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/WLAN-1  showWifiEnabledAlarm  update
    ...  ${value}  skip_parameter_relation_errors=True
    IF  ${status}
        Log  Parameter showWifiEnableAlarm is set to ${value}![OK]  console=true
    ELSE
        Fail  Parameter showWifiEnableAlarm is not set to ${value}![NOK]
    END


Step${index}: Sending Command GetSSDWifiInfo Via ADMIN CLI
    Log  \nStep${index}: Sending Command GetSSDWifiInfo Via ADMIN CLI  console=true
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getSSDWifiInfo"}}
    IF  '${requestStatus}' == 'completed' and ${errorCode} == 0
        Log  Command sent with status: ${requestStatus} and error code: ${errorCode}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}![NOK]
    END
    IF  ${index} == 2
        Check Default Users  ${requestMessage}
    ELSE
        Check Users Set After Sending Command  ${index}  ${requestMessage}
    END


Step3: Sending Command SetSSDWifiUser Via ADMIN CLI
    Log  \nStep3: Sending Command SetSSDWifiUser Via ADMIN CLI  console=true
    ${status_file}  Run Keyword And Return Status  Should Not Be Empty  ${FILE_WITH_USERS}
    IF  ${status_file}
        Log  Path to file with users is provided, test should continue![OK]  console=true
    ELSE
        Fail  Please provide path to file with users![NOK]
    END
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"setSSDWifiUser"}}
    ...  input_file=${FILE_WITH_USERS}
    IF  '${requestStatus}' == 'completed' and ${errorCode} == 0
        Log  Command sent with status: ${requestStatus} and error code: ${errorCode}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}![NOK]
    END


Step5: Sending Command GetWifiConnectedClients Via ADMIN CLI
    Log  \nStep5: Sending Command GetWifiConnectedClients Via ADMIN CLI  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getWifiConnectedClients"}}
    IF  '${requestStatus}' == 'completed' and ${errorCode} == 0
        Log  Command sent with status: ${requestStatus} and error code: ${errorCode}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}![NOK]
    END
    Check Users Set After Sending Command  5  ${requestMessage}


Check Default Users
    [Arguments]  ${requestMessage}

    ${status_factorySetUser}  Run Keyword And Return Status  Dictionary Should Contain Key  ${requestMessage}  factorySetUser
    IF  ${status_factorySetUser}
        Check Parameters For Users  ${requestMessage}[factorySetUser]
    ELSE
        Log  No users already logged in!  console=true
    END


Check Parameters For Users
    [Arguments]  ${users_list}

    ${user1}  Create Dictionary  userLabel=wifiuser00a  authType=WPA3-SAE  passphrase=${PASSPHRASE_FIRST_USER}
    ${user2}  Create Dictionary  userLabel=wifiuser01b  authType=WPA2-PSK  passphrase=${PASSPHRASE_SECOND_USER}
    ${user3}  Create Dictionary  userLabel=wifiuser02c  authType=WPA2-PSK  passphrase=${PASSPHRASE_THIRD_USER}
    ${default_users}  Create List  ${user1}  ${user2}  ${user3}
    FOR  ${index}  ${user}  IN ENUMERATE  @{users_list}
        Should Be Equal As Strings  ${user}[userLabel]  ${default_users}[${index}][userLabel]
        Should Be Equal As Strings  ${user}[authType]  ${default_users}[${index}][authType]
        Should Be Equal As Strings  ${user}[passphrase]  ${default_users}[${index}][passphrase]
    END


Check Users Set After Sending Command
    [Arguments]  ${index}  ${requestMessage}

    ${type_users}  Set Variable If  ${index} == 4  configuredUser  wifiConnectedClients
    ${status_dict}  Run Keyword And Return Status  Dictionary Should Contain Key  ${requestMessage}  ${type_users}
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${requestMessage}[${type_users}]
    IF  ${status_dict} and ${status}
        Log  Users:${type_users} appeared in request message.  console=true
    ELSE
        Fail  Users:${type_users} not appeared in request message.
    END


TC Setup
    Common Test Setup  tc_name=WebEM__Remote_Tool_WiFi_management
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    Common Test Teardown
