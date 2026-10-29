*** Settings ***
Documentation
...               squad group: MMW_SG_04

Force Tags  STATE_SW_UPLOADED

Suite Setup        robot_common_operations.Common Suite Setup
Suite Teardown     robot_common_operations.Common Suite Teardown

#Library           check_cap.CapPacket    WITH NAME    cap
Library           taf.sbts.oam.coam.admin         WITH NAME      coam
Library           ./resources/8004_common_keyword.py
#Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/get_set_TL_info.robot
Resource          ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/UE_TP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
${username}                 ${tl.test_pc.default_ssh_connection_details.username}
${password}                 ${tl.test_pc.default_ssh_connection_details.password}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gnb_path}                 /ffs/run/config/toor4nsn/
${filename}                 tcpdump_ru.pcap
${holdover_time_1325}       1325
${holdover_time_200000}     200000
${LNApower}                 actGnssOutputLnaPowerSupply
${gnssMode}                 gnssControlMode
${GLONASS_only}             GLONASS only
${GPS_Beidou}               GPS-Beidou
${holdover_threshold}       phaseHoldoverSpecThreshold
${dist_CLOCK}               MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
${dist_GNSS}                MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
${dist_ECPRIMASTER}         MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${luashark_path}            /opt/luashark/luashark.lua
${dist_actEcpriRuPtpOnlySync}        MRBTS-${MRBTS_ID}/NRBTS-10703
${act_EcpriRuPtpOnlySync}            actEcpriRuPtpOnlySync
${gNB_ip}                   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${ue_type}                  ${tl.ues[0].capabilities[-1]}
${Enb_ip}                   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${BTS_ID}                   ${tl.gnbs[0].instance_id}
${ul_iperf_port}            ${tl.ues[0].iperf_details.ports[0]}
${dl_iperf_port}            ${tl.ues[0].iperf_details.ports[1]}
@{cell_id_list}             11730945    11730946    11730947
${Clock_mode_state}         locked

