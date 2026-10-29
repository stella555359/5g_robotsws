*** Settings ***
Documentation     author: Debbie Wang
...               contact: debbie.wang@nokia-sbell.com
...               squad group: mmw_SG_04
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
#Resource         ../../../../../resources/common/DEPRECATED/wireshark_parsing.robot
#Library          ../../5GC001726/Resources/common_event_trace_log_analysis.py
Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/common_event_trace_log_analysis.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          ../../5GC001655/Resources/1347_common_keyword.robot
Variables         ./5GC000523_modify_para.py
Resource          ./power_ue_sumsang_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_34/5GC002040_A/Resources/5GC002040_common_checkpoints.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource          ../../../libraries/biplog_capture/biplog_capture.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
Library           taf.transport.ssh    WITH NAME    csn

*** Variables ***
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
${523_default_scf}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_0_800_DU.xml
${E500_SCRIPTS_BASE_523}    ${CURDIR}/E500_scripts_523
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${ul_port_list}    ${tl.ues[0].iperf_details.ports}
${tma_ssh_alias}    tma_ssh
${dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${dl_full_throughput}    600M
${ul_throughput}    50M
${ul_time}    99999
${test_bler_first_cmd}    forw mte Getstats [0] [0] [0]
${test_bler_second_cmd}    forw mte Getstats [0] [0] [1]
${523_TS_CASE_LOG_PATH}    ${CURDIR}
${523_X2}    S1-X2AP_523.pcap
${523_s1}    S1AP_4G.pcap
${gNB_ip}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${LUA_SCRIPT_PATH}      /home/ute/Downloads/lua/generated_luashark/luashark.lua
${TSHARK_PATH}      /usr/bin/tshark
${bip_log_name}      tcpdumpL2L1_filtering_off.pcap
${eNB_ip}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0:4]}
${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[4:8]}
${CURDIR_path}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/


*** Keywords ***
start tti trace
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Modify 523_SCF File and Commissioning
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${523_scf}=${523_default_scf}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${523_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${new_scf_file}

Cobham UE attach
    [Arguments]    ${BW}    ${e500_script_path}=${E500_SCRIPTS_BASE_523}    ${type}=NSA    ${tma_path}=${TAM_APP_PATH}    ${ue_num}=1
    [Timeout]    10 min
    tm500.Precondition_SSH    TMA_PATH=${tma_path}
    wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
    tm500.Connect HW and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/${type}_5G_Cell_Config_${BW}.txt    tm500_alias=${TMA_APP_ALIAS}
    5GC000523_common_keyword.Retry ue attach if failed    type=${type}    attach_script_path=${e500_script_path}/${type}_5G_${ue_num}UEattach.txt
    ...    detach_script_path=${e500_script_path}/${type}_5G_UEdetach.txt    e500_alias=${TMA_APP_ALIAS}
    Sleep    5s

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_index=${item}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ...    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${1}
         sleep    1s
         run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${1}
    END


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
    ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

Retry ue attach if failed
    [Arguments]    ${type}    ${attach_script_path}    ${detach_script_path}    ${retry_time}=${3}    ${e500_alias}=${TMA_APP_ALIAS}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status    5GC000523_common_keyword.E500 attach and verify
    ...    attach_script_path=${attach_script_path}    type=${type}    e500_alias=${e500_alias}
        Exit for loop if    ${attach_status}==${True}
        tm500.TM500 Detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${detach_script_path}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console    Attached failed, retry detach time ${detach_time}
        ...    AND
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed

E500 attach and verify
    [Arguments]    ${attach_script_path}    ${type}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    filename=${attach_script_path}    alias=${e500_alias}
    Sleep    5s
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    run keyword if    '${type}'=='NSA'    5GC000523_common_keyword.NSA L3 call Check    response=${response}
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

NSA L3 call Check
    [Arguments]    ${response}    ${cmd}=${test_bler_first_cmd}
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    ${response_verify_NR_attach}    tm500_remote.send command    command=${cmd}    alias=${TMA_APP_ALIAS}
    Should contain    ${response_verify_NR_attach}    L2 Random Access Complete
    ...    msg=UE attach failed, string "L2 Random Access Complete" is not found

GNB ready and UE attach capture X2 log
    [Arguments]    ${ue_num}    ${e500_script_path}=${E500_SCRIPTS_BASE_523}    ${BW}=${100}
    ...    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}
#    Modify 523_SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
    COAM Wait for gnb ready and cell setup
    Synchron gNB and VIAVI
    Start to Capture X2 Log on Asik 523   filename=${523_X2}
    5GC000523_common_keyword.Cobham UE attach    e500_script_path=${e500_script_path}    ue_num=${ue_num}    BW=${BW}
    sleep    3s
    Stop and Download Log 523    filename=${523_X2}

Start to Capture X2 Log on Asik 523
    [Arguments]    ${filename}
    Connect to Common Unit Master
#    csn.send command    command=killall tcpdump    connection=ASIK Master
    Start to Capture wireshark Log 523    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ASIK Master

Start to Capture wireshark Log 523
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Stop and Download Log 523
    [Arguments]    ${filename}    ${asik}=ASIK Master
    Connect to Common Unit Master
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    Csn.Disconnect	connection=${asik}

Download BIP Logs
    [Arguments]    ${saved_bip_log_name}     ${connection}=ASIK Master
    Connect to Common Unit Master    alias=${connection}
    csn.download_file   remote_path=/tmp/${bip_log_name}   local_path=${LOG_PATH}/${saved_bip_log_name}   connection=${connection}

Capture BIP log
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts
    sleep    2s
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${connection}   ${filter}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert pcap file to txt
    [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
    [Teardown]  run keyword and ignore error  csn.Disconnect	connection=${connection}

suite setup to prepare default scf
    [Arguments]     ${connection}=GNB_OAM
    robot_common_operations.Common Suite Setup
    Set Default scf name
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM

Set Default scf name
    [Arguments]    ${connection}=GNB_OAM
    Log To Console  Set Default scf name
    Connect to gnb coam via ssl     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    set suite variable    ${version_list}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00_523_720.xml
    ...     ${CURDIR_path}SCF_${version_list[0]}_523_720.xml
#    ${if_22R2_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
#    ${if_23R3_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS23R3
#    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}${SBTS_scf_name}.xml
#    ...    ${if_22R2_load}    ${CURDIR_path}${Branch_scf_name_22R2}.xml
#    ...    ${if_23R3_load}    ${CURDIR_path}${Branch_scf_name_23R3}.xml
#    ...    ${CURDIR_path}${Branch_scf_name_22R1}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    log to console   Set Default scf name successful
