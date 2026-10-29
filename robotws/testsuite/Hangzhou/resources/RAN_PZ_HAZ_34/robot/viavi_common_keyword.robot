*** Settings ***
Documentation    This is related with cobham UE L3 call
...              Author: Ding Binmei
...              Squard: HZ MMW_SG1
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ./traffic_via_iperf.robot
Library     taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    taf.ue.tm500.asc      WITH NAME    asc
Library    robot.utils.robottime

*** Variables ***
${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts

${TMA_SSH_ALIAS}    tma_ssh
# After upgrade to Win10, telnet is no longer supported. So here the TMA_TELNET_ALIAS refers to TMA_SSH_ALIAS
${TMA_TELNET_ALIAS}    tma
${TMA_APP_ALIAS}    e500
${TMA_ASC_ALIAS}    ASC
${TMA_APP_PATH}    ${tl.ues[0].tma_path}
${ASIK_ALIAS}    ASIK Master

${E500_USER}    ${TM500_USER}
${E500_IP}    ${TM500_IP}
${E500_PW}    ${TM500_PW}
${E500_SSH_USER}    ${E500_USER}
${FSP1A_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${FSP1A_USER}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${FSP1A_PW}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${E500_ASC_USER}    switch
${E500_ASC_PW}    switch
${E500_ASC_PORT}    10011
${NEED_PROTOCAL_LOG}    ${False}


*** Keywords ***
# Reset viavi if not stable, this step is not intergrated in 'Precondition for attach', testers can call it by themselves if needed
Reset Viavi via ASC
    [Documentation]  Author: Iris Yin
    ...              Description: cycle cobham via ASC
    ...              ${tma_asc_alias} must be different in a test suite with muliple test cases.
    ...              Otherwise re-connection to cobham ASC will failed in second connection due to Socket is closed issue
    [Arguments]    ${username}=tm500    ${group}=Units-1    ${tma_asc_alias}=${TMA_ASC_ALIAS}    ${cobham_asc_ip}=192.168.10.10
    Wait until keyword succeeds    2 min    10 s    Connect to cobham ASC via ssh    tma_asc_alias=${tma_asc_alias}
    asc.set username    name=${username}    connection=${tma_asc_alias}
    ${power_off_output}    asc.set power off    group_name=${group}    connection=${tma_asc_alias}
    should contain    ${power_off_output}    Status: 0: Ok
    sleep    10s
    ${power_on_output}    asc.set power on    group_name=${group}    connection=${tma_asc_alias}
    should contain    ${power_on_output}    Status: 0: Ok
    sleep    10s
    wait until keyword succeeds    5min    5sec    Ping cobham asc ip    cobham_asc_ip=${cobham_asc_ip}
    sleep    10s
    [Teardown]    Run keyword and ignore error    Disconnect from cobham ASC via ssh    tma_asc_alias=${tma_asc_alias}

Connect to cobham ASC via ssh
    [Documentation]  Author: Iris Yin
    ...              Description: Access to cobham ASC via ssh. Precondition is that the port has been mapped in control pc
    [Arguments]  ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.Connect to    hostname=${E500_IP}    username=${E500_ASC_USER}    password=${E500_ASC_PW}    port=${E500_ASC_PORT}
    ...            alias=${tma_asc_alias}

Disconnect from cobham ASC via ssh
    [Arguments]    ${tma_asc_alias}=${TMA_ASC_ALIAS}
   csn.disconnect    connection=${tma_asc_alias}

Ping cobham asc ip
    [Documentation]  Author: Iris Yin
    ...              Description: ping cobham asc IP
    [Arguments]    ${cobham_asc_ip}=192.168.10.10        ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    Wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    csn.send command    command=ping ${cobham_asc_ip}    connection=${tma_ssh_alias}
    ${response}    csn.read output    connection=${tma_ssh_alias}
    Should Contain    ${response}    Reply from ${cobham_asc_ip}: bytes=32
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

# This step is only needed after GNB restart, it's not intergrated in 'Precondition for attach', testers can call it by themselves if needed
Synchron gNB and cobham
    [Documentation]    Author: Yin Iris
    ...                Description: This is to sync between GNB and cobham
    [Arguments]    ${alias}=${ASIK_ALIAS}
    Log to console    Start to sync GNB and cobham
    ${cmd_sync_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                             -t execute --action setClock10MHz --args clock10MHz=1
    ${cmd_sync_frame_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                    -t execute --action setFrameClock --args frameClock=1
    ${output_sync_clock}    csn.execute    ${cmd_sync_clock}    connection=${alias}
    ${output_sync_frame_clock}    csn.execute    ${cmd_sync_frame_clock}    connection=${alias}

# Precontions for attach
Precondition for attach
    [Timeout]  10 min
    [Documentation]    Author: Ding Binmei
    ...                Description: precondition for UE attach on cobham
    ...                Logic: 1. Kill tma process in case manual forget about this step
    ...                       2. Open tma software and run init_config script to connect to cobham
    ...                       3. Start logging on cobham so that protocol logs are captured
    ...                       4. Run cell config script and do ue attach( Will retry 10 times if attach failed)
    ...                ${is_protocal_log_needed} if True, then it means protocal log is captured
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${tma_path}=${TMA_APP_PATH}
    ...            ${is_protocal_log_needed}=${False}
    Cobham connection and start logging    e500_script_path=${e500_script_path}      tma_path=${tma_path}
    ...    is_protocal_log_needed=${is_protocal_log_needed}
    tm500_hangzhou.Perform cell search    cell_search_script_path=${e500_script_path}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}

Cobham connection and start logging
    [Timeout]  20 min
    [Documentation]    Yuan le: Split step from keyword Precondition for attach
    ...                Ding Binmei 2019-6-27: Add empty cobham session logs to this keyword
    ...                Description: precondition for UE attach on cobham
    ...                Logic: 1. Kill tma process in case manual forget about this step
    ...                       2. Empty cobham session logs
    ...                       2. Open tma software and run init_config script to connect to cobham
    ...                       3. Start logging on cobham so that protocol logs are captured
    ...              ${is_protocal_log_needed} if True, then it means protocal log is captured
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${tma_path}=${TMA_APP_PATH}
    ...            ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ...            ${connection}=${TMA_SSH_ALIAS}
    ...            ${is_protocal_log_needed}=${NEED_PROTOCAL_LOG}
    Kill tma process    tma_telnet_alias=${TMA_TELNET_ALIAS}
    wait until keyword succeeds    5 min    20 s    Clear cobham session logs    tma_log_path=${tma_log_path}    connection=${connection}
    tm500_hangzhou.Precondition_SSH    tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${tma_path}
    wait until keyword succeeds    2 min    10 s    tm500_hangzhou.Connect    tm500_alias=${TMA_APP_ALIAS}
    tm500_hangzhou.Connect hw and initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    Run keyword if    ${is_protocal_log_needed}    Start logging on cobham

Kill tma process
    [Documentation]    Author: Ding Binmei
    ...                Description: Kill tma process
    [Arguments]    ${tma_telnet_alias}=${TMA_TELNET_ALIAS}    ${retry}=${3}
    FOR    ${i}    IN RANGE    ${retry}
           ${tma_pid}    tm500_hangzhou.Postcondition_SSH    tma_alias=${tma_telnet_alias}
           exit for loop if    "${tma_pid}"=="${EMPTY}"
    END
    should be empty    ${tma_pid}
    Sleep    5s

Clear cobham session logs
    [Documentation]  Author: Ding Binmei
    ...              Description: Clear all session logs for cobham before starting the new session
    [Arguments]    ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ...    ${connection}=${TMA_SSH_ALIAS}
    Wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh    tma_ssh_alias=${connection}
    csn.send_command    command=cd "${tma_log_path}";rm -rf *session*    connection=${connection}
    ${output_remove_error}    csn.read_error    connection=${connection}
    Should be empty    ${output_remove_error}    msg=Fail to remove cobham session logs, error message: ${output_remove_error}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

Start logging on cobham
    [Documentation]  Author: Ding Binmei
    ...              Description: Start logging on cobham TMA so that the protocol logs can be captured
    ...                           It is helpful in debugging phase
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_start_logging}    tm500_remote.send_command    command=#$$START_LOGGING    alias=${connection}
    should contain    ${output_start_logging}      START_LOGGING 0x00 OK    msg=Start logging on cobham failed

Stop logging on cobham
    [Documentation]  Author: Ding Binmei
    ...              Description: Stop logging on cobham TMA and convert log to txt
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_stop_logging}    tm500_remote.send_command    command=#$$STOP_LOGGING   alias=${connection}
    should contain    ${output_stop_logging}      STOP_LOGGING 0x00 OK    msg=Stop logging on cobham failed
    ${output_disconnect}    tm500_remote.send_command    command=#$$DISCONNECT   alias=${connection}
    Should Contain    ${output_disconnect}    DISCONNECT 0x00 OK
    ${output_convert_to_txt}    tm500_remote.send_command    command=#$$CONVERT_TO_TEXT 2   alias=${connection}
    Should Contain    ${output_convert_to_txt}    CONVERT_TO_TEXT 0x00 ok

# Attach
Cobham retry ue attach if failed
    [Timeout]    10 min
    [Documentation]    Author: Ding Binmei
    ...               Will retry detach and attach if attach failed. Max retry time is 10
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${retry_time}=${10}    ${e500_alias}=${TMA_APP_ALIAS}
    ...    ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream}=142D28DFAFC7370CD311FAFC7370CC28
    ...    ${rrc_count}=1
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
           ${attach_status}    run keyword and return status  E500 attach and verify
           ...                              attach_script_path=${e500_script_path}/NSA_5G_UEattach.txt
           ...                              e500_alias=${e500_alias}
           ...                              is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
           ...                              mul_drb_code_stream=${mul_drb_code_stream}    rrc_count=${rrc_count}
           Exit for loop if    ${attach_status}==${True}
           tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt
           ${detach_time}    Evaluate    ${detach_time}+1
           Log to console    Attached failed, retry detach time ${detach_time}
           sleep    1s
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed
    [Return]    ${detach_time}

