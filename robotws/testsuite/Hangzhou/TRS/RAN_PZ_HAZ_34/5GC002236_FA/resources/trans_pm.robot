*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   common PM keyword

Resource    trans_comm.robot

*** Variables ***
${TIMEZONE_DIFFERENCE}    1
${TIMEZONE_NAME}    CET
@{LIST_COUNTER_INFO_CHK_EXISTENCE}
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C1,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C2,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C3,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C4,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C5,-1
#-------- End of M51300  ---------------

...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C0,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C1,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C2,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C3,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C4,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C5,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C7,-1
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C9,-1
#-------- End of M51301  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C0,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C1,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C2,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C3,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C4,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C5,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C6,-1
#-------- End of M51321  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C0,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C1,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C2,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C3,-1
#-------- End of M51325  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C0,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C1,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C2,-1
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C3,-1
#-------- End of M51326  ---------------

#-------- End of LIST_COUNTER_INFO_CHK_EXISTENCE  ---------------


@{LIST_COUNTER_INFO_CHK_INEXISTENCE}
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C1,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C2,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C3,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C4,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C5,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C6,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C7,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C8,-2
#-------- End of M51300  ---------------

...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C0,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C1,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C2,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C3,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C4,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C5,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C7,-2
...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C9,-2
#-------- End of M51301  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C0,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C1,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C2,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C3,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C4,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C5,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C6,-2
#-------- End of M51321  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C0,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C1,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C2,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C3,-2
#-------- End of M51325  ---------------

...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C0,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C1,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C2,-2
...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C3,-2
#-------- End of M51326  ---------------

#-------- End of LIST_COUNTER_INFO_CHK_EXISTENCE  ---------------

*** Keyword ***
Sync To PM Timer Clock
    [Arguments]   ${PM_collecting_interval}   ${estimated_traffic_generating_duration}=4
    [Teardown]  Run Keyword And Ignore Error  TAF Disconnect From DU OAM
    [Documentation]  Sync To PM Timer Clock
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | estimated_traffic_generating_duration     | No  | estimated_traffic_generating_duration, unit is minute, default value is 7 |
    ...    | PM_collecting_interval     | No  | PM_collecting_interval, unit is minute, default value is 15 |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Sync To PM Timer Clock |
    ...    | # generate traffic to triggle counter increasement |
    ...    | # ... |
    ...    | Get PM File For Next |
    ...    | ${result} | ${result2} | Run Keyword And Ignore Error | Get Counter By DistName From Local PM File |
    ...    | | | | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |  M51321C1 |
    ...    | ${curr_counter_value}     | Set Variable If | '${result}'=='PASS'  |  ${result2[0]} |
    ...    | ${curr_counter_timestamp} | Set Variable If | '${result}'=='PASS'  |  ${result2[1]} |
    ...    | #now, ${curr_counter_value} is the counter value after traffic |  |
    Log To Console  Begin: Sync To PM Timer Clock
    ${oam_conn}   TAF Connect To DU OAM

    #wait clock to the moment which is 15*n minutes(n=0,1,2,3)
    ${ret}    ssh.Execute    command=date +"%Y-%m-%d %H:%M:%S"
    ${vm_time}=    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current system time:${vm_time[0]}

    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${vm_minutes}  Set Variable   ${matches[0]}

    ${estimated_traffic_generating_duration}  Evaluate   int('${estimated_traffic_generating_duration}')
    ${PM_collecting_interval}  Evaluate  int('${PM_collecting_interval}')
    ${vm_minutes}  Evaluate  int('${vm_minutes}')

    Run Keyword If
      ...   ${PM_collecting_interval}!=5 and ${PM_collecting_interval}!=15 and ${PM_collecting_interval}!=30 and ${PM_collecting_interval}!=60
      ...    Fail   PM_collecting_interval should be 5, 15, 30 or 60 minutes.
    _Wait Some Time For Next Round PM Collecting    collecting_interval=${PM_collecting_interval}
     ...   estimated_traffic_generating_duration=${estimated_traffic_generating_duration}   vm_minutes=${vm_minutes}

    ${ret}    ssh.Execute    command=date +"%Y-%m-%d %H:%M:%S"

    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current system time:${vm_time[0]}
    Log To Console  End: Sync To PM Timer Clock


_Wait Some Time For Next Round PM Collecting
    [Arguments]   ${collecting_interval}  ${estimated_traffic_generating_duration}   ${vm_minutes}
    Should Be True  ${estimated_traffic_generating_duration}<=${collecting_interval}

    ${vm_minutes_mod}    Evaluate    int(math.fmod(${vm_minutes},int(${collecting_interval})))    modules=math

    Log To Console  vm_minutes_mod:${vm_minutes_mod}
    Run Keyword If   ${vm_minutes_mod}==0  Log To Console   it's the time of N*${collecting_interval} minutes, so need not wait
    Return From Keyword If  ${vm_minutes_mod}==0

    ${wait_time}    Evaluate    int(${collecting_interval})-${vm_minutes_mod}

    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    There is no next collecting point during estimated_traffic_generating_duration
    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    ${msg}(${estimated_traffic_generating_duration} minutes), so need not wait to synced to next round collecting point.

    Run Keyword If   ${wait_time}>${estimated_traffic_generating_duration}
    ...  Log To Console   ${msg}
    Return From Keyword If   ${wait_time}>${estimated_traffic_generating_duration}

    ${msg}  Set Variable   There is next collecting point during estimated_traffic_generating_duration
    ${msg}  Set Variable  ${msg}(${estimated_traffic_generating_duration} minutes), so need wait to sync to next round collecting point.
    Log To Console  ${msg}

    ${wait_time_sec}   Evaluate   ${wait_time}*60+31
    Log To Console   wait time: ${wait_time} minutes
    Sleep   ${wait_time_sec}


