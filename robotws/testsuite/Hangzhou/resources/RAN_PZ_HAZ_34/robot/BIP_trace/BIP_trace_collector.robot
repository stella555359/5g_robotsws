*** Settings ***
Documentation    This is for BIP log capture
...              Contacts: stella.lin@nokia-sbell.com
...                        binmei.ding@nokia-sbell.com
Library    String
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource   ../container_log_capturing.robot


*** Keywords ***
Precondition For Bip Capture
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Descrition：Start BIP capture on gnb ASIK.
    ...                :param log_name <str>: xxxx.pcap
    ...                :param script_path <str>:  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace
    ...                :param L1_version <str>: L1R50,L1R51,L1R52.....
    ...                :param source_to_capture <str> : GNB or AF.
    ...                :param connection <str> : asik master connection alias
    ...                :capture_abil_number_index: all capture abil indexs. e.g. 1, 12, 123
    [Arguments]        ${script_path}=${CURDIR}
    ...                ${L1_version}=L1R52
    ...                ${source_to_capture}=GNB
    ...                ${connection}=ASIK Master
    ...                ${capture_abil_number_index}=1
    ${capture_abil_number_list}    Convert To List    ${capture_abil_number_index}
    ${store_script_path}      Set Variable    ${/}ffs${/}run${/}config${/}scripts
    ${asik_mirror_script}     Set Variable    ${L1_version}_${source_to_capture}_asik_mirror_on.sh
    ${loner_mirror_script}    Set Variable    ${L1_version}_${source_to_capture}_loner_mirror_on.sh
    ${is_store_script_path_exists}    csn.file_exists    remote_path=${store_script_path}
    ...                               connection=${connection}
    Run keyword if    ${is_store_script_path_exists}==${False}
    ...    csn.execute    command=mkdir ${store_script_path}       connection=${connection}
    csn.upload_file     local_path=${script_path}${/}${asik_mirror_script}
    ...                        remote_path=${store_script_path}${/}${asik_mirror_script}
    ...                        connection=${connection}
    csn.upload_file     local_path=${script_path}${/}${loner_mirror_script}
    ...                        remote_path=${store_script_path}${/}${loner_mirror_script}
    ...                        connection=${connection}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}${/}${asik_mirror_script}   connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}${/}${loner_mirror_script}   connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    ${connection_asik} =    csn.get connection by alias    alias=${connection}
    ${channel} =    Call Method    ${connection_asik}    invoke_shell
    Call Method    ${channel}    send    sh ${store_script_path}${/}${asik_mirror_script}\n
    Sleep    10s
    Call Method    ${channel}    recv      ${65535}
    FOR    ${item}    IN    @{capture_abil_number_list}
        Run Keywords
        ...    Call Method    ${channel}    send    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}\n    AND
        ...    Sleep    10s    AND
        ...    Call Method    ${channel}    recv      ${65535}
    END
    Call Method    ${channel}    close

Start BIP Capture On ASIK
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Descrition：Start BIP capture on gnb ASIK
    ...                :param log_prefix <str>:bip log name prefix, it can be used for specify logs
    ...                :param interface<str>:capture port on ASIK
    ...                :param connection <str> : asik master connection alias
    [Arguments]        ${log_prefix}
    ...                ${interface}=etha01
    ...                ${connection}=ASIK Master
    ${time_stamp_for_bip} =    Get current date    result_format=%Y%m%d%H%M%S
    ${command}   Set Variable   nohup tcpdump -s 0 -i ${interface} -w ${/}tmp${/}${log_prefix}_${time_stamp_for_bip}.pcap &>/dev/null &
    csn.send command      ${command}    connection=${connection}
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix}
    ${is_process_on}    csn.execute    command=${check_process_command}    connection=${connection}
    Should Not Be Empty    ${is_process_on}    msg=Fail to start bip log capturing on ASIK

