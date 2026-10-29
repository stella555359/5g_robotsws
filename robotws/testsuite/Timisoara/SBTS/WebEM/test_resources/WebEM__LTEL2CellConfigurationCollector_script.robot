*** Settings ***
Documentation
    ...  This TC selects l2_lte_col_cell troubleshooting script for many cases.
    ...  The first step verify if LTE cells exist because only if LTE cells exist the script l2_lte_col_cell is available.
    ...  Open Troubleshooting Scripts tab and select l2_lte_col_cell script.
    ...  First case: Launch the script with a random cell and save the results in BTSFiles. Launching succeeded needs to be visible.
    ...  The first case is running for 3 times.
    ...  Second case: Launch the script with a random cell and the related BBMOD and save the results in BTSFiles.
    ...  Launching succeeded needs to be visible.
    ...  Third case: Launch the script with a random bbmod and save the results in BTSFiles. Launching succeeded needs to be visible.
    ...  Fourth case: Launch the script with all cells and save the results in BTSFiles. Warning needs to be visible.
    ...  Fifth case: Launch the script with a random cell and the related BBMOD but with a text in Input Text. Error needs to be visible.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${COLLECTING_FILES_TIMEOUT}  600  # Time in seconds for collecting files.


*** Keywords ***
TC__WebEM__LTEL2CellConfigurationCollector_script
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23249
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23249 - Initial TAT creation
    ...  - 08.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23666 - Add check if BBMODs exist
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25553 - Adding timer for Click Element
    ...  - 20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30029 - Adding timer for Click Element and fixing xpath

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify If LTE Cells Exist And Open Troubleshooting Scripts Tab
    Step2: Launch LTE Troubleshooting Script For One Cell
    Step3: Launch LTE Troubleshooting Script For One Cell
    Step4: Launch LTE Troubleshooting Script For One Cell
    Step5: Launch LTE Troubleshooting Script For One Bbmod And One Cell
    Step6: Launch LTE Troubleshooting Script For One Bbmod
    Step7: Launch LTE Troubleshooting Script For All Cells
    Step8: Launch LTE Troubleshooting Script With Text


Step1: Verify If LTE Cells Exist And Open Troubleshooting Scripts Tab
    Log  Step1: Verify if LTE cells exist and open Troubleshooting Scripts tab  console=true
    Log  Verify if LTE cells exists  console=true
    IF  ${SCF_COUNT_LTE}
        Log  LTE cells exist!  console=true
    ELSE
        Fail  LTE cells does not exist, the test will be failed because script l2_lte_col_cell does not exist!
    END
    ${nr_iot_cells}  SeleniumLibrary.Get Element Count  xpath=//*[@id='guardband']
    Set Test Variable  ${NR_IOT_CELLS}
    Log  Open Troubleshooting Scripts tab  console=true
    Open Diagnostic Menu
    Click Element  //*[contains(text(), "Troubleshooting Scripts")]
    Log  Troubleshooting Scripts is open!  console=true
    Log  Waiting for text "Fetching succeeded" to appear!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  300  5
    ...  Element Should Be Visible  //*[contains(text(), 'Fetching succeeded')]
    IF  ${status}
        Log  Text "Fetching succeeded" appeard![OK]  console=true
    ELSE
        Set Test Restriction  Text "Fetching succeeded" is not appeard![NOK]
    END
    Click Element  xpath=//*[contains(@aria-label, 'l2_lte_col_cell')]
    Set Test Variable  ${COMMAND_CELL}  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]
    ${command_bbmod}  Catenate  SEPARATOR=  //*[contains(@class, 'troubleshooting-main-script-parameters-group')]/validation-input-group-container
    ...  /validation-multi-select-group[2]/div/p-multiselect/div/div[2]
    Set Test Variable  ${COMMAND_BBMOD}


