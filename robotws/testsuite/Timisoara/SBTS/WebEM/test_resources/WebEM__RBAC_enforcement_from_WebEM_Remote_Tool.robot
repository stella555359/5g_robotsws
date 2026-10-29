*** Settings ***
Documentation
    ...  This TC execute commands with RBAC account.
    ...  Change parameter actCli to be true.
    ...  Change parameter actDccSupport to be true.
    ...  Activate all accounts.
    ...  Sending three supported commands for BTS Read-Only User.
    ...  Sending three unsupported commands for BTS Read-Only User.
    ...  Sending three supported commands for BTS Application Administrator.
    ...  Sending three unsupported commands for BTS Application Administrator.
    ...  Sending three supported commands for BTS Security Administrator.
    ...  Sending three unsupported commands for BTS Security Administrator.
    ...  Sending three supported commands for BTS Data Collection User.
    ...  Sending three unsupported commands for BTS Data Collection User.
    ...  Deactivate all accounts.
    ...  Change parameter actCli to be false.
    ...  Change parameter actDccSupport to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${READ_ONLY_ALIAS}  readonly  # Username for read only user
${APPLICATION_ALIAS}  application  # Username for application user
${SECURITY_ALIAS}  security  # Username for security user
${PASSWORD}  Nokia02!  # Password for all users without DCC user
${PASSWORD_DCC}  Nokia02!  # Password for DCC user
${TECHNOLOGY}  LTE  # Technology to be blocked
${RECOVERY_TIMEOUT}  900  # Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24448
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24448 - Initial TAT creation
    ...  - 28.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26016 - Adding timeout before dcuser commands
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 05.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27815 - Skip user account state if already active

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Activate All Specific Accounts
    Step2: Supported Commands For BTS Read-Only User
    Step3: Unsupported Commands For BTS Read-Only User
    Step4: Supported Commands For BTS Application Administrator
    Step5: Unsupported Commands For BTS Application Administrator
    Step6: Supported Commands For BTS Security Administrator
    Step7: Unsupported Commands For BTS Security Administrator
    Step8: Supported Commands For BTS Data Collection User
    Step9: Unsupported Commands For BTS Data Collection User


Step1: Activate All Specific Accounts
    Log  \nStep1: Activate all specific accounts  console=true
    Change ActCli Parameter  true
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  actDccSupport  update  true
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter actDccSupport is set to true![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actDccSupport is not set to true![NOK]
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Change Specific Account  BTS Read-Only User  ${READ_ONLY_ALIAS}  ${PASSWORD}  Active
    Change Specific Account  BTS Application Administrator  ${APPLICATION_ALIAS}  ${PASSWORD}  Active
    Change Specific Account  BTS Security Administrator  ${SECURITY_ALIAS}  ${PASSWORD}  Active
    ${button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body/
    ...  wf-tabs/div/wf-pane[1]/div/div/uam-local-tab/form/div[1]/fieldset/div[1]/ui-select/div/wf-dropdown/div/button
    Click Element  ${button}
    Click Element  //*[contains(@data-value, 'BTS Data Collection User')]
    Input Password  //*[@id="uam-local-password"]/div/input  ${PASSWORD}
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  ${PASSWORD}
    Wait Until Element Is Visible  //button[@ui-tooltip='Save']  20
    Click Element  //button[@ui-tooltip='Save']
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Element Is Visible  //*[contains(text(),"Process completed.")]  timeout=300
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step2: Supported Commands For BTS Read-Only User
    Log  \nStep2: Supported commands for BTS Read-Only User  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  ${READ_ONLY_ALIAS}  ${PASSWORD}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getBtsInformation"}}
    Log  \nSending command via Admin CLI for getBtsInformation in read-only user...  console=true
    Sending Allowed Commands  ${request}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getActiveAlarms"}}
    Log  \nSending command via Admin CLI for getActiveAlarms in read-only user...  console=true
    Sending Allowed Commands  ${request}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getRADSWDomains"}}
    Log  \nSending command via Admin CLI for getRADSWDomains in read-only user...  console=true
    Sending Allowed Commands  ${request}


Step3: Unsupported Commands For BTS Read-Only User
    Log  \nStep3: Unsupported commands for BTS Read-Only User  console=true
    ${rmods_id}  Get All RMODs Ids
    ${length}  Get Length  ${rmods_id}
    ${rmod_id}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${rmods_id})  random
    ...  ELSE
    ...  Set Variable  ${rmods_id}[0]
    Set Test Variable  ${RMOD_ID}
    ${request}  Set Variable  {"requestId":23,"parameters":{"name":"unitReset","parameters":{"id":"/MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"}}}
    Log  \nSending command via Admin CLI for unitReset RMOD-${RMOD_ID} in read-only user...  console=true
    Sending Unsupported Commands  ${request}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"collectMirroringLogs"}}
    Log  \nSending command via Admin CLI for collectMirroringLogs in read-only user...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/mirroringLogs.zip
    Run Keyword If
    ...  '${request_status}' == 'failed' and '${request_message}' == 'Operation rejected due to no access permission' and ${error_code} == 171
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"setRADDebugParameters","parameters":{"domain":"OamUri","persistency":
    ...  "Persistent","parameters":[{"name":"PrintCore","value":"true"}]}}}
    Log  \nSending command via Admin CLI for setRADDebugParameters in read-only user...  console=true
    Sending Unsupported Commands  ${request}


