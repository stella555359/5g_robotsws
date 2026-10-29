*** Settings ***
Documentation    log analysis

Library          ./python/command_execution_in_bts.py
Resource         ../resources/common_resources.robot

*** Variables ***
@{L1_ERR_whitelist}     Received unexpected PDCCH send request message
@{L1_WRN_whitelist}     nrDl DU Stats<0> part
...    HB/StartStop/processStartStopHbRequestOnThisProcess more conditional
...    drop_alias_client_msg: Master node ID unknown
...    nbOfEventsToTrigAutoBTSSnapshot RAD should be set to 1 by operator for BBURU capture type
...    ip_mgmt: counters.*have already been subscribed                  # PR811058
...    received AAPRO_NODE_POLL_REQ_MSG with the same transaction id    # adet WRN print to whitelist
...    there is possibly a connectivity problem between                 # adet WRN print to whitelist
...    changeIndication: Unsupported value. Old configuration will be used     # https://gerrit.ext.net.nokia.com/gerrit/c/MN/RPSW/CCS/ccs/+/9722693

*** Keywords ***
###################syslog###########################
Robot Isinstance
    [Arguments]    ${var}    ${type}    ${need_right_type}=${False}
    [Documentation]     To determine the {var} should be the type {type}.
    ...    {var} is the target.
    ...    {type} should be str | int | list | dict | tuple.
    ${type}    Set Variable    ${type.lower()}
    ${var}    Run Keyword If    ',' in '''${var}''' and '[' not in '''${var}''' and '{' not in '''${var}'''    Set Variable     '${var}'
    ...    ELSE    Set Variable    ${var}
    Should Be True    '${type}'=='str' or '${type}'=='int' or '${type}'=='list' or '${type}'=='dict' or '${type}'=='tuple'
    ...    [ERROR] ${type} should be 'int' | 'list' | 'dict' | 'tuple'.
    ${status}    ${isTrue}    Run Keyword And Ignore Error    Evaluate    isinstance(${var}, ${type})
    Run Keyword If    '${status}'=='FAIL'    Log To Console    \n[ERROR] The value <${var}> is NOT ${type}, because of ${isTrue}.
    ${isTrue}    Run Keyword If    '${status}'=='FAIL'    Set Variable    False
    ...    ELSE    Set Variable    ${isTrue}
    ${real_type}    Run Keyword If    ${need_right_type} and '${isTrue}'=='False'    Evaluate    type(${var})
    Run Keyword If    ${need_right_type} and '${isTrue}'=='False'    Log To Console    \n[WARN] The value <${var}> is ${real_type}, but NOT ${type}.
    [Return]    ${isTrue}

Check L1 ERR and WRN in syslog
    ${err_status}=    Run Keyword And Return Status    Get L1 ERR/l1_application
    ${wrn_status}=    Run Keyword And Return Status    Get L1 WRN/l1_application
    ${ignore_err_dicts}    ${final_err_list}    Run Keyword If    ${err_status}    syslog_checker.Get_ERR_and_WRN_info
    ...    ${err_info}    ${L1_ERR_whitelist}
    ${ignore_wrn_dicts}    ${final_wrn_list}    Run Keyword If    ${wrn_status}    syslog_checker.Get_ERR_and_WRN_info
    ...    ${wrn_info}    ${L1_WRN_whitelist}

    ${isNoneErr}    Run Keyword And Return Status    Should Be True    '''${final_err_list}'''=='None'
    ${isEmptyErr}    Run Keyword And Return Status    Should Be Empty    ${final_err_list}

    ${isNoneWrn}    Run Keyword And Return Status    Should Be True    '''${final_wrn_list}'''=='None'
    ${isEmptyWrn}    Run Keyword And Return Status    Should Be Empty    ${final_wrn_list}

    Run Keyword And Continue On Failure    Should Be True    ${isNoneErr} or ${isEmptyErr}
    ...    [ ERROR ] /ERR is visible in SYSLOG:\n${final_err_list}
    Run Keyword And Continue On Failure    Should Be True    ${isNoneWrn} or ${isEmptyWrn}
    ...    [ ERROR ] /WRN is visible in SYSLOG:\n${final_wrn_list}
    # Run Keyword And Warn On Failure    Should Be True    '''${ignore_err_dicts}'''=='None'
    # ...    [ ERROR ] /ERR in white list is visible in SYSLOG:\n${ignore_err_dicts}
    # Run Keyword And Warn On Failure    Should Be True    '''${ignore_wrn_dicts}'''=='None'
    # ...    [ ERROR ] /WRN in white list is visible in SYSLOG:\n${ignore_wrn_dicts}

Get L1 ${err_wrn}
    ${output}    ute_syslog.Message Should Exist In Syslog File    regexp=${err_wrn}    alias=enb_testSetup
    log    L1 ${err_wrn} is ${output}
    Run Keyword If    'ERR' in '${err_wrn}'    Set Test Variable    ${err_info}    ${output}
    Run Keyword If    'WRN' in '${err_wrn}'    Set Test Variable    ${wrn_info}    ${output}

Filter ERR WRN Message From Syslog By Log Path
    [Arguments]    ${log_path}    ${filter_message_file}    ${output_file_path}
    [Documentation]    This keyword is used to filter error and warnning message from syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By Log Path | ${SUITE_LOG_DIRECTORY} ${CURDIR}/filter_msg.txt ${CURDIR}/output_log.txt |
    OperatingSystem.Run And Return Rc And Output    rm -f ${output_file_path}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb*syslog.tar.gz
    Run Keyword If    "${output}"!=""    Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}

Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    FOR    ${file}    IN    @{files_list}
        ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${file}
        Log    ${output}
        Filter ERR WRN Message From Syslog By One File    ${output}    ${filter_message_file}    ${output_file_path}
    END
    ${status}=    Run Keyword And Return Status    File Should Be Empty    ${output_file_path}
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${status}
    #    Run Keyword If    "${status}"=="${False}"    Show Fatal Log    ${output_file_path}
    #    Run Keyword If    "${status}"=="${False}"    Check Syslog L2 Core Dump Error    ${output_file_path}

Show Fatal Log
    [Arguments]    ${output_file}
    ${output}=    Get File    ${output_file}
    Log    ---In ${output_file}:---${output}    WARN

Filter ERR WRN Message From Syslog By One File
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt ${CURDIR}/filter_log.txt ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    Get File    ${filter_message_file}
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
        OperatingSystem.Run And Return Rc And Output    egrep "${filter_item}" ${log_file}>>${output_file}
    END

# ~~~~~~~~~~~~~~~~~~~~~~~~~    BIP analysis    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

Download MCShark To UTE
    [Arguments]    ${sw_version}
    Run    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${MCShark}=    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-*buster.so
    ${version}=    Run    wireshark -v
    ${output}=    Get Regexp Matches    ${version}    Wireshark (...)    1
    ${plugin_path}    Set Variable    /usr/lib/x86_64-linux-gnu/wireshark/plugins/${output[0]}/epan
    Run    sudo rm ${plugin_path}/mcshark-*buster.so
    Run    sudo cp ${MCShark} ${plugin_path}
    ${MCShark}=    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins/${output[0]}/epan/mcshark-*buster.so
    Should Contain    ${MCShark}    ${sw_version}    [ERROR]The MCShark plugin cannot be found in ${plugin_path}

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${filter}    ${csv_column_list}    ${sw_version}=${active_sw}
    [Documentation]    This keyword is used to filter and convert BIP log to csv, and return the csv file path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_file} | Yes | BIP log file path, e.g. /home/ute/bip_test/5GL1L2.pcap. |
    ...    | ${filter} | Yes | filter the messages in pcap file, e.g. uldata_puschreceiverespharqu and uldata_pucchreceiverespharqd |
    ...    | ${csv_column_list} | Yes | column name of csv file, e.g. [3gpp.sfn, 3gpp.slot, UlData_UePuschReceiveRespHarqU_t.crc] |
    ...    | ${sw_version} | No | the version is used to download related MCSark plugin. default is ${active_sw} from Common Test Setup |
    ...    Examples:
    ...    | @{csv_column_list} | Create List | 3gpp.sfn | 3gpp.slot | UlData_UePuschReceiveRespHarqU_t.crc |
    ...    | ${csv_file} | Convert BIP To CSV By MCShark | /home/ute/logs/5GL1L2.pcap | uldata_puschreceiverespharqu | ${csv_column_list}] |
    Download MCShark To UTE    ${sw_version}
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_column_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${output_file}    Set Variable    ${bip_file.strip('pcap')}csv
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    [Return]    ${output_file}