Get Next Counters And Verify Them
    [Arguments]  ${counter_table_name}   ${CounterCollectionInterval}
    Log To Console   Get Next Counters And Verify them
    Get PM File For Next   CounterCollectionInterval=${CounterCollectionInterval}

    ${VM_ROLE_TNL_NUMBER_MAP}   Get VNF VM Role TNL Number Map

    FOR   ${counter_info}   IN   @{counter_table_name}
         Get One PM Counter Valule From Local PM File And Verify It   counter_info=${counter_info}
         ...   vnf_vm_role_and_tnl_map=${VM_ROLE_TNL_NUMBER_MAP}   CounterCollectionInterval=${CounterCollectionInterval}
    END


Get PM File For Next
    [Arguments]   ${CounterCollectionInterval}
    [Teardown]  Run Keyword And Ignore Error  TAF Disconnect From DU OAM
    [Documentation]  Get PM File For Next
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    return counter value
    ...    Example
    ...    | Sync To PM Timer Clock |
    ...    | # generate traffic to triggle counter increasement |
    ...    | # ... |
    ...    | Get PM File For Next |
    ...    | ${result} | ${result2} | Run Keyword And Ignore Error | Get Counter By DistName From Local PM File |
    ...    | | | | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |  M51321C1 |
    ...    | ${curr_counter_value}     | Set Variable If | '${result}'=='PASS'  |  ${result2[0]} |
    ...    | ${curr_counter_timestamp} | Set Variable If | '${result}'=='PASS'  |  ${result2[1]} |
    ...    | #now, ${curr_counter_value} is the counter value after traffic |  |
    Log To Console  Begin: Get PM File For Next
    Should Be True
    ...  ${CounterCollectionInterval}==5 or ${CounterCollectionInterval}==15 or ${CounterCollectionInterval}==30 or ${CounterCollectionInterval}==60

    TAF Connect To DU OAM
    ${ret}    ssh.Execute   command=date +"%Y-%m-%d %H:%M:%S"
    ${vm_time}=    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    ${next_interval}=    Evaluate    int(${CounterCollectionInterval}-math.fmod(int('${vm_time[0][-5:-3]}'),${CounterCollectionInterval}))
        ...   modules=math
    ${pm_file_generation_interval}    Set Variable  ${CounterCollectionInterval}   #interval for PM file generatin
    ${current_clock_mod_pm_file_generation_interval}    Evaluate    int(math.fmod(int('${vm_time[0][-5:-3]}'),${pm_file_generation_interval}))
    ...   modules=math
    Log To Console   Current system time:${vm_time[0]}
    Log To Console   current_clock_mod_pm_file_generation_interval:${current_clock_mod_pm_file_generation_interval}
    Log To Console   Counter Collection next_interval:${next_interval}

    ${ORIGINAL_PM_COUNTER_FILE_LIST}    List File Or Directory Info    path=${PM_FILE_LOCATION}   file_pattern=${PM_FILE_PATTERN}   option=File
    Set Test Variable    ${ORIGINAL_PM_COUNTER_FILE_LIST}

    ${local_pm_dir}    Get A Directory    pmcounter
    ${wait_time_out}   Evaluate   str( int(${CounterCollectionInterval})+1 )
    Log To Console   Maximum Wait for Next PM file generation:${wait_time_out} minutes
    ${TRANS_LOCAL_PM_FILE}     Get Newest PM File    output_dir=${local_pm_dir}   max_wait_time=${wait_time_out}
    ...   org_file_list=${ORIGINAL_PM_COUNTER_FILE_LIST}

    ${ret}    ssh.Execute   command=date +"%Y-%m-%d %H:%M:%S"
    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   New PM file Found(Current system time:${vm_time[0]}).

    Set Test Variable     ${TRANS_LOCAL_PM_FILE}
    Log To Console  End: Get PM File For Next


Get PM File For Current
    [Arguments]  ${CounterCollectionInterval}=5
    [Documentation]  Get PM File For Current
    ...    After this KW is called, current generated PM file will be downloaded to local UTE server.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...     None
    ...    Example
    ...    | Get PM File For Current |
    ...    | ${mo} | set variable | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
    ...    | ${result} | ${result2} | Run Keyword And Ignore Error | Get Counter By DistName From Local PM File | ${mo} |  M51321C1 |
    ...    | ${curr_counter_value}     | Set Variable If | '${result}'=='PASS'  |  ${result2[0]} |
    ...    | ${curr_counter_timestamp} | Set Variable If | '${result}'=='PASS'  |  ${result2[1]} |
    Log To Console  Begin: Get PM File For Current
    Should Be True
    ...  ${CounterCollectionInterval}==5 or ${CounterCollectionInterval}==15 or ${CounterCollectionInterval}==30 or ${CounterCollectionInterval}==60

    ${oam_conn}    TAF Connect To DU OAM
    ${ret}   ssh.Execute    command=date +"%Y-%m-%d %H:%M:%S"
    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    #${wait_time_out}   Run Keyword If  ${CounterCollectionInterval}<=30   Evaluate   str( int(${CounterCollectionInterval})*2+1 )
    #...    ELSE  Evaluate    str(int(${CounterCollectionInterval})*2+1)
    ${wait_time_out}    Evaluate   int('${CounterCollectionInterval}')+1

    Log To Console   Current system time:${vm_time[0]}
    Log To Console   Make Sure PM File Exists(wait_time_out: ${wait_time_out})...
    Wait Until Keyword Succeeds   ${wait_time_out}min   20s    _Make Sure PM File Exists
    ${ret}    ssh.Execute    command=date +"%Y-%m-%d %H:%M:%S"
    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   PM file exists(Current system time:${vm_time[0]}).

    ${local_pm_dir}    Get A Directory    pmcounter
    ${TRANS_LOCAL_PM_FILE}   _Get Current PM File Internal    output_dir=${local_pm_dir}
    Set Test Variable     ${TRANS_LOCAL_PM_FILE}
    Log To Console  End: Get PM File For Current


