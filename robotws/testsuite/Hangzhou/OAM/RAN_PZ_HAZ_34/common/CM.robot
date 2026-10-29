Documentation
...    author: Liu Shasha
...    contact: shasha.liu@nokia-sbell.com


*** Settings ***
Resource   ./NetAct_swing.robot
Resource   ./NetAct_selenium.robot

*** Variables ***
${CMOP_TREE_NAME}    navigationTree

*** Keywords ***
NetAct CM Upload
    [Documentation]   Operation Upload in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | mrbts_id | yes | the mrbts id of gnb |
    ...    *RETURN VALUE*
    ...    the result of CM upload.
    ...    Example
    ...    | ${upload_result} = | NetAct CM Upload | MRBTS-1900 |
    [Arguments]    ${mrbts_id}
    Wait Until Keyword Succeeds    30s   5s     swing.Select Main Window
    Wait Until Keyword Succeeds    30s   10s    swing.Select From Main Menu And Wait    Upload|New Upload...
    Wait Until Keyword Succeeds    30s   10s    swing.Select Window   Upload
    wait until keyword succeeds    5s    1s     swing.Select tab   BSC
    FOR    ${i}    IN RANGE    9
       swing.Send Keyboard Event    VK_RIGHT
    END
    swing.Select tab    5G/LTE/SRAN
    Wait Until Keyword Succeeds    30s    10s    swing.Click On Component  SelectAllButton
    Wait Until Keyword Succeeds    30s    10s    swing.Click On Component  DeselectAllButton
    Wait Until Keyword Succeeds    30s    10s    swing.Expand All Tree Nodes    0
    ${nodes}    _Search All tree nodes CM upload    0
    ${bts_index}    ${bts_node}    _Search dedicated node index CM upload    ${nodes}    ${mrbts_id}
    swing.Click On Tree Node    0    ${bts_index}
    Wait Until Keyword Succeeds    10s    1s     swing.Check Check Box    SranUploadBTSCheckBox
    Wait Until Keyword Succeeds    10s    1s     swing.Check Check Box    SranUploadHWCheckBox
    Wait Until Keyword Succeeds    30s    10s    swing.Select Window    Upload
    Wait Until Keyword Succeeds    30s    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    10s    1s     swing.Select Dialog    Confirmation
    Wait Until Keyword Succeeds    30s    10s    swing.Push Button    Yes
    ${CM_finished}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    10s
    ...    swing.Select Window    Upload: Finished
    Wait Until Keyword Succeeds    30s    10s    swing.Push Button    Close
    [Return]    ${CM_finished}

Create CM Plan
    [Documentation]   Create a new Plan in CM Editor Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_name | yes | the original plan name |
    ...    *RETURN VALUE*
    ...    the name of the new plan created.
    ...    Example
    ...    | ${plan_name} = | Create CM Plan | bts_reset |
    [Arguments]    ${plan_name}
    ${current_date}    Get Current Date
    ${DATE_STR}    Convert Date    ${current_date}    %Y%m%d%H%M
    ${new_plan_name}    Set Variable    ${plan_name}_${DATE_STR}
    Set Variable    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    10s    swing.Select From Main Menu And Wait    Plan|New Plan
    Wait Until Keyword Succeeds    10s    1s     Insert Text to Target Field and Check   headerTextFieldName   ${new_plan_name}
    wait until keyword succeeds    10s    2s     swing.Click On Component    headerTextFieldName
    wait until keyword succeeds    10s    2s     swing.Send Keyboard Event    VK_ENTER
    [Return]    ${new_plan_name}

