*** Settings ***
Documentation   ENV preparating should follow link: https://confluence.int.net.nokia.com/pages/viewpage.action?pageId=800188392
Library    Collections
Library    String
Library    OperatingSystem
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.ul.swing.core    WITH NAME    swing
Library    ../libraries/utils/csv_operation.py
Library    ../libraries/utils/netact_swing.py
Library    ../libraries/utils/swconfig.py
Library    ../libraries/utils/throughput.py

*** Variables ***
&{app_port_mapping}   Monitor=&{monitor_def}   Software Manager=&{sw_manage_def}   CM Operations Manager=&{cm_upload_def}
...   CM Editor=&{cm_editor_def}   CM Reference=&{cm_reference_def}
&{monitor_def}   app=start.jnlp   port=34221
&{sw_manage_def}   app=webstart.jnlp   port=34222
&{cm_upload_def}   app=racpmc.jnlp   port=34223
&{cm_editor_def}   app=cmedit.jnlp   port=34224
&{cm_reference_def}   app=racrec.jnlp   port=34225
${JRE_FORCE_VERSION}

*** Keywords ***
Open Application
    [Timeout]    30m
    [Arguments]   ${app_name}   ${start}=directly   ${keyword_name}=${EMPTY}   ${keyword_params}=${EMPTY}
    ${app_file}   Set Variable   ${app_port_mapping['${app_name}']['app']}
    ${app_path}   Set Variable   ${WEB_DOWNLOAD_DIR}/${app_file}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${app_path}
    Run Keyword If   ${file_exists}   OperatingSystem.Remove File   ${app_path}
    ${remote_port}   Set Variable   ${${app_port_mapping['${app_name}']['port']}}
    Wait Until Keyword Succeeds   3 times   5s   Action download JAVA app   ${app_name}   ${app_path}   ${start}
    ...   ${keyword_name}   ${keyword_params}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${app_path}
    ${java_path}   OperatingSystem.Run   ls /usr/lib/jvm | grep jre${JRE_FORCE_VERSION}*
    ${java_env}   Set Variable   /usr/lib/jvm/${java_path}/bin/javaws
    swing.Setup    javaws_path=${java_env}
    Start Java app   app_path=${app_path}   remote_port=${remote_port}   alias=${app_name}
    [Return]   ${remote_port}

Action download JAVA app
    [Arguments]   ${app_name}   ${app_path}   ${start}=directly   ${keyword_name}=${EMPTY}   ${keyword_params}=${EMPTY}
    Run Keyword If   '${start}'=='directly'   selenium_netact.Click Button   //span[text()='${app_name}']
    ...   ELSE   ${keyword_name}   &{keyword_params}
    Wait Until Keyword Succeeds   3 times   5s   OperatingSystem.File Should Exist   ${app_path}

Start Java app
    [Timeout]    25m
    [Arguments]   ${app_path}   ${remote_port}   ${alias}
    Run Keyword and Ignore Error   Close Java Application by Remote Port   ${remote_port}
    Log to console   Start Open ${alias}
    swing.Start Application    jnlp_file=${app_path}
    ...   remote_port=${remote_port}   timeout=${900}   close_security_dialogs=${True}   alias=${alias}
    Wait Until Keyword Succeeds   10s   2s   swing.Application Started      ${alias}     remote_port=${remote_port}
    Log to console   ${alias} APP started
    Sleep   1s
    Log to console   Switch to ${alias} java app UI
    swing.Switch to Application    ${alias}
    Sleep   20s
    Wait Until Keyword Succeeds   1m   5s   swing.Select Main Window

Close Java app
    [Arguments]   ${app_name}
    ${app_regex}   Set Variable   [${test_name[0]}]${test_name[1:]}
    OperatingSystem.Run   ps aux | grep -ie ${app_regex} | awk '{print $2}' | xargs kill -9

Close All Java Application Forced
    OperatingSystem.Run   ps -ef | grep javaws | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps aux | grep -ie [j]nlp | awk '{print $2}' | xargs kill -9

Close Java Application by Remote Port
    [Arguments]    ${remote_port}
    ${output}    Run    netstat -tunlp|grep ${remote_port}
    ${output}    Strip String    ${output}
    @{port_info_list}    Split String    ${output}    ${SPACE}
    ${list_length}   Get Length   ${port_info_list}
    ${port_info_str} =    Set Variable If
    ...    '${list_length}'=='0'    ${SPACE}
    ...    '${list_length}'!='0'    ${port_info_list[-1]}
    @{pid_list}    Split String    ${port_info_str}    /
    ${pid}    Set Variable    ${pid_list[0]}
    # ${output}    Run    kill -15 ${pid}
    ${output}    Run    kill -9 ${pid}

Close Monitor
    [Arguments]   ${alias}
    [Timeout]    2m
    swing.Switch To Application   ${alias}
    Sleep   10s
    swing.Close All Dialogs
    swing.Select From Main Menu   File|Exit
    swing.Select Dialog   Save
    swing.Push Button   Discard All

