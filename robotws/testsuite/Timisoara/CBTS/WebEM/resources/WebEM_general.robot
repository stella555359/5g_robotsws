*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for CBTS WebEM TCs that contain common KWs, both from old GUI and from the new GUI.


*** Keywords ***
Login On CBTS
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Input Text  //*[@id="login-username"]  Nemuadmin
    Input Password  //*[@id="login-password"]  Nokia@123
    Click Element  //*[@id="login-button"]/button/span


Check Private Connection From CBTS
    [Documentation]  This keyword checks if private connection page appears and proceed the link.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  \nCheck private connection  console=true
    ${status}  Run Keyword And Return Status
    ...  Get Text  //*[@id="main-message"]/h1
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Click Element  //*[@id="details-button"]
    ...  AND
    ...  Click Element  //*[@id="proceed-link"]


Create Delta Plan For CBTS
    [Documentation]  This keyword is used to create delta plan for CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //span[contains(text(), "Create Delta Plan")]  120
    Wait Until Element Is Clicked  //*[@id="edit-plan-create-button"]/button/span  120
    Sleep  60s  Time for plan to be updated!
    ${text_plan}  Get Text  //*[@id="configuration-plans-dropdown"]/div
    Run Keyword If  '${text_plan}'!='CURRENT_PLAN'
    ...  Log  Delta plan was created![OK]  console=true
    ...  ELSE
    ...  Fail  CURRENT_PLAN is still visible, delta plan was not created![NOK]


Create Duplicate Plan For CBTS
    [Documentation]  This keyword is used to create a duplicate plan for CBTS.
    ...  Works only on vDUCNF25R2 or newer.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@id="toolbar-create-plan-button"]/button/span[1]  120
    Wait Until Element Is Clicked  //*[contains(@class, 'ot-radiogroup ot-radiogroup-vertical')]/p-radiobutton[2]/div/div[2]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span  60
    Sleep  60s  Time for plan to be updated!
    Page Should Contain  CONF-1
    Log  Duplicated plan was created![OK]  console=true


Validate And Activate Plan For CBTS
    [Documentation]  This keyword is used to validate and activate plan for CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-validation-button"]
    Wait Until Element Is Visible  //*[contains(text(), "Validate plan operation finished")]  120
    Log  Validate plan was performed![OK]  console=true
    Wait Until Element Is Clicked  //*[@id="webem-parameter-editor-menu-plan-activation-button"]
    Wait Until Element Is Clicked  //*[@id="execute-activate-plan"]/button/span
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Plan activation has finished successfully')]  300
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    Log  Plan activation has finished successfully![OK]  console=true


Validate And Activate Plan For Unified CBTS
    [Documentation]  This keyword is used to validate and activate plan for Unified CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@icon="mdi mdi-check-all"]/button  60
    IF  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF26R1'
        Wait Until Keyword Succeeds  60  1  Page should contain  Plan Validation operation succeeded
    ELSE
        Wait Until Element Is Enabled  //*[@icon="mdi mdi-check-all"]/button  60
    END
    Log  Validate plan was performed![OK]  console=true
    Mouse Over  //*[@id="/commissioning-wizard"]
    Wait Until Element Is Clicked  //*[@id="toolbar-activate-plan-button"]/button  120
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Run Keyword And Ignore Error  Wait Until Element Is Visible  //*[@id="Close"]/button  600s
    Run Keyword And Ignore Error  Click Element  //*[@id="Close"]/button
    Wait Until Element Is Visible
    ...  //span[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Plan activation has finished successfully.')]  120
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span
    Log  Plan activation has finished successfully![OK]  console=true


Validate And Activate Current Plan For Unified CBTS
    [Documentation]  This keyword is used to validate and activate plan for Unified CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@icon="mdi mdi-check-all"]/button  60
    IF  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF26R1'
        Wait Until Keyword Succeeds  60  1  Page should contain  Plan Validation operation succeeded
    ELSE
        Wait Until Element Is Enabled  //*[@icon="mdi mdi-check-all"]/button  60
    END
    Log  Validate plan was performed![OK]  console=true
    Mouse Over  //*[@id="/commissioning-wizard"]
    Wait Until Element Is Clicked  //*[@id="toolbar-activate-plan-button"]/button
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Wait Until Element Is Visible
    ...  //span[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Plan activation has finished successfully.')]  120
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[2]/button/span
    Log  Plan activation has finished successfully![OK]  console=true