Check CM Plan Create Succefully
    [Documentation]   Check if CM Plan Create Succefully in CM Editor Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the target plan name |
    ...    *RETURN VALUE*
    ...    check status.
    ...    Example
    ...    | ${create_result} = | Check CM Plan Create Succefully | bts_reset |
    [Arguments]    ${new_plan_name}
    swing.Select From Main Menu    Plan|Open Plan...
    swing.Select Dialog    Open Plan
    wait until keyword succeeds    10s    2s    swing.Clear Text Field    openPlanFilterTextField
    swing.Type Into Text Field    openPlanFilterTextField    ${new_plan_name}
    wait until keyword succeeds    10s    2s    swing.Send Keyboard Event    VK_ENTER
    ${result}    wait until keyword succeeds    10s    2s    run keyword and ignore error    swing.Select Table Cell    openPlanPlanTable    0    0
    ${create_result}    set variable    ${result}[0]
    swing.Push Button    Cancel
    [Return]    ${create_result}

Delete CM Plan
    [Documentation]   Delete a CM Plan in CM Editor Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the target plan name |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Delete CM Plan | bts_reset |
    [Arguments]    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    30s    5s    swing.Combo Box Should Be Enabled    editorViewComboBox
    wait until keyword succeeds    10s    2s    swing.Select From Combo Box    editorViewComboBox    0
    wait until keyword succeeds    10s    2s    swing.Select From Main Menu    Plan|Open Plan...
    wait until keyword succeeds    10s    2s    swing.Select Dialog    Open Plan
    wait until keyword succeeds    10s    2s    swing.Clear Text Field    openPlanFilterTextField
    wait until keyword succeeds    10s    2s    swing.Type Into Text Field    openPlanFilterTextField    ${new_plan_name}
    wait until keyword succeeds    10s    2s    swing.Send Keyboard Event    VK_ENTER
    wait until keyword succeeds    10s    2s    swing.Select Table Cell    openPlanPlanTable    0    0
    wait until keyword succeeds    10s    2s    swing.Push Button    Open
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu    Plan|Delete Plan
    Wait Until Keyword Succeeds    30s    5s    swing.Select Dialog    CM Editor
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button    Delete

Delete CM Plan on Operations Manager
    [Documentation]   Delete a CM Plan in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the target plan name |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Delete CM Plan on Operations Manager | bts_reset |
    [Arguments]    ${new_plan_name}
    Wait Until Keyword Succeeds    30 sec    5 sec    SWING.Select Main Window
    SWING.Clear Text Field   FilterTextField
    SWING.Insert Into Text Field   FilterTextField   ${new_plan_name}
    Wait Until Keyword Succeeds   3 times   5s   SWING.Select From Main Menu And Wait    View|Refresh
    Wait Until Keyword Succeeds   3 times   5s   SWING.Get Table Values   PlanTable
    Wait Until Keyword Succeeds   3 times   5s   SWING.Click On Table Cell   PlanTable   0   0
    Wait Until Keyword Succeeds   3 times   5s   SWING.Select From Main Menu And Wait    Plan|Delete
    Wait Until Keyword Succeeds   3 times   5s   SWING.Select Dialog   Confirmation
    Wait Until Keyword Succeeds   3 times   5s   SWING.Push Button   Yes

Get parameter value on CM Editor
    [Documentation]   Get Exist Parameter value On CM Editor. CM Editor App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | dist_name | yes | the dist name of parameter |
    ...   | row | yes | the row in which the parameter is located |
    ...   | column | yes | the column in which the parameter is located |
    ...    *RETURN VALUE*
    ...    the value of parameter.
    ...    Example
    ...    | ${para_value} = | Get parameter value on CM Editor | MRBTS-xxxx | 0 | 1 |
    [Arguments]    ${dist_name}   ${row}    ${column}
    Wait Until Keyword Succeeds    30 sec    5 sec    SWING.Select Main Window
    sleep    5
    SWING.Select From Main Menu    View|Go To Managed Object...
    SWING.Select Window    Go To Managed Object
    ${output}=    SWING.List Components In Context
    sleep    5
    SWING.Clear Text Field    goToViewTextFieldDN
    SWING.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${dist_name}
    sleep    5
    SWING.Select Table Cell    objectSelectionTable    0    0
    swing.Push Button    Go To
    swing.Push Button    Close
    Wait Until Keyword Succeeds    30 sec    5 sec    SWING.Select Main Window
    ${para_value}=    SWING.Get Table Cell Value    Vertical actual table    ${row}    ${column}
    [Return]    ${para_value}

