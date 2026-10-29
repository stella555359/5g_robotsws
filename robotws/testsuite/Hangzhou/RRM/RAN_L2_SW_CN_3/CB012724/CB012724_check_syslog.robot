# @Time    : 2025/8/20 10:20
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CBO12724_check_syslog.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    Feature: NR Counters of Utilization and Quality Measurements
Resource    ../../RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    ../../RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot

*** Keywords ***
Check Syslog For H312
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/28 15:06
    [Arguments]    ${bwp_count}=3    ${connection}=M5_DCAP
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${syslog_files}    find_special_file_from_folder    ${dcap_folder}    syslog.log
    ${bwp_length}    get_bwp_profile_id    syslog_file=${syslog_files[-1]}
    Should Be Equal As Numbers    ${bwp_length}    ${bwp_count}
