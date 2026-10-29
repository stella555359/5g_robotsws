*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Library     taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library     TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot




*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_name}               ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gNB_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${MRBTS_ID}                   MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                   NRBTS-${tl.gnbs[0].global_bts_id}
@{all_cell_list}              1    2    3    4    7    5    6
@{all_nr_cell_list}           184057857    184057858    184057859    184057860    184057863    184057861    184057862
@{allowed_list1}              ${4655}    ${61524}    ${4654}    ${61652}    ${61649}    ${49}
@{allowed_list2}              ${4655}    ${61524}    ${4654}    ${61652}    ${61649}
${NRCELL4_ID}                 NRCELL-4
${NRCELL7_ID}                 NRCELL-7
${NRCELL5_ID}                 NRCELL-5
@{case7_counter_name}         RSACU    NCELA   NCELA
@{case8_counter_name}         PDCCH
@{case10_counter_name}        NCELA    NCELA
@{readcap_ue_ul_tp}           12    12    12    12


*** Keywords ***
########### setup KW #################
Test Case Setup
    Set Suite Variable    ${Test_case_log_dir}  ${output_dir}/${TEST_NAME[:30]}
    Create Directory    ${Test_case_log_dir}
    robot_common_operations.Common Case Setup
    ${if_sleeping_time}    Determine whether it is during the power saving period    week_day=Sun    start_hour=21    period_min=30
    Run Keyword If    ${if_sleeping_time}    Check GNB on air except sleeping cell    expect_cell_id=${3}
    ...    ELSE    Check GNB on air    bts_host=${gNB_ip}

Test Case Teardown
    [Arguments]    ${unblock_cell_list}=${empty_list}    ${input_list}=${empty_list}
    ${unblock_num}   Get Length    ${unblock_cell_list}
    ${modify_para_num}    Get Length    ${input_list}
    Run Keyword If    ${modify_para_num}!=${0}    Modify Parameters with json    input_list=${input_list}
    Run Keyword If    ${unblock_num}!=${0}    BLock or UnBlock Cell And Check Status    block_flag=${False}
    ...   unblock_cell_id_list=${unblock_cell_list}    allowed_list=${allowed_list2}
    Common Case Teardown    bts_host=${gNB_ip}

Determine whether it is during the power saving period
    [Arguments]    ${week_day}=Sun    ${start_hour}=21    ${period_min}=30   ${connection}=GNB_SSH
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=date   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID_list}    Evaluate    re.findall(r'[a-zA-Z0-9:]+', '''${PID}''')    modules=re
    ${actual_week_day}    set variable    ${PID_list[0]}
    ${actual_time}    Set Variable    ${PID_list[3]}
    ${actual_time}    split string    ${actual_time}    :
    ${actual_hour}    set variable    ${actual_time[0]}
    ${actual_min}    set variable    ${actual_time[1]}
    ${result}     Run Keyword And Return Status    Run Keywords    Should Be Equal As Numbers    ${actual_hour}    ${start_hour}    AND
    ...    Should Be True    ${actual_min}<${period_min}    AND    Should Be Equal As Strings    ${actual_week_day}    ${week_day}
    [Return]    ${result}
    [Teardown]    ssh.disconnect    connection=${connection}

Check GNB on air except sleeping cell
    [Timeout]    20 min
    [Arguments]  ${expect_cell_id}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM     ${time}=2min    ${interval}=20
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    ${time}    ${interval}s    Verify all cells should be onair and sleeping cell is disable
    ...    expect_cell_id=${expect_cell_id}    connection=${connection}    timeout=${interval}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair and sleeping cell is disable
    [Documentation]    Description: verify all the cells status should be correct.
    [Arguments]    ${expect_cell_id}    ${cell_type}=nr  ${connection}=GNB_OAM    ${timeout}=20
    Log to console    Verify all cells are on air
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
       ${cell_id}  Set Variable    ${cell['globalCellId']}
       Run Keyword If    '${cell_id}'=='${expect_cell_id}'    Verify cell is sleeping    ${cell}    ${administrative_expected}
       ...    ELSE    Verify cell on air    ${cell}    ${administrative_expected}
    END