Modify Exist Parameter in New Plan
    [Documentation]   Modify Exist Parameter In new plan. New plan should be created before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | dist_name | yes | the dist name of parameter |
    ...   | plan_name_new | yes | the new plan name |
    ...   | row | yes | the row in which the parameter is located |
    ...   | column_plan | yes | the column in which the planed parameter value is located |
    ...   | column_actual | yes | the column in which the actual parameter value is located |
    ...   | new_value | yes | the new value of parameter |
    ...    *RETURN VALUE*
    ...    the original value of parameter.
    ...    Example
    ...    | ${original} = | Modify Exist Parameter in New Plan | MRBTS-xxxx | change_name | 0 | 1 | 2 | new_value |
    [Arguments]    ${dist_name}   ${plan_name_new}  ${row}    ${column_plan}    ${column_actual}   ${new_value}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Main Menu    View|Go To Managed Object...
    Wait Until Keyword Succeeds    10s    1s    swing.Select Window    Go To Managed Object
    Wait Until Keyword Succeeds    10s    1s    swing.Clear Text Field    goToViewTextFieldDN
    swing.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${dist_name}
    Wait Until Keyword Succeeds    10s    1s    swing.Select Table Cell    objectSelectionTable    0    0
    swing.Push Button    Go To
    swing.Push Button    Close
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    ${output}    swing.Get Table Cell Value    Vertical plan and actual table    ${row}    ${column_actual}
    set Test variable    ${original_value}    ${output}
    Wait Until Keyword Succeeds    10s    2s
    ...    swing.Set Table Cell Value    Vertical plan and actual table    ${row}    ${column_plan}    ${new_value}
    wait until keyword succeeds    10s    2s    swing.Send Keyboard Event    VK_ENTER
    [Return]    ${original_value}