Get Newest PM File
    [Arguments]    ${output_dir}   ${max_wait_time}    ${pm_file_path}=${PM_FILE_LOCATION}    ${desired_pm_file_pattern}=${PM_FILE_PATTERN}
    ...   ${org_file_list}=${ORIGINAL_PM_COUNTER_FILE_LIST}   ${pm_file_count}=1
    [Documentation]    Get PM report file from OAM VM after waiting the new file generated. the waiting interval is 10 seconds.
    ...    BK-Area:TRANS-PM
    ...    *AUTHOR* jinbo.yu@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | des_dir | Yes | output destination directory which pm cound file will be saved, e.g: path of ute environment |
    ...    | max_wait_time | Yes | wait time, normally, it can be 15 minutes which is pm counter time interval  |
    ...    | pm_file_path | No | Path of PM files stored in VM, default is ${PM_FILE_LOCATION}bts/pmReports. |
    ...    | pm_file_pattern | No | RE pattern for filtering PM files. |
    ...    | org_file_list | No | orginal pm file list in pm_file_pattern, |
    ...    | | | will wait util max_wait_time exceeded to get latest pm counter file list |
    ...    *RETURN VALUE*
    ...    newest counter file path on output directory
    ...    Example
    ...    | ${pm_file_list}=  | Get Newest PM File |  |
    ${org_pm_file_list}   Run Keyword If  ${org_file_list.__len__()}==0
    ...   List File Or Directory Info    path=${pm_file_path}   file_pattern=${desired_pm_file_pattern}    option=File
    ...   ELSE   set variable    ${org_file_list}

    ${cur_pm_file}    Run Keyword If    ${org_pm_file_list.__len__()}==0
    ...   _Wait For PM File Generate  pm_file_path=${pm_file_path}
    ...   file_pattern=${desired_pm_file_pattern}   timeout=${maxwait_time}
    ...   ELSE IF    ${org_pm_file_list.__len__()}!=0 and ${org_file_list.__len__()}==0    set variable    ${org_pm_file_list}
    ...   ELSE    wait until keyword succeeds    ${max_wait_time}mins    20
    ...   _get latest pm file list after specified count of new pm files generated    org_pm_file_list=${org_pm_file_list}
        ...   pm_file_count=${pm_file_count}   pm_file_path=${pm_file_path}    desired_pm_file_pattern=${desired_pm_file_pattern}

    ${pm_file_name}    Run Keyword If    ${org_pm_file_list.__len__()}==0    Set Variable    ${cur_pm_file}
    ...   ELSE   set variable   ${cur_pm_file[0]["name"]}

    Run Keyword If   '${pm_file_name}'=='None'  Fatal Error   can't get PM counter after ${max_wait_time}mins
    ${des_path}=    Join Path    ${output_dir}    ${pm_file_name}
    ${file_path}=    Join Path    ${pm_file_path}     ${pm_file_name}

    TAF Connect To DU OAM
    ${TRANS_LOCAL_PM_FILE_TIMESTAMP}   Get Modified Time By Linux Cmd   filename=${file_path}
    File Name And Timestamp Should Be Correct   file_name=${file_path}    timestamp=${TRANS_LOCAL_PM_FILE_TIMESTAMP}
    Set Test Variable   ${TRANS_LOCAL_PM_FILE_TIMESTAMP}

    ssh.Download File   remote_path=${file_path}   local_path=${des_path}
    OperatingSystem.File Should Exist    ${des_path}

    ${cmd}   Set Variable  uncompress ${des_path}
    Run Process   ${cmd}   shell=true
    OperatingSystem.Remove File   ${des_path}

    ${des_xml_file}   ${rest}   Split String From Right   ${des_path}  .  1

    Set Suite Variable    ${des_xml_file}
    [Return]    ${des_xml_file}


_Make Sure PM File Exists
    ${ORIGINAL_PM_COUNTER_FILE_LIST}   List File Or Directory Info   path=${PM_FILE_LOCATION}  file_pattern=${PM_FILE_PATTERN}  option=File
    Set Test Variable    ${ORIGINAL_PM_COUNTER_FILE_LIST}
    ${pm_file_number_len}   Get Length  ${ORIGINAL_PM_COUNTER_FILE_LIST}
    Should Be True  ${pm_file_number_len}>0