Verify cell on air
    [Arguments]    ${cell}    ${administrative_expected}
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
    ...      ${administrative_expected}
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
    Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
    ...   msg=Cell-${cell['physicalCellId']}'s availabilityStatus present, means cell is disable or degraded, please check.

Verify cell is sleeping
    [Arguments]    ${cell}    ${administrative_expected}
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
    ...      ${administrative_expected}
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    disabled
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}    off line

############# About UE #################
Get all UE pointer variable
    [Documentation]    Pixel range of X80 mobile phones
    ...                330b40af：（1530~1720）：1625
    ...                15be99f6：（1530~1720）：1625
    ...                ee5a4d5c：（1570~1770）：1670
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1660
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

X80 attach multi power ue
    [Timeout]    10min
    [Arguments]    ${ue_info_dict}    ${ue_type}=samsung
    log to console       Prepare UE
    ${ue_index_list}    Get From Dictionary    ${ue_info_dict}    ue_call_list
    FOR    ${item}   IN    @{ue_index_list}
        Run Keyword If    '${ue_info_dict['${item}']['ue_mode']}'=='X80'    Get all UE pointer variable
        power_ue.Prepare UE    ue_index=${item}    ue_type=${ue_type}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    attach_mode=5G_NSA   ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${item}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

Get Commercial UE Right IP
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=${connection}
    csn.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    csn.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    UE IP :${UE_IP}
    [Return]    ${UE_IP}

172 UE IP Start DL traffic UDP
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10    ${traffic}=10    ${process_num}=${1}
    ${UE_IP}    Get Commercial UE Right IP    ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}    connection=cygwin
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i 1 -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l 1024B -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

X80 start multi power ue traffic ul and dl
    [Documentation]    compare iperf_type=via_command  or  via_app
    [Arguments]    ${ue_info_dict}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung    ${duration}=6000
    log to console      Start traffic    console=yes
    ${ue_index_list}    Get From Dictionary    ${ue_info_dict}    ue_call_list
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ue_info_dict['${item}']['ul_throughput']}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ue_info_dict['${item}']['ul_port']}    process_num=${ue_info_dict['${item}']['ul_process_num']}   iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    172 UE IP Start DL traffic UDP
        ...    ue_index=${item}    DL_port=${ue_info_dict['${item}']['dl_port']}    time=${duration}
        ...    traffic=${ue_info_dict['${item}']['dl_throughput']}    process_num=${ue_info_dict['${item}']['dl_process_num']}
    END

X80 stop multi power ue traffic ul and dl
    [Arguments]    ${ue_info_dict}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    ${ue_index_list}    Get From Dictionary    ${ue_info_dict}    ue_call_list
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ue_info_dict['${item}']['ul_port']}
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ue_info_dict['${item}']['dl_port']}
    END

X80 detach multi power ue
    [Timeout]    6min
    [Arguments]    ${ue_info_dict}    ${ue_type}=samsung
    log to console      UE Detach    console=yes
    ${ue_index_list}    Get From Dictionary    ${ue_info_dict}    ue_call_list
    FOR    ${item}    IN    @{ue_index_list}
        Run Keyword If    '${ue_info_dict['${item}']['ue_mode']}'=='X80'    Get all UE pointer variable
        ...    ELSE    Get all Samsung pointer variable
        power_ue.UE Detach    ue_index=${item}    ue_type=${ue_type}
    END

X80 Stop Traffic and release UE
    [Arguments]    ${ue_info_dict}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    X80 stop multi power ue traffic ul and dl    ue_info_dict=${ue_info_dict}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    X80 detach multi power ue    ue_info_dict=${ue_info_dict}

