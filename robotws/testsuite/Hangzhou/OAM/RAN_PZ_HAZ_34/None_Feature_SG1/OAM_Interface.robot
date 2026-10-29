*** Settings ***
Documentation     author: SkyMei
...                 contact: sky.mei@nokia-sbell.com
...                 COAM and NetAct related to Classicalbts.

Resource        ../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library         OAM_Interface.py
Library         OAM_Interface.netact_extend     WITH NAME     selenium_netact
#Resource        ../common/taf_megazone.robot
#Library         RemoteSwingLibrary    WITH NAME    RSL
Library         taf.ul.swing.core     WITH NAME    RSL
#Resource       ../common/taf_coam.robot
#Resource       ../common/NetAct_selenium.robot
Resource        ../common/NetAct_swing.robot
Resource        ../common/NetAct_ssh.robot
Library         taf.fdsw.rc    WITH NAME    rc

*** Variables ***
&{app_port_mapping}   Monitor=&{monitor_def}   Software Manager=&{sw_manage_def}   CM Operations Manager=&{cm_upload_def}
...   CM Editor=&{cm_editor_def}    CM Analyzer=&{cm_analyzer_def}
&{monitor_def}   app=start.jnlp   port=34221
&{sw_manage_def}   app=webstart.jnlp   port=34222
&{cm_upload_def}   app=racpmc.jnlp   port=34223
&{cm_editor_def}   app=cmedit.jnlp   port=34224
&{cm_analyzer_def}  app=rulche.jnlp  port=34226
${COAM_LOGIN}    false
${NETACT_LOGIN}    false
${FDSW_LOGIN}    false
*** Keywords ***
FDSW.Connect
    Run Keyword If   '${FDSW_LOGIN}'=='true'    rc.teardown
    ${con}   Wait until keyword succeeds     10min    30s   rc.connect_to
    ...    ip_address=${ASIK_IP}    port=443    username=Nemuadmin    password=nemuuser
    set suite variable    ${FDSW_LOGIN}    true
    [Return]       ${con}
FDSW.DisConnect
    Return From Keyword if    '${FDSW_LOGIN}'=='false'
    Run Keyword And Ignore error    rc.teardown
    set suite variable    ${FDSW_LOGIN}    false
FDSW.EnableSSH
    [Arguments]    ${con}
    rc.enable_ssh_service     connection=${con}
FDSW.CheckKeyValue
    [Arguments]   ${keys}    ${values}    ${con}
    ${res}=    fdsw_oam_extend.fetch_value_by_checkkey    conn=${con}    checkkeys=@{keys}
    Should Be Equal   ${res}   ${values}
FDSW.GetActiveSWversion
    [Arguments]    ${con}
    ${param}    rc.get_active_sw_version_name   connection=${con}
    [Return]       ${param}
FDSW.SetParameters
    [Arguments]    ${con}    ${parameters}    ${scenario}=private network manual
#    [Arguments]    ${parameters}
#    rc.set_autoconnection_parameters    @{parameters}
#    [Arguments]  ${protocol}  ${primary_ip_address}  ${primary_prefix_length}  ${primary_gateway}
#     ...    ${identification_entity_ip_address}
#     ...    ${ip_address}  ${server_port}  ${subject_name}
#     ...    ${directory}   ${vpn_gateway_ip_address}    ${con}
    rc.set_autoconnection_parameters_to_default
    ...    primary_ip_address=${parameters['IPs']['primary_ip_address']}
    ...    primary_prefix_length=${parameters['IPs']['primary_prefix_length']}
    ...    primary_gateway=${parameters['IPs']['primary_gateway']}
    ...    identification_entity_ip_address=${parameters['IPs']['identification_entity_ip_address']}
#    ...    primary_vlan_id=${parameters['IPs']['primary_vlan_id']}
#    ...    secondary_ip_address=${parameters['IPs']['secondary_ip_address']}
#    ...    secondary_prefix_length=${parameters['IPs']['secondary_prefix_length']}
#    ...    secondary_vlan_id=${parameters['IPs']['secondary_vlan_id']}
    ...    ip_address=${parameters['Security']['CMPServer']}
    ...    server_port=${parameters['Security']['CMPPort']}
    ...    subject_name=${parameters['Security']['CMPSubject']}
    ...    directory=${parameters['Security']['CMPDir']}
    ...    vpn_gateway_ip_address=${parameters['Security']['VNPGateway']}
    ...    timeout=10
    ...    protocol=${parameters['protocol']}
    ...    scenario=${scenario}
    ...    connection=${con}
FDSW.SetBTSID
    [Arguments]    ${btsID}=MRBTS-1964    ${con}=con
    rc.set_site_identification    autoconnection_site_id=${btsID}
#    ${ID}    rc.get_site_identification_siteId
#    should be equal   ${ID}    ${btsID}
COAM.Login
    [Documentation]    {WEBUI_URL} {WEBUI_USERNAME} {WEBUI_PASSWORD} is needed
    COAM_WebEM.Login

COAM.Logout
    COAM_WebEM.Logout

COAM.GetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${distName}    filter_param=${abbr}
    [Return]       ${value}

COAM.SetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name    ${value}=TL012
    Wait Until Keyword Succeeds    3 times    30s
    ...   selenium_coam.set_parameter_value   dist_name=${distName}   filter_param=${abbr}   new_value=${value}

COAM.DeleteParameter
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.delete_parameter    dist_name=${distName}    filter_param=${abbr}

COAM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    #${error}    selenium_megazone.get_validation_error
    #log    ${error}
    #should be empty    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

COAM.GetCellInfo
    [Arguments]    ${idx}=1
    ${info}    selenium_coam.get_cell_info    cell_idx=${idx}
    [Return]     ${info}

COAM.EnableSSH
    log    COAM.EnableSSH
    selenium_coam.enable_ssh_service

COAM.DisableSSH
    log    COAM.DisableSSH
    selenium_coam.disable_ssh_service

