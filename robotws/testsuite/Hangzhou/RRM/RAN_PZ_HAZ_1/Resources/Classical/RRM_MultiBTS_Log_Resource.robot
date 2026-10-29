*** Settings ***
Documentation
...    author: winnie he
...    contact: winnie.he@nokia-sbell.com
...    multi bts log resource
Resource          RRM_MultiBTS_Common_Resource.robot
Library           taf.pdu    WITH NAME    pdu


*** Variables ***
${ONAIR_MAX_DURATION}            40min
${LANIP}                         192.168.255.126
${CALIBRATE_WAIT}                10
${BTSLOG_TIMESTAMP_EXP_STRING_WITH_ANGLE_BRACKET}    <20\\d{2}-[0-1]?\\d-[0-3]?\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+Z>
${TIMESTAMP_EXP_STRING}          20\\d{2}-[0-1]?\\d-[0-3]?\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+Z
@{COLUMN_NAME}                   DlData_PdschSendReq.PdschSendReq.sfn    DlData_PdschSendReq.PdschSendReq.slot
...                              DlData_PdschSendReq.grants_item_0.numOfPrb
...                              DlData_SsBlockSendReq.SsBlockSendReq.sfn    DlData_SsBlockSendReq.SsBlockSendReq.slot
...                              DlData_CsiRsSendReq.CsiRsSendReq.sfn    DlData_CsiRsSendReq.CsiRsSendReq.slot
*** Keywords ***
#-------------------Syslog---------------------------------------------------------------------------------
Prepare BTSLite For Btslog
    Connect All VM
    Prepare BTSLite On Local
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Keyword If    '${REMOTE_MODE}'!='${TRUE}'
        ...    Continue For Loop If    ${i}==${0}
        Prepare BTSLite On Remote VM${i}
    END

Prepare BTSLite On Local
    ${exist_btslite}    csn.File Exists
    ...    ${BTSLITE_INFO.local_path}    connection=BTS0_VM
    Return From Keyword If    ${exist_btslite}
    csn.Execute    wget -P ~/ http://sw1.tc.china.nsn-net.net/build/tools/TA/BTSLite
    ...    connection=BTS0_VM
    csn.execute    command=chmod u+x ${BTSLITE_INFO.local_path}
    ...    connection=BTS0_VM
    ${ret}    csn.execute    command=cd ${BTSLITE_INFO.local_path};ls -l
    ...    connection=BTS0_VM
    Should Contain    ${ret}    BTSLite

Prepare BTSLite On Remote VM${vm_index}
    ${file_exist}    csn.file_exists    remote_path=${BTSLITE_INFO.local_path}
    ...    connection=BTS${vm_index}_VM
    csn.execute    command=ps -ef|grep BTSLite | awk '{print $2}' |xargs kill -9
    ...    connection=BTS${vm_index}_VM
    Return From Keyword If    ${file_exist}
    csn.upload_file    local_path=${BTSLITE_INFO.local_path}
    ...    remote_path=${BTSLITE_INFO.local_path}    connection=BTS${vm_index}_VM
    csn.execute    command=chmod u+x ${BTSLITE_INFO.local_path}
    ...    connection=BTS${vm_index}_VM

Start BTSLite For Btslog On VM
    [Arguments]    ${vm_index}=0    ${btslog_save_path}=${TEST_LOG_DIRECTORY}
    ...    ${btslog_read_path}=${TEST_LOG_DIRECTORY}    ${btslog_name}=syslog.log
    Run Keyword And Ignore Error    Stop BTSLite For Btslog On VM${vm_index}
    ${btslog_process}   Create List    btslog    BTSLite
    Kill Process    ${btslog_process}    connection=BTS${vm_index}_VM
    Log to Console    clear btslog enviroment done.
    csn.send_command    command=nohup ${BTSLITE_INFO.local_path} -dir ${btslog_save_path} -name ${btslog_name} &>/dev/null &
    ...    connection=BTS${vm_index}_VM
    Set Suite Variable    ${BTS${vm_index}_LOG_PATH}    ${btslog_read_path}${/}${btslog_name}

