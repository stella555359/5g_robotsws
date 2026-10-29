*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_snapshot.robot



*** Variables ***



*** Keywords ***
VCU Collect Snapshot To Local
    [Arguments]     ${gnb_index}=0   ${snapshot_time}=600
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...  modified by:        <24-Apr-2023>, <r3li>, <check status before start save snapshot>
    ...  modified by:        <2-Jun-2023>, <r3li>, <add parameter named snapshot time>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...   The full path file name of snapshot, e.g, /tmp/TESTCASE__5G_CU_Save_Snapshot/2023_05_24_07_33_59/snapshot/Snapshot_20230524-073405.zip
    ...
    ...    Example
    ...    | ${snapshot_file} | VCU Collect Snapshot To Local |
    ...
   Wait Until Keyword Succeeds  1200   20s   VCU Snapshot Status Should Be Idle    gnb_index=${gnb_index}
   Log To Console   \n*** Start to save VCU snapshot ***
   CU Rest Login   gnb_index=${gnb_index}
   ${snapshot_file_dir}=  Get A Directory   snapshot
   cu.Get_Local_Snapshot  ${snapshot_file_dir}   operation_timeout=${snapshot_time}
   ${file_list}=   List_Directory   ${snapshot_file_dir}
   ${file_num}=   Get Length   ${file_list}
   Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
   [Return]  ${snapshot_file_dir}/${file_list[0]}
   [Teardown]  Run Keyword And Ignore Error   CU Rest Logout


VCU Collect Snapshot To Remote And Download
    [Arguments]     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect From LSS Server   alias=${alias}
    [Documentation]    VCU Collect Snapshot To Remote And Download
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:        <23-6-2023>, <chris.l.cao>, Initializatoin
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index         | No | default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   local snapshot file which is downloaded from LSS server
    ...
    ...    Example
    ...    | ${local_snapshot_file} |   VCU Collect Snapshot To Remote And Download |
    ...
    Log To Console   VCU Collect Snapshot To Remote And Download...
    ${alias}   get_unique_id
    Connect To LSS Server   alias=${alias}
    ${mrbts_id}   Get MRBTS Id From vCU SCF     gnb_index=${gnb_index}
    Remove Snapshot Folder On LSS Server   *MRBTS-${mrbts_id}_\\S+  alias=${alias}
    CU Rest Login   gnb_index=${gnb_index}
    ${vcu_oam_http_connection_info}   Get vCU OAM Http Connection Info  gnb_index=${gnb_index}
    ${vcu_oam_ip}   set variable  ${vcu_oam_http_connection_info["addr"]}
    ${remote_name}    save_snapshot_to_lss_server   ${vcu_oam_ip}

    Log To Console   Snapshot Should Exists On LSS Server...
    ${remote_snapshot_folder}  Wait Until Keyword Succeeds  2m  10
     ...   Snapshot Should Exists On LSS Server  Snapshot_folder_name=${remote_name}   alias=${alias}

    ${local_snapshot_file}   Download Snapshot From LSS Server  snapshot_folder_name=${remote_snapshot_folder}   alias=${alias}
    [Return]  ${local_snapshot_file}


VCU Snapshot Status Should Be Idle
    [Arguments]     ${gnb_index}=0
    [Documentation]    VCU Snapshot Status Should Be Idle
    ...  author:             luofei.tu@nokia-sbell.com
    ...  modified by:        <16-April-2023>, <lutu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | snapshot_time | No | snapshot time, default 600s |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  VCU Snapshot Status Should Be Idle  |   |
   CU Login  ${gnb_index}
   ${status}   cu.Check_snapshot_status
   should be true   "${status}"=="idle"   Snapshot is not idle
   [Teardown]  Run Keyword And Ignore Error   CU Logout