_Get Current PM File Internal
    [Arguments]    ${output_dir}    ${pm_file_path}=${PM_FILE_LOCATION}    ${PM_FILE_PATTERN}=${PM_FILE_PATTERN}
    [Documentation]    Get PM report file from OAM VM after waiting the new file generated.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | des_dir | Yes | output destination directory which pm cound file will be saved, e.g: path of ute environment |
    ...    | pm_file_path | No | Path of PM files stored in VM, default is /tmp/bts/pmReports. |
    ...    | pm_file_pattern | No | RE pattern for filtering PM files. |
    ...    *RETURN VALUE*
    ...    Current existed counter file path on output directory
    ...    Example
    ...    | ${local_pm_dir}  |  Get A Directory  |  pmcounter |
    ...    | ${pm_file_list}  | _Get Current PM File Internal |  ${local_pm_dir} |
    ${tmp_file_list}   List File Or Directory Info    path=${pm_file_path}   file_pattern=${PM_FILE_PATTERN}   option=File
    ${status}   ${pm_file_name}   Run Keyword And Ignore Error  Set Variable   ${tmp_file_list[0]["name"]}
    Run Keyword If   '${status}'!='PASS'  Fatal Error   can't get PM counter file!
    ${remote_full_path_file}   OperatingSystem.Join Path  ${pm_file_path}   ${pm_file_name}
    ${local_ute_full_path_file}   OperatingSystem.Join Path  ${output_dir}   ${pm_file_name}

    ${TRANS_LOCAL_PM_FILE_TIMESTAMP}  trans_pm.Get Modified Time By Linux Cmd   filename=${remote_full_path_file}
    File Name And Timestamp Should Be Correct   file_name=${remote_full_path_file}    timestamp=${TRANS_LOCAL_PM_FILE_TIMESTAMP}
    Set Test Variable   ${TRANS_LOCAL_PM_FILE_TIMESTAMP}

    ssh.Download File    remote_path=${remote_full_path_file}   local_path=${local_ute_full_path_file}
    OperatingSystem.File Should Exist    ${local_ute_full_path_file}

    ${cmd}   Set Variable  uncompress ${local_ute_full_path_file}
    Run Process   ${cmd}   shell=true
    OperatingSystem.Remove File   ${local_ute_full_path_file}

    [Return]    ${local_ute_full_path_file}


_Wait For PM File Generate
    [Arguments]    ${pm_file_path}=${PM_FILE_LOCATION}    ${file_pattern}=${PM_FILE_PATTERN}   ${timeout}=30
    [Documentation]    Get latest pm file from OM VM
    ...    *AUTHOR* fen.huang@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | pm_file_path | No | The remote direciton of PM file, default value: ${PM_FILE_LOCATION}bts/pmReports |
    ...    | file_pattern | No | File pattern for file filtering, default value: (.*?)xml.gz$ |
    ...    | timeout | No | Timeout for pm file generation |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | _Wait For PM File Generate | /tmp |
    ${loop_count}    Evaluate    ${timeout}/2+1
    FOR    ${index}    IN RANGE    0    ${loop_count}
         ${file_name}=    Get Latest File Name    parent_dir=${pm_file_path}   file_pattern=${file_pattern}
         Exit For Loop If    "${file_name}"!="None"
         Sleep    20
    END
    [Return]    ${file_name}


_Get Latest PM File List After Specified Count Of New PM Files Generated
    [Arguments]    ${org_pm_file_list}    ${pm_file_count}=1    ${pm_file_path}=${PM_FILE_LOCATION}   ${desired_pm_file_pattern}=${PM_FILE_PATTERN}
    [Teardown]  Run Keyword And Ignore Error  TAF Disconnect From DU OAM
    [Documentation]    Get PM report file from OAM VM after specified count of new PM files generated since test started.
    ...    *AUTHOR* jun.6.he@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | org_pm_file_list | Yes | Original file list before test execution, can be fetched via kw |
    ...    | | | List File Or Directory Info. |
    ...    | pm_file_count | No | Count of how many new PM files need to generated before fetch them. |
    ...    | | | default is 1. |
    ...    | pm_file_path | No | Path of PM files stored in VM, default is ${PM_FILE_LOCATION}bts/pmReports. |
    ...    | pm_file_pattern | No | RE pattern for filtering PM files. |
    ...    *RETURN VALUE*
    ...    list(refer to kw List File Or Directory Info)
    ...    Example
    ...    | ${org_pm_file_list}=  | List File Or Directory Info | ${PM_FILE_LOCATION}bts/pmReports |
    ...    | | BTS\\d+_PM_\\d{8}_\\d{6}_SRAN_xml.gz | File |
    ...    | ${cur_pm_file_list}=  | wait until keyword succeeds | 35mins | 5mins |
    ...    | | Get latest PM file list after specified count of new PM files generated |
    ...    | | ${org_pm_file_list} | 1 |
    ...    | ${first_pm_file}=  | Set variable | ${cur_pm_file_list[0].name} |
    TAF Connect To DU OAM
    ${pm_file_list}    List File Or Directory Info   path=${pm_file_path}   file_pattern=${desired_pm_file_pattern}    option=File
    @{org_pm_name_list}        create list
    FOR   ${i}  IN  @{org_pm_file_list}
        Append To List  ${org_pm_name_list}  ${i["name"]}
    END
    List Should Contain Sub List   ${org_pm_file_list}   ${pm_file_list[${pm_file_count}::]}

    FOR  ${i}  IN  @{pm_file_list[:${pm_file_count}:]}
        List Should Not Contain Value  ${org_pm_name_list}   ${i["name"]}
    END
    [Return]    ${pm_file_list}