Stop BTSLite For Btslog On VM${vm_index}
    csn.execute    command=ps -ef|grep BTSLite | awk '{print $2}' |xargs kill -9
    ...    connection=BTS${vm_index}_VM
    ${ret}    csn.execute    command=ps -ef|grep BTSLite
    ...    connection=BTS${vm_index}_VM
    Log    ${ret}
    Should Not Contain    ${ret}    ./BTSLite

Stop All BTSLog And Download to Local
    [Arguments]    ${btslog_path}=${TEST_LOG_DIRECTORY}
    Log    ${btslog_path} is not used
    Run Keyword And Ignore Error    Connect All VM
    Run Keyword If    '${REMOTE_MODE}'!='${TRUE}'    Stop BTSLite For Btslog On VM0
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Keyword If    '${REMOTE_MODE}'!='${TRUE}'    Continue For Loop If    ${i}==${0}
        Stop BTSLite For Btslog On VM${i}
        ${btslog_path_list}    Split String    ${BTS${i}_LOG_PATH}    ${/}
        Log To Console
        ...    sshpass -p ${BTS_PC_INFO.PASSWORD} scp ${BTS_PC_INFO.USERNAME}@${BTS${i}_PC_INFO.Host}:${BTS${i}_LOG_PATH} ${TEST_LOG_DIRECTORY}
        Run Keyword If    '${REMOTE_MODE}'=='${TRUE}'    OperatingSystem.Run
        ...    sshpass -p ${BTS_PC_INFO.PASSWORD} scp ${BTS_PC_INFO.USERNAME}@${BTS${i}_PC_INFO.Host}:${BTS${i}_LOG_PATH} ${TEST_LOG_DIRECTORY}
        ...    ELSE
        ...    OperatingSystem.Run
        ...    scp ${BTS_PC_INFO.USERNAME}@${BTS${i}_PC_INFO.Host}:${BTS${i}_LOG_PATH} ${TEST_LOG_DIRECTORY}
        csn.File Exists    ${TEST_LOG_DIRECTORY}${/}${btslog_path_list[-1]}    connection=BTS0_VM
        Set Suite Variable    ${BTS${i}_LOG_PATH}    ${TEST_LOG_DIRECTORY}${/}${btslog_path_list[-1]}
    END

Get TimeStamp From BtsLog Line
    [Arguments]    ${btslog_line}
    ${matches}    Get Regexp Matches    ${btslog_line}    ${BTSLOG_TIMESTAMP_EXP_STRING_WITH_ANGLE_BRACKET}
    ${matches}    Get Regexp Matches    ${matches}[0]    ${TIMESTAMP_EXP_STRING}
    Remove String Using Regexp    ${matches}[0]    [A-Z]+
    ${btslog_timestamp}    Convert Date    ${matches}[0]
    [Return]    ${btslog_timestamp}

Start Multi Bts Log
    Prepare BTSLite For Btslog
    ${log_start_time}    Get TimeStamp With Date
    Run Keyword If    '${REMOTE_MODE}'!='${TRUE}'
    ...    Start BTSLite For Btslog On VM    vm_index=0    btslog_name=syslog_${log_start_time}.log
    FOR    ${i}    IN RANGE    ${vm_count}
        Run Keyword If    '${REMOTE_MODE}'!='${TRUE}'    Continue For Loop If    ${i}==${0}
        Start BTSLite For Btslog On VM    vm_index=${i}    btslog_read_path=${BTSLITE_INFO.btslog_read_path}
        ...    btslog_save_path=${BTSLITE_INFO.btslog_save_path}
        ...    btslog_name=remote_bts${i}_syslog_${log_start_time}.log
    END

Start Local Bts Log
    Prepare BTSLite On Local
    Start BTSLite For Btslog On VM    vm_index=0    btslog_name=syslog_${log_start_time}.log

#-------------------Aasyslog---------------------------------------------------------------------------------
ReStart aasyslog
    [Documentation]    Author: He winnie
	...                restart aasyslog
    [Arguments]    ${gnb_index}=${0}    ${du_index}=0    ${log_name}=5Grach.txt    &{kwargs}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
#    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=${log_name}

