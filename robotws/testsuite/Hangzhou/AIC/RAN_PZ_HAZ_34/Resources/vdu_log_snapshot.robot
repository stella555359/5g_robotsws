*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_snapshot.robot



*** Variables ***



*** Keywords ***
VDU Collect Snapshot To Local
    [Arguments]  ${local_snapshot_location}=snapshot   ${compressed_or_not}=${False}   ${operation_timeout}=900
    [Documentation]    VDU Collect Snapshot To Local
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:
    ...   <24-4-2023>, <r3li>, <check status before start save snapshot>
    ...   <25-6-2023>, <r3li>, <add operation_timeout parameter>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...    | compressed_or_not | No | a zip file if True, unzip files if False |
    ...
    ...    *RETURN VALUE*
    ...   path of local snapshot if compressed_or_not is ${False}, else a compressed file of snapshot
    ...
    ...    Example
    ...    | ${snapshot_file} | VDU Collect Snapshot To Local | local_snapshot_location=snapshot |
    ...    | ${out} | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot_file} | log_file_name_keyword=rcplog |
    ...    | Should Be True | ${out.__len__()}==2 |
    ...
    VDU Rest Login
    Wait Until Keyword Succeeds  1200   20s   _Check Snap Status Is Idle For vDU
    log to console  VDU Collect Snapshot To Local...
    ${mypath}   Get A Directory  ${local_snapshot_location}
    ${a}  vdu.Get_Local_Snapshot   directory=${mypath}    compressed_or_not=${compressed_or_not}  operation_timeout=${operation_timeout}
    ${zip_file_name}    Run Keyword If    "${compressed_or_not}"=="${True}"    OperatingSystem.Run    ls ${mypath}
    Return From Keyword If    "${compressed_or_not}"=="${True}"    ${mypath}/${zip_file_name}
    [Return]  ${mypath}


VDU Collect Snapshot To Remote And Download
    [Arguments]   ${log_level}=full  ${request_timeout}=30  ${operation_timeout}=600  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect From LSS Server   alias=${alias}
    [Documentation]    VDU Collect Snapshot To Remote And Download
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:        <23-6-2023>, <chris.l.cao>, Initializatoin
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | log_level       | No | log_level, full or minor, default is minor  |
    ...    | request_timeout | No | default is 30 seconds |
    ...    | operation_timeout | No | default is 600 seconds  |
    ...    | gnb_index         | No | default is 0 |
    ...    | vdu_index         | No | default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   local snapshot file which is downloaded from LSS server
    ...
    ...    Example1
    ...    | ${local_snapshot_file} | VDU Collect Snapshot To Remote And Download |
    ...    | ${out} | Get Specific Log File Name From Snapshot | snapshot_path=${local_snapshot_file} | log_file_name_keyword=rcplog |
    ...    | Should Be True | ${out.__len__()}==2 |
    ...

    ...
    Log To Console   VDU Collect Snapshot To Remote And Download...
    ${alias}   get_unique_id
    Connect To LSS Server   alias=${alias}
    ${mrbts_id}   Get MRBTS Id From vDU SCF     gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Remove Snapshot Folder On LSS Server   *MRBTS-${mrbts_id}_\\S+  alias=${alias}
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}   delay=15
    ${res}=  vdu.get_remote_snapshot  log_level=${log_level}   request_timeout=${request_timeout}  operation_timeout=${operation_timeout}

    Log To Console   Snapshot Should Exists On LSS Server...
    ${remote_snapshot_folder}  Wait Until Keyword Succeeds  2m  10
       ...   Snapshot Should Exists On LSS Server  Snapshot_folder_name=MRBTS-${mrbts_id}_\\S+   alias=${alias}
    ${local_snapshot_file}   Download Snapshot From LSS Server  snapshot_folder_name=${remote_snapshot_folder}   alias=${alias}
    [Return]  ${local_snapshot_file}


