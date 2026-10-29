*** Settings ***
Documentation     author: jackie ji
...               Group: HGZ_SG5
...               contact: jackie.ji@nokia-sbell.com


Library           ../../libraries/get_bts_info.py   WITH NAME    lib
Library           ../../libraries/time_handle.py    WITH NAME    time_handle
Library           taf.ul.selenium.netact    WITH NAME    selenetact
Library           taf.ul.swing.core    WITH NAME    swing
Resource          ../../common/coam_resource.robot

*** Variables ***
${couter_id}               M55319C00001
${tmp_path}                /tmp/
${snapshot_filename}       snapshot_file_list.txt
${renamed_zip}             snapshot.zip




*** Keywords ***
"${Step}" Login cOAM WebUI
    log to console    Login cOAM WebUI
    wait until keyword succeeds    2min    20s    WEBUI Login

"${Step}" Check BTS counters info
    log to console    Check BTS counters info
    wait until keyword succeeds    10min    2min    Check BTS counters info display normally

"${Step}" SSH to BTS and check PM files exist
    log to console    SSH to BTS and check PM files exist
    wait until keyword succeeds    10min    2min    Check whether PM files exist

"${Step}" Fetch BTS ID info
    log to console    Fetch BTS ID info
    Obtain_BTS_Name_ID

"${Step}" Alter measurement and reportingIntervalPm values
    log to console    Alter measurement and reportingIntervalPm values
    Confirm measurement and reporting interval values    5min
    sleep    6min


Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbts_id}    Set Variable    NRBTS-${nrbtsId}
    ${mrbts_id}    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${mrbtsId}
    set suite variable    ${nrbtsId}
    set suite variable    ${mrbts_id}
    set suite variable    ${nrbts_id}

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Check BTS counters info display normally
    &{bts_counters_info}    selenium_coam.get_bts_counters_info    counter_id=${couter_id}
    ${keys_list}      Get Dictionary Keys    ${bts_counters_info}
    ${values_list}    Get Dictionary Values    ${bts_counters_info}

    log to console    Check count key as timestamps
    FOR    ${key}    IN    @{keys_list}
        should match regexp    ${key}    \\d{4}-\\d{2}-\\d{2}\\s\\d+:\\d{2}:\\d{2}
    END
    log to console    Check count value as non_zero
    ${zero_count}    get count    ${values_list}    0
    should be equal    ${zero_count}    ${0}

Check whether PM files exist
    csn.connect_to     hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    ${tmp_files}    csn.execute    command=cd ${tmp_path} && ls -al | grep 'PM.BTS.*.ANY.*.gz'    connection=gNB
    csn.disconnect    connection=gNB
    should not be empty    ${tmp_files}

Recovery measurement and reportingIntervalPm values
    [Arguments]    ${recovery_value}=15min
    log to console    Recovery measurement and reportingIntervalPm values
    wait until keyword succeeds    2min    30s    WEBUI Login
    Obtain_BTS_Name_ID
    Confirm measurement and reporting interval values     expected_value=${recovery_value}
    WebUI Logout

Confirm measurement and reporting interval values
    [Arguments]    ${expected_value}
    Confirm alter measurement interval value    expected_value=${expected_value}
    Confirm alter reporting interval PM value    expected_value=${expected_value}

Confirm alter measurement interval value
    [Arguments]    ${expected_value}
    set suite variable    ${measure_distname}    ${mrbts_id}/${nrbts_id}/NRPMRNL-1
    set suite variable    ${meas_filter_name}    Measurement interval for NR PDCP Report 1
    ${cur_value}    selenium_coam.get_parameter_value    dist_name=${measure_distname}    filter_param=${meas_filter_name}
    run keyword if    "${cur_value}"!="${expected_value}"    Alter measurement interval value to expected     expected_value=${expected_value}