E500 attach and verify
    [Documentation]    Author: Ding Binmei
    ...                Description: ${is_need_to_check_mul_drb_established} can be set to ${True} or ${False} to decide whether
    ...                             to check mul drb has established, default value is ${False}
    ...    ${mul_drb_code_stream}: needs to set some value when mul drb is required to check.
    [Arguments]    ${attach_script_path}    ${e500_alias}=${TMA_APP_ALIAS}    ${is_need_to_check_mul_drb_established}=${False}
    ...    ${mul_drb_code_stream}=142D28DFAFC7370CD311FAFC7370CC28    ${rrc_count}=1
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=  tm500_remote.send script  ${attach_script_path}  alias=${e500_alias}
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    Run keyword if    ${is_need_to_check_mul_drb_established}==${True}    Wait until code stream is triggered    code_stream=${mul_drb_code_stream}
    ${all_response}    Verify string in viavi response    string=NR-RRCReconfigurationComplete    count=${rrc_count}    initial_response=${response}
    ...    retry_time=10s    unwanted_string=RRC Leave Connected Cell    e500_alias=${e500_alias}
    ${all_response}    Verify string in viavi response    string=Random Access Complete    count=2    initial_response=${all_response}
    ...    retry_time=10s    unwanted_string=RRC Leave Connected Cell    e500_alias=${e500_alias}
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set suite variable    ${UE_IP}    ${e500_ue_ip}