Step4: Supported Commands For BTS Application Administrator
    Log  \nStep4: Supported commands for BTS Application Administrator  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  ${APPLICATION_ALIAS}  ${PASSWORD}
    ${request}  Set Variable  {"requestId":23,"parameters":{"name":"unitReset","parameters":{"id":"/MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"}}}
    Log  \nSending command via Admin CLI for unitReset RMOD-${RMOD_ID} in application user...  console=true
    Sending Allowed Commands  ${request}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"blockAllCells","parameters":{"technology":"${TECHNOLOGY}"}}}
    Log  \nSending command via Admin CLI for blockAllCells in application user...  console=true
    Sending Allowed Commands  ${request}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"unblockAllCells","parameters":{"technology":"${TECHNOLOGY}"}}}
    Log  \nSending command via Admin CLI for unblockAllCells in application user...  console=true
    Sending Allowed Commands  ${request}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


Step5: Unsupported Commands For BTS Application Administrator
    Log  \nStep5: Unsupported commands for BTS Application Administrator  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"certRestoreVendor"}}
    Log  \nSending command via Admin CLI for certRestoreVendor in application user...  console=true
    Sending Unsupported Commands  ${request}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"deleteCert","parameters":{"fingerPrint":"16:FC:BC:26:DB:ED:AC:2B:52:
    ...  F3:1A:51:E6:E9:97:3C:E2:72:E8:92", "domainType":"3GPP"}}}
    Log  \nSending command via Admin CLI for deleteCert in application user...  console=true
    Sending Unsupported Commands  ${request}
    ${request}  Catenate  SEPARATOR=  {"requestId":100,"parameters":{"name":"certAutomaticManagement","parameters":{"referenceNumber":"123456",
    ...  "preSharedKey":"123456"}}}
    Log  \nSending command via Admin CLI for certAutomaticManagement in application user...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Sending Unsupported Commands  ${request}


Step6: Supported Commands For BTS Security Administrator
    Log  \nStep6: Supported commands for BTS Security Administrator  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  ${SECURITY_ALIAS}  ${PASSWORD}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getAlarmHistory"}}
    Log  \nSending command via Admin CLI for getAlarmHistory in security user...  console=true
    Sending Allowed Commands  ${request}
    ${request}  Set Variable  {"requestId":11,"requestType":"infoModel","parameters":{"name":"sfpData"}}
    Log  \nSending command via Admin CLI for sfpData in security user...  console=true
    Sending Allowed Commands  ${request}
    ${request}  Catenate  SEPARATOR=  {"requestId":31,"parameters":{"name":"getRmodMeasurementsById","parameters":{"id":"MRBTS-${BTS_ID}/EQM-1
    ...  /APEQM-1/RMOD-${RMOD_ID}"}}}
    Log  \nSending command via Admin CLI for getRmodMeasurementsById in security user...  console=true
    Sending Allowed Commands  ${request}


Step7: Unsupported Commands For BTS Security Administrator
    Log  \nStep7: Unsupported commands for BTS Security Administrator  console=true
    ${lncel_ids}  Get Ids For All  LNCEL
    ${length}  Get Length  ${lncel_ids}
    ${lncel}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${lncel_ids})  random
    ...  ELSE
    ...  Set Variable  ${lncel_ids}[0]
    ${id}  Fetch From Right  ${lncel}  LNCEL_R-
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"setRADDebugParameters","parameters":{"domain":"OamUri","persistency":
    ...  "Persistent","parameters":[{"name":"PrintCore","value":"true"}]}}}
    Log  \nSending command via Admin CLI for setRADDebugParameters in security user...  console=true
    Sending Unsupported Commands  ${request}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"blockCell","parameters":{"id":"MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${id}"}}}
    Log  \nSending command via Admin CLI for blockCell in security user...  console=true
    Sending Unsupported Commands  ${request}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"unblockCell","parameters":{"id":"MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${id}"}}}
    Log  \nSending command via Admin CLI for unblockCell in security user...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Sending Unsupported Commands  ${request}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


