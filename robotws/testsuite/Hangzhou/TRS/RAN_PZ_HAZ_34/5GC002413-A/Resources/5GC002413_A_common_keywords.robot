*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000561/Resources/5GC000561_ABIO_keyword.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000561/5GC000561_ZA/Resources/variables_ABIO.py
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_variables.py
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC002413-A/Resources/5GC002413_A_variables.py
Library    check_sync_log.py
Library    check_sync_log.SyncLog     WITH NAME    synclog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
@{content_of_sync_log}    Avg tuning value
...                       Active tuning mode
...                       Clk freq diff
...                       Pct. of rejected phase samples
...                       Active Sync ref source type
...                       Synchronization status
...                       Clk phase diff
...                       Active reference source

${sync_flag}    ptp.v2.flags == 0x00000000

@{portlist}       3    4    1    2

${clockidentity}      ptp.v2.an.grandmasterclockidentity

${announce}     ptp.v2.messagetype==11

${msgid}     ptp.v2.messagetype
${sync_message}        ${msgid} == 0
${announce_message}    ${msgid} == 11
${followup_message}    ${msgid} == 8
${delayReq_message}    ${msgid} == 1
${delayResp_message}   ${msgid} == 9

${check_ptp_sync}    ${sync_message} and
...                  ${sync_flag}

${announce_flag}    ptp.v2.flags == 0x0000003c

${check_ptp_announce}    ${announce_message} and
...                      ptp.v2.an.priority1 == 128 and
...                      ptp.v2.an.priority2 == 128 and
...                      ptp.v2.an.localstepsremoved == 1 and
...                      ptp.v2.an.origincurrentutcoffset == 37 and
...                      ptp.v2.timesource == 32 and
...                      ${announce_flag}

*** Keywords ***
5GC002413-A Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory for 561
    COAM Wait for gnb ready and cell setup and sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Check for unexpected alarms
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}

5GC002413-A Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

Get RFSW Log File On RU
    [Arguments]     ${connection}=RU_1    ${download_dir}=${TS_CASE_LOG_PATH}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_dir}    Set Variable    rfsw_log_${timestamp}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=${connection}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}
    ...                                                         connection=${connection}
    ...                                                         download_dir=${download_dir}
    ${unzip_result}    Run    unzip -d ${download_dir}/${rfsw_log_dir} ${rfsw_log_path_on_testPC}|awk '{print $2}'
    [Return]   ${download_dir}/${rfsw_log_dir}

Check Content of Synchronization Log
    [Arguments]    ${file_path}
    synclog.confirm_all_content_of_sync_log_is_covered    log_file=${file_path}/1011_RFSW_synchronization.log

Check Timer Is Work of Synchronization Log
    [Arguments]    ${file_path}
    synclog.check_timer_iswork     log_file=${file_path}/1011_RFSW_synchronization.log

Check Preserved Parameters
    [Documentation]    parameter1: domainNumber and Asymmetry Correction; parameter2: Sync Mode
    [Arguments]    ${file_path}
    ${result}    Run And Return Rc And Output    unzip -d ${file_path} ${file_path}/1011_startup.zip
    ${result}    Convert To String      ${result}
    ${check_result}    Get Regexp Matches     ${result}     zipfile is empty
    ${check_result}     Convert To String      ${check_result}
    Run keyword If     ${check_result}==['zipfile is empty']
    ...      Check Parameters when file empty      file_path=${file_path}
    ...      ELSE    Run Keyword     Check Parameters when file not empty     file_path=${file_path}

Check Parameters when file not empty
    [Arguments]    ${file_path}
    ${default_log}    Set Variable    ${file_path}/startup_DEFAULT.log.xz
    ${parameter1}    Run    xzcat ${default_log} |grep domainNumber| grep delaySymmetry
    Should Not Be Empty    ${parameter1}
    ${parameter2}    Run    xzcat ${default_log} |grep 'Synchronization Mode'
    Should Not Be Empty    ${parameter2}

Check Parameters when file empty
    [Arguments]    ${file_path}
    Run    unzip -d ${file_path} ${file_path}/1011_runtime.zip
    ${default_log}    Set Variable    ${file_path}/runtime_DEFAULT.log.xz
    ${parameter1}    Run    xzcat ${default_log} |grep domainNumber| grep delaySymmetry
    Should Not Be Empty    ${parameter1}
    ${parameter2}    Run    xzcat ${default_log} |grep 'Synchronization Mode'
    Should Not Be Empty    ${parameter2}

