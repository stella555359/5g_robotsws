*** Settings ***
Documentation
...    Author:fangmin wu
...    contact:fangmin.wu@nokia-sbell.com
...    squad group:mmw_SG_03
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    ./CB007963_coam_keyword.robot


*** Variables ***
${tmp_log_dir}      ${TS_LOG_PATH_BASE}
${ue_type}                   ${tl.ues[-1].capabilities[-1]}
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
@{listen_port}     arb0p0   arb0p1
@{portlist}       1    2
${PTP_SyncE_filter}    'ether proto 0x88f7||0x8809'

${msgid}     ptp.v2.messageid
${sync_message}        ${msgid} == 0
${announce_message}    ${msgid} == 11
${delayReq_message}    ${msgid} == 1
${delayResp_message}   ${msgid} == 9

${announce_flag}    ptp.v2.flags == 0x0000003c
${sync_flag}    ptp.v2.flags == 0x0200

${check_ptp_sync}    ${sync_message} and
...                  ${sync_flag}

${check_ptp_announce}    ${announce_message} and
...                      ptp.v2.an.priority1 == 128 and
...                      ptp.v2.an.priority2 == 128 and
...                      ptp.v2.an.origincurrentutcoffset == 37 and
...                      ptp.v2.timesource == 32 and
...                      ${announce_flag}
${clock_class}          ptp.v2.an.grandmasterclockclass
${clock_accuracy}       ptp.v2.an.grandmasterclockaccuracy
${clock_variance}       ptp.v2.an.grandmasterclockvariance

&{eCpriMasterClockClass}    locked=6    holdover_in=7    holdover_out=150
&{eCpriMasterClockAccuracy}    locked=33    holdover_in=254    holdover_out=254
&{eCpriMasterOffsetScaledLogVariance}    locked=20061    holdover_in=65535    holdover_out=65535