*** Test Cases ***
[1]CB008004-5G-A_001_Generic startup of synchronization functions_configuration with PTP
    [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
    ...    these five scripts PTP.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
    ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
    ...    if not exist , you can find them on git the same path with this robot case file
    [Tags]    CRT_TRUNK
    [Setup]    case Setup utecloud
    Setup Commission SCF    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    25min    10s    Check cell on air    DU_IP=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Add_GNSS_1     synctype1=1pps/ToD from external GNSS receiver
    sleep   60s
#    set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}    DU_IP=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    wait until keyword succeeds    10min    10s    Check cell on air    DU_IP=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    Start and save RU tcpdump
#    Check sync mode    PTP    sync_mode: PTP
#    check lockState and syncStatus on WebEM    Locked    Locked
#    Read Log 01    tcpdump_log=${filename}
#    log to console    \n\tcheck frame info
#    ${check_result}    Check_frame_info    req_fl=${OUTPUT_DIR}/Req.txt    resp_fl=${OUTPUT_DIR}/Resp.txt
#    Check clock ID from tcpdump    tcpdump_log=${filename}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    run keyword and ignore error   CI_interface.Common Case Teardown


[1]CB008004-5G-A_002_Keeping and monitoring sync in the normal operation mode - configuration with PTP only
    [Documentation]    TL7101->TL733
    [Tags]    CRT_TRUNK
    [Setup]    Case Setup
    wait until keyword succeeds    25min    10s    Check cell on air
    set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
    wait until keyword succeeds    10min    10s    Check cell on air
    Reset gnb And Wait Until On Air
    Start and save RU tcpdump_TL733
    Check sync mode_TL733    PTP    sync_mode: PTP
    check lockState and syncStatus on WebEM    Locked    Locked
    Read Log    tcpdump_log=${filename}
    log to console    \n\tcheck frame info
    ${check_result}    Check_frame_info    req_fl=${OUTPUT_DIR}/Req.txt    resp_fl=${OUTPUT_DIR}/Resp.txt
    Check clock ID from tcpdump    tcpdump_log=${filename}
    Should Be Equal As Strings    ${check_result}    True
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    run keyword and ignore error   CI_interface.Common Case Teardown

[4]CB008004-5G-A_003_PTP Failure - configuration with PTP only
    [Documentation]    TL716
    [Tags]    CRT_TRUNK
    [Setup]    Case Setup
    wait until keyword succeeds    25min    10s    Check cell on air
    set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
    wait until keyword succeeds    10min    10s    Check cell on air
#    Check clock ID from switch
#    Check clock mode from switch
    Check sync mode    PTP    sync_mode: PTP
    Get and check Tuning mode    Normal tuning
    Delete_TOPP_2    synctype=1pps/ToD from external GNSS receiver
    Check Clockclass on WEBEM    value=7
    Get and check Tuning mode    Adaptive holdover
    sleep    5min
    check lockState and syncStatus on WebEM    OutOfLock    Freerun
    run keyword and continue on failure     Check fault
    ADD_TOPP_2     synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
    sleep    1min
    wait until keyword succeeds    20min    10s    Check cell on air
    Check sync mode    PTP    sync_mode: PTP
    Check Clockclass on WEBEM    value=6
    check lockState and syncStatus on WebEM    Locked    Locked
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    run keyword and ignore error   CI_interface.Common Case Teardown

*** Keywords ***
Case Setup
#    CI_interface.Common Suite Setup
    robot_common_operations.Common Case Setup
    Setup Commission SCF
    CP 8004-A sh file

case Setup utecloud
    robot_common_operations.Common Case Setup
    CI_interface.Common Suite Setup
    Adapt to ute cloud commission scf

CP 8004-A sh file
    log to console    CP 8004-A sh file
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    5s
    ssh.execute    command=sudo scp /opt/CB008004-A/PTP.sh ${CURDIR}/
    ...    connection=ute
    sleep    1s
    ssh.execute    command=sudo scp /opt/CB008004-A/start_tcp.sh ${CURDIR}/
    ...    connection=ute
    sleep    1s
    ssh.execute    command=sudo scp /opt/CB008004-A/Clock_mode.sh ${CURDIR}/
    ...    connection=ute
    sleep    1s
    ssh.execute    command=sudo scp /opt/CB008004-A/SYNCE_PTP.sh ${CURDIR}/
    ...    connection=ute
    sleep    1s
    ssh.execute    command=sudo scp /opt/CB008004-A/eCpriMasterClockIdentity.sh ${CURDIR}/
    ...    connection=ute
    sleep    1s

Check clock mode from switch
    log to console    Check clock mode from switch...
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 755 /home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008161-A/Clock_mode.sh
    ...    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=/home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008161-A/Clock_mode.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out}    ${Clock_mode_state}
    [Teardown]    ssh.disconnect    connection=ute

Check clock ID from switch
    Connect to DU
    ${GrandMaster_clockID}    Get SCF single Value from current xml file
    ...   parameter=eCpriMasterClockIdentity   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects

    log to console    \n\tCheck clock ID from switch...
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 755 ${CURDIR}/eCpriMasterClockIdentity.sh
    ...    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=${CURDIR}/eCpriMasterClockIdentity.sh
    ...    connection=ute
    sleep    1s
    ${out}    Remove String    ${out}   :
    run keyword and continue on failure    should contain any    ${out}    ${GrandMaster_clockID}
    ssh.disconnect    connection=ute
    [Teardown]    Disconnect from DU