Stop BIP Capture with gnbMirroring scripts On Common Unit
    [Documentation]    Auther:tong.chen@nokia-sbell.com
    ...                Descrition：Stop BIP capture on gnb ASIK or ASIB which is cptured by gnbMirroring.
    ...                :param interface<str>:capture port on ASIK or ASIB
    ...                :param connection <str> : master connection alias
    [Arguments]     ${interface}=etha01  ${connection}=ASIK Master
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${interface}
    ${is_process_on}    csn.execute    command=${check_process_command}    connection=${connection}
    Should Not Be Empty    ${is_process_on}    msg=Fail to stop bip log capturing on ASIK
    ${prepare_ssh}    csn.Execute    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |sed 's/tcpdump.*//g' |sed 's/.*ssh -o/ssh -o/'
    ...               connection=${connection}
    ${prepare_ssh}    Strip String    ${prepare_ssh}    characters=\r\n
    csn.execute    command=${prepare_ssh}killall tcpdump    connection=${connection}
    sleep  3 sec
    ${is_process_killed} =    csn.Execute    command=${check_process_command}    connection=${connection}
    Should Be Empty    ${is_process_killed}

Stop BIP Capture On ASIK
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Descrition：Stop BIP capture on gnb ASIK.
    ...                :param interface<str>:capture port on ASIK
    ...                :param connection <str> : asik master connection alias
    [Arguments]     ${interface}=etha01  ${connection}=ASIK Master  ${kill_type}=2
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${interface}
    ${is_process_on}    csn.execute    command=${check_process_command}    connection=${connection}
    Should Not Be Empty    ${is_process_on}    msg=Fail to stop bip log capturing on ASIK
    csn.Execute        ps -ef | grep tcpdump | grep -v grep | grep ${interface} | awk '{print $2}' | xargs kill -${kill_type}
    ...                connection=${connection}
    sleep  3 sec
    ${is_process_killed} =    csn.Execute    command=${check_process_command}    connection=${connection}
    Should Be Empty    ${is_process_killed}

Download BIP Logs From ASIK To TestPC
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                Descrition：dowmload BIP logs from gnb ASIK to TestPc
    ...                :param interface <str>: the way of download BIP file: Download or SSHpass
    [Arguments]   ${log_prefix}  ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master    ${download_type}=Download
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=/tmp    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No bip logs found with log prefix ${log_prefix} under asik tmp folder
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
      Run Keyword If    '${download_type}'=='Download'    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
      ...                                                 remote_path=/tmp/${log_name}
      ...                                                 local_path=${log_path}/${log_name}
      ...                                                 connection=${connection}
      ...    ELSE IF    '${download_type}'=='SSHpass'    Wait Until Keyword Succeeds   2 min  5 sec    Run Process
      ...               sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:/tmp/${log_name} ${log_path}/${log_name}
      ...               shell=yes
      ...    ELSE    Fail    msg=the value ${download_type} is not a valid value
      Append to list    ${list_log_path_local}    ${log_path}/${log_name}
      csn.execute      command=rm -rf ${/}tmp${/}${log_name}    connection=${connection}
    END
    [Return]    ${list_log_path_local}

