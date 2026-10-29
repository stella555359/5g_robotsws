*** Settings ***
Documentation
    ...  This test case checks HW via ADMIN CLI and verify serial number for all alarms.
    ...  actCli parameter is changed to be true.
    ...  Sending command for checkHW via ADMIN CLI.
    ...  Verify for command to be sent with status completed, error code 0 and request message empty.
    ...  Trigger fault 1868 by changing bbmodBoardConfigType parameter for one specific BBMOD.
    ...  Wait until fault id is visible in active alarms.
    ...  Sending command for checkHW via ADMIN CLI.
    ...  Verify for command to be sent with status completed and error code 37.
    ...  Taking from every alarm the specific faultId and serial number via ADMIN CLI.
    ...  Only fault id 1868 must be available in ADMIN CLI response because is supported by checkHW command.
    ...  Taking from every alarm the specific faultId and serial number via WebEM.
    ...  Verify if faults id with proper serial number from ADMIN CLI are the same as those from WebEM.
    ...  Change bbmodBoardConfigType parameter with initial value and verify if the alarm is disappeared.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${BBMOD_ID_FOR_FAULT_1868}  #Mandatory! BBMOD id for changing parameter bbmodBoardConfigType. E.g 4
${NEW_BBMODBOARDCONFIGTYPE_VALUE}  #Mandatory! New value for parameter bbmodBoardConfigType to appear fault 1868.


*** Keywords ***
TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29679
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29679 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS26  FEATURE-CNI-130136

    Step0: TC Preconditions
    Step1: Sending CheckHw Command Via Admin Cli Without Triggering The Specific Supported Fault Id
    Step2: Trigger Fault Id 1868
    Step3: Sending CheckHw Command Via Admin Cli After Specific Supported Fault Id Is Active
    Step4: Get Active Alarms From WebEM And Verify Serial Number To Be The Same


Step0: TC Preconditions
    Should Not Be Empty  ${BBMOD_ID_FOR_FAULT_1868}
    ...  BBMOD id for changing parameter bbmodBoardConfigType must be specified, please provide it and retest.
    Should Not Be Empty  ${NEW_BBMODBOARDCONFIGTYPE_VALUE}
    ...  New value for parameter bbmodBoardConfigType must be specified for alarm to be visible, please provide it and retest.
    ${list}  Create List  bbmodBoardConfigType
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_ID_FOR_FAULT_1868}  ${list}
    ${initial_value}  Set Variable  ${object}[0][parameters][bbmodBoardConfigType]
    Set Test Variable  ${INITIAL_VALUE}


Step1: Sending CheckHw Command Via Admin Cli Without Triggering The Specific Supported Fault Id
    Log  \nStep1: Sending CheckHw Command Via Admin Cli Without Triggering The Specific Supported Fault Id  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"checkHw"}}
    Log  \nSending command via Admin CLI for checkHw  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    ${req_message_status}  Run Keyword And Return Status  Should Be Empty  ${request_message}
    IF  ${req_message_status} and '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status}, error code: ${error_code} and request message empty![OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message: ${request_message}![NOK]
    END


Step2: Trigger Fault Id 1868
    Log  \nStep2: Trigger Fault Id 1868  console=true
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_ID_FOR_FAULT_1868}
    ...  bbmodBoardConfigType  update  ${NEW_BBMODBOARDCONFIGTYPE_VALUE}  skip_parameter_relation_errors=true
    IF  ${status}
        Log  Parameter bbmodBoardConfigType is set to ${NEW_BBMODBOARDCONFIGTYPE_VALUE}![OK]  console=true
    ELSE
        Fail  Parameter bbmodBoardConfigType is not set to ${NEW_BBMODBOARDCONFIGTYPE_VALUE}![NOK]
    END
    ${fault_1868_params}  Get String With Alarm Parameters  ${FAULT_1868_CRITICAL}
    Assert Alarm Active  parameters=${fault_1868_params}  timeout=300
    Log  Fault id 1868 is visible in WebEM!  console=true


Step3: Sending CheckHw Command Via Admin Cli After Specific Supported Fault Id Is Active
    Log  \nStep3: Sending CheckHw Command Via Admin Cli After Specific Supported Fault Id Is Active  console=true
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"checkHw"}}
    Log  \nSending command via Admin CLI for checkHw  console=true
    ${request_status}  ${error_code}  ${REQUEST_MESSAGE}  Admin CLI Send Request  ${request}
    IF  '${request_status}' == 'completed' and ${error_code} == 37
        Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    END
    Set Test Variable  ${REQUEST_MESSAGE}


Step4: Get Active Alarms From WebEM And Verify Serial Number To Be The Same
    Log  \nStep4: Get Active Alarms From WebEM And Verify Serial Number To Be The Same  console=true
    ${fault_sn_webem_dict}  Get Serial Number From All Active Alarms
    FOR  ${fault}  IN  @{REQUEST_MESSAGE}
        ${fault_id}  Get From Dictionary  ${fault}  faultId
        ${fault_id}  Convert To String  ${fault_id}
        Should Be Equal  ${fault_id}  1868
        ${sn_status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${fault}[alarmInformation]  serialNo
        IF  ${sn_status}
            ${sn}  Get From Dictionary  ${fault}[alarmInformation]  serialNo
            Log  In admin cli response is visible fault id:${fault_id} with serial number:${sn}![OK]  console=true
        ELSE
            ${sn}  Set Variable  N/A
            Log  In admin cli response is visible fault id:${fault_id} but without serial number![OK]  console=true
        END
        FOR  ${fault_webem}  ${sn_webem}  IN  &{fault_sn_webem_dict}
            IF  '${fault_id}' == '${fault_webem}' and '${sn}' == '${sn_webem}'
                Log  In WebEM is visible fault id:${fault_id} with serial number:${sn}![OK]  console=true
                BREAK
            ELSE
                CONTINUE
            END
            Fail  In WebEM is not visible fault id:${fault_id} with serial number:${sn}![NOK]
        END
    END


Recovery Action For Fault Id 1868
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_ID_FOR_FAULT_1868}
    ...  bbmodBoardConfigType  update  ${INITIAL_VALUE}  skip_parameter_relation_errors=true
    ${fault_1868_params}  Get String With Alarm Parameters  ${FAULT_1868_CRITICAL}
    Assert Alarm Inactive  parameters=${fault_1868_params}  timeout=300
    Log  Fault id 1868 is not visible anymore in WebEM!  console=true
    Wait Until Keyword Succeeds  600  10
    ...  Check All Cells


TC Setup
    Common Test Setup  tc_name=WebEM__Admin_CLI_alarm_information_in_macro_site_checkHw
    WebEM Setup
    Change ActCli Parameter  true


TC Teardown
    Recovery Action For Fault Id 1868
    Change ActCli Parameter  false
    WebEM Teardown
    Common Test Teardown