@{status}    locked    holdover_in    holdover_out
${time_relative}     frame.time_relative
${command_template}    {tshark_path} -r {pcap_file} -T pdml
*** Keywords ***
Check ClockState and MaterUsed
    [Arguments]  ${ok_num_expect}  ${index_begin}   ${index_end}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${ok_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=MASTER_CLOCK_OK
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    Should Be Equal     ${ok_num}    ${ok_num_expect}
    ${used_num}    Count param according to expect values     index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_values=used
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    Should Be Equal     ${used_num}      ${1}
    [Teardown]    COAM selenium logout

Get topSlavePortNumber from topMasterClockState
   [Arguments]   ${index_begin}   ${index_end}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${ok_index}    Get Structure_index from expect_index    index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_index=MASTER_CLOCK_OK
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ${PortNumber}       _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${ok_index}
    [Teardown]    COAM selenium logout
    [Return]       ${PortNumber}

Get topSlavePortNumber from topMasterUsed
    [Arguments]   ${index_begin}   ${index_end}  ${is_or_not_used}
    ${used_index}    Get Structure_index from expect_index    index_begin=${index_begin}
    ...                                                       index_end=${index_end}
    ...                                                       expect_index=${is_or_not_used}
    ...                                                       dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ${PortNumber}       _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${used_index}
    [Return]      ${PortNumber}

Set ruECpriPortNumber from topMasterUsed is used
    [Arguments]      ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${PortNumber_used}   Get topSlavePortNumber from topMasterUsed    index_begin=${0}   index_end=${2}   is_or_not_used=used
    ${PortNumber_notused}   Get topSlavePortNumber from topMasterUsed    index_begin=${0}   index_end=${2}   is_or_not_used=not used
    selenium_coam.set_parameter_value    dist_name=${PARAM_7963_STRUCTURE1[2]}[dist_name]
    ...                                  filter_param=${PARAM_7963_STRUCTURE1[2]}[filter_param]
    ...                                  new_value=${PortNumber_used}
    ...                                  abbr=${PARAM_7963_STRUCTURE1[2]}[abbr]
    ...                                  node_index=${0}
    ...                                  timeout=${120}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    COAM selenium logout
    [Return]  ${PortNumber_used}     ${PortNumber_notused}

Set ruECpriPortNumber from topMasterUsed is not used
    [Arguments]    ${PortNumber_notused}     ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.set_parameter_value    dist_name=${PARAM_7963_STRUCTURE1[2]}[dist_name]
    ...                                  filter_param=${PARAM_7963_STRUCTURE1[2]}[filter_param]
    ...                                  new_value=${PortNumber_notused}
    ...                                  abbr=${PARAM_7963_STRUCTURE1[2]}[abbr]
    ...                                  node_index=${0}
    ...                                  timeout=${120}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    COAM selenium logout

Check status and port used
    [Arguments]   ${PortNumber}  ${is_or_not_used}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${lockState}   selenium_coam.get_parameter_value     dist_name=${PARAM_7963_LOCKSTATE[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_LOCKSTATE[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_LOCKSTATE[0]}[abbr]
    Should Be Equal     ${lockState}      Locked
    ${syncStatus}   selenium_coam.get_parameter_value    dist_name=${PARAM_7963_SYNCSTATUS[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_SYNCSTATUS[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_SYNCSTATUS[0]}[abbr]
    Should Be Equal     ${syncStatus}      Locked
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterUsed}       ${is_or_not_used}
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topSlavePortNumber}       ${PortNumber}
    [Teardown]    COAM selenium logout

Check status and port used after activate resiliency
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${lockState}   selenium_coam.get_parameter_value     dist_name=${PARAM_7963_LOCKSTATE[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_LOCKSTATE[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_LOCKSTATE[0]}[abbr]
    Should Be Equal     ${lockState}      Locked
    ${syncStatus}   selenium_coam.get_parameter_value    dist_name=${PARAM_7963_SYNCSTATUS[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_SYNCSTATUS[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_SYNCSTATUS[0]}[abbr]
    Should Be Equal     ${syncStatus}      Locked
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterUsed}       used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topSlavePortNumber}       1
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterUsed}       not used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topSlavePortNumber}       2
    [Teardown]    COAM selenium logout

Check status and port used before activate resiliency
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${lockState}   selenium_coam.get_parameter_value     dist_name=${PARAM_7963_LOCKSTATE[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_LOCKSTATE[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_LOCKSTATE[0]}[abbr]
    Should Be Equal     ${lockState}      Locked
    ${syncStatus}   selenium_coam.get_parameter_value    dist_name=${PARAM_7963_SYNCSTATUS[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_SYNCSTATUS[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_SYNCSTATUS[0]}[abbr]
    Should Be Equal     ${syncStatus}      Locked
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterUsed}       used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topSlavePortNumber}       1
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_DISABLED
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterUsed}       not used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topSlavePortNumber}       2
    [Teardown]    COAM selenium logout

Check status and port used after recovery
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${lockState}   selenium_coam.get_parameter_value     dist_name=${PARAM_7963_LOCKSTATE[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_LOCKSTATE[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_LOCKSTATE[0]}[abbr]
    Should Be Equal     ${lockState}      Locked
    ${syncStatus}   selenium_coam.get_parameter_value    dist_name=${PARAM_7963_SYNCSTATUS[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_SYNCSTATUS[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_SYNCSTATUS[0]}[abbr]
    Should Be Equal     ${syncStatus}      Locked
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_OK
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topMasterUsed}       used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${0}
    Should Be Equal     ${topSlavePortNumber}       1
    ${topMasterClockState}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterClockState}      MASTER_CLOCK_DISABLED
    ${topMasterUsed}   _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topMasterUsed}       not used
    ${topSlavePortNumber}   _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${1}
    Should Be Equal     ${topSlavePortNumber}       2
    [Teardown]    COAM selenium logout

Add one element and set value
    [Arguments]   ${start_num}      ${end_num}
    ...           ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE1[0]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE1[1]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE1[2]}
    ...                                    node_index=${start_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE1[3]}
    ...                                    node_index=${start_num}
    _Add_elements   dist_name=${ADD_ELEMENTS_7963[0]}[dist_name]
    ...             filter_param=${ADD_ELEMENTS_7963[0]}[filter_param]
    ...             abbr=${ADD_ELEMENTS_7963[0]}[abbr]
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE2[0]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE2[1]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE2[2]}
    ...                                    node_index=${end_num}
    Coam Input Parameter value via webUI   param_data=${PARAM_7963_STRUCTURE2[3]}
    ...                                    node_index=${end_num}
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    COAM selenium logout

Check topMasterUsed distribution
    [Arguments]
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    &{port1_values}      Get values from different ports     ports_num=1
    &{port2_values}      Get values from different ports     ports_num=2
    @{used_list}=    Create List
    Append To List     ${used_list}     ${port1_values}[topMasterUsed]
    Append To List     ${used_list}     ${port2_values}[topMasterUsed]
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topGMasterClockClass]
    ...                                                two_num=${port2_values}[topGMasterClockClass]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[localPriority]
    ...                                                two_num=${port2_values}[localPriority]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topStepsRemoved]
    ...                                                two_num=${port2_values}[topStepsRemoved]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    ${used_index}      Find the smallest from list and get topMasterUsed index     one_num=${port1_values}[topMasterClockIdentity]
    ...                                                two_num=${port2_values}[topMasterClockIdentity]
    ...                                                count=${2}
    Run Keyword If     ${used_index}==${0} or ${used_index}==${1}
    ...       Should Be Equal      ${used_list}[${used_index}]         used
    [Teardown]    COAM selenium logout