Step${index}: Launch LTE Troubleshooting Script For One Cell
    Log  Step${index}: Launch LTE troubleshooting script for one cell  console=true
    ${cell_id}  Choose And Click A Random Cell
    Log  Launch script will be performed!  console=true
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until text with Launching succeeded appears!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(text(), 'Launching succeeded')]  600
    IF  ${status}
        Log  'Launching script succeeded' text is visible![OK]  console=true
    ELSE
        Fail  'Launching succeeded' text is not visible![NOK]
    END
    Move Script Results In BTSFiles  cell=${cell_id}
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    Wait Until Element Is Clicked  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]  60
    ${status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    IF  ${status}  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60


Step5: Launch LTE Troubleshooting Script For One Bbmod And One Cell
    Log  Step5: Launch LTE troubleshooting script for one bbmod and one cell  console=true
    ${bbmod_ids}  Get Ids For All  BBMOD
    ${bbmod_exists}  Run Keyword And Return Status  Should Not Be Empty  ${bbmod_ids}
    Set Test Variable  ${BBMOD_EXISTS}
    IF  ${BBMOD_EXISTS}==${FALSE}
        Log  This step will be skipped.  console=true
        RETURN
    END
    ${cell_id}  Choose And Click A Random Cell
    Click Element  ${COMMAND_BBMOD}
    ${bbmod_r_id}  Get And Click The Specific BBMOD  ${cell_id}
    Click Element  ${COMMAND_BBMOD}
    Log  Launch script will be performed!  console=true
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until text with Launching succeeded appears!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(text(), 'Launching succeeded')]  600
    IF  ${status}
        Log  'Launching script succeeded' text is visible![OK]  console=true
    ELSE
        Fail  'Launching succeeded' text is not visible![NOK]
    END
    Move Script Results In BTSFiles  cell=${cell_id}  bbmod=${bbmod_r_id}
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    Wait Until Element Is Clicked  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]  60
    ${status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    IF  ${status}  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60
    Wait Until Element Is Clicked  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]  60
    ${status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    IF  ${status}  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60


Step6: Launch LTE Troubleshooting Script For One Bbmod
    Log  Step6: Launch LTE troubleshooting script for one bbmod  console=true
    IF  ${BBMOD_EXISTS}==${FALSE}
        Log  This step will be skipped.  console=true
        RETURN
    END
    ${bbmod_id}  Choose And Click A Random BBMOD
    Log  Launch script will be performed!  console=true
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until text with Launching succeeded appears!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(text(), 'Launching succeeded')]  600
    IF  ${status}
        Log  'Launching script succeeded' text is visible![OK]  console=true
    ELSE
        Fail  'Launching succeeded' text is not visible![NOK]
    END
    Move Script Results In BTSFiles  bbmod=${bbmod_id}
    Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60
    Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    ${status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box') and contains(@class, 'p-highlight')]
    IF  ${status}  Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60


Step7: Launch LTE Troubleshooting Script For All Cells
    Log  Step7: Launch LTE troubleshooting script for all cells  console=true
    Wait Until Element Is Enabled  ${COMMAND_CELL}  60
    Click Element  ${COMMAND_CELL}
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
    IF  ${status}
        Click Element  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]
        Log  All cells has been selected!  console=true
    END
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    Log  Launch script will be performed!  console=true
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until warning with text 'Launching partially succeeded' appears!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(text(), 'Launching partially succeeded')]  600
    IF  ${status}
        Log  'Launching partially succeeded' text is visible![OK]  console=true
    ELSE
        Fail  'Launching partially succeeded' text is not visible![NOK]
    END
    Move Script Results In BTSFiles  cell=all_cells
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    Wait Until Element Is Clicked  //div[contains(@class, 'p-multiselect-header')]//div[contains(@class, 'p-checkbox-box')]  60
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60


Step8: Launch LTE Troubleshooting Script With Text
    Log  Step8: Launch LTE troubleshooting script with text  console=true
    ${cell_id}  Choose And Click A Random Cell
    IF  ${BBMOD_EXISTS}
        Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60
        Get And Click The Specific BBMOD  ${cell_id}
        Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60
    END
    Input Text  //textarea[@class='p-inputtextarea p-inputtext p-component p-element']  text
    Log  Launch script will be performed!  console=true
    ${status}  Run Keyword And Return Status  Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    IF  ${status}
        Log  Launching started!  console=true
    ELSE
        Fail  Script did not launch!
    END
    Log  Wait until error with text 'Launching failed' appears!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(text(), 'Launching failed')]  600
    IF  ${status}
        Log  'Launching failed' text is visible![OK]  console=true
    ELSE
        Fail  'Launching failed' text is not visible![NOK]
    END


Choose And Click A Random Cell
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60
    ${DIV_NUMBER}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Set Test Variable  ${DIV_NUMBER}
    ${number_of_cells}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[${DIV_NUMBER}]/div[2]/ul/p-multiselectitem
    ${lte_cells_ids}  Create List
    FOR  ${cell}  IN RANGE  1  ${number_of_cells}+1
        ${cell_id}  Get Text  xpath:/html/body/div[${DIV_NUMBER}]/div[2]/ul/p-multiselectitem[${cell}]
        ${status_cell_name}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL-*
        IF  ${status_cell_name}  Append To List  ${lte_cells_ids}  ${cell_id}
    END
    IF  ${NR_IOT_CELLS}  Remove IoT Cells From The List  ${lte_cells_ids}
    ${cell_id}  Evaluate  random.choice(${lte_cells_ids})  random
    Log  Cell ${cell_id} will be choose!  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "${cell_id}")]  60
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60

    RETURN  ${cell_id}