Download CM Plan
    [Documentation]   Download CM Plan in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the new plan name |
    ...   | create_back_plan | no | whether to create a backup plan , the default value is false |
    ...    *RETURN VALUE*
    ...    the Backup plan name and result of Download CM Plan.
    ...    Example
    ...    | ${Backup_plan_name} | ${result} = | Download CM Plan | new_plan_reset_ru |
    [Arguments]    ${new_plan_name}    ${create_back_plan}=${False}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    swing.Clear Text Field   FilterTextField
    swing.Insert Into Text Field   FilterTextField   ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    View|Refresh
    Wait Until Keyword Succeeds    30s    5s    swing.Get Table Values   PlanTable
    Wait Until Keyword Succeeds    30s    5s    swing.Click On Table Cell   PlanTable   0   0
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    Plan|Provision...
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window   Provision - ${new_plan_name}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    5s    swing.Check Check Box    ProvisionView_ProvisionCheckbox
    Wait Until Keyword Succeeds    30s    5s    swing.Push Radio Button    ProvisionView_PreActivateRadioButton
    run keyword if    '${create_back_plan}' == 'False'    Wait Until Keyword Succeeds   3 times   5s   swing.Uncheck Check Box
    ...    ProvisionViewBackupPanel_BackupPlanCheckbox
    run keyword if    '${create_back_plan}' == 'True'    Wait Until Keyword Succeeds   3 times   5s   swing.Check Check Box
    ...    ProvisionViewBackupPanel_BackupPlanCheckbox
    ${Backup_plan_name}    swing.Get Text Field Value   ProvisionViewBackupPanel_BackupPlanTextField
    set variable    ${Backup_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Start
    Wait Until Keyword Succeeds    30s    5s    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Yes
    ${CM_finished}    Run Keyword And Return Status   Wait Until Keyword Succeeds    5min    10s
    ...   swing.Select Window   Provision - Pre-Activate: Finished - ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Close
    [Return]    ${Backup_plan_name}    ${CM_finished}

Validate CM Plan
    [Documentation]   Validate CM Plan in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the new plan name |
    ...    *RETURN VALUE*
    ...    the result of Validate CM Plan.
    ...    Example
    ...    | ${result} = | Validate CM Plan | new_plan_reset_ru |
    [Arguments]    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    swing.Clear Text Field   FilterTextField
    swing.Insert Into Text Field   FilterTextField   ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    View|Refresh
    Wait Until Keyword Succeeds    30s    5s    swing.Get Table Values   PlanTable
    Wait Until Keyword Succeeds    30s    5s    swing.Click On Table Cell   PlanTable   0   0
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    Plan|Provision...
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window   Provision - ${new_plan_name}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    5s    swing.Check Check Box    ProvisionView_ProvisionCheckbox
    Wait Until Keyword Succeeds    30s    5s    swing.Push Radio Button    ProvisionView_ValidateRadioButton
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Start
    Wait Until Keyword Succeeds    30s    5s    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Yes
    ${CM_finished}    Run Keyword And Return Status   Wait Until Keyword Succeeds    5min    10s
    ...   swing.Select Window   Provision - Validate: Finished - ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Close
    [Return]    ${CM_finished}

Activate CM Plan
    [Documentation]   Activate CM Plan in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the new plan name |
    ...    *RETURN VALUE*
    ...    the result of Activate CM Plan.
    ...    Example
    ...    | ${result} = | Validate CM Plan | new_plan_reset_ru |
    [Arguments]    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    swing.Clear Text Field   FilterTextField
    swing.Insert Into Text Field   FilterTextField   ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    View|Refresh
    Wait Until Keyword Succeeds    30s    5s    swing.Get Table Values   PlanTable
    Wait Until Keyword Succeeds    30s    5s    swing.Click On Table Cell   PlanTable   0   0
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    Plan|Provision...
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window   Provision - ${new_plan_name}
    #${Backup_plan_name}    swing.Get Text Field Value   ProvisionViewBackupPanel_BackupPlanTextField
    #set variable    ${Backup_plan_name}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    5s    swing.Check Check Box    ProvisionView_ProvisionCheckbox
    Wait Until Keyword Succeeds    30s    5s    swing.Push Radio Button    ProvisionView_ActivatePreactivationRadioButton
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Start
    Wait Until Keyword Succeeds    30s    5s    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Yes
    ${CM_finished}    Run Keyword And Return Status   Wait Until Keyword Succeeds    5min    10s
    ...   swing.Select Window   Provision - Activate Pre-Activated Plan: Finished - ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Close
    [Return]    ${CM_finished}

Provision CM Plan
    [Documentation]   Provision CM Plan in CM Operations Manager Java App. App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | new_plan_name | yes | the new plan name |
    ...   | create_back_plan | no | whether to create a backup plan , the default value is false |
    ...    *RETURN VALUE*
    ...    the Backup plan name and result of Provision CM Plan.
    ...    Example
    ...    | ${Backup_plan_name} | ${result} = | Provision CM Plan | new_plan_reset_ru |
    [Arguments]    ${new_plan_name}    ${create_back_plan}=${False}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    swing.Clear Text Field   FilterTextField
    swing.Insert Into Text Field   FilterTextField   ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    View|Refresh
    Wait Until Keyword Succeeds    30s    5s    swing.Get Table Values   PlanTable
    Wait Until Keyword Succeeds    30s    5s    swing.Click On Table Cell   PlanTable   0   0
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    Plan|Provision...
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window   Provision - ${new_plan_name}
    ${Backup_plan_name}    swing.Get Text Field Value   ProvisionViewBackupPanel_BackupPlanTextField
    set variable    ${Backup_plan_name}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    5s    swing.Check Check Box    ProvisionView_ProvisionCheckbox
    Wait Until Keyword Succeeds    30s    5s    swing.Push Radio Button    ProvisionView_ActivateRadioButton
    run keyword if    '${create_back_plan}' == 'False'    Wait Until Keyword Succeeds   3 times   5s   swing.Uncheck Check Box
    ...    ProvisionViewBackupPanel_BackupPlanCheckbox
    run keyword if    '${create_back_plan}' == 'True'    Wait Until Keyword Succeeds   3 times   5s   swing.Check Check Box
    ...    ProvisionViewBackupPanel_BackupPlanCheckbox
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Start
    Wait Until Keyword Succeeds    30s    5s    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Yes
    ${CM_finished}    Run Keyword And Return Status   Wait Until Keyword Succeeds    5min    10s
    ...   swing.Select Window   Provision - Activate: Finished - ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   Close
    [Return]    ${Backup_plan_name}    ${CM_finished}

Modify Parameter Online
    [Documentation]   Modify Parameter Online. CM Editor App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | dist_name | yes | the dist name of parameter |
    ...   | MO_name | no | the mo name of modify parameter , default is empty |
    ...   | MRBTSID | yes | the mrbtsid of gnb located |
    ...   | row | yes | the row in which the parameter is located |
    ...   | column | yes | the column in which the parameter is located |
    ...   | new_value | yes | the new value of parameter |
    ...    *RETURN VALUE*
    ...    the original value of parameter.
    ...    the result of modify parameter online.
    ...    Example
    ...    | ${original} | ${result} | Modify Parameter Online | MRBTS-1968/NRBTS-1 | MRBTS-1968 | 0 | 0 | new_value |
    [Arguments]    ${dist_name}    ${mrbts_id}    ${row}    ${column}   ${new_value}     ${MO_name}=${EMPTY}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    30s    1s    swing.Select From Main Menu    View|Go To Managed Object...
    Wait Until Keyword Succeeds    30s    1s    swing.Select Window    Go To Managed Object
    Wait Until Keyword Succeeds    30s    1s    swing.Clear Text Field    goToViewTextFieldDN
    Wait Until Keyword Succeeds    30s    1s    swing.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${dist_name}
    Wait Until Keyword Succeeds    30s    1s    swing.Select Table Cell    objectSelectionTable    0    0
    Wait Until Keyword Succeeds    30s    1s    swing.Push Button    Go To
    Wait Until Keyword Succeeds    30s    1s    swing.Push Button    Close
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    ${output}    Wait Until Keyword Succeeds    30s    5s        swing.Get Table Cell Value    Vertical actual table    
	...    ${row}    ${column}
    set Test variable    ${original_value}    ${output}
    Wait Until Keyword Succeeds    30s    2s    swing.Check Check Box    parameters.by.actual.view.modify
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Clear Table Cell    
	...    Vertical actual table    ${row}    ${column}
    Wait Until Keyword Succeeds    30s    2s    swing.Set Table Cell Value    Vertical actual table    ${row}    ${column}    ${new_value}
    wait until keyword succeeds    30s    2s    swing.Send Keyboard Event    VK_ENTER
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu    Actual|Send to Network
    wait until keyword succeeds    30s    2s    swing.Select Dialog    CM Editor
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button   OK
    ${CM_finished}=    run keyword if    '${MO_name}' != ''    Run Keyword And Return Status   Wait Until Keyword Succeeds   10min    10s
    ...    swing.Select Window   Provision - Activate: Finished - Modify ${MO_name} in ${mrbts_id} ${mrbts_id}
    ...    ELSE IF    '${MO_name}' == ''    Run Keyword And Return Status   Wait Until Keyword Succeeds    10min    10s
    ...    swing.Select Window   Provision - Activate: Finished - Modify ${mrbts_id} ${mrbts_id}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   30s   5s   swing.Select Dialog   Warning
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   30s   5s   swing.Push Button   OK
    Wait Until Keyword Succeeds    30s   5s   swing.Push Button   Close
    [Return]    ${original_value}    ${CM_finished}

Export Actual Configuration
    [Documentation]   export actual configuration. CM Editor App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | mrbtsid | yes | the mrbts id of gnb |
    ...   | Export_path | yes | the export path |
    ...    *RETURN VALUE*
    ...    the export file path
    ...    Example
    ...    | ${original} = | Export Actual Configuration | MRBTS-1900 | /home/nokia/Downloads |
    [Arguments]    ${mrbts_id}    ${Export_path}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    30s    5s    swing.Combo Box Should Be Enabled    editorViewComboBox
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Combo Box    editorViewComboBox    0
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Main Menu    View|Go To Managed Object...
    Wait Until Keyword Succeeds    10s    1s    swing.Select Window    Go To Managed Object
    Wait Until Keyword Succeeds    10s    1s    swing.Clear Text Field    goToViewTextFieldDN
    Wait Until Keyword Succeeds    10s    1s    swing.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${mrbts_id}
    Wait Until Keyword Succeeds    10s    1s    swing.Select Table Cell    objectSelectionTable    0    0
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    Go To
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    Close
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Main Menu    Actual|Export...
    Wait Until Keyword Succeeds    10s    1s    swing.Select Window    Export
    Wait Until Keyword Succeeds    10s    2s    swing.Clear Text Field    0
    Wait Until Keyword Succeeds    10s    2s    swing.Type Into Text Field    0    ${Export_path}/${mrbts_id}
    Wait Until Keyword Succeeds    10s    1s    swing.Check Check Box    0
    Wait Until Keyword Succeeds    10s    1s    swing.Check Check Box    2
    Wait Until Keyword Succeeds    10s    1s    swing.Check Check Box    3
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    3
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    5
    set Test variable    ${actual_file_path}    ${Export_path}/${mrbts_id}.csv
    [Return]    ${actual_file_path}

Import plan
    [Documentation]   Import plan on CM Editor. CM Editor App should be opened before running this KW.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_name | yes | the plan name |
    ...   | Import_file | yes | the Import file path of the plan|
    ...    *RETURN VALUE*
    ...    the new plan name
    ...    Example
    ...    | ${original} = | Export Actual Configuration | MRBTS-1900 | /home/nokia/Downloads |
    [Arguments]    ${plan_name}    ${Import_file}
    ${current_date}   Get Current Date
    ${DATE_STR}   Convert Date   ${current_date}   %Y%m%d%H%M
    ${new_plan_name}   Set Variable   ${plan_name}_${DATE_STR}
    Set Test Variable    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    30s    5s    swing.Select From Main Menu And Wait    Plan|Import...
    Wait Until Keyword Succeeds    30s    5s    swing.Select Window   Import
    Wait Until Keyword Succeeds    30s    5s    swing.Clear Text Field    0
    Wait Until Keyword Succeeds    30s    5s    swing.Type Into Text Field    0    ${Import_file}
    Wait Until Keyword Succeeds    30s    5s    swing.Clear Text Field    1
    Wait Until Keyword Succeeds    30s    5s    swing.Type Into Text Field    1    ${new_plan_name}
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button    Start
    Wait Until Keyword Succeeds    30s    5s    swing.Push Button    Close
    [Return]    ${new_plan_name}

Insert Text to Target Field and Check
    [Arguments]    ${component}   ${text}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    swing.Text Field Should Be Enabled    ${component}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    swing.Clear Text Field    ${component}
    Wait Until Keyword Succeeds    10s    2s    swing.Insert Into Text Field   ${component}    ${text}
    ${text_inserted}    Wait Until Keyword Succeeds   10s   2s   swing.Get Text Field Value    ${component}
    Should Be Equal As Strings   ${text_inserted}   ${text}