Connect To LSS Server
    [Arguments]   ${alias}=default
    [Documentation]   Connect to lss server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | Connect To LSS Server |
    ...
    issh.Connect_to   ip=${LSS_IP_ADDRESS}    username=${LSS_USERNAME}  password=${LSS_PASSWORD}  prompt=\\$   alias=${alias}   width=200
    [Return]  ${alias}

Disconnect From LSS Server
    [Arguments]  ${alias}=default
    [Documentation]    Disconnect From LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Disconnect From LSS Server |
    issh.Disconnect   alias=${alias}


Snapshot Should Exists On LSS Server
    [Arguments]  ${Snapshot_folder_name}   ${alias}=default
    [Documentation]    Snapshot Should Exists On LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...   history change: <date>,<who>,<what and how>
    ...   23.6.2023,chris.l.cao@nokia-sbell.com, return full folder name of remote snapshot, which begins with "Snapshot_"
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | Snapshot_folder_name  |  yes | Snapshot folder name, support regexp |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...    | Snapshot Should Exists On LSS Server |  MRBTS-5240_.* |
    ${res}=  issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}    Get Regexp Matches    ${res}   ${Snapshot_folder_name}
    Should Be True   ${match}   snapshot not found on lss server with regex match: ${Snapshot_folder_name}
    ${file_name}  Set Variable   ${match[-1]}
    ${starts_with_Snapshot_}   Set Variable   ${file_name.startswith("Snapshot_")}
    ${ret}  Set Variable If   "${starts_with_Snapshot_}"=="${True}"   ${file_name}  Snapshot_${file_name}
    [Return]    ${ret}


Download Snapshot From LSS Server
    [Arguments]  ${snapshot_folder_name}   ${alias}=default
    [Documentation]    Download Snapshot From LSS Server
    ...  *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...  |  Input Parameters | Man. | Description |
    ...  | snapshot_folder_name | yes | Snapshot folder name in LSS server, Snapshot_MRBTS-108201_vDU-108201_vDUCNF23R4_0.300.14101_20230623-0919 |
    ...  | alias                | no | aliase name, default is default |
    ...
    ...  *RETURN VALUE*
    ...  Local snapshot file name, file format is .zip
    ...
    ...  Example
    ...  | ${alias} | Get Unique Id |
    ...  | Connect To LSS Server | alias=${alias} |
    ...  | Remove Snapshot Folder On LSS Server | MRBTS-1234_* | alias=${alias} |
    ...  | VDU Rest Login |
    ...  | vdu.get_remote_snapshot  log_level=full |
    ...  | ${remote_snapshot_folder} | Snapshot Should Exists On LSS Server | MRBTS-1234_\\S+ | alias=${alias} |
    ...  | ${local_snapshot} |  Download Snapshot From LSS Server | snapshot_folder_name=${remote_snapshot_folder} | alias=${alias} |
    ...  | Disconnect From LSS Server |  alias=${alias} |
    ...
    ${temp_id}   get_unique_id   prefix=lss_snapshot_   precise=FORMAT_DATETIME  suffix=.zip
    ${local_snapshot_zip_file}   Get A File   Snapshot_LSS   ${temp_id}
    issh.Execute   command=zip -r ${snapshot_folder_name}.zip ./${snapshot_folder_name}   alias=${alias}
    issh.download_file  remote_path=${snapshot_folder_name}.zip  local_path=${local_snapshot_zip_file}   alias=${alias}
    OperatingSystem.File Should Exist    ${local_snapshot_zip_file}
    OperatingSystem.File Should Not Be Empty   ${local_snapshot_zip_file}
    [Return]    ${local_snapshot_zip_file}


Remove Snapshot Folder On LSS Server
    [Arguments]  ${Snapshot_folder_name}   ${alias}=default
    [Documentation]    Remove Snapshot Folder On LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | Snapshot_folder_name  |  yes | snapshot folder name to remove, support wildcard |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Remove Snapshot Folder On LSS Server | MRBTS-5240_ |
    issh.Execute   command=rm -rf ${Snapshot_folder_name}  check_result=${False}  alias=${alias}


