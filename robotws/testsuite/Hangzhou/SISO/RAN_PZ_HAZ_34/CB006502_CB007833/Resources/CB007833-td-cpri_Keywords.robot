*** Settings ***
Documentation    This is for CB007833-5G-A-td-Cpri-Amber keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    CB006502_Keywords.robot
Library    ../TestData/variables_CB007833.py
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***

*** Keywords ***

CB007833-5G-A_01_RU_online_access_to_Black_Box_contents
    [Arguments]    ${ru_index}=${1}    ${blackbox5}=BBOX5
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd /mnt/runtime/;ls    connection=RU_${ru_index}
    Sleep    2s
    ${result}    csn.read output    connection=RU_${ru_index}
    Should contain     ${result}    ${blackbox5}
    Log to console    \n******RU online access to BlackBox BBOX5 Passed******
    csn.Disconnect    connection=RU_${ru_index}

CB007833-5G-A_02_RU_Definition_of_Black_Box_Contents_Format
    Save Full Level Snapshot and Check BBOX5 Content

CB007833-5G-A_05_RU_Time-of-day_for_BlackBox_entries
    [Arguments]    ${ru_index}=1    ${blackbox5}=BBOX5    ${download_dir}=${TS_CASE_LOG_PATH}    ${remote_path}=/mnt/runtime/BBOX5
    Connect to Common Unit Master
    Log to console    \n********* check RU online access to BlackBox BBOX5 *********
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd /mnt/runtime/;ls    connection=RU_${ru_index}
    Sleep    2s
    ${result}    csn.read output    connection=RU_${ru_index}
    Should contain     ${result}    ${blackbox5}
    csn.Download file    remote_path=${remote_path}    local_path=${download_dir}/BBOX5    connection=RU_${ru_index}
    ${updatable_items_total}    Check BBOX5 items if exist
    Log to console    \n************ get BBOX5 file content *************
    ${bbox5_content}    Run    command=cat ${download_dir}/BBOX5
    ${pattern}    Set Variable    Last write: ([^T]*)T
    ${last_write_time}    Get Regexp Matches    ${bbox5_content}    ${pattern}    1
    ${updatable_items_times}    get_array_appeared_times_in_file    args=${last_write_time}
    log    ${updatable_items_times}
    log    ${updatable_items_total}
    ${today}    DateTime.Get Current Date    result_format=%Y-%m-%d
    ${yesterday}    DateTime.Subtract Time From Date    ${today}    1 day    result_format=%Y-%m-%d
    Should Contain Any    ${last_write_time}[0]    ${today}    ${yesterday}
    csn.Disconnect    connection=RU_${ru_index}

CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log
    Log to console    \n********* check snapshot Full level's BBOX5 file ************
    Save Full Level Snapshot and Check BBOX5 Content
    Log to console    \n********* check snapshot Minor level's BBOX5 file ***********
    Save Minor Level Snapshot and Check BBOX5 Content

CB007833-5G-A_7_RU_Minimum_information_in_Black_Box
    [Arguments]    ${ISTI}=Item type: Isti    ${resets}=Item type: resets    ${memory}=Item type: memory_load
    ...    ${cpu}=Item type: cpu_load    ${temp}=Item type: Temperature    ${SW}=Item type: SW_version    ${Vol}=Item type: Voltage
    ...    ${Optical_signal}=Item type: Optical_lvl_signal    ${version}=BlackBox ver: 5.0
    ${BBOX5_file}    Get BBOX5 on Minor Level Snapshot
    Log to console    \n********* check BBOX5 items info *********
    Check BBOX5 items if exist    filepath=${BBOX5_file}
    get_values_for_temp_voltage    item=${temp}    filepath=${BBOX5_file}
    get_values_for_temp_voltage    item=${Vol}    filepath=${BBOX5_file}
    get_values_for_cpu_memory    item=${cpu}    filepath=${BBOX5_file}
    get_values_for_cpu_memory    item=${memory}    filepath=${BBOX5_file}
    get_values_for_signal    item=${Optical_signal}    filepath=${BBOX5_file}
    ${events}    check RF internal faults
    ${List of events}    get_events    item=${version}    filepath=${BBOX5_file}
    Sort List    ${List of events}
    Sort List    ${events}
    ${result}    list_comparison    list1=${List of events}    list2=${events}
    should not be empty    ${result}
    get_resets_info    item=${resets}    filepath=${BBOX5_file}
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${pattern}    Set Variable    Last write: ([^T]*)T
    ${last_write_time}    Get Regexp Matches    ${bbox5_content}    ${pattern}    1
    ${today}    DateTime.Get Current Date    result_format=%Y-%m-%d
    ${yesterday}    DateTime.Subtract Time From Date    ${today}    1 day    result_format=%Y-%m-%d
    Should Contain Any    ${last_write_time}[0]    ${today}    ${yesterday}

