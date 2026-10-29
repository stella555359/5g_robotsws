*** Settings ***
Documentation
...  This TC is created to verify WebEM behaviour when blocking, unblocking and changing cell name.
...  First, cell is blocked, fault 49 must be generated.
...  Cell name is modified by creating BTS EM delta plan.
...  Alarm fields are checked in Active Alarms list and also alarming object must contain the cell name modification.
...  Active Alarms list is also saved in a csv file and it's fields must be checked.
...  Same steps are done with Historical Alarms after unblocking the cell.
...  Last steps are used to verify cell name in Performance View.
...  After chosing randomly a NRCELL counter, it's path must be checked to contain the cell name modification.
...  The check must be done in table view and plot view.
...  Also a csv PM counters file and a png file are saved and checked.
...  Lastly, cell name is modified back to initial value.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${ALARM_ID}  7102
${ALARM_NAME}  BASE STATION RESOURCE BLOCKED BY USER
${FAULT_ID}  49
${FAULT_NAME}  Cell blocked
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__configurable_identifiers_in_WebEM_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25056
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  27.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25056 - Initial TAT creation
    ...  17.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28236 - Fix cell name value
    ...  18.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28248 - Fix vdu instance id and counters xpath
    ...  04.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28700 - Fix sw release variable
    ...  11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28709 - Saving method in PE fixed and RF5.0 KWs replacement
    ...  07.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28950 - Xpath changed for cellName in trunk only
    ...  05.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29148 - Xpath changed for table row in trunk only
    ...  ******************

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB009275

    Step 0: TC Preconditions
    Step 1: Block Cell
    Step 2: Configure Cell Name
    Step 3: Check Active Alarms View
    Step 4: Select Active Alarm And Check Details
    Step 5: Save And Check Active Alarms List
    Step 6: Unblock Cell
    Step 7: Check Historical Alarms View
    Step 8: Select Historical Alarm And Check Details
    Step 9: Save And Check Historical Alarms List
    Step 10: Select NRCELL Counter In Performance View
    Step 11: Check Selected Counter In Performance View - Table View
    Step 12: Save Counters List And Check File Content - Table View
    Step 13: Check Selected Counter In Performance View - Plot View
    Step 14: Save Counters List - Plot View


Step 0: TC Preconditions
    Log  Step 0: TC Preconditions  console=true
    ${vdu_cells_status}  Get Vdu Cells Status
    ${cell_dn}  Set Variable  ${vdu_cells_status}[0][dist_names][config]
    ${cell_id}  Fetch From Right  ${cell_dn}  -
    ${test_start_date_time}  Get Current Date  UTC  exclude_millis=True
    ${current_date_time}  Convert Date  ${test_start_date_time}  date_format=%Y-%m-%d %H:%M:%S  result_format=%d.%m.%Y %H:%M:%S
    ${current_date}  Fetch From Left  ${test_start_date_time}  ${SPACE}
    ${current_date_csv_format}  Remove String Using Regexp  ${current_date}  -
    ${test_start_time_csv_format}  Fetch From Right  ${test_start_date_time}  ${SPACE}
    ${test_start_time_csv_format}  Split String From Right  ${test_start_time_csv_format}  :  1
    ${test_start_time_csv_format}  Remove String Using Regexp  ${test_start_time_csv_format}[0]  :
    Set Test Variable  ${CELL_DN}
    Set Test Variable  ${CELL_ID}
    Set Test Variable  ${CURRENT_DATE_TIME}
    Set Test Variable  ${CURRENT_DATE_CSV_FORMAT}
    Set Test Variable  ${TEST_START_TIME_CSV_FORMAT}


Step 1: Block Cell
    Log  \nStep 1: Block cell.  console=true
    Click Element  //div[contains(text(), "Total Cells")]
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-icon mdi mdi-dots-vertical')]  10  2
    Wait Until Element Is Clicked  //*[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Block Cell')]  90  10
    Wait Until Element Is Clicked  //*[contains(@class, 'p-confirm-dialog-accept')]  90  10


