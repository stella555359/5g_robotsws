*** Settings ***
Documentation
    ...  This TC selects Radio Module troubleshooting scripts for many cases.
    ...  Only for SBTS with NR available.
    ...  The first step: Open Troubleshooting Scripts tab and select Radio Module.
    ...  Verify if the scripts are available.
    ...  The second step verify if LTE cells exist because only if LTE cells exist warning will be available.
    ...  If LTE cells exist: Launch all scripts from Radio Module with all cells and save the results in BTSFiles.
    ...  Warning needs to be visible.
    ...  The third step, launch all scripts from Radio Module with all NR cells and save the results in BTSFiles.
    ...  Launching succeeded needs to be visible.
    ...  The fourth step verify if LTE cells exist.
    ...  If LTE exist: Launch all scripts from Radio Module with all LTE cells.
    ...  Error needs to be visible.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${COLLECTING_FILES_TIMEOUT}  600  # Time in seconds for collecting files, default value is 600s.
${MESSAGE_TIMEOUT}  600  # Time for warning or successfull message to be visible.


*** Keywords ***
TC__WebEM__launches_script_with_CELL_list_only
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24451
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24451 - Initial TAT creation
    ...  - 15.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25552 - Adding timer for Click Element

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Open Troubleshooting Scripts Tab For Radio Module
    Step2: Launching Scripts With All Cells
    Step3: Launching Scripts With All 5G Cells
    Step4: Launching Scripts With All 4G Cells


Step1: Open Troubleshooting Scripts Tab For Radio Module
    Log  \nStep1: Open Troubleshooting Scripts tab for Radio Module  console=true
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Log  NR cells exist, scripts should be exist!  console=true
    ...  ELSE
    ...  Fail  NR cells does not exist, the test will be failed because scripts from radio module does not exist!
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
    Run Keyword If  ${script_count}==0
    ...  Fail  There is no script available for radio module.
    Set Test Variable  ${SCRIPT_WEB_ELEMENTS}  ${scripts_web_elem}
    FOR  ${script}  IN  @{SCRIPT_WEB_ELEMENTS}
        ${text}  Get Text  ${script}
        Log  Script with name "${text}" is available!  console=true
    END
    Set Test Variable  ${CELLS_BUTTON}  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]


Step2: Launching Scripts With All Cells
    Log  \nStep2: Launching scripts with all cells  console=true
    Log  This KW should run if LTE cells exist!  console=true
    Run Keyword If  ${SCF_COUNT_LTE}==0
    ...  Return From Keyword
    FOR  ${script}  IN  @{SCRIPT_WEB_ELEMENTS}
        ${script_name}  Get Text  ${script}
        Log  Launch ${script_name} script with all cells!  console=true
        Wait Until Element Is Clicked  ${script}  120
        Wait Until Element Is Enabled  ${CELLS_BUTTON}  60
        Click Element  ${CELLS_BUTTON}
        ${element_status}  Run Keyword And Return Status
        ...  Element Should Be Visible  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
        Run Keyword If  ${element_status}
        ...  Run Keywords
        ...  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
        ...  AND
        ...  Log  All cells has been selected!  console=true
        Click Element  ${CELLS_BUTTON}
        Log  Launch script will be performed!  console=true
        Click Element  //*[contains(@class, 'launch-script')]/p-button/button
        Log  Wait until warning with text 'Launching partially succeeded' appears!  console=true
        ${message_status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  //div[contains(text(), 'Launching partially succeeded')]  ${MESSAGE_TIMEOUT}
        Run Keyword If  ${message_status}
        ...  Log  'Launching partially succeeded' text is visible![OK]  console=true
        ...  ELSE
        ...  Fail  'Launching partially succeeded' text is not visible![NOK]
        Move Results In BTSFiles  ${script_name}  all_cells
    END


Step3: Launching Scripts With All 5G Cells
    Log  \nStep3: Launching scripts with all 5G cells  console=true
    FOR  ${script}  IN  @{SCRIPT_WEB_ELEMENTS}
        ${script_name}  Get Text  ${script}
        Log  Launch ${script_name} script with all 5G cells!  console=true
        Wait Until Element Is Clicked  ${script}  120
        Wait Until Element Is Enabled  ${CELLS_BUTTON}  60
        Choose All Specific Cells For Troubleshooting Scripts  NRCELL
        Click Element  //*[contains(@class, 'launch-script')]/p-button/button
        Log  Wait until text with Launching succeeded appears!  console=true
        ${message_status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  //div[contains(text(), 'Launching succeeded')]  ${MESSAGE_TIMEOUT}
        Run Keyword If  ${message_status}
        ...  Log  'Launching script succeeded' text is visible![OK]  console=true
        ...  ELSE
        ...  Fail  'Launching succeeded' text is not visible![NOK]
        Move Results In BTSFiles  ${script_name}  NRCELL
    END


Step4: Launching Scripts With All 4G Cells
    Log  \nStep4: Launching scripts with all 4G cells  console=true
    Log  This KW should run if LTE cells exist!  console=true
    Run Keyword If  ${SCF_COUNT_LTE}==0
    ...  Return From Keyword
    FOR  ${script}  IN  @{SCRIPT_WEB_ELEMENTS}
        ${script_name}  Get Text  ${script}
        Log  Launch ${script_name} script with all 4G cells!  console=true
        Wait Until Element Is Clicked  ${script}  120
        Wait Until Element Is Enabled  ${CELLS_BUTTON}  60
        Choose All Specific Cells For Troubleshooting Scripts  LNCEL
        Click Element  //*[contains(@class, 'launch-script')]/p-button/button
        Log  Wait until text with Launching failed appears!  console=true
        ${message_status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  //div[contains(text(), 'Launching failed')]  ${MESSAGE_TIMEOUT}
        Run Keyword If  ${message_status}
        ...  Log  'Launching failed' text is visible![OK]  console=true
        ...  ELSE
        ...  Fail  'Launching failed' text is not visible![NOK]
    END


Move Results In BTSFiles
    [Arguments]  ${script}  ${cell}

    Wait Until Created  /home/ute/Downloads/SCRIPT_RESULT_${script}*.zip  ${COLLECTING_FILES_TIMEOUT}
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    Move File  /home/ute/Downloads/SCRIPT_RESULT_${script}*.zip  ${BTS_FILES}/scripts_results/SCRIPT_RESULT_${script}_${current_time}_${cell}.zip
    Log  Script result 'SCRIPT_RESULT_${script}_${current_time}_${cell}' saved in BTSFiles!  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