CB007833-5G-A_8_RU_parameter_CPU_load_in_BBOX5
    [Arguments]    ${CPU_load}=Item type: cpu_load
    ${BBOX5_file}    Get BBOX5 on Full Level Snapshot
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${cpu_load_list}    Get Regexp Matches     ${bbox5_content}    cpu_load
    ${cpu_load_num}    get length    ${cpu_load_list}
    Should be true    ${cpu_load_num}==${5}
    get_values_for_cpu_memory    item=${CPU_load}    filepath=${BBOX5_file}

CB007833-5G-A_9_RU_parameter_memory_load_in_BBOX5
    [Arguments]    ${memory_load}=Item type: memory_load
    ${BBOX5_file}    Get BBOX5 on Full Level Snapshot
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${memory_load_list}    Get Regexp Matches     ${bbox5_content}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${5}
    get_values_for_cpu_memory    item=${memory_load}    filepath=${BBOX5_file}

CB007833-5G-A_10_RU_installation_time_optical_signal_level_in_BBOX5
    [Arguments]    ${Optical_signal}=Item type: Optical_lvl_signal
    ${BBOX5_file}    Get BBOX5 on Full Level Snapshot
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${optical_signal_list}    Get Regexp Matches     ${bbox5_content}    Optical_lvl_signal
    ${optical_signal_num}    get length  ${optical_signal_list}
    Should be true    ${optical_signal_num}
    get_values_for_signal    item=${Optical_signal}    filepath=${BBOX5_file}

CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log_All_RU_Operation
    log to console    \n++++ 01_RU_online_access_to_Black_Box_contents and 05_RU_Time-of-day_for_BlackBox_entries ++++
    CB007833-5G-A_05_RU_Time-of-day_for_BlackBox_entries
    log to console    \n++++ 06_RU_Black_Box_contents_in_BTS_Technical_Log_All_RU_Operation
    ...    and include 02_RU_Definition_of_Black_Box_Contents_Format ++++
    Log to console    \n********* check snapshot Full level's BBOX5 file  ****
    Save Full Level Snapshot and Check BBOX5 Content
    Log to console    \n********* check snapshot Minor level's BBOX5 file ***********
    Save Minor Level Snapshot and Check BBOX5 Content

CB007833-5G-A_7_RU_Minimum_information_in_Black_Box_snapshot_operation
    [Arguments]    ${ISTI}=Item type: Isti    ${resets}=Item type: resets    ${memory}=Item type: memory_load
    ...    ${cpu}=Item type: cpu_load    ${temp}=Item type: Temperature    ${SW}=Item type: SW_version    ${Vol}=Item type: Voltage
    ...    ${Optical_signal}=Item type: Optical_lvl_signal    ${version}=BlackBox ver: 5.0
    ${release}    Get BTS Release
    08_09_10_full_level_snapshot
    ${BBOX5_file}    Get BBOX5 on Minor Level Snapshot
    Log to console    \n********* check BBOX5 items info *********
    Check BBOX5 items if exist    filepath=${BBOX5_file}
    get_values_for_temp_voltage    item=${temp}    filepath=${BBOX5_file}
    get_values_for_temp_voltage    item=${Vol}    filepath=${BBOX5_file}
    get_values_for_cpu_memory    item=${cpu}    filepath=${BBOX5_file}
    get_values_for_cpu_memory    item=${memory}    filepath=${BBOX5_file}
    get_values_for_signal    item=${Optical_signal}    filepath=${BBOX5_file}
    ${events}    check RF internal faults
    ${List of events_1}    get_events    item=${version}    filepath=${BBOX5_file}
    ${List of events_2}    get_events_bbox5    filepath=${BBOX5_file}
    Sort List    ${List of events_1}
    Sort List    ${List of events_2}
    Sort List    ${events}
    ${result_1}    list_comparison    list1=${List of events_1}    list2=${events}
    ${result_2}    list_comparison    list1=${List of events_2}    list2=${events}
    ${result_1_status}    run keyword and return status
    ...    should not be empty    ${result_1}
    ${result_2_status}    run keyword and return status
    ...    should not be empty    ${result_2}