UE attach And Start Traffic
    [Arguments]    ${ue_info_dict}    ${excpet_element_list}    ${block_flag}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    ${output_list}    Add Element To List    input_list=${all_cell_list}    excpet_element_list=${excpet_element_list}
    Set Suite Variable    ${output_list}
    Run Keyword If    ${block_flag}    AlarmWatchdog.add_allow_alarms    fault_id=49
    Run Keyword If    ${block_flag}    BLock or UnBlock Cell And Check Status    block_flag=${block_flag}    block_cell_id_list=${output_list}
    ...    allowed_list=${allowed_list1}    unblock_cell_id_list=${excpet_element_list}
    X80 attach multi power ue    ue_info_dict=${ue_info_dict}
    X80 start multi power ue traffic ul and dl    ue_info_dict=${ue_info_dict}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    [Return]    ${output_list}

############# About log #################
Collect Aasyslog
    [Arguments]    ${log_time}    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=${ignore_time}
    [Return]    ${log_path}

Check TP From Aasyslog
    [Arguments]    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0

Common Capture BIP log and download
    [Arguments]    ${target_dir}    ${duration}=3s    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${destination}=Local
    ...    ${nr_phy_cell_ids}=${None}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    sleep    ${duration}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    [Return]    ${full_log_path}

Covert Pcap To Pdml
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T pdml > ${output_file}
    Run    ${command}

Covert Pcap To txt
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T text > ${output_file}
    Run    ${command}

pdml entries should match
    [Arguments]      ${pdmlFile}     ${field_name}    ${attrib_value}    ${expect_value}
    [Documentation]      this KW matches the entry in the pdml file
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=${field_name}      attrib_name=show    attrib_value=${attrib_value}
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=${field_name}    attrib_name=showname
    should contain     ${attrib_values}[0]      ${expect_value}

Start Catch Trace Log
    [Arguments]    ${filename}   ${time}=3s    ${connection}=GNB_SSH
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Stop And Copy Log To UTE
    [Arguments]    ${filename}    ${time}=10s     ${connection}=GNB_SSH
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${Test_case_log_dir}/${filename}    connection=${connection}
    sleep    ${time}
    [Return]    ${Test_case_log_dir}/${filename}
    [Teardown]    ssh.disconnect    connection=${connection}

Capture TTI log
    [Timeout]    20min
    [Arguments]    ${tti_log}    ${filter}=None    ${log_time}=3    ${bts_ip}=${gNB_ip}    ${eth_port_on_ute}=eth0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${csv_path}    CB008927_common_keyword.Capture And Decode TTitrace Log    duration=${log_time}    filter=${filter}
    ...    eth_port_on_ute=${eth_port_on_ute}    log_dir=${tti_log}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Capture And Decode TTitrace Log
    [Documentation]    Migrate from ET
    [Arguments]    ${log_dir}=${Test_case_log_dir}/ttitrace_streaming/    ${collector_names}=l2stream3_ttitrace    ${duration}=3
    ...    ${filter}=None    ${eth_port_on_ute}=eth3
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    ...    l2_stream_configuration=${L2STREAM_L2_PS_CONFIG}
    Sleep    ${duration}s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}
    ${csv_file_path}    TTI_logs_Capture.Decode Ttitrace Logs    log_dir=${log_dir}    collector_names=${collector_names}
    ...    by_filter=${True}    except_filter=${False}    filter=${filter}
    [Return]    ${csv_file_path}

Copy TargetBD Xml From BTS
    [Arguments]     ${connection}=GNB_SSH
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    Log To Console    download file to local
    ${output}    ssh.execute    command=ls /ffs/run    connection=${connection}
    @{files}    Split String    ${output}    \n
    Log    ${files}
    ${file}    Get_TargetBD_file_name    input_list=${files}
    ssh.download_file    remote_path=/ffs/run/${file}    local_path=${output_dir}/${file}    connection=${connection}
    sleep    10s
    Set Suite Variable    ${TargetBD_file_path}    ${output_dir}/${file}
    log to console    ${TargetBD_file_path}
    [Teardown]    ssh.disconnect    connection=${connection}