Activate Plan For CBTS
    [Documentation]  This keyword is used to activate plan for CBTS.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Click Element  //*[@id="global-search-table"]/div[1]/div
    Wait Until Element Is Clicked  //span[contains(text(),'Activate Plan')]
    Wait Until Element Is Clicked  //span[contains(text(),'Execute')]
    Wait Until Element Is Visible  //span[contains(@class, 'feedback-text') and contains(text(), 'Plan activation has finished successfully')]  300
    Wait Until Element Is Clicked  //*[@id="activate-modal-done"]/button/span
    Log  Plan activation has finished successfully![OK]  console=true


Verify Alarm Fields In Active Alarms List
    [Documentation]  This keyword is used to verify alarm fields in Active Alarms list in WebEM.
    ...  ${test_start_date_time} must have this format: %d.%m.%y %H:%M:%S
    ...  Example of use:
    ...  Verify alarm fields in Active Alarms list  22.09.2023 09:55:18
    ...                                         7102
    ...                                         BASE STATION RESOURCE BLOCKED BY USER
    ...                                         49
    ...                                         Cell blocked
    ...                                         MRBTS-10334/NRBTS-1/NRCELL-351
    ...  ${alarming_object} is optional.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${test_start_date_time}  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${alarming_object}=${None}

    ${alarm_class}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF26R1'  p-datatable-table ng-star-inserted
    ...  p-datatable-table p-datatable-scrollable-table
    ${alarms}  SeleniumLibrary.Get Element Count  //tr[contains(@class, 'p-element p-selectable-row ng-star-inserted')]
    FOR  ${row_id}  IN RANGE  1  ${alarms}+1
        ${alarm_locator}  Get WebElement  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]
        ${appeared_time}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[2]
        ${extracted_alarm_id}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[3]
        ${extracted_alarm_name}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[4]
        ${extracted_fault_id}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[5]
        ${extracted_fault_name}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[6]
        ${extracted_alarming_object}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[7]
        ${time_status}  Run Keyword And Return Status
        ...  Evaluate  '${appeared_time}'>'${test_start_date_time}'
        ${alarm_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarm_id}  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarm_name}  ${alarm_name}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_fault_id}  ${fault_id}
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_fault_name}  ${fault_name}
        ${alarming_object_status}  Run Keyword If  $alarming_object is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarming_object}  ${alarming_object}
        ${match_condition}  Catenate  ${time_status}  and ${alarm_id_status}  and ${alarm_name_status}  and ${fault_id_status}
        ...  and ${fault_name_status}  and ${alarming_object_status}
        ${match}  Set Variable If  ${match_condition}  True  False
        Exit For Loop If  ${match} == True
    END
    Should Be Equal As Strings  ${match}  True  Alarm with fault id: ${fault_id} not found in Active Alarms list. [NOK]

    [Return]  ${alarm_locator}


