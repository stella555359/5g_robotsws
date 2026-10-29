*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Resource    5GC000561_coam_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${PTP_SyncE_filter}    'ether proto 0x88f7||0x8809'
${PTP_filter}          'ether proto 0x88f7'

${msgid}     ptp.v2.messagetype
${sync_message}        ${msgid} == 0
${announce_message}    ${msgid} == 11
${followup_message}    ${msgid} == 8
${delayReq_message}    ${msgid} == 1
${delayResp_message}   ${msgid} == 9
${syncE_message}       ossp.esmc.event_flag == 0x00000000

${announce_flag}    ptp.v2.flags == 0x0000003c
${sync_flag}    ptp.v2.flags == 0x00000200

${check_ptp_announce}    ${announce_message} and
...                      ptp.v2.an.priority1 == 128 and
...                      ptp.v2.an.priority2 == 128 and
...                      ptp.v2.an.localstepsremoved == 0 and
...                      ptp.v2.an.origincurrentutcoffset == 37 and
...                      ptp.v2.timesource == 32 and
...                      ${announce_flag}

${check_ptp_sync}    ${sync_message} and
...                  ${sync_flag}

${clock_class}          ptp.v2.an.grandmasterclockclass
${clock_accuracy}       ptp.v2.an.grandmasterclockaccuracy
${clock_variance}       ptp.v2.an.grandmasterclockvariance
${ssm_value}            ossp.esmc.ql

${sourceportid}    ptp.v2.sourceportid
${clockidentity}    ptp.v2.clockidentity

@{status}    locked    holdover_in    holdover_out
&{eCpriMasterClockClass}    locked=6    holdover_in=7    holdover_out=150
&{eCpriMasterClockAccuracy}    locked=33    holdover_in=254    holdover_out=254
&{eCpriMasterOffsetScaledLogVariance}    locked=20061    holdover_in=65535    holdover_out=65535
&{ssmType_ITU}    eCpriMasterSsmType=SSM_ITU    eCpriMasterSsmValue=PRC    ql_value=0x2
&{ssmType_ANSI}    eCpriMasterSsmType=SSM_ANSI    eCpriMasterSsmValue=PRS    ql_value=0x1

${default_syncInputType}    1pps/ToD from external GNSS receiver

&{multicast_Address}    nonForwardable=01-80-C2-00-00-0E    Forwardable=01-1B-19-00-00-00
&{multicast_Address_filter}    nonForwardable=${check_nonForwardable_Address}    Forwardable=${check_Forwardable_Address}

${check_nonForwardable_Address}    eth.dst == 01:80:c2:00:00:0e
${check_Forwardable_Address}    eth.addr == 01:1b:19:00:00:00

${PTP_domainNumber_name}    ptp.v2.domainnumber

&{SyncMsgCounter}           id=M40102C0    countpermin=960
&{AnnounceMsgCounter}       id=M40102C1    countpermin=480
&{DelayRespMsgCounter}      id=M40102C2    countpermin=1920
&{DelayReqMsgCounter}       id=M40102C3    countpermin=1920
&{SyncEMsgCounter}          id=M40102C4    countpermin=60

${command_template}    {tshark_path} -r {pcap_file} -T pdml
${ptp_log}    ptp_561_A.pcap
${ptp_locked_log}    ptp_561_A_locked.pcap
${ptp_holdover_log}    ptp_561_A_holdover.pcap

${vm_tmp_log_dir}    /tmp
@{faults_list}       16    4298    1899    4405    4452    4681

*** Keywords ***
5GC000561 ABIO Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory for 561
    COAM Wait for gnb ready and cell setup and sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == '${EMPTY}'    add fault to the allowed fault list    faultId=${4681}
    AlarmWatchdog.add_allow_alarms    fault_id=${faults_list}

5GC000561 ABIO Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=${faults_list}
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    Run keyword and ignore error    ssh.Reset cache
    CI_interface.Common Case Teardown

