*** Settings ***
Documentation
...    author yinghua zhang
...    date: 10/23/2025
Suite Setup         Run Keywords    robot_common_operations.Common Suite Setup
...    AND          CI_interface.Common Suite Setup
Suite Teardown      robot_common_operations.Common Suite Teardown
Test Setup          robot_common_operations.Common Case Setup    allowed_faults_ids=7311
Test Teardown       MMW5 Common Case Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library     parse_pm_info.py
Library     analysis_iperf_result.py

*** Variables ***
#${if_commissioning}         False
${IPERF_R_IP}               ${tl.ues[0].data_transfer[0].app_server.address}
${IPERF_R_USER}             ${tl.ues[0].data_transfer[0].app_server.user}
${IPERF_R_PASSWORD}         ${tl.ues[0].data_transfer[0].app_server.password}
${5QI82}                    5QI82
${SIZE_5QI82}               35
${PORT_5QI82}               45024
${DATA_RATE_5QI82}          399pps
${TIME_5QI82}               752
${5QI83}                    5QI83
${SIZE_5QI83}               1326
${PORT_5QI83}               45023
${DATA_RATE_5QI83}          99pps
${TIME_5QI83}               3031
${LOCAL_PATH}               /home/ute/MMW_SG5/
#for now, only check the lost and late counters must be 0, and M55159C00015 is greater than 300000
#@{COUNTERS}            M55159C00013    M55159C00014   M55159C00015   M55159C00024
@{COUNTERS}            M55159C00013    M55159C00014   M55159C00015
${SHELL_SCRIPTS_SENDER}     ${CURDIR}/resources/sender/
${SHELL_SCRIPTS_RECEIVER}   ${CURDIR}/resources/receiver/
@{BTS_CUSTOM_PROFILE}       immediateSnapshot
#@{CUSTOM_PROFILE}           condor5gSyslog    cp_5g
@{CUSTOM_PROFILE}    condor5gSyslog    cp_5g    L2Ps_Component    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component

*** Test Cases ***
CB008600-W_104_DC-GBR_UL_PER_and_PDB_Verification_for_TDD_Cell_Case2
    [Documentation]    run two cases for 5QI82 and 5QI83 respectively
    Connect to gnb coam via ssl
    Reboot_ptp_service
    Log To Console    ***test for 5QI-82***\n
    Wait Until Keyword Succeeds    3x    15s    CASE_STEP_FLOW    cpe_apn=mdrb.nokia.com
    ...    5qi=${5QI82}    port=${PORT_5QI82}    size=${SIZE_5QI82}
    ...    datarate=${DATA_RATE_5QI82}    time=${TIME_5QI82}    nrcellId=NRCELL-3502
    ...    pmqapId=NRPMQAP-1    pdb=90    per=0.0001
    Log To Console    ***test for 5QI-83***\n
    Wait Until Keyword Succeeds    3x    15s    CASE_STEP_FLOW    cpe_apn=mdrb3.nokia.com
    ...    5qi=${5QI83}    port=${PORT_5QI83}    size=${SIZE_5QI83}
    ...    datarate=${DATA_RATE_5QI83}    time=${TIME_5QI83}    nrcellId=NRCELL-3502
    ...    pmqapId=NRPMQAP-3    pdb=90    per=0.0001

    [Teardown]    Common_Teardown


*** Keywords ***
Reboot_ptp_service
    Connect to control pc enhanced
    Wait Until Keyword Succeeds    5min    20s    Csn.Connect to   ${IPERF_R_IP}
    ...    ${IPERF_R_USER}    ${IPERF_R_PASSWORD}    alias=IPERF_RECEIVER
    csn.Send Command    command=sudo systemctl restart ptp4l.service
    ...    connection=IPERF_RECEIVER
    csn.Send Command    command=sudo systemctl restart ptp4l.service
    ...    connection=cpc_0
    Sleep    60s
    csn.Send Command    command=sudo systemctl status ptp4l.service
    ...    connection=IPERF_RECEIVER
    csn.Send Command    command=sudo systemctl status ptp4l.service
    ...    connection=cpc_0
    ${output1}    csn.Read Output    connection=IPERF_RECEIVER
    ${output2}    csn.Read Output    connection=cpc_0

    Run Keyword And Ignore Error    csn.Disconnect    connection=cpc_0
    Run Keyword And Ignore Error    csn.Disconnect    connection=IPERF_RECEIVER