Close CM App
    [Arguments]   ${alias}
    [Timeout]   2m
    swing.Switch To Application   ${alias}
    Sleep   10s
    swing.Close All Dialogs
    swing.Select From Main Menu   File|Exit

NetAct CM Upload
    [Arguments]   ${bts_id}
    selenium_netact.switch_to_page   Start Page
    ${REMOTE_PORT_OPERATIONS}   Open Application    CM Operations Manager
    Wait Until Keyword Succeeds   3 times   10s   swing.Select From Main Menu And Wait    Upload|New Upload...
    Sleep   3s
    Wait Until Keyword Succeeds   3 times   10s   swing.Select Window   Upload
    Sleep   3s
    swing.Select tab   BSC
    FOR   ${i}    IN RANGE    8
       swing.Send Keyboard Event   VK_RIGHT
    END
    swing.Select tab   5G/LTE/SRAN
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component  SelectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Click On Component  DeselectAllButton
    Wait Until Keyword Succeeds   3 times   10s   swing.Expand All Tree Nodes   0
    ${nodes}   _Search All tree nodes CM upload  0
    ${bts_index}   ${bts_node}   _Search dedicated node index CM upload   ${nodes}   MRBTS-${bts_id}
    swing.Click On Tree Node   0   ${bts_index}
    Sleep   3s
    Wait Until Keyword Succeeds   3 times   10s   swing.Select Window   Upload
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Start
    Sleep   3s
    swing.Select Dialog   Confirmation
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Yes
    Sleep   15s
    ${CM_finished}  Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   10s
    ...   swing.Select Window   Upload: Finished
#    Run Keyword Unless  ${CM_finished}  Wait Until Keyword Succeeds      3 times   10s   swing.Select Window   Upload: Failed
    Sleep   5s
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Close
    Sleep   5s
    [Teardown]   Close Java app   cm3apps
    [Return]   ${CM_finished}    ${REMOTE_PORT_OPERATIONS}

CM Editor Select gNB
    [Arguments]   ${MO_NAME}
    Select Main Window
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree   Actual Configuration
    Expand Tree Node   navigationTree   Actual Configuration
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree   Actual Configuration|PLMN-PLMN
    Expand Tree Node   navigationTree   Actual Configuration|PLMN-PLMN
    Sleep   3s
    ${nodes}   Get Tree Node Child Names   navigationTree   Actual Configuration|PLMN-PLMN
    ${mid_node_not_exist}   is_mo_in_node_list   ${MO_NAME}   ${nodes}
    ${mid_node}  Run Keyword If   not ${mid_node_not_exist}   _Exppand BTS Scope   ${MO_NAME}   ${nodes}
    ...   ELSE   Set Variable   ${EMPTY}
    run keyword if  not '${mid_node}'==''   Run Keywords   Wait Until Keyword Succeeds   3 times   5s
    ...   Click On Tree Node   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}
    ...   AND   Expand Tree Node   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}
    ${nodes}   Get Tree Node Child Names   navigationTree   Actual Configuration|PLMN-PLMN|${mid_node}
    ${node_index}  ${node_name}   _Search dedicated node index CM upload   ${nodes}   ${MO_NAME}
    ${node_path}   Run Keyword If   ${node_index} >= ${0}   Set Variable   Actual Configuration|PLMN-PLMN|${mid_node}${node_name}
    ...   ELSE   Fail
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree
    ...   ${node_path}
    [Return]   ${node_path}
    
CM Editor Select gNB Module
    [Arguments]   ${MO_NAME}   ${father_tree}=Actual Configuration|PLMN-PLMN
    Select Main Window
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree   Actual Configuration   \#0
    Expand Tree Node   navigationTree   Actual Configuration   \#0
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree   Actual Configuration|PLMN-PLMN   \#0
    Expand Tree Node   navigationTree   Actual Configuration|PLMN-PLMN   \#0
    Sleep   3s
    ${nodes}   Get Tree Node Child Names   navigationTree   ${father_tree}
    ${nodes_tmp}   Set Variable   ${nodes}
    ${sub_tree_path}   Run Keyword If   '${MO_NAME} ${MO_NAME}' not in ${nodes_tmp}   _Get CM Sub Tree Path   ${nodes_tmp}   ${father_tree}
    ${nodes}   Run Keyword If   '${MO_NAME} ${MO_NAME}' not in ${nodes_tmp}   Get Tree Node Child Names   navigationTree   ${sub_tree_path}
    ${father_tree}=   Run Keyword If   '${MO_NAME} ${MO_NAME}' not in ${nodes_tmp}   Set Variable   ${sub_tree_path}    
    ${mid_node_not_exist}   is_mo_in_node_list   ${MO_NAME}   ${nodes}
    ${mid_node}  Run Keyword If   not ${mid_node_not_exist}   _Exppand BTS Scope   ${MO_NAME}   ${nodes}
    ...   ELSE   Set Variable   ${EMPTY}
    run keyword if  not '${mid_node}'==''   Run Keywords   Wait Until Keyword Succeeds   3 times   5s
    ...   Click On Tree Node   navigationTree   ${father_tree}|${mid_node}   \#0
    ...   AND   Expand Tree Node   navigationTree   ${father_tree}|${mid_node}   \#0
    ${nodes}   Get Tree Node Child Names   navigationTree   ${father_tree}|${mid_node}
    ${node_index}  ${node_name}   _Search dedicated node index CM upload   ${nodes}   ${MO_NAME}
    ${node_path}   Run Keyword If   ${node_index} >= ${0}   Set Variable   ${father_tree}|${mid_node}${node_name}
    ...   ELSE   Fail
    Wait Until Keyword Succeeds   3 times   5s   Click On Tree Node   navigationTree   ${node_path}   \#0
    [Return]   ${node_path}