#-------------------Snapshot---------------------------------------------------------------------------------
Collect Coam Snapshot For One GNB
    [Arguments]        ${gnb_index}=0    ${name}=gnb_coam_snapshot     ${coverage}=Full    ${force}=${True}     ${timeout}=900    ${port}=443
    [Documentation]     Author: He winnie
	...                Collects the snapshot files to the default path.
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: gnb_coam_snapshot
    Log    ${timeout} is not used
    COAM_Admin.Login    bts_host=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    bts_port=${port}
    ...    alias=snapshot_bts${gnb_index}
    coam.Get Snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${name}.zip    coverage=${coverage}    force=${force}
    ...    connection=snapshot_bts${gnb_index}    timeout=600
    [Teardown]    COAM_Admin.Logout    connection=snapshot_bts${gnb_index}

    # coam.Get Snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${name}.zip    coverage=Full    force=True    connection=${coam_connection}

#-------------------dcap---------------------------------------------------------------------------------
Start Multi Dcap Log
    FOR    ${i}    IN RANGE    ${1}
        dcap.Connect To    bts_s1_ip=${BTS${i}_INFO.IP}    mrBtsId=${BTS${i}_INFO.MRBTSID}
        ...    bts_type=lte
        ...    url_ip=${DCAP_BASE_URL}
        ...    alias=dcap_${BTS${i}_INFO.MRBTSID}
        ${trace_profile}    dcap.Get Trace Profile Id List    connection=dcap_${BTS${i}_INFO.MRBTSID}
        ${trace_id}    dcap.Start Trace    trace_profile=${trace_profile[0]}    tag=ta_${BTS${i}_INFO.MRBTSID}
        ...    connection=dcap_${BTS${i}_INFO.MRBTSID}
        Set Test Variable    ${${BTS${i}_INFO.MRBTSID}_TRACEID}    ${trace_id}
    END
    dcap.get_trace_info_by_id    trace_id=${${BTS${i}_INFO.MRBTSID}_TRACEID}    connection=dcap_${BTS${i}_INFO.MRBTSID}
Stop All Dcap Log
    FOR    ${i}    IN RANGE    ${1}
        dcap.Stop Trace    connection=dcap_${BTS${i}_INFO.MRBTSID}
        dcap.Get Result File    target_dir=${TEST_LOG_DIRECTORY}
        ...    file_name=dcap_${BTS${i}_INFO.MRBTSID}_log.zip
        ...    connection=dcap_${BTS${i}_INFO.MRBTSID}
        ${${BTS${i}_INFO.MRBTSID}_LOG_PATH}    dcap.Unzip Result File Return Paths
        ...    zipfilepath=${TEST_LOG_DIRECTORY}${/}dcap_${BTS${i}_INFO.MRBTSID}_log.zip
        ...    connection=dcap_${BTS${i}_INFO.MRBTSID}
    END

#-------------------bip---------------------------------------------------------------------------------
Start Bip Capture On Remote Bts
    [Arguments]    ${bip_log_store_path}=${TEST_LOG_DIRECTORY}
    ...    ${dest_ip}=${ASIB_IP}
    gnb_tool.prepare_gnb_tool
    gnb_tool.start_to_capture_bip_log_with_gnb_tool    log_dire=${bip_log_store_path}
    ...    dest_ip=${dest_ip}

Stop Bip Capture On Remote Bts
    ${zip_bip_log_path}    gnb_tool.stop_bip_log_with_gnb_tool
    ${bip_log_store_path}    Replace String    ${zip_bip_log_path}    .zip    ${EMPTY}
    ${zip_bip_file}    Split String From Right    ${zip_bip_log_path}    /    1
    ${ret}    OperatingSystem.Run
    ...    command=cd ${zip_bip_file}[0];unzip ${zip_bip_file}[-1]
    ${files}    Get All File With Expect Suffix    ${bip_log_store_path}/bip    pcap
    Should Not Be Empty    ${files}
    # @{csv_title_list}=    Create List    DlData_PdschGrant.numOfDmrsCdmGroupWithoutData    DlData_PdschGrant.mcs
    ${bip_file_path}    Replace String    ${files}[0]    ${TEST_LOG_DIRECTORY}    ${EMPTY}
    Convert BIP To CSV By MCShark Without Filter    bip_file=${bip_file_path}    output_file=${TEST_LOG_DIRECTORY}/bipfile.csv
    ...    csv_title_list=${COLUMN_NAME}