unzip And Get pcap File
    [Arguments]    ${zip_log}
    ${log_path}    Set Variable    ${zip_log.rsplit('/',1)[0]}
    ${unzip_file}    Run    unzip -o ${zip_log} "*.pcap" -d ${log_path}
    #${pcap_log}    Run    ${unzip_file.split('inflating:')[-1].strip()}
    ${pcap_log}    Run    find ${log_path} -name "*.pcap"
    File Should Exist    ${pcap_log}
    [Return]    ${pcap_log}

Filter Source Column And Return Values
    [Arguments]    ${csv_file}    ${column_name}    ${condition}=['0', '1']    ${operation}=include    ${remove_duplicate}=no
    [Documentation]    This keyword is used to filter values of the source column that based on condition.
    ...    if operation==include, return the values is in condition list;
    ...    if operation==except, return the values is not in condition list.
    ...    | Input Parameters | Man. | Description |
    ...    | ${csv_file} | Yes | csv file path |
    ...    | ${column_name} | Yes | the column name in csv file |
    ...    | ${condition} | Yes | the condition list, the values list of the specific column |
    ...    | ${operation} | Yes | include / except |
    ...    | ${remove_duplicate} | Yes | yes / no, remove the duplicate values |
    ${result}    TRACEANALYZER.filter_source_column_return_self    ${csv_file}    ${column_name}    ${condition}
    ...    ${operation}    ${remove_duplicate}
    [Return]    ${result}

Filter Source Column And Return Target Column Values
    [Arguments]    ${csv_file}    ${column_name}    ${condition}=['0', '1']    ${target_column_name}=''    ${operation}=include
    ...    ${remove_duplicate}=no
    [Documentation]    This keyword is used to filter values of the source column that based on condition.
    ...    if operation==include, return target column values list if the source column values are in condition list;
    ...    if operation==except, return target column values list if the source column values are not in condition list.
    ...    | Input Parameters | Man. | Description |
    ...    | ${csv_file} | Yes | csv file path |
    ...    | ${column_name} | Yes | the column name in csv file |
    ...    | ${condition} | Yes | the condition list, the values list of the specific column |
    ...    | ${target_column_name} | Yes | the condition list, the values list of the specific column |
    ...    | ${operation} | Yes | include / except |
    ...    | ${remove_duplicate} | Yes | yes / no, remove the duplicate values |
    ${result}    TRACEANALYZER.filter_source_column_return_other    ${csv_file}    ${column_name}    ${condition}    ${operation}
    ...    ${target_column_name}
    ...    ${remove_duplicate}
    [Return]    ${result}

# ~~~~~~~~~~~~~~~~~~~~~~~~~     Snapshot    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
Get Target Logs From Snapshot
    [Arguments]    ${snapshot}    ${target_file_name}
    ${path}    Split String From Right    ${snapshot}    /    1
    ${log_path}    Set Variable    ${path}[0]
    ${snapshot_file_list_txt}    Run    cd ${log_path}; unzip -o ${path}[1] "snapshot_file_list.txt"
    ${snapshot_file_list}    Run    cd ${log_path};cat snapshot_file_list.txt
    ${file_content_list}    Set Variable    ${snapshot_file_list.split('\n\n')}
    ${tmp_list}    Create List
    FOR    ${file}    IN    @{file_content_list}
        ${next_files}    Set Variable If    '${target_file_name}' in '''${file}'''    ${file}    None
        Run Keyword If    '''${next_files}'''!='None'    Append To List    ${tmp_list}    ${next_files}
    END
    ${isNotEmpty}    Run Keyword And Return Status    Should Not Be Empty    ${tmp_list}
    ${target_files_list}    Run Keyword If    ${isNotEmpty}    _get_target_files    ${tmp_list}
    ...    ELSE    Fail    '[ERROR] ${target_file_name} can NOT be found in snapshot_file_list.txt'
    Log To Console    \n${target_files_list}
    [Return]    ${target_files_list}    ${log_path}

_get_target_files
    [Arguments]    ${target_files_name_list}
    ${target_list}    Create List
    FOR    ${files}    IN    @{target_files_name_list}
        Append To List    ${target_list}    ${files.split('\n')[0].strip(':')}
    END
    [Return]    ${target_list}


Extract Target file From Compressed File
    [Arguments]    ${compress_file}    ${target_startswith}    ${target_endswith}=${EMPTY}    ${file_index}=-1
    File Should Exist    ${compress_file}
    ${path}    Split String From Right    ${compress_file}    /    1
    ${log_path}    Set Variable    ${path}[0]
    ${compress_format}    __get the archive compress format    ${compress_file.split('.', 1)[-1]}
    ${list_cmd}    Run Keyword If    '${compress_format}'=='zip'    Set Variable
    ...    unzip -l ${compress_file} | grep ${target_startswith} | awk '{print $4}'
    ...    ELSE IF    '${compress_format}' in ('txz','gz','tgz','tar')    Set Variable    tar -tf ${compress_file} | grep ${target_startswith}
    ...    ELSE IF    '${compress_format}'=='tar.gz'    Set Variable    tar -tzf ${compress_file} | grep ${target_startswith}
    ...    ELSE IF    '${compress_format}' in ('xz',)    Set Variable    ls ${compress_file}
    ...    ELSE    Fail    '[ERROR] NOT supported compress format.'
    ${file_info}    Run    ${list_cmd}
    ${isNotEmpty}    Run Keyword And Return Status    Should Not Be Empty    ${file_info}
    ${files}    Set Variable If    ${isNotEmpty}    ${file_info.split(' ')[-1].strip('./').strip()}    ${EMPTY}
    Should Not Be Empty    ${files}    [ ERROR ] No ${target_startswith} found in ${compress_file}.
    ${original_split_list}    Set Variable If    ${isNotEmpty}    ${files.split('\n')}    {EMPTY}

    ${files_split_list}    Evaluate    [file for file in ${original_split_list} if file.endswith('${target_endswith}')]

    ${file_count}    Get Length    ${files_split_list}
    Run Keyword If    ${file_count} < 1
    ...    Fail    [ ERROR ] File [ startswith :: ${target_startswith} | endswith :: ${target_endswith} ] is NOT found, Did you mean\n ${file_info}?
    ...    ELSE    Log To Console    [ INFO ] ${file_count} * [ startswith :: ${target_startswith} | endswith :: ${target_endswith} ] are found

    ${target_list}    Run Keyword If    '${file_index}'=='all'    Set Variable    ${files_split_list}
    ...    ELSE    Create List    ${files_split_list}[${file_index}]
    ${files_list}    Set Variable If    '${file_index}'=='all'    ${files_split_list}    ${target_list}

    ${files_list_count}    Get Length    ${files_list}
    Run Keyword If    ${files_list_count} < 1
    ...    Fail    [ ERROR ] The [ ${file_index} ] element in ${files_split_list} are NOT exists.
    ...    ELSE    Log To Console    [ INFO ] ${files_list_count} * ${files_list} is selected and going to be uncompressed.

    ${find_files_list}    Create List
    FOR    ${file}    IN     @{files_list}
        ${uncompress_cmd}    Run Keyword If    '${compress_format}'=='zip'
        ...    Set Variable    cd ${log_path}; unzip -o ${compress_file} "${file.strip()}"
        ...    ELSE IF    '${compress_format}' in ('txz','tgz','tar', 'tar.gz', 'tar.xz')
        ...    Set Variable    cd ${log_path}; tar -xvf ${compress_file} --wildcards '*${file}*'
        ...    ELSE IF    '${compress_format}' in ('xz')
        ...    Set Variable    xz -d ${compress_file.replace('home','/home')}; ls ${log_path} | grep ${target_startswith}
        ...    ELSE IF    '${compress_format}' in ('gz')    Set Variable    cd ${log_path}; gunzip -v ${compress_file}| grep ${target_startswith}
        ...    ELSE    Fail    ${compress_format} is NOT supported, need to be implemented.

        ${target_file}    Run Keyword If    '${file}'!='None'   Run    ${uncompress_cmd}
        ...    ELSE    Fail    "[ERROR] '${target_startswith}' can NOT be found in '${compress_file}'."

        Should Not Be Empty    ${target_file}
        ${file_name_list}    Set Variable    ${target_file.split(':')[-1].strip().split('\n')}
        ${find_files_list}    Combine Lists    ${find_files_list}    ${file_name_list}
    END
    ${find_files}    Set Variable If    '${file_index}'=='all'    ${find_files_list}    ${find_files_list}[${file_index}]
    Log To Console    [ INFO ] ${find_files} is found.
    [Return]    ${find_files}    ${log_path}