Precondition for bip capture with gnbMirroring scripts
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...    Descrition：Start BIP capture on gnb ASIK to support for 19A, 19B and trunk. also support feature 1514.
    ...    The scripts location: \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring\V23
    ...    Due to the binary file should not be uploaded to robotws5g, so if gulp engine is needed for capturing instead of tcpdump,
    ...    gulp file should be uploded from other path.
    ...    :param script_path <str>:  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace
    [Arguments]        ${script_path}=${CURDIR}
    ...                ${gnb_mirroring}=gnbMirroring.sh
    ...                ${gnb_mirroring_config}=gnbMirroringConfig.sh
    ...                ${gulp_needed}=${False}
    ...                ${gulp_path}=/opt/ute/gulp
    ...                ${gulp}=gulp
    ...                ${connection}=ASIK Master
    ${store_script_path}      Set Variable    ${/}ffs${/}run${/}config${/}scripts
    ${is_store_script_path_exists}    csn.file_exists    remote_path=${store_script_path}
    ...                               connection=${connection}
    Run keyword if    ${is_store_script_path_exists}==${False}
    ...    csn.execute    command=mkdir ${store_script_path}       connection=${connection}
    csn.upload_file     local_path=${script_path}${/}${gnb_mirroring}
    ...                        remote_path=${store_script_path}${/}${gnb_mirroring}
    ...                        connection=${connection}
    csn.upload_file     local_path=${script_path}${/}${gnb_mirroring_config}
    ...                        remote_path=${store_script_path}${/}${gnb_mirroring_config}
    ...                        connection=${connection}
    Run keyword if    ${gulp_needed}==${True}    csn.upload_file     local_path=${gulp_path}${/}${gulp}
    ...                        remote_path=${store_script_path}${/}${gulp}
    ...                        connection=${connection}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}${/}${gnb_mirroring}  connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}${/}${gnb_mirroring_config}   connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}

Bip Capture with gnbMirroring scripts
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...    Descrition：Start BIP capture on gnb ASIK to support for 19A, 19B and trunk. also support feature 1514.
    ...    The scripts location: \\eseefsn50.emea.nsn-net.net\rotta4internal\5G_2\Oulu\juhakang\tools\gnbMirroring\V49
    ...    # General options
    ...    :param MIRRORING_MODE='local' # remote/local/manual, remote mirrors to EIF2, local dumps data to gNB,
    ...    manual enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring
    ...    :param BB_BOARD_TYPE='ABIL' # 'ABIL'/'ABIO'
    ...    # Mirror BB boards
    ...    :param BB_SLOT_1='true' # true/false
    ...    :param BB_SLOT_2='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_3='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_5='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_6='false' # true/false, do not enable for CA configs
    ...    :param BB_SLOT_7='false' # true/false, do not enable for CA configs
    ...    # Mirrored interfaces, the less interfaces are configured for mirroring, the better are chances to not to drop packets
    ...    :param L2_L1_BIP='true' # true/false
    ...    :param SYSCOM_MIRRORING='true' # true/false, mirrors syscom traffic between control and baseband boards
    ...    :param CARRIER_AGGREGATION='false' # true/false, for GC2/GD2 L2-RT instances
    ...    :param BACKHAUL_MIRRORING='false' # true/false, S1/X2 in Classical deployment, F1-U in Cloud deployment, works only in ASIK
    ...    :param L2HI_L2LO_MIRRORING='false' # true/false, traffic between L2-HI - L2-LO, only in ASIK
    ...    # Local mode options
    ...    :param FILTERING='off' # off/on, on filters out control messages sent in every TTI
    ...    :param USE_GULP='true' # true/false, use gulp engine for capturing instead of tcpdump, provides better performance
    ...    :param CAPTURING_TIME_SECONDS=5 # in seconds/special value 'infinite' keeps capture rolling
    ...    :param NUMBER_OF_FILES=1 # number of files created, tcpdump -W
    ...    :param FILE_SIZE_MBYTES=100 # size of file create, tcpdump -C
    ...    # connection
    ...    :param XTRACE='off' # on/off
    ...    # Debug options
    ...    :param connection <str> : asik master connection alias
    ...    :param check_times <int>: retry time for checking BIP process existence. Check interval is 1 second.
    ...    the tcpdump command is like:
    ...    ssh -o ConnectTimeout=5s -F /etc/bsoc/bsoc_ssh_config 192.168.253.21 tcpdump -i ethbp1 -C 100 -W 1 -w /tmp/tcpdump_L2L1_filtering_off.pcap
    ...    2020/04/09 Chen Tong: update the invoke shell method to send command due to invoke shell not take effect on ASIB environment.
    [Arguments]    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh     ${mirroring_mode}=local
    ...            ${bb_slot_1}=true    ${bb_slot_2}=false    ${bb_slot_3}=false
    ...            ${bb_slot_5}=true    ${bb_slot_6}=false    ${bb_slot_7}=false    ${l2_l1_bip}=true
    ...            ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${backhaul_mirroring}=false
    ...            ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false     ${capturing_time_seconds}=infinite
    ...            ${number_of_files}=1    ${file_size_mbytes}=100    ${xtrace}=off    ${sleep_time}=10s    ${bip_prefix}=tcpdump_L2L1
    ...            ${check_times}=${20}
    ${cmd_local}    catenate    nohup sh /ffs/run/config/scripts/${gnb_mirroring} --mirroring_mode=${mirroring_mode}
    ...             --bb_slot_1=${bb_slot_1} --bb_slot_2=${bb_slot_2}
    ...             --bb_slot_3=${bb_slot_3} --bb_slot_5=${bb_slot_5} --bb_slot_6=${bb_slot_6} --bb_slot_7=${bb_slot_7}
    ...             --l2_l1_bip=${l2_l1_bip} --syscom_mirroring=${syscom_mirroring}
    ...             --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...             --l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring} --filtering=${filtering} --use_gulp=${use_gulp}
    ...             --capturing_time_seconds=${capturing_time_seconds} --number_of_files=${number_of_files}
    ...             --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace} &>/dev/null &
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${sleep_time}
    Trace capturing process should be triggered    log_prefix=${bip_prefix}    connection_alias=${connection}
    ...    check_times=${check_times}