_Exppand BTS Scope
    [Arguments]   ${MO_NAME}   ${nodes}
    ${node_name}   search_node_scope   ${MO_NAME}   ${nodes}
    ${node_expr}   Run Keyword If   '${node_name}'=='None' or '${node_name}'==''   Set Variable   ${EMPTY}
    ...   ELSE   Set Variable   ${node_name}|
    [Return]   ${node_expr}

_Search All tree nodes CM upload
    [Arguments]   ${tree_index}
    ${nodeCount}=    swing.Get Tree Node Count  ${tree_index}
    @{nodes}   Create List
    FOR    ${index}    IN RANGE    ${nodeCount}
       ${node_name}=   swing.Get Tree Node Label   ${tree_index}   ${index}
       Append To List   ${nodes}   ${node_name}
    END
    [Return]   ${nodes}
    
_Get CM Sub Tree Path
    [Arguments]   ${child_list}   ${tree_path_header}
    FOR   ${folder_name}   IN   @{child_list}
       Continue For Loop If   "${folder_name.find('MRBTS')}"=="-1"
       ${folder_name}   Strip String   ${folder_name}
       @{range}   Split String   ${folder_name}   -
       @{range}   Split String   ${range[-1]}   ...
       Return From Keyword If   ${BTSID} >=${range[0]} and ${BTSID} <=${range[1]}   ${tree_path_header}|${folder_name}
    END

_Search dedicated node index CM upload
    [Arguments]   ${nodes}   ${node_name}
    FOR   ${node}   IN   @{nodes}
       ${index}   Run Keyword If   ${node.count("${node_name}")} > 0   Get Index from List   ${nodes}   ${node}
       ...   ELSE   Set Variable   ${-1}
       Exit For Loop If   ${node.count("${node_name}")} > 0
    END
    [Return]   ${index}   ${node}

Upload NetAct image
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
    Wait Until Keyword Succeeds   10m   20s   _Check Upload Action Match Ready for import
    Wait Until Keyword Succeeds   10m   20s   swing.Button Should Be Enabled   Import All
    Wait Until Keyword Succeeds   3 times   20s   _Upload action done
    [Teardown]   Close Java Application by Remote Port   ${remote_port}

_Upload action done
    [Documentation]   Internal Keyword, no plan to user interface keyword.
    ...   Author: jingmin.he@nokia-sbell.com
    ${load_success}   Set Variable   Software package imported successfully
    Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Import All
    Wait Until Keyword Succeeds   10m   20s   _Check Upload Action Not Match Ready for import
    Sleep   10s
    FOR   ${index}    IN RANGE    1000
       ${curr_action}   swing.Get label Content   16
       ${curr_status}   swing.Get label Content   15
       Run Keyword If   '${curr_status.lower().count('ready for import')}' > 0
       ...   Wait Until Keyword Succeeds   3 times   10s   swing.Push Button   Import All
       Run Keyword If   '${curr_action.lower()}'=='stop'   Sleep   5s
       ...   ELSE   Exit For Loop
    END
    Run Keyword   _Check Upload Action Match ${load_success}

_Check Upload Action ${should}Match ${message}
    ${curr_status}   swing.Get label Content   15
    Run Keyword   Should ${should}Be Equal   ${curr_status}   ${message}

_SW Manager app
    [Documentation]   Internal Keyword, no plan to user interface keyword.
    ...   Author: jingmin.he@nokia-sbell.com
    selenium_netact.switch_to_page   Software Manager
    selenium_netact.wait_for_enable   //span[text()='Software Archive']
    Wait Until Keyword Succeeds   3 times   10s   Run Keywords   selenium_netact.Click Button   //span[text()='Software Archive']
    ...   AND   selenium_netact.wait_for_enable   //input[@id='embTreeFrm:cccomboboxField']
    Sleep   3s
    selenium_netact.write_value_and_enter   //input[@id='embTreeFrm:cccomboboxField']   MRBTS
    selenium_netact.wait_for_visibility   //*[@id='embTreeFrm:swTree:#REGULAR__PACKAGES#::remoteRepositoryTreeNode:mainRow']
#    selenium_netact.wait_for_visibility   //span[text()='Add software package...']
    Sleep   3s
    selenium_netact.Click Button   //span[text()='Add software package...']