Choose And Click A Random BBMOD
    Wait Until Element Is Clicked  ${COMMAND_BBMOD}  60
    ${number_of_bbmods}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[${DIV_NUMBER}]/div[2]/ul/p-multiselectitem
    ${bbmods}  Create List
    FOR  ${bbmod}  IN RANGE  1  ${number_of_bbmods}+1
        ${bbmod_id}  Get Text  xpath:/html/body/div[${DIV_NUMBER}]/div[2]/ul/p-multiselectitem[${bbmod}]
        Append To List  ${bbmods}  ${bbmod_id}
    END
    ${bbmod_id}  Evaluate  random.choice(${bbmods})  random
    Log  ${bbmod_id} will be choose!  console=true
    Wait Until Element Is Clicked  //*[contains(text(), "${bbmod_id}")]  60
    Wait Until Element Is Clicked  ${COMMAND_CELL}  60

    RETURN  ${bbmod_id}


Remove IoT Cells From The List
    [Arguments]  ${lte_cells_ids}

    ${values}  Get Slice From List  ${lte_cells_ids}  -${NR_IOT_CELLS}
    Remove Values From List  ${lte_cells_ids}  @{values}


Get And Click The Specific BBMOD
    [Arguments]  ${cell_id}

    ${bbmod_ids}  Get Ids For All  BBMOD
    ${bbmod_r_id}  Get Bbmod Id  ${bbmod_ids}  ${cell_id}
    ${bbmod_elements}  SeleniumLibrary.Get WebElements  //div[contains(@class, 'p-multiselect-items-wrapper')]//li
    FOR  ${bbmod_element}  IN  @{bbmod_elements}
        ${bbmod_dn}  SeleniumLibrary.Get Element Attribute  ${bbmod_element}  aria-label
        ${status}  Run Keyword And Return Status  Should Contain  ${bbmod_dn}  ${bbmod_r_id}
        ${box_checked}  Run Keyword And Return Status  Element Should Be Visible
        ...  //div[contains(@class, 'p-multiselect-items-wrapper')]//li[@aria-label='${bbmod_dn}']//div[contains(@class, 'p-highlight')]
        IF  ${status} and ${box_checked}==${FALSE}
            Log  ${bbmod_r_id} will be choose!  console=true
            Click Element  ${bbmod_element}
        END
    END

    RETURN  ${bbmod_r_id}


Get Bbmod Id
    [Arguments]  ${bbmod_ids}  ${cell_id}

    FOR  ${bbmod_id}  IN  @{bbmod_ids}
        ${cells_on_bbmod}  Get_cell_mapping_by_module_id  ${bbmod_id}
        ${cells_ids}  Get Cells Id  ${cells_on_bbmod}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${cells_ids}  ${cell_id}
        IF  ${status}  BREAK
    END
    ${bbmod_r_id}  Fetch From Right  ${bbmod_id}  /

    RETURN  ${bbmod_r_id}


Get Cells Id
    [Arguments]  ${cells_on_bbmod}

    ${cells_id}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_bbmod}
        ${last_part}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${last_part}  _R
        Append To List  ${cells_id}  ${cell_id}
    END

    RETURN  ${cells_id}


Move Script Results In BTSFiles
    [Arguments]  ${cell}=${EMPTY}  ${bbmod}=${EMPTY}

    ${file_name}  Catenate  SEPARATOR=_  ${cell}  ${bbmod}
    Wait Until Created  /home/ute/Downloads/SCRIPT_RESULT_l2_lte_col_cell*.zip  ${COLLECTING_FILES_TIMEOUT}
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    Move File  /home/ute/Downloads/SCRIPT_RESULT_l2_lte_col_cell*.zip
    ...  ${BTS_FILES}/scripts_results/SCRIPT_RESULT_l2_lte_col_cell_${current_time}_${file_name}.zip
    Log  Script result 'SCRIPT_RESULT_l2_lte_col_cell_${current_time}_${file_name}' saved in BTSFiles!  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__LTEL2CellConfigurationCollector_script
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