Wait until code stream is triggered
    [Documentation]  Author: Ding Binmei
    ...              Description: ${E500_USER} and ${TMA_SSH_ALIAS} are all defined in Variables of this file.
    ...                           Wait until code stream is triggered from cobham command log.
    ...                           Code stream values can be selected by users based on case user scenario
    ...             ${trigger_time}: Refers to how many times does the code stream been triggered. Add this parameter to support for 1200-E cases
    [Arguments]    ${code_stream}    ${connection}=${TMA_SSH_ALIAS}    ${timeout}=20 s    ${trigger_time}=${1}   ${ue_idx}=0
    ...    ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ${command_log_file_path}    Get cobham command log file path    tma_log_path=${tma_log_path}   connection=${connection}
    Wait until keyword succeeds    ${timeout}    1 s    Verify code stream is triggered from cobham command log
    ...       code_stream=${code_stream}
    ...       cobham_command_log_file_path=${command_log_file_path}
    ...       connection=${connection}
    ...       trigger_time=${trigger_time}
    ...       ue_idx=${ue_idx}

Verify code stream is triggered from cobham command log
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${code_stream}    ${cobham_command_log_file_path}    ${connection}=${TMA_SSH_ALIAS}    ${trigger_time}=${1}   ${ue_idx}=0
    ${cmd_search_code_stream_in_file}    set variable
    ...    cat "${cobham_command_log_file_path}"|grep -a "${code_stream['prefix']}"|grep -a "UE Id ${ue_idx}"
    csn.send command    command=${cmd_search_code_stream_in_file}    connection=${connection}
    ${matched_code_stream_list}    csn.read output    connection=${connection}
    run keyword if    ${trigger_time}==${None}
    ...    Should Contain    container=${matched_code_stream_list}   item=${code_stream['code_stream']}   msg=${code_stream} is not triggered
    run keyword if    ${trigger_time}!=${None}
    ...    should_contain_x_times       item1=${matched_code_stream_list}     item2=${code_stream['code_stream']}    count=${trigger_time}
    ...    ignore_case=${TRUE}    msg=${code_stream} is not triggered

