*** Settings ***
Documentation
    ...  This test case gets active alarms via ADMIN CLI and WebEM and verify serial number for all alarms.
    ...  actCli parameter is changed to be true.
    ...  Sending command for getting all alarms from SBTS via ADMIN CLI.
    ...  Verify for command to be sent with status completed and error code 0.
    ...  Taking from every alarm the specific faultId and serial number via ADMIN CLI.
    ...  Taking from every alarm the specific faultId and serial number via WebEM.
    ...  Verify if faults id with proper serial number from ADMIN CLI are the same as those from WebEM.
    ...  Sending command for getting all alarms from SBTS with enhancedOutput on false and true via ADMIN CLI.
    ...  Verify for command to be sent with status completed.
    ...  Taking from every alarm the specific faultId via ADMIN CLI.
    ...  Taking from every alarm the specific faultId via WebEM.
    ...  Verify lists to be equal.
    ...  Test will fail if the lists are not equal.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29678
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29678 - Initial TAT creation
    ...  - 22.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29826 - Adding steps 1, 4 and 5

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS26  FEATURE-CNI-130136

    Step1: Block One NR Cell
    Step2: Get Active Alarms Via ADMIN CLI
    Step3: Get Active Alarms From WebEM And Verify Them
    Step4: Get Active Alarms Via ADMIN CLI With EnhancedOutput On false
    Step5: Get Active Alarms Via ADMIN CLI With EnhancedOutput On true


Step1: Block One NR Cell
    Log  \nStep1: Block One NR Cell  console=true
    Block NR Cell
    Assert Any  NRCEL  blockingState=${BLOCKED}  timeout=150
    Log  NRCEL is blocked!  console=true
    ${fault_49_params}  Get String With Alarm Parameters  ${FAULT_49}
    Assert Alarm Active  parameters=${fault_49_params}  timeout=120
    ${fault_id_webem_list}  Get All Active Alarms
    List Should Contain Value  ${fault_id_webem_list}  ${49}  Fault Id 49 is not visible in WebEM active alarms![NOK]
    Log  Fault Id 49 is visible in WebEM active alarms![OK]  console=true


Step2: Get Active Alarms Via ADMIN CLI
    Log  \nStep2: Get Active Alarms Via ADMIN CLI  console=true
    ${fault_id_admin_cli_list}  Create List
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"getActiveAlarms"}}
    Log  \nSending command via Admin CLI for getActiveAlarms  console=true
    ${request_status}  ${error_code}  ${REQUEST_MESSAGE}  Admin CLI Send Request  ${request}
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    END
    Set Test Variable  ${REQUEST_MESSAGE}


Step3: Get Active Alarms From WebEM And Verify Them
    Log  \nStep3: Get Active Alarms From WebEM And Verify Them  console=true
    ${fault_sn_webem_dict}  Get Serial Number From All Active Alarms
    FOR  ${fault}  IN  @{REQUEST_MESSAGE}
        ${fault_id}  Get From Dictionary  ${fault}  faultId
        ${fault_id}  Convert To String  ${fault_id}
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
            Fail  In WebEM is not visible fault id:${fault_id} with serial number:${sn}![NOK]  console=true
        END
    END