Check Log in WebUI for SSM and PTP
    [Arguments]    ${status}    &{ssmType}
    ${clockAccuracy}    Convert To Hex    ${eCpriMasterClockAccuracy}[${status}]   lowercase=yes
    ${logVariance}    Convert To Hex    ${eCpriMasterOffsetScaledLogVariance}[${status}]   lowercase=yes
    Coam Check Parameter via webUI    expected_val=${eCpriMasterClockClass}[${status}]
    ...                               dist_name=${PARAM_561_013[2]}[dist_name]
    ...                               filter_param=${PARAM_561_013[2]}[filter_param]
    ...                               p_name=${PARAM_561_013[2]}[p_name]
    Coam Check Parameter via webUI    expected_val=${ssmType}[eCpriMasterSsmType]
    ...                               dist_name=${PARAM_561_013[0]}[dist_name]
    ...                               filter_param=${PARAM_561_013[0]}[filter_param]
    ...                               p_name=${PARAM_561_013[0]}[p_name]
    Coam Check Parameter via webUI    expected_val=${ssmType}[eCpriMasterSsmValue]
    ...                               dist_name=${PARAM_561_013[1]}[dist_name]
    ...                               filter_param=${PARAM_561_013[1]}[filter_param]
    ...                               p_name=${PARAM_561_013[1]}[p_name]
    Coam Check Parameter via webUI when lowercase    expected_val=${clockAccuracy}
    ...                               dist_name=${PARAM_561_013[3]}[dist_name]
    ...                               filter_param=${PARAM_561_013[3]}[filter_param]
    ...                               p_name=${PARAM_561_013[3]}[p_name]
    Coam Check Parameter via webUI when lowercase    expected_val=${logVariance}
    ...                               dist_name=${PARAM_561_013[4]}[dist_name]
    ...                               filter_param=${PARAM_561_013[4]}[filter_param]
    ...                               p_name=${PARAM_561_013[4]}[p_name]

Check Log in Wireshark Log for SSM and PTP
    [Arguments]    ${file_name}    ${status}    &{ssmType}
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log for a While from RU for DomainNumber    filename=${file_name}    time=30s    filter=${PTP_SyncE_filter}
    Check Message Rate    filename=${file_name}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${followup_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
    Check Message Rate    filename=${file_name}    filter=${syncE_message}     min_rate=0.9    max_rate=1.1
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
    ...                          ${check_ptp_announce}
    ...                          ${clock_class}==${eCpriMasterClockClass}[${status}]
    ...                          ${clock_accuracy}==${eCpriMasterClockAccuracy}[${status}]
    ...                          ${clock_variance}==${eCpriMasterOffsetScaledLogVariance}[${status}]
    Check expression in Bip Log by Name    filter_expression=${expression}    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${check_ptp_sync}    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${ssm_value}==${ssmType}[ql_value]    field_name=${ssm_value}

Check Log in Locked State
    [Arguments]    ${file_name}    &{ssmType}
    Check Log in WebUI for SSM and PTP    status=${status}[0]    &{ssmType}
    Check Log in Wireshark Log for SSM and PTP    file_name=${file_name}    status=${status}[0]    &{ssmType}

Check Synchronization status is Holdover state in WebUI
    [Arguments]    ${connection}=GNB_OAM
    ${sync_source_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_state}    Set variable    ${sync_source_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_state[0]}
    Should be equal as strings    ${sync_source_info['syncMode']}    PhaseSync
    Should be equal as strings    ${sync_source_info['tuningMode']}    Adaptive holdover

Check Log in Holdover and Phase Error within specification
    [Arguments]    ${file_name}    &{ssmType}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_SYNCIN_2048}
    wait until keyword succeeds    5min    1min    Check Synchronization status is Holdover state in WebUI
    ${phase_error}    get Phase error value
    Run Keyword If     ${phase_error} <= ${1325}
    ...         Check Log in Wireshark Log for SSM and PTP    file_name=${file_name}    status=${status}[1]    &{ssmType}
    ...     ELSE     Check Log in Wireshark Log for SSM and PTP    file_name=${file_name}    status=${status}[2]    &{ssmType}
    ${phase_error}    get Phase error value
    Run Keyword If     ${phase_error} <= ${1325}
    ...         Check Log in WebUI for SSM and PTP    status=${status}[1]    &{ssmType}
    ...    ELSE      Check Log in WebUI for SSM and PTP    status=${status}[2]    &{ssmType}

