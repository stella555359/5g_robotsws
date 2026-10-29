*** Settings ***
Documentation    author：yang jiao
...              contact: jiao.1.yang@nokia.com
...              squad group: HAZ7


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan


*** Variables ***
${gNB_ip0}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${TL_BTS_ID}                  ${tl.gnbs[0].instance_id}
${TL_NRBTS_ID}                ${tl.gnbs[0].global_bts_id}
@{PA_port_list}               ${8}   ${9}   ${10}   ${11}   ${12}   ${13}   ${14}   ${15}
@{allowed_list1}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${4298}    ${4459}
@{gnb0_all_cell}              ${5}    ${2}    ${301}    ${401}    ${411}
${allowed_faults_ids}         7311,7331,49
@{counter_object_name}        NCAC    NCAC
${dl_port_list}               ${tl.ues[0].iperf_details.ports}
${ul_port_list}               ${tl.ues[0].iperf_details.ports}
@{swap_value_1}               ${0}   ${0}   ${0}   ${0}   ${40}   ${40}   ${40}   ${40}
@{swap_value_2}               ${40}   ${40}   ${40}   ${40}   ${0}   ${0}   ${0}   ${0}
@{init_PA_value}              ${0}   ${0}   ${0}   ${0}   ${0}   ${0}   ${0}   ${0}
@{cell_id_list}               ${153681925}




*** Keywords ***
########### setup and teardown KW #################
CNI144631 Suite setup
    #CI_interface.Common Suite Setup
    Setup Commission SCF       bts_host=${gNB_ip0}    connection=GNB_OAM
    Check GNB on air    bts_host=${gnb_ip0}    connection=GNB_OAM
    sleep    3min
    robot_common_operations.Common Suite Setup

CNI144631 Suite Teardown
    robot_common_operations.Common Suite Teardown

CNI144631 Common Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

CNI144631 Common Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    _Create Test Log Directory

_Create Test Log Directory
    ${TEST_LOG_DIR}    Set Variable    ${OUTPUT_DIR}/${TEST_NAME[:21]}
    Create Directory  ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}

########### common operate #################
MTK90 Attach By Power UE And Start Traffic And Check TP
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index}    ${target_avg_percent}=0.9
    ...    ${min_percent}=0    ${log_time}=10s    ${if_ul}=${True}    ${if_dl}=${True}    ${ignore_time}=10s    ${check_tput}=${True}
    Adjust the HBTE attenuation value    value_list=${init_PA_value}    port_list=${PA_port_list}
    MTK UE Click on airplane mode    ue_mode=Attach    ue_index=${ue_index}
    UE Start Traffic    ue_index=${ue_index}    ue_type=samsung    ul_throughput=50M    dl_throughput=400M
    Run keyword if    ${check_tput}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}
    ...    ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    ...   ignore_time=${ignore_time}

MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}
    Get all UE pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Get all UE pointer variable
    [Documentation]    Pixel range of X80 mobile phones
    ...                MTK：（1110~1280）：1200
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${brand}    mtk

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s