Get VNF VM Role TNL Number Map
    ${rtn_map}  Create Dictionary
    FOR  ${vm}   IN   @{DU_ALL_VM}
        #${instanceid}     Get Active VM ID By Role   ${vm}
        #${tnl_number}     Rest_Get_Tnl_Id   ${VNF_HOSTNAME_PREFIX}${vm}-${instanceid}
        #${tnl_number}   Evaluate  str(${tnl_number})
        ${tnl_number}    Set Variable  ${DU_TNL_OAM}
        Set To Dictionary   ${rtn_map}   ${vm}  ${tnl_number}
    END

    [Return]  ${rtn_map}


Get One PM Counter Valule From Local PM File And Verify It
    [Arguments]     ${counter_info}   ${vnf_vm_role_and_tnl_map}   ${CounterCollectionInterval}
    [Documentation]  Get One PM Counter Valule From Local PM File And Verify It
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_info | Yes | counter information includes distName, counter name, |
    ...    | | | e.g, TNLSVC-1/TNL-TNLINSTANCE_CPIF/IPNO-1/IPIF-2;M51321C6,yes,100 |
    ...    | vnf_vm_role_and_tnl_map | Yes | vnf_vm_role_and_tnl dictionary, key/value is <VM_ROLE>/<TNL_instance_number>, |
    ...    | | | e.g, OAM/7, CCP/8, CES/9, UES/10,CPIF/11 |
    ...    *RETURN VALUE*
    ...    PM counter value and timestamp is update to ${returned_pm_counter_result_dict}
    ...    Example
    ...    | Get PM File For Next |
    ...    | ${vm_role_tnl_number_map} |  Get VNF VM Role TNL Number Map |
    ...    | ${temp_counter_result}    | Create Dictionary |
    ...    | ${VM_ROLE_TNL_NUMBER_MAP} | Get VNF VM Role TNL Number Map |
    ...    | Set Test Variable  | ${VM_ROLE_TNL_NUMBER_MAP} |
    ...    | ${counter_rec} | set variable | TNLSVC-1/TNL-TNLINSTANCE_CPIF/IPNO-1/IPIF-2;M51321C6,yes,1  |
    ...   | Get One PM Counter Valule From Local PM File And Verify It | ${counter_rec} | ${VM_ROLE_TNL_NUMBER_MAP} |
    ${list_detailed_counter}  Split String   ${counter_info}   ;
    ${distName}   Set Variable    ${ROOT_CLASS_NAME}-${DU_BTS_ID}/${list_detailed_counter[0]}
    ${distName}   Counter Handle DistName   vm_role_and_tnl_number_map=${vnf_vm_role_and_tnl_map}  distName=${distName}

    ${list_len}   Get Length   ${list_detailed_counter}
    FOR  ${i}    IN RANGE    1   ${list_len}
         Log To Console    ${list_detailed_counter[${i}]}
         #${one_counter_meta_data}    Split String   ${list_detailed_counter[${i}]}   ,
         #${counter_name}    ${increasement}   Set Variable   ${one_counter_meta_data}
         ${one_counter_meta_data}     Split String    ${list_detailed_counter[${i}]}    ,
         ${counter_name}    Set Variable    ${one_counter_meta_data[0]}
         ${increasement}    Set Variable If    ${one_counter_meta_data.__len__()}>=2    ${one_counter_meta_data[1]}    5
         ${max}    Set Variable If    ${one_counter_meta_data.__len__()}==3    ${one_counter_meta_data[2]}    ${EMPTY}
         #${increasement}  Set Variable If   '${increasement}'=='${EMPTY}'   5    ${increasement}
         Log To Console  distname:${distName}, count name:${counter_name}, increasement:${increasement}, max:${max}
         Continue For Loop If   '${increasement.strip()}'=='-999'
         ${result}  ${result2}  Run Keyword If   '${increasement.strip()}'=='-1'    Run Keyword And Ignore Error
         ...   Get Counter By DistName From Local PM File Check Timestamp    distName=${distName}
         ...   counter_name=${counter_name}   CounterCollectionInterval=${CounterCollectionInterval}
         Run Keyword If   '${increasement.strip()}'=='-1'  Run Keyword And Continue On Failure   Should Be True  '${result}'=='PASS'
         ${value}   Set Variable If    '${increasement.strip()}'=='-1' and '${result}'=='PASS'    ${result2[0]}
         Run Keyword If    '${increasement.strip()}'=='-1' and '${result}'=='PASS'   Should Be True  ${value}>=0
         Continue For Loop If   '${increasement.strip()}'=='-1'
         Run Keyword If  '${increasement.strip()}'=='-2'  Counter Should Not Exist By DistName From Local PM File  distName=${distName}
         ...   counter_name=${counter_name}
         Continue For Loop If   '${increasement.strip()}'=='-2'
         ${result}  ${result2}  Run Keyword And Ignore Error  Get Counter By DistName From Local PM File Check Timestamp  distName=${distName}
         ...   counter_name=${counter_name}   CounterCollectionInterval=${CounterCollectionInterval}
         ${value}   Set Variable If      '${result}'=='PASS'    ${result2[0]}
         ${timestamp}   Set Variable If  '${result}'=='PASS'    ${result2[1]}
         Run Keyword And Continue On Failure  Should Be True  '${result}'=='PASS'
         Run Keyword If   ${increasement}==0   Run Keyword And Continue On Failure  Should Be True  ${value}==0
         Continue For Loop If  ${increasement}==0
         Run Keyword If   ${increasement}>0   Run Keyword And Continue On Failure  Should Be True  ${value}>=${increasement}
         Run Keyword If   '${max}'!='${EMPTY}'   Run Keyword And Continue On Failure  Should Be True  ${value}<=${max}
         ${timestamp}  Set Variable If  '${result}'!='PASS'
         ...   No timestamp for calling failure of 'Get Counter By DistName From Local PM File'   ${timestamp}
         ${output_key_list}   Create List  ${distName}   ${counter_name}
         ${output_key_tuple}   Evaluate  tuple(${output_key_list})
         ${output_value}  Create Dictionary  value=${value}   timestamp=${timestamp}   increasement=${increasement}
         Log To Console   ${output_key_tuple}:${output_value}
    END