Netact.OpenStartPage
    [Arguments]   ${url}   ${username}   ${password}   ${showall}=${true}
    Set Suite Variable   ${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
    Run Keyword And Ignore Error   selenium_netact.Set Download Dir   download_dir=${WEB_DOWNLOAD_DIR}
    Wait Until Keyword Succeeds   10m   1m   selenium_netact.Login   url=${url}   username=${username}   password=${password}
    Run Keyword If    ${showall}    Netact.ShowAllAPP
    ...    ELSE    selenium_netact.wait for visibility   //a[contains(@folder, 'onfiguration')]
Netact.ShowAllAPP
    selenium_netact.Click Button    button_xpath=//a[@id='linkShowAppFolder']
    selenium_netact.Click Button    button_xpath=//a[@class='menuItem2']
NetAct.Login
    [Documentation]  use URL username and password to login
    [Arguments]   ${url}   ${username}   ${password}   ${showall}=${true}
    Run Keyword If   '${NETACT_LOGIN}'=='true'    NetAct.Logout
    Sleep   5
    Run Keyword And Ignore error    selenium_netact.enable_virtual_display
    Run Keyword And Ignore error    Netact.OpenStartPage    url=${url}   username=${username}
    ...    password=${password}   showall=${showall}
    set suite variable    ${NETACT_LOGIN}    true
    Sleep   10
NetAct.Logout
    Return From Keyword if    '${NETACT_LOGIN}'=='false'
    Run Keyword And Ignore error    selenium_netact.logout
    Run Keyword And Ignore error    selenium_netact.disable_virtual_display
    Run Keyword And Ignore error    selenium_netact.destory_netact
    set suite variable    ${NETACT_LOGIN}    false
NetAct.StartApp
    [Documentation]  App name should be Monitor or Software Manager or CM Operations Manager orCM Editor
    [Arguments]   ${app_name}
    Open Application    ${app_name}   directly   ${EMPTY}   ${EMPTY}
NetAct.SWM.Open
    [Documentation]    WebOpenSoftwareManager
    Wait until keyword succeeds     3times   60s    NetAct.Login
    ...    url=${HZ_NETACT_URL}    username=${HZ_NETACT_USER}   password=${HZ_NETACT_PASSWORD}    showall=false
    selenium_netact.open_configuration_software_manager
    sleep    5s
NetAct.SWM.Upload
    [Arguments]   ${Path}
    ${result}    NetAct.Upload NetAct image    file_path=${Path}
    [Return]     ${result}
NetAct.CloseApp
    [Documentation]  App name should be Monitor or Software Manager or CM Operations Manager orCM Editor
    [Arguments]   ${app_name}
    Close CM App    ${app_name}
NetAct.SelectCMEditor
    Run Keyword And Ignore error    swing.Switch to Application    CM Editor
    Run Keyword And Ignore error    swing.Select Main Window
    Sleep  2s
NetAct.SelectCMOperationManager
    Run Keyword And Ignore error    swing.Switch to Application    CM Operations Manager
    Run Keyword And Ignore error    swing.Select Main Window
    Sleep  2s
NetAct.CM.SelectgNB
    [Documentation]   find the node path for bts_name
    [Arguments]   ${bts_name}
    swing.Select Main Window
    Wait Until Keyword Succeeds    1m    10s    swing.Menu Item Should Exist    File
#    swing.Collapse Tree Node    navigationTree    Opened Plans
    ${node_path}  NetAct.CM Editor Select gNB    MO_NAME=${bts_name}
    swing.List Components In Context
    Sleep  5
    ${INODE}   ${BTSNode}   Split String From Right    string=${node_path}   separator=|     max_split=1
    set global variable    ${BTSPATH}    ${node_path}
    set global variable    ${INODE}    ${INODE}
    ${BTSAlias}    NetAct.CM.GetBTSAliasName
    set global variable    ${BTSALIAS}   ${BTSAlias}
    [return]    ${node_path}
NetAct.CM.GetCellNodeName
    [Arguments]   ${MO_BTS}    ${MO_CELL}
    FOR    ${i}    IN RANGE    10
        NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}|${MO_BTS}
        ${nodes}   _Search All tree nodes CM upload    0
        ${node_index}  ${node_name}   NetAct.Search dedicated node index CM upload   nodes=${nodes}   node_name=${MO_CELL}
        Run Keyword If    ${node_index}<0    Sleep    5
        Continue For Loop If   ${node_index}<0
    END
    Run Keyword If    ${node_index}<0     Fail   Can't Find ${MO_CELL}
    [Return]    ${node_name}
NetAct.CM.OpenStatistics
    [Arguments]     ${create_plan}=false   ${name}=TA_GEN_${MO_BTS_NAME}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}
    Wait Until Keyword Succeeds    3 times    10s    SWING.selectFromMainMenu    Tools|Run CM Analyzer Check...
    Wait Until Keyword Succeeds    3 times    10s    swing.Select Dialog    CM Analyzer check
    Run Keyword If   '${create_plan}'=='true'    Sleep   5
    Run Keyword If   '${create_plan}'=='true'    swing.List Components In Context
    Run Keyword If   '${create_plan}'=='true'    Run Keyword And Ignore error    swing.Select Tab    Post-Check Actions
    Run Keyword If   '${create_plan}'=='true'    Wait Until Keyword Succeeds    3 times    10s  swing.Check Check Box    3
    Run Keyword If   '${create_plan}'=='true'    Wait Until Keyword Succeeds    3 times    10s  swing.Insert Into Text Field  2  ${name}
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    DefinerViewOKButton
    Wait Until Keyword Succeeds    3 times    10s    swing.Select Dialog    CM Analyzer Check Results
    Sleep   5
NetAct.CM.GetStatistics
    #Errors, Warnings, Notes
    [Arguments]   ${item}=SyncNameToCellName    ${type}=Warnings
    FOR    ${i}    IN RANGE    10
        Run Keyword And Ignore error   swing.Get Table Row Count    1
        ${row}    swing.Find Table Row    1    ${item}
        Exit For Loop IF    ${row}>=0
        Sleep   2
    END
    ${info}    Run Keyword If   '${type}'=='Errors'    swing.Get Table Cell Value    1   ${row}    1
    ...    ELSE IF            '${type}'=='Warnings'    swing.Get Table Cell Value    1   ${row}    2
    ...    ELSE IF            '${type}'=='Notes'       swing.Get Table Cell Value    1   ${row}    3
    ...    ELSE               Set Variable    0
    [Return]     ${info}
NetAct.CM.FindTableRow
    #Errors, Warnings, Notes
    [Arguments]    ${key}=Name    ${column}=0   ${table}=Vertical actual table
    ${rowCount}   swing.Get Table Row Count    ${table}
    FOR    ${i}    IN RANGE    ${rowCount}
        log    ${i}
        ${rowValue}    swing.Get Table Cell Value    ${table}   ${i}    ${column}
        Exit For Loop IF    '${rowValue}'=='${key}'
    END
    [Return]     ${i}
NetAct.CM.SetBTSNameAndActive
    [Arguments]   ${newName}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  BTS name
    NetAct.CM.EnableModify
    Sleep  5
    ${row}    NetAct.CM.FindTableRow    BTS name
    NetAct.CM.SetTableValue  Vertical actual table  ${row}  1  ${newName}
    Sleep  5
    ${title}    Set Variable    ${MO_BTS_NAME} ${BTSAlias}
    NetAct.CM.ActiveValueUntilSuccess    ${BTSPATH.strip()}   ${title}
NetAct.CM.GetBTSName
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  BTS name
    Sleep  1
    ${row}    NetAct.CM.FindTableRow    BTS name
    Sleep  2
    ${btsName}    NetAct.CM.GetTableValue  Vertical actual table  ${row}  1
    [return]    ${btsName}
NetAct.CM.GetBTSNameByPath
    [Arguments]   ${path}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${path.strip()}
    Sleep  5
    NetAct.CM.FilterByName  BTS name
    Sleep  1
    ${row}    NetAct.CM.FindTableRow    BTS name
    Sleep  2
    ${btsName}    NetAct.CM.GetTableValue  Vertical actual table  ${row}  1
    [return]    ${btsName}
