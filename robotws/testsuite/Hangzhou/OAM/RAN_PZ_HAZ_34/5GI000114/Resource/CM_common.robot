*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot
Resource   ../../common/NetAct_selenium.robot
Resource   ../../common/NetAct_swing.robot
Resource   ../../common/NetAct_ssh.robot

*** Variables ***

*** Keywords ***
Create a new configuration plan
    [Arguments]   ${new_plan_name}
    Switch to Application   alias=CM Editor
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait   menuPath=Plan|New Plan
    Sleep   3s
    Insert Text to Target Field and Check   component=headerTextFieldName   text=${new_plan_name}
    wait until keyword succeeds  10s   2s   swing.Click On Component    identifier=headerTextFieldName
    wait until keyword succeeds  10s   2s   swing.Send Keyboard Event   keyCode=VK_ENTER

CM Get Tree Path
    [Arguments]   ${tree_name}   ${tree_path_header}
    Expand Tree Node and Select node in CM application
    ...   tree_name=${tree_name}
    ...   node_path=${tree_path_header}
    ...   component_name=${tree_name}
    Sleep   5s
    @{child_list}   Get Tree Node Child Names   ${tree_name}   ${tree_path_header}
    Return From Keyword If   '${MO_NAME} ${MO_NAME}' in ${child_list}   ${tree_path_header}
    FOR   ${folder_name}   IN   @{child_list}
       Continue For Loop If   "${folder_name.find('MRBTS')}"=="-1"
       ${folder_name}   Strip String   ${folder_name}
       @{range}   Split String   ${folder_name}   -
       @{range}   Split String   ${range[-1]}   ...
       Return From Keyword If   ${BTSID} >=${range[0]} and ${BTSID} <=${range[1]}   ${tree_path_header}|${folder_name}
    END

Expand Tree Node and Select node in CM application
    [Arguments]   ${tree_name}   ${node_path}   ${component_name}
    ${nodes}   Set Variable   ${node_path.split('|')}
    ${curr_node}   Set Variable   ${nodes[0]}
    Expand Tree Node   ${tree_name}   ${curr_node}   \#0
    FOR   ${node}   IN   @{nodes}
       Continue For Loop If   '${node}'=='${nodes[0]}'
       ${curr_node}   Set Variable   ${curr_node}|${node}
       Expand Tree Node    ${tree_name}    ${curr_node}   \#0
       Sleep   3s
    END
    Click On Tree Node    ${tree_name}    ${node_path}   \#0
    Sleep   5s
    Wait Until Keyword Succeeds   1m   3s   Component Should Exist    identifier=${component_name}

Set Table Cell Value and Verify
    [Arguments]   ${table_name}   ${row_id}   ${column_id}   ${target_value}
    Set Table Cell Value    identifier=${table_name}    row=${row_id}   columnIdentifier=${column_id}   newValue=${target_value}
    Click on Table Cell   identifier=${table_name}   row=${row_id}   column=0   clickCountString=1
    ${table_cell_value}   Get Table Cell Value   identifier=${table_name}    row=${row_id}   columnIdentifier=${column_id}
    should be equal   ${target_value}   ${table_cell_value}

Get Table Cell Value and Position
    [Arguments]   ${table_name}   ${search_key}   ${search_value}   ${target_key}
    &{condition}   Create Dictionary   ${search_key}=${search_value}
    ${table_cell}   Get Table Value By Condition   table_name=${table_name}   condition=${condition}   column=${target_key}
    ${cell_value}   Set Variable   ${table_cell[0]['value']}
    ${column_id}  Set Variable    ${table_cell[0]['column']}
    ${row_id}   Set Variable   ${table_cell[0]['row']}
    [Return]   ${cell_value}   ${row_id}   ${column_id}

Execute CM Provision in Operations Manager
    [Arguments]   ${plan_name}
    Switch to Application    alias=CM Operations Manager
    Insert Text to Target Field and Check   component=FilterTextField   text=${plan_name}
    Wait Until Keyword Succeeds   1m   3s   swing.Select From Main Menu And Wait    menuPath=View|Refresh
    Wait Until Keyword Succeeds   1m   3s   Get Table Values   identifier=PlanTable
    Wait Until Keyword Succeeds   1m   3s   Click On Table Cell   identifier=PlanTable   row=0   column=0
    Wait Until Keyword Succeeds   1m   3s   swing.Select From Main Menu And Wait    menuPath=Plan|Provision...
    Wait Until Keyword Succeeds   1m   3s   Select Window   identifier=Provision - ${plan_name}
    Wait Until Keyword Succeeds   1m   3s   Push Button   identifier=Start
    Select Dialog   Confirmation
    Wait Until Keyword Succeeds   1m   3s   Push Button   identifier=Yes
    Sleep   20s
    Wait Until Keyword Succeeds   1m   3s   Select Window   identifier=Provision - Activate: Finished - ${plan_name}
    Wait Until Keyword Succeeds   1m   3s   swing.Push Button   identifier=Close