UE Prepare
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=9999    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=9999    ue_type=${ue_type}    iperf_type=via_command

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}
    [teardown]    Run Keyword and Ignore Error    admin_cli.teardown    connection=COAM

Stop UE traffic and detach UE
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

UE Prepare and UE attach
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Check TP
    [Arguments]    ${tp_direction}=both    ${dl_tp}=100M    ${ul_tp}=100M
    ...    ${exp_dl_tp}=100    ${exp_ul_tp}=100    ${check_times}=30s
    log to console    check tp
    #Attach UE
    UE start traffic   tp_direction=${tp_direction}   ul_tp=${ul_tp}    dl_tp=${dl_tp}
    #Start UE traffic    dl_data=${dl_tp}    ul_data=${ul_tp}
    sleep    1min
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    check_times=${check_times}
    #power_ue.Stop traffic    direction=${tp_direction}    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Check UE DL and UL peak TP seperately
    [Arguments]    ${expect_dl_tp}=1300    ${expect_ul_tp}=60    ${dl_traffic}=1500M    ${ul_traffic}=90M
    UE start traffic   tp_direction=dl   ul_tp=0    dl_tp=${dl_traffic}
	sleep    10s
   	UE check throughput by syslog    tp_direction=dl    exp_ul_tp=0    exp_dl_tp=${expect_dl_tp}    check_times=60
	power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    UE start traffic   tp_direction=ul   ul_tp=${ul_traffic}    dl_tp=0
    sleep    10s
   	UE check throughput by syslog    tp_direction=ul    exp_ul_tp=${expect_ul_tp}    exp_dl_tp=0    check_times=60s
	power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}


Check UE DL throughput is stable during the switchover
    UE start traffic   tp_direction=dl   ul_tp=0    dl_tp=1500M
    sleep    10s
    UE check throughput by syslog    tp_direction=dl    exp_ul_tp=0    exp_dl_tp=500    check_times=60
    set test variable    ${dl_tp_before}    ${all_tp[1]}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_7963_LOCALPRIOPROTY}
    Wait until keyword succeeds    11min    1min    Check topMasterUsed distribution
    UE check throughput by syslog    tp_direction=dl    exp_ul_tp=0    exp_dl_tp=500    check_times=60
    set test variable    ${dl_tp_after}    ${all_tp[1]}
    should be true    ${dl_tp_before}*0.95 < ${dl_tp_after} < ${dl_tp_before}*1.05
    [Teardown]    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}

Check UE UL throughput is stable during the switchover
    UE start traffic   tp_direction=ul   ul_tp=100M    dl_tp=0
    sleep    10s
    UE check throughput by syslog    tp_direction=ul    exp_ul_tp=30    exp_dl_tp=0   check_times=60
    set test variable    ${ul_tp_before}    ${all_tp[4]}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_7963_LOCALPRIOPROTY_1}
    Wait until keyword succeeds    11min    1min    Check topMasterUsed distribution
    UE check throughput by syslog    tp_direction=ul    exp_ul_tp=30    exp_dl_tp=0    check_times=60
    set test variable    ${ul_tp_after}    ${all_tp[4]}
    should be true    ${ul_tp_before}*0.95 < ${ul_tp_after} < ${ul_tp_before}*1.05
    [Teardown]    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}

Start to Capture Wireshark Log
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}
    sleep    3s

Start to Capture Wireshark Log with filter
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
    csn.send command    command=sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &    connection=${connection}
#    csn.send command    command=ip netns exec radions tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &
#    ...    connection=${connection}
    sleep    3s

Capture Wireshark Log for a While from RU
    [Arguments]    ${filename}     ${filter}    ${listen_port}
    Start to Capture Wireshark Log from RU    filename=${filename}    filter=${filter}    listen_port=${listen_port}
    sleep    30s
    Stop and Download Logs from RU     ${filename}

Start to Capture Wireshark Log from RU
    [Arguments]    ${filename}    ${filter}=none    ${listen_port}=arb0p0
    Connect to RU With Allocated IP
    Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    connection=RU
    ...               ELSE    Start to Capture Wireshark Log with filter    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    filter=${filter}    connection=RU