UE Start Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if     ${if_ul}    power_ue.Start traffic    direction=ul    duration=${ul_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${ul_port_list[${ue_index}]}    throughput=${ul_throughput}
    ...    ue_type=${ue_type}    apn_address=dxdata1    iperf_type=via_command
    run keyword and continue on failure    run keyword if     ${if_dl}    power_ue.Start traffic    direction=dl    duration=${dl_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${dl_port_list[${ue_index}]}    throughput=${dl_throughput}
    ...    ue_type=${ue_type}

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${10}    ${dl_tp}=${10}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0    ${ue_type}=samsung   ${log_time}=60s    ${ignore_time}=30s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=${ignore_time}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    omit_time=80
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    omit_time=80

MTK90 Stop Traffic And Detach UE
    [Arguments]  ${ue_index}    ${if_ul}    ${if_dl}    ${protocol}=udp
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]  MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

UE Stop Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${ul_port_list[${ue_index}]}    iperf_type=via_command
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${dl_port_list[${ue_index}]}


Adjust PA to trigger scell swap
    [Arguments]    ${value_list}     ${gnb_index}=${0}     ${need_syslog}=${False}    ${log_name}=None
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${PA_port_list}
    Run Keyword If    ${need_syslog}    sleep   30s
    ${local_path}    Run Keyword If    ${need_syslog}    Stop Capture Aasyslog    gnb_index=${gnb_index}    log_name=${log_name}
    [Return]   ${local_path}

A6 swap trigger
    FOR   ${index}   IN RANGE    5
        Adjust PA to trigger scell swap    value_list=${swap_value_1}
        sleep    5s
        Adjust PA to trigger scell swap    value_list=${swap_value_2}
        sleep    5s
    END



get_bts_counters
    [Arguments]    ${counter_ids}    ${counter_name_list}    ${NRCELL_ID}    ${MRBTS_ID}    ${NRBTS_ID}    ${if_before}     ${bts_host}=${gNB_ip}
    ...    ${before_timestamp_list}=${empty_list}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    @{counter_last_time_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_name_list}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}     timeout=${300}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${before_last_time}    Set Variable if    not ${if_before}    ${before_timestamp_list[${item}]}    0
        ${result}    Set Variable
        ...     ${counter_value['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['${NRCELL_ID}']['${counter_name}']['${counter_id}']}
        ${values}    get dictionary values     ${result}
        ${keys}    get dictionary keys     ${result}
        ${index}    get_list_index    my_list=${keys}    value=${before_last_time}
#        ${index}    Set Variable if    not ${if_before}    ${index_1}    ${-1}
        ${sum_value}    Evaluate    sum(${values[${index}:]})
        Append To List    ${counter_value_list}    ${sum_value}
        Append To List    ${counter_last_time_list}    ${keys[${-1}]}
    END
    [Return]    ${counter_value_list}    ${counter_last_time_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

check counter value
    [Arguments]    ${before_value}    ${after_value}    ${expected_value}
    ${counter_len}    Get Length    ${before_value}
    FOR  ${value}    IN RANGE    0    ${counter_len}
         ${before}    Set Variable    ${before_value[${value}]}
         ${after}    Set Variable    ${after_value[${value}]}
         ${expected}    Set Variable    ${expected_value[${value}]}
         ${actually}    Evaluate    ${after}-${before}
         should be equal    ${expected}      ${actually}
    END

Generate counter csv file And Check counter
    [Arguments]    ${bts_host}=${gNB_ip}    ${output_path}=${output_dir}
    Log to console    Start get and calculate Kpi from BTS
    ${output_result}    calculate_kpi_via_counter    bts_host=${bts_host}
    ...    counter_object_patterns=/NRCELL-5/
    ...    output_path=${output_path}    kpi_ids=swap
    ...    filename=CNI_144631_kpi    calculate_kpi=${True}
    Log to console    kpi saved: ${output_result}[output_file]
    Log to console    kpi value: ${output_result}[kpi_dict]
    ${kpi_dict}    set variable    ${output_result}[kpi_dict]
    ${kpi_name}    get dictionary keys    ${kpi_dict}
    FOR    ${kpi}    IN    @{kpi_name}
        ${kpi_value}    set variable    ${kpi_dict}[${kpi}]
        ${diff}    Evaluate    ${kpi_value}-${100}
        Run Keyword And Continue On Failure    Should Be True    ${diff}==${0}    msg=${kpi}, ${kpi_value}% != 100%, pls check!!!
    END

Start Capture Aasyslog
    [Arguments]      ${gnb_index}    ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}
    Aasyslog precondition    gnb_index=${gnb_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    gnb_path=${gnb_path}    log_name=${log_name}

Stop Capture Aasyslog
    [Arguments]  ${gnb_index}    ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    ${local_path}    set variable    ${TEST_LOG_DIR}/${log_name}
    Download Aasyslog File From GNB    gnb_index=${gnb_index}    log_path=${gnb_path}${log_name}    local_path=${local_path}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}
    [Return]    ${local_path}