Do CM Provision Recovery
    [Arguments]   ${plan_name}   ${origin_parameter}
    Click NetAct Web and Switch to App   alias=CM Editor
    ${TREE_PATH}    CM Get Tree Path   tree_name=navigationTree   tree_path_header=Opened Plans|${plan_name}|Managed Objects|PLMN-PLMN
    Expand Tree Node   navigationTree   Opened Plans|${plan_name}  \#0 
    Expand Tree Node   navigationTree   Opened Plans|${plan_name}|Managed Objects   \#0
    Expand Tree Node   navigationTree   Opened Plans|${plan_name}|Managed Objects|PLMN-PLMN   \#0
    Expand Tree Node   navigationTree   ${TREE_PATH}   \#0
    Click On Tree Node    navigationTree   ${TREE_PATH}|${MO_NAME} ${MO_NAME}   \#0
    Run Keyword And Ignore Error   Set Table Cell Value
    ...   identifier=Vertical plan and actual table   row=0   columnIdentifier=1   newValue=${origin_parameter}
    Click On Tree Node    navigationTree   ${TREE_PATH}|${MO_NAME} ${MO_NAME}   \#0
    Sleep    10s
    Switch to Application   alias=CM Operations Manager
    Wait Until Keyword Succeeds   1m   5s   swing.Select Main Window
    Clear Text Field   identifier=FilterTextField
    Insert Into Text Field   identifier=FilterTextField   text=${plan_name}
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait   menuPath=View|Refresh
    Wait Until Keyword Succeeds   3 times   10s   Get Table Values   identifier=PlanTable
    Wait Until Keyword Succeeds   3 times   10s   Click On Table Cell   identifier=PlanTable   row=0   column=0
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait   menuPath=Plan|Provision...
    Wait Until Keyword Succeeds	  3 times   10s   Select Window   identifier=Provision - ${plan_name}
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Start
    Select Dialog   Confirmation
    Wait Until Keyword Succeeds	  3 times   10s   Push Button   identifier=Yes
    Sleep   20s
    Wait Until Keyword Succeeds	  3 times   10s   Select Window   identifier=Provision - Activate: Finished - ${plan_name}
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   identifier=Close

Open Plan in CM Editor
    [Documentation]   Open Plan in CM Editor
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | planname | yes | the plan you want to open |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Open Plan in CM Editor | AC2000|
    [Arguments]  ${planname}
    wait until keyword succeeds  20s   5s   swing.Switch to Application   alias=CM Editor
    wait until keyword succeeds  10s   2s   swing.Select Main Window
    wait until keyword succeeds  20s   10s   swing.Select From Main Menu And Wait   menuPath=Plan|Open Plan...
    wait until keyword succeeds  10s   2s   swing.Select Dialog   identifier=Open Plan
    List Components In Context
    Insert Text to Target Field and Check   component=openPlanFilterTextField   text=${planname}
    List Components In Context
    wait until keyword succeeds  10s   2s   swing.Click On Component   identifier=0
    wait until keyword succeeds  10s   2s   swing.Send Keyboard Event   keyCode=VK_ENTER
    Sleep   10s
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Table Cell   identifier=openPlanPlanTable   row=0   column=0
    wait until keyword succeeds  3 times   5s   swing.Push Button   identifier=Open
    sleep   5s
    wait until keyword succeeds  10s   2s   swing.Select Main Window
    List Components In Context
    Component Should Exist   identifier=headerTextFieldName

Check if the Modified Parameter is Right in CM Editor Plan
    [Documentation]   Check if the Modified Parameter is Right in CM Editor Plan
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | modified_parameter | yes | modified parameter |
    ...   | key | yes | key of parameter |
    ...   | value | yes | value of parameter |
    ...   | table_name | yes | table name |
    ...   | column_name | yes | name of parameter |
    ...   | Tree_name | yes | name of MO located |
    ...   | Root_Folder | yes | path of MO |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Check if the Modified Parameter is Right in CM Editor Plan | current_value | Parameter | BTS name |
    ...   Vertical plan and actual table | Planned value | navigationTree |
    ...   Opened Plans|planname|Managed Objects|PLMN-PLMN|${MO_NAME} ${MO_NAME} |
    [Arguments]  ${modified_parameter}   ${key}   ${value}   ${table_name}   ${column_name}   ${Tree_name}   ${Root_Folder}
    List Components In Context
    wait until keyword succeeds  20s   5s   swing.Switch to Application    alias=CM Editor
    wait until keyword succeeds  10s   2s   swing.Select Main Window