Step8: Supported Commands For BTS Data Collection User
    Log  \nStep8: Supported commands for BTS Data Collection User  console=true
    ${path}  Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DCC}  9020
    Set Test Variable  ${PATH}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getBtsInformation"}}
    Log  \nSending command via Admin CLI for getBtsInformation in data collection user...  console=true
    Sending Allowed Commands  ${request}
    Sleep  30s  This sleep is for the connection to end.
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getActiveAlarms"}}
    Log  \nSending command via Admin CLI for getActiveAlarms in data collection user...  console=true
    Sending Allowed Commands  ${request}
    Sleep  30s  This sleep is for the connection to end.
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getInterfaceMirroringStatus"}}
    Log  \nSending command via Admin CLI for getInterfaceMirroringStatus in data collection user...  console=true
    Sending Allowed Commands  ${request}
    Sleep  30s  This sleep is for the connection to end.


Step9: Unsupported Commands For BTS Data Collection User
    Log  \nStep9: Unsupported commands for BTS Data Collection User  console=true
    Log  \nSending command via Admin CLI for getAlarmHistory in data collection user...  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getAlarmHistory"}}
    Sending Unsupported Commands For Dcuser  ${request}
    Sleep  30s  This sleep is for the connection to end.
    Log  \nSending command via Admin CLI for getBtsSyncMode in data collection user...  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getBtsSyncMode"}}
    Sending Unsupported Commands For Dcuser  ${request}
    Sleep  30s  This sleep is for the connection to end.
    Log  \nSending command via Admin CLI for getRadioList in data collection user...  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getRadioList"}}
    Sending Unsupported Commands For Dcuser  ${request}


Deactivate All Specific Accounts
    Log  \nDeactivate all specific accounts  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Change Specific Account  BTS Read-Only User  ${READ_ONLY_ALIAS}  ${PASSWORD}  Inactive
    Change Specific Account  BTS Application Administrator  ${APPLICATION_ALIAS}  ${PASSWORD}  Inactive
    Change Specific Account  BTS Security Administrator  ${SECURITY_ALIAS}  ${PASSWORD}  Inactive
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120
    Change ActCli Parameter  false
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  actDccSupport  update  false
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter actDccSupport is set to false![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actDccSupport is not set to false![NOK]


Change Specific Account
    [Arguments]  ${account_name}  ${alias}  ${password}  ${value}

    ${element}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body/wf-tabs
    ...  /div/wf-pane[1]/div/div/uam-local-tab/form/div[1]/fieldset/div[1]/ui-select/div/wf-dropdown/div/button
    Click Element  ${element}
    Click Element  //*[contains(@data-value, '${account_name}')]
    Input Text  //*[@id="uam-local-alias"]/div/input  ${alias}
    Input Password  //*[@id="uam-local-password"]/div/input  ${password}
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  ${password}
    ${state}  Get Text  //*[@id="uam-local-account-state"]/div/wf-dropdown/div/button/span[1]/span
    Run Keyword If  '${state}' == '${value}'
    ...  Log  Account ${account_name} is already ${value}!  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Click Element  //*[@id="uam-local-account-state"]/div/wf-dropdown/div/button
    ...  AND
    ...  Wait Until Element Is Clicked  //*[contains(@data-value, '${value}')]  120
    Wait Until Element Is Visible  //button[@ui-tooltip='Save']  20
    Click Element  //button[@ui-tooltip='Save']
    Wait Until Element Is Visible  //*[contains(text(),"Process completed.")]  timeout=300
    Log  ${account_name} is ${value} and saved, text 'Process completed' is visible![OK]  console=true


Sending Allowed Commands
    [Arguments]  ${request}

    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}


Sending Unsupported Commands
    [Arguments]  ${request}

    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If
    ...  '${request_status}' == 'failed' and '${request_message}' == 'Operation rejected due to no access permission' and ${error_code} == 171
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}


Sending Unsupported Commands For Dcuser
    [Arguments]  ${req}

    ${request_ddc_user}  Catenate  SEPARATOR=  ${PATH}/admin-cli.sh --bts-username=dcuser --bts-password=${PASSWORD_DCC} --bts-host
    ...  =${MPLANE_IP} --bts-port=9020 --format=human --data='${req}'
    ${rc}  ${output}  OperatingSystem.Run And Return Rc And Output  ${request_ddc_user}
    Should Contain  ${output}  "requestStatus": "failed"
    Should Contain  ${output}  "requestMessage": "Operation rejected due to no access permission"
    Should Contain  ${output}  "errorCode": 171
    Log  Command sent with status: failed, message: Operation rejected due to no access permission and error code: 171  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    WebEM Setup


TC Teardown
    Deactivate All Specific Accounts
    WebEM Teardown
    Common Test Teardown