Step 2: Configure Cell Name
    Log  \nStep 2: Configure cell name  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  120
    Sleep  15s  This sleep is for plan to be updated!
    IF  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF25R2'
        Page Should Contain  CURRENT_PLAN
        Create Delta Plan For CBTS
        Input Text  //*[@id="parameter-search-input"]/div/input  cellName
        Click Element  //*[@id="parameter-search-input"]/div/div/i
        Wait Until Keyword Succeeds  10s  2s
        ...  Element Text Should Be  //*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr/td[2]/div/div[2]  ${CELL_DN}
    ELSE IF  '${VDU_ACTIVE_SW_RELEASE}' == 'vDUCNF25R2'
        Page Should Contain  Current Plan
        Wait Until Keyword Succeeds  30  5
        ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  cellName
        Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
        Sleep  5s  Time for page to be loaded.
        Wait Until Keyword Succeeds  30s  5s
        ...  Element Text Should Be  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[2]/div/div/div[2]  ${CELL_DN}
    ELSE
        Page Should Contain  Current Plan
        Wait Until Keyword Succeeds  30  5
        ...  Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  cellName
        Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
        Sleep  5s  Time for page to be loaded.
        Wait Until Keyword Succeeds  30s  5s
        ...  Element Text Should Be  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[2]/div/div/div/div[2]  ${CELL_DN}
    END
    ${slot_input_locator}  Catenate  SEPARATOR=  //*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody
    ...  /tr/td[4]/div/span/configuration-shared-input/div/span[1]/input
    ${slot_input_locator_unified}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[4]/cem-parameter-input/
    ...  cem-string-input/ot-field/div/input
    ${input_locator}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' >= 'vDUCNF25R2'  ${slot_input_locator_unified}  ${slot_input_locator}
    Input Text  ${input_locator}  test
    IF  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF25R2'
        Click Element  //*[@id="global-search-table"]/div[1]/div
        Sleep  5s  This sleep is for "Validate Plan" and "Activate Plan" buttons to be accessible.
        Validate And Activate Plan For CBTS
    ELSE
        Click Element  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]
        Click Element  //*[contains(@class, 'p-element p-button-neutral first-letter-underlined p-button p-component ng-star-inserted')]
        Sleep  5s  This sleep is for "Validate Plan" and "Activate Plan" buttons to be accessible.
        Validate And Activate Current Plan For Unified CBTS
    END


Step 3: Check Active Alarms View
    Log  \nStep 3: Check Active Alarms view.  console=true
    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Wait Until Keyword Succeeds  180s  10s
    ...  Verify Alarm Fields In Active Alarms List  ${CURRENT_DATE_TIME}  ${ALARM_ID}  ${ALARM_NAME}  ${FAULT_ID}  ${FAULT_NAME}  [test] ${CELL_DN}
    Log  Alarm with fault id: ${FAULT_ID} and fault name: ${FAULT_NAME} is active in WebEM. [OK]  console=true


Step 4: Select Active Alarm And Check Details
    Log  \nStep 4: Select active alarm and check details.  console=true
    Wait Until Element Is Clicked  //td[contains(text(),"[test] ${CELL_DN}")]  60
    Wait Until Element Is Clicked  //*[@id="open-detail-panel-button"]/span[1]  60
    Sleep  2s  This sleep is for "Details" page to be uploaded.
    ${alarming_object}  Get Text  //*[@id="undefined-table"]/ui-webem-detail-data-row[8]/div/div[2]/span
    Should Be Equal As Strings  ${alarming_object}  [test] ${CELL_DN}  Alarming object doesn't contain modified dist name: [test] ${CELL_DN}. [NOK]
    Log  Alarming object contains modified dist name: [test] ${CELL_DN}. [OK]  console=true


Step 5: Save And Check Active Alarms List
    Log  \nStep 5: Save and check active alarms list.  console=true
    Click Element  //*[contains(text(),"Save Alarms List")]
    Wait Until Keyword Succeeds  60s  5s
    ...  Find Last File Downloaded  MRBTS  .csv  ${CURRENT_DATE_CSV_FORMAT}  ${TEST_START_TIME_CSV_FORMAT}  currentAlarms
    Verify Active Alarms Csv File Content  ${FILE_PATH}  ${CURRENT_DATE_TIME}  ${ALARM_ID}  ${ALARM_NAME}  ${FAULT_ID}  ${FAULT_NAME}
    ...  [test] ${CELL_DN}
    Log  All fields in Active Alarms csv file are set correctly. [OK]  console=true


Step 6: Unblock Cell
    Log  \nStep 6: Unblock cell.  console=true
    Click Element  ${VDU_DASHBOARD}
    Wait Until Element Is Clicked  //div[contains(text(), "Total Cells")]  10  2
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-icon mdi mdi-dots-vertical')]  10  2
    Wait Until Element Is Clicked  //*[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Unblock Cell')]  90  10
    Wait Until Element Is Clicked  //*[contains(@class, 'p-confirm-dialog-accept')]  90  10

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}