Convert BIP To CSV By MCShark Without Filter
    [Arguments]    ${bip_file}    ${output_file}    ${csv_title_list}
    [Documentation]    This kw is used to Convert BIP To CSV By MCShark
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bip_file | Yes | bip file name which is colleted |
    ...    | output_file | Yes | the path of csv file is stored |
    ...    | csv_title_list | Yes | csv file list |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | ${name}.pcap | ${TEST_LOG_DIRECTORY}/csv_${name}.csv | ${filter} | ${csv_title_list} |
    ...
    Prepare MCShark Files
    ${csv_title}=    Set Variable
    FOR    ${column}    IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${TEST_LOG_DIRECTORY}/${bip_file} -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Convert BIP To CSV By MCShark New
    [Arguments]    ${bip_file}    ${filter}    ${csv_title_list}    ${output_file}=${TEST_LOG_DIRECTORY}/bip.csv
    ...    ${T_param}=fields
    [Documentation]    This kw is used to Convert BIP To CSV By MCShark
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bip_file | Yes | bip file name which is colleted |
    ...    | output_file | Yes | the path of csv file is stored |
    ...    | filter | Yes | What is used to filter messages |
    ...    | csv_title_list | Yes | csv file list |
    ...    | T_param | Yes | use for tshark file output format,options: fields, pdml,txt
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | ${name}.pcap | ${TEST_LOG_DIRECTORY}/csv_${name}.csv | ${filter} | ${csv_title_list} |
    ...
    Prepare MCShark Files
    ${csv_title}    Run Keyword If    '${T_param}'=='fields'    Set Variable
    ...    -e _ws.col.No. -e _ws.col.Info
    ...    ELSE    Set Variable    ${EMPTY}
    FOR    ${column}    IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T ${T_param}
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Get Match List From BIP Csv File
    [Arguments]    ${bip_csv_log}    ${check_point_regexp}
    [Documentation]    This keyword is to get match list from bip csv log with the specified regexp.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_csv_log} | Yes | the file path for bip csv log |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...
    ...    Examples:
    ...    | ${dl_check_point_regexp} | Set Variable | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    ...    | Get Match List From BIP Csv File | /home/ute/tcpdumpL2L1_filtering_off_dl_nack.csv | ${dl_check_point_regexp} |
    ...
    Log To Console    \nGet Match List From BIP Csv File...
    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
    @{group_list}    Get Regexp Group List    ${check_point_regexp}
    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${check_point_regexp}    @{group_list}
    [Return]    @{match_list}

Get Regexp Group List
    [Arguments]    ${check_point_regexp}
    [Documentation]    This keyword is to get group name form the specified regexp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...
    ...    Examples:
    ...    | @{group_list} | Get Regexp Group List | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    ...
    @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>    1
    [Return]    @{group_list}
# for test
# Verify Single UE PDSCH Schedule In SSB Slot
#     [Arguments]       ${BIP_CSV_LOG}
#     ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_SSB_REGEXP}
#     Should Not Be Empty    ${matches}
#     ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
#     ${CHECK_PDSCH_PRB_REGEXP}     Set Variable
#     ...        DlData_PdschSendReq.*?(?P<sfn>${matches[1][0]}).*?(?P<slot>0x00000010).*?(?P<numOfPrb>0x\\w+).*?
#     ${PDSCH}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_PRB_REGEXP}   numOfPrb
#     ${PDSCH}     Run Keyword    hex to oct    ${PDSCH[0]}
#     FOR   ${item}   IN   @{matches}
#           ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}     Set Variable
#           ...        DlData_PdschSendReq.*?(?P<sfn>${item[0]}).*?(?P<slot>${item[1]}).*?(?P<numOfPrb>0x\\w+).*?
#           ${PDSCH_IN_SSB}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}   numOfPrb
#           ${PDSCH_IN_SSB}     Run Keyword    hex to oct    ${PDSCH_IN_SSB[0]}
#           should be true     (${PDSCH}-32)>=${PDSCH_IN_SSB}>= (${PDSCH}-48)
#     END
#-------------------file operation---------------------------------------------------------------------------------
Get All File With Expect Suffix
    [Arguments]    ${path}    ${suffix}    ${is_full_path}=${True}    ${connection}=${None}
    ${file_list_string}    Run Keyword If    '${connection}'=='${None}'
    ...    OperatingSystem.Run    command=cd ${path};ls
    ...    ELSE
    ...    csn.Execute    command=cd ${path};ls    connection=${connection}
    Log   ${file_list_string}
    ${file_list}    Split String    ${file_list_string}
    ${expect_file_list}    Create List
    FOR    ${file}    IN     @{file_list}
        ${file_split_array}    Split String    ${file}    .
        ${file_path}    Run Keyword If    ${is_full_path}    Join Path    ${path}    ${file}
        ...    ELSE    ${file}
        Run Keyword If    '${suffix}'=='${file_split_array[-1]}'
        ...    Append To List    ${expect_file_list}    ${file_path}
    END
    [Return]    ${expect_file_list}

