*** Settings ***
Documentation
...   This is for 2236 TA common keywords
...   squad group: MMW_SG1

Resource    ./5GC002236_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000920/Resources/5GC000920_Keywords.robot




*** Variables ***
&{fault_10}       faultId=${10}    source=RMOD_R-1    # No connection to unit
&{fault_4527}    faultId=${4527}    source=RMOD_R-1    # Radio diagnostic files collected



*** Keywords ***
Collect snapshot and check ru specific log
    [Documentation]   Auther: journey.jin@nokia-sbell.com
    [Arguments]   ${ru_index}=${1}    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM    ${timeout}=600
    ...    ${key_string}=IPCCrash
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    Run   rm -rf ${snapshot_path}/
    Check specific log in snapshot file    specific_xz_file=pm_1_DEFAULT.log.xz    connection=${connection}
    ...    key_string=${key_string}    specific_zip_file=BTS_${serial_number}_RMOD_L_1_pm_1_syslog.zip

Verify ASOD is disconnected
    [Documentation]  Author: Jin Journey
    ${status} =    Run Keyword And Return Status    Ping to destination from local should be success
    ...    destation=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Should Be Equal    ${status}    ${False}


Get time from site
    [Documentation]    Author: Jin Journey
    ...                Description: Get the real time from site,return as '15-08-2020:05:20' or '2020-08-15T05:20'
    [Arguments]    ${alias}=ASOD-loner    ${site_type}=du
    Run keyword if    '${site_type}'=='du'    csn.send command    command=date +"%d-%m-%Y:%H:%M"    connection=${alias}
    ...    ELSE IF    '${site_type}'=='cu'    csn.send command    command=date +"%Y-%m-%dT%H:%M"    connection=${alias}
    ${date_time}    csn.read output    connection=${alias}
    ${date_time}    Strip String   ${date_time}
    [Return]    ${date_time}


Check specific log in cu snapshot file
    [Documentation]   Author: Jin Journey
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}
    ...    ${specific_zip_file}=rcplog*.zip    ${key_string}=SIGSEGV    ${kill_process_time}=${time}
    Run   rm -rf ${snapshot_path}/
    Generate test case log path
    ${snapshot_zip_file}    CU Collect Snapshot    log_path=${snapshot_path}
    ${snapshot_unzip_dir}    Fetch from left    ${snapshot_zip_file}    .zip
    Extract zip file    ${snapshot_zip_file}    ${snapshot_unzip_dir}
    Run    unzip ${snapshot_unzip_dir}/${specific_zip_file} -d ${snapshot_unzip_dir}
    ${key_string}    Catenate    COMMAND=/usr/bin/kill -s ${key_string}
    @{dir_name}    OperatingSystem.List Directories In Directory    ${snapshot_unzip_dir}/symptomreport    *-oam-000
    ${output}   OperatingSystem.grep file
    ...    ${snapshot_unzip_dir}/symptomreport/${dir_name}[0]/syslog_info/syslog_info
    ...    ${key_string}    encoding_errors=replace
    Should not be empty    ${output}
    Should contain    ${output}    ${kill_process_time}
    [Return]    ${kill_process_time}


Collect du snapshot and extract specific file
    [Documentation]   Author: Jin Journey
    [Arguments]    ${snapshot_log_folder}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ...    ${specific_file}=BTS${tl.gnbs[0].instance_id}_105D_crash.tgz    ${case_type}=rau
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=600   connection=${connection}
    ${snapshot_unzip_folder}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}
    Extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_folder}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/snapshot_file_list.txt
    ${output}    Run keyword if    '${case_type}'=='rau'    OperatingSystem.get file    ${snapshot_unzip_folder}/snapshot_file_list.txt
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox.xz
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox_adet_data.xz
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox_alarms.xz
    Run    grep -e 'zip:' -e '${specific_file}' ${snapshot_unzip_folder}/snapshot_file_list.txt > ${snapshot_unzip_folder}/tmp_test1.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test1.txt
    Run    grep -B1 '${specific_file}' ${snapshot_unzip_folder}/tmp_test1.txt > ${snapshot_unzip_folder}/tmp_test2.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test2.txt
    ${rc}    ${specific_file_in}    Run and return rc and output
    ...    grep -v '${specific_file}' ${snapshot_unzip_folder}/tmp_test2.txt
    ${specific_file_in}    Fetch from left    ${specific_file_in}    :
    ${specific_dir}    Fetch from left    ${specific_file_in}    .zip
    Extract zip file    ${snapshot_unzip_folder}/${specific_file_in}    ${snapshot_unzip_folder}/${specific_dir}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    ${specific_file_name}    Run keyword if    '${case_type}'=='l1crash'    Fetch from left    ${specific_file}    .tgz
    ...    ELSE IF    '${case_type}'=='rau'    Fetch from left    ${specific_file}    .tar
    Run    mkdir ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}
    ${specific_compress_file_path}    Set variable    ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}
    ${specific_compress_file}    Set variable    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    Run keyword if    '${case_type}'=='l1crash'
    ...    Run     tar -zxvf ${specific_compress_file} -C ${specific_compress_file_path}
    Run keyword if    '${case_type}'=='rau'
    ...    Run     tar -xvf ${specific_compress_file} -C ${specific_compress_file_path}
    [Return]    ${specific_compress_file_path}


Check specific log in du snapshot
    [Documentation]     Author: Jin Journey
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM
    ...    ${specific_file}=BTS${tl.gnbs[0].instance_id}_105D_crash.tgz    ${key_string}=killed    ${case_type}=rau
    Run   rm -rf ${snapshot_path}/
    ${extract_path}=    Collect du snapshot and extract specific file    snapshot_log_folder=${TS_CASE_LOG_PATH}
    ...    connection=GNB_OAM    specific_file=${specific_file}    case_type=${case_type}
    @{file_list}    Run keyword if    '${case_type}'=='l1crash'
    ...    OperatingSystem.List Files In Directory    ${extract_path}/service_failures    *autodetection*
    ${file_list_length}    Run keyword if    '${case_type}'=='l1crash'    Get length    ${file_list}
    ${file_list_index}    Run keyword if    '${case_type}'=='l1crash'    Evaluate    ${file_list_length}-1
    ${specific_ungz_file_dir}    Run keyword if    '${case_type}'=='l1crash'
    ...    Fetch from left    ${file_list}[${file_list_index}]    .tgz
    Run keyword if    '${case_type}'=='l1crash'
    ...    Run    cd ${extract_path}/service_failures/ ; mv ${file_list}[${file_list_index}] autodetection.tar.gz ; tar -zxvf autodetection.tar.gz
    Run keyword if    '${case_type}'=='rau'
    ...    Run    gzip -d ${extract_path}/00_journal.gz
    ${key_string}    Run keyword if    '${case_type}'=='l1crash'    Catenate    Main process exited, code=${key_string}, status=9/KILL
    ...    ELSE IF    '${case_type}'=='rau'    Catenate    setsid $CCSRTDIR/${key_string}
    ${output}   Run keyword if    '${case_type}'=='l1crash'
    ...    OperatingSystem.grep file    ${extract_path}/service_failures/${specific_ungz_file_dir}/journal.txt
    ...    ${key_string}    encoding_errors=replace
    ...    ELSE IF    '${case_type}'=='rau'    OperatingSystem.grep file    ${extract_path}/00_journal
    ...    ${key_string}    encoding_errors=replace
    Should not be empty    ${output}