Check clock ID from tcpdump
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    Connect to DU
#    ${GMaster_ID}    Get SCF single Value from current xml file
#    ...   parameter=topGMasterClockIdentity   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
#    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#    ${Master_ID}    Get SCF single Value from current xml file
#    ...   parameter=topMasterClockIdentity   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
#   ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${bts_objects}    coam.get_managed_objects    class_name=TOPP_R    connection=cOAM_admin
    FOR   ${item}   IN     @{bts_objects}
        ${id}    String.Fetch From Right    ${item['distName']}   marker=-
        ${Master_ID_dic}    set variable     ${item['parameters']['topMasterList']}[${0}]
        ${Master_ID}    set variable if    ${id}==3     ${Master_ID_dic['topMasterClockIdentity']}
        ${GMaster_ID_dic}    set variable    ${id}==3     ${item['parameters']['topMasterList']}[${0}]
        ${GMaster_ID}    set variable if    ${id}==3    ${Master_ID_dic['topGMasterClockIdentity']}
        Exit For Loop If    ${id}==3
    END
    Disconnect from DU
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
    Convert pcap to text    source=${OUTPUT_DIR}/${tcpdump_log}    target=${OUTPUT_DIR}/Req.txt
    ...    filter='ptp.v2.clockidentity == 0x${Master_ID}'    connection=${connection}
    ${ReqContent}    Get File    ${OUTPUT_DIR}/Req.txt
    should not be empty    ${ReqContent}
    Convert pcap to text    source=${OUTPUT_DIR}/${tcpdump_log}    target=${OUTPUT_DIR}/Resp.txt
    ...    filter='ptp.v2.an.grandmasterclockidentity == 0x${GMaster_ID}'    connection=${connection}
    ${RespContent}    Get File    ${OUTPUT_DIR}/Resp.txt
    should not be empty    ${RespContent}
    [Teardown]    ssh.Disconnect	  connection=${connection}

Case Teardown
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time_1325}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${True}    operation=update
    ${versiontitle}    Get Version
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
    run keyword and ignore error    CI_interface.Common Case Teardown
    [Teardown]    Disconnect from DU


Check cell on air
    [Arguments]  ${connection}=cOAM_admin    ${DU_IP}=${DU_IP}
    log to console    check cell onair...
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${status}            coam.get_bts_statuses       connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}

set actEcpriRuPtpOnlysync value
    [Arguments]    ${actEcpriRuPtpOnlysync_value}    ${DU_IP}=${DU_IP}
    log to console    set actEcpriRuPtpOnlysync value...
    Connect to DU    DU_IP=${DU_IP}
    perform muti Parameter recommissioning    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter=${act_EcpriRuPtpOnlySync}
    ...    value=${actEcpriRuPtpOnlysync_value}    operation=update
    [Teardown]    Disconnect from DU

Connect to DU
    [Arguments]    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

gNB connections
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${DU_OAM_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

Get and check Tuning mode
    [Arguments]    ${tuning_mode}
    log to console    Get and check Tuning mode...
    Connect to DU
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=cOAM_admin
    should be equal as strings    ${bts_sync_status['tuningMode']}    ${tuning_mode}    ignore_case=true
    [Teardown]    Disconnect from DU

Start and save RU tcpdump
    log to console    \n\tstart RU tcpdump
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    log to console    send command 1...
    ssh.execute    command=chmod 755 ${CURDIR}/../CB008161-A/start_tcp.sh
    ...    connection=ute
    sleep    1s
    log to console    send command 2...
    ssh.execute    command=${CURDIR}/../CB008161-A/start_tcp.sh
    ...    connection=ute
    sleep    15s
    log to console    save log....
    Save Logs
    log to console    end save log....
    [Teardown]    ssh.disconnect    connection=ute


Start and save RU tcpdump_TL733
    log to console    \n\tstart RU tcpdump
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    log to console    send command 1...
    ssh.execute    command=chmod 755 ${CURDIR}/start_tcp.sh
    ...    connection=ute
    sleep    1s
    log to console    send command 2...
    ssh.execute    command=${CURDIR}/start_tcp.sh
    ...    connection=ute
    sleep    15s
    log to console    save log....
    Save Logs
    log to console    end save log....
    [Teardown]    ssh.disconnect    connection=ute


Check sync mode
    [Arguments]     ${check_sync_mode}    ${sync_mode}
    log to console    \n\tcheck sync mode...
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 755 ${CURDIR}/../CB008161-A/${check_sync_mode}.sh
    ...    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=${CURDIR}/../CB008161-A/${check_sync_mode}.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out}    ${sync_mode}
    [Teardown]    ssh.disconnect    connection=ute