__get the archive compress format
    [Arguments]    ${postfix}
    @{compress_format_list}    Create List    gz    xz    tgz    txz    zip    tar    tar.gz    tar.xz

    @{aa_to_az_list}=    Create List    aa    ab    ac    ad    ae    af    ag    ah    ai    aj    ak
    ...    al    am    an    ao    ap    aq    ar    as    at    au    av    aw    ax    ay    az

    ${isExistd}    Run Keyword And Return Status    Should Contain    ${compress_format_list}    ${postfix}
    ${re_split}    Set Variable    ${postfix.split('.')}[-1]
    ${compress_format}    Run Keyword If    ${isExistd}    Set Variable    ${postfix}
    ...    ELSE IF    '${re_split}' in ${compress_format_list}    Set Variable    ${re_split}
    ...    ELSE IF    '${re_split}' in ${aa_to_az_list}    Set Variable    merge
    ...    ELSE    Log    To be implemented
    [Return]    ${compress_format}

Get Snapshot Documentation
    [Arguments]    ${save_path}    ${build}
    ${release_tag}    Set Variable    ${build.split('_')[0]}
    ${root_link}    Set Variable    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
    ${hz_link}    Set Variable    ${root_link}/${release_tag}/${build}/
    ${doc_link}    Set Variable    ${build}_snapshot_documentation.tgz
    ${download}    Run    wget -t 0 -c --progress=bar ${hz_link}/${doc_link} -O ${save_path}/${doc_link}
    File Should Exist    ${save_path}/${doc_link}
    [Return]    ${save_path}/${doc_link}

Extract Specific Logs From Snapshot
    [Arguments]    ${log_folder}    ${snapshot}    ${node_id}
    ${target_log_name}    Run Keyword If    '${log_folder.lower()}'=='coredump'    Set Variable    l1_application_rt.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('servicefailures', 'service failures', 'service_failures')
    ...    Set Variable    l1sw-rt-launcher.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('l1acrashtrace')    Set Variable    ${node_id}D_l1a_crash_trace.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('mdab', 'mdab_crash_files')    Set Variable    ${node_id}D_mdab_CNCBP14_crash
    ...    ELSE IF    '${log_folder.lower()}' in ('mhab', 'mhab_crash_files')    Set Variable    ${node_id}D_mhab_MHAB_ULFE0_crash
    ...    ELSE    Fail    [ERROR] ${log_folder} is NOT supported now, it need to be implemented later.
    ${target_zip_file}    Run Keyword If    '${log_folder.lower()}'=='coredump'    Set Variable    ${node_id}D_l1p_crash.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('servicefailures', 'service failures', 'service_failures')
    ...    Set Variable    ${node_id}D_l1p_crash.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('l1acrashtrace')    Set Variable    ${node_id}D_l1a_crash_trace.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('mdab', 'mdab_crash_files')    Set Variable    ${node_id}D_l1a_crash.tgz
    ...    ELSE IF    '${log_folder.lower()}' in ('mhab', 'mhab_crash_files')    Set Variable    ${node_id}D_l1a_crash.tgz
    ...    ELSE    Fail    [ERROR] ${log_folder} is NOT supported now, it need to be implemented later.
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${target_zip_file}
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${target_zip_file}
    IF    '${target_log_name}' == '${target_zip_file}'
        ${forth_zip}    Set Variable    ${third_zip}
        ${path3}    Set Variable    ${path2}
    ELSE
        ${forth_zip}    ${path3}    Extract Target file From Compressed File    ${path2}/${third_zip}    ${target_log_name}
    END
    ${files}    Run    tar -tvf ${path3}/${forth_zip} | awk '{print $3, $6}'
    log    ${files}
    ${tmp_files_list}    Split String    ${files}    \n
    ${files_dict}    Create Dictionary
    FOR    ${file}    IN    @{tmp_files_list}
        ${size}    Set Variable    ${file.split()[0]}
        ${name}    Set Variable    ${file.split()[1].split('/')[-1]}
        ${size}    Convert To Integer    ${size}
        Run Keyword If    '${name}'!=''    Set To Dictionary    ${files_dict}    ${name}    ${size}
        ...    ELSE    Log To Console    [ WARN ] ${file} is NOT a file or NOT the target file.
    END

    [Return]    ${files_dict}
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${path1}/${second_zip}    ${path2}/${third_zip}    ${path3}/${forth_zip}

Extract rpramjournal Logs In Local rpram From Snapshot
    [Documentation]     crash_time should be got when perform mdab/mhab crash. format:date +"%Y-%m-%dT%H"
    [Arguments]    ${snapshot}    ${node_id}    ${crash_time}    ${crash_type}=MHAB    ${target_log_name}=rpramjournal
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id}D_l1p_crash.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${node_id}D_l1p_crash.tgz
    ${files}    Run    tar -tvf ${path2}/${third_zip} | awk '{print $3, $6}'
    log    ${files}
    ${test_end_time}    Get Time    result_format=%Y-%m-%d %H:%M:%S
    Log    Test End Time: ${test_end_time}
    ${tmp_files_list}    Split String    ${files}    \n
    ${files_dict}    Create Dictionary
    ${kenel_console_dict}    Create Dictionary
    FOR    ${file}    IN    @{tmp_files_list}
        IF    '${target_log_name}' not in '${file}'
            CONTINUE
        END
        ${extracted_time}    Extract Time From Log File    ${file}
        Log    Extracted time from ${file}: ${extracted_time}
        ${size}    Set Variable    ${file.split()[0]}
        ${name}    Set Variable    ${file.split()[1].split('/')[-1]}
        ${size}    Convert To Integer    ${size}
        ${is_in_range}    Validate Time Range    ${extracted_time}    ${crash_time}    ${test_end_time}
        Run Keyword If    '${name}'!='' and ${is_in_range} and 'previous_boot_running_journal' in '${name}'
        ...    Set To Dictionary    ${files_dict}    ${name}    ${size}
        ...    ELSE    Log To Console    [WARN] ${file} is NOT a file or NOT the target file.
        Run Keyword If    '${name}'!='' and ${is_in_range} and 'previous_boot_kernel_console' in '${name}'
        ...    Set To Dictionary    ${kenel_console_dict}    ${name}    ${size}
        ...    ELSE    Log To Console    [WARN] ${file} is NOT a file or NOT the target file.
    END

    ${files_dict_length}    Get Length    ${files_dict}
    Run Keyword If    ${files_dict_length} == 1
    ...    Log To Console    [INFO]: ${files_dict_length}  crash log meet expected.
    ...    ELSE
    ...    Fail    it contains ${files_dict_length} crash log, which is more than 1. Only 1 crash log is allowed.
    Check log print in rpram log   ${path2}    ${third_zip}    ${files_dict}    ${crash_type}

    [Return]    ${files_dict}
    [Teardown]    Remove Files    ${path1}/${second_zip}    ${path2}/${third_zip}