NetAct.CM.SetCellNameAndActive
    [Arguments]   ${MO_BTS}    ${MO_CELL}    ${cell_name}
    ${CELLNode}    NetAct.CM.GetCellNodeName   ${MO_BTS}    ${MO_CELL}
    ${CELLPATH}     Set Variable    ${BTSPATH.strip()}|${MO_BTS}|${CELLNode}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${CELLPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Cell name
    NetAct.CM.EnableModify
    Sleep  5
    ${row}    NetAct.CM.FindTableRow    Cell name
    ${len}    Get Length    ${cell_name}
    Run Keyword If    ${len}==0
    ...    swing.Select From Table Cell Popup Menu    Vertical actual table  ${row}  1  Plan empty value
    ...    ELSE
    ...    NetAct.CM.SetTableValue  Vertical actual table  ${row}  1  ${cell_name}
    Sleep  5
    ${title}    Set Variable    ${MO_CELL} in ${MO_BTS_NAME} ${BTSAlias}
    NetAct.CM.ActiveValueUntilSuccess    ${CELLPATH.strip()}   ${title}
NetAct.CM.GetCellName
    [Arguments]   ${MO_BTS}    ${MO_CELL}
    ${CELLNode}    NetAct.CM.GetCellNodeName   ${MO_BTS}    ${MO_CELL}
    ${CELLPATH}     Set Variable    ${BTSPATH.strip()}|${MO_BTS}|${CELLNode}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${CELLPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Cell name
    Sleep  2
    ${row}    NetAct.CM.FindTableRow    Cell name
    Sleep  2
    ${CellName}  NetAct.CM.GetTableValue    Vertical actual table  ${row}  1
    [return]    ${CellName}
NetAct.CM.SetBTSAliasNameAndActive
    [Arguments]   ${newName}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Name
    NetAct.CM.EnableModify
    Sleep  5
    ${row}    NetAct.CM.FindTableRow    Name
    ${len}    Get Length    ${newName}
    Run Keyword If    ${len}==0
    ...    swing.Select From Table Cell Popup Menu    Vertical actual table  ${row}  1  Plan empty value
    ...    ELSE
    ...    NetAct.CM.SetTableValue  Vertical actual table  ${row}  1  ${newName}
    Sleep  5
    ${title}    Set Variable    ${MO_BTS_NAME} ${BTSAlias}
    NetAct.CM.ActiveValueUntilSuccess    ${BTSPATH.strip()}   ${title}
    set global variable    ${BTSPATH}    ${INODE}|${MO_BTS_NAME} ${newName}
    set global variable    ${BTSALIAS}   ${newName}
NetAct.CM.GetBTSAliasName
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${BTSPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Name
    Sleep  2
    ${row}    NetAct.CM.FindTableRow    Name
    Sleep  2
    ${alias}    NetAct.CM.GetTableValue  Vertical actual table  ${row}  1
    [return]    ${alias}
NetAct.CM.GetBTSAliasNameByPath
    [Arguments]   ${path}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${path.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Name
    ${row}    NetAct.CM.FindTableRow    Name
    Sleep  2
    ${alias}    NetAct.CM.GetTableValue  Vertical actual table  ${row}  1
    [return]    ${alias}
NetAct.CM.SetCellAliasNameAndActive
    [Arguments]   ${MO_BTS}    ${MO_CELL}    ${cell_name}
    ${CELLNode}    NetAct.CM.GetCellNodeName   ${MO_BTS}    ${MO_CELL}
    ${CELLPATH}     Set Variable    ${BTSPATH.strip()}|${MO_BTS}|${CELLNode}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${CELLPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName  Name
    NetAct.CM.EnableModify
    Sleep  5
    ${row}    NetAct.CM.FindTableRow    Name
    ${len}    Get Length    ${cell_name}
    Run Keyword If    ${len}==0
    ...    swing.Select From Table Cell Popup Menu    Vertical actual table  ${row}  1  Plan empty value
    ...    ELSE
    ...    NetAct.CM.SetTableValue  Vertical actual table  ${row}  1  ${cell_name}
    Sleep  5
    ${title}    Set Variable    ${MO_CELL} in ${MO_BTS_NAME} ${BTSAlias}
    NetAct.CM.ActiveValueUntilSuccess    ${CELLPATH.strip()}   ${title}
NetAct.CM.GetCellAliasName
    [Arguments]   ${MO_BTS}    ${MO_CELL}
    ${CELLNode}    NetAct.CM.GetCellNodeName   ${MO_BTS}    ${MO_CELL}
    ${CELLPATH}     Set Variable    ${BTSPATH.strip()}|${MO_BTS}|${CELLNode}
    NetAct.CM.ExpandAndClickTreeNode    TreeNode=${CELLPATH.strip()}
    Sleep  5
    NetAct.CM.FilterByName   Name
    Sleep  2
    ${row}    NetAct.CM.FindTableRow    Name
    Sleep  2
    ${CellName}  NetAct.CM.GetTableValue    Vertical actual table  ${row}  1
    [return]    ${CellName}
NetAct.CM.ExpandAndClickTreeNode
    [Arguments]   ${TreeNode}
    swing.Select Main Window
    @{Nodes}    Split String    ${TreeNode}    separator=|
    ${Path}     Set Variable    ${EMPTY}
    FOR    ${Node}    IN    @{Nodes}
        ${Path}    Set Variable  ${Path}${Node}
        Wait Until Keyword Succeeds   3 times   5s   swing.Click On Tree Node   navigationTree    ${Path}    \#0
        Wait Until Keyword Succeeds   3 times   5s   swing.Expand Tree Node     navigationTree    ${Path}    \#0
        ${Path}    Set Variable  ${Path}|
    END

NetAct.CM.OpenPlan
    [Arguments]     ${name}
    swing.Click On Tree Node    navigationTree    Opened Plans
    swing.Select From Popup Menu On Selected Tree Nodes    navigationTree    Open Plan...
    Sleep    5s
#    swing.List Components In Context
    swing.List Windows
    Run Keyword And Ignore error    Wait Until Keyword Succeeds    2m   10s   swing.Select Dialog   Open Plan
    swing.List Components In Context
    Sleep    5s
    swing.Clear Text Field    openPlanFilterTextField
    Sleep    5s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Insert Into Text Field   openPlanFilterTextField   ${name}
    Sleep    5s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${rowCount}   swing.Get Table Row Count    openPlanPlanTable
    ${row}    swing.Find Table Row    openPlanPlanTable    ${name}
    swing.Click On Table Cell    openPlanPlanTable    ${row}    0
    Sleep    2s
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    openPlanBtnOpen
    Sleep    15s
#NetAct.CM.SetPluginVersion
#    [Arguments]     ${name}    ${version}    ${node}
#    swing.Select Main Window
#    ${value}    Run Keyword And Ignore error
#    ...    NetAct.CM.ExpandAndClickTreeNode     TreeNode=Opened Plans|${name}|Managed Objects|${node}|mnl-1
#    Run Keyword If   '${value[0]}'!='PASS'
#    ...    NetAct.CM.ExpandAndClickTreeNode     TreeNode=Opened Plans|${name}|Managed Objects|${node}|MNL-1
#    Sleep    5s
#    swing.List Components In Context
#    ${row}    NetAct.CM.FindTableRow    key=Planned software release version    column=0    table=Vertical plan and actual table
#    NetAct.CM.SetTableValue  table=Vertical plan and actual table  row=${row}  column=1  value=${version}
#    Sleep    2s
#    swing.Send Keyboard Event     VK_ENTER
NetAct.CM.SetPluginVersion
    [Arguments]     ${name}    ${version}    ${node}
    swing.Select Main Window

    ${value}    Run Keyword And Ignore error
    ...    NetAct.CM.ClickTreeNode     preTree=Opened Plans|${name}|Managed Objects|PLMN-PLMN     MO_NAME=${node}    tailTree=mnl-1
    Run Keyword If   '${value[0]}'!='PASS'
    ...    NetAct.CM.ClickTreeNode     preTree=Opened Plans|${name}|Managed Objects|PLMN-PLMN     MO_NAME=${node}    tailTree=MNL-1
    Sleep    5s
    swing.List Components In Context
    ${row}    NetAct.CM.FindTableRow    key=Planned software release version    column=0    table=Vertical plan and actual table
    NetAct.CM.SetTableValue  table=Vertical plan and actual table  row=${row}  column=1  value=${version}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
NetAct.CM.ClickTreeNode
    [Arguments]     ${preTree}    ${MO_NAME}    ${tailTree}
    swing.Select Main Window
    NetAct.CM.ExpandAndClickTreeNode     TreeNode=${preTree}
    Sleep    5s
    ${nodes}   swing.Get Tree Node Child Names   navigationTree   ${preTree}
    ${mid_node_not_exist}   is_mo_in_node_list   ${MO_NAME}   ${nodes}
    ${mid_node}  Run Keyword If   not ${mid_node_not_exist}   NetAct._Exppand BTS Scope   ${MO_NAME}   ${nodes}
    ...   ELSE   Set Variable   ${EMPTY}
    run keyword if  not '${mid_node}'==''   Run Keywords   Wait Until Keyword Succeeds   3 times   5s
    ...   swing.Click On Tree Node   navigationTree   ${preTree}|${mid_node}
    ...   AND   swing.Expand Tree Node   navigationTree   ${preTree}|${mid_node}
    #${nodes}   Get Tree Node Child Names   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}
    ${nodes}   _Search All tree nodes CM upload    0
    ${node_index}  ${node_name}   NetAct.Search dedicated node index CM upload   ${nodes}   ${MO_NAME}
    ${node_path}   Run Keyword If   ${node_index} >= ${0}   Set Variable   ${preTree}|${mid_node}${node_name}
    ...   ELSE   Fail    Can't find ${MO_NAME}
    NetAct.CM.ExpandAndClickTreeNode     TreeNode=${node_path}|${tailTree}
    log to console     ${node_path}|${tailTree}
    [Return]   ${node_path}|${tailTree}
NetAct.CMOperationManager.CreatAndValidatePnPPlan
    [Arguments]     ${filename}     ${PlanName}=TA_PnP_TL11
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
#    swing.Insert Into Text Field    FilterTextField     ${PlanName}
#    Sleep    2s
#    swing.Send Keyboard Event     VK_ENTER
#    Sleep    5s
    swing.Select From Main Menu And Wait    Tools|Workflow Engine...
    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Components In Context
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Exist    Start
    swing.Get Combobox Values      OperationListComboBox
    swing.Select From Combo Box    OperationListComboBox    Unified PnP - Direct Integration Planning
    Sleep   2s
    swing.List Components In Context

    swing.Click On Table Cell    OperationTable    3    1
#    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Sleep   10s
    swing.Insert Into Text Field    4    ${PlanName}
    swing.Insert Into Text Field    Input_File_Choose_Field     ${filename}
    Run Keyword And Ignore error    swing.Get Combobox Values      3
    swing.Select From Combo Box    3    Yes
    Sleep   2s
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    swing.List Windows
    swing.List Components In Context
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Create BTS configuration plan: Finished.*|^Unified PnP - COAM - Create BTS configuration plan: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Create Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Windows
    swing.Get Selected Window Title
    swing.List Components In Context
    swing.Click On Table Cell    OperationTable    5    1
    Sleep   10s
    #Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Validate configuration plan: Finished.*|^Unified PnP - COAM - Validate configuration plan: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Validate Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Windows
    swing.Get Selected Window Title
    swing.List Components In Context
    swing.Click On Table Cell    OperationTable    7    1
    Sleep   10s
    #Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    ${regexp}=    Set Variable
    ...    regexp=^Unified PnP - COAM - Activate autoidentification: Finished.*|^Unified PnP - COAM - Activate autoidentification: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Fail    Active Plan Failed.

    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button     CloseWorkflowButton
    log to console    Create Plan Success
NetAct.CMOperationManager.ImportPlan
    [Arguments]     ${FileName}     ${PlanName}=TA_PLAN_TL_${MRBTS_ID}
    NetAct.CMOperationManager.DeletePlan    name=${PlanName}
    NetAct.SelectCMOperationManager
    swing.Select From Main Menu And Wait    File|Import...
    ${regexp}=    Set Variable    regexp=^Import.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Components In Context
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Exist    StartButton
    swing.Insert Into Text Field    ImportPlanDataFileField     ${FileName}
    swing.Insert Into Text Field    NewPlanNameText     ${PlanName}
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    StartButton
    Timer.Start
    FOR    ${i}    IN RANGE    ${60}
        ${curr_status}   swing.Get label Content   12
         Run Keyword If   ${curr_status.count('Import finished')} > 0    exit for loop
        ...    ELSE    Sleep   1s
    END
    ${duration}   Timer.Stop
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    CloseImportButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   CloseImportButton
    [Return]    ${duration}

NetAct.CMOperationManager.Upload
    [Arguments]     ${MO_NAME}=${MRBTS_ID}
    NetAct.SelectCMOperationManager
    swing.Select From Main Menu And Wait    Upload|New Upload...
    ${regexp}=    Set Variable    regexp=^Upload.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    swing.List Components In Context
    swing.Select Tab   tabIdentifier=BSC
    FOR   ${i}    IN RANGE    9
       swing.Send Keyboard Event   keyCode=VK_RIGHT
    END
    swing.Select Tab   tabIdentifier=5G/LTE/SRAN
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component   identifier=SelectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component   identifier=DeselectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Expand All Tree Nodes   identifier=0

    ${nodes}   _Search All tree nodes CM upload    0
    ${node_index}  ${node_name}   NetAct.Search dedicated node index CM upload in CMUpload   ${nodes}   ${MO_NAME}
#    ${node_path}   Run Keyword If   ${node_index} >= ${0}   Set Variable   Actual Configuration|PLMN-PLMN|${mid_node}${node_name}
#    ...   ELSE   Fail    Can't find ${MO_NAME}
    Run Keyword If   ${node_index} < ${0}    Fail    Can't find ${MO_NAME}
#    ${nodes}   Search All tree nodes   tree_index=0
#    ${bts_index}   Search dedicated node index   nodes=${nodes}   node_name=PLMN-PLMN/MRBTS-${BTS_ID}
    swing.Click On Tree Node    0    ${node_index}    \#0
    Sleep   3s
    Wait Until Keyword Succeeds   3 times   10s   swing.Select Window   identifier=Upload
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Start
    Wait Until Keyword Succeeds    2m  5s    swing.Select Dialog   identifier=Confirmation
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Yes
    Timer.Start
    ${CM_finished}   Run Keyword And Return Status   Wait Until Keyword Succeeds   10 times   3s
    ...   swing.Select Window   identifier=Upload: Finished
    ${duration}   Timer.Stop
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   identifier=Close
    [Return]    ${duration}

NetAct.CMOperationManager.ActiveNewPlan
    [Arguments]     ${name}    ${pre_provision}=false
    ...     ${filter_method}=original
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Select From Table Cell Popup Menu	  PlanTable    0    0    Refresh
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${name}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${row}    swing.Find Table Row    PlanTable    ${name}
    swing.Select From Table Cell Popup Menu	  PlanTable    ${row}    0    Provision
    Sleep    2s
    Wait Until Keyword Succeeds	  18 times   10s    swing.Select Window    Provision - ${name}
    Sleep    2s
    swing.List Components In Context
    swing.Uncheck Check Box    ProvisionViewBackupPanel_BackupPlanCheckbox
    sleep    2s
    run keyword if   '${pre_provision}'=='true'    swing.Push Radio Button    ProvisionView_PreActivateRadioButton
    sleep    2s
    swing.Push Button     Start
    Sleep   2s
    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Yes
    Timer.Start
    ${title}    set variable if   '${pre_provision}'=='true'    Pre-Activate    Activate
#    ${CM_finished}	Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m  2s
#    ...   swing.Select Window    Provision - ${title}: Finished - ${name}
#        ${regexp}=    Set Variable
#        ...    regexp=^Provision - ${title}: Finished.*|^Provision - ${title}: Failed.*
    ${regexp}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*|^Provision - ${title}: Failed.*
    ${regexp1}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*
    ${CM_finished}    BuiltIn.Run Keyword If    '${filter_method}'=='original'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp}
    ...   ELSE IF   '${filter_method}'=='Other'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp1}
    ${duration}    Timer.Stop
    Sleep   3s
    ${regexp2}=    Set Variable    regexp=*Prepare Plan started*
    BuiltIn.Run Keyword If    '${CM_finished}'=='False'
    ...    Wait Until Keyword Succeeds	  2m   3s    swing.Select Window    ${regexp2}
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Close
    BuiltIn.should be true    ${CM_finished}    True
    [Return]    ${duration}

NetAct.CMOperationManager.Validation
    [Arguments]     ${name}    ${pre_provision}=false
    ...     ${filter_method}=original
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Select From Table Cell Popup Menu	  PlanTable    0    0    Refresh
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${name}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${row}    swing.Find Table Row    PlanTable    ${name}
    swing.Select From Table Cell Popup Menu	  PlanTable    ${row}    0    Provision
    Sleep    2s
    Wait Until Keyword Succeeds	  18 times   10s    swing.Select Window    Provision - ${name}
    Sleep    2s
    swing.List Components In Context
    swing.Uncheck Check Box    ProvisionViewBackupPanel_BackupPlanCheckbox
    sleep    2s
    run keyword if   '${pre_provision}'=='true'    swing.Push Radio Button    ProvisionView_PreActivateRadioButton
    sleep    2s
    swing.Push Button     Start
    Sleep   2s
    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Yes
    Sleep    5s
#    Timer.Start
    ${title}    set variable if   '${pre_provision}'=='true'    Pre-Activate    Activate
    ${regexp}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*|^Provision - ${title}: Failed.*
    ${regexp1}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*
    ${CM_finished}    BuiltIn.Run Keyword If    '${filter_method}'=='original'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp}
    ...   ELSE IF   '${filter_method}'=='Other'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp1}
#    ${duration}    Timer.Stop
    Sleep   3s
    ${regexp2}=    Set Variable    regexp=*Prepare Plan started*
    BuiltIn.Run Keyword If    '${CM_finished}'=='False'
    ...    Wait Until Keyword Succeeds	  2m   3s    swing.Select Window    ${regexp2}
    swing.List Components In Context
    ${RowCount}    swing.Get Table Row Count    FeedbackView_FeedbackTable
    ${RowIndex_s}    Set Variable    None
    ${RowIndex_e}    Set Variable    None
    FOR    ${i}    IN RANGE       ${RowCount}
        ${RowValue}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${i}    2
        ${result1}    run keyword and return status    should contain    ${RowValue}    validate started
        ${RowIndex_s}    Set Variable if    ${result1}   ${i}    ${RowIndex_s}
        ${result2}    run keyword and return status    should contain    ${RowValue}    Validation successful
        ${RowIndex_e}    Set Variable if    ${result2}   ${i}    ${RowIndex_e}
        ${result3}    run keyword and return status    should contain    ${RowValue}    Validation failed
        ${RowIndex_e}    Set Variable if    ${result3}   ${i}    ${RowIndex_e}
    END
    ${validation_start_tmp}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${RowIndex_s}    3
    ${validation_start_tmp}    convert date    ${validation_start_tmp}    epoch
    ${validation_end_tmp}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${RowIndex_e}    3
    ${validation_end_tmp}    convert date    ${validation_end_tmp}    epoch
    ${validation_duration}    Evaluate    ${validation_end_tmp}-${validation_start_tmp}
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Close
#    BuiltIn.should be true    ${CM_finished}    True
    [Return]    ${validation_duration}

NetAct.CMOperationManager.deltaPlanDownload
    [Arguments]     ${name}    ${pre_provision}=false
    ...     ${filter_method}=original
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Select From Table Cell Popup Menu	  PlanTable    0    0    Refresh
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${name}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${row}    swing.Find Table Row    PlanTable    ${name}
    swing.Select From Table Cell Popup Menu	  PlanTable    ${row}    0    Provision
    Sleep    2s
    Wait Until Keyword Succeeds	  18 times   10s    swing.Select Window    Provision - ${name}
    Sleep    2s
    swing.List Components In Context
    swing.Uncheck Check Box    ProvisionViewBackupPanel_BackupPlanCheckbox
    sleep    2s
    run keyword if   '${pre_provision}'=='true'    swing.Push Radio Button    ProvisionView_PreActivateRadioButton
    sleep    2s
    swing.Push Button     Start
    Sleep   2s
    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Yes
    Sleep    5s
#    Timer.Start
    ${title}    set variable if   '${pre_provision}'=='true'    Pre-Activate    Activate
    ${regexp}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*|^Provision - ${title}: Failed.*
    ${regexp1}=    Set Variable
    ...    regexp=^Provision - ${title}: Finished.*
    ${CM_finished}    BuiltIn.Run Keyword If    '${filter_method}'=='original'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp}
    ...   ELSE IF   '${filter_method}'=='Other'
    ...   BuiltIn.Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   3s
    ...   swing.Select Window    ${regexp1}