############# Get GNB Counter #################
get_bts_counters
    [Arguments]    ${counter_ids}    ${counter_name_list}    ${NRCELL_ID}=${NRCELL1_ID}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_name_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${result}    Set Variable    ${counter_value['BTS']['${MRBTS_ID}']['${NRBTS_ID}']['${NRCELL_ID}']['${counter_name}']['${counter_id}']}
        Append To List    ${counter_value_list}    ${result}
    END
    [Return]    ${counter_value_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

############# Case Check Log #################
Add Element To List
    [Arguments]    ${input_list}    ${excpet_element_list}
    @{output_list}    Create List
    FOR    ${i}    IN   @{input_list}
        run keyword if    '${i}' not in @{excpet_element_list}    Append To List    ${output_list}    ${i}
    END
    [Return]    ${output_list}

Check value From Bip
    [Arguments]    ${log_path}    ${pcap_file}    ${numOfPdschSymbols}    ${filter}=dldata_pdschsendreq    ${field_name}=DlData_PdschGrant
    ${output_log}    Set Variable    ${log_path}/${pcap_file}
    ${pdml_path}    Set Variable    ${output_log}/${pcap_file}.pdml
    ${bip_cover_result}    Run Keyword And Return Status    Covert Pcap To Pdml    pcap_file=${output_log}/${pcap_file}.pcap
    ...   output_file=${pdml_path}    filter=${filter}
    ${rat0Bitmap_value}    Get_packet_info    file_path=${pdml_path}    field_name=${field_name}.rat0Bitmap
    ${numOfPdschSymbols_value}    Get_packet_info    file_path=${pdml_path}    field_name=${field_name}.numOfPdschSymbols
    ${check_rat0Bitmap_result}    Check_the_list_contains_zero_or_non_zero    value_list=${rat0Bitmap_value}    check_value=2
    Run Keyword And Continue On Failure     Should Be True    ${check_rat0Bitmap_result}
    Run Keyword And Continue On Failure    List Should Contain Value    ${numOfPdschSymbols_value}    ${numOfPdschSymbols}

Check BWP_ID From Tcpdump
    [Arguments]    ${file_path}    ${check_value}
    @{dl_field_list}    Create List    UEContextModificationResponse    DUtoCURRCInformation    BWP-Downlink    bwp-Id
    ${dl_bwp_value_list}    Get_Field_Value_From_Frame_Content    file_path=${file_path}    field_list=${dl_field_list}
    ${vaild_list1}    ${invaild_list1}    Check_list_Only_Contain_one_value    input_list=${dl_bwp_value_list}    check_value=1
    ${vaild_list2}    ${invaild_list2}    Check_list_Only_Contain_one_value    input_list=${dl_bwp_value_list}    check_value=2
    ${vaild_list1_len}    Get Length    ${vaild_list1}
    ${vaild_list2_len}    Get Length    ${vaild_list2}
    ${check_value1_result}    Run Keyword If    ${vaild_list1_len} > ${0} and ${vaild_list2_len} == ${0}    Set Variable    True
    ...    ELSE    Set Variable    False
    ${check_value2_result}    Run Keyword If    ${vaild_list1_len} > ${0} and ${vaild_list2_len} > ${0}    Set Variable    True
    ...    ELSE    Set Variable    False
    Run Keyword And Continue On Failure    Run Keyword If    ${check_value} == 1    Should Be True    ${check_value1_result}
    ...    ELSE        Should Be True    ${check_value2_result}

Common Case UE start Traffic
    [Arguments]    ${ue_info_dict}    ${tti_log_name}    ${excpet_element_list}=${empty_list}    ${block_flag}=${True}    ${log_time}=90s
    ...    ${sleep_time}=1s    ${ignore_time}=10s
    ${output_list}    UE attach And Start Traffic    ue_info_dict=${ue_info_dict}    excpet_element_list=${excpet_element_list}
    ...    block_flag=${block_flag}
    ${aasyslog_path}    Collect Aasyslog    log_time=${log_time}    ignore_time=${ignore_time}
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    sleep    ${sleep_time}
    [Return]    ${aasyslog_path}    ${csv_file_path}    ${output_list}
    [Teardown]    X80 Stop Traffic and release UE    ue_info_dict=${ue_info_dict}

Check Aasyslog And Get Value From TTI
    [Arguments]   ${nr_cell_list}    ${aasyslog_path}=none    ${tti_path}=none    ${exp_ul_tp}=130    ${exp_dl_tp}=160
    Run Keyword And Continue On Failure    CB008927_common_keyword.Check TP From Aasyslog    ul_list=${nr_cell_list}    dl_list=${nr_cell_list}
    ...    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    log_path=${aasyslog_path}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${rat0Bitmap_value_list}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${startPrb_value_list}    TTI_Stream.get_dlFdSchedData_startPrb_value    file_path=${dl_tti_file}
    ${rat0Bitmap_vaild_result}    ${rat0Bitmap_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${rat0Bitmap_value_list}    check_value=0
    ${startPrb_min_value}    Evaluate    min(${startPrb_value_list})
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${rat0Bitmap_invaild_len}    Get Length    ${rat0Bitmap_invaild_result}
    ${rat0Bitmap_vaild_len}    Get Length    ${rat0Bitmap_vaild_result}
    [Return]    ${startPrb_min_value}    ${rat0Bitmap_invaild_len}    ${rat0Bitmap_vaild_len}    ${bler}

Check Aasyslog And TTI
    [Arguments]    ${nr_cell_list}    ${aasyslog_path}    ${tti_path}    ${exp_ul_tp}=130    ${exp_dl_tp}=160    ${startPrb}=none
    ...    ${bler}=${1}    ${check_numOfPrb}=${False}    ${except_rat0Bitmap_invaild_len}=${0}    ${ssb_slot}=${False}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${startPrb_min_value}    ${rat0Bitmap_invaild_len}    ${rat0Bitmap_vaild_len}    ${act_bler}    Check Aasyslog And Get Value From TTI
    ...    nr_cell_list=${nr_cell_list}    aasyslog_path=${aasyslog_path}
    ...    tti_path=${tti_path}    exp_ul_tp=${exp_ul_tp}   exp_dl_tp=${exp_dl_tp}
    Run Keyword And Continue On Failure    Should Be True    ${rat0Bitmap_invaild_len}>${except_rat0Bitmap_invaild_len}
    Run Keyword And Continue On Failure    Should Be True    ${act_bler}<=${bler}
    Run Keyword If    '${startPrb}'!='none'    Run Keyword And Continue On Failure    Should Be True    ${startPrb_min_value}>=${startPrb}
    Run Keyword If    ${check_numOfPrb}    Check slot numOfPrb rrmDlUsedMcs Value    tti_path=${dl_tti_file}    ssb_slot=${ssb_slot}

Case 08 UE start Traffic
    [Arguments]    ${ue_info_dict}    ${excpet_element_list}    ${block_flag}
    ${output_list}    UE attach And Start Traffic    ue_info_dict=${ue_info_dict}    excpet_element_list=${excpet_element_list}
    ...    block_flag=${block_flag}
    CB008927_common_keyword.Common Capture BIP log and download    target_dir=${Test_case_log_dir}    target_file_name=l1l2bip_log
    ${aasyslog_path}    Collect Aasyslog    log_time=5m
    sleep    5min
    [Return]    ${aasyslog_path}    ${output_list}
    [Teardown]    X80 Stop Traffic and release UE    ue_info_dict=${ue_info_dict}

Case 08 check point
    [Arguments]    ${log_path}    ${pcap_file}   ${aasyslog_path}    ${befor_counter}    ${nr_cell_list}    ${NRCELL_ID}
    ...    ${exp_ul_tp}    ${exp_dl_tp}    ${numOfPdschSymbols}=14
    ${status}    Run Keyword And Return Status    Check value From Bip    log_path=${log_path}    pcap_file=${pcap_file}
    ...    numOfPdschSymbols=${numOfPdschSymbols}    filter=dldata_pdschsendreql1sw    field_name=DlData_PdschGrantL1sw
    Run Keyword If    ${status}==${False}    Check value From Bip    log_path=${log_path}    pcap_file=${pcap_file}
    ...    numOfPdschSymbols=${numOfPdschSymbols}    filter=dldata_pdschsendreq    field_name=DlData_PdschGrant
    CB008927_common_keyword.Check TP From Aasyslog    ul_list=${nr_cell_list}    dl_list=${nr_cell_list}    exp_ul_tp=${exp_ul_tp}
    ...    exp_dl_tp=${exp_dl_tp}    log_path=${aasyslog_path}
    ${after_counter}    get_bts_counters    counter_ids=M55335C02019    counter_name_list=${case8_counter_name}    NRCELL_ID=${NRCELL_ID}
    ${counter_value}    Case8_Count_counter_value    befor_counter=${befor_counter[0]}    after_counter=${after_counter[0]}
    Run Keyword And Continue On Failure     Should Be True    ${counter_value} > ${240000}

Case 07 check Bip And Tcpdump
    [Arguments]    ${tcpdump_name}   ${tcpdump_check_value}    ${aasyslog_path}    ${tti_path}    ${nr_cell_list}
    ...    ${exp_ul_tp}    ${exp_dl_tp}    ${log_path}=${Test_case_log_dir}
    Run Keyword And Continue On Failure    CB008927_common_keyword.Check TP From Aasyslog    ul_list=${nr_cell_list}    dl_list=${nr_cell_list}
    ...    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    log_path=${aasyslog_path}
    Covert Pcap To txt    pcap_file=${log_path}/${tcpdump_name}.pcap   output_file=${log_path}/${tcpdump_name}.txt    filter='f1ap || ngap'
    Check BWP_ID From Tcpdump    file_path=${log_path}/${tcpdump_name}.txt    check_value=${tcpdump_check_value}
    ${startPrb_min_value}    ${rat0Bitmap_invaild_len}    ${rat0Bitmap_vaild_len}    ${act_bler}    Check Aasyslog And Get Value From TTI
    ...    nr_cell_list=${nr_cell_list}    aasyslog_path=${aasyslog_path}
    ...    tti_path=${tti_path}    exp_ul_tp=${exp_ul_tp}   exp_dl_tp=${exp_dl_tp}
    Run Keyword And Continue On Failure    Should Be True    ${rat0Bitmap_vaild_len} > ${0}
    Run Keyword And Continue On Failure    Should Be True    ${rat0Bitmap_invaild_len} == ${0}

Case 07 UE start Traffic
    [Arguments]    ${multiue_config_direction}    ${excpet_element_list}    ${ul_tp_list}    ${tcpdump_name}    ${tti_log_name}    ${duration}
    ${output_list}    Add Element To List    input_list=${all_cell_list}    excpet_element_list=${excpet_element_list}
    Set Suite Variable    ${output_list}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    BLock or UnBlock Cell And Check Status    block_flag=${True}    block_cell_id_list=${output_list}
    ...    allowed_list=${allowed_list1}    unblock_cell_id_list=${excpet_element_list}
    Start Catch Trace Log    filename=${tcpdump_name}
    Start Traffic By Spark    ul_tp_list=${ul_tp_list}    if_ul=${True}    if_dl=${True}    duration=6000    process=${1}
    ...    multiue_config_direction=${multiue_config_direction}    ul_port_list=${ul_port_list}    get_spark_license=${False}
    ${file_path}    Stop And Copy Log To UTE    filename=${tcpdump_name}
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    ${aasyslog_path}    Collect Aasyslog    log_time=90s    ignore_time=10s
    sleep    ${duration}
    [Return]    ${aasyslog_path}    ${csv_file_path}   ${output_list}
    [Teardown]    Stop Traffic And Detach UE    if_ul=${True}    if_dl=${True}

Case 07 check Counter
    [Arguments]    ${befor_counter}    ${NRCELL_ID}
    sleep   5min
    ${after_counter}    get_bts_counters    counter_ids=M55138C00057,M55308C36003,M55308C36004
    ...    counter_name_list=${case7_counter_name}    NRCELL_ID=${NRCELL_ID}
    ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
    ${M55308C36003_zero_result}    ${M55308C36003_none_zero_result}    Check_list_Only_Contain_one_value
    ...    input_list=${all_counter_value_list[1]}    check_value=0
    ${M55308C36004_zero_result}    ${M55308C36004_none_zero_result}    Check_list_Only_Contain_one_value
    ...    input_list=${all_counter_value_list[2]}    check_value=0
    ${M55308C36003_none_zero_len}    Get Length    ${M55308C36003_none_zero_result}
    ${M55308C36004_none_zero_len}    Get Length    ${M55308C36004_none_zero_result}
   # ${M55308C36003_result}    Check_the_list_contains_zero_or_non_zero    value_list=${all_counter_value_list[1]}    check_value=2
   # ${M55308C36004_result}    Check_the_list_contains_zero_or_non_zero    value_list=${all_counter_value_list[2]}    check_value=2
    Run Keyword And Continue On Failure    List Should Contain Value    ${all_counter_value_list[0]}    ${4}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C36003_none_zero_len}>${0}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C36004_none_zero_len}>${0}