Counter Handle DistName
    [Arguments]  ${vm_role_and_tnl_number_map}  ${distName}
    [Documentation]  Replace TNLINSTANCE_<VM_ROLE> to TNL instance,
    ...    e.g, replace 'TNLSVC-1/TNL-TNLINSTANCE_OAM/IPNO-1/IPIF-1' to 'TNLSVC-1/TNL-7/IPNO-1/IPIF-1'
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | des_dir | Yes | output destination directory which pm cound file will be saved, e.g: path of ute environment |
    ...    | pm_file_path | No | Path of PM files stored in VM, default is /tmp/bts/pmReports. |
    ...    | pm_file_pattern | No | RE pattern for filtering PM files. |
    ...    *RETURN VALUE*
    ...    Current existed counter file path on output directory
    ...    Example
    ...    | ${distName}               | Set Variable  | MRBTS-3006/TNLSVC-1/TNL-TNLINSTANCE_OAM/IPNO-1/IPIF-1 |
    ...    | ${vm_role_tnl_number_map} |  Get VNF VM Role TNL Number Map |
    ...    | ${distName}               | Counter Handle DistName   | ${vm_role_tnl_number_map} | ${distName} |
    ...    | #now ${distName} equal to MRBTS-3006/TNLSVC-1/TNL-7/IPNO-1/IPIF-1 |
    FOR  ${vm}   IN   @{DU_ALL_VM}
        ${tnl_number}   Get TNL Number  vm=${vm}
        ${distName}  Run Keyword If   "TNL${VM}" in "${distName}"   Replace String   ${distName}   TNL${VM}   ${tnl_number}
        ...    ELSE   set variable  ${distName}
    END

    #For VM Instance
    FOR  ${vm}   IN   @{DU_ALL_VM}
        ${tnl_number}   Get From Dictionary   ${vm_role_and_tnl_number_map}   ${vm}
        ${distName}  Run Keyword If   "TNLINSTANCE_${VM}" in "${distName}"   Replace String   ${distName}   TNLINSTANCE_${VM}   ${tnl_number}
        ...    ELSE   set variable  ${distName}
    END
    [Return]   ${distName}



Counter Should Not Exist By DistName From Local PM File
    [Arguments]   ${distName}   ${counter_name}
    [Documentation]  Counter Should Not Exist By DistName From Local PM File
    ...    Before calling this KW, 'Get PM File For Next' must be called firstly.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | distName  | Yes  |  distName, e.g, MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
    ...    | counter_name  | Yes  |  counter_name, e.g, M51301C0 |
    ...    *RETURN VALUE*
    ...    None.  Do nothing if counter does not exist, otherwise FAIL the case and continue to run next statement.
    ...    Example
    ...    | Sync To PM Timer Clock |
    ...    | # generate traffic to triggle counter increasement |
    ...    | # ... |
    ...    | Get PM File For Next |
    ...    | ${distName} | set variable | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
    ...    | Run Keyword And Continue | Counter Should Not Exist By DistName From Local PM File | ${distName} |  M51321C1 |

    ${result}  Run Keyword And Ignore Error   Variable Should Exist   ${TRANS_LOCAL_PM_FILE}
    Should Be True   '${result[0]}'=='PASS'
    ${result}   Trans_Counter_Should_Not_Exist  file_name=${TRANS_LOCAL_PM_FILE}    distname=${distName}   counter_id=${counter_name}
    Run Keyword And Continue On Failure  Should Be True   '${result}'=='True'