#    ${duration}    Timer.Stop
    Sleep   3s
    ${regexp2}=    Set Variable    regexp=*Prepare Plan started*
    BuiltIn.Run Keyword If    '${CM_finished}'=='False'
    ...    Wait Until Keyword Succeeds	  2m   3s    swing.Select Window    ${regexp2}
    swing.List Components In Context
    ${RowCount}    swing.Get Table Row Count    FeedbackView_FeedbackTable
    ${RowIndex_s}    Set Variable    None
    ${RowIndex_e}    Set Variable    None
    FOR    ${i}    IN RANGE       ${RowCount}
        ${RowValue}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${i}    2
        ${result1}    run keyword and return status    should contain    ${RowValue}    download started
        ${RowIndex_s}    Set Variable if    ${result1}   ${i}    ${RowIndex_s}
        ${result2}    run keyword and return status    should contain    ${RowValue}    Download Successful
        ${RowIndex_e}    Set Variable if    ${result2}   ${i}    ${RowIndex_e}
    END
    ${download_start_tmp}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${RowIndex_s}    3
    ${download_start_tmp}    convert date    ${download_start_tmp}    epoch
    ${download_end_tmp}    swing.Get Table Cell Value    FeedbackView_FeedbackTable    ${RowIndex_e}    3
    ${download_end_tmp}    convert date    ${download_end_tmp}    epoch
    ${download_duration}    Evaluate    ${download_end_tmp}-${download_start_tmp}
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Close
#    BuiltIn.should be true    ${CM_finished}    True
    [Return]    ${download_duration}