#    run keyword if    ${result_1_status}==${True} or ${result_2_status}==${True}
#    ...    Pass Execution
    get_resets_info    item=${resets}    filepath=${BBOX5_file}
    ${bbox5_content}    Run    command=cat ${BBOX5_file}
    ${pattern}    Set Variable    Last write: ([^T]*)T
    ${last_write_time}    Get Regexp Matches    ${bbox5_content}    ${pattern}    1
    ${today}    DateTime.Get Current Date    result_format=%Y-%m-%d
    ${yesterday}    DateTime.Subtract Time From Date    ${today}    1 day    result_format=%Y-%m-%d
    Should Contain Any    ${last_write_time}[0]    ${today}    ${yesterday}
    run keyword if    ${result_1_status}==${True} or ${result_2_status}==${True}
    ...    Pass Execution    test case passed

08_09_10_full_level_snapshot
    [Arguments]    ${CPU_load}=Item type: cpu_load    ${memory_load}=Item type: memory_load    ${Optical_signal}=Item type: Optical_lvl_signal
    ${BBOX5_file_full}    Get BBOX5 on Full Level Snapshot
    ${bbox5_content}    Run    command=cat ${BBOX5_file_full}
    log to console    \n++++ 8_RU_parameter_CPU_load_in_BBOX5 ++++
    ${cpu_load_list}    Get Regexp Matches     ${bbox5_content}    cpu_load
    ${cpu_load_num}    get length    ${cpu_load_list}
    Should be true    ${cpu_load_num}==${5}
    get_values_for_cpu_memory    item=${CPU_load}    filepath=${BBOX5_file_full}
    log to console    \n++++ 9_RU_parameter_memory_load_in_BBOX5 ++++
    ${memory_load_list}    Get Regexp Matches     ${bbox5_content}    memory_load
    ${memory_load_num}    get length  ${memory_load_list}
    Should be true    ${memory_load_num}==${5}
    get_values_for_cpu_memory    item=${memory_load}    filepath=${BBOX5_file_full}
    log to console    \n++++ 10_RU_installation_time_optical_signal_level_in_BBOX5 ++++
    ${optical_signal_list}    Get Regexp Matches     ${bbox5_content}    Optical_lvl_signal
    ${optical_signal_num}    get length  ${optical_signal_list}
    Should be true    ${optical_signal_num}
    get_values_for_signal    item=${Optical_signal}    filepath=${BBOX5_file_full}

Save Minor Level Snapshot and Check BBOX5 Content
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_minor}    Save Minor Level Snapshot
    Log to console    \n************ check BBOX5 if exist in Minor level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    ${pattern}    Set Variable    BTS_part(\\d).zip:[^:]*BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    extract zip file    ${snapshot_unzip_file_path_minor}/${bts_part}.zip    ${snapshot_unzip_file_path_minor}/${bts_part}
    Log to console    \n************ get BBOX5 file content *************
    Run    command=cd ${snapshot_unzip_file_path_minor}/${bts_part}; unxz BTS_${serial_number}_RMOD_L_1_BBOX5.xz
    ${bbox5_content}    Run    command=cat ${snapshot_unzip_file_path_minor}/${bts_part}/BTS_${serial_number}_RMOD_L_1_BBOX5

Save Full Level Snapshot and Check BBOX5 Content
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_full}    Save Full Level Snapshot
    Log to console    \n************ check BBOX5 if exist in full level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    ${pattern}    Set Variable    BTS_part(\\d).zip:[^:]*BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    extract zip file    ${snapshot_unzip_file_path_full}/${bts_part}.zip    ${snapshot_unzip_file_path_full}/${bts_part}
    Log to console    \n************ get BBOX5 file content *************
    Run    command=cd ${snapshot_unzip_file_path_full}/${bts_part}; unxz BTS_${serial_number}_RMOD_L_1_BBOX5.xz
    ${bbox5_content}    Run    command=cat ${snapshot_unzip_file_path_full}/${bts_part}/BTS_${serial_number}_RMOD_L_1_BBOX5
    [Return]    ${bbox5_content}

Get BBOX5 on Minor Level Snapshot
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_minor}    Save Minor Level Snapshot
    Log to console    \n************ check BBOX5 if exist in Minor level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_minor}/snapshot_file_list.txt
    ${pattern}    Set Variable    BTS_part(\\d).zip:[^:]*BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    ${BBOX5_zip_filepath}    Join path    ${snapshot_unzip_file_path_minor}    ${bts_part}
    extract zip file    ${snapshot_unzip_file_path_minor}/${bts_part}.zip    ${BBOX5_zip_filepath}
    Run    command=cd ${BBOX5_zip_filepath}; unxz BTS_${serial_number}_RMOD_L_1_BBOX5.xz
    ${BBOX5_original_file}    Join path    ${BBOX5_zip_filepath}    BTS_${serial_number}_RMOD_L_1_BBOX5
    ${BBOX5_file}    file_replace    filepath=${BBOX5_original_file}
    [Return]    ${BBOX5_file}