Check sync mode_TL733
    [Arguments]     ${check_sync_mode}    ${sync_mode}
    log to console    \n\tcheck sync mode...
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 755 ${CURDIR}/${check_sync_mode}.sh
    ...    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=${CURDIR}/${check_sync_mode}.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out}    ${sync_mode}
    [Teardown]    ssh.disconnect    connection=ute

Check PTP sync mode for case 8
    [Arguments]     ${sync_mode}
    log to console    \n\tcheck sync mode
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 755 ${CURDIR}/../CB008161-A/PTP.sh
    ...    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=${CURDIR}/../CB008161-A/PTP.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out}    ${sync_mode}
    ssh.execute    command=chmod 755 ${CURDIR}/../CB008161-A/PTP1.sh
    ...    connection=ute
    sleep    1s
    ${out1}    ssh.execute    command=${CURDIR}/../CB008161-A/PTP1.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out1}    ${sync_mode}
    ssh.execute    command=chmod 755 ${CURDIR}/../CB008161-A/PTP2.sh
    ...    connection=ute
    sleep    1s
    ${out2}    ssh.execute    command=${CURDIR}/../CB008161-A/PTP2.sh
    ...    connection=ute
    sleep    1s
    should contain any    ${out2}    ${sync_mode}
    [Teardown]    ssh.disconnect    connection=ute

Save Logs
    gNB connections
    download Logs    logname=${filename}    connection=gnb
    [Teardown]    csn.Disconnect    connection=gnb

download Logs
    [Arguments]    ${logname}    ${connection}
    csn.download_file    remote_path=${gnb_path}${logname}    local_path=${OUTPUT_DIR}/${logname}   connection=${connection}
    sleep    3

check lockState and syncStatus on WebEM
    [Arguments]     ${lock_State}    ${sync_Status}
    log to console    \n\tcheck lockState and syncStatus on WebEM
    Connect to DU
    ${lockState}    Get SCF single Value from current xml file
    ...   parameter=lockState   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be true    '${lockState}'=='${lock_State}'
    ${syncStatus}    Get SCF single Value from current xml file
    ...   parameter=syncStatus   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be true    '${syncStatus}'=='${sync_Status}'
    [Teardown]    Disconnect from DU

Read Log
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
    Convert pcap to text    source=${OUTPUT_DIR}/${tcpdump_log}    target=${OUTPUT_DIR}/Req.txt   filter='ptp.v2.messageid == 0x1'
    ...    connection=${connection}
    Convert pcap to text    source=${OUTPUT_DIR}/${tcpdump_log}    target=${OUTPUT_DIR}/Resp.txt   filter='ptp.v2.messageid == 0x9'
    ...    connection=${connection}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Log 01
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
    Convert pcap to text    source=${OUTPUT DIR}/${tcpdump_log}    target=${OUTPUT DIR}/Req.txt   filter='ptp.v2.messagetype == 0x1'
    ...    connection=${connection}
    Convert pcap to text    source=${OUTPUT DIR}/${tcpdump_log}    target=${OUTPUT DIR}/Resp.txt   filter='ptp.v2.messagetype == 0x9'
    ...    connection=${connection}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}   

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    ssh.send_command
    ...  command=tshark -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min

Change para Glonass only
    [Arguments]    ${LNAvalue}    ${holdover_time}
    Log To Console    Change para Glonass only...
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GLONASS_only}    operation=update
    ...    ELSE    act Glonass
    [Teardown]    Disconnect from DU

act Glonass
    Log To Console    act Glonass...
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${False}    operation=update

act GPS-Beidou
    Log To Console    act GPS-Beidou...
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${True}    operation=update

Change para GPS Beidou
    [Arguments]    ${LNAvalue}    ${holdover_time}
    Log To Console    Change para GPS Beidou...
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
   [Teardown]    Disconnect from DU

Get Version
    Log To Console    Get Version
#    ${connection}    coam.connect_to    bts_host=${DU_OAM_IP}     name=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=GNB_OAM
    ${version}    coam.get_sw_version    connection=GNB_OAM
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=GNB_OAM