Get Specific Log File Name From Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_keyword}  ${extension}=${None}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Get Specific Log File Name From Snapshot
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | snapshot_path       | yes | snapshot file path |
    ...    | log_file_name_keyword | yes | log_file_name_keyword, e.g, L2hi, l2lo or l2ps, it's a regex string |
    ...    | retrieve_type | no | retrieve_type, e.g, FILE, DIR, FILE_AND_DIR, default is FILE |
    ...
    ...    *RETURN VALUE*
    ...    Return value is a list, list content is absoluate path of log file.
    ...    Return empty list if find nothing.
    ...
    ...    Example1: (Collect snaplog and save to LSS server)
    ...    | ${snapshot} | VDU Collect Snapshot To Remote And Download |
    ...    | ${out}     |  Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=L2TraceHi_DU |
    ...    | Should Be True | ${out.__len__()}==1 |
    ...
    ...    Example2: (Collect snaplog and save to local without compressed format)
    ...   | ${snapshot}   | VDU Collect Snapshot To Local | snapshot |
    ...   | ${out}  | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=L2TraceHi_DU |
    ...   | Should Be True | ${out.__len__()}==1 |
    ...
    ...    Example3: (Collect snaplog and save to local with compressed format)
    ...   | ${snapshot} | VDU Collect Snapshot To Local | snapshot |
    ...   | ${out}      | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=rcplog | extension=.zip |
    ...   | Should Be True | ${out.__len__()}==1 |
    ...
    ...    Example4: (Collect snaplog and save to local without compressed format)
    ...   | ${snapshot}   | VDU Collect Snapshot To Local | snapshot | compressed_or_not=${True} |
    ...   | ${out}  | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=L2TraceHi_DU |
    ...   | Should Be True | ${out.__len__()}==1 |
    ...
    Should Not Be Empty  ${log_file_name_keyword}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}

    ${r}  ${out}  Run Keyword And Ignore Error   OperatingSystem.Directory Should Exist   ${snapshot_path}
    Run Keyword If  "${r}"=="FAIL"   OperatingSystem.File Should Exist  ${snapshot_path}

    ${snapshot_path}   Run Keyword If  "${r}"=="FAIL"   Extract Zip File To The Same Folder  file=${snapshot_path}  alias=${alias}
       ...  ELSE   Set Variable   ${snapshot_path}

    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${snapshot_path}   extension=.zip
    Extract Zip File List   zip_file_list=${zip_file_fullpath_list}   alias=${alias}
    ...   check_file_exist=${TRUE}    remove_zip_file=${False}
    ${file_list}   ${file_fullpath_list}   List File With Extension    path=${snapshot_path}   extension=${extension}
    ${index}  Set Variable  0
    ${rtn_file_list}  Create List
    FOR  ${filename}   IN   @{file_list}
       ${matches}  Get Regexp Matches  ${filename}   ${log_file_name_keyword}
       Run Keyword If    ${matches}   Append To List    ${rtn_file_list}  ${file_fullpath_list[${index}]}
       ${index}   Evaluate  str(int('${index}')+1)
    END

    [Return]  ${rtn_file_list}


Trigger Local Snapshot Of vDU
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Trigger Local Snapshot Of vDU
    ...   author: rui.3.li@nokia-sbell.com
    ...   history change: <date>,<who>,<what and how>
    ...   29.4.2022,chris.l.cao@nokia-sbell.com, change to save operation id to disk
    ...   29.6.2023,rui.3.li@nokia-sbell.com, optimize keyword
    ...   *Argument Description*
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...
    ...   *Example*
    ...   | Trigger Local Snapshot Of vDU |
    ...
    ...   *Return*
    ...   - String, operation id

    _Check Snap Status Is Idle For vDU   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${operation_id}    vdu.trigger_local_snapshot
    [Return]    ${operation_id}