get Phase error value
    ${phase_error}    Check Phase error Alarm in DU
    ${phase_error}    Strip String    ${phase_error}    right    /r/n
    ${phase_error}    Convert To Number    ${phase_error}
    ${phase_error}    Evaluate    abs(${phase_error})
    [Return]     ${phase_error}

Check TOP Alarm Raised in COAM
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    ${expect_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
        Run Keyword If    ${alarm['faultId']} == 16    Should Be Equal    ${alarm['alarmName']}    BASE STATION SERVICE PROBLEM
        ...    ELSE IF    ${alarm['faultId']} == 4298    Should Be Equal    ${alarm['alarmName']}    BASE STATION SYNCHRONIZATION PROBLEM
        ...       ELSE    Continue For Loop
        Append To List    ${expect_alarms}   ${alarm}
    END
    ${alarm_num}   Get Length   ${expect_alarms}
    Should Be Equal    ${alarm_num}    ${2}

Verify ENV is Recovered
    [Arguments]    ${listen_port}=ecpri1
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Capture Wireshark Log for a While from RU for DomainNumber    filename=ptp_recover.pcap
    ...                                                           time=10
    ...                                                           filter=${PTP_SyncE_filter}
    ...                                                           listen_port=${listen_port}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/ptp_recover.pcap
    ...                                                 command_template=${command_template}
    ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
    ...                          ${check_ptp_announce}
    ...                          ${clock_class}==${eCpriMasterClockClass}[locked]
    ...                          ${clock_accuracy}==${eCpriMasterClockAccuracy}[locked]
    ...                          ${clock_variance}==${eCpriMasterOffsetScaledLogVariance}[locked]
    Check expression in Bip Log by Name    filter_expression=${expression}    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/ptp_recover.pcap
    ...                                                 command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${check_ptp_sync}    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/ptp_recover.pcap
    ...                                                 command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${ssm_value}==${ssmType_ITU}[ql_value]    field_name=${ssm_value}

Check Phase error Alarm in DU
    Connect to Common Unit Master
    ${phase_error}    csn.execute
    ...    command=/opt/hwmt/python/SendOMMessage.py -s 0x04dc -d HWASYNC-1/TUNER-1 --proto SYNC/tuner -t query|grep phaseError:|awk '{print$2}'
    ...    connection=ASIK Master
    [return]    ${phase_error}

Phase error below 100ns
    ${phase_error}    Check Phase error Alarm in DU
    ${phase_error}    Strip String    ${phase_error}    right    /r/n
    ${phase_error}    Convert To Number    ${phase_error}
    ${phase_error}    Evaluate    abs(${phase_error})
    Should Be True    ${phase_error} < ${100}

Recover ENV syncInputType
    [Arguments]    ${listen_port}=ecpri1
    Run Keyword And Ignore Error    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_013_RECOVER_ENV}
    COAM Wait for gnb ready and cell setup and sync status
    Log to Console    check phase error
    wait until keyword succeeds    10min    1min    Phase error below 100ns
    Verify ENV is Recovered    listen_port=${listen_port}

Check Multicast Address
    [Arguments]    ${tx_flag}    ${rx_flag}
    Check Multicast Address for TX Packets    flag=${tx_flag}
    Check Multicast Address for RX Packets    flag=${rx_flag}

Check Multicast Address for TX Packets
    [Arguments]    ${flag}    ${file_name}=${ptp_log}
    Coam Check Parameter via webUI    expected_val=${multicast_Address}[${flag}]
    ...                               dist_name=${PARAM_561_MASTER_MULTICASTADDRESS[0]}[dist_name]
    ...                               filter_param=${PARAM_561_MASTER_MULTICASTADDRESS[0]}[filter_param]
    ...                               p_name=${PARAM_561_MASTER_MULTICASTADDRESS[0]}[parameter]
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${sync_message} and ${multicast_Address_filter}[${flag}]
    ...                                    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${followup_message} and ${multicast_Address_filter}[${flag}]
    ...                                    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${announce_message} and ${multicast_Address_filter}[${flag}]
    ...                                    field_name=${msgid}
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${delayResp_message} and ${multicast_Address_filter}[${flag}]
    ...                                    field_name=${msgid}