Get BBOX5 on Full Level Snapshot
    [Arguments]    ${str}=BBOX5    ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${snapshot_unzip_file_path_full}    Save Full Level Snapshot
    Log to console    \n************ check BBOX5 if exist in full level snapshot **************
    ${BBOX5_appear_times}    get_str_appeared_times_in_file     str=${str}
    ...    filepath=${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    should not be equal    ${BBOX5_appear_times}    '0'
    ${output}    OperatingSystem.get file    ${snapshot_unzip_file_path_full}/snapshot_file_list.txt
    ${pattern}    Set Variable    BTS_part(\\d).zip:[^:]*BBOX5
    ${bts_part_list}    Get Regexp Matches    ${output}    ${pattern}    1
    ${bts_part}    Set Variable    BTS_part${bts_part_list}[0]
    ${BBOX5_zip_filepath}    Join path    ${snapshot_unzip_file_path_full}    ${bts_part}
    extract zip file    ${snapshot_unzip_file_path_full}/${bts_part}.zip    ${BBOX5_zip_filepath}
    Run    command=cd ${BBOX5_zip_filepath}; unxz BTS_${serial_number}_RMOD_L_1_BBOX5.xz
    ${BBOX5_original_file}    Join path    ${BBOX5_zip_filepath}    BTS_${serial_number}_RMOD_L_1_BBOX5
    ${BBOX5_file}    file_replace    filepath=${BBOX5_original_file}
    [Return]    ${BBOX5_file}

Check BBOX5 items if exist
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${ISTI}=Isti    ${resets}=resets    ${memory}=memory_load
    ...    ${cpu}=cpu_load    ${temp}=Temperature    ${SW}=SW_version    ${Vol}=Voltage    ${Optical_signal}=Optical_lvl_signal
    ...    ${filepath}=${download_dir}/BBOX5
    Log to console    \n*********** check Amber BBOX5 items **************
    ${Isti_times}    get_str_appeared_times_in_file     str=${ISTI}    filepath=${filepath}
    should be equal    ${Isti_times}    ${1}
    ${resets_times}    get_str_appeared_times_in_file     str=${resets}    filepath=${filepath}
    should be equal    ${resets_times}    ${1}
    ${memory_times}    get_str_appeared_times_in_file     str=${memory}    filepath=${filepath}
    should be equal    ${memory_times}    ${5}
    ${cpu_times}    get_str_appeared_times_in_file     str=${cpu}    filepath=${filepath}
    should be equal    ${cpu_times}    ${5}
    ${temp_times}    get_str_appeared_times_in_file     str=${temp}    filepath=${filepath}
    should be equal    ${temp_times}    ${76}
    ${SW_times}    get_str_appeared_times_in_file     str=${SW}    filepath=${filepath}
    should be equal    ${SW_times}    ${1}
    ${Voltage_times}    get_str_appeared_times_in_file     str=${Vol}    filepath=${filepath}
    should be equal    ${Voltage_times}    ${1}
    ${signal_times}    get_str_appeared_times_in_file     str=${Optical_signal}    filepath=${filepath}
    should be equal    ${signal_times}    ${4}
    ${updatable_items_total}    Evaluate    ${Isti_times}+${memory_times}+${cpu_times}+${temp_times}+${Voltage_times}+${signal_times}
    [Return]    ${updatable_items_total}

check RF internal faults
    [Arguments]    ${ru_index}=${1}    ${blackbox5}=BBOX5
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd /run/;cat fault_history_log.txt|tail -n +24|cut -d ' ' -f 3    connection=RU_${ru_index}
    Sleep    2s
    ${result_RF_internal_faults}    csn.read output    connection=RU_${ru_index}
    ${RF_internal_faults}    Create List    ${result_RF_internal_faults}
    ${str_faults}    Convert to string    ${RF_internal_faults}
    ${events}    duplicate_removal_list    str=${str_faults}
    csn.Disconnect    connection=RU_${ru_index}
    [Return]    ${events}

Save Full Level Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
    ${snapshot_unzip_file_path_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_full}    ${snapshot_unzip_file_path_full}
    [Return]    ${snapshot_unzip_file_path_full}

Save Minor Level Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_minor}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_minor}    coverage=Minor    timeout=1500    connection=${connection}
    ${snapshot_unzip_file_path_minor}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_minor}    ${snapshot_unzip_file_path_minor}
    [Return]    ${snapshot_unzip_file_path_minor}
