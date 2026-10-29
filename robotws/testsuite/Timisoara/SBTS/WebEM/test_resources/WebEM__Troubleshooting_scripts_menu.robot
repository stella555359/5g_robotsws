*** Settings ***
Documentation
    ...  This TC selects all troubleshooting scripts and launches the scripts with different parameters selected and
    ...  the script results are saved in BTSFiles/script_results.
    ...  The parameters selection is the following:
    ...  1. one random cell and the BBMOD on which it is deployed are selected
    ...  2. all cells and the corresponding BBMODs are selected
    ...  If the script needs values for free text, the previous 1. and 2. selections are made for each value.
    ...  Script must be launched successfully for every selection mentioned above.
    ...  Then, 2 cases of not successfully script launching are tested.
    ...  The first one: one random cell and the corresponding BBMOD are selected correctly, but the free text has a wrong value. In
    ...  this case script launching must be failed.
    ...  The second one: one random cell and all BBMODs are selected and script launching should be partially succeeded. In this case
    ...  the script results will be saved even if there are more BBMODs selected then needed.
    ...  Cells and modules on SBTS are not affected during this TC. In the end, they are checked and must be onAir.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Troubleshooting_scripts_menu
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23250
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23250 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 05.10.2013 - https://jiradc.ext.net.nokia.com/browse/TAT-26221 - Increase webEMSessionLogoutTimer and change object with
    ...                                                               Fetching Succeeded text

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Access Troubleshooting Scripts Page
    Step2: Check If Troubleshooting Scripts Are Listed In WebEM
    Step3: Check Description For Every Troubleshooting Script
    Step4: Launch Troubleshooting Scripts And Save Logs


Step1: Access Troubleshooting Scripts Page
    Log  \nStep1: Access troubleshooting scripts page  console=true
    Open Diagnostic Menu
    Click Element  xpath://*[contains(text(), "Troubleshooting Scripts")]
    Log  The page is accessed.  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  webEMSessionLogoutTimer  update  1800
    ...  skip_parameter_relation_errors=true


Step2: Check If Troubleshooting Scripts Are Listed In WebEM
    Log  \nStep2: Check if troubleshooting scripts are listed in WebEM  console=true
    ${script_web_elem}  SeleniumLibrary.Get WebElements  //div[@class='p-element script-item ng-star-inserted']
    ${script_count}  Get Length  ${script_web_elem}
    Run Keyword If  ${script_count} == 0
    ...  Fail  There is no script available for system module.
    Set Test Variable  ${SCRIPT_WEB_ELEMENTS}  ${script_web_elem}
    Log  All available troubleshooting scripts are listed.  console=true


Step3: Check Description For Every Troubleshooting Script
    Log  \nStep3: Check description for every troubleshooting script  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //h1[contains(text(), 'Details')]
    Run Keyword If  ${status}==${FALSE}
    ...  Wait Until Element Is Clicked  //*[contains(@class, 'details-panel-container')]/ui-button/button/i  120
    FOR  ${web_element}  IN  @{SCRIPT_WEB_ELEMENTS}
        Click Element  ${web_element}
        ${script_details_lines}  SeleniumLibrary.Get Element Count  //p-table[@class='p-element details-table']//tr[@class='ng-star-inserted']
        Check Script Details  ${script_details_lines}
    END


Step4: Launch Troubleshooting Scripts And Save Logs
    Log  \nStep4: Launch troubleshooting scripts and save logs  console=true
    FOR  ${script_web_element}  IN  @{SCRIPT_WEB_ELEMENTS}
        Click Element  ${script_web_element}
        Sleep  2s
        ${free_text_values}  Get Values For Free Text
        ${length}  Get Length  ${free_text_values}
        Run Keyword If  ${length}>0
        ...  Add Cells And Bbmods With Free Text And Launch Script  ${free_text_values}  ${script_web_element}
        ...  ELSE
        ...  Add Cells And Bbmods And Launch Script  ${script_web_element}
    END
    Add Wrong Value For Free Text And Launching Script Must Fail
    Add One Cell And All BBMODs And Launching Script Succeeds With Warning
    ${status}  Run Keyword And Return Status
    ...  Check All Cells
    Run Keyword If  ${status}
    ...  Log  SBTS is onAir.  console=true
    ...  ELSE
    ...  Fail  SBTS is not onAir after TC execution.