Download BIP Logs From ASIK To TestPC and rename it
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...                Descrition：dowmload BIP logs from gnb ASIK to TestPc
    ...                :param interface <str>: the way of download BIP file: Download or SSHpass
    ...                after the logs downloaded to test PC, rename them.
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master    ${download_type}=Download
    ...            ${log_prefix}=${None}    ${bip_prefix}=tcpdump_L2L1
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=/tmp    connection=${connection}
    ...    file_indicator=${bip_prefix}*
    should not be empty  ${list_log_names}    msg=No bip logs found with log prefix tcpdumpL2L1 under asik tmp folder
    Sort List    ${list_log_names}
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
      ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
      ${bip_name}    fetch from left    ${log_name}    .
      ${bip_name_new}    Set Variable If    '${log_prefix}'!='${None}'    ${log_prefix}_${bip_name}_${timestamp}.pcap
      ...                                                                 ${bip_name}_${timestamp}.pcap
      Run Keyword If    '${download_type}'=='Download'    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
      ...                                                 remote_path=/tmp/${log_name}
      ...                                                 local_path=${log_path}/${bip_name_new}
      ...                                                 connection=${connection}
      ...    ELSE IF    '${download_type}'=='SSHpass'    Wait Until Keyword Succeeds   2 min  5 sec    Run Process
      ...               sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:/tmp/${log_name} ${log_path}/${bip_name_new}
      ...               shell=yes
      ...    ELSE    Fail    msg=the value ${download_type} is not a valid value
      Append to list    ${list_log_path_local}    ${log_path}/${bip_name_new}
      csn.execute      command=rm -rf ${/}tmp${/}${log_name}    connection=${connection}
      sleep    1s    msg=Force to make ${timestamp} different for each ${log_name}. Otherwise differenet bip logs will be renamed to same one.
    END
    [Return]    ${list_log_path_local}

If GNB In Right Side Of AMIA
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  check for dual core env
    [Arguments]    ${connection}=ASIK Master
    ${cmd_output0}    ssh.Execute    command=cat /etc/hosts   connection=${connection}
    ${fctid}    get regexp matches      ${cmd_output0}     fct(\\d+)s0lla    1
    ${is_right_enabled}    Set Variable If    '4' in ${fctid}    ${True}    ${False}
    [Return]    ${is_right_enabled}

