# *** Settings ***
# Library    OperatingSystem
# Library    Collections
# Library    BuiltIn
# Library    String
# Library     ../Resources/get_time_relative.py
# Resource    ../Resources/5GC000561_coam_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource    taf/rfrl/common_resources/robot/coam.robot
# Variables    Resources/variables.py
# 
# Documentation
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# 
# Force Tags    5G_SISO          5G_RAN_TDD   STATE_GNB_COMMISSIONED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_ENB
# ...    PY36
# 
# *** Variables ***
# ${PTP_filter}    'ether proto 0x88f7'
# ${SyncE_filter}    'ether proto 0x8809'
# ${PTP_SyncE_filter}    'ether proto 0x88f7||0x8809'
# 
# ${RU_log_02}    loner_561_A_02.pcap
# 
# ${sourceportid}    ptp.v2.sourceportid
# ${clockidentity}    ptp.v2.clockidentity
# ${sync_message}     ptp.v2.messagetype == 0x0
# ${announce_message}     ptp.v2.messagetype == 0xb
# ${syncE_message}    eth.type == 0x8809 and ossp.esmc.event_flag == 0x0
# 
# 
# ${case_02_timer}    60s
# ${SCF_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_8cc.xml
# 
# *** Test Cases ***
# [1]5GC000561_002_PTP_syncE_message_should_be_provide_on_ABIL_ecpri_port_S-RF1
#     [Tags]    5GC000561-ZA    6.8151    COAM    CRT_22R1     master_classicalbts_all    CIT_21A    CIT_21B    CIT_22R1
#     ...    CRT_22R3    CRT_22R4    CRT_TRUNK    CRT_23R1
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     case prepare for 561
#     COAM Wait for gnb ready and cell setup and sync status
# #    Capture Wireshark Log for a While from Loner trunk    filename=${loner_log_02}    time=${case_02_timer}    filter=${PTP_SyncE_filter}
#     Connect to Common Unit Master    alias=ASIK Master
#     Connect to gnb coam via ssl
#     ${ru_ip_addr}     Auto Get RU IP Address
#     Set Suite Variable       ${ru_ip_addr}       ${ru_ip_addr}
#     Capture Wireshark Log for a While from RU case    filename=${RU_log_02}    time=${case_02_timer}    filter=${PTP_SyncE_filter}
#     Check Message Rate of sync announce synce messages
#     Check SourcePortIdentity from mac address EUI_48 to EUI_64    filename=${RU_log_02}
#     [Teardown]    case teardown
# 
# *** Keywords ***
# Capture Wireshark Log for a While from RU case
#     [Arguments]    ${filename}    ${time}=10s    ${filter}=${None}    ${listen_port}=arb0p0
#     Start to Capture Wireshark Log from RU case    filename=${filename}    filter=${filter}    listen_port=${listen_port}
#     sleep    ${time}
#     Stop and Download Logs from RU case    ${filename}
# 
# Start to Capture Wireshark Log from RU case
#     [Arguments]    ${filename}    ${filter}=none    ${listen_port}=arb0p0
#     Connect to RU With Allocated IP
#     Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
#     ...                                           filename=${filename}    connection=RU
#     ...               ELSE    Start to Capture Wireshark Log with filter case   listen_port=${listen_port}     log_dir=${gnb_tmp_log_dir}
#     ...                                           filename=${filename}    filter=${filter}    connection=RU
# 
# Start to Capture Wireshark Log with filter case
#     [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
#     ${connection}    csn.get_connection_by_alias    alias=${connection}
#     ${channel}    Call Method    ${connection}    invoke_shell
#     Call Method    ${channel}    send    sudo su\n
#     Sleep    1s
#     Call Method    ${channel}    recv    ${65535}
#     Call Method    ${channel}    send    sudo tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter}\n
#     sleep    30s
#     Call Method    ${channel}    recv    ${65535}
#     Call Method    ${channel}    close
# 
# Check Message Rate of sync announce synce messages
#     Check Message Rate case    filename=${tmp_log_dir}/${RU_log_02}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
#     Check Message Rate case    filename=${tmp_log_dir}/${RU_log_02}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
#     Check Message Rate case    filename=${tmp_log_dir}/${RU_log_02}    filter=${syncE_message}     min_rate=0.9    max_rate=1.1
# 
# Check Message Rate case
#     [Arguments]    ${filename}    ${filter}    ${min_rate}    ${max_rate}
#     ${ptp_command}     set variable   {tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
#     ${filtered_packets}    Load pcap with filter    pcap_file=${filename}    filter_expression=${filter}
#     ...    command_template=${ptp_command}
#     OperatingSystem.Run And Return Rc And Output    sudo chown ute ${tmp_log_dir}/${RU_log_02}
#     run keyword and ignore error    Get pdml log    tcpdump_log=${filename}    filter=${filter}
#     # PDML_LOG_PATH_TESTCASE is test variable of keyword "Get pdml log"
#     @{msg}    get_time_relative_item    tcpdump_pdml=${PDML_LOG_PATH_TESTCASE}
#     ${cnt}=    Get Length     ${msg}
#     ${time}=    Evaluate    ${msg[-1]}-${msg[0]}
#     ${rate}=    Evaluate        (${cnt}-1)/${time}
#     Should Be True     ${min_rate} < ${rate} < ${max_rate}
# 
# Get pdml logpath
#     [Documentation]   author: Wang Yixiang
#     ...    convert pcap to pdml with filter
#     [Arguments]    ${tcpdump_log}
#     ${tcpdump_path}    ${tcpdump_file}    Split Path     ${tcpdump_log}
#     @{log_file}   List Files In Directory    path=${tcpdump_path}    pattern=*.pdml
#     ${list_len}    get length    ${log_file}
#     ${full_log_path}    set variable    ${tcpdump_path}${/}@{log_file}[0]
#     [Return]    ${full_log_path}
# 
# Check SourcePortIdentity from mac address EUI_48 to EUI_64
#     [Arguments]    ${filename}
#     Connect to Common Unit Master
#     ${EUI_64}    csn.execute
#     ...          command=ifconfig ethlmp0|grep ether|awk '{print$2}'|sed -e 's/://g' -e 's/....../0x&fffe/'|xargs echo -n
#     ...          connection=${asik}
#     Connect to gnb coam via ssl
#     ${eCpriMasterClockIdentity}    Get SCF single Value from current xml file
#     ...    parameter=eCpriMasterClockIdentity    alias=GNB_OAM    config_type=configurationAndRuntimeObjects
#     ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
# #    ${eCpriMasterClockIdentity}    Coam Get Parameter via webUI    dist_name=&{PARAM_561_002[0]}[dist_name]
# #    ...                            filter_param=&{PARAM_561_002[0]}[filter_param]    p_name=&{PARAM_561_002[0]}[p_name]
#     #${eCpriMasterClockIdentity}    Convert To Integer    ${eCpriMasterClockIdentity}
#     #${EUI_64_INT}    Convert To Integer    ${EUI_64}
#     ${eCpriMasterClockIdentity}    remove string    ${eCpriMasterClockIdentity}    :
#     should be equal    first=0x${eCpriMasterClockIdentity}    second=${EUI_64}    ignore_case=True
# 
#     ${ptp_command}   set variable   {tshark_path} -r {pcap_file} -Y \"${clockidentity}==${EUI_64}\" -T pdml
#     ${filtered_packets}    Load pcap with filter    pcap_file=${tmp_log_dir}/${filename}
#     ...    filter_expression=${clockidentity}==${EUI_64}    command_template=${ptp_command}
#     ${items}   pcap.get_field_value_by_name    field_name=ptp.v2.clockidentity    attribute_name=show
#     should not be empty     item=${items}     msg=check clockidentity exist failed!
# 
# case prepare for 561
#     Connect to gnb coam via ssl
#     ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${cur_program}
#     ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
#     run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'   Prepare for ute cloud
#     COAM Create log directory
#     Set suite variable    ${tmp_log_dir}    ${LOG_PATH}
# 
# case teardown
#     COAM Teardown gnb connections
#     common_setup_teardown.Common case teardown    is_log_required=${False}
# 
# Prepare for ute cloud
#     ${SCF_PATH}     Get Substring    ${CURDIR}  0  -47
#     ${pattern}   Set Variable    7_5(.*)
#     ${TLNAME}    Get Regexp Matches     ${CONFIGURATION}    ${pattern}    1
#     ${testlinename}   Set Variable    7_5@{TLNAME}[0]
#     set suite variable     ${TS_LOG_PATH_BASE}    /home/ute
#     set suite variable     ${GOLDEN_FULL_SCF}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800.xml
#     COAM Commission with scf file  scf_file_path=${GOLDEN_FULL_SCF}    timeout=600    is_pdl_checking_needed=${False}
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
# 
# Start to Capture Wireshark Log with filter trunk
#     [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
#     csn.send command    command=ip netns exec radions tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &
#     ...    connection=${connection}
#     sleep    3s
# 
# Stop and Download Logs from RU case
#     [Arguments]    @{filenames}    ${container_id}=0x1018    ${asik_alias}=ASIK Master
#     ...            ${ru_index}=${1}    ${gnb_index}=${0}
#     ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
#     ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
#     ...            ${asik_addr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#     ...            ${asik_name}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
#     ...            ${asik_pass}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
#     csn.execute        command=ps -ef|grep -i tcpdump     connection=RU
#     csn.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=RU
# #    csn.send command        command=killall tcpdump     connection=RU
#     csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}    connection=RU
#     :FOR    ${filename}    IN    @{filenames}
#     \    csn.send command        command=sudo chmod 777 ${gnb_tmp_log_dir}/${filename}    connection=RU
# #    \    csn.download_file   remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${tmp_log_dir}/${filename}   connection=RU
#     \    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
#     \    csn.execute    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=${connection}
#     \    ${channel}    Call Method    ${connection}    invoke_shell
#     \    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
#     \    Sleep    1 sec
#     \    Call Method    ${channel}    recv    ${65535}
#     \    ${SCP_commond}  run keyword if   "${PROGRAM}"=="23R3"      set variable
#     ...  scp ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r    ELSE     set variable
#     ...  scp -O ${ru_username}@${ru_ip_addr}:${gnb_tmp_log_dir}/${filename} /tmp\r
#     \    Call Method    ${channel}    send    ${SCP_commond}
#     \    Sleep    3 sec
#     \    Call Method    ${channel}    recv    ${65535}
#     \    Call Method    ${channel}    send    yes\r
#     \    Sleep    3 sec
#     \    Call Method    ${channel}    recv    ${65535}
#     \    Call Method    ${channel}    send    ${ru_password}\r
#     \    Sleep    3 sec
#     \    Call Method    ${channel}    recv    ${65535}
#     \    sleep    10s
#     \    Run Keyword And Ignore Error    run process
#     \    ...  sudo sshpass -p ${asik_pass} scp ${asik_name}@${asik_addr}:/tmp/node_FHNET00/tmp/${filename} ${tmp_log_dir}/${filename}   shell=yes
#     \    csn.execute    command=rm /tmp/node_FHNET00/tmp/${filename}    connection=${connection}
#     \    csn.execute    command=sudo rm ${gnb_tmp_log_dir}/${filename}    connection=RU
# 
# 
# 
# 
# 
# 
# 