Step 7: Check Historical Alarms View
    Log  \nStep 7: Check Historical Alarms view.  console=true
    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Wait Until Element Is Clicked  //*[@id="/alarm/historical"]/span  10  2
    Wait Until Element Is Clicked  //*[@id="appeared-header"]  10  2
    ${aria_sort}  Get Element Attribute  //*[@id="appeared-header"]  aria-sort
    Should Be Equal As Strings  ${aria_sort}  descending  Alarms are not sorted in descending order, after click on "Appeared GMT+0000" header. [NOK]
    Sleep  5s  Wait for list to be updated.
    ${historical_alarm_locator}  Verify Alarm Fields In Historical Alarms List  ${CURRENT_DATE_TIME}  ${ALARM_ID}  ${ALARM_NAME}  ${FAULT_ID}
    ...  ${FAULT_NAME}  [test] ${CELL_DN}
    Set Test Variable  ${HISTORICAL_ALARM_LOCATOR}
    Log  Alarm with fault id: ${FAULT_ID} and fault name: ${FAULT_NAME} founded in Historical Alarms list. [OK]  console=true


Step 8: Select Historical Alarm And Check Details
    Log  \nStep 8: Select historical alarm and check details.  console=true
    Click Element  ${HISTORICAL_ALARM_LOCATOR}
    Click Element  //*[@id="open-detail-panel-button"]/span[1]
    Sleep  2s  This sleep is for "Details" page to be uploaded.
    ${alarming_object}  Get Text  //*[@id="undefined-table"]/ui-webem-detail-data-row[9]/div/div[2]/span
    Should Be Equal As Strings  ${alarming_object}  [test] ${CELL_DN}  Alarming object doesn't contain modified dist name: [test] ${CELL_DN}. [NOK]
    Log  Alarming object contains modified dist name: [test] ${CELL_DN}. [OK]  console=true


Step 9: Save And Check Historical Alarms List
    Log  \nStep 9: Save and check historical alarms list.  console=true
    Click Element  //*[contains(text(),"Save Alarms List")]
    Wait Until Keyword Succeeds  60s  5s
    ...  Find Last File Downloaded  MRBTS  .csv  ${CURRENT_DATE_CSV_FORMAT}  ${TEST_START_TIME_CSV_FORMAT}  historicalAlarms
    Verify Historical Alarms Csv File Content  ${FILE_PATH}  ${CURRENT_DATE_TIME}  ${ALARM_ID}  ${ALARM_NAME}  ${FAULT_ID}  ${FAULT_NAME}
    ...  [test] ${CELL_DN}
    Log  All fields in Historical Alarms file are set correctly. [OK]  console=true


Step 10: Select NRCELL Counter In Performance View
    Log  \nStep 10: Select NRCELL counter in Performance view.  console=true
    Click Element  ${VDU_PERFORMANCE}
    Wait Until Element Is Clicked  //*[contains(@class,'mdi mdi-format-list-checks p-button-icon p-button-icon-left ng-star-inserted')]  10  2
    Wait Until Element Is Clicked  //span[contains(text(),'NRCELL')]  10  2
    Wait Until Element Is Clicked  //*[contains(text(),'NR Cell Availability (NCAV)')]  10  2
    Sleep  10s  Time for counters to be visible
    ${counters_locator}  Catenate  SEPARATOR=  xpath:/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[1]
    ...  /div/div[1]/div[2]/ui-webem-panel-split/as-split/div[2]/div/oam-select-counter-column/div/div[2]/tree-root/tree-viewport
    ...  /div/div/tree-node-collection/div/tree-node[2]/div/tree-node-children/div/tree-node-collection/div/tree-node[5]/div
    ...  /tree-node-children/div/tree-node-collection/div/tree-node
    ${counters_no}  SeleniumLibrary.Get Element Count  ${counters_locator}
    ${counters_names}  Create List
    FOR  ${id}  IN RANGE  1  ${counters_no}+1
        ${counter_locator}  Catenate  SEPARATOR=  xpath:/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[1]/div/div[1]/div[2]
        ...  /ui-webem-panel-split/as-split/div[2]/div/oam-select-counter-column/div/div[2]/tree-root/tree-viewport/div/div/tree-node-collection
        ...  /div/tree-node[2]/div/tree-node-children/div/tree-node-collection/div/tree-node[5]/div/tree-node-children/div/tree-node-collection
        ...  /div/tree-node[${id}]/div/tree-node-wrapper/div/div/div[2]/tree-node-content/span
        ${counter_name}  Get Text  ${counter_locator}
        Append To List  ${counters_names}  ${counter_name}
    END
    Should Not Be Empty  ${counters_names}  Counters list is empty. [NOK]
    ${chosen_counter}  Evaluate  random.choice(${counters_names})  random
    Click Element  //*[contains(text(),'${chosen_counter}')]
    Wait Until Element Is Clicked  //*[contains(text(),'NRCELL-${CELL_ID}')]  20  2
    ${selected_counter_locator}  Catenate  xpath:/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[1]/div/div[2]/div[2]/div[2]
    ...  /oam-pm-counters-modal-selected-counters-column/oam-pm-counters-modal-counters-group-list/div/div/p-chips/div/ul/li[1]/span[1]
    ${nr_cell_text}  Get Text  ${selected_counter_locator}
    Should Contain  ${nr_cell_text}  test  NRCELL doesn't contain [test] in it's notation. [NOK]
    Click Element  xpath:/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[2]/p-footer/ui-webem-button[1]/p-button/button/span


