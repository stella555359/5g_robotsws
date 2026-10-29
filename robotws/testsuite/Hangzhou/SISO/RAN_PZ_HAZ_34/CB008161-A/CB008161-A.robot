# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Force Tags        5G_SISO    CB008161    CRT_22R2    CRT_TRUNK
# ...    PY36
# 
# Suite Setup        All Case suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# #Library           check_cap.CapPacket    WITH NAME    cap
# #Library           taf.sbts.oam.coam.admin         WITH NAME      coam
# Library           ./resources/8161_common_keyword.py
# #Resource          taf/rfrl/common_resources/robot/coam.robot
# Resource          ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/get_set_TL_info.robot
# Resource          ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/UE_TP.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
# ${username}                 ${tl.test_pc.default_ssh_connection_details.username}
# ${password}                 ${tl.test_pc.default_ssh_connection_details.password}
# ${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
# ${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
# ${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gnb_path}                 /ffs/run/config/toor4nsn/
# ${filename}                 tcpdump_ru.pcap
# ${holdover_time_1325}       1325
# ${holdover_time_200000}     200000
# ${LNApower}                 actGnssOutputLnaPowerSupply
# ${gnssMode}                 gnssControlMode
# ${GLONASS_only}             GLONASS only
# ${GPS_Beidou}               GPS-Beidou
# ${holdover_threshold}       phaseHoldoverSpecThreshold
# ${dist_GNSS}                MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# ${dist_ECPRIMASTER}         MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
# ${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${luashark_path}            /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
# ${dist_actEcpriRuPtpOnlySync}        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
# ${act_EcpriRuPtpOnlySync}            actEcpriRuPtpOnlySync
# ${gNB_ip}                   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${ue_type}                  ${tl.ues[0].capabilities[-1]}
# ${Enb_ip}                   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${BTS_ID}                   ${tl.gnbs[0].instance_id}
# ${ul_iperf_port}            ${tl.ues[0].iperf_details.ports[0]}
# ${dl_iperf_port}            ${tl.ues[0].iperf_details.ports[1]}
# @{cell_id_list}             11730945    11730946    11730947
# ${Clock_mode_state}         locked
# 
# *** Test Cases ***
# [1]CB008161-5G-A_001_Generic startup of synchronization functions_configuration with PTP and SyncE
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these five scripts PTP.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]    CB008161    CRT_22R2
#     [Setup]    robot_common_operations.Common case Setup
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${false}
#     wait until keyword succeeds    10min    10s    Check cell on air
#     Check clock ID from switch
#     Start and save RU tcpdump
#     Check sync mode    SYNCE_PTP    sync_mode: SYNCE_PTP
#     check lockState and syncStatus on WebEM    Locked    Locked
#     Read Log    tcpdump_log=${filename}
#     ${check_result}    Check_frame_info    req_fl=${output_dir}/Req.txt    resp_fl=${output_dir}/Resp.txt
#     Should Be Equal As Strings    ${check_result}    True
#     Check clock ID from tcpdump    tcpdump_log=${filename}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]CB008161-5G-A_002_Generic startup of synchronization functions_configuration with PTP
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these five scripts PTP.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]    CB008161    CRT_TRUNK    CRT_22R2    CRT_22R4
#     [Setup]    robot_common_operations.Common case Setup
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
#     wait until keyword succeeds    10min    10s    Check cell on air
#     Check clock ID from switch
#     Start and save RU tcpdump
#     Check sync mode    PTP    sync_mode: PTP
#     check lockState and syncStatus on WebEM    Locked    Locked
#     Read Log    tcpdump_log=${filename}
#     log to console    \n\tcheck frame info
#     ${check_result}    Check_frame_info    req_fl=${output_dir}/Req.txt    resp_fl=${output_dir}/Resp.txt
#     Should Be Equal As Strings    ${check_result}    True
#     Check clock ID from tcpdump    tcpdump_log=${filename}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]CB008161-5G-A_003_Keeping and monitoring sync in the normal operation mode - configuration with PTP and SyncE
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these five scripts PTP.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]    CB008161    CRT_22R2
#     [Setup]    robot_common_operations.Common case Setup
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${false}
#     wait until keyword succeeds    10min    10s    Check cell on air
#     Check clock ID from switch
#     FOR    ${i}    IN RANGE    ${6}
#         Start and save RU tcpdump
#         Check sync mode    SYNCE_PTP    sync_mode: SYNCE_PTP
#         check lockState and syncStatus on WebEM    Locked    Locked
#         Read Log    tcpdump_log=${filename}
#         ${check_result}    Check_frame_info    req_fl=${output_dir}/Req.txt    resp_fl=${output_dir}/Resp.txt
#         Should Be Equal As Strings    ${check_result}    True
#         Check clock ID from tcpdump    tcpdump_log=${filename}
#         sleep    3
#     END
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]CB008161-5G-A_006_PTP Failure - configuration with PTP only
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these five scripts PTP.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]    CB008161    CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common case Setup
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
#     wait until keyword succeeds    10min    10s    Check cell on air
#     Check clock ID from switch
#     Check clock mode from switch
#     Check sync mode    PTP    sync_mode: PTP
#     Get and check Tuning mode    Normal tuning
#     Change para Glonass only    LNAvalue=${False}    holdover_time=${holdover_time_200000}
#     Check Clockclass on WEBEM    value=7
#     Get and check Tuning mode    Adaptive holdover
#     sleep    5min
# #    wait until keyword succeeds    40min    10s    Check cell on air
#     check lockState and syncStatus on WebEM    OutOfLock    Freerun
#     run keyword and continue on failure     Check fault
#     Change para GPS Beidou    LNAvalue=${True}    holdover_time=${holdover_time_1325}
#     sleep    1min
#     wait until keyword succeeds    20min    10s    Check cell on air
#     Check sync mode    PTP    sync_mode: PTP
#     Check Clockclass on WEBEM    value=6
#     check lockState and syncStatus on WebEM    Locked    Locked
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]CB008161-5G-A_008_L3_call_with_PTP_only
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these seven scripts PTP.sh PTP1.sh PTP2.sh start_tcp.sh SYNCE_PTP.sh eCpriMasterClockIdentity.sh Clock_mode.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB008161-A/ on UTE 10.57.167.203
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]    CB008161    CRT_TRUNK    CRT_22R2    CRT_22R4
#     [Setup]    robot_common_operations.Common case Setup
#     wait until keyword succeeds    25min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
#     wait until keyword succeeds    10min    10s    Check cell on air
#     Check PTP sync mode for case 8    sync_mode: PTP
# #    FOR    ${item}    IN RANGE    ${3}
# #        ${defaultLnRelGnbCellId_value}    evaluate    ${item}+${2}
# #        modify enb defaultLnRelGnbCellId parameter    value=${defaultLnRelGnbCellId_value}
# #        run keyword and continue on failure    start call and check TP    cell_index=${item}
# #    END
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${false}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check clock mode from switch
#     log to console    Check clock mode from switch...
#     ssh.connect_to      hostname=${host}
#     ...                 username=${username}
#     ...                 password=${password}
#     ...                 alias=ute
#     sleep    10s
#     ssh.execute    command=chmod 777 ${CURDIR}/Clock_mode.sh
#     ...    connection=ute
#     sleep    1s
#     ${out}    ssh.execute    command=${CURDIR}/Clock_mode.sh
#     ...    connection=ute
#     sleep    1s
#     should contain any    ${out}    ${Clock_mode_state}
#     [Teardown]    ssh.disconnect    connection=ute
# 
# Check clock ID from switch
#     Connect to DU
#     ${GrandMaster_clockID}    Get SCF single Value from current xml file
#     ...   parameter=eCpriMasterClockIdentity   list_name=${None}
#     ...   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
#     ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
# 
#     log to console    \n\tCheck clock ID from switch...
#     ssh.connect_to      hostname=${host}
#     ...                 username=${username}
#     ...                 password=${password}
#     ...                 alias=ute
#     sleep    10s
#     ssh.execute    command=chmod 777 ${CURDIR}/eCpriMasterClockIdentity.sh
#     ...    connection=ute
#     sleep    1s
#     ${out}    ssh.execute    command=${CURDIR}/eCpriMasterClockIdentity.sh
#     ...    connection=ute
#     sleep    1s
#     ${out}    Remove String    ${out}   :
#     run keyword and continue on failure    should contain any    ${out}    ${GrandMaster_clockID}
#     ssh.disconnect    connection=ute
#     [Teardown]    Disconnect from DU
# 
# Check clock ID from tcpdump
#     [Arguments]      ${tcpdump_log}    ${connection}=TestPc
#     Connect to DU
#     ${GMaster_ID}    Get SCF single Value from current xml file
#     ...   parameter=topGMasterClockIdentity   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
#     ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     ${Master_ID}    Get SCF single Value from current xml file
#     ...   parameter=topMasterClockIdentity   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
#     ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     Disconnect from DU
#     log to console    \n\tRead Log and check
#     ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
#     Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Req.txt
#     ...    filter='ptp.v2.clockidentity == 0x${Master_ID}'    connection=${connection}
#     ${ReqContent}    Get File    ${output_dir}/Req.txt
#     should not be empty    ${ReqContent}
#     Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Resp.txt
#     ...    filter='ptp.v2.an.grandmasterclockidentity == 0x${GMaster_ID}'    connection=${connection}
#     ${RespContent}    Get File    ${output_dir}/Resp.txt
#     should not be empty    ${RespContent}
#     [Teardown]    ssh.Disconnect	  connection=${connection}
# 
# Case Teardown
#     Connect to DU
#     perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
#     ...    value=${holdover_time_1325}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${True}    operation=update
#     ${versiontitle}    Get Version
#     run keyword if    '${versiontitle}'=='SBTS21B'
#     ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
#     ...    ELSE    act GPS-Beidou
#     run keyword and ignore error    CI_interface.Common Case Teardown
#     [Teardown]    Disconnect from DU
# 
# #Check cell on air
# #    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
# #    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
# #    Gnb Cell Should Be Onair R    alias=cOAM_admin
# #    [Teardown]   coam.teardown     connection=cOAM_admin
# 
# Check cell on air
#     [Arguments]  ${connection}=cOAM_admin
#     log to console    check cell onair...
#     Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
#     ${status}            coam.get_bts_statuses       connection=${connection}
#     ${bts_status}        get from dictionary     ${status}     proceduralState
#     should be equal      ${bts_status}      OnAir
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}
# 
# #Gnb Cell Should Be Onair R
# #    [Arguments]    ${alias}=default    ${cell_type}=nr
# #    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
# #    log to console    waiting for BTS onair
# #    ${status}      coam.Get_Bts_Statuses   connection=${alias}
# #    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
# #    ${stat1}    run keyword and return status    Should Be Equal as strings    ${proceduralState}    OnAir
# #    ${stat2}    run keyword and return status    Should Be Equal as strings    ${proceduralState}    Configured
# #    should be true    ${stat1} or ${stat2}
# 
# #Gnb Cell Should Be Onair
# #    [Arguments]    ${all_cell_info}=${all_cell_info}    ${alias}=default    ${cell_type }=nr
# #    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
# #    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
# #    FOR    ${item}    IN    @{all_cell_info}
# #        ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
# #        ${tmp}   Get From Dictionary    ${status}  usageState
# #        Should Be Equal    ${tmp}    Active
# #    END
# 
# set actEcpriRuPtpOnlysync value
#     [Arguments]    ${actEcpriRuPtpOnlysync_value}
#     log to console    set actEcpriRuPtpOnlysync value...
#     Connect to DU
#     perform muti Parameter recommissioning    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter=${act_EcpriRuPtpOnlySync}
#     ...    value=${actEcpriRuPtpOnlysync_value}    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Connect to DU
# #    [Arguments]    ${alias}=cOAM_admin
# #    ${conn}=    coam.connect_to
# #    ...    bts_host=${DU_IP}
# #    ...    username=${WEBEM_USERNAME}
# #    ...    password=${WEBEM_PASSWORD}
# #    ...    name=${alias}
# #    [Return]    ${conn}
# 
# Connect to DU
#     [Arguments]    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
#     Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
#     ${conn}    set variable    ${alias}
#     [Return]    ${conn}
# 
# Disconnect from DU
#     [Arguments]    ${alias}=cOAM_admin
#     coam.teardown     connection=${alias}
# 
# gNB connections
#     csn.Connect To    hostname=${DU_OAM_IP}
#     ...               username=${DU_OAM_SSH_USERNAME}
#     ...               password=${DU_OAM_SSH_PASSWORD}
#     ...               alias=gnb
# 
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
#     ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${value}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...    should_activate=${should_activate}
#     ...    connection=${connection}
# 
# Get and check Tuning mode
#     [Arguments]    ${tuning_mode}
#     log to console    Get and check Tuning mode...
#     Connect to DU
#     ${bts_sync_status}    coam.get_bts_sync_source_status    connection=cOAM_admin
#     should be equal as strings    ${bts_sync_status['tuningMode']}    ${tuning_mode}    ignore_case=true
#     [Teardown]    Disconnect from DU
# 
# Start and save RU tcpdump
#     log to console    \n\tstart RU tcpdump
#     ssh.connect_to      hostname=${host}
#     ...                 username=${username}
#     ...                 password=${password}
#     ...                 alias=ute
#     sleep    10s
#     log to console    send command 1...
#     ssh.execute    command=chmod 777 ${CURDIR}/start_tcp.sh
#     ...    connection=ute
#     sleep    1s
#     log to console    send command 2...
#     ssh.execute    command=${CURDIR}/start_tcp.sh
#     ...    connection=ute
#     sleep    1s
#     log to console    save log....
#     Save Logs
#     log to console    end save log....
#     [Teardown]    ssh.disconnect    connection=ute
# 
# Check sync mode
#     [Arguments]     ${check_sync_mode}    ${sync_mode}
#     log to console    \n\tcheck sync mode...
#     ssh.connect_to      hostname=${host}
#     ...                 username=${username}
#     ...                 password=${password}
#     ...                 alias=ute
#     sleep    10s
#     ssh.execute    command=chmod 777 ${CURDIR}/${check_sync_mode}.sh
#     ...    connection=ute
#     sleep    1s
#     ${out}    ssh.execute    command=${CURDIR}/${check_sync_mode}.sh
#     ...    connection=ute
#     sleep    1s
#     should contain any    ${out}    ${sync_mode}
#     [Teardown]    ssh.disconnect    connection=ute
# 
# Check PTP sync mode for case 8
#     [Arguments]     ${sync_mode}
#     log to console    \n\tcheck sync mode
#     ssh.connect_to      hostname=${host}
#     ...                 username=${username}
#     ...                 password=${password}
#     ...                 alias=ute
#     sleep    10s
#     ssh.execute    command=chmod 777 ${CURDIR}/PTP.sh
#     ...    connection=ute
#     sleep    1s
#     ${out}    ssh.execute    command=${CURDIR}/PTP.sh
#     ...    connection=ute
#     sleep    1s
#     should contain any    ${out}    ${sync_mode}
#     ssh.execute    command=chmod 777 ${CURDIR}/PTP1.sh
#     ...    connection=ute
#     sleep    1s
#     ${out1}    ssh.execute    command=${CURDIR}/PTP1.sh
#     ...    connection=ute
#     sleep    1s
#     should contain any    ${out1}    ${sync_mode}
#     ssh.execute    command=chmod 777 ${CURDIR}/PTP2.sh
#     ...    connection=ute
#     sleep    1s
#     ${out2}    ssh.execute    command=${CURDIR}/PTP2.sh
#     ...    connection=ute
#     sleep    1s
#     should contain any    ${out2}    ${sync_mode}
#     [Teardown]    ssh.disconnect    connection=ute
# 
# Save Logs
#     gNB connections
#     download Logs    logname=${filename}    connection=gnb
#     [Teardown]    csn.Disconnect    connection=gnb
# 
# download Logs
#     [Arguments]    ${logname}    ${connection}
#     csn.download_file    remote_path=${gnb_path}${logname}    local_path=${output_dir}/${logname}   connection=${connection}
#     sleep    3
# 
# check lockState and syncStatus on WebEM
#     [Arguments]     ${lock_State}    ${sync_Status}
#     log to console    \n\tcheck lockState and syncStatus on WebEM
#     Connect to DU
#     ${lockState}    Get SCF single Value from current xml file
#     ...   parameter=lockState   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
#     ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be true    '${lockState}'=='${lock_State}'
#     ${syncStatus}    Get SCF single Value from current xml file
#     ...   parameter=syncStatus   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
#     ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be true    '${syncStatus}'=='${sync_Status}'
#     [Teardown]    Disconnect from DU
# 
# Read Log
#     [Arguments]      ${tcpdump_log}    ${connection}=TestPc
#     log to console    \n\tRead Log and check
#     ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
#     Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Req.txt   filter='ptp.v2.messageid == 0x1'
#     ...    connection=${connection}
#     Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Resp.txt   filter='ptp.v2.messageid == 0x9'
#     ...    connection=${connection}
#     [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}
# 
# Convert pcap to text
#     [Arguments]  ${source}   ${target}   ${filter}   ${connection}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
#     ...  connection=${connection}
#     ssh.await execution end    connection=${connection}    timeout=30min
# 
# Change para Glonass only
#     [Arguments]    ${LNAvalue}    ${holdover_time}
#     Log To Console    Change para Glonass only...
#     Connect to DU
#     perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
#     ...    value=${holdover_time}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
#     ${versiontitle}    Get Version
#     run keyword if    '${versiontitle}'=='SBTS21B'
#     ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GLONASS_only}    operation=update
#     ...    ELSE    act Glonass
#     [Teardown]    Disconnect from DU
# 
# act Glonass
#     Log To Console    act Glonass...
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${False}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${True}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${False}    operation=update
# 
# act GPS-Beidou
#     Log To Console    act GPS-Beidou...
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${True}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${False}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${True}    operation=update
# 
# Change para GPS Beidou
#     [Arguments]    ${LNAvalue}    ${holdover_time}
#     Log To Console    Change para GPS Beidou...
#     Connect to DU
#     perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
#     ...    value=${holdover_time}    operation=update
#     perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
#     ${versiontitle}    Get Version
#     run keyword if    '${versiontitle}'=='SBTS21B'
#     ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
#     ...    ELSE    act GPS-Beidou
#    [Teardown]    Disconnect from DU
# 
# #Change para GPS Beidou
# #    [Arguments]    ${LNAvalue}
# #    Log To Console    Change para GPS Beidou...
# #    Connect to DU
# ##    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
# ##    ...    value=${holdover_time}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
# #    ${versiontitle}    Get Version
# #    run keyword if    '${versiontitle}'=='SBTS21B'
# #    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
# #    ...    ELSE    act GPS-Beidou
# #   [Teardown]    Disconnect from DU
# 
# Get Version
#     Log To Console    Get Version
# #    ${connection}    coam.connect_to    bts_host=${DU_OAM_IP}     name=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=GNB_OAM
#     ${version}    coam.get_sw_version    connection=GNB_OAM
#     ${version_list}    split string    ${version}    _
#     ${versiontitle}    set variable    ${version_list[0]}
#     [Return]    ${versiontitle}
#     [Teardown]    coam.Teardown  connection=GNB_OAM
# 
# Check fault
#     Log To Console     Check fault...
#     Connect to DU
#     ${fault_name_list}     ${fault_id_list}     Get Alarm Info     timeout=60
#     run keyword and continue on failure    list should contain value      ${fault_id_list}    ${4298}
#     run keyword and continue on failure    list should contain value      ${fault_id_list}    ${16}
#     [Teardown]    Disconnect from DU
# 
# Get Alarm Info
#     [Arguments]   ${timeout}    ${connection}=cOAM_admin
#     sleep    10s
#     @{alarms}    coam.get_historic_alarms    timeout=${timeout}    connection=cOAM_admin
#     sleep    1s
#     log     ${alarms}
#     ${fault_id_list}    create list
#     ${fault_name_list}    create list
#     FOR    ${item}    IN    @{alarms}
#         ${fault_id}    get from dictionary    ${item}    faultId
#         ${fault_name}    get from dictionary    ${item}    faultName
#         append to list    ${fault_id_list}    ${fault_id}
#         append to list    ${fault_name_list}    ${fault_name}
#     END
#     [Return]    ${fault_name_list}    ${fault_id_list}
# 
# Check Clockclass on WEBEM
#     [Arguments]    ${value}
#     Log To Console    Check Clockclass on WEBEM...
#     Connect to DU
#     ${Clockclass}   coam.Get SCF single Value from current xml file
#     ...   parameter=eCpriMasterClockClass   list_name=${None}
#     ...   dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1   p_index=${0}
#     ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
#     should be equal    ${Clockclass}    ${value}
#     [Teardown]    Disconnect from DU
# 
# modify enb defaultLnRelGnbCellId parameter
#     [Arguments]     ${value}=${1}
# #    Login BaseStation By Admin    hostname=${Enb_ip}    connection=ENB_conn
#     Connect to gnb coam via ssl    bts_host=${Enb_ip}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=ENB_conn
#     ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${value}
#     ${list}    create list    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
#     ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#     ...    connection=ENB_conn
#     wait until keyword succeeds    5min    10s  Check GNB ENB cell on air    gNB_ip=${Enb_ip}
#     [Teardown]    coam.Teardown     connection=ENB_conn
# 
# start call and check TP
#     [Arguments]     ${cell_index}=${0}
#     power ue attach    ue_num=${1}    ue_type=${ue_type}
#     ${ul_iperf_port}    create list    ${ul_iperf_port}
#     ${dl_iperf_port}    create list    ${dl_iperf_port}
#     wait until keyword succeeds    5min    10s    start power ue traffic ul and dl    ue_num=${1}    ul_throughput=100MKbits/sec
#     ...    dl_throughput=100MKbits/sec   ue_type=${ue_type}    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
#     ...    ul_duration=180    dl_duration=180
#     sleep    10s
#     ${cell_list}    create list    11730945    11730946    11730947
#     power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=10    cellid=${cell_list[${cell_index}]}
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=50    cellid=${cell_list[${cell_index}]}
#     [Teardown]    UE teardown    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
# 
# get each cell TP and check
#     [Documentation]    Get ul and dl peak and ave throughput and return result
#     ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}
#     [Arguments]    ${cell_index}=${0}    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
#     ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
#     run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    log_name=data_dl${cell_index}.txt
# #    ${cell_id_list}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}    log_name=data_dl${cell_index}.txt
# #    sort list     ${cell_id_list}
#     ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    cell_id=${cell_id_list[${cell_index}]}    log_name=data_dl${cell_index}.txt
#     ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
#     ...    cell_numbers=${1}
#     ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
#     ...    cell_numbers=${1}
#     should be true    ${dl_average_tp}>50
#     should be true    ${ul_average_tp}>10
# 
# UE teardown
#     [Arguments]    ${ul_iperf_port}    ${dl_iperf_port}
#     run keyword and ignore error    stop power ue traffic ul and dl    ue_num=${1}    ue_type=${ue_type}
#     ...    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
#     run keyword and ignore error  detach power ue    ue_num=${1}    ue_type=${ue_type}
# 
# Adapt to ute cloud commission scf
#     ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
#     ${pattern}   Set Variable    7_5(.*)
#     ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
#     ${TLNAME}   Set Variable    7_5@{TLNAME}[0]
#     Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../commissionings/HGZ/${TLNAME}/
# 
# Set default SCF
#     [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    separator=_
#     ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
#     ...    ELSE IF    '${version_list[0]}'=='SBTS23R3'    Set Variable    SBTS23R3
#     ...    ELSE   Set Variable    SBTS23R2
#     ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
#     set suite variable    ${default_scf_path}
#     log to console   ${default_scf_path}
#     [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Setup Commission SCF
#     [Arguments]   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
#     Adapt to ute cloud commission scf
#     Set default SCF    bts_host=${bts_host}
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
#     COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# All Case suite Setup
#     robot_common_operations.Common Suite Setup
#     Setup Commission SCF