Verify string in viavi response
    [Documentation]    Author: Cui Lingxue    5G_PZ_MMW_HZ_1_SG
    ...    Description: WA in case send script does not return the full response.
    ...        Will look up ${string} in full response for ${count} times.
    ...        Will fail if ${unwanted_string} match in full response.
    ...        Keyword will retry several times with ${retry_interval} for total retry time ${retry_time}.
    [Arguments]    ${string}    ${initial_response}    ${unwanted_string}=${EMPTY}    ${retry_time}=10s    ${retry_interval}=200ms    ${count}=1
    ...    ${e500_alias}=${TMA_APP_ALIAS}
    ${retry_time}        timestr_to_secs    ${retry_time}
    ${retry_interval}    timestr_to_secs    ${retry_interval}
    ${repeat_times}      evaluate    ${retry_time}//${retry_interval}
    ${all_response}    set variable    ${initial_response}
    FOR    ${i}    IN RANGE    ${repeat_times}
           ${current_response}    tm500_remote.read_responses    alias=${e500_alias}
           ${all_response}    catenate    ${all_response}    ${current_response}
           ${match_string}    run keyword and return status    should_contain_x_times
           ...    ${all_response}    ${string}    count=${count}    msg=String "${string}" is not found in response
           run keyword if    '${unwanted_string}'!='${EMPTY}'    should_not_match_regexp    ${all_response}    ${unwanted_string}
           ...    msg=String "${unwanted_string}" should not be found in response\n
           exit for loop if    ${match_string}
           sleep    ${retry_interval}
    END
    should be true    ${match_string}    msg=String "${string}" is not found in response
    [Return]    ${all_response}

Get ue ip address
    [Documentation]  Author: Ding Binmei
    ...              Description: Get ue ip from attach response output
    [Arguments]    ${attach_response}
    @{ue_ip_list}    Get regexp matches    ${attach_response}    IPv4 Address:(.*)    1
    ${ue_ip}    strip_string    ${ue_ip_list}[0]
    [Return]    ${ue_ip}

# Detach
Cobham UE detach
    [Documentation]  Author: Ding Binmei
    ...              Description: ${is_protocal_log_needed} if True, then it means protocal log is captured, so need to stop logging
    [Arguments]  ${e500_script_path}=${E500_SCRIPTS_BASE}    ${is_protocal_log_needed}=${NEED_PROTOCAL_LOG}
    tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt
    Run keyword if    ${is_protocal_log_needed}    Stop logging on cobham
    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}

