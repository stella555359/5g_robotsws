*** Settings ***
Documentation
    ...  This TC launch script due to script already ongoing.
    ...  Open Troubleshooting Scripts tab and select Radio Module.
    ...  Verify if the scripts are available.
    ...  Launch in background RU_Common_capture_IQ_data script with all 5G cells.
    ...  While the script is running in background, is launching another script with 5G cells in WebEM.
    ...  Text 'Launching failed, the operation conflicts' should be visible.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__script_launch_failed_due_to_script_already_ongoing
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24453
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24453 - Initial TAT creation
    ...  - 11.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25065 - Adding admin cli command and remove KW from taf

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Open Troubleshooting Scripts Tab For Radio Module
    Step2: Launching Second Script Should Fail Due To Script Already Ongoing


Step1: Open Troubleshooting Scripts Tab For Radio Module
    Log  \nStep1: Open Troubleshooting Scripts tab for Radio Module  console=true
    Open Diagnostic Menu
    Click Element  //*[contains(text(), "Troubleshooting Scripts")]
    Log  Troubleshooting Scripts is open!  console=true
    Log  Waiting for text "Fetching succeeded" to appear!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Element Should Be Visible  //*[contains(text(), 'Fetching succeeded')]
    Run Keyword If  ${status}
    ...  Log  Text "Fetching succeeded" appeared![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Text "Fetching succeeded" is not appeared![NOK]
    Click Element  //*[contains(@class, 'p-radiobutton-box')]
    Sleep  20s  Time for scripts to appear.
    ${scripts_web_elem}  SeleniumLibrary.Get WebElements  //div[@class='p-element script-item ng-star-inserted']
    ${script_count}  Get Length  ${scripts_web_elem}
    Run Keyword If  ${script_count} == 0
    ...  Fail  There is no script available for radio module.
    Set Test Variable  ${SCRIPT_WEB_ELEMENTS}  ${scripts_web_elem}
    FOR  ${script}  IN  @{SCRIPT_WEB_ELEMENTS}
        ${text}  Get Text  ${script}
        Log  Script with name "${text}" is available!  console=true
    END
    Set Test Variable  ${CELLS_BUTTON}  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]


Step2: Launching Second Script Should Fail Due To Script Already Ongoing
    Log  \nStep2: Launching second script should fail due to script already ongoing  console=true
    Change ActCli Parameter  true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${nrbts}  Get Id For Current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts}  NRBTS_R-
    ${nrcel_ids_list}  Create List
    ${nrcel_ids}  Get Ids For All  NRCEL
    FOR  ${index}  IN  @{nrcel_ids}
        ${id}  Fetch From Right  ${index}  NRCELL_R-
        Append To List  ${nrcel_ids_list}  ${id}
    END
    ${all_5_g_cells}  Set Variable
    FOR  ${cell}  IN  @{nrcel_ids_list}
        ${all_5_g_cells}  Catenate  ${all_5_g_cells}  "MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell}",
    END
    ${all_5_g_cells}  Get Substring  ${all_5_g_cells}  0  -1
    ${script_name}  Get Text  ${SCRIPT_WEB_ELEMENTS}[0]
    Log  Launch ${script_name} script with all 5G cells!  console=true
    Click Element  ${SCRIPT_WEB_ELEMENTS}[0]
    Wait Until Element Is Enabled  ${CELLS_BUTTON}  60
    Choose All Specific Cells For Troubleshooting Scripts  NRCELL
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Script '${script_name}' is running from WebEM in background!  console=true
    Sleep  10s  Time for script to start.
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"launchTroubleshootingScript","parameters":{"scriptName":"${script_name}"
    ...  ,"cells":[${all_5_g_cells}]}}}
    Log  Sending command via Admin CLI for ${script_name} with all NR cells...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/${script_name}.json
    Should Contain  ${request_message}  Launching failed, the operation conflicts due to launch script is ongoing
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 69
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    Wait Until Element Is Visible  //div[contains(text(), 'Collection completed')]  600
    Change ActCli Parameter  false


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