Get Counter By DistName From Local PM File Check Timestamp
    [Arguments]   ${distName}   ${counter_name}  ${CounterCollectionInterval}=5
    [Documentation]  Get Counter By DistName From Local PM File Check Timestamp
    ...    Before calling this KW, 'Get PM File For Next' must be called firstly.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | distName  | Yes  |  distName, e.g, MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
    ...    | counter_name  | Yes  |  counter_name, e.g, M51301C0 |
    ...    *RETURN VALUE*
    ...    return counter value
    ...    Example
    ...    | Sync To PM Timer Clock |
    ...    | # generate traffic to triggle counter increasement |
    ...    | # ... |
    ...    | Get PM File For Next |
    ...    | ${distName} | set variable | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
    ...    | ${result} | ${result2} | Run Keyword And Ignore Error | Get Counter By DistName From Local PM File | ${distName} |  M51321C1 |
    ...    | ${curr_counter_value}     | Set Variable If | '${result}'=='PASS'  |  ${result2[0]} |
    ...    | ${curr_counter_timestamp} | Set Variable If | '${result}'=='PASS'  |  ${result2[1]} |
    ...    | #now, ${curr_counter_value} is the counter value after traffic |  |

    ${result}  Run Keyword And Ignore Error   Variable Should Exist   ${TRANS_LOCAL_PM_FILE}
    Should Be True   '${result[0]}'=='PASS'
    ${value}  ${timestamp}   Get TRANS Level Counter    file_name=${TRANS_LOCAL_PM_FILE}   distname=${distName}    counter_id=${counter_name}
    ${pure_path}   ${file_name}   Split Path  path=${TRANS_LOCAL_PM_FILE}
    ${expected_ts}  Get PM Timestamp Substract Interval   file_name=${file_name}   CounterCollectionInterval=${CounterCollectionInterval}
    Should Be True   "${expected_ts}"=="${timestamp}"
    [Return]  ${value}   ${timestamp}


Get PM Timestamp Substract Interval
    [Arguments]    ${file_name}    ${CounterCollectionInterval}=5
    ${matches}    Get Regexp Matches    ${file_name}    PM\\.BTS-\\d+\\.(\\d+)\\.(\\d+)\\.\\S+    1    2
    Should Be True    ${matches}
    ${ts_date}    Set Variable    ${matches[0][0]}
    ${ts_time}    Set Variable    ${matches[0][1]}
    ${ts_file}    Convert Date    ${ts_date} ${ts_time}    result_format=timestamp
    ${ts_file}    Subtract Time From Date    ${ts_file}    ${CounterCollectionInterval}min
    ${ts_file}    Add Time To Date    ${ts_file}    ${TIMEZONE_DIFFERENCE}h
    ${ts_file}    Replace String    ${ts_file}    ${SPACE}    T
    #${ts_file}    Set Variable    ${ts_file}+0${TIMEZONE_DIFFERENCE}:00:00
    ${ts_file}    Set Variable    ${ts_file}${TIMEZONE_DIFFERENCE}:00:00
    [Return]  ${ts_file}


Display Counter Table
    [Arguments]  ${counter_table_name}
    Log To Console    ====Handled counters========
    FOR  ${row}   IN   @{counter_table_name}
        Log To Console  ${row}
    END
    ${new_length}   Get Length   ${counter_table_name}
    Log To Console  handled counter number: ${new_length}


PM Test Setup General
    [Arguments]  ${counter_table_name}
    [Teardown]  Run Keyword And Ignore Error   Rest Logout DU
    TRANS Test Common Setup
    Rest Login DU
    run keyword and ignore error  Get Existing Fault Id List
    run keyword and ignore error  Get Existing History Fault Id List
    Display Counter Table   counter_table_name=${counter_table_name}


PM Test Teardown General
    TRANS Test Common Teardown


Step1: Check BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Log To Console  Step1: Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal


StepN: Check BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Log To Console  StepN: Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal


Step2: Sync To PM Timer Clock
    [Arguments]  ${estimated_traffic_generating_duration}=4
    Log To Console  Step2: Sync To PM Timer Clock(estimated_traffic_generating_duration:${estimated_traffic_generating_duration})
    Sync To PM Timer Clock   estimated_traffic_generating_duration=${estimated_traffic_generating_duration}
    ...   PM_collecting_interval=15

Step4: Get Counters After Traffic And Verify Them
    [Arguments]  ${counter_table_name}
    Log To Console   Step4:Get Counters After Traffic And Verify Them
    Get Next Counters And Verify Them   counter_table_name=${counter_table_name}    CounterCollectionInterval=15


Two Numbers Substraction Should Be Less Than
    [Arguments]  ${number1}   ${number2}  ${delta}
    ${diff}  Evaluate  abs(int('${number1}')-int('${number2}'))
    #Log To Console  diff:${diff} seconds
    Should Be True  ${diff}<${delta}
    [Return]  ${diff}


Two Timestamps Interval Should Be N Minutes
    [Arguments]  ${timestamp1}   ${timestamp2}  ${N_minutes}  ${N_delta_seconds}=0
    ${N_minutes_to_seconds}  Evaluate  int('${N_minutes}')*60
    ${substract_result}  Evaluate   int('${timestamp1}')-int('${timestamp2}')
    Two Numbers Substraction Should Be Less Than   number1=${substract_result}    number2=${N_minutes_to_seconds}   delta=${N_delta_seconds}


Change PM Collect Interval
    [Arguments]  ${interval}=15   ${bLougin}=${True}    ${bLougout}=${True}
    [Teardown]  Run Keyword And Ignore Error  Run Keyword If  '${bLougout}'=='True'  WEBUI Logout
    Log To Console  change PM collect interval:${interval}
    Run Keyword If
      ...   ${interval}!=0 and ${interval}!=5 and ${interval}!=15 and ${interval}!=30 and ${interval}!=60
      ...    Fail   interval should be 0, 5, 15, 30 or 60 minutes.

    Run Keyword If  '${bLougin}'=='True'   WEBUI Login
    ${ipV4AddressStatisticsInterval_and_v6}   Set Variable If  ${interval}==5    15min
    ...   ${interval}==0    disabled
    ...   ${interval}min

    ${general_interval}   Set Variable If  ${interval}==0    disabled    ${interval}min

    Configure PMTNL MO   VM_name=OAM   interval=${general_interval}   activate_plan_despite_errors=True
      ...   ipV4AddressStatisticsInterval=${ipV4AddressStatisticsInterval_and_v6}
      ...   ipV6AddressStatisticsInterval=${ipV4AddressStatisticsInterval_and_v6}

    ${general_interval}   Set Variable If  ${interval}==0    5min    ${interval}min
    Configure PMCADM MO   VM_name=OAM   reportingIntervalPm=${general_interval}   activate_plan_despite_errors=True