#-------------------TTi Trace---------------------------------------------------------------------------------
Prepare Ttitrace Pstools
    [Arguments]    ${sw}=${ACTIVE_SW_VERSION}    ${release}=${RELEASE}
    ...    ${alias}=Ctrl_VM
    ${fixed_sw}    Fix SBTS Trunk Sw Version    ${sw}
    ${download_link}    Set Variable
    ...    ${SW_SERVER_LINK}/tools/${release}/${fixed_sw}/pstools/${fixed_sw}_pstools.zip
    csn.execute    command=wget ${download_link} -nv -P ${TEST_LOG_DIRECTORY}
    ...    connection=${alias}
    ${is_exist}    csn.file_exists    ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools.zip
    ...    connection=${alias}
    Should Be True    ${is_exist}
    ${is_exist}    csn.file_exists    ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools
    ...    connection=${alias}
    Run Keyword If    ${is_exist}    csn.execute    command=mkdir ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools
    ...    connection=${alias}
    csn.execute
    ...    command=unzip ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools.zip -d ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools
    ...    connection=${alias}
    ${tti_tool}    Set Variable
    ...    ${TEST_LOG_DIRECTORY}/${fixed_sw}_pstools/TtiTracer/onlineTtiStream/onlineTtiStream
    ${is_exist}    csn.file_exists    ${tti_tool}
    ...    connection=${alias}
    Should Be True    ${is_exist}
    [Return]    ${tti_tool}

#-------------------tcp dump log---------------------------------------------------------------------------------
Start tcpdump by command For Remote
    [Documentation]    Author: He winnie
    ...                this KW is collect wiresahrk log in sbts by command
    [Arguments]    ${bts_index}=${0}    ${append_str}=${Empty}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    set suite variable    ${tcpdump_log_name_${bts_index}}
    ...    Wireshark_${timestamp}_${bts_index}.pcap
    ssh.send command    command=tcpdump -i any ${append_str} -w /tmp/${tcpdump_log_name_${bts_index}} &>/dev/null &
    ...    connection=BTS${bts_index}_LOCAL_Conn
    [Return]    ${tcpdump_log_name_${bts_index}}

Stop tcpdump And download by command For Remote
    [Documentation]    Author: He winnie
    ...                this KW is stop wiresahrk log in sbts by command
    [Arguments]    ${bts_index}=${0}
    Stop tcpdump in SBTS by command    connection=BTS${bts_index}_LOCAL_Conn

Download wireshark log to testvm For Remote
    [Documentation]    Author: He winnie
    ...                this KW is stop wiresahrk log in sbts by command
    [Arguments]    ${bts_index}=${0}
    ${log_path}    Download wireshark log to testvm    connection=BTS${bts_index}_LOCAL_Conn
    ...    tcpdump_log_name=${tcpdump_log_name_${bts_index}}
    [Return]    ${log_path}

Start tcpdump by command For Local VM
    [Arguments]    ${bts_index}=${0}    ${append_str}=${EMPTY}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    set variable    Wireshark_vm_${timestamp}_${bts_index}.pcap
    ssh.send command    command=sudo tcpdump -i any ${append_str} -w ~/${tcpdump_log_name} &>/dev/null &
    ...    connection=BTS${bts_index}_VM
    [Return]    ${tcpdump_log_name}

Stop tcpdump And download by command For Local VM
    [Arguments]    ${log_name}    ${bts_index}=${0}
    Stop tcpdump in SBTS by command    connection=BTS${bts_index}_VM
    Download wireshark log to testvm    connection=BTS${bts_index}_VM    tcpdump_log_name=${log_name}
    ...    remote_log_dir=home/ute