Check Script Details
    [Arguments]  ${script_details_lines}

    ${details_checked}  Create List
    ${required_script_details}  Create List  name  owner  fixed parameters  description
    FOR  ${index}  IN RANGE  1  ${script_details_lines}+1
        ${parameter_name}  Get Text  //*[contains(@class, 'p-element details-table')]/div/div/table/tbody/tr[${index}]/td[1]
        ${status}  ${parameter}  Check If Parameter Name Contains String  ${parameter_name}  ${required_script_details}
        Run Keyword If  ${status}
        ...  Append To List  ${details_checked}  ${parameter}
        ${value}  Get Text  //*[contains(@class, 'p-element details-table')]/div/div/table/tbody/tr[${index}]/td[2]
        Run Keyword If  '${value}'=='${EMPTY}'
        ...  Fail  ${parameter_name} does not have a value.
    END
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${details_checked}  ${required_script_details}
    Run Keyword If  ${status}
    ...  Log  Script description is listed correctly.  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Remove Values From List  ${required_script_details}  @{details_checked}
    ...  AND
    ...  Set Test Restriction  Not all script details are visible: ${required_script_details} are missing.


Check If Parameter Name Contains String
    [Arguments]  ${parameter_name}  ${required_script_details}

    FOR  ${parameter}  IN  @{required_script_details}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${parameter_name}  ${parameter}
        Run Keyword If  ${status}
        ...  Return From Keyword  ${TRUE}  ${parameter}
    END

    [Return]  ${FALSE}  ${EMPTY}


Get Values For Free Text
    ${free_text_values}  Create List
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //p-table[@class='p-element script-parameters-table']//td[contains(text(), 'No data available')]
    Run Keyword If  ${status}
    ...  Return From Keyword  ${free_text_values}
    ${free_text_names}  SeleniumLibrary.Get WebElements  //p-table[@class='p-element script-parameters-table']//tr[@class='ng-star-inserted']/td[1]
    FOR  ${name}  IN  @{free_text_names}
        ${value}  Get Text  ${name}
        Append To List  ${free_text_values}  ${value}
    END

    [Return]  ${free_text_values}


Add Cells And Bbmods With Free Text And Launch Script
    [Arguments]  ${free_text_values}  ${script_web_element}

    ${length}  Get Length  ${free_text_values}
    FOR  ${value}  IN  @{free_text_values}
        Wait Until Element Is Visible  //textarea[contains(@class, 'p-inputtextarea p-inputtext p-component p-element')]  timeout=20s
        Input Text  //textarea[contains(@class, 'p-inputtextarea p-inputtext p-component p-element')]  ${value}
        Add Cells And Bbmods And Launch Script  ${script_web_element}  ${value}
    END


Add Cells And Bbmods And Launch Script
    [Arguments]  ${script_web_element}  ${free_text}=${EMPTY}

    Log  Launch script for one random cell and save script results.  console=true
    Launch Script For One Random Cell  ${script_web_element}  ${free_text}
    Log  Launch script for all cells and save script results.  console=true
    Launch Script For All Cells  ${script_web_element}  ${free_text}


Launch Script For One Random Cell
    [Arguments]  ${script_web_element}  ${free_text}=${EMPTY}

    ${cell_id}  Click Cell Web Element And Get Random Cell Id
    ${command_bbmod}  Catenate  SEPARATOR=  //*[contains(@class, 'troubleshooting-main-script-parameters-group')]/validation-input-group-container
    ...  /validation-multi-select-group[2]/div/p-multiselect/div/div[2]
    Set Test Variable  ${COMMAND_BBMOD}
    Click Element  ${COMMAND_BBMOD}
    Click BBMOD Elements  ${cell_id}
    Click Element  ${COMMAND_BBMOD}
    Click Launch Button And Move Results  ${script_web_element}  ${cell_id}  ${free_text}