Check log print in rpram log
    [Arguments]    ${path}    ${target_package}    ${files_dict}    ${crash_type}=MHAB
    ${dict_keys}=    Get Dictionary Keys    ${files_dict}
    Remove Directory    ${path}/crash_log    ignore_errors=True
    Create Directory    ${path}/crash_log
    Run    tar -zxf ${path}/${target_package} -C ${path}/crash_log
    ${gz_file_path}=    Set Variable    ${path}/crash_log/local_rpram/${dict_keys}[0]
    Run    gzip -d ${gz_file_path}
    ${log_file}=    Evaluate    '${gz_file_path}'.replace('.gz', '')
    ${crash_regexp}    Run Keyword If    '${crash_type.lower()}'=='arm'    Set Variable    "crashed due to signal 11"
    ...    ELSE IF    '${crash_type.lower()}'=='mhab'    Set Variable    "Found MHAB crash initiator"
    ...    ELSE    Fail    [ ERROR ] No '${crash_type}' crash type implemented.

    ${isCrashReset}=    Run    cat ${log_file} | grep ${crash_regexp}
    Should Not Be Empty    ${isCrashReset}    [ERROR] The reset is not caused by MHAB/ARM crash, please check further.
    Remove Directory    ${path}/crash_log    ignore_errors=True

Extract Time From Log File
    [Arguments]    ${log_file_path}
    ${start_pos}=    Evaluate    '${log_file_path}'.find('rpramjournal_') + 13
    ${end_pos}=    Evaluate    '${log_file_path}'.find('_previous_boot')
    ${extracted_timestamp}=    Get Substring    ${log_file_path}    ${start_pos}    ${end_pos}
    ${timestamp_length}=    Get Length    ${extracted_timestamp}
    Run Keyword If    ${timestamp_length} < 19
    ...    Fail    Could not extract valid timestamp from ${log_file_path}
    ${formatted_time}=    Evaluate    '${extracted_timestamp}'.replace('T', ' ').replace('_', ':')
    RETURN    ${formatted_time}

Validate Time Range
    [Arguments]    ${file_time}    ${start_time}    ${end_time}
    ${is_after_start}=    Evaluate    '${file_time}' >= '${start_time}'
    ${is_before_end}=    Evaluate    '${file_time}' <= '${end_time}'
    ${is_in_range}=    Evaluate    '${file_time}' >= '${start_time}' and '${file_time}' <= '${end_time}'
    Log    File time: ${file_time}, Test Start: ${start_time}, Test End: ${end_time}
    Log    Is in range (with tolerance): ${is_in_range}
    RETURN    ${is_in_range}

Get And Check Specific Logs Size
    [Arguments]    ${files_dict}    ${startswith}=${EMPTY}    ${endswith}=${EMPTY}
    ${tmp_dict}    Create Dictionary
    ${files_list}    Get Dictionary Keys    ${files_dict}
    FOR    ${file}    IN    @{files_list}
        ${size}    Run Keyword If    ${file.startswith('${startswith}')} and ${file.endswith('${endswith}')}
        ...    Get From Dictionary    ${files_dict}    ${file}
        Run Keyword If    '${size}'!='None'    Set To Dictionary    ${tmp_dict}    ${file}    ${size}
    END
    Should Not Be Empty    ${tmp_dict}    [ERROR] No filename is startswith:${startswith} and endswith:${endswith}.
    ${tmp_files_list}    Get Dictionary Keys    ${tmp_dict}
    FOR    ${file}    IN    @{tmp_files_list}
        ${size}    Get From Dictionary    ${tmp_dict}    ${file}
        Log To Console    ${file} -- ${size}
        Run Keyword And Continue On Failure    Should Be True     ${size}>1    [ERROR] The size of ${file} is less than 1 Kb: ${size}.
    END

Upload Logs To Rotta
    [Arguments]    ${local_logs}    ${rotta_path}=//eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2a_regression
    ${local_path}    Set Variable    /mnt/rotta/snapshots
    ${isNotExisted}    Run Keyword And Return Status    Directory Should Not Be Empty    ${local_path}
    Run Keyword If    ${isNotExisted}    Create Directory    ${local_path}
    Mount ROTTA network drive to the mounting point    ${local_path}    ${rotta_path}
    Copy Files    ${local_logs}    ${local_path}
    ${path}    ${filename}    Split Path    ${local_logs}
    File Should Exist    ${local_path}/${local_logs}    [ ERROR ] ${filename} is NOT be copied to ROTTA network drive: ${local_path}.

# ~~~~~~~~~~~~~~~~~~~~~~~~~     L1 journal log in Snapshot    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
Filter And Check DU L1 Journal Log
    [Arguments]    ${snapshot}
    [Documentation]    To filter and check /ERR, /WRN, Handling signal. there are white list for ERR and WRN.
    Log To Console    [ INFO ] Starting to filter and check DU L1 journal log ... ...

    ${target_log_list}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    D_l1p_syslog.tgz
    FOR    ${syslog}    IN    @{target_log_list}
        ${target_zip}    ${first_path}    Extract Target file From Compressed File    ${snapshot}    ${syslog}
        ${D_syslog_tgz}    ${second_path}    Extract Target file From Compressed File    ${first_path}/${target_zip}    D_l1p_syslog.tgz
        ${journal_txt}    ${third_path}    Extract Target file From Compressed File    ${second_path}/${D_syslog_tgz}    journal
        File Should Exist    ${third_path}/${journal_txt}
        ${file_hierarchy}    Set Variable    ${target_zip} -> ${D_syslog_tgz} -> ${journal_txt}
        __Check ERR WRN In Log    ${third_path}/${journal_txt}    ${file_hierarchy}
        Remove Files    ${first_path}/${target_zip}    ${second_path}/${D_syslog_tgz}    ${third_path}/${journal_txt}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${first_path}/${target_zip}    ${second_path}/${D_syslog_tgz}
    ...    ${third_path}/${journal_txt}

Filter And Check RU L1 Runtime Log
    [Arguments]    ${snapshot}
    [Documentation]    To filter and check /ERR, /WRN, Handling signal. there are white list for ERR and WRN.
    Log To Console    \n[ INFO ] Starting to filter and check RU L1 Runtime log ... ...

    ${FRIps_list}    get_FRIps_from    192.168.255.1
    @{productNameList}    Create List
    FOR    ${rmod}    IN    @{FRIps_list}
        ${productName}    Set Variable    ${rmod.split(';')[-1]}
        Append To List    ${productNameList}    ${productName}
    END
    Log To Console    ❄❄❄ [ INFO ] Filter and Check ${productNameList} L1 log
    ${isRF7}    Evaluate    any(rf.startswith('AVQ') for rf in ${productNameList})
    ${isMade2}    Evaluate    any(rf.startswith('AKQ') for rf in ${productNameList})

    Run Keyword If    ${isRF7}    _RF7 L1 Runtime Log Check    ${snapshot}
    ...    ELSE IF    ${isMade2}    _RF6 Made2 L1 Runtime Log Check    ${snapshot}
    ...    ELSE    Log To Console    [ WARN ] Need to be implemented later.