Step 11: Check Selected Counter In Performance View - Table View
    Log  \nStep 11: Check selected counter in Performance view - table view.  console=true
    Sleep  3s  This sleep is for "Selected Counters" page to be uploaded.
    ${rows_no}  SeleniumLibrary.Get Element Count  //*[@id="pmTable"]/div/div/table/tbody[1]/tr
    FOR  ${id}  IN RANGE  1  ${rows_no}+1
        IF  '${VDU_ACTIVE_SW_RELEASE}' >= 'vDUCNF25R3'
            ${cell_dist_name}  Get Text  //*[@id="pmTable"]/div/div/table/tbody[1]/tr/td[${id}]
        ELSE
            ${cell_dist_name}  Get Text  //*[@id="pmTable"]/div/div/table/tbody[1]/tr/td[${id}]/b
        END
        ${dist_name_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell_dist_name}  [test]
        ${match}  Set Variable If  ${dist_name_status}  ${TRUE}  ${FALSE}
        IF  ${match}  BREAK
    END
    IF  not(${match})  Fail  NRCELL doesn't contain "[test]" in it's notation, in Performance view - table view. [NOK]
    Log  NRCELL contains "[test]" in it's notation, in Performance view - table view. [OK]  console=true


Step 12: Save Counters List And Check File Content - Table View
    Log  \nStep 12: Save counters file and check csv file content.  console=true
    Click Element  //*[contains(text(),'Save Counters List')]
    Wait Until Keyword Succeeds  60s  10s
    ...  Find Last File Downloaded  PM  .csv  ${CURRENT_DATE_CSV_FORMAT}  ${TEST_START_TIME_CSV_FORMAT}
    Verify PM Counters Csv File Content  ${FILE_PATH}  [test] ${CELL_DN}
    Log  All fields in PM Counters file are set correctly. [OK]  console=true


Step 13: Check Selected Counter In Performance View - Plot View
    Log  \nStep 13: Check selected counter in Performance view - plot view.  console=true
    Click Element  //*[contains(text(),'Plot View')]
    ${plot_view_cell_locator}  Catenate  SEPARATOR=  //*[@class="main-content"]/as-split/div[2]/div/div/pm-v2-main-view/div[2]/ui-webem-pm-chart
    ...  /ui-webem-line-chart/div/div/div/div/span
    ${plot_view_cell_text}  Get Text  ${plot_view_cell_locator}
    Should Contain  ${plot_view_cell_text}  [test]  NRCELL doesn't contain "[test]" in it's notation, in Performance view - plot view. [NOK]
    Log  NRCELL contains "[test]" in it's notation, in Performance view - plot view. [OK]  console=true


Step 14: Save Counters List - Plot View
    Log  \nStep 14: Save counters list - plot view.  console=true
    Click Element  //*[contains(text(),'Save Counters List')]
    Wait Until Keyword Succeeds  60s  10s
    ...  Find Last File Downloaded  PM  .png  ${CURRENT_DATE_CSV_FORMAT}  ${TEST_START_TIME_CSV_FORMAT}
    Log  Founded file: ${FILE_PATH}  console=true