# This step can be added to case teardown, if tester would like to collect the tma session logs
Collect tma logs to test pc
    [Documentation]  Author: Ding Binmei
    ...              Description: Move tma logs to test pc for debug purpose
    ...              Logic: 1. Remove all tar.gz logs under cobham log folder
    ...                     2. Get the latest session log folder name
    ...                     3. compress the log and move it from cobham control pc to test pc
    [Arguments]    ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ...    ${connection}=${TMA_SSH_ALIAS}
    ...    ${local_path}=${TS_CASE_LOG_PATH}
    Wait until keyword succeeds    2min    10s    traffic_via_iperf.Connect to cobham control pc via ssh    tma_ssh_alias=${connection}
    ${cmd_clear_compressed_log_files}    set variable    cd "${tma_log_path}";rm -rf *.tar.gz
    csn.execute    command=${cmd_clear_compressed_log_files}    connection=${connection}
    ${cmd_get_latest_tma_log_folder}    set variable  ls -tr "${tma_log_path}"|grep -i _session|grep -v "tar.gz"|tail -n 1
    csn.send command    command=${cmd_get_latest_tma_log_folder}    connection=${connection}
    ${tma_log_folder_name}    csn.read output    connection=${connection}
    ${tma_log_folder_name}    Strip string    ${tma_log_folder_name}
    Log to console    Start to compress log folder for ${tma_log_path}/${tma_log_folder_name}
    ${compress_tma_log_folder_name}    set variable    ${tma_log_folder_name}.tar.gz
    ${cmd_compress_log_folder}    set variable  cd "${tma_log_path}";tar -zcvf ${compress_tma_log_folder_name} ${tma_log_folder_name}
    csn.execute    command=${cmd_compress_log_folder}    connection=${connection}
    wait until keyword succeeds  10s    2s    csn.assert_file_exists    remote_path=${tma_log_path}/${compress_tma_log_folder_name}
    ...                                                                 connection=${connection}
    ...                       msg=File ${compress_tma_log_folder_name} is not generated
    Log to console    Copy logs from cobham control pc to test pc
    csn.download file    remote_path=${tma_log_path}/${compress_tma_log_folder_name}
    ...                  local_path=${local_path}/${compress_tma_log_folder_name}
    ...                  connection=${connection}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

Get cobham session log path
    [Documentation]  Author: Ding Binmei
    ...              Description: Return the tma session log path. Example output: XXX/XXX/190627_221508_session
    [Arguments]    ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ...    ${connection}=${TMA_SSH_ALIAS}
    ${cmd_get_latest_tma_log_folder}    set variable  ls -tr "${tma_log_path}"|grep -i _session|grep -v "tar.gz"|tail -n 1
    csn.send command    command=${cmd_get_latest_tma_log_folder}    connection=${connection}
    ${tma_log_folder_name}    csn.read output    connection=${connection}
    ${tma_log_folder_name}    Strip string    ${tma_log_folder_name}
    Should not be empty    ${cmd_get_latest_tma_log_folder}    msg=There is no session logs found
    ${tma_log_folder_path}    Join path    ${tma_log_path}    ${tma_log_folder_name}
    [Return]  ${tma_log_folder_path}

Get cobham command log file path
    [Documentation]  Author: Ding Binmei
    ...              Description: Return the command log file path. Example output: XXX/XXX/190627_221508_session/190627_221508_Command_Log000.txt
    [Arguments]    ${tma_log_path}=/cygdrive/c/Users/${E500_USER}/Documents/Aeroflex/TM500/5G NR/Test Mobile Application/Logged Data
    ...    ${connection}=${TMA_SSH_ALIAS}
    ${tma_log_folder_path}    Get cobham session log path    tma_log_path=${tma_log_path}    connection=${connection}
    ${cmd_get_latest_command_log_file_name}    set variable    ls "${tma_log_folder_path}"|grep -i command
    csn.send command    command=${cmd_get_latest_command_log_file_name}    connection=${connection}
    ${command_log_file_name}    csn.read output    connection=${connection}
    ${command_log_file_name}    Strip string    ${command_log_file_name}
    Should not be empty    ${command_log_file_name}    msg=No command log found under ${tma_log_folder_path}
    ${command_log_file_path}    Join path    ${tma_log_folder_path}    ${command_log_file_name}
    [Return]  ${command_log_file_path}

