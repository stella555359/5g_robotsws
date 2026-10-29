*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_snapshot.robot



*** Variables ***



*** Keywords ***


CU Save Snapshot
    [Arguments]     ${gnb_index}=0
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  CU Save Snapshot  |   |
   Log To Console   \n*** Start to save snapshot ***
   CU Login  ${gnb_index}
   ${snapshot_file_dir}=  Get A Directory   snapshot
   cu.Get_Local_Snapshot  ${snapshot_file_dir}
   ${file_list}=   List_Directory   ${snapshot_file_dir}
   ${file_num}=   Get Length   ${file_list}
   Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
   [Return]  ${snapshot_file_dir}/${file_list[0]}
   [Teardown]  Run Keyword And Ignore Error   CU Logout

Trigger Local Snapshot Of CU
    [Arguments]    ${gnb_index}=0
    [Documentation]    Trigger Local Snapshot Of CU
    ...   *AUTHOR*  rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-4-15 | r3li | new |
    ...   *Argument Description*
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   *Example*
    ...   | Trigger Local Snapshot Of Cu | 0 |
    ...   *Return*
    ...   - String, operate id
    CU Login    gnb_index=${gnb_index}
    FOR   ${i}   IN RANGE    ${10}
    \     ${reulst}    ${response}    Run Keyword And Ignore Error     cu.trigger_local_snapshot
    \     Exit For Loop If    '${reulst}'=='PASS'
    [Return]    ${response}
    [Teardown]   CU Logout