Step${index}: Get Active Alarms Via ADMIN CLI With EnhancedOutput On ${value}
    Log  \nStep${index}: Get Active Alarms Via ADMIN CLI With EnhancedOutput On ${value}  console=true
    ${fault_id_admin_cli_list}  Create List
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"getActiveAlarms","parameters":{"enhancedOutput":${value}}}}
    Log  \nSending command via Admin CLI for getActiveAlarms with enhancedOutput on ${value}  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    IF  '${request_status}' == 'completed'
        Log  Command sent with status: ${request_status}  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}
    END
    IF  '${value}'=='true'
        ${command}  ${request_message_alarms}  Set Variable  Dictionary Should Contain Key  ${request_message}[alarms]
    ELSE
        ${command}  ${request_message_alarms}  Set Variable  List Should Not Contain Value  ${request_message}
    END
    ${status_bts_id}  Run Keyword And Return Status  ${command}  ${request_message}  btsId
    ${status_bts_name}  Run Keyword And Return Status  ${command}  ${request_message}  btsName
    ${status_current_time}  Run Keyword And Return Status  ${command}  ${request_message}  currentTime
    ${status_parameters}  IF  '${value}'=='true'  Check Value Of Parameters  ${request_message}
    IF  '${value}'=='false' and ${status_bts_id} and ${status_bts_name} and ${status_current_time}
        Log  In request message for getActiveAlarms with enhancedOutput on ${value} are no parameters btsId, btsName and currentTime.  console=true
    ELSE IF  '${value}'=='true' and ${status_bts_id} and ${status_bts_name} and ${status_current_time} and ${status_parameters}
        Log  In request message for getActiveAlarms with enhancedOutput on ${value} are parameters btsId, btsName and currentTime.  console=true
    ELSE
        Fail  Request message is unexpected for getActiveAlarms with enhancedOutput on ${value}.
    END
    FOR  ${index}  IN  @{request_message_alarms}
        IF  ${index}[faultId]
            Append To List  ${fault_id_admin_cli_list}  ${index}[faultId]
        ELSE
            CONTINUE
        END
    END
    ${fault_id_webem_list}  Get All Active Alarms
    Sort List  ${fault_id_admin_cli_list}
    Sort List  ${fault_id_webem_list}
    Log  Verify if alarms are the same in Admin CLI and WebEM...  console=true
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${fault_id_admin_cli_list}  ${fault_id_webem_list}
    IF  ${status}
        Log Alarms  ${fault_id_admin_cli_list}
    ELSE
        Fail  Fault Ids from CLI are ${fault_id_admin_cli_list} which are not the same with fault Ids from WebEM ${fault_id_webem_list}
    END


Unblock the cell
    Go To Site View
    ${status}  Run Keyword And Return Status  Assert Any  NRCEL  blockingState=${BLOCKED}  timeout=120
    IF  ${status}  Wait Until Keyword Succeeds  60  10  Unblock NR Cell By ${NR_CELL_XPATH_FOR_BLOCK}
    Wait Until Keyword Succeeds  600  20  Check All Cells
    Log  All cells are onAir!  console=true
    ${fault_id_webem_list}  Get All Active Alarms
    List Should Not Contain Value  ${fault_id_webem_list}  ${49}  Fault Id 49 is still visible in WebEM![NOK]
    Log  Fault Id 49 is not visible in WebEM![OK]  console=true


Check Value Of Parameters
    [Arguments]  ${request_message}

    ${date_time}  Get Current Date  time_zone=UTC
    ${current_date_time}  Convert Date  ${date_time}  result_format=%Y-%m-%d
    ${bts_obj}  Get Parameters For All  BTS
    ${status_bts_id}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${request_message}[btsId]  ${BTS_ID}
    ${status_bts_name}  Run Keyword And Return Status
    ...  Should Be Equal  ${request_message}[btsName]  ${bts_obj[0].btsName}
    ${status_current_time}  Run Keyword And Return Status
    ...  Should Start With  ${request_message}[currentTime]  ${current_date_time}
    IF  ${status_bts_id} and ${status_bts_name} and ${status_current_time}
        RETURN  ${TRUE}
    ELSE
        RETURN  ${FALSE}
    END


Log Alarms
    [Arguments]  ${fault_id_admin_cli_list}

    FOR  ${fault_id}  IN  @{fault_id_admin_cli_list}
        Log  Alarm with faultId ${fault_id} is visible in Admin CLI and WebEM![OK]  console=true
    END


Block NR Cell
    ${cell_xpath}  Evaluate  random.choice(${NR_CELLS_XPATH})  random
    Set Test Variable  ${NR_CELL_XPATH_FOR_BLOCK}  ${cell_xpath}
    Block NR Cell By ${NR_CELL_XPATH_FOR_BLOCK}


${block_unblock} NR Cell By ${cell_xpath}
    Log  ${block_unblock} one NR cell.  console=true
    Click Element  ${cell_xpath}
    Wait Until Element Is Clicked  //*[contains(text(), '${block_unblock}')][contains(text(), 'Cell')]  60
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


TC Setup
    Common Test Setup  tc_name=WebEM__Admin_CLI_macro_site_getActiveAlarms
    WebEM Setup
    Change ActCli Parameter  true


TC Teardown
    Unblock the cell
    Change ActCli Parameter  false
    WebEM Teardown
    Common Test Teardown