Verify Alarm Fields In Historical Alarms List
    [Documentation]  This keyword is used to verify alarm fields in Historical Alarms list in WebEM.
    ...  ${test_start_date_time} must have this format: %d.%m.%y %H:%M:%S
    ...  Example of use:
    ...  Verify alarm fields in Historical Alarms list  22.09.2023 09:55:18
    ...                                             7102
    ...                                             BASE STATION RESOURCE BLOCKED BY USER
    ...                                             49
    ...                                             Cell blocked
    ...                                             MRBTS-10334/NRBTS-1/NRCELL-351
    ...  ${alarming_object} is optional.
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com
    [Arguments]  ${test_start_date_time}  ${alarm_id}  ${alarm_name}  ${fault_id}  ${fault_name}  ${alarming_object}=${None}

    ${alarm_class}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' < 'vDUCNF26R1'  p-datatable-table ng-star-inserted
    ...  p-datatable-table p-datatable-scrollable-table
    ${alarms}  SeleniumLibrary.Get Element Count  //tr[contains(@class, 'p-element p-selectable-row ng-star-inserted')]
    FOR  ${row_id}  IN RANGE  1  ${alarms}+1
        ${alarm_locator}  Get WebElement  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]
        ${appeared_time}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[2]
        ${extracted_alarm_id}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[4]
        ${extracted_alarm_name}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[5]
        ${extracted_fault_id}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[6]
        ${extracted_fault_name}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[7]
        ${extracted_alarming_object}  Get Text  //*[contains(@class,'${alarm_class}')]/tbody/tr[${row_id}]/td[8]
        ${time_status}  Run Keyword And Return Status
        ...  Evaluate  '${appeared_time}'>'${test_start_date_time}'
        ${alarm_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarm_id}  ${alarm_id}
        ${alarm_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarm_name}  ${alarm_name}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_fault_id}  ${fault_id}
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_fault_name}  ${fault_name}
        ${alarming_object_status}  Run Keyword If  $alarming_object is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${extracted_alarming_object}  ${alarming_object}
        ${match_condition}  Catenate  ${time_status}  and ${alarm_id_status}  and ${alarm_name_status}  and ${fault_id_status}
        ...  and ${fault_name_status}  and ${alarming_object_status}
        ${match}  Set Variable If  ${match_condition}  True  False
        Exit For Loop If  ${match} == True
    END
    Should Be Equal As Strings  ${match}  True  Alarm with fault id: ${fault_id} not found in Historical Alarms list. [NOK]

    [Return]  ${alarm_locator}


Delete Actual Plan Via WebEM
    [Documentation]  This keyword is used to delete actual plan from CBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Delete actual plan  console=true
    ${cw_status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //*[@id="laf-component"]/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]
    ${pe_status}  Run Keyword And Return Status  Element Should Be Visible
    ...  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]
    ${delete_xpath_unified}  Set Variable If  ${cw_status} == ${TRUE}
    ...  //*[@id="laf-component"]/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]
    ...  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div[4]/p-button[3]/button/span[1]
    ${delete_button}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' >= 'vDUCNF25R2'
    ...  ${delete_xpath_unified}
    ...  //span[contains(text(), "Delete Plan")]
    Wait Until Element Is Clicked  ${delete_button}  60
    Log  Delete plan button was pushed!  console=true
    ${confirm_button}  Set Variable If  '${VDU_ACTIVE_SW_RELEASE}' >= 'vDUCNF25R2'
    ...  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    ...  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]/span[2]
    Wait Until Element Is Clicked  ${confirm_button}  60
    Sleep  10s  Time for plan to be deleted.
    Log  The plan was deleted!  console=true


Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
    [Documentation]  This keyword is used to set test variable the first cell id with the technology and group from the from the first rmod.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${rmods_statuses}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods_statuses}
        ${rmod_status}  Run Keyword And Return Status
        ...  Should Contain  ${rmod}[id]  1
        Run Keyword If  ${rmod_status}
        ...  Run Keywords
        ...  Set First Cell Id Depends On RMOD  ${rmod}
        ...  AND
        ...  Set Test Variable  ${RMOD_ID}  ${rmod}[id]
        ...  AND
        ...  Exit For Loop
    END
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        ${cell_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}[name]  NRCELL-${CELL_ID}
        Run Keyword If  ${cell_status}
        ...  Run Keywords
        ...  Set Test Variable  ${CELL_GROUP_ID}  ${cell}[cell_group_id]
        ...  AND
        ...  Set Test Variable  ${CONFIG_CELL}  ${cell}[dist_names][config]
        ...  AND
        ...  Set Test Variable  ${CELL_TECHNOLOGY}  ${cell}[technology]
        ...  AND
        ...  Exit For Loop
    END


Set First Cell Id Depends On RMOD
    [Documentation]  This keyword is used to set first cell id depends on RMOD
    [Arguments]  ${rmod}

    ${cell_id}  Get From List  ${rmod}[cell_ids]  0
    Set Test Variable  ${CELL_ID}


Get List Of Nr Cells Id
    [Documentation]  This keyword is used to get all nrcells id.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${nr_cells_id_list}  Create List
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        Append To List  ${nr_cells_id_list}  ${cell}[id]
    END

    [Return]  ${nr_cells_id_list}