CASE_STEP_FLOW
    [Arguments]    ${cpe_apn}    ${5qi}    ${port}    ${size}
    ...    ${datarate}    ${time}    ${nrcellId}    ${pmqapId}
    ...    ${pdb}    ${per}
    Connect to control pc enhanced
    Wait Until Keyword Succeeds    5min    20s    Csn.Connect to   ${IPERF_R_IP}
    ...    ${IPERF_R_USER}    ${IPERF_R_PASSWORD}    alias=IPERF_RECEIVER
    Upload_Shell_Scripts_To_Server    connection=cpc_0    dir=${SHELL_SCRIPTS_SENDER}
    Upload_Shell_Scripts_To_Server    connection=IPERF_RECEIVER    dir=${SHELL_SCRIPTS_RECEIVER}
    Kill_process_before_test    connection=cpc_0
    Kill_process_before_test    connection=IPERF_RECEIVER
    Log To Console    ***start to capture traces via DCAP***\n
    Run Keyword And Ignore Error    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}
    ...    bts_profile_list=${BTS_CUSTOM_PROFILE}    host=10.57.195.96
    Log To Console    ***traces launched successfully***\n
    # xxx seconds for 5QI-xx UL traffic to make sure enough data for e2e delay statistics
    ${start_time}    get_nearest_5min_timestamps_down
    ${s_datetime}=    Evaluate    datetime.datetime.fromtimestamp(${start_time}).strftime('%Y-%m-%d %H:%M:%S')
    ...    datetime
    Log To Console    ***counter start time is: ${s_datetime}***\n
    COMMON_PROCESS    cpe_apn=${cpe_apn}    5qi=${5qi}    port=${port}    size=${size}
    ...    datarate=${datarate}    time=${time}
    Log To Console    ***start sending ul traffic, will be last ${time} seconds***\n
#    sleep    ${time}
    ${end_time}    get_nearest_5min_timestamps_up
    ${e_datetime}=    Evaluate    datetime.datetime.fromtimestamp(${end_time}).strftime('%Y-%m-%d %H:%M:%S')
    ...    datetime
    Log To Console    ***counter end time is: ${e_datetime}***\n
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID
    Wait Until Keyword Succeeds    2min    30s    Check_the_iperf_tcpdump_process_finished    port=${port}
    #check if 5QI-xx e2e delay and counters is met requirement
    ${sizeName}    Evaluate    ${size} + 28
    ${E2E_DELAY_FILE}      Set Variable    case104_${5qi}_UL_TTI_${sizeName}B_${datarate}.txt
    Log To Console    ***check e2e delay***\n
    Check_e2e_delay    ran_PDB=${pdb}    ran_PER=${per}    filename=${E2E_DELAY_FILE}
    Log To Console    ***check counters***\n
    Check_pm_counters    nrcellId=${nrcellId}    pmqapId=${pmqapId}    counter_ids=${COUNTERS}
    ...    start_time=${start_time}    end_time=${end_time}
    Run Keyword And Ignore Error    csn.Disconnect    connection=cpc_0
    Run Keyword And Ignore Error    csn.Disconnect    connection=IPERF_RECEIVER

COMMON_PROCESS
    [Arguments]    ${cpe_apn}    ${5qi}    ${port}    ${size}
    ...    ${datarate}    ${time}
    #step1: set APN for 5QI-xx
    Log To Console    ***ssh to iperf-sender server***\n
    Log To Console    ***change the apn for UE***\n
    csn.Send Command    command=./CB008600_changing_apn.sh ${cpe_apn}    connection=cpc_0
    ${output_apn}    csn.Read Output    connection=cpc_0
    #step2: UE detach and attach
    Log To Console    ***UE re-attach and add static route***\n
    csn.Send Command    command=./CB008600_route_conf_with_CPE_re-attach.sh    connection=cpc_0
    ${output_call}    csn.Read Output    connection=cpc_0
    #step3: sending UL traffic for 5QI-xx
    Log To Console    ***run script on iperf-receiver, and start tcpdump***\n
    #add time to avoid iperf receiver stop before sender, because the gap between two keywords is more than 5s
    ${time_R}    Evaluate    ${time} + 10
    Start_Script_On_IperfReceiver    5qi=${5qi}    port=${port}    size=${size}    datarate=${datarate}    time=${time_R}
    Log To Console    ***run script on iperf-sender, and start tcpdump***\n
    Start_Script_On_IperfSender    5qi=${5qi}    port=${port}    size=${size}    datarate=${datarate}    time=${time}
    ${output_r}    csn.Read Output    connection=IPERF_RECEIVER
    ${output_s}    csn.Read Output    connection=cpc_0

Get_Files_Absolute_Directory_In_Directory
    [Documentation]    get all files absolute directory in a given directory
    [Arguments]    ${dir}
    ${files}=    OperatingSystem.list_directory    path=${dir}    absolute=True
    RETURN    ${files}

Upload_Shell_Scripts_To_Server
    [Arguments]    ${dir}    ${connection}
    ${files}=    Get_Files_Absolute_Directory_In_Directory    ${dir}
    csn.Upload File    local_path=@{files}   remote_path=/home/ute/    connection=${connection}
    #change permission for shell scripts
    csn.Send Command    command=chmod +x /home/ute/CB008600*.sh
    ...              connection=${connection}

Start_Script_On_IperfReceiver
    [Arguments]    ${5qi}    ${port}    ${size}    ${datarate}    ${time}
    #send commands
    csn.Send Command    command=./CB008600_start_iperf_receiver.sh ${5qi} ${port} ${size} ${datarate} ${time}
    ...    connection=IPERF_RECEIVER