NetAct.CMOperationManager.PreActiveNewPlan
    [Arguments]     ${name}
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Select From Table Cell Popup Menu	  PlanTable    0    0    Refresh
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${name}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${row}    swing.Find Table Row    PlanTable    ${name}
    swing.Select From Table Cell Popup Menu	  PlanTable    ${row}    0    Provision
    Sleep    2s
    Wait Until Keyword Succeeds	  6m   10s    swing.Select Window    Provision - ${name}
    Sleep    2s
    swing.List Components In Context
    swing.Uncheck Check Box    ProvisionView_PreparePlanCheckbox
    sleep    2s
    swing.Push Radio Button    ProvisionView_PreActivateRadioButton
    sleep    2s
    swing.Uncheck Check Box    ProvisionViewBackupPanel_BackupPlanCheckbox
    sleep    2s
    swing.Push Button     ProvisionView_StartProvisionButton
    Sleep   2s
    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Yes
    ${regexp}=    Set Variable
    ...    regexp=^Provision - Pre-Activate: Finished.*|^Provision - Pre-Activate: Failed.*
    ${CM_finished}	Run Keyword And Return Status   Wait Until Keyword Succeeds	  6m   10s
    ...   swing.Select Window    ${regexp}
    Sleep   3s
    Wait Until Keyword Succeeds	  3 times   10s   swing.Push Button   Close