Bip Capture with gnbMirroring scripts with retry
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
     ...               2021/06/22  Su Li, update the BIP script version with V49, adapt the script for MultiRAT
    [Arguments]        ${script_path}=${CURDIR}    ${gnb_mirroring}=gnbMirroring.sh    ${gnb_mirroring_config}=gnbMirroringConfig.sh
    ...                ${gulp_needed}=${False}    ${gulp_path}=/opt/ute/gulp    ${gulp}=gulp    ${connection}=ASIK Master
    ...                ${mirroring_mode}=local    ${bb_slot_1}=true    ${bb_slot_2}=false
    ...                ${bb_slot_3}=false    ${bb_slot_5}=false    ${bb_slot_6}=false    ${bb_slot_7}=false
    ...                ${l2_l1_bip}=true    ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${du_index}=${0}
    ...                ${backhaul_mirroring}=false    ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false
    ...                ${capturing_time_seconds}=infinite    ${number_of_files}=1    ${file_size_mbytes}=100
    ...                ${xtrace}=off    ${retry_time}=10    ${sleep_time}=10s    ${add_mirror_port}=false    ${bip_prefix}=tcpdump_L2L1
    ...                ${oam_connection}=GNB_OAM    ${check_times}=${20}   ${gnb_index}=${0}   ${is_capture_right_bbmod}=${False}
    ${multiRAT}    Check If MultiRAT BTS
    ${amia_right}    If GNB In Right Side Of AMIA    connection=${connection}
    run keyword if    ${multiRAT} and ${amia_right}    Connect To MultiRAT GNB Common Unit Master
    ${connection}    set variable if    ${multiRAT} and ${amia_right}    MultiRAT GNB Master    ${connection}
    run keyword if   '${multiRAT}'=='${False}' and ${is_capture_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    ...               proxy=${connection}
    Precondition for bip capture with gnbMirroring scripts
    ...                script_path=${script_path}
    ...                gnb_mirroring=${gnb_mirroring}
    ...                gnb_mirroring_config=${gnb_mirroring_config}
    ...                gulp_needed=${gulp_needed}
    ...                gulp_path=${gulp_path}
    ...                gulp=${gulp}
    ...                connection=${connection}
    run keyword if    '${add_mirror_port}'=='true'    Modify gnbMirroring to add mirror port of abil slave    connection=${connection}
    Wait until keyword succeeds    ${retry_time}X    3 s    Bip Capture with gnbMirroring scripts
    ...                connection=${connection}
    ...                gnb_mirroring=${gnb_mirroring}
    ...                mirroring_mode=${mirroring_mode}
    ...                bb_slot_1=${bb_slot_1}
    ...                bb_slot_2=${bb_slot_2}
    ...                bb_slot_3=${bb_slot_3}
    ...                bb_slot_5=${bb_slot_5}
    ...                bb_slot_6=${bb_slot_6}
    ...                bb_slot_7=${bb_slot_7}
    ...                l2_l1_bip=${l2_l1_bip}
    ...                syscom_mirroring=${syscom_mirroring}
    ...                carrier_aggregation=${carrier_aggregation}
    ...                backhaul_mirroring=${backhaul_mirroring}
    ...                l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring}
    ...                filtering=${filtering}
    ...                use_gulp=${use_gulp}
    ...                capturing_time_seconds=${capturing_time_seconds}
    ...                number_of_files=${number_of_files}
    ...                file_size_mbytes=${file_size_mbytes}
    ...                xtrace=${xtrace}
    ...                sleep_time=${sleep_time}
    ...                bip_prefix=${bip_prefix}
    ...                check_times=${check_times}

Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...     Descrition：Stop BIP capture on gnb ASIK.
    ...     :param interface<str>:
    ...     the tcpdump command is like:
    ...    ssh -o ConnectTimeout=5s -F /etc/bsoc/bsoc_ssh_config 192.168.253.21 tcpdump -i ethbp1 -C 100 -W 1 -w /tmp/tcpdump_L2L1_filtering_off.pcap
    ...     :param connection <str> : asik master connection alias
    ...      2021/06/22  Su Li, update the BIP script version with V49, adapt the script for MultiRAT
    [Arguments]     ${interface}=pepbp1    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download   ${gnb_index}=${0}   ${du_index}=${0}
    ...             ${log_prefix}=${None}    ${bip_prefix}=tcpdump_L2L1    ${is_capture_right_bbmod}=${False}
    ...             ${asib_interface}=eths2    ${asil_interface}=ethbp1    ${kill_type}=2
    ${multiRAT}    Check if multiRAT BTS
    ${amia_right}    If GNB In Right Side Of AMIA    connection=${connection}
    run keyword if    ${multiRAT} and ${amia_right}    Connect To MultiRAT GNB Common Unit Master
    ${connection}    set variable if    ${multiRAT} and ${amia_right}    MultiRAT GNB Master    ${connection}
    run keyword if   '${multiRAT}'=='${False}' and ${is_capture_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection}
    ...               proxy=${connection}
    ${common_unit_type}    Get hardware type    alias=${connection}
    ${capture_interface}    set variable if    '${common_unit_type}'=='ASIB'    ${asib_interface}
    ...                                        '${common_unit_type}'=='ASIL'    ${asil_interface}
    ...                                        '${common_unit_type}'=='ASIK'    ${interface}
    ${kill_type}    set variable if    '${common_unit_type}'=='ASIL'    15    ${kill_type}
    Stop BIP Capture On ASIK    interface=${capture_interface}    connection=${connection}    kill_type=${kill_type}
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    connection=${connection}
    ...    download_type=${download_type}
    ...    log_prefix=${log_prefix}
    ...    bip_prefix=${bip_prefix}
    [Return]    ${list_log_path_local}