Check fault
    Log To Console     Check fault...
    Connect to DU
    sleep    15min
    ${fault_name_list}     ${fault_id_list}     Get Alarm Info     timeout=60
    run keyword and continue on failure    list should contain value      ${fault_id_list}    ${4298}
    run keyword and continue on failure    list should contain value      ${fault_id_list}    ${16}
    [Teardown]    Disconnect from DU

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
#    @{alarms}    coam.get_historic_alarms    timeout=${timeout}    connection=cOAM_admin
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

Check Clockclass on WEBEM
    [Arguments]    ${value}
    Log To Console    Check Clockclass on WEBEM...
    Connect to DU
    ${Clockclass}   coam.Get SCF single Value from current xml file
    ...   parameter=eCpriMasterClockClass   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be equal    ${Clockclass}    ${value}
    [Teardown]    Disconnect from DU

modify enb defaultLnRelGnbCellId parameter
    [Arguments]     ${value}=${1}
#    Login BaseStation By Admin    hostname=${Enb_ip}    connection=ENB_conn
    Connect to gnb coam via ssl    bts_host=${Enb_ip}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=ENB_conn
    ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=ENB_conn
    wait until keyword succeeds    5min    10s  Check GNB ENB cell on air    gNB_ip=${Enb_ip}
    [Teardown]    coam.Teardown     connection=ENB_conn


get each cell TP and check
    [Documentation]    Get ul and dl peak and ave throughput and return result
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}
    [Arguments]    ${cell_index}=${0}    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ...    log_name=data_dl${cell_index}.txt
#    ${cell_id_list}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}    log_name=data_dl${cell_index}.txt
#    sort list     ${cell_id_list}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ...    cell_id=${cell_id_list[${cell_index}]}    log_name=data_dl${cell_index}.txt
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${1}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${1}
    should be true    ${dl_average_tp}>50
    should be true    ${ul_average_tp}>10

UE teardown
    [Arguments]    ${ul_iperf_port}    ${dl_iperf_port}
    run keyword and ignore error    stop power ue traffic ul and dl    ue_num=${1}    ue_type=${ue_type}
    ...    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
    run keyword and ignore error  detach power ue    ue_num=${1}    ue_type=${ue_type}

Reset gnb And Wait Until On Air
    [Arguments]
    Log To Console    Reset BTS And Wait Until On Air
    sleep    2s
    COAM.Setup Admin    bts_host=${DU_OAM_IP}    alias=cOAM_reset
    COAM.reset          connection=cOAM_reset
    Log To Console    Check cell on air
    wait until keyword succeeds    13min    10s    Check cell on air
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown    connection=cOAM_reset

Delete_TOPP_2
    [Arguments]    ${synctype}      ${Num}=${1}     ${alias}=cOAM_admin
    Log To Console    Delete TOPP
    Connect to DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${alias}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${parameter_list}    get from dictionary     ${item}    parameters
         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
         ${object}     set variable if    ${sync_list}!=[]    ${item}
         Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    ${Num}
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=1
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_CLOCK}    connection=${alias}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    100s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${alias}

Add_TOPP_2
    [Arguments]    ${synctype1}    ${synctype2}     ${alias}=cOAM_admin
    Log To Console    ADD TOPP
    Connect to DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${alias}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${parameter_list}    get from dictionary     ${item}    parameters
         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
         ${object}     set variable if    ${sync_list}!=[]    ${item}
         Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=1
    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_CLOCK}    connection=${alias}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${alias}

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../commissionings/HGZ/${TLNAME}/

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Adapt to ute cloud commission scf
    Set default SCF    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Add_GNSS_1
    [Arguments]    ${synctype1}     ${synctype2}=TOPP    ${alias}=cOAM_admin
    Log To Console    ADD TOPP
    Connect to DU
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${alias}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${parameter_list}    get from dictionary     ${item}    parameters
         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
         ${object}     set variable if    ${sync_list}!=[]    ${item}
         Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=1
    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_CLOCK}    connection=${alias}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${alias}
