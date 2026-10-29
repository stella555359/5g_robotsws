*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_snapshot.robot



#*** Variables ***



*** Keywords ***
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
    ...    |  Input Parameters | Man. | Description |
    ...    | Snapshot_folder_name  |  yes | Snapshot folder name, support regexp |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...    | Snapshot Should Exists On LSS Server |  MRBTS\\-5240.* |
    ${res}=  issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}    Get Regexp Matches    ${res}   ${Snapshot_folder_name}
    Should Be True   ${match}   snapshot not found on lss server with regex match: ${Snapshot_folder_name}
    [Return]    ${match[-1]}


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
    ...    | Remove Snapshot Folder On LSS Server |  MRBTS-5240* |
    issh.Execute   command=rm -rf ${Snapshot_folder_name}  check_result=${False}  alias=${alias}

Check L2 Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific L2 Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Specific Log All In Snapshot | snapshot_path=${snapshot} |
    ...
    Check L2 Ps Log Should Be In Snapshot  ${snapshot_path}
    Check L2 Lo Log Should Be In Snapshot  ${snapshot_path}
    Check L2 Hi Log Should Be In Snapshot  ${snapshot_path}


Check L2 Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific L2 Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Specific Log In Snapshot | snapshot_path=${snapshot} | L2TtiTrace_EventsSnapshot |
    ...   | Check L2 Specific Log In Snapshot | snapshot_path=${snapshot} | L2TraceHi_DU |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
    \   File Should Not Be Empty   ${file}    file is empty: ${file}
    END

Check L2 Ps Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TtiTrace_EventsSnapshot
    [Documentation]    check l2 ps log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Ps Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Ps Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TtiTrace_EventsSnapshot |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L2 Hi Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TraceHi_DU
    [Documentation]    Check l2 hi log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Hi Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Hi Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TraceHi_DU |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}

Check L2 Lo Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TraceLo
    [Documentation]    Check l2 lo log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Lo Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Lo Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TraceLo |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Get Specific Log File Name From Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_keyword}  #${retrieve_type}=FILE
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
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | Save Local Snapshot | snapshot |
    ...   | ${log_value}  | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=pm_1_syslog |
    ...   | VDU Rest Logout|
    ...
    Should Not Be Empty  ${log_file_name_keyword}
    OperatingSystem.Directory Should Exist   ${snapshot_path}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${snapshot_path}   extension=.zip
    _Extract Zip File List   zip_file_list=${zip_file_fullpath_list}   alias=${alias}
    ...   check_file_exist=${TRUE}    remove_zip_file=${False}
    ${file_list}   ${file_fullpath_list}    List File    path=${snapshot_path}   retrieve_type=FILE_AND_DIR
    ${index}  Set Variable  0
    ${rtn_file_list}  Create List
    FOR  ${filename}   IN   @{file_list}
       ${matches}  Get Regexp Matches  ${filename}   ${log_file_name_keyword}
       Run Keyword If    ${matches}   Append To List    ${rtn_file_list}  ${file_fullpath_list[${index}]}
       ${index}   Evaluate  str(int('${index}')+1)
    END
    [Return]  ${rtn_file_list}


_Get Snapshot File List
    [Arguments]  ${snapshot_path}   ${snapshot_file_list_file_name}=snapshot_file_list.txt
    ${snapshot_file_list_file_name_full}   OperatingSystem.Join Path   ${snapshot_path}   ${snapshot_file_list_file_name}
    ${content}   OperatingSystem.Get File   ${snapshot_file_list_file_name_full}
    ${lines}     Split To Lines   ${content}
    ${rtn}   Create List
    ${new_section}  Set Variable  0
    ${current_folder_name}   Set Variable  ${EMPTY}
    FOR   ${line}   IN   @{lines}
       Log To Console   ${line}
       ${striped_line}   Set Variable  ${line.strip()}
       Continue For Loop If  ${striped_line.__len__()}==0
       ${current_folder_name}  Set Variable If  ${line.endswith(":")}    ${line.split(".zip:")[0]}    ${current_folder_name}
       Continue For Loop If   ${line.endswith(":")}
       ${current_file}   Run Keyword If  ${line.startswith(" ")}
                    ...   OperatingSystem.Join Path   ${snapshot_path}   ${current_folder_name}  ${striped_line}
       ...   ELSE    OperatingSystem.Join Path   ${snapshot_path}    ${striped_line}
       Append To List  ${rtn}    ${current_file}
    END
    [Return]   ${rtn}


