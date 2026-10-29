*** Settings ***
Documentation     Author: debbie.wang@nokia-sbell.com
...               Description: about all kinds of ue attach、detach、traffic keywords

Library           taf.transport.ssh    WITH NAME    csn
################################VIAVI###################################
#Resource          ../../../../resources/common/tm500.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
################################samsung##################################
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource          login_logout.robot


*** Variables ***
${TMA_SSH_ALIAS}    tma
${TMA_APP_ALIAS}    e500
${TAM_APP_PATH}    ${tl.ues[0].tma_path}
${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
${E500_IP}        ${tl.ues[0].tma_host.addr}
${E500_USER}      ${tl.ues[0].tma_host.username}
${E500_PW}        ${tl.ues[0].tma_host.password}
${E500_SSH_DOMAIN}    ${tl.ues[0].tma_host.private_key}
${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0]}
${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[1]}

*** Keywords ***
################################samsung##################################
power ue attach
    [Documentation]    power ue attach,support samsung S20/askey,support one ue or multi ue
    [Arguments]    ${ue_num}     ${ue_type}=samsung
    FOR    ${item}    IN RANGE    ${ue_num}
        log to console    attach ue ${item}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${item}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=${ue_type}    log_type=Aasyslog
        power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start power ue traffic ul and dl
    [Documentation]    start traffic about ul、dl、ul and dl,support samsung S20/askey
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung    ${ul_iperf_port}=${ul_power_port_list}
    ...    ${dl_iperf_port}=${dl_power_port_list}    ${ue_mode}=NSA
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_iperf_port}[${item}]    ue_mode=${ue_mode}    process_num=${1}
         sleep    1s
         run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${dl_iperf_port}[${item}]    ue_mode=${ue_mode}    process_num=${1}
    END

stop power ue traffic ul and dl
    [Documentation]    stop traffic about ul、dl、ul and dl,support samsung S20/askey
    [Arguments]    ${ue_num}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    ...    ${ul_iperf_port}=@{ul_power_port_list}    ${dl_iperf_port}=@{dl_power_port_list}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}        iperf_port=${ul_iperf_port}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${dl_iperf_port}[${item}]
    END

detach power ue
    [Arguments]    ${ue_num}=${1}    ${ue_type}=samsung
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=${ue_type}
    END

Synchron gNB and VIAVI
    [Arguments]    ${asik_addr}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
                   ${asik_username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
                   ${asik_password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    ${alias}=${asik}
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=${alias}
    ${cmd_export_pylib}    Evaluate    'export PYTHONPATH=/opt/hwmt/python:/opt/hwmt/lib/python2.7/site-packages'
    ${cmd_sync_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                             -t execute --action setClock10MHz --args clock10MHz=1
    ${cmd_sync_frame_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                    -t execute --action setFrameClock --args frameClock=1
    csn.send command    ${cmd_export_pylib}    connection=${alias}
    ${output_sync_clock}    csn.execute    ${cmd_sync_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_clock}    MitAaSysComFinalize ok
    ${output_sync_frame_clock}    csn.execute    ${cmd_sync_frame_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_frame_clock}    MitAaSysComFinalize ok

Cobham UE attach
    [Arguments]    ${BW}    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA    ${tma_path}=${TAM_APP_PATH}    ${ue_num}=1
    [Timeout]    10 min
    tm500.Precondition_SSH    TMA_PATH=${tma_path}
    wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
    tm500.Connect HW and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/${type}_5G_Cell_Config_${BW}.txt    tm500_alias=${TMA_APP_ALIAS}
    Retry ue attach if failed    type=${type}    attach_script_path=${e500_script_path}/${type}_5G_${ue_num}UEattach.txt
    ...    detach_script_path=${e500_script_path}/${type}_5G_UEdetach.txt    e500_alias=${TMA_APP_ALIAS}
    Sleep    5s

Retry ue attach if failed
    [Arguments]    ${type}    ${attach_script_path}    ${detach_script_path}    ${retry_time}=${3}    ${e500_alias}=${TMA_APP_ALIAS}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status     E500 attach and verify
    ...    attach_script_path=${attach_script_path}    type=${type}    e500_alias=${e500_alias}
        Exit for loop if    ${attach_status}==${True}
        run keyword and ignore error    tm500.TM500 Detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${detach_script_path}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console    Attached failed, retry detach time ${detach_time}
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed

E500 attach and verify
    [Arguments]    ${attach_script_path}    ${type}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    ${attach_script_path}    alias=${e500_alias}
    Sleep    5s
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    run keyword if    '${type}'=='NSA'    NSA L3 call Check    response=${response}
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

Cobham UE detach
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA
    [Timeout]    5 min
    ${log}=    tm500_remote.send script    ${e500_script_path}/${type}_5G_UEdetach.txt    alias=${TMA_APP_ALIAS}
    ${status}    run keyword and return status    Should contain    ${log}    DTRC
    Run Keyword If    '${status}'=='False'    tm500_remote.send command    command=#$$DISCONNECT    alias=${TMA_APP_ALIAS}
    tm500.Disconnect    tm500_alias=${TMA_APP_ALIAS}
    run keyword and ignore error  csn.disconnect    connection='BB1'