Click Cell Web Element And Get Random Cell Id
    Click Element  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    ${cells_elements}  SeleniumLibrary.Get WebElements  //div[contains(@class, 'p-multiselect-items-wrapper')]//li
    ${cells_ids}  Create List
    FOR  ${cell_element}  IN  @{cells_elements}
        ${cell_id}  SeleniumLibrary.Get Element Attribute  ${cell_element}  aria-label
        ${cell_id}  Get Regexp Matches  ${cell_id}  [A-Z]+-[0-9]+
        Append To List  ${cells_ids}  ${cell_id}[0]
    END
    Set Test Variable  ${CELLS_IDS}

    ${length}  Get Length  ${cells_elements}
    ${index}  Run Keyword If  ${length}>1
    ...  Evaluate  random.randint(0, ${length}-1)  modules=random
    ...  ELSE
    ...  Set Variable  0
    Click Element  ${cells_elements}[${index}]
    Click Element  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]

    [Return]  ${CELLS_IDS}[${index}]


Click Launch Button And Move Results
    [Arguments]  ${script_web_element}  ${cells}  ${free_text}=${EMPTY}

    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until text with Collection completed appears!  console=true
    Wait Until Element Is Visible  //div[contains(text(), "Collection completed")]  300
    Log  'Collection completed' text is visible!  console=true
    Move Script Results In BTSFiles  ${free_text}  ${script_web_element}  ${cells}


Launch Script For All Cells
    [Arguments]  ${script_web_element}  ${free_text}=${EMPTY}

    Select All Elements  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    Click Element  ${COMMAND_BBMOD}
    FOR  ${cell_id}  IN  @{CELLS_IDS}
        Click BBMOD Elements  ${cell_id}
    END
    Click Element  ${COMMAND_BBMOD}
    Click Launch Button And Move Results  ${script_web_element}  allCells  ${free_text}
    Uncheck All Elements  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    Uncheck All Elements  ${COMMAND_BBMOD}


Select All Elements
    [Arguments]  ${dropdown_xpath}

    Wait Until Element Is Visible  ${dropdown_xpath}  20s
    Click Element  ${dropdown_xpath}
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    Run Keyword If  ${status}==${FALSE}
    ...  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Click Element  ${dropdown_xpath}


Click BBMOD Elements
    [Arguments]  ${cell_id}

    ${bbmod_ids}  Get Ids For All  BBMOD
    ${bbmod_r_id}  Get Bbmod Id  ${bbmod_ids}  ${cell_id}
    ${bbmod_elements}  SeleniumLibrary.Get WebElements  //div[contains(@class, 'p-multiselect-items-wrapper')]//li
    FOR  ${bbmod_element}  IN  @{bbmod_elements}
        ${bbmod_dn}  SeleniumLibrary.Get Element Attribute  ${bbmod_element}  aria-label
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${bbmod_dn}  ${bbmod_r_id}
        ${box_checked}  Run Keyword And Return Status
        ...  Element Should Be Visible
        ...  //div[contains(@class, 'p-multiselect-items-wrapper')]//li[@aria-label='${bbmod_dn}']//div[contains(@class, 'p-highlight')]
        Run Keyword If  ${status} and ${box_checked}==${FALSE}
        ...  Click Element  ${bbmod_element}
    END


Uncheck All Elements
    [Arguments]  ${dropdown_xpath}

    Click Element  ${dropdown_xpath}
    Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    Run Keyword If  ${status}
    ...  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Click Element  ${dropdown_xpath}


Get Bbmod Id
    [Arguments]  ${bbmod_ids}  ${cell_id}

    FOR  ${bbmod_id}  IN  @{bbmod_ids}
        ${cells_on_bbmod}  Get_cell_mapping_by_module_id  ${bbmod_id}
        ${cells_ids}  Get Cells Id  ${cells_on_bbmod}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${cells_ids}  ${cell_id}
        Run Keyword If  ${status}
        ...  Exit For Loop
    END
    ${bbmod_r_id}  Fetch From Right  ${bbmod_id}  /

    [Return]  ${bbmod_r_id}