Confirm alter reporting interval PM value
    [Arguments]    ${expected_value}
    set suite variable    ${reporting_distname}    ${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    set suite variable    ${reporting_filter_name}    Performance measurement data reporting interval
    ${cur_value}    selenium_coam.get_parameter_value    dist_name=${reporting_distname}    filter_param=${reporting_filter_name}
    run keyword if    "${cur_value}"!="${expected_value}"    Alter reporting interval PM value to expected     expected_value=${expected_value}

Alter measurement interval value to expected
    [Arguments]    ${expected_value}
    selenium_coam.set_parameter_value    dist_name=${measure_distname}    filter_param=${meas_filter_name}    new_value=${expected_value}
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${measure_distname}    filter_param=${meas_filter_name}
    should be equal    ${current_value}    ${expected_value}
    sleep    1s
    log to console    measurement value altered success

Alter reporting interval PM value to expected
    [Arguments]    ${expected_value}
    selenium_coam.set_parameter_value    dist_name=${reporting_distname}    filter_param=${reporting_filter_name}    new_value=${expected_value}
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${reporting_distname}    filter_param=${reporting_filter_name}
    should be equal    ${current_value}    ${expected_value}
    sleep    1s
    log to console    reporting value altered success

Capture snapshot log and copy it to specified path
    [Arguments]    ${save_log_path}=/tmp
    log to console    Capture snapshot log and copy it to specified path
    ${snapshot_path}    selenium_coam.collect_snapshot
    set suite variable    ${snapshot_path}
    log to console    start to sleep
    sleep    5s
    log to console    sleep done
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM

    csn.execute    command=cd ${save_log_path};mkdir -m 777 copied_log    connection=VM
    set suite variable    ${save_log_path}
    set suite variable    ${copied_snapshot_path}    ${save_log_path}/copied_log

    run process    scp -r ${snapshot_path} ${copied_snapshot_path}    shell=yes
    sleep    3s
    ${copied_file}    csn.execute    command=cd ${copied_snapshot_path};ls    connection=VM
    @{copied_file_list}    split string    ${copied_file}
    ${copied_file_name}    set variable    ${copied_file_list}[0]
    should not be empty    ${copied_file_name}
    ${copied_file_size}    get file size    ${copied_snapshot_path}/${copied_file_name}
    should not be equal    ${copied_file_size}    ${0}
    log to console    zip file found!!!
    sleep    10s
    csn.disconnect    connection=VM

Unzip snapshot log and check R&D exist
    [Arguments]    ${snapshot_file_list}=${snapshot_filename}
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    ${snapshot_zip}    csn.execute    command=cd ${copied_snapshot_path} && ls | grep 'zip'    connection=VM
    @{snapshot_list}    Split String    ${snapshot_zip}
    ${zip_file}    set variable    ${snapshot_list}[0]
    csn.execute    command=cd ${copied_snapshot_path} && mv ${zip_file} ${renamed_zip}    connection=VM
    log to console   rename long zip to short...
    ${renamed_zip_file}    join path    ${copied_snapshot_path}    ${renamed_zip}
    csn.execute    command=unzip ${renamed_zip_file} -d ${copied_snapshot_path}    connection=VM
    sleep    5s
    ${files_list}    csn.execute    command=cd ${copied_snapshot_path}&& ls    connection=VM
    csn.disconnect    connection=VM
    should contain    ${files_list}    ${snapshot_file_list}
    ${snapshot_list_txt_path}    join path    ${copied_snapshot_path}    ${snapshot_file_list}
    ${snapshot_list_content}    get file    ${snapshot_list_txt_path}
    should match regexp    ${snapshot_list_content}    BTS.*RD.BTS.*.ANY.*.gz


Delete loaded snapshot log
    log to console    delete loaded snapshot log
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    run keyword and ignore error    csn.execute    command=rm -r ${snapshot_path}    connection=VM
    run keyword and ignore error    csn.execute    command=cd ${save_log_path};rm -r copied_log    connection=VM
    csn.disconnect    connection=VM

Wait some minutes and check counter interval
    [Arguments]    ${wait_time}    ${time_interval}
    wait until keyword succeeds    ${wait_time}    ${time_interval}    Check counter interval

Check counter interval
    log to console    start to check counter interval
    &{output}    selenium_coam.get_bts_counters_info     couter_id=${couter_id}
    ${values}    Get Dictionary Keys    ${output}
    ${time_list}    time_handle.sort_time    time_value=${values}
    ${values0}    set variable    ${time_list}[0]
    ${values1}    set variable    ${time_list}[1]
    ${result}    time_handle.time_check    date0=${values0}    date1=${values1}
    should be equal    ${result}    success