#---------------------------emil log------------------------
Connect To DCAP And Start Trace
    [Arguments]    ${bts_index}=${0}
    ...            ${gnb_trace_profile}=dcap-lite-default
    ...            ${vcu_trace_profile}=None
    ...            ${vdu_trace_profile}=None
    ...            ${enb_trace_profile}=None
    ...            ${bts_trace_profile}=None
    ...            ${custom_filter_file}=None
    ...            ${gnb_custom_profile_list}=None
    ...            ${enb_custom_profile_list}=None
    ...            ${vdu_custom_profile}=None
    ...            ${vcu_custom_profile}=None
    Log    ${vcu_custom_profile},${vdu_custom_profile},${custom_filter_file},${bts_trace_profile} is not used
    Log    ${enb_trace_profile},${vdu_trace_profile},${vcu_trace_profile},${gnb_trace_profile} is not used
    Connect To DCAP    host=${DCAP_Server.host}
    ...    port=${DCAP_Server.port}    username=${DCAP_Server.username}
    ...    password=${DCAP_Server.password}    rd_version=dcapv3
    ...    secure=${True}    alias=dcap
    ${host}    Run Keyword If    ${bts_index}==${0}    Get S1 Ip Of BTS
    ...    ELSE    ${BTS${bts_index}_INFO.IP}
    Set Test Variable    ${host}    ${host}
    ${bts}    Create Dictionary    host=${host}
    ...    username=${BTS${bts_index}_INFO.http_USERNAME}
    ...    password=${BTS${bts_index}_INFO.http_PASSWORD}
    ...    port=${BTS${bts_index}_INFO.PORT}
    Start Trace In DCAP    bts_dic=${bts}    tag=${BTS${bts_index}_INFO.MRBTSID}_start_trace
    ...    enb_custom_profile_list=${enb_custom_profile_list}
    ...    gnb_custom_profile_list=${gnb_custom_profile_list}

Get S1 Ip Of BTS
    [Arguments]    ${connection}=COAM_0
    ${info}    coam.get_parameters_for_all    class_name=BTS
    ...    connection=${connection}
    [Return]    ${info}[0][btsMplaneIp4V]

Stop Trace In DCAP and Convert It To CSV
    [Arguments]    ${bts_ip}=${host}
    ...    ${emil_host}=${Emil_Server}[host]
    ...    ${emil_user}=${Emil_Server}[username]
    ...    ${emil_password}=${Emil_Server}[password]
    ...    ${site_type_list}=${[]}
    [Documentation]    Author: He winnie
    ...                this KW is stop dcap and convert emil log to csv
    ...    | Input Parameters | Man. | Description |
    ...    | local_path | Yes | local path |
    ...    | connection_ABIL | Yes | connection alias |
    ...
    ...    | Return Value | Description |
    ...    | local_csv_file_path | rturn local csv file path |
    ...
    ...    Example
    ...    | ${local_csv_file_path} | Convert TTI trace to CVS and download csv logs to test pc |
    ...    | ...                    | local_path=${TEST_LOG_DIRECTORY} | ${connection_ABIL}=ABIL Slave |
    ...
    Stop Trace In DCAP    btsip=${bts_ip}
    Set Test Variable    ${${bts_ip}_dcap_trace_stop}    ${True}
    ${trace_file}    Download Trace File    btsip=${bts_ip}
    @{files}    List Files In Directory    ${trace_file}   *.zip
    ${archive}    Set Variable    ${trace_file}/@{files}[0]
    ${site_type_csv_file}    Create Dictionary
    FOR    ${site_type}    IN    @{site_type_list}
        ${log_file}    tti.extract_log_from_zip_file    ${archive}    directory=${trace_file}
        ...    postfix=${Emil_Config}[${site_type}_log_postfix]
        ${log_file}    Set Variable    ${log_file}[0]
        ${csv_file}    Convert Emil Log to CSV    emil_log_file=${log_file}
        ...    profile_path=${Emil_Config}[${site_type}_profile_path]
        ...    emil_host=${emil_host}
        ...    emil_user=${emil_user}
        ...    emil_password=${emil_password}
        Set To Dictionary    ${site_type_csv_file}    ${site_type}=${csv_file}
    END
    [Return]    ${site_type_csv_file}