Start_Script_On_IperfSender
    [Arguments]    ${5qi}    ${port}    ${size}    ${datarate}    ${time}
    #has been login control pc in previous steps
    #send commands
    csn.Send Command    command=./CB008600_start_iperf_sender.sh ${5qi} ${port} ${size} ${datarate} ${time}
    ...    connection=cpc_0

Check_e2e_delay
    [Arguments]    ${ran_PDB}    ${ran_PER}    ${filename}
    # Before downloading the file, delete any existing file with the same name in the local path
    ${local_file_path}    Catenate    SEPARATOR=    ${LOCAL_PATH}    ${filename}
    Run Keyword And Ignore Error    Remove File    ${local_file_path}
    # Proceed to download the file from iperfReceiver
    csn.Download File    remote_path=/home/ute/${filename}
    ...                  local_path=${local_file_path}
    ...                  connection=IPERF_RECEIVER
    ${result}    sum_cnt_above_bin_from_file    file_path=${local_file_path}    bin_threshold=${ran_PDB}
    ...    per_threshold=${ran_PER}
    Should Be True    ${result}    msg=Case failed: iperf output does not meet requirements

Common_Teardown
    Connect to control pc enhanced
    csn.Send Command    command=./CB008600_detach_CPE.sh    connection=cpc_0
    Run Keyword And Ignore Error    csn.Disconnect    connection=cpc_0
    Run Keyword And Ignore Error    csn.Disconnect    connection=IPERF_RECEIVER
    Run Keyword And Ignore Error    Coam.teardown    connection=GNB_OAM
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID
    MMW5 Common Case Teardown

Check_the_iperf_tcpdump_process_finished
    [Documentation]    check whether the iperf and tcpdump process finished on both sender and receiver side
    [Arguments]    ${port}=None
    #check iperf and tcpdump process on iperf sender side(control pc)
    csn.Send Command    command=ps -ef | grep iperf | grep -v grep | wc -l
    ...    connection=cpc_0
    ${iperf_sender_process}    csn.Read Output    connection=cpc_0
    log    ${iperf_sender_process}
    Should Be Equal As Integers    ${iperf_sender_process.strip()}    0
    ...    msg=iperf sender process is still running on control pc
    csn.Send Command    command=ps -ef | grep tcpdump | grep -v grep | wc -l
    ...    connection=cpc_0
    ${tcpdump_sender_process}    csn.Read Output    connection=cpc_0
    log    ${tcpdump_sender_process}
    Should Be Equal As Integers    ${tcpdump_sender_process.strip()}    0
    ...    msg=tcpdump sender process is still running on control pc

    #check iperf and tcpdump process on iperf receiver side(iperf receiver pc)
    csn.Send Command    command=ps -ef | grep iperf | grep -v grep | grep ${port} | wc -l
    ...    connection=IPERF_RECEIVER
    ${iperf_receiver_process}    csn.Read Output    connection=IPERF_RECEIVER
    Should Be Equal As Integers    ${iperf_receiver_process.strip()}    0
    ...    msg=iperf receiver process is still running on iperf receiver pc
    csn.Send Command    command=ps -ef | grep tcpdump | grep -v grep | wc -l
    ...    connection=IPERF_RECEIVER
    ${tcpdump_receiver_process}    csn.Read Output    connection=IPERF_RECEIVER
    Should Be Equal As Integers    ${tcpdump_receiver_process.strip()}    0
    ...    msg=tcpdump receiver process is still running on iperf receiver pc

Check_pm_counters
    [Arguments]    ${nrcellId}    ${pmqapId}    ${counter_ids}    ${start_time}    ${end_time}
    wait_until_next_5_min    extra_sleep_time=60
    ${counter_str}=    Evaluate    ','.join(${counter_ids})
    ${pm_info}    coam.get_pm_counters    counter_ids=${counter_str}    connection=GNB_OAM    timeout=300
    ${pm_dic}    load_pm_info_as_dict    ${pm_info}
    ${countPerId}    sum_counts_in_time_range    ${pm_dic}    ${nrcellId}    ${pmqapId}
    ...    ${counter_ids}    ${start_time}    ${end_time}
    FOR   ${counterid}   IN    @{counter_ids}
        ${count}    Set Variable    ${countPerId["${counterid}"]}
        Continue For Loop If    '${counterid}' == 'M55159C00015' and ${count} > 300000
        Continue For Loop If    '${counterid}' == 'M55159C00024' and ${count} == ${countPerId["M55159C00015"]}
        Should Be True    ${count} == 0    msg=Counter ${counterid} is not 0, actual value is ${count}
    END

Kill_process_before_test
    [Arguments]    ${connection}
    csn.Send Command    command=ps -ef|grep iperf|grep -v grep|grep -v iperf3| awk '{print $2}' |sudo xargs kill -9
    ...    connection=${connection}
    csn.Send Command    command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |sudo xargs kill -9
    ...    connection=${connection}