# Check throughput from cobham
Get values on cobham by executing check throughput command
    [Documentation]    Author: Ding Binmei
    ...                Description: Check throughput from cobham side
    ...                ${throughput_log_file_path}: Used to save the ENB throughput output log get from cobham.
    ...                                                Default to save it on test pc of case log directory
    ...                ${ue_index}: used to identify for ue, number value, can start from 0...
    ...                ${rat_type}: value can be 0 or 1: 0 refers to ENB; 1 refers to GNB
    ...                Return a dictionary about the check items: Keys can be :
    ...                   ul_average_tput, dl_average_tput, dl_bler, ul_tput_on_rb, dl_tput_on_rb
    [Arguments]    ${throughput_log_file_path}=${TS_CASE_LOG_PATH}    ${e500_alias}=${TMA_APP_ALIAS}
    ...      ${ue_index}=0    ${rat_type}=1    ${rb_id}=6
    [Timeout]    5 minutes
    ${is_enb_or_gnb}    Set variable if    '${rat_type}'=='0'    ENB
    ...                                    '${rat_type}'=='1'    GNB
    ...                                     Invalid input
    should not contain    ${is_enb_or_gnb}    Invalid input
    ...    msg=Invalid input for rlt value: ${rat_type}, valid value should be 0 or 1
    ${cmd_check_tput}    Set variable    forw mte Getstats [0] [${ue_index}] [${rat_type}]
    ${response}    tm500_remote.send command    command=${cmd_check_tput}  alias=${e500_alias}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Log to console    Execute check ${is_enb_or_gnb} throughput command and write to file
    Run   echo '${response}'>${throughput_log_file_path}/Check_Tput_Cobham_${is_enb_or_gnb}_UE${ue_index}_${timestamp}.txt

    ${ul_average}    Run    echo '${response}' |grep -A 5 "UL-SCH (PCC)(SCG)"|awk '$3=="Average:" {print $4}'
    ${len_ul_average_ouput}    Get length    ${ul_average.strip()}
    ${ul_average}    Set variable if    ${len_ul_average_ouput} == 0    0    ${ul_average}
    ${ul_average_tput}    Evaluate  float("${ul_average}") / 1000.0 / 1000.0

    ${dl_average}    Run    echo '${response}' |grep -A 6 "DL-SCH (PCC)(SCG)"|awk '$3=="Average:" {print $4}'
    ${len_dl_average_ouput}    Get length    ${dl_average.strip()}
    ${dl_average}    Set variable if    ${len_dl_average_ouput} == 0    0    ${dl_average}
    ${dl_average_tput}    Evaluate  float("${dl_average}") / 1000.0 / 1000.0

    ${ul_tput_on_rb}    Run    echo '${response}' |grep -A 1 "UL RB (RB id: ${rb_id}"|awk '$3=="Average:" {print $4}'
    ${len_ul_tput_on_rb}    Get length    ${ul_tput_on_rb.strip()}
    ${ul_tput_on_rb}    Set variable if    ${len_ul_tput_on_rb} == 0    0    ${ul_tput_on_rb}
    ${ul_tput_on_rb}    Evaluate  float("${ul_tput_on_rb}") / 1000.0 / 1000.0

    ${dl_tput_on_rb}    Run    echo '${response}' |grep -A 1 "DL RB (RB id: ${rb_id}"|awk '$3=="Average:" {print $4}'
    ${len_dl_tput_on_rb}    Get length    ${dl_tput_on_rb.strip()}
    ${dl_tput_on_rb}    Set variable if    ${len_dl_tput_on_rb} == 0    0    ${dl_tput_on_rb}
    ${dl_tput_on_rb}    Evaluate  float("${dl_tput_on_rb}") / 1000.0 / 1000.0

    ${dl_bler}    Run    echo '${response}' |grep -a -A 6 "DL-SCH (PCC)(SCG)"|awk '$3=="[BLER]" {getline;print $3}'
    ${len_dl_bler_output}    Get length    ${dl_bler.strip()}
    ${dl_bler}    Set variable if    ${len_dl_bler_output} == 0    1    ${dl_bler}
    ${dl_bler}    Evaluate    float("${dl_bler}")

    ${ul_bler}    Run    echo '${response}' |grep -a -A 4 "UL-SCH (PCC)(SCG)"|awk '$6=="[BLER]" {getline;print $6}'
    ${len_ul_bler_output}    Get length    ${ul_bler.strip()}
    ${ul_bler}    Set variable if    ${len_ul_bler_output} == 0    1    ${ul_bler}
    ${ul_bler}    Evaluate    float("${ul_bler}")

    &{dict_result}    Create dictionary
    Set to dictionary    ${dict_result}    ul_average_tput    ${ul_average_tput}
    Set to dictionary    ${dict_result}    dl_average_tput    ${dl_average_tput}
    Set to dictionary    ${dict_result}    ul_tput_on_rb      ${ul_tput_on_rb}
    Set to dictionary    ${dict_result}    dl_tput_on_rb      ${dl_tput_on_rb}
    Set to dictionary    ${dict_result}    dl_bler            ${dl_bler}
    Set to dictionary    ${dict_result}    ul_bler            ${ul_bler}
    [Return]    ${dict_result}