List File Or Directory Info
    [Arguments]  ${path}   ${file_pattern}=${EMPTY}   ${option}=All
    [Documentation]   List File Or Directory Info
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | path | yes | path |
    ...    | file_pattern | no | file_pattern, regex string , default is ${EMPTY} |
    ...    | option | yes | no | all, file, directory, default value is all |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    file list matches pattern under folder 'path'
    ...    Example
    ...    | ${filename} | Get Latest File Name | /tmp |  PM* |
    ${command}   Set Variable If   "${option.lower()}"== "file"    ls -lt ${path} | grep \"^-\"
    ...    "${option.lower()}"== "directory"    ls -lt ${path} | grep \"^d\"
    ...   ls -lt ${path}

    ${out}  ssh.Send Command   command=${command}
    ${out}  ssh.Read Output

    ${pattern}  Set Variable If  "${file_pattern}"=="${EMPTY}"
    ...  (\\S{10})\\s+(\\d+)\\s+(\\w+)\\s+(\\w+)\\s+(\\d+)\\s+(\\w+\\s+\\d+\\s+\\d{2}(:|)\\d{2})\\s+(\\S+)
    ...  (\\S{10})\\s+(\\d+)\\s+(\\w+)\\s+(\\w+)\\s+(\\d+)\\s+(\\w+\\s+\\d+\\s+\\d{2}(:|)\\d{2})\\s+(${file_pattern})

    ${lines}   Set Variable  ${out.splitlines()}
    ${rtn}   Create List
    FOR  ${line}   IN  @{lines}
         ${matches}  Get Regexp Matches   ${line}   ${pattern}   1  2  3  4  5  6  7  8
         ${matches_len}   Get Length  ${matches}
         Continue For Loop If  ${matches_len}==0
         ${tmp_dict}   Create Dictionary   property=${matches[0][0]}
         ...    count=${matches[0][1]}
         ...    owner=${matches[0][2]}
         ...    owner_group=${matches[0][3]}
         ...    size=${matches[0][4]}
         ...    modified_time=${matches[0][5]}
         ...    name=${matches[0][7]}
        Append To List  ${rtn}  ${tmp_dict}
    END
    [Return]  ${rtn}


Get Modified Time By Linux Cmd
    [Arguments]    ${filename}  ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd | /root/a.txt |
    ${out}    ssh.Execute   command=stat --format=%Y ${filename}  connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get System Time By Linux Cmd
    [Arguments]  ${alias}=default
    [Documentation]   Get system Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${sec} | Get system Time By Linux Cmd | /root/a.txt |
    ${out}    ssh.Execute   command=date +%s   connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Latest File Name
    [Arguments]  ${parent_dir}   ${file_pattern}
    [Documentation]   Get Latest File Name
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | parent_dir | yes | parent_dir |
    ...    | file_pattern | yes | file_pattern, regex string |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    file name matches pattern under folder parent_dir
    ...    Example
    ...    | ${filename} | Get Latest File Name | /tmp |  PM* |
    ${command}   Set Variable   ls --color=auto -tl '${parent_dir}'|awk \'{print $9}\'

    ${out}    ssh.Send Command   command=${command}
    ${out}    ssh.Read Output
    ${lines}   Set Variable  ${out.splitlines()}
    FOR  ${line}   IN  @{lines}
        ${matches}  Get Regexp Matches   ${line}   ${file_pattern}   1
        ${matches_len}   Get Length  ${matches}
        Return From Keyword If   ${matches_len}>=0   ${line.strip()}
    END


File Name And Timestamp Should Be Correct
   [Arguments]   ${file_name}    ${timestamp}   ${alias}=default
    ${matches}    Get Regexp Matches    ${file_name}    PM\\.BTS-\\d+\\.(\\d+)\\.(\\d+)\\.\\S+    1    2
    Should Be True    ${matches}
    ${ts_date}    Set Variable    ${matches[0][0]}
    ${ts_time}    Set Variable    ${matches[0][1]}

    ${ts_file}    Convert Date    ${ts_date} ${ts_time}    result_format=timestamp
    ${out}    ssh.Execute   command=date "+%s" -d "${ts_file}"   connection=${alias}
    ${ts_file}  Get Lines Matching Regexp   ${out}   \\d{8,12}
    ${ts_file}  Evaluate  str(int(${ts_file})+int('${TIMEZONE_DIFFERENCE}')*3600+30)

    Two Numbers Substraction Should Be Less Than   number1=${ts_file}    number2=${timestamp}   delta=30


Get OAM Gateway By Linux Cmd
    [Arguments]    ${alias}=default
    [Documentation]   Get OAM Gateway By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd | /root/a.txt |
    ${out}    ssh.Execute   command=ip route|grep default|awk '{print $3}'  connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d+\\.\\d+\\.\\d+\\.\\d+
    [Return]   ${lines}