Check Log in Locked State for 5GC002413
    [Arguments]    ${file_name}    ${listen_port}    &{ssmType}
    Check Log in WebUI for SSM and PTP    status=${status}[0]    &{ssmType}
    Check Log in Wireshark Log for PTP for 5GC002413    file_name=${file_name}    status=${status}[0]   listen_port=${listen_port}

Check Log in Holdover and Phase Error within specification for 5GC002413
    [Arguments]    ${file_name}    ${listen_port}    &{ssmType}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_SYNCIN_2048}
    wait until keyword succeeds    5min    1min    Check Synchronization status is Holdover state in WebUI
    Check Log in WebUI for SSM and PTP    status=${status}[1]    &{ssmType}
    Check Log in Wireshark Log for PTP for 5GC002413    file_name=${file_name}    status=${status}[1]   listen_port=${listen_port}

Check Log in Wireshark Log for PTP for 5GC002413
    [Arguments]    ${file_name}    ${status}    ${listen_port}
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log from RU for 2413    filename=${file_name}    time=30s    filter=${PTP_SyncE_filter}    listen_port=${listen_port}
    Check Message Rate    filename=${file_name}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
    Check Message Rate    filename=${file_name}    filter=${delayReq_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate    filename=${file_name}    filter=${delayReq_message}     min_rate=15.9    max_rate=16.1
    Load BIP Log with Template Command    pcap_file=${tmp_log_dir}/${file_name}
    ...                                                 command_template=${command_template}
    ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
    ...                          ${check_ptp_announce}
    ...                          ${clock_class}==${eCpriMasterClockClass}[${status}]
    ...                          ${clock_accuracy}==${eCpriMasterClockAccuracy}[${status}]
    ...                          ${clock_variance}==${eCpriMasterOffsetScaledLogVariance}[${status}]
    Check expression in Bip Log by Name    filter_expression=${expression}    field_name=${msgid}
    Check expression in Bip Log by Name    filter_expression=${check_ptp_sync}    field_name=${msgid}

Capture Wireshark Log from RU for 2413
    [Arguments]    ${filename}    ${time}=10s    ${filter}=${None}    ${listen_port}=arb0p0
    Start to Capture Wireshark Log from RU    filename=${filename}    filter=${filter}    listen_port=${listen_port}
    sleep    ${time}
    Stop and Download Logs from RU for 5GC002413     ${filename}

Stop and Download Logs from RU for 5GC002413
    [Arguments]    @{filenames}     ${container_id}=0x1018    ${asik_alias}=ASIK Master
    ...            ${ru_index}=${1}    ${gnb_index}=${0}
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...            ${asik_addr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${asik_name}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${asik_pass}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
    csn.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=RU
#    csn.send command        command=killall tcpdump     connection=RU
    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
    Log to Console    ${asik_addr} ${asik_name} ${asik_pass}
    FOR    ${filename}    IN    @{filenames}
        csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}/${filename}    connection=RU
#        csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=RU
        ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
        csn.execute    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${connection}
        ${channel}    Call Method    ${connection}    invoke_shell
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    scp ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    yes\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    ${ru_password}\r
        Sleep    3 sec
        Call Method    ${channel}    recv    ${65535}
        sleep    5s
        csn.download_file   remote_path=/tmp/node_FHNET00/tmp/${filename}    local_path=${tmp_log_dir}/${filename}   connection=${connection}
        sleep    2s
#        Run Keyword And Ignore Error    run process
#        ...  sudo sshpass -p ${asik_pass} scp ${asik_name}@${asik_addr}:/tmp/node_FHNET00/tmp/${filename} ${tmp_log_dir}/${filename}   shell=yes
        csn.execute    command=rm /tmp/node_FHNET00/tmp/${filename}    connection=${connection}
        csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
    END

_Get_parameter_values
    [Arguments]    ${dist_name}    ${filter_param}  ${abbr}  ${node_index}
    ${parameter_values}       selenium_coam.get_parameter_value    dist_name=${dist_name}
                              ...                                  filter_param=${filter_param}
                              ...                                  abbr=${abbr}
                              ...                                  node_index=${node_index}
    [Return]  ${parameter_values}

Get Structure_index from expect_index
   [Arguments]   ${index_begin}   ${index_end}  ${expect_index}  ${dist_name}  ${filter_param}  ${abbr}
    @{index_actual} =    Create List
    FOR    ${index}    IN RANGE    ${index_begin}    ${index_end}
        ${index_values}     _Get_parameter_values  dist_name=${dist_name}
        ...                                            filter_param=${filter_param}
        ...                                            abbr=${abbr}
        ...                                            node_index=${index}
        Append To List    ${index_actual}      ${index_values}
    END
    ${structure_index}   Get Index From List   ${index_actual}     ${expect_index}
    [Return]       ${structure_index}

Get topSlavePortNumber from topMasterUsed
    ${used_index}    Get Structure_index from expect_index    index_begin=${0}
    ...                                                       index_end=${3}
    ...                                                       expect_index=used
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ${PortNumber}       _Get_parameter_values  dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    ...                                            node_index=${used_index}
    [Return]      ${PortNumber}

Get listen_port
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${PortNumber}      Get topSlavePortNumber from topMasterUsed
    ${port_index}    Get Index From List      ${portlist}     ${PortNumber}
    COAM selenium logout
    [Return]       ${port_index}

Get topGMasterClockIdentity from topMasterUsed
    ${used_index}    Get Structure_index from expect_index    index_begin=${0}
    ...                                                       index_end=${3}
    ...                                                       expect_index=used
    ...                                                       dist_name=${GET_PARAMETER_VALUES_5740[1]}[dist_name]
    ...                                                       filter_param=${GET_PARAMETER_VALUES_5740[1]}[filter_param]
    ...                                                       abbr=${GET_PARAMETER_VALUES_5740[1]}[abbr]
    ${topGMasterClockIdentity}       _Get_parameter_values  dist_name=MRBTS-20529/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    ...                                            filter_param=Grandmaster clock identity
    ...                                            abbr=topGMasterClockIdentity
    ...                                            node_index=${used_index}
    [Return]      ${topGMasterClockIdentity}

Check topGMasterClockIdentity
    [Arguments]    ${filename}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${UI_value}    Get topGMasterClockIdentity from topMasterUsed
    COAM selenium logout
    ${ptp_command}   set variable   {tshark_path} -r {pcap_file} -Y \"${announce} and ${clockidentity}==0x${UI_value}\" -T pdml
    Load pcap with filter    pcap_file=${tmp_log_dir}/${filename}
    ...    filter_expression=${announce_message} and ${clockidentity}==0x${UI_value}    command_template=${ptp_command}
    ${items}   pcap.get_field_value_by_name    field_name=ptp.v2.an.grandmasterclockidentity    attribute_name=show
    ${items_singal}    Remove Duplicates    ${items}
    ${items_singal}     Convert To String     ${items_singal}
    Should Match Regexp         ${items_singal}       (0x.{6}fffe.{6})

Connect to gnb coam via ssl Enb
    [Arguments]  ${connection}=ENB_OAM
    ...    ${bts_host}=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=Nemuadmin
    ...    ${password}=nemuuser
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

COAM Update several parameters via rest api Enb
    [Arguments]    ${parameters_to_update_via_api}    ${timeout}=${60}    ${connection}=ENB_OAM
    ${para_file}    coam_parameter.create_update_parameters_delta
    ...    parameters=${parameters_to_update_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Should contain    ${update_via_api_status}    PASS
    ...    msg=parameters do not update successfully.    ignore_case=${True}
    [Return]   ${update_via_api_status}

Change Clockclass and Syncin on Enb
    Connect to gnb coam via ssl Enb
    COAM Update several parameters via rest api Enb   parameters_to_update_via_api=${PARAM_2413_ACCEPTEDCLOCKCLASS}
    COAM Update several parameters via rest api Enb   parameters_to_update_via_api=${PARAM_2413_SYNCIN_2048}

Recover Clockclass and Syncin on Enb
    Connect to gnb coam via ssl Enb
    COAM Update several parameters via rest api Enb   parameters_to_update_via_api=${PARAM_2413_RECOVER_ENV}

Recover ENV syncInputType 2413-A
    [Arguments]    ${listen_port}
    Run Keyword And Ignore Error    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAM_561_013_RECOVER_ENV}
    COAM Wait for gnb ready and cell setup and sync status
    Log to Console    check phase error
    wait until keyword succeeds    10min    1min    Phase error below 100ns
    Verify ENV is Recovered for 2413    listen_port=${listen_port}

Verify ENV is Recovered for 2413
    [Arguments]    ${listen_port}=arb0p0
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    ${ru_ip_addr}     Auto Get RU IP Address
    Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
    Capture Wireshark Log from RU for 2413    filename=ptp_recover.pcap    time=10    filter=${PTP_SyncE_filter}    listen_port=${listen_port}
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

Clear the cache and reconnect
    Run keyword and ignore error    ssh.Reset cache
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    ${status}    @{RUS_ALIAS}    Run keyword and ignore error    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}

5GC0002413_A Suit Setup
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    Run Keyword And Continue On Failure    Save Coam Snapshot

Check for unexpected alarms for 2413-A
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