NetAct.CMOperationManager.NEDelete
    [Arguments]     ${BTSMO}=PLMN-PLMN/MRBTS-1964
    NetAct.SelectCMOperationManager
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${BTSMO}
    Sleep    2s
    swing.Select From Popup Menu    FilterTextField   Select All
    Sleep    2s
    swing.Select From Popup Menu    FilterTextField   Copy
    Sleep    2s
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Select From Main Menu And Wait    Tools|Workflow Engine...
    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window     ${regexp}
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Exist    Start
    swing.Get Combobox Values      OperationListComboBox
    swing.Select From Combo Box    OperationListComboBox    NE data deletion from Configurator
    Sleep   2s
    swing.List Components In Context
    swing.Select From Popup Menu    MOList   Paste
    Sleep    2
    swing.Click On Table Cell    OperationTable    0    1
#    Run Keyword And Ignore error    Log to console    TTTTTTTTT
    Sleep    5
    swing.Click On Table Cell    OperationTable    0    1
    Sleep   2s
    Wait Until Keyword Succeeds    2m    10s    swing.Button Should Be Enabled    Start
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Start
    Wait Until Keyword Succeeds    2m    10s    swing.Select Dialog   Confirmation
    swing.List Components In Context
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OperationConfirmationDialog_YESButton
    ${regexp}=    Set Variable
    ...    regexp=^NE data deletion from Configurator: Finished.*|^NE data deletion from Configurator: Failed.*
    Wait Until Keyword Succeeds    10m  10s  swing.Select Window    ${regexp}
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    FeedbackView_CloseButton
    Run Keyword If    '${status}'=='False'    Log to console    Ne Delete Failed
    ${regexp}=    Set Variable    regexp=^Workflow Engine.*
    Wait Until Keyword Succeeds    2m   10s   swing.Select Window  ${regexp}
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button     CloseWorkflowButton
    Log to console    Ne Delete Done
NetAct.CMOperationManager.DeletePlan
    [Arguments]     ${name}
    NetAct.SelectCMOperationManager
    swing.List Components In Context
    swing.Clear Text Field    FilterTextField
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    swing.Select From Table Cell Popup Menu	  PlanTable    0    0    Refresh
    Sleep    2s
    swing.Insert Into Text Field    FilterTextField     ${name}
    Sleep    2s
    swing.Send Keyboard Event     VK_ENTER
    Sleep    5s
    ${row}    swing.Find Table Row    PlanTable    ${name}
    return from keyword if    ${row}<${0}
    swing.Select From Table Cell Popup Menu	  PlanTable    ${row}    0    Delete
    Wait Until Keyword Succeeds    3 times    10s    Run Keyword And Ignore error    swing.Select Dialog    Confirmation
    Sleep    2s
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    ConfirmationDialogConfirmButton
NetAct.Monitor.SelectNode
    [Arguments]     ${mo_name}
    wait until keyword succeeds  20s   5s   swing.Switch to Application    Monitor
    wait until keyword succeeds  20s   2s   swing.Select Main Window
    swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep   5s
    wait until keyword succeeds  20s   5s   swing.Select Tree Node   Objects   ${mo_name}

NetAct.Monitor.CheckValue
    [Arguments]     ${NewRow}    ${name}
    ${BTSValue}    set variable    TEST
    FOR    ${i}    IN RANGE    ${NewRow}
        ${BTSValue}     swing.Get Table Cell Value    Operations History Table    ${i}    1
        ${StartTime}    swing.Get Table Cell Value    Operations History Table    ${i}    3
        ${EndTime}      swing.Get Table Cell Value    Operations History Table    ${i}    4
        Exit For Loop If   ${BTSValue.count('${name}')}>0
    END
    return from keyword if    ${BTSValue.count('TEST')}>0    ${0}
    ${StartTime}         convert date    ${StartTime}     epoch
    ${EndTime}           convert date    ${EndTime}       epoch
    ${duration}          Evaluate        ${EndTime}-${StartTime}
    [Return]    ${duration}