Precondition For ASOD Bip Capture
    [Documentation]    Precondition For ASOD Bip Capture,upload script to gnb and excute shell script.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${asod_mirror_script}=ASOD_mirror.sh
    ${store_script_path}      Set Variable    /ffs/run/config/scripts
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=rm -rf /tmp/asod_bip_*.pcap*    connection=ASIK_Master
    ${is_store_script_path_exists}    csn.file_exists    remote_path=${store_script_path}    connection=ASIK_Master
    Run keyword if    ${is_store_script_path_exists}==${False}
    ...    csn.execute    command=mkdir ${store_script_path}       connection=ASIK_Master
    csn.upload_file     local_path=${CURDIR}/${asod_mirror_script}    remote_path=${store_script_path}/${asod_mirror_script}
    ...    connection=ASIK_Master
    ${output}    csn.execute    command=chmod 777 ${store_script_path}/${asod_mirror_script}   connection=ASIK_Master
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    csn.Execute    command=sh ${store_script_path}/${asod_mirror_script} 6 11    connection=ASIK_Master
    ${output}    csn.execute    command=cat /var/run/cpss/ports/mirror_info |tail -n 1 |awk '{print $1,$2,$3}'   connection=ASIK_Master
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Start BIP Capture On ASOD
    [Documentation]    Start BIP Capture On ASOD.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_size_mbytes: size of file create, tcpdump -C.
    ...                :param number_of_files: number of files created, tcpdump -W.
    ...                :param save_time_interval: The saving time interval of capture message.
    ...                :param filter: filter message by message id.E.G ether[0x18:2]!=0x23a && ether[0x18:2]!=0x108
    ...                :param timeout: bip captrue timeout in backgroud.'s'for seconds,'m' for minutes,'h'for hours or 'd'for days
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${filter}=${EMPTY}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${file_size_mbytes}=200    ${number_of_files}=10    ${save_time_interval}=1    ${timeout}=15m
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ASIK_Master
    #Should be empty    ${output}
    ${cmd}=    catenate    timeout ${timeout} tcpdump -i pepbp1 -C ${file_size_mbytes} -W ${number_of_files} -G ${save_time_interval} -w
    ...    /tmp/asod_bip_%Y_%m%d_%H%M_%S.pcap "${filter}" &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Stop BIP Capture On ASOD
    [Documentation]    Stop BIP Capture On ASOD.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIK_Master
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=ASIK_Master
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Download ASOD BIP Logs To TestPC
    [Documentation]    Download ASOD BIP Logs To TestPC.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master    ${log_path}=${output_dir}    ${sample}=1
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${list_log_path_local}    Create List
    ${files}    csn.execute    command=ls -l /tmp/asod_bip_*.pcap* |awk '{print $9}'    connection=ASIK_Master
    ${files}    Split To Lines    ${files}
    ${length}=    get length     ${files}
    FOR    ${i}    IN RANGE    0    ${length}    ${sample}
        csn.Download file    remote_path=${files[${i}]}    local_path=${log_path}/${files[${i}].split("/")[2]}   connection=ASIK_Master
        Append to list    ${list_log_path_local}    ${log_path}/${files[${i}].split("/")[2]}
    END
    FOR    ${file}    IN    @{files}
        csn.execute    command=rm -rf ${file}     connection=ASIK_Master
    END
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
    [Return]    ${list_log_path_local}