Check Multicast Address for RX Packets
    [Arguments]    ${flag}    ${file_name}=${ptp_log}
    Coam Check Parameter via webUI    expected_val=${multicast_Address}[${flag}]
    ...                               dist_name=${PARAM_561_Slave_MULTICASTADDRESS[0]}[dist_name]
    ...                               filter_param=${PARAM_561_Slave_MULTICASTADDRESS[0]}[filter_param]
    ...                               p_name=${PARAM_561_Slave_MULTICASTADDRESS[0]}[parameter]
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                                 command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${delayReq_message} and ${multicast_Address_filter}[${flag}]
    ...                                    field_name=${msgid}

Change Multicast Address and Check
    [Arguments]    ${multi_addr_param}    ${tx_flag}    ${rx_flag}
    ${multi_addr_param[0]}    Run Keyword If    '${multi_addr_param[0]}[parameter]' == 'eCpriMasterEthMulticastAddress'
    ...                            Set To Dictionary    ${multi_addr_param[0]}    value=${multicast_Address}[${tx_flag}]
    ...                    ELSE    Set To Dictionary    ${multi_addr_param[0]}    value=${multicast_Address}[${rx_flag}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${multi_addr_param}
    Connect to Common Unit Master
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log for a While from RU for DomainNumber    filename=${ptp_log}    time=10s    filter=${PTP_filter}
    Check Multicast Address    tx_flag=${tx_flag}    rx_flag=${rx_flag}

Check DomainNumber in the Log
    [Arguments]    ${domainNumber}    ${file_name}=${ptp_log}    ${listen_port}=ecpri1
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log for a While from RU for DomainNumber    filename=${file_name}    filter=${PTP_filter}    listen_port=${listen_port}
    Coam Check Parameter via webUI    expected_val=${domainNumber}
    ...                               dist_name=${PARAM_561_DOMAINNUMBER[0]}[dist_name]
    ...                               filter_param=${PARAM_561_DOMAINNUMBER[0]}[filter_param]
    ...                               p_name=${PARAM_561_DOMAINNUMBER[0]}[p_name]
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${announce_message} and ${PTP_domainNumber_name} == ${domainNumber}
    ...                                    field_name=${msgid}

Check Error for DomainNumber
    [Arguments]    ${error}
    ${error}    convert to string    ${error}
    Should Contain    ${error}    eCpriMasterDomainNumber

Change DomainNumber and Check DomainNumber in Log
    [Arguments]    ${domainNumber}    ${need_active}=${True}
    ${error}    Coam Change Parameter via webUI    expected_val=${domainNumber}
    ...                                            dist_name=${PARAM_561_DOMAINNUMBER[0]}[dist_name]
    ...                                            filter_param=${PARAM_561_DOMAINNUMBER[0]}[filter_param]
    ...                                            p_name=${PARAM_561_DOMAINNUMBER[0]}[p_name]
    ...                                            need_active=${need_active}
    Connect to Common Unit Master
    Run Keyword If    ${need_active}    Check DomainNumber in the Log    domainNumber=${domainNumber}
    run keyword if  not 23 < ${domainNumber} < 44    Check Error for DomainNumber    error=${error}

Check the PM counter for DelayReq and DelayRsp Msg
    ${delay_request}    COAM Get Transport Counters via webUI    counter_id=${DelayReqMsgCounter}[id]
    ${delay_reqt}    Get Dictionary Values    ${delay_request}
    @{delay_req}    Get Slice From List    ${delay_reqt}    1
    ${delay_response}    COAM Get Transport Counters via webUI    counter_id=${DelayRespMsgCounter}[id]
    ${delay_resp}    Get Dictionary Values    ${delay_response}
    @{delay_rsp}    Get Slice From List    ${delay_resp}    1
    ${length}    Get Length    ${delay_req}
    FOR    ${item}    IN RANGE    ${length}-1
            Should Be True     ${delay_req}[${item}]==${delay_rsp}[${item}]
    END

Check the PM counter xml report
    [Arguments]    ${PM_counter}    ${exp_result}=0
    ${min}    Evaluate    ${exp_result}-2
    ${max}    Evaluate    ${exp_result}+2
    ${pm_cnt}    COAM Get Transport Counters via webUI    counter_id=${PM_counter}
    ${pm_cnt}    Get Dictionary Values    ${pm_cnt}
    Should Be True     ${pm_cnt}[0] < ${max}
    Should Be True     ${pm_cnt}[1] < ${max}
    ${pm_cnt}    Get Slice From List    ${pm_cnt}    2
    FOR    ${item}    IN    @{pm_cnt}
            Should Be True     ${min} < ${item} < ${max}
    END

Get eCpriMasterStatisticsInterval accord to release
    ${ci_var_dict}    CI_commssion._Set Variables For Test
    Set Test variable       ${release}     ${ci_var_dict}[stream]
    run keyword if     '${release}' == 'SBTS23R3'
    ...                                                                 Get eCpriMasterStatisticsInterval for old
    ...       ELSE IF    '${release}' == 'SBTS23R4'         Get eCpriMasterStatisticsInterval for old
    ...       ELSE IF    '${release}' == 'SBTS24R1'         Get eCpriMasterStatisticsInterval after 24R2
    ...       ELSE                                                      Get eCpriMasterStatisticsInterval after 24R2

Get eCpriMasterStatisticsInterval after 24R2
    ${interval}    Get eCpriMasterStatisticsInterval for new
    Set suite variable    ${interval}    ${interval}

Get eCpriMasterStatisticsInterval for old
    ${interval}    Get eCpriMasterStatisticsInterval
    Set suite variable    ${interval}    ${interval}

Get eCpriMasterStatisticsInterval for new
    ${interval}    Coam Get Parameter via webUI    dist_name=${PARAM_561_INTERVAL_OTHER[0]}[dist_name]
    ...                                            filter_param=${PARAM_561_INTERVAL_OTHER[0]}[filter_param]
    ...                                            p_name=${PARAM_561_INTERVAL_OTHER[0]}[p_name]
    ${interval}    Strip String    ${interval}    characters=min
    ${interval}    convert to integer    ${interval}
    [return]    ${interval}

Get eCpriMasterStatisticsInterval
    ${interval}    Coam Get Parameter via webUI    dist_name=${PARAM_561_INTERVAL[0]}[dist_name]
    ...                                            filter_param=${PARAM_561_INTERVAL[0]}[filter_param]
    ...                                            p_name=${PARAM_561_INTERVAL[0]}[p_name]
    ${interval}    Strip String    ${interval}    characters=min
    ${interval}    convert to integer    ${interval}
    [return]    ${interval}

Check SourcePortIdentity from mac address EUI_48 to EUI_64
    [Arguments]    ${filename}
    Connect to Common Unit Master
    ${EUI_64}    csn.execute
    ...          command=ifconfig ethlmp0|grep ether|awk '{print$2}'|sed -e 's/://g' -e 's/....../0x&fffe/'|xargs echo -n
    ...          connection=${asik}
    ${ptp_command}   set variable   {tshark_path} -r {pcap_file} -Y \"${sourceportid}==19 and ${clockidentity}==${EUI_64}\" -T pdml
    ${filtered_packets}    Load pcap with filter    pcap_file=${tmp_log_dir}/${filename}
    ...    filter_expression=${sourceportid}==19 and ${clockidentity}==${EUI_64}    command_template=${ptp_command}
    ${items}   pcap.get_field_value_by_name    field_name=ptp.v2.clockidentity    attribute_name=show
    should not be empty     item=${items}     msg=check clockidentity exist failed!

Check for unexpected alarms
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