Find Last File Downloaded
    [Arguments]  ${file_type}  ${extension}  ${current_date}  ${test_start_time}  ${alarm_type}=${None}

    ${downloads_files}  OperatingSystem.List Files In Directory  /home/ute/Downloads
    FOR  ${file}  IN  @{downloads_files}
        ${file_type_status}  Run Keyword And Return Status
        ...  Should Contain  ${file}  ${file_type}
        ${VDU_INSTANCE_ID}  Convert To String  ${VDU_INSTANCE_ID}
        ${id_status}  Run Keyword And Return Status
        ...  Should Contain  ${file}  ${VDU_INSTANCE_ID}
        ${date_status}  Run Keyword And Return Status
        ...  Should Contain  ${file}  ${current_date}
        ${extension_status}  Run Keyword And Return Status
        ...  Should Contain  ${file}  ${extension}
        IF  $alarm_type is $None
            ${alarm_status}  Set Variable  ${TRUE}
        ELSE
            ${alarm_status}  Run Keyword And Return Status  Should Contain  ${file}  ${alarm_type}
        END
        ${file_time}  Fetch From Right  ${file}  -
        ${file_time}  Fetch From Left  ${file_time}  ${extension}
        ${match_condition}  Catenate  ${file_type_status}  and ${id_status}  and ${alarm_status}  and ${date_status}  and ${extension_status}
        IF  '${file_time}' >= '${test_start_time}' and ${match_condition}
            Set Test Variable  ${FILE_PATH}  /home/ute/Downloads/${file}
            RETURN
        END
    END
    Fail  No file found in Downloads.


Verify Active Alarms Csv File Content
    [Arguments]  ${file_path}  ${current_date_time}  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${alarming_object}=${None}

    ${csv_content}  Return Csv File Content  ${file_path}
    FOR  ${row}  IN  @{csv_content}
        ${time_status}  Run Keyword And Return Status
        ...  Evaluate  '${row}[1]'>'${current_date_time}'
        ${alarm_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[2]  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[3]  ${alarm_name}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[4]  ${fault_id}
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[5]  ${fault_name}
        IF  $alarming_object is $None
            ${alarming_object_status}  Set Variable  ${TRUE}
        ELSE
            ${alarming_object_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${row}[6]  ${alarming_object}
        END
        ${match_condition}  Catenate  ${time_status}  and ${alarm_id_status}  and ${alarm_name_status}  and ${fault_id_status}
        ...  and ${fault_name_status}  and ${alarming_object_status}
        ${match}  Set Variable If  ${match_condition}  ${TRUE}  ${FALSE}
        IF  ${match}  BREAK
    END
    Should Be True  ${match}  Alarm with fault id: ${fault_id} not found in Active Alarms list in downloaded file. [NOK]


Verify Historical Alarms Csv File Content
    [Arguments]  ${file_path}  ${current_date_time}  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${alarming_object}=${None}

    ${csv_content}  Return Csv File Content  ${file_path}
    FOR  ${row}  IN  @{csv_content}
        ${time_status}  Run Keyword And Return Status
        ...  Evaluate  '${row}[1]'>'${current_date_time}'
        ${alarm_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[3]  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[4]  ${alarm_name}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[5]  ${fault_id}
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${row}[6]  ${fault_name}
        IF  $alarming_object is $None
            ${alarming_object_status}  Set Variable  ${TRUE}
        ELSE
            ${alarming_object_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${row}[7]  ${alarming_object}
        END
        ${match_condition}  Catenate  ${time_status}  and ${alarm_id_status}  and ${alarm_name_status}  and ${fault_id_status}
        ...  and ${fault_name_status}  and ${alarming_object_status}
        ${match}  Set Variable If  ${match_condition}  ${TRUE}  ${FALSE}
        IF  ${match}  BREAK
    END
    Should Be True  ${match}  Alarm with fault id: ${fault_id} not found in Historical Alarms list in downloaded file. [NOK]


Verify PM Counters Csv File Content
    [Arguments]  ${file_path}  ${cell_dist_name}

    ${csv_content}  Return Csv File Content  ${file_path}
    FOR  ${row}  IN  @{csv_content}
        ${cell_dist_name_status}  Run Keyword And Return Status
        ...  Should Contain  ${row}[1]  ${cell_dist_name}
        IF  ${cell_dist_name_status}  RETURN
    END
    Fail  Modified cell dist name: [test] ${CELL_DN}, not found in PM counters file. [NOK]


Perform Recovery Action
    ${cell_status}  Run Keyword And Return Status
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}
    IF  ${cell_status}==${FALSE}
        vdu.Unblock Cell  ${CELL_ID}
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
        ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}
    END


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__configurable_identifiers_in_WebEM_vDU


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    Change Specific Parameter For VDU  cellName  ${CELL_ID}  ${CELL_DN}
    VDU WebEM Teardown
    Common VDU Teardown