Get List Of NRCELLGRP Ids
    [Documentation]  This keyword is used to get all nrcellgroups id.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${nr_cells_groups_list}  Create List
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        Append To List  ${nr_cells_groups_list}  ${cell}[cell_group_id]
    END
    ${nr_cells_groups_list}  Remove Duplicates  ${nr_cells_groups_list}
    Sort List  ${nr_cells_groups_list}

    [Return]  ${nr_cells_groups_list}


Save Plan From Commissioning Wizard
    [Documentation]  This keyword is used to save plan from Commissioning Wizard.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[@id="save-btn"]
    Log  Saving plan is ongoing...  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "General Site Settings")]  300
    Element Should Be Disabled  //*[@id="save-btn"]
    Log  The plan is saved successfully!  console=true


Discard Plan From Commissioning Wizard
    [Documentation]  This keyword is used to discard the plan from commissioning wizard.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Discard plan from Commissioning Wizard  console=true
    Wait Until Element Is Clicked  //*[@id="undo-btn"]
    Log  Discarding the plan is ongoing...  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "General Site Settings")]  300
    Element Should Be Disabled  //*[@id="undo-btn"]
    Log  The plan is discarded successfully!  console=true


Open Suppressed Alarms View And Verify If A Specific Fault Is Visible
    [Documentation]  This keyword is used to open suppressed alarms view and verify if a specific fault id is visible in the table.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${fault_id}  ${alarm_id}

    Click Element  //*[@id="/alarm/suppressed"]/span
    Click Element
    ...  //*[@id="laf-component"]/blocks-suppressed-alarm/div/cem-toolbar/div/div[1]/div/cem-operation-button/div/div/p-button[1]/button/span
    Log  Get Suppressed Alarms button was pushed!  console=true
    Wait Until Keyword Succeeds  60  5
    ...  Page Should Contain  Get Suppressed Alarms success
    Log  Message 'Get Suppressed Alarms success' is visible![OK]  console=true
    Wait Until Element Is Visible  //*[contains(@class, "p-element p-datatable-tbody")]/tr  60
    ${alarm_table_tr}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-datatable-tbody")]/tr
    FOR  ${alarm_index}  IN RANGE  1  ${alarm_table_tr}+1
        IF  ${alarm_index} == 1
            ${suppressed_fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[5]
            ${suppressed_alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr/td[3]
        ELSE
            ${suppressed_fault_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[5]
            ${suppressed_alarm_id}  Get Text  //*[contains(@class, "p-element p-datatable-tbody")]/tr[${alarm_index}]/td[3]
        END
        IF  '${suppressed_fault_id}' == '${fault_id}' and '${suppressed_alarm_id}' == '${alarm_id}'
            Should be equal  ${suppressed_fault_id}  ${fault_id}  Fault id ${fault_id} is not visible on Suppressed Alarms page![NOK]
            Should be equal  ${suppressed_alarm_id}  ${alarm_id}  Alarm id ${alarm_id} is not visible on Suppressed Alarms page![NOK]
            Log  Fault id ${fault_id} with alarm id ${alarm_id} is visible on Suppressed Alarms page![OK]  console=true
            BREAK
        ELSE
            CONTINUE
        END
    END


Verify The Titles From The Statistics File With Suppressed Alarms
    [Documentation]  This keyword is used to verify the titles from the statistics file with suppressed alarms.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${file_content}

    ${title_list}  Create List  Severity  Latest appeared  Alarm ID  Alarm name  Fault ID  Fault name  Alarming object
    ...  Current 10s  Last 10s  Current minute  Last minute  Current hour  Last hour  Current day  Last day  All
    FOR  ${title}  IN  @{title_list}
        Should Contain  ${file_content}  ${title}  The file doesn't contain ${title} title![NOK]
        Log  The saved file contains ${title} title![OK]  console=true
    END


Wait Until Element Is Clicked
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW waits for Click Element KW to succeeds.
    [Arguments]  ${xpath}  ${retry_timeout}=30s  ${retry_interval}=5s

    Wait Until Keyword Succeeds  ${retry_timeout}  ${retry_interval}
    ...  Click Element  ${xpath}