Case 05 Capture log And Check
    [Arguments]    ${exp_ul_tp}    ${exp_dl_tp}    ${tti_log_name}    ${nr_cell_list}    ${actDlDynSwitchAlloc}=${False}    ${bler}=${1}
    ${aasyslog_path}    Collect Aasyslog    log_time=1m
    CB008927_common_keyword.Check TP From Aasyslog    ul_list=${nr_cell_list}    dl_list=${nr_cell_list}    exp_ul_tp=${exp_ul_tp}
    ...    exp_dl_tp=${exp_dl_tp}    log_path=${aasyslog_path}
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=4
    ${dl_tti_file}    Get From Dictionary    ${csv_file_path}    DL
    ${dmrsConfigType_value_list}    TTI_Stream.get_dlFdSchedData_dmrsConfigType_value    file_path=${dl_tti_file}
    ${rat0Bitmap_value_list}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${act_bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${dmrsConfigType_vaild_result}    ${dmrsConfigType_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${dmrsConfigType_value_list}    check_value=TYPE2
    ${rat0Bitmap_vaild_result}    ${rat0Bitmap_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${rat0Bitmap_value_list}    check_value=0
    ${dmrsConfigType_invaild_len}    Get Length    ${dmrsConfigType_invaild_result}
    ${rat0Bitmap_invaild_len}    Get Length    ${rat0Bitmap_invaild_result}
    Run Keyword And Continue On Failure     Should Be True    ${dmrsConfigType_invaild_len}==${0}
    Run Keyword And Continue On Failure     Run Keyword If    ${actDlDynSwitchAlloc}==${False}    Should Be True    ${rat0Bitmap_invaild_len}==${0}
    Run Keyword And Continue On Failure     Run Keyword If    ${actDlDynSwitchAlloc}==${True}    Should Be True    ${rat0Bitmap_invaild_len}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${act_bler}<=${bler}

Check slot numOfPrb rrmDlUsedMcs Value
    [Arguments]    ${tti_path}    ${msc_value}=21    ${numOfPrb_value1}=184    ${numOfPrb_value2}=18    ${ssb_slot}=${False}
    ${slot_dict}    TTI_Stream.get_dlFdSchedData_slot_numOfPrb_rrmDlUsedMcs    file_path=${tti_path}
    ${slot0_msc_value_list}    ${slot0_numOfPrb_value_list1}    ${slot0_numOfPrb_value_list2}    Count_the_value_of_one_layers_list
    ...    input_list=${slot_dict['0']}    msc_value=${msc_value}    numOfPrb_value1=${numOfPrb_value1}    numOfPrb_value2=${numOfPrb_value2}
    ...    ssb_slot=${ssb_slot}
    ${slot1_msc_value_list}    ${slot1_numOfPrb_value_list1}    ${slot1_numOfPrb_value_list2}    Count_the_value_of_one_layers_list
    ...    input_list=${slot_dict['1']}    msc_value=${msc_value}    numOfPrb_value1=${numOfPrb_value1}    numOfPrb_value2=${numOfPrb_value2}
    ${slot0_msc_value_num}    Get Length    ${slot0_msc_value_list}
    ${slot1_msc_value_num}    Get Length    ${slot1_msc_value_list}
    ${slot0_numOfPrb_value1_num}    Get Length    ${slot0_numOfPrb_value_list1}
    ${slot0_numOfPrb_value2_num}    Get Length    ${slot0_numOfPrb_value_list2}
    ${diff_numOfPrb}    Evaluate    abs(${slot0_numOfPrb_value1_num}-${slot0_numOfPrb_value2_num})
    Run Keyword And Continue On Failure    Should Be True    ${slot0_msc_value_num}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${slot1_msc_value_num}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${slot0_numOfPrb_value1_num}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${slot0_numOfPrb_value2_num}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${diff_numOfPrb}<${20}

SA UE Attach on cell And Circular Flow
    [Arguments]    ${ue_info_dict}    ${interval_time}    ${count}
    X80 attach multi power ue    ue_info_dict=${ue_info_dict}
    FOR   ${i}  IN RANGE  ${count}
        ${tmp}    Evaluate    ${count}-${1}
        sleep    ${interval_time}
        X80 start multi power ue traffic ul and dl    ue_info_dict=${ue_info_dict}    if_ul=${True}    if_dl=${True}    duration=60
        ${csv_file_path}    Run Keyword If    ${i}==${tmp}    Capture TTI log    filter=dlFdSchedData|dlDtxOptimData|dlHarqRxDataArray
        ...    log_time=3    tti_log=${Test_case_log_dir}/ttitrace_streaming
        sleep    50s
    END
    [Return]    ${csv_file_path}

Case 10 UE start Traffic
    [Arguments]    ${excpet_element_list}    ${block_flag}
    ${output_list}    UE attach And Start Traffic    ue_info_dict=${case10_ue1_info}    excpet_element_list=${excpet_element_list}
    ...    block_flag=${block_flag}
    ${csv_file_path}    SA UE Attach on cell And Circular Flow    ue_info_dict=${case10_ue2_info}    interval_time=20s    count=${8}
    [Return]    ${csv_file_path}    ${output_list}
    [Teardown]    X80 Stop Traffic and release UE    ue_info_dict=${case10_ue3_info}

Case 10 Check TTI Log
    [Arguments]    ${tti_path}    ${dlDtxOptimEvent_value}=REMOVALUE
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${act_bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${dlDtxOptimEvent_dict}    TTI_Stream.get_dlDtxOptimData_dlDtxOptimEvent    file_path=${dl_tti_file}
    ${REMOVALUE_len}    Get From Dictionary    ${dlDtxOptimEvent_dict}    ${dlDtxOptimEvent_value}
    Run Keyword And Continue On Failure    Should Be True    ${act_bler}<${1}
    Run Keyword And Continue On Failure    Should Be True    ${REMOVALUE_len}>=${200}

Case 10 check Counter
    [Arguments]    ${befor_counter}    ${NRCELL_ID}
    ${after_counter}    get_bts_counters    counter_ids=M55308C33000,M55308C33001
    ...    counter_name_list=${case10_counter_name}    NRCELL_ID=${NRCELL_ID}
    ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
    ${M55308C33000_counter_list}    Set Variable    ${all_counter_value_list[0]}
    ${M55308C33001_counter_list}    Set Variable    ${all_counter_value_list[1]}
    ${M55308C33001_vaild_result}    ${M55308C33001_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${M55308C33001_counter_list}    check_value=${0}
    ${M55308C33001_invaild_len}    Get Length    ${M55308C33001_invaild_result}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C33000_counter_list[-1]}>${0}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C33001_invaild_len}>${0}