Stop and Download Logs from RU
    [Arguments]    @{filenames}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
    csn.send command        command=killall tcpdump     connection=RU
    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
    FOR    ${filename}    IN    @{filenames}
        csn.send command        command=sudo chmod 777 ${filename}    connection=RU
        csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=RU
        sleep    2s
        csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
    END

Check Log in Wireshark Log for SSM and PTP
    [Arguments]    ${file_name}    ${status}    ${listen_port}    ${is_have_message_status}
    Check Complete PTP messages      file_name=${file_name}    listen_port=${listen_port}    is_have_message_status=${is_have_message_status}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                                 command_template=${command_template}
    ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
    ...                          ${check_ptp_announce}
    ...                          ${clock_class}==${eCpriMasterClockClass}[${status}]
    ...                          ${clock_accuracy}==${eCpriMasterClockAccuracy}[${status}]
    ...                          ${clock_variance}==${eCpriMasterOffsetScaledLogVariance}[${status}]
    Check expression in Bip Log by Name    filter_expression=${expression}    field_name=${msgid}
    Check expression in Bip Log by Name    filter_expression=${check_ptp_sync}    field_name=${msgid}

Check Message Rate
    [Arguments]    ${filename}    ${filter}    ${min_rate}    ${max_rate}
    ${msg}=    Get Frame Info Value from Wireshark Log
    ...        filename=${filename}
    ...        check_param=${time_relative}
    ...        condition_expression=${filter}
    ${cnt}=    Get Length     ${msg}
    ${time}=    Evaluate    ${msg[-1]}-${msg[0]}
    ${rate}=    Evaluate        (${cnt}-1)/${time}
    Should Be True     ${min_rate} < ${rate} < ${max_rate}

Get Frame Info Value from Wireshark Log
    [Arguments]    ${filename}    ${check_param}   ${condition_expression}=${None}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${filename}
    ...                                                 command_template=${command_template}
    ${filtered_packets}    pcap.filter_packets_by_expression    filter_expression=${condition_expression}
    ${value}      pcap.get_field_value_by_name
    ...                                              field_name=${check_param}
    [Return]    ${value}

Check Complete PTP messages
    [Arguments]    ${file_name}   ${listen_port}  ${is_have_message_status}
    Capture Wireshark Log for a While from RU    filename=${file_name}   filter=${PTP_SyncE_filter}   listen_port=${listen_port}
    Check Message Rate    filename=${file_name}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
    ${result_status1}    Run Keyword And Return Status    Check Message Rate    filename=${file_name}
    ...                                                                         filter=${delayReq_message}
    ...                                                                         min_rate=15.9
    ...                                                                         max_rate=16.1
    Should Be Equal    ${result_status1}     ${is_have_message_status}
    ${result_status2}    Run Keyword And Return Status    Check Message Rate    filename=${file_name}
    ...                                                                         filter=${delayResp_message}
    ...                                                                         min_rate=15.9
    ...                                                                         max_rate=16.1
    Should Be Equal    ${result_status2}     ${is_have_message_status}

Check complete PTP messages for All ports
    [Arguments]   ${file_name}
    ${PortNumber}      Get topSlavePortNumber from topMasterClockState     index_begin=${0}       index_end=${2}
    ${port_index}    Get Index From List      ${portlist}     ${PortNumber}
    Run keyword if     ${port_index}==${0}
    ...    Check Complete PTP messages       file_name=${file_name[0]}    listen_port=${listen_port}[0]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[0]}
    ...                                                              listen_port=${listen_port}[0]
    ...                                                              is_have_message_status=${False}
    Run keyword if     ${port_index}==${1}
    ...    Check Complete PTP messages      file_name=${file_name[1]}    listen_port=${listen_port}[1]    is_have_message_status=${True}
    ...    ELSE     Run Keyword     Check Complete PTP messages      file_name=${file_name[1]}
    ...                                                              listen_port=${listen_port}[1]
    ...                                                              is_have_message_status=${False}

Check Two Structure Log in Wireshark Log for SSM and PTP
    [Arguments]   ${file_name}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[0]}
    ...                                            status=${status}[0]
    ...                                            listen_port=${listen_port}[0]
    ...                                            is_have_message_status=${True}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name[1]}
    ...                                           status=${status}[0]
    ...                                            listen_port=${listen_port}[1]
    ...                                            is_have_message_status=${True}
#    Check Complete PTP messages      file_name=${file_name[0]}    listen_port=@{listen_port}[0]    is_have_message_status=${False}
#    Check Complete PTP messages     file_name=${file_name[1]}    listen_port=@{listen_port}[1]    is_have_message_status=${False}