Check RT Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_rtlog
    [Documentation]    Check RT log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check RT Log Should Be In Snapshot | ${snapshot} |
    ...   | Check RT Lo Log Should Be In Snapshot | ${snapshot} | E300_rtlog |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb0 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb0
    [Documentation]    Check L1 EMtraceHb0 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb0 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb1 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb1
    [Documentation]    Check L1 EMtraceHb1 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb1 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb2 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb2
    [Documentation]    Check L1 EMtraceHb2 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb2 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific L1 Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 Specific Log In Snapshot | ${snapshot} | E300_rtlog.bin |
    ...   | Check L1 Specific Log In Snapshot | ${snapshot} | E300_EmTraceHb0 |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty   ${file}    file is empty: ${file}
    END


Check L1 Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific L1 Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 Specific Log All In Snapshot | ${snapshot} |
    ...
    Check RT Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb0 Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb1 Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb2 Log Should Be In Snapshot  ${snapshot_path}


Check L1 snapshot nrt Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_l1_snapshot_nrt
    [Documentation]    Check L1 snapshot nrt should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 snapshot nrt Log Should Be In Snapshot | ${snapshot} |
    ...   | Check L1 snapshot nrt Log Should Be In Snapshot | ${snapshot} | E300_l1_snapshot_nrt |
    ...
    Check IQ Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 snapshot rt Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_l1_snapshot_rt
    [Documentation]    Check l1 snapshot rt should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 snapshot rt Log Should Be In Snapshot | ${snapshot} |
    ...   | Check L1 snapshot rt Log Should Be In Snapshot | ${snapshot} | E300_l1_snapshot_rt |
    ...
    Check IQ Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check IQ Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific IQ Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check IQ Specific Log In Snapshot | ${snapshot} | E300_l1_snapshot_nrt |
    ...   | Check IQ Specific Log In Snapshot | ${snapshot} | E300_l1_snapshot_rt |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty   ${file}    file is empty: ${file}
    END


Check IQ Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific IQ Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check IQ Specific Log All In Snapshot | ${snapshot} |
    ...
    Check L1 snapshot nrt Log Should Be In Snapshot  ${snapshot_path}
    Check L1 snapshot rt Log Should Be In Snapshot  ${snapshot_path}

Check FlowCtrl Value In Snapshot
    [Arguments]    ${snapshot_path}    ${log_file_name_regex_string}=E100_LINUX_runtime    ${key}=dlFCAlgo =
    [Documentation]    check Specific FlowCtrl value in Snapshot
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check Specific FlowCtrl value In Snapshot | snapshot_path=${snapshot} |
    ...   | Check Specific FlowCtrl value In Snapshot | snapshot_path=${snapshot} | dlFCAlgo |
    ${file_list}    Get Specific Log File Name From Snapshot    snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}    retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty    ${file}    file is empty: ${file}
       ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    END
    _Extract Zip File    file=${file}  alias=${alias}   check_file_exist=${True}   remove_zip_file=${False}
    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${extract_path}   extension=.log
    ${out}    issh.Execute    awk -F '${key}' '{print $2}' ${zip_file_fullpath_list[0]} | cut -c1-1    alias=${alias}
    ${out1}    Strip String    ${out}    characters='\r\n'
    ${dlFlowControlAlgo}    Set Variable    ${out1[0]}
    [Return]  ${dlFlowControlAlgo}


Check auditlog In Snapshot
    [Arguments]    ${snapshot_path}    ${log_file_name_regex_string}=auditlogs
    [Documentation]    check auditlog in Snapshot
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check auditlog In Snapshot | snapshot_path=${snapshot} |
    ...   | Check auditlog In Snapshot | snapshot_path=${snapshot} | STOP_UPLANE_TRACE |
    ${file_list}    Get Specific Log File Name From Snapshot    snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}    retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty    ${file}    file is empty: ${file}
       ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    END
    _Extract Zip File    file=${file}  alias=${alias}   check_file_exist=${True}   remove_zip_file=${False}
    ${dummy}    ${zip_file_fullpath_list}  List File   path=${extract_path}   retrieve_type=FILE
	[Return]  ${zip_file_fullpath_list[0]}

Save Local Snapshot
    [Arguments]  ${local_snapshot_location}=snapshot
    [Documentation]    Save Local Snapshot
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...
    ...    *RETURN VALUE*
    ...   path of local snapshot
    ...
    ...    Example
    ...    | Save Local Snapshot |
    ...
    log to console  Save Local Snapshot...
    VDU Rest Login
    ${mypath}   Get A Directory  ${local_snapshot_location}
    ${a}  vdu.Get_Local_Snapshot   ${mypath}
    [Return]  ${mypath}