BIP log capture and download
    [Documentation]    BIP log capture and download,return the log path.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_size_mbytes: size of file create, tcpdump -C.
    ...                :param number_of_files: number of files created, tcpdump -W.
    ...                :param save_time_interval: The saving time interval of capture message.
    ...                :param filter: filter message by message id.E.G ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135
    ...                :param sleep_time: capture bip log time, default is 30s
    ...                :param timeout: bip captrue timeout in backgroud.'s'for seconds,'m' for minutes,'h' for hours,default is 15m
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${filter}=${EMPTY}    ${timeout}=15m
    ...    ${file_size_mbytes}=200    ${number_of_files}=10    ${save_time_interval}=1    ${sleep_time}=30s
    Precondition For ASOD Bip Capture    gnb_index=${gnb_index}    du_index=${du_index}
    Start BIP Capture On ASOD    gnb_index=${gnb_index}    du_index=${du_index}    save_time_interval=${save_time_interval}    filter=${filter}
    ...    file_size_mbytes=${file_size_mbytes}    number_of_files=${number_of_files}    timeout=${timeout}
    sleep    ${sleep_time}
    Stop BIP Capture On ASOD    gnb_index=${gnb_index}    du_index=${du_index}
    ${log_path}    Download ASOD BIP Logs To TestPC    gnb_index=${gnb_index}    du_index=${du_index}
    [Return]    ${log_path}

Remove big log files
    [Documentation]    Remove big log files.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param filename: captured bip log.
    [Arguments]    ${filename}
    FOR    ${item}    IN    @{filename}
        Remove File    ${item}
    END

Modify gnbMirroring to add mirror port of abil slave
    [Documentation]    Author:Wang Yixiang
    ...     Add following command to gnbMirroring.sh to capture msg of abil slave
    ...    	dbgrrc mirror sport 21 dport $1 $2 both
	...     dbgrrc mirror sport 29 dport $1 $2 both
    [Arguments]    ${script_path}=/ffs/run/config/scripts    ${connection}=ASIK Master
    ${line_number}    csn.execute    command=awk '/enableMirroringInAsikRrc\\(\\)/{print NR}' ${script_path}/gnbMirroring.sh
    ...    connection=${connection}
    ${line_number}    replace string    ${line_number}   \n    ${SPACE}
    ${line_number}    replace string    ${line_number}   \r    ${SPACE}
    ${line_number}    evaluate     ${line_number}-2
    ${replace_cmd}   Catenate    sed -i '${line_number},${line_number}c \\\tdbgrrc mirror sport 21 dport $1 $2 both\\n\\tdbgrrc
    ...    mirror sport 29 dport $1 $2 both\\n}' ${script_path}/gnbMirroring.sh
    ${ret}    csn.execute    command=${replace_cmd}
    ...    connection=${connection}