NetAct.Monitor.AlarmUpload
    [Arguments]     ${name}=[1]
    NetAct.Monitor.SelectNode  PLMN-PLMN|${name}
#    swing.List Components In Context
    swing.Click On Tree Node    Objects    PLMN-PLMN|${name}    \#0
    swing.Select From Popup Menu On Selected Tree Nodes    identifier=Objects    menuPath=Alarm Upload
    ${rowCount0}   swing.Get Table Row Count    Operations History Table
    ${duration}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${60}
         ${rowCount}   swing.Get Table Row Count    Operations History Table
         ${NewRow}     Evaluate    ${rowCount}-${rowCount0}
         ${duration}    NetAct.Monitor.CheckValue    NewRow=${NewRow}   name=${name}
         Exit For Loop If   ${duration}>${0}
         Sleep    2s
    END
    [Return]    ${duration}
#
#    swing.List Components In Context
#    ${rowCount}   swing.Get Table Row Count    Operations History Table
#    ${row}    swing.Find Table Row    Operations History Table    HTTPS
#    ${value}    swing.Get Table Cell Value    Operations History Table    2    2
#    ${value}    swing.Get Table Cell Value    Operations History Table    2    3
#    ${value}    swing.Get Table Cell Value    Operations History Table    2    4
NetAct.CM.GetTableValue
    [Documentation]  Get Vertical actual table value from row and column
    [Arguments]   ${table}=Vertical actual table    ${row}=0    ${column}=0
    ${value}    swing.Get Table Cell Value    ${table}    ${row}    ${column}
    [Return]    ${value}
NetAct.CM.SetTableValue
    [Arguments]    ${table}=Vertical actual table    ${row}=0    ${column}=1    ${value}=MRBTS
    swing.Set Table Cell Value    ${table}    ${row}    ${column}    ${value}
NetAct.CM.FilterByName
    [Arguments]    ${name}=name
    swing.Insert Into Text Field  parameters.by.MO.view.filter.filter_field  ${name}
NetAct.CM.EnableModify
    swing.Check Check Box    parameters.by.actual.view.modify
NetAct.CM.ActiveValueUntilSuccess
    [Arguments]   ${node_path}    ${title}
    swing.Click On Tree Node    navigationTree    ${node_path}
    swing.Select From Popup Menu On Selected Tree Nodes    navigationTree    Send to Network
    swing.Select Dialog    CM Editor
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    OK
    ${regexp}=    Set Variable
    ...    regexp=^Provision - Activate: Finished.*|^Provision - Activate: Failed.*
    Wait Until Keyword Succeeds    4m  10s  swing.Select Window   ${regexp}
    Wait Until Keyword Succeeds    2m  10s  swing.Button Should Be Disabled    Interrupt
    Wait Until Keyword Succeeds    2m  10s  swing.Select Window   ${regexp}
    #NeVe.Screenshot    Provision_window
    ${provStatus}=    swing.Get Selected Window Title
    log    ${provStatus}
    ${status}=    Run Keyword And Return Status    Should Contain    ${provStatus}    Finished
    Wait Until Keyword Succeeds    3 times    10s    swing.Push Button    Close
    Run Keyword If    '${status}'=='False'    Fail    ActiveValueUntilSuccess Failed