#    Sleep   10s
#    List Components In Context
#    ${nodes}   Set Variable   ${Root_Folder.split('|')}
#    wait until keyword succeeds  3 times   5s   swing.Expand Tree Node    ${Tree_name}    ${nodes[0]}|${nodes[1]}
#    wait until keyword succeeds  3 times   5s   swing.Expand Tree Node    ${Tree_name}    ${nodes[0]}|${nodes[1]}
#    wait until keyword succeeds  3 times   5s   swing.Collapse Tree Node    ${Tree_name}    ${nodes[0]}|${nodes[1]}
#    sleep   10s
#    wait until keyword succeeds  3 times   2s   swing.Select Tree Node   ${Tree_name}   ${nodes[0]}|${nodes[1]}
    Expand Tree Node and Select node in CM application   tree_name=${Tree_name}   node_path=${Root_Folder}   component_name=${table_name}
    wait until keyword succeeds  20s   10s   swing.Select From Main Menu And Wait    menuPath=View|Refresh Tree
    sleep   10s
    &{condition}   Create Dictionary   ${key}=${value}
    run keyword and ignore error   swing.Get Table Values   identifier=${table_name}
    ${table_cell}   Get Table Value By Condition   table_name=${table_name}   condition=${condition}   column=${column_name}
    ${cell_column}   Set Variable   ${table_cell[0]['column']}
    ${cell_row}   Set Variable   ${table_cell[0]['row']}
    ${parameter_value_of_plan}    swing.Get Table Cell Value   identifier=${table_name}   row=${cell_row}   columnIdentifier=${cell_column}
    should be equal  ${parameter_value_of_plan}   ${modified_parameter}

Open CM Application
    [Arguments]   ${app_name}
    ${remote_port}   Open Application    app_name=${app_name}
    Select Main Window
    Wait Until Keyword Succeeds    1m    3s    Menu Item Should Exist    menuPath=File
    Run Keyword And Ignore Error   swing.Set Jemmy Timeouts   timeout=40
    [Return]   ${remote_port}

Close CM Application
    [Timeout]   2m
    [Arguments]   ${app_name}
    swing.Switch To Application   alias=${app_name}
    Sleep   10s
    swing.Close All Dialogs
    swing.Select From Main Menu   menuPath=File|Exit

Insert Text to Target Field and Check
    [Documentation]   Insert Text to Target Field and Check if the text is wrote on the field
    ...    Author: shengyuan.jiang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | component | yes | the component name of the target field |
    ...   | text | yes | text will be inserted into terget field |
    ...    *RETURN VALUE*
    ...    no
    ...    Example
    ...    |  Insert Text to Target Field and Check | 0 | planname |
    [Arguments]    ${component}   ${text}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    swing.Text Field Should Be Enabled   identifier=${component}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    swing.Clear Text Field   identifier=${component}
    Wait Until Keyword Succeeds    10s    2s    swing.Insert Into Text Field   identifier=${component}   text=${text}
    ${text_inserted}    Wait Until Keyword Succeeds   10s   2s   swing.Get Text Field Value   identifier=${component}
    Should Be Equal As Strings   ${text_inserted}   ${text}

Execute Send To Network And Verify The Status
    [Arguments]   ${tree_path}   ${mo_name}
    Click On Tree Node   navigationTree   ${tree_path}   \#0
    Select From Popup Menu On Selected Tree Nodes   identifier=navigationTree   menuPath=Send to Network
    Select Dialog   identifier=CM Editor
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=OK
    Wait Until Keyword Succeeds   3 times   10s
    ...   swing.Select Window   identifier=Provision - Activate: Finished - Modify ${mo_name} ${mo_name}
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   Push Button   identifier=Close
    
Remove gNB Module registration
    [Arguments]   ${MO_name}
    Wait Until Keyword Succeeds   3 times   10s   CM Editor Select gNB Module   ${MO_name}
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait   Tools|Open Workflow Engine For Selected MO(s)...
    Select Window   Workflow Engine
    sleep   10s
    Select From Combo Box	  OperationListComboBox	  NE data deletion from Configurator
    sleep   10s
    Push Button	  Start
    Select Dialog   Confirmation
    sleep   2s
    Push Button	  Yes
    Sleep   10s
    Wait Until Keyword Succeeds   3 times   15s   Select Window   NE data deletion from Configurator: Finished
    Push Button   Close
    Select Window   Workflow Engine
    sleep   2s
    Push Button   Close
    Sleep   10s

NetAct CM Operation remove gNB Module
    selenium_netact.switch_to_page   Start Page
    Show All Applications
    ${remote_port}   Open Application   CM Editor
    CM Editor Select gNB Module   MRBTS-${BTS_ID}
    Remove gNB Module registration   MRBTS-${BTS_ID}
    [Teardown]   Close Java Application by Remote Port   ${remote_port}