_Check Snap Status Is Idle For vDU
    [Arguments]     ${gnb_index}=0  ${vdu_index}=0
    [Documentation]   If snap status is not idle, save snapshot, otherwise do nothing.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   history change: <date>,<who>,<what and how>
    ...   29.6.2023,rui.3.li@nokia-sbell.com, optimize keyword
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index    | no | gnb_index, default is 0 |
    ...	  | vdu_index    | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | _Set Operation Id In Disk File | operation_id_folder_name=/tmp/tmp_vdu_cran1 |
    ...  | operation_id_file_name=vdu_operation_id.txt | operation_id=MRBTS-108201_20220429-115532-357  |
    ...
    ${status}   vdu.Check_snapshot_status
    Return From Keyword If  '${status}'=='idle'

    ${snapshot_info}   vdu.get_snapshot_operations_information
    ${length}   Get Length    ${snapshot_info}
    Should Be Equal As Numbers    ${length}   ${1}
    ${operation_id}   Set Variable   ${snapshot_info}[0][operation_id]
    ${myvdupath_previous_snapshot}   Get A Directory  vdu_snapshot_teardown_previous
    vdu.check_local_snapshot_status_and_save_it    directory=${myvdupath_previous_snapshot}  operation_id=${operation_id}


_Set Operation Id In Disk File
    [Arguments]  ${operation_id_folder_name}   ${operation_id_file_name}   ${operation_id}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Set Operation Id In Disk File
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | operation_id_folder_name | yes | operation_id_folder_name |
    ...	  | operation_id_file_name | yes | operation_id_file_name |
    ...	  | operation_id          | yes | operation_id |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | _Set Operation Id In Disk File | operation_id_folder_name=/tmp/tmp_vdu_cran1 |
    ...  | operation_id_file_name=vdu_operation_id.txt | operation_id=MRBTS-108201_20220429-115532-357  |
    ...
    log to console  _Set Operation Id In Disk File
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${full_path_file_name}  OperatingSystem.Join Path  ${operation_id_folder_name}   ${operation_id_file_name}
    ${out}  issh.Execute   command=mkdir -p ${operation_id_folder_name}   alias=${alias}
    ${out}  issh.Execute   command=touch ${full_path_file_name}   alias=${alias}

    ${found}   issh.is_file   ${full_path_file_name}   alias=${alias}
    should be true  ${found}

    #display old value
    ${out}  issh.Execute   command=cat ${full_path_file_name}   alias=${alias}

    #change file content
    ${out}  issh.Execute   command=echo ${operation_id} > ${full_path_file_name}    alias=${alias}

    #display new value
    ${out}  issh.Execute   command=cat ${full_path_file_name}   alias=${alias}


_Get Operation Id In Disk File
    [Arguments]  ${operation_id_folder_name}   ${operation_id_file_name}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Operation Id In Disk File
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | Input Parameters | Man. | Description |
    ...	   | operation_id_folder_name | yes | operation_id_folder_name |
    ...	   | operation_id_file_name | yes | operation_id_file_name |
    ...
    ...   *RETURN VALUE*
    ...   vdu snapshot operation_id
    ...
    ...   Example
    ...  | _Get Operation Id In Disk File |
    ...
    log to console  _Get Operation Id In Disk File
    ${alias}   get_unique_id
    connect to ute locally  alias=${alias}

    ${full_path_file_name}  OperatingSystem.Join Path  ${operation_id_folder_name}   ${operation_id_file_name}
    ${found}   issh.is_file   ${full_path_file_name}   alias=${alias}
    Return From Keyword If   "${found}"=="${False}"   ${EMPTY}

    #display old value
    ${out}  issh.Execute   command=cat ${full_path_file_name}   check_result=${False}  alias=${alias}

    ${operation_id}  Strip Prompt   ${out}
    [Return]  ${operation_id}