NetAct.LogServer.ClearLogFile
    [Arguments]     ${name}
    Conn.ConnectTo    ${NETACT_LOGSERVER_IP}    ${NETACT_LOGSERVER_USERNAME}    ${NETACT_LOGSERVER_PASSWORD}    ANETACT_LOGSERVER
    Conn.Execute    cmd=rm /d/oss/global/diagsnap/ne3sws/*${name}* -rf    alias=ANETACT_LOGSERVER
    Conn.Disconnect  ANETACT_LOGSERVER

NetAct.LogServer.Connect
    Conn.ConnectTo    ${NETACT_LOGSERVER_IP}    ${NETACT_LOGSERVER_USERNAME}    ${NETACT_LOGSERVER_PASSWORD}    ANETACT_LOGSERVER

NetAct.LogServer.Disconnect
    Conn.Disconnect  ANETACT_LOGSERVER

NetAct.LogServer.CheckLogFileName
    [Arguments]     ${name}
    Conn.ConnectTo    ${NETACT_LOGSERVER_IP}    ${NETACT_LOGSERVER_USERNAME}    ${NETACT_LOGSERVER_PASSWORD}    ANETACT_LOGSERVER
    ${result}    Conn.Execute    cmd=ls /d/oss/global/diagsnap/ne3sws |grep ${name}    alias=ANETACT_LOGSERVER
    Conn.Execute    cmd=rm /d/oss/global/diagsnap/ne3sws/*${name}* -rf    alias=ANETACT_LOGSERVER
    Conn.Disconnect  ANETACT_LOGSERVER
    should not be empty    ${result}
Conn.ConnectTo
    [Arguments]   ${IP}    ${username}    ${password}    ${alias}
    Wait Until Keyword Succeeds    10min    30sec   ssh.Connect to    ${IP}    ${username}    ${password}    alias=${alias}
Robot.RunKeywordMultiTimesToSuccess
    [Arguments]   ${keyword}   ${teardown}=${EMPTY}    ${times}=2
    FOR    ${i}    IN RANGE    ${times}
         ${res}    Run Keyword And Ignore error    ${keyword}
         Run Keyword And Ignore error    ${teardown}
         Return From Keyword if   '${res[0]}'=='PASS'
    END
    Fail  Run '${keyword}' failed after retry '${times}' times
gNB.CheckgNBReset
    ${status}    Run Keyword And Return Status    gNB.PingOAM
    Should Be True    '${status}'=='False'
WFT.DownloadPackage
    [Arguments]   ${link_to_Artifact}    ${filename}    ${md5}=false    ${UPDATE_FILE_PATH}=/opt/ute/5GC000092
    [Timeout]         20 minutes
    ${result}=   run    ls ${UPDATE_FILE_PATH}/${filename}
    ${result}=	 Remove String    ${result}    '
    Return From Keyword if     '${result}'=='${UPDATE_FILE_PATH}/${filename}'
    run    wget ${link_to_Artifact}${filename} -P ${UPDATE_FILE_PATH}
    run keyword if    '${md5}'=='true'    run    wget ${link_to_Artifact}/${filename}.md5 -P ${UPDATE_FILE_PATH}
    ${md5_src}    run keyword if    '${md5}'=='true'    run     md5sum ${UPDATE_FILE_PATH}/${filename}
    ${md5_dec}    run keyword if    '${md5}'=='true'    run     cat ${UPDATE_FILE_PATH}/${filename}.md5
    run keyword if    '${md5}'=='true'    should contain    ${md5_src}    ${md5_dec}
    ${result}=   run    ls ${UPDATE_FILE_PATH}/${filename}
    ${result}=	 Remove String    ${result}    '
    Should Be True    '${result}'=='${UPDATE_FILE_PATH}/${filename}'
#--------------Internal redefination----------------------------------------------------
#redefine for Java path
#NetAct.Open Application
#    [Arguments]   ${app_name}   ${start}=directly   ${keyword_name}=${EMPTY}   ${keyword_params}=${EMPTY}
#    ${app_file}   Set Variable   ${app_port_mapping['${app_name}']['app']}
#    ${app_path}   Set Variable   ${WEB_DOWNLOAD_DIR}/${app_file}
#    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${app_path}
#    Run Keyword If   ${file_exists}   OperatingSystem.Remove File   ${app_path}
#    ${remote_port}   Set Variable   ${${app_port_mapping['${app_name}']['port']}}
#    Wait Until Keyword Succeeds   3 times   5s   Action download JAVA app   ${app_name}   ${app_path}   ${start}
#    ...   ${keyword_name}   ${keyword_params}
#    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${app_path}
#    ${java_path}   OperatingSystem.Run   ls /usr/lib/jvm | grep jre-8-oracle-x64
#    ${java_env}   Set Variable   /usr/lib/jvm/${java_path}/bin/javaws
#    swing.Setup    javaws_path=${java_env}
#    Run Keyword and Ignore Error   Close Java Application by Remote Port   ${remote_port}
#    Start Java app   ${app_path}   ${remote_port}   ${app_name}
#    [Return]   ${remote_port}
#redefine for gNB path
NetAct.CM Editor Select gNB
    [Arguments]   ${MO_NAME}
    swing.Select Main Window
    Wait Until Keyword Succeeds   3 times   5s   swing.Click On Tree Node   navigationTree   Actual Configuration    \#0
    swing.Expand Tree Node   navigationTree   Actual Configuration    \#0
    Wait Until Keyword Succeeds   3 times   5s   swing.Click On Tree Node   navigationTree   Actual Configuration|PLMN-PLMN    \#0
    swing.Expand Tree Node   navigationTree   Actual Configuration|PLMN-PLMN    \#0
    Sleep   3s
    ${nodes}   swing.Get Tree Node Child Names   navigationTree   Actual Configuration|PLMN-PLMN
    ${mid_node_not_exist}   is_mo_in_node_list   ${MO_NAME}   ${nodes}
    ${mid_node}  Run Keyword If   not ${mid_node_not_exist}   NetAct._Exppand BTS Scope   ${MO_NAME}   ${nodes}
    ...   ELSE   Set Variable   ${EMPTY}
    run keyword if  not '${mid_node}'==''   Run Keywords   Wait Until Keyword Succeeds   3 times   5s
    ...   swing.Click On Tree Node   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}    \#0
    ...   AND   swing.Expand Tree Node   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}    \#0
    #${nodes}   Get Tree Node Child Names   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}
    ${nodes}   _Search All tree nodes CM upload    0
    ${node_index}  ${node_name}   NetAct.Search dedicated node index CM upload   ${nodes}   ${MO_NAME}
    ${node_path}   Run Keyword If   ${node_index} >= ${0}   Set Variable   Actual Configuration|PLMN-PLMN|${mid_node}${node_name}
    ...   ELSE   Fail    Can't find ${MO_NAME}
    Wait Until Keyword Succeeds   3 times   5s   swing.Click On Tree Node   navigationTree
    ...   ${node_path}    \#0
    [Return]   ${node_path}
#refine for Bts Path ...
NetAct._Exppand BTS Scope
    [Arguments]   ${MO_NAME}   ${nodes}
    ${node_name}   search_node_folder   ${MO_NAME}   ${nodes}
    ${node_expr}   Run Keyword If   '${node_name}'=='None' or '${node_name}'==''   Set Variable   ${EMPTY}
    ...   ELSE   Set Variable   ${node_name}|
    [Return]   ${node_expr}
NetAct.Search dedicated node index CM upload
    [Arguments]   ${nodes}   ${node_name}
    ${index}   Set Variable   -1
    FOR   ${node}   IN   @{nodes}
        ${temp}   ${Alias}  Run Keyword If   ${node.count(" ")} > 0
        ...    Split String    string=${node}   separator=${SPACE}    max_split=1
        ...    ELSE    Set Variable   ${node}    ${EMPTY}
        ${index}   Run Keyword If  ${temp.count("${node_name}")} > 0 and ${temp.count("...")} ==0
        ...    Get Index from List   ${nodes}   ${node}
		${index_type}    Evaluate    type(${index})
        Exit For Loop If    ${index} is not None
        #log to console    index type is ${index_type}
        #Exit For Loop If   ${index} > ${-1}
    END
    [Return]   ${index}   ${node}

NetAct.Search dedicated node index CM upload in CMUpload
    [Arguments]   ${nodes}   ${node_name}
    ${index}   Set Variable   -1
    FOR   ${node}   IN   @{nodes}
        ${temp}   ${Alias}  Run Keyword If   ${node.count(" ")} > 0
        ...    Split String    string=${node}   separator=${SPACE}    max_split=1
        ...    ELSE    Set Variable   ${node}    ${EMPTY}
        ${index}   Run Keyword If  ${Alias.count("${node_name}")} > 0 and ${Alias.count("...")} ==0
        ...    Get Index from List   ${nodes}   ${node}
		${index_type}    Evaluate    type(${index})
        Exit For Loop If    ${index} is not None
        #log to console    index type is ${index_type}
        #Exit For Loop If   ${index} > ${-1}
    END
    [Return]   ${index}   ${node}

NetAct.Upload NetAct image
    [Arguments]   ${file_path}   ${load_type}=Local
    &{params}   Create Dictionary
    ${remote_port}   Open Application   Software Manager   page   _SW Manager app   ${params}
    swing.List Components In Context
    swing.Select From Combobox   0   MRBTS
    Sleep   3s
    swing.List Components In Context
    swing.Push Button   Add ${load_type} Files...
    swing.Select Dialog   Open ${load_type} Files
    swing.Insert into Text Field   0   ${file_path}
    swing.Push Button   Open
    ${windows}   swing.List Windows
    swing.Select Window   ${windows[-2]}
    #Wait Until Keyword Succeeds   10m   20s   NetAct.Check Upload Action Match Ready for import
    Wait Until Keyword Succeeds   10m   20s   swing.Button Should Be Enabled   Import All
    FOR   ${index}    IN RANGE    1000
       ${curr_status}   swing.Get label Content   15
       Run Keyword If   ${curr_status.lower().count('ready for import')} > 0
       ...   Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Import All
       Run Keyword If   ${curr_status.lower().count('ready for import')} > 0
       ...   Exit For Loop
    END
    Sleep   180s
    FOR   ${index}    IN RANGE    1000
       ${curr_action}   swing.Get label Content   16
       Run Keyword If   '${curr_action.lower()}'=='stop'   Sleep   5s
       ...   ELSE   Exit For Loop
    END
    Sleep   30s
    ${curr_status}   swing.Get label Content   15
    ${result}   set variable if    ${curr_status.count('Software package imported successfully')} > 0    Pass    Failed
    ${result}   set variable if    ${curr_status.count('File already exists')} > 0    PassExist    ${result}
    [Return]     ${result}
    #${
    #should be true    ${curr_status.count('Software package imported successfully')} > 0
#    Close Java Application by Remote Port   ${remote_port}