Get values on cobham by executing check ENB throughput command
    [Documentation]    Author: Ding Binmei
    ...                Description: Check throughput from cobham side for ENB
    ...                ${throughput_log_file_path}: Used to save the ENB throughput output log get from cobham.
    ...                                                Default to save it on test pc of case log directory
    ...                ${ue_index}: used to identify for ue, number value, can start from 0...
    ...                Return a dictionary about the check items: Keys can be : ul_average_tput, dl_average_tput, dl_bler
    [Arguments]    ${throughput_log_file_path}=${TS_CASE_LOG_PATH}    ${e500_alias}=${TMA_APP_ALIAS}        ${ue_index}=0
    [Timeout]    5 minutes
    ${dict_result}    Get values on cobham by executing check throughput command    throughput_log_file_path=${throughput_log_file_path}
    ...    e500_alias=${e500_alias}    ue_index=${ue_index}    rat_type=0
    [Return]    ${dict_result}

Get values on cobham by executing check GNB throughput command
    [Documentation]    Author: Ding Binmei
    ...                Description: Check throughput from cobham side for GNB
    ...                ${throughput_log_file_path}: Used to save the GNB throughput output log get from cobham.
    ...                                                Default to save it on test pc of case log directory
    ...                ${ue_index}: used to identify for ue, number value, can start from 0...
    ...                Return a dictionary about the check items: Keys can be : ul_average_tput, dl_average_tput, dl_bler
    [Arguments]    ${throughput_log_file_path}=${TS_CASE_LOG_PATH}    ${e500_alias}=${TMA_APP_ALIAS}    ${ue_index}=0    ${rb_id}=6
    [Timeout]    5 minutes
    ${dict_result}    Get values on cobham by executing check throughput command    throughput_log_file_path=${throughput_log_file_path}
    ...    e500_alias=${e500_alias}    ue_index=${ue_index}    rat_type=1    rb_id=${rb_id}
    [Return]    ${dict_result}

Disconnect cobham connection
    [Documentation]    Author: Cui Lingxue 5G_PZ_MMW_HZ_1_SG
    [Arguments]    ${is_protocal_log_needed}=${False}    ${e500_alias}=${TMA_APP_ALIAS}
    Run keyword if    ${is_protocal_log_needed}    Stop logging on cobham    connection=${e500_alias}
    tm500_hangzhou.Disconnect    tm500_alias=${e500_alias}

Precondition for attach with retry
    [Documentation]    Author: Cui Lingxue 5G_PZ_MMW_HZ_1_SG
    ...    Retry precondition for several times in case init cobham failure or cell search failure.
    ...    :param ${is_protocal_log_needed}: if True, then it means protocal log is captured
    ...    :param ${repeat_times}: retry precondition for attach for ${repeat_times} times.
    [Arguments]    ${repeat_times}=${3}    ${is_protocal_log_needed}=${False}    ${tma_path}=${TMA_APP_PATH}
    ...    ${e500_script_path}=${E500_SCRIPTS_BASE}
    FOR    ${i}    IN RANGE    ${repeat_times}
           ${cell_search_succeed}    run keyword and return status    Precondition for attach    e500_script_path=${e500_script_path}
           ...    tma_path=${tma_path}    is_protocal_log_needed=${is_protocal_log_needed}
           run keyword if    '${cell_search_succeed}'=='${False}'    Disconnect cobham connection  is_protocal_log_needed=${is_protocal_log_needed}
           exit for loop if    ${cell_search_succeed}
    END
    should be true    ${cell_search_succeed}