Get Cells Id
    [Arguments]  ${cells_on_bbmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_bbmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    [Return]  ${cells_id}


Add Wrong Value For Free Text And Launching Script Must Fail
    Log  Add wrong value for free text and launching script must fail.  console=true
    FOR  ${script_web_element}  IN  @{SCRIPT_WEB_ELEMENTS}
        Click Element  ${script_web_element}
        Sleep  2s
        ${free_text_values}  Get Values For Free Text
        ${length}  Get Length  ${free_text_values}
        Run Keyword If  ${length}>0
        ...  Exit For Loop
    END
    Uncheck All Elements  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    Uncheck All Elements  ${COMMAND_BBMOD}

    ${cell_id}  Click Cell Web Element And Get Random Cell Id
    Click Element  ${COMMAND_BBMOD}
    Click BBMOD Elements  ${cell_id}
    Click Element  ${COMMAND_BBMOD}
    Input Text  //textarea[contains(@class, 'p-inputtextarea p-inputtext p-component p-element')]  wrong_value

    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible
    ...  //div[contains(text(), 'Launching failed') and contains(text(), 'stderr: ERROR: invalid parameter, please input supported number!')]
    ...  120s
    Run Keyword If  ${status}
    ...  Log  Launching failed with error message: ERROR: invalid parameter, please input supported number!  console=true
    ...  ELSE
    ...  Fail  Script launching ERROR message did not appear.


Add One Cell And All BBMODs And Launching Script Succeeds With Warning
    Log  Add one cell and all BBMODs and launching script succeeds with warning.  console=true
    ${length}  Get Length  ${SCRIPT_WEB_ELEMENTS}
    ${index}  Run Keyword If  ${length}>1
    ...  Evaluate  random.randint(0, ${length}-1)  modules=random
    ...  ELSE
    ...  Set Variable  0
    ${script_web_element}  Set Variable  ${SCRIPT_WEB_ELEMENTS}[${index}]

    Click Element  ${script_web_element}
    Uncheck All Elements  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    Uncheck All Elements  ${COMMAND_BBMOD}

    ${free_text_values}  Get Values For Free Text
    ${length}  Get Length  ${free_text_values}
    ${free_text}  Run Keyword If  ${length}>0
    ...  Set Variable  ${free_text_values}[0]
    ...  ELSE
    ...  Set Variable  ${EMPTY}
    Run Keyword If  '${free_text}'!='${EMPTY}'
    ...  Input Text  //textarea[contains(@class, 'p-inputtextarea p-inputtext p-component p-element')]  ${free_text}

    ${cell_id}  Click Cell Web Element And Get Random Cell Id
    Select All Elements  ${COMMAND_BBMOD}
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //div[contains(text(), 'Launching partially succeeded')]  120s
    Run Keyword If  ${status}
    ...  Log  Warning is visible: Launching partially succeeded.  console=true
    ...  ELSE
    ...  Fail  Script launching Warning message did not appear.
    Move Script Results In BTSFiles  ${free_text}  ${script_web_element}  ${cell_id}


Move Script Results In BTSFiles
    [Arguments]  ${free_text}  ${script_web_element}  ${cells}

    ${free_text_for_zip_file}  Set Variable If  '${free_text}'=='${EMPTY}'  ${EMPTY}  _freeText-${free_text}
    ${script_name}  Get Text  ${script_web_element}
    Wait Until Created  /home/ute/Downloads/SCRIPT_RESULT_${script_name}*.zip  timeout=3min
    Move File  /home/ute/Downloads/SCRIPT_RESULT_${script_name}*.zip
    ...  ${BTS_FILES}/scripts_results/SCRIPT_RESULT_${script_name}_${cells}${free_text_for_zip_file}.zip
    ${free_text_output}  Set Variable If  '${free_text}'=='${EMPTY}'  ${EMPTY}  with freeText=${free_text}
    Log  Script ${script_name} results is saved for ${cells} ${free_text_output}.  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  webEMSessionLogoutTimer  update  900  skip_parameter_relation_errors=true
    Common Test Teardown