_RF7 L1 Runtime Log Check
    [Arguments]    ${snapshot}
    Log To Console    ❄❄❄ [ INFO ] RF7 RU L1 Runtime log
    ${target_log_list}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    l1-runtime.tar.gz

    FOR    ${targetlog}    IN    @{target_log_list}
        ${isCompressedIn_BTS_Part_X}    Set Variable If    'BTS_part' in '${targetlog}'    True    False
        ${target_file}    ${target_path}    Run Keyword If    ${isCompressedIn_BTS_Part_X}
        ...    Extract Target file From Compressed File    ${snapshot}    ${targetlog}
        ...    ELSE    Set Variable    ${targetlog}    ${root_path}
        ${first_log}    Set Variable If    ${isCompressedIn_BTS_Part_X}    ${target_path}/${target_file}    ${snapshot}
        ${first_target}    Set Variable If    ${isCompressedIn_BTS_Part_X}    l1-runtime.tar.gz    ${targetlog}
        ${senond_file}    ${second_path}    Extract Target file From Compressed File    ${first_log}    ${first_target}
        ${third_file}    ${third_path}    Extract Target file From Compressed File    ${second_path}/${senond_file}    l1sw.txz
        ${forth_files}    ${forth_path}    Extract Target file From Compressed File    ${third_path}/${third_file}    l1_runtime    .log    all
        FOR    ${file}    IN    @{forth_files}
            ${target_file}    Set Variable If    ${file.endswith('l1_runtime.log')}    ${file}    NotFound
            Exit For Loop If    '${target_file}'!='NotFound'
        END
        File Should Exist    ${forth_path}/${target_file}    [ ERROR ] RU l1-runtime log is ${target_file}
        ${file_hierarchy}    Set Variable    ${target_file} -> ${senond_file} -> ${third_file} -> ${target_file}
        __Check ERR WRN In Log    ${forth_path}/${target_file}    ${file_hierarchy}
        Remove Files    ${target_path}/${target_file}    ${second_path}/${senond_file}    ${third_path}/${third_file}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${target_path}/BTS_part*    ${target_path}/l1-runtime*    ${target_path}/var/log/*


_RF6 Made2 L1 Runtime Log Check
    [Arguments]    ${snapshot}
    Log To Console    ❄❄❄\n[ INFO ] RF6 made2 RU L1 Journal log
    ${target_log_list}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    journal.tar.gz
    FOR    ${targetlog}    IN    @{target_log_list}
        ${target_zip}    ${first_path}    Extract Target file From Compressed File    ${snapshot}    ${targetlog}
        ${senond_file}    ${second_path}    Extract Target file From Compressed File    ${first_path}/${target_zip}    journal.tar.gz
        ${third_file}    ${third_path}    Extract Target file From Compressed File    ${second_path}/${senond_file}    journal.txt
        File Should Exist    ${third_path}/${third_file}
        ${file_hierarchy}    Set Variable    ${target_zip} -> ${senond_file} -> ${third_file}
        __Check ERR WRN In Log    ${third_path}/${third_file}    ${file_hierarchy}
        Remove Files    ${first_path}/${target_zip}    ${second_path}/${senond_file}    ${third_path}/${third_file}
    END
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${first_path}/${target_zip}    ${second_path}/${senond_file}
    ...    ${third_path}/${third_file}

__Check ERR WRN In Log
    [Arguments]    ${file_path}    ${file_hierarchy}=${EMPTY}
    ${err_info}    Run   cat ${file_path} | grep /ERR
    ${wrn_info}    Run   cat ${file_path} | grep /WRN
    ${crash_info}    Run   grep -i -E 'handling signal [0-9]+' ${file_path}

    ${ignore_err_dict}    ${final_err_list}    syslog_checker.Get_ERR_and_WRN_info    ${err_info}    ${L1_ERR_whitelist}
    ${ignore_wrn_dict}    ${final_wrn_list}    syslog_checker.Get_ERR_and_WRN_info    ${wrn_info}    ${L1_WRN_whitelist}

    Run Keyword And Continue On Failure    Should Be Empty    ${final_err_list}
    ...    [ ERROR ] /ERR is visible in ${file_hierarchy}:\n${final_err_list}
    Run Keyword And Continue On Failure    Should Be Empty    ${final_wrn_list}
    ...    [ ERROR ] /WRN is visible in ${file_hierarchy}:\n${final_wrn_list}
    Run Keyword And Continue On Failure    Should Be Empty    ${crash_info}
    ...    [ ERROR ] Handling signal is visible in ${file_hierarchy}:\n${crash_info}

    ${ignoreERRisNotEmpty}    Run Keyword And Return Status    Should Not Be Empty    ${ignore_err_dict}
    Run Keyword If    ${ignoreERRisNotEmpty}    Log To Console
    ...    \n[ ERROR ] /ERR in white list is visible in ${file_hierarchy}:\n${ignore_err_dict}
    ${ignoreWRNisNotEmpty}    Run Keyword And Return Status    Should Not Be Empty    ${ignore_wrn_dict}
    Run Keyword If    ${ignoreWRNisNotEmpty}    Log To Console
    ...    \n[ ERROR ] /WRN in white list is visible in ${file_hierarchy}:\n${ignore_wrn_dict}


## ------------------To filter 'sendFcp240Message', 'Detected suspicious event' in DU L1 journal log--------------------#

Filter And Get Information in DU L1 Journal Log
    [Arguments]    ${snapshot}
    [Documentation]    To filter "Sending UlCellSetupResp", "sendFcp240Message", "Detected suspicious event", 'physCellId'.

    @{patterns_list}    Create List    Detected suspicious event    sendFcp240Message    physCellId
    ${target_log_list}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    D_l1p_syslog.tgz
    FOR    ${syslog}    IN    @{target_log_list}
        ${target_zip}    ${first_path}    Extract Target file From Compressed File    ${snapshot}    ${syslog}
        ${D_syslog_tgz}    ${second_path}    Extract Target file From Compressed File    ${first_path}/${target_zip}    D_l1p_syslog.tgz
        ${journal_txt}    ${third_path}    Extract Target file From Compressed File    ${second_path}/${D_syslog_tgz}    journal
        File Should Exist    ${third_path}/${journal_txt}
        ${file_hierarchy}    Set Variable    ${target_zip} -> ${D_syslog_tgz} -> ${journal_txt}
        ${isExistCells}    Run    cat ${third_path}/${journal_txt} | grep "Sending UlCellSetupResp:"
        ${isTarget}    Run Keyword And Return Status    Should Not Be Empty    ${isExistCells}
        Exit For Loop If    ${isTarget}
        Remove Files    ${first_path}/${target_zip}    ${second_path}/${D_syslog_tgz}    ${third_path}/${journal_txt}
    END
    File Should Exist    ${third_path}/${journal_txt}    [ ERROR ] No "Sending UlCellSetupResp" in ${third_path}/${journal_txt}
    ${output_dict}    __filter specific log    ${patterns_list}    ${third_path}/${journal_txt}

    [Return]    ${output_dict}
    [Teardown]    Remove Files    ${first_path}/${target_zip}    ${second_path}/${D_syslog_tgz}    ${third_path}/${journal_txt}

__filter specific log
    [Arguments]    ${patterns_list}    ${file}
    &{output_dict}    Create Dictionary
    FOR    ${pattern}    IN    @{patterns_list}
        ${log_line}    Run    cat ${file} | grep -E "${pattern}"
        Set To Dictionary    ${output_dict}    ${pattern}=${log_line.strip()}
    END
    [Return]    ${output_dict}

_Get sendFcp240Message Information From L1 Journal Log
    [Arguments]    ${sendFcp240Message_line}
    ${timestamp_pattern}    Set Variable    (\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2})
    ${match_timestamp}=    Evaluate    re.search(r"${timestamp_pattern}", """${sendFcp240Message_line.strip()}""")    re
    Should Not Be Empty    ${match_timestamp.group(0)}    [ ERROR ] Not Found [ ${timestamp_pattern} ] in [${sendFcp240Message_line}]
    ${init_timestamp}=    Set Variable    ${match_timestamp.group(1)}
    ${timestamp}    Set Variable    ${init_timestamp.replace(':', '-')}

    ${event_sfn_pattern}    Set Variable    sfn\.slot (\\d+)\.(\\d+), numOfSlots (\\d+), event (\\d+)
    ${match_event_sfn}=    Evaluate    re.search(r"${event_sfn_pattern}", """${sendFcp240Message_line.strip()}""")    re
    Should Not Be Empty    ${match_event_sfn.group(0)}    [ ERROR ] Not Found [ ${event_sfn_pattern} ] in [${sendFcp240Message_line}]
    ${sfn}=    Evaluate    ${match_event_sfn.group(1)}
    ${slot}=    Evaluate    ${match_event_sfn.group(2)}
    ${numOfSlots}=    Evaluate    ${match_event_sfn.group(3)}
    ${event}=    Evaluate    ${match_event_sfn.group(4)}
    Log    timestamp=${timestamp} | sfn=${sfn} | slot=${slot} | numOfSlots=${numOfSlots} | event=${event}
    &{fcp240_info_dict}    Create Dictionary    timestamp=${timestamp}    sfn=${sfn}    slot=${slot}    numOfSlots=${numOfSlots}    event=${event}
    [Return]    ${fcp240_info_dict}

_Get SuspiciousEvent From L1 Journal Log
    [Arguments]    ${detected_SuspiciousEvent_line}
    ${pattern}    Set Variable    SuspiciousEvent_([A-Za-z0-9_]+)
    ${match}=    Evaluate    re.search(r"${pattern}", """${detected_SuspiciousEvent_line.strip()}""")    re
    ${isMatched}    Run Keyword And Return Status    Should Not Be True    """${match}"""=='None'
    Return From Keyword If    ${isMatched}    ${match.group(1)}

_Get physCellId From L1 Journal Log
    [Arguments]    ${physCellId_line}
    ${pattern}    Set Variable    physCellId:([0-9_]+)
    ${match}=    Evaluate    re.findall(r"${pattern}", """${physCellId_line.strip()}""")    re
    ${isMatched}    Run Keyword And Return Status    Should Not Be True    """${match}"""=='None'
    ${min}    Evaluate    min(${match})
    ${max}    Evaluate    max(${match})
    Return From Keyword If    ${isMatched}    ${min}-${max}


Filter And Get enableCaptureIqData from runtime BTSOM
    [Arguments]    ${snapshot}    ${regex_pattern}=EnableCaptureIqData
    [Documentation]    To filter information from runtime BTSOM log, such as "EnableCaptureIqData" ...

    ${runtime_zip}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    1011_runtime.zip
    ${first_zip}    ${first_path}    Extract Target file From Compressed File    ${snapshot}    ${runtime_zip}[-1]
    ${second_xz}    ${second_path}    Extract Target file From Compressed File    ${first_path}/${first_zip}    1011_runtime.zip
    ${third_xz}    ${third_path}    Extract Target file From Compressed File    ${second_path}/${second_xz}    runtime_BTSOM.log.xz
    ${target}    ${target_path}    Extract Target file From Compressed File    ${third_path}/${third_xz}    runtime_BTSOM.log

    ${enableCaptureIqData_content}    Run    cat ${target_path}/${target} | grep '${regex_pattern}'

    [Return]    ${enableCaptureIqData_content}
    [Teardown]    Remove Files    ${first_path}/${first_zip}    ${second_path}/${second_xz}    ${third_path}/${third_xz}    ${target_path}/${target}

_Get capture mode and profile from enableCaptureIqData
    [Arguments]    ${enableCaptureIqData}
    ${profile_pattern}    Set Variable    profile=([A-Za-z0-9_]+)
    ${profile_match}=    Evaluate    re.search(r"${profile_pattern}", """${enableCaptureIqData.strip()}""")    re
    ${profile}=    Set Variable    ${profile_match.group(1)}
    Should Not Be Empty    ${profile}

    ${capture_mode_pattern}    Set Variable    capture mode=([A-Za-z]+)
    ${capture_mode_match}=    Evaluate    re.search(r"${capture_mode_pattern}", """${enableCaptureIqData.strip()}""")    re
    ${capture_mode}=    Set Variable    ${capture_mode_match.group(1)}
    Should Not Be Empty    ${profile}
    &{capture_id_dict}    Create Dictionary    profile=${profile}    capture mode=${capture_mode}
    [Return]    ${capture_id_dict}


_Get fetchArrayElements and antenna id for UL_PROFILE_3
    [Arguments]    ${enableCaptureIqData_content}

    ${ArrayElements_pattern}    Set Variable    fetchArrayElements:.*(rxArray[0-9]+)
    ${antenna_pattern}    Set Variable    antenna:\\s*([0-9]+)

    # initial the {result}
    ${result}    Create Dictionary
    ${current_array}    Set Variable    ${EMPTY}

    # split the content by line
    @{lines}    Split String    ${enableCaptureIqData_content}    \n

    FOR    ${line}    IN    @{lines}
        # check the new rxArray
        ${array_matches}    Get Regexp Matches    ${line}    ${ArrayElements_pattern}    1
        IF    ${array_matches}
            ${current_array}    Set Variable    ${array_matches}[0]
            # create a new list for rxArray
            ${empty_list}    Create List
            Set To Dictionary    ${result}    ${current_array}    ${empty_list}
            Continue For Loop
        END

        # get the antenna for rxArray
        IF    '${current_array}' != '${EMPTY}'
            ${antenna_matches}    Get Regexp Matches    ${line}    ${antenna_pattern}    1
            IF    ${antenna_matches}
                ${antenna_num}    Set Variable    ${antenna_matches}[0]
                ${antenna_list}    Get From Dictionary    ${result}    ${current_array}
                Append To List    ${antenna_list}    ${antenna_num}
            END

            # if contain "formatAntennaList()", reset the {current_array}
            ${is_format_line}    Run Keyword And Return Status    Should Contain    ${line}    formatAntennaList()
            IF    ${is_format_line}
                ${current_array}    Set Variable    ${EMPTY}
            END
        END
    END
    RETURN    ${result}


Generate L1-IQ log name
    [Documentation]     To return the ru iq file name, such as:
    ...    Examples:
    ...    UL_PROFILE_1
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_2_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_1_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_0_3342340_1017_4_1_FD.bin
    ...
    ...    UL_PROFILE_2
    ...      fcpTriggeredCapture_2025-08-22T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3145733_1017_4_1_FD_PUxCH.bin
    ...      or
    ...      fcpTriggeredCapture_2025-08-22T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3145733_1017_4_1_FD_SRS.bin
    ...
    ...    UL_PROFILE_3 (TD: for capture mode=TD, it will not be added in file name)
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray1_0_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray1_4_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray2_16_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray2_20_3407874_768_3_1.bin
    ...
    ...    UL_DL_PROFILE_1
    ...      TBD
    ...
    ...    DL_PROFILE_1
    ...      fcpTriggeredCapture_2025-10-30T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_txArray3_1_1_0_0_0_FD.bin

    [Arguments]    ${snapshot}    ${selected_SuspiciousEvent}=${None}
    ${output_dict}    Filter And Get information in DU L1 Journal Log    ${snapshot}
    ${fcp240_dict}    _Get sendFcp240Message information From L1 Journal Log    ${output_dict}[sendFcp240Message]
    ${detected_SuspiciousEvent}    _Get SuspiciousEvent From L1 Journal Log    ${output_dict}[Detected suspicious event]

    Should Not Be True    '${detected_SuspiciousEvent}'=='None' and '${selected_SuspiciousEvent}'=='None'
    ...    [ ERROR ] Detected SuspiciousEvent [${detected_SuspiciousEvent}] is None, {Selected_SuspiciousEvent} should be given.

    ${SuspiciousEvent}    Set Variable If    '${detected_SuspiciousEvent}'=='None'    ${selected_SuspiciousEvent}    ${detected_SuspiciousEvent}

    ${physCellId}    _Get physCellId From L1 Journal Log    ${output_dict}[physCellId]

    ${utc_date}    Set Variable    ${fcp240_dict}[timestamp]
    ${sfn}    Set Variable    ${fcp240_dict}[sfn]    # historyFrameId
    ${slot}    Set Variable    ${fcp240_dict}[slot]  # historySlotId
    ${numOfSlots}    Set Variable    ${fcp240_dict}[numOfSlots]

    ${enableCaptureIqData}    Filter And Get enableCaptureIqData from runtime BTSOM    ${snapshot}
    ${capture_id_dict}    _Get capture mode and profile from enableCaptureIqData    ${enableCaptureIqData}

    Set Test Variable    ${profile_prefix_from_runtime_BTSOM}    ${capture_id_dict}[profile]
    ${capture_mode}    Set Variable    ${capture_id_dict}[capture mode]

    ${tmp_str}    Set Variable    sendFcp240Message: ${utc_date} | sfn.slot=${sfn}.${slot} | numOfSlots=${numOfSlots} |
    Log To Console    \n[ INFO ] ${profile_prefix_from_runtime_BTSOM} | ${capture_mode} | ${SuspiciousEvent} | ${physCellId} | ${tmp_str}

    ${result}    __Get arrayInstance And sampleType    ${profile_prefix_from_runtime_BTSOM}    ${capture_mode}    ${SuspiciousEvent}
    ${sampleType}    Set Variable    ${result}[0]

    ${iq_name_list}    Create List

    IF    '${profile_prefix_from_runtime_BTSOM}'=='DL_PROFILE_1'
        ${iq_name_list}    Create List    fcpTriggeredCapture_${utc_date}Z_[${physCellId}]+_1_txArray[1-9]+_1_1_0_0_0_${sampleType}\.bin
        Return From Keyword    ${iq_name_list}
    END

    IF    '${profile_prefix_from_runtime_BTSOM}'=='UL_PROFILE_1'
        FOR    ${index}    IN RANGE    4
            ${tmp_str}    Set Variable    [${physCellId}]+_1_${result}[1]_${index}_${fcp240_dict}[event]
            Append To List    ${iq_name_list}    fcpTriggeredCapture_${utc_date}Z_${tmp_str}_${sfn}_${slot}_${numOfSlots}_FD\.bin
        END
        Return From Keyword    ${iq_name_list}
    END

    IF    '${profile_prefix_from_runtime_BTSOM}'=='UL_PROFILE_3'
        ${rxArray_antenna}    _Get fetchArrayElements and antenna id for UL_PROFILE_3    ${enableCaptureIqData}
        FOR    ${raArray}    ${antenna}    IN    &{rxArray_antenna}
            FOR    ${id}    IN    @{antenna}
                ${tmp_str}    Set Variable    [${physCellId}]+_1_${raArray}_${id}_${fcp240_dict}[event]
                Append To List    ${iq_name_list}    fcpTriggeredCapture_${utc_date}Z_${tmp_str}_${sfn}_${slot}_${numOfSlots}\.bin
            END
        END
        Return From Keyword    ${iq_name_list}
    END

    ## for UL_PROFILE_2 and UL_DL_PROFILE_1
    ${tmp_str}    Set Variable    [${physCellId}]+_1_${result}[1]_${fcp240_dict}[event]
    Append To List    ${iq_name_list}
    ...    fcpTriggeredCapture_${utc_date}Z_${tmp_str}_${sfn}_${slot}_${numOfSlots}_${sampleType}\.bin
    Return From Keyword    ${iq_name_list}


__Get arrayInstance And sampleType
    [Arguments]    ${profile}    ${capture_mode}    ${eventName}
    ${profile}    Set Variable    ${profile.upper()}
    Should Be True    '${profile}' in ('UL_PROFILE_1', 'UL_PROFILE_2', 'UL_PROFILE_3', 'DL_PROFILE_1', 'UL_DL_PROFILE_1')
    ${tmp_array}    Set Variable If    'Srs' in '${eventName}'    FD_SRS    FD_PUxCH
    ${arrayInstance}    Set Variable If    '${profile}' in ('UL_PROFILE_2',)    ${tmp_array}    ${capture_mode}
    ${sampleType}    Set Variable    rxArray3
    [Return]    ${arrayInstance}    ${sampleType}


Extract trbl log and check ru iq log
    [Arguments]    ${snapshot}    ${selected_SuspiciousEvent}=${None}    ${MAX_SIZE_BYTES}=6100000    ${MIN_SIZE_BYTES}=10240
    ...    ${fcpTriggeredCapture_thor}=fcpTriggeredCapture
    [Documentation]     To extract trbl log and check ru iq log, such as:
    ...    | Arguments | Mandatory | Default | Description |
    ...    | snapshot | Y | NA | realpath of snapshot |
    ...    | selected_SuspiciousEvent | N | None | The iq log related SuspiciousEvent type, if None, it will be got in L1 journal log |
    ...    | MAX_SIZE_BYTES | N | 6100000(bytes) | The max bytes size of iq log |
    ...    | MIN_SIZE_BYTES | N | 10240(bytes) | The min bytes size of iq log |
    ...    | fcpTriggeredCapture_thor | N | fcpTriggeredCapture_thor.tar.gz | The archive name of RU iq log |
    ...    Examples:
    ...    UL_PROFILE_1
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_2_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_1_3342340_1017_4_1_FD.bin
    ...      fcpTriggeredCapture_2025-08-12T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_0_3342340_1017_4_1_FD.bin
    ...
    ...    UL_PROFILE_2
    ...      fcpTriggeredCapture_2025-08-22T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3145733_1017_4_1_FD_PUxCH.bin
    ...      or
    ...      fcpTriggeredCapture_2025-08-22T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray3_3145733_1017_4_1_FD_SRS.bin
    ...
    ...    UL_PROFILE_3 (TD: for capture mode=TD, it will not be added in file name)
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray1_0_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray1_4_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray2_16_3407874_768_3_1.bin
    ...      fcpTriggeredCapture_2025-10-20T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_rxArray2_20_3407874_768_3_1.bin
    ...
    ...    UL_DL_PROFILE_1
    ...      TBD
    ...
    ...    DL_PROFILE_1
    ...      fcpTriggeredCapture_2025-10-30T[0-9]{2}-[0-9]{2}-[0-9]{2}Z_300_1_txArray3_1_1_0_0_0_FD.bin

    ${ru_iq_files_name_list}    Generate L1-IQ log name    ${snapshot}    ${selected_SuspiciousEvent}

    ${found_zip_list}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${fcpTriggeredCapture_thor}

    ${found_zip_list}    Run Keyword If    '${profile_prefix_from_runtime_BTSOM}'=='UL_PROFILE_3'
    ...    Evaluate    [item for item in $found_zip_list if 'fcpTriggeredCapture_thor.tar.gz' not in item]
    ...    ELSE    Set Variable    ${found_zip_list}

    ## if file endswith 'aa | ab | ac | ... | ax', files should be merged then extract, {found_zip_list} and ${iq_snapshot} will be replaced
    ${isMerge}    __get the archive compress format    ${found_zip_list[0].split('.')}[-1]
    IF    '${isMerge}'=='merge'
        ${merged_file}    ${path}    Extract And Merge Files To fcpTriggeredCapture_thor.tar.gz    ${snapshot}    ${found_zip_list}
        @{found_zip_list}    Create List    ${fcpTriggeredCapture_thor}
    END
    ${iq_snapshot}    Set Variable If    '${isMerge}'=='merge'    ${path}/${merged_file}    ${snapshot}

    FOR    ${found_zip}    IN    @{found_zip_list}
        ${first_zip}    ${path1}    Extract Target file From Compressed File     ${iq_snapshot}    ${found_zip}    ${EMPTY}    all
        ${contains_fcptriggeredCapture_1st_zip}    Evaluate    any('${fcpTriggeredCapture_thor}' in item for item in ${first_zip})
        ${second_zip}    Set Variable    ${None}
        ${path2}    Set Variable    ${None}

        FOR    ${zip_file_1}    IN    @{first_zip}
            ${second_zip}     ${path2}    Run Keyword If    not ${contains_fcptriggeredCapture_1st_zip}
            ...    Extract Target file From Compressed File     ${path1}/${zip_file_1}    ${fcpTriggeredCapture_thor}    ${EMPTY}    all
            Run Keyword If    not ${contains_fcptriggeredCapture_1st_zip}    Remove File    ${path1}/${zip_file_1}
        END

        ${TGZ_FILE_LIST}    Set Variable If    ${contains_fcptriggeredCapture_1st_zip}    ${first_zip}    ${second_zip}

        FOR    ${zip_file}    IN    @{TGZ_FILE_LIST}
            Exit For Loop If    '${isMerge}'=='merge'    ## if zip file is from "Extract And Merge Files...", uncompress step will be exited
            Log To Console    \n[INFO]captured file path is ${zip_file}
            ${compress_format}    __get the archive compress format    ${zip_file.split('.',1)[-1]}
            ${file}    Set Variable    ${path}/${zip_file}
            ${uncompress_cmd}    Run Keyword If    '${compress_format}'=='zip'    Set Variable    cd ${path}; unzip -o ${path} "${file}"
                ...    ELSE IF    '${compress_format}' in ('txz','tgz','tar')    Set Variable    cd ${path}; tar -xvf ${file}
                ...    ELSE IF    '${compress_format}' in ('xz')    Set Variable    xz -d ${file}
                ...    ELSE IF    '${compress_format}' in ('gz')    Set Variable    gunzip -v ${file}
                ...    ELSE IF    '${compress_format}'=='tar.gz'    Set Variable    cd ${path}; tar -zxvf ${file}
                ...    ELSE    Fail    '[ERROR] NOT supported compress format.'
            ${uncompress}    Run    ${uncompress_cmd}
        END
    END

        FOR    ${file_name}    IN    @{ru_iq_files_name_list}
            ${output}    Run    ls -l ${path} | grep -E ${file_name}
            ${isIqExisted}    Run Keyword And Return Status    Should Not Be Empty    ${output}

            ${fcp_ls}    Run Keyword If    not ${isIqExisted}    Run    ls ${path} | grep -E fcpTriggeredCapture
            ${file_name}    ${file_size}    Run Keyword If    not ${isIqExisted}
            ...    Fail    "[ ERROR ] ${path}:\n${file_name} not found, Did you mean:\n${SPACE * 4}${fcp_ls}"
            ...    ELSE    Get File Name And Size From ls-l    ${output}

            Remove File    ${path}/${file_name}

            Log    [INFO] File :: Size | [ ${file_name} ] :: [ ${file_size} ]
            Should Be True    ${MAX_SIZE_BYTES} > ${file_size} > ${MIN_SIZE_BYTES}
            ...    [ ERROR ][ ${file_name} ] size [ ${file_size} ] NOT in [ ${MIN_SIZE_BYTES} : ${MAX_SIZE_BYTES} ] bytes.
        END

    [Teardown]    Remove Files    ${path1}/*fcpTriggeredCapture*

Extract And Merge Files To fcpTriggeredCapture_thor.tar.gz
    [Arguments]    ${snapshot}    ${split_files}
    ${path}    Set Variable    None

    FOR    ${sub_file}    IN    @{split_files}
        IF    'BTS_part' in '${sub_file}'
            ${second_zip}    ${path}    Extract Target file From Compressed File     compress_file=${snapshot}    target_startswith=${sub_file}
            ${third_zip}    ${path}    Extract Target file From Compressed File     compress_file=${path}/${second_zip}
            ...    target_startswith=fcpTriggeredCapture

        ELSE
            ${second_zip}    ${path}    Extract Target file From Compressed File     ${snapshot}    ${sub_file}
            ${file_name}    Set Variable    ${sub_file.rsplit('.',-1)}[0]
        END
    END
    ${merged_file}=    Set Variable    ${path}/fcpTriggeredCapture_thor.tar
    Run    cd ${path}; cat ${file_name}* > ${merged_file}

    File Should Exist    ${merged_file}    [ ERROR ] Not Found::${merged_file}
    FOR    ${sub_file}    IN    @{split_files}
        Remove File    ${path}/${sub_file}
    END
    [Return]    fcpTriggeredCapture_thor.tar    ${path}


Extract trbl log and check du iq log
    [Arguments]    ${snapshot}    ${TARGET_FILE_NAMES}
    ${node_id}    Get Node Id    ABIP    thor_1
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    Log To Console    \ncaptured file path is ${path2}/${third_zip}
    ${result}=    is_target_files_exist_in_captured_package    ${path2}/${third_zip}    ${TARGET_FILE_NAMES}
    Run Keyword If    not ${result}    Fail    Some target files were not found in the package.
    [Teardown]    Run Keyword And Ignore Error    Remove files    ${path2}/${third_zip}    ${path1}/${second_zip}


Check RU FD IQ logs
    [Arguments]    ${file_min_size}=10240    ${file_max_size}=6100000    ${iq_local_path}=${TEST_LOG_DIR}/bin    ${max_number_of_bin}=4
    Directory Should Exist     ${iq_local_path}    [ ERROR ]Not Found: ${iq_local_path}
    #LMI Transfer Files    remote=/ram/l1radio/*.bin    local=${iq_local_path}    operation=download
    #...    ip=192.168.101.17    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    ${result}    Run    cd ${iq_local_path};ls *iq_capture* -l | awk '{print $9 " " $5}'
    ${bin_list}    Set Variable    ${result.split('\n')}
    Log To Console    ${bin_list}
    ${number_of_bin}    Get Length    ${bin_list}
    Should Be True    ${number_of_bin} >= ${max_number_of_bin}    [ ERROR ] The number of bin file is NOT ${max_number_of_bin} : ${bin_list}
    ${size_list}    Create List
    FOR    ${file}    IN    @{bin_list}
        ${name}    Set Variable    ${file.split()}[0]
        ${size}    Set Variable    ${file.split()}[1]
        Append To List    ${size_list}    ${size}
    END
    ${size_set}    Remove Duplicates    ${size_list}
    ${number_of_set}    Get Length    ${size_set}
    Should Be True    ${number_of_set} == 1    [ ERROR ] The bin files are NOT the same size : ${bin_list} : ${size_list}
    Should Be True    ${file_min_size} <= ${size_set}[0] <= ${file_max_size}
    ...    [ ERROR ] the bin size [${size_set}[0]] should be in [ ${file_min_size} : ${file_max_size}]


Get File Name And Size From ls-l
    [Arguments]    ${ls}
    @{str_list}=    Split String    ${ls}
    ${size}    ${name}    Set Variable    ${str_list}[-5]    ${str_list}[-1]
    [Return]    ${name}    ${size}
