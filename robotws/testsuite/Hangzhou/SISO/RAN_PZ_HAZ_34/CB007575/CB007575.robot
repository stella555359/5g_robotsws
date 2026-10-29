# *** Settings ***
# Documentation     author: Wang Debbie
# ...               contact: debbie.wang@nokia-sbell.com
# ...               squad group: MMW_04
# #Suite Setup    Suite setup details
# #Suite Teardown
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Force Tags
# ...    PY36
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_B-573/Resources/5GC000573_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Library    taf.sbts.oam.coam.admin    WITH NAME    coam
# 
# *** Variables ***
# ${instance_id}    ${tl.gnbs[0].instance_id}
# ${bts_id}     ${tl.gnbs[0].global_bts_id}
# ${LMP_IP}     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${ssh_bts_USER}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${ssh_bts_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${default_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SBTS00_DU.xml
# ${ul_throughput}      300M
# ${dl_throughput}      2048M
# ${Expected_dl_Tput}    2100
# ${Expected_ul_Tput}    220
# ${expect_AMID_SN}     CZ211100002
# ${4G_IP}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${4G_BTS_ID}    ${tl.enbs[0].global_bts_id}
# @{ignore_fault}    ${7319}   ${7300}   ${9000}   ${61524}   ${61652}   ${61649}   ${61074}
# ...    ${61618}   ${4592}   ${1932}   ${4420}   ${4340}   ${4655}   ${4654}   ${4459}    ${1898}
# 
# 
# *** Test Cases ***
# [1]CB007575_A_08_call_setup_with_DL&UL_traffic_AES
#      [Tags]    CRT_22R2     CRT_TRUNK
#      change AES_SNOW_ZUC
#      power ue attach    ue_index=${0}
#      log to console      Start traffic    console=yes
#      power_ue.Start traffic    ue_index=${0}    direction=ul
#      ...    throughput=${ul_throughput}    duration=660    ue_type=samsung    iperf_type=via_command    protocol=udp
#      power_ue.Start traffic    ue_index=${0}    direction=dl
#      ...    throughput=${dl_throughput}    duration=660    ue_type=samsung    protocol=udp
#      ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=600s    ignore_time=10s
#      ${dl_cell_list}    create list    11583489    11583490    11583491    11583492
#      ${ul_cell_list}    create list    11583489    11583490
#      power_ue.Check Tput    ue_type=samsung    direction=dl    log=${log_path}     cells=${dl_cell_list}    target_throughput=${Expected_dl_Tput}
#      ...    actCarrierAggregation=${True}
#      ${state}    Run Keyword and Return Status    power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_pa
# ...th}     cells=${ul_cell_list}
#      ...    target_throughput=${Expected_ul_Tput}    actCarrierAggregation=${True}
#      run keyword unless     ${state}    save Snapshot Log
#      run keyword unless    ${state}    Fail
#      [Teardown]    08_case_teardown
# 
# [1]CB007575_A_02_HW_inventory_upload_to_WebEM_after_commissioning
#      [Tags]    CRT_22R2
#      check BTS on air
#      FOR    ${index}    IN RANGE    ${3}
#          ${old_fault_list}    Get Active Alarm List
#          run keyword and continue on failure    start btslog capture on ute    btslog_name=reset_bts_log
#          reset bts
#          run keyword and continue on failure    stop syslog    alias=ute
#          ${new_fault_list}    Get Active Alarm List
#          ${AMID_SN_web}    run keyword and continue on failure    get AMID info from web
#          ${AMID_SN_bts_log}    run keyword and continue on failure    get AMID SN from bts log    btslog_name=reset_bts_log
#          lists should be equal    ${old_fault_list}    ${new_fault_list}
#          ${state}    Run Keyword and Return Status    BuiltIn.Should Be Equal As Strings    ${AMID_SN_web}    ${AMID_SN_bts_log}
#      END
#      run keyword unless     ${state}    save Snapshot Log
#      run keyword unless    ${state}    Fail
#      [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB007575_A_11_attach_detach
#      [Tags]    CRT_22R2
#      check BTS on air
#      ${old_fault_id}    Get history Alarm List
#      FOR    ${i}    IN RANGE    ${10}
#         log to console    attach ${i}
#         power ue attach    ue_index=${0}
#         power_ue.UE Detach    ue_index=${0}    ue_type=samsung
#         sleep    2s
#      END
#      ${new_fault_id}    Get history Alarm List
#      ${state}    Run Keyword and Return Status    lists should be equal    ${old_fault_id}    ${new_fault_id}
#      run keyword unless     ${state}    save Snapshot Log
#      run keyword unless    ${state}    Fail
#      [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB007575_A_04_fan_fault_4077_4078_trigger_and_clear
#     [Tags]    CRT_TRUNK 
#     [Setup]    robot_common_operations.Common case Setup
#     check BTS on air
#     get and check fan speed
#     ${fault_id1}    Get Active Alarm List
#     run keyword and continue on failure    list should not contain value    ${fault_id1}    ${4077}
#     run keyword and continue on failure    list should not contain value    ${fault_id1}    ${4078}
#     run keyword and continue on failure    stop fan and check speed alarm
# 
#     run keyword and ignore error    recovery fan and service and check fan speed
#     ${fault_id3}    wait until keyword succeeds    30min    60s    wait no alarm
#     ${fault_id1_length}    get length    ${fault_id1}
#     ${fault_id3_length}    get length    ${fault_id3}
#     ${state}    Run Keyword and Return Status    should be true    ${fault_id1_length}>=${fault_id3_length}
#     run keyword unless     ${state}    save Snapshot Log
#     run keyword unless    ${state}    Fail
#     [Teardown]    Run Keywords    recovery fan and service and check fan speed    AND    CI_interface.Common Case Teardown
# 
# [1]CB007575_A_09_call_setup_with_DL&UL_traffic_AES_SNOW3G_ZUC
#      [Tags]    CRT_22R2
#      power ue attach    ue_index=${0}
#      log to console      Start traffic    console=yes
#      power_ue.Start traffic    ue_index=${0}    direction=ul
#      ...    throughput=${ul_throughput}    duration=660    ue_type=samsung    iperf_type=via_command    protocol=udp
#      power_ue.Start traffic    ue_index=${0}    direction=dl
#      ...    throughput=${dl_throughput}    duration=660    ue_type=samsung    protocol=udp
#      ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=600s    ignore_time=10s
#      ${dl_cell_list}    create list    11583489    11583490    11583491    11583492
#      ${ul_cell_list}    create list    11583489    11583490
# 
#      power_ue.Check Tput    ue_type=samsung    direction=dl    log=${log_path}     cells=${dl_cell_list}    target_throughput=${Expected_dl_Tput}
#      ...    actCarrierAggregation=${True}
#     ${state}    Run Keyword and Return Status    power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_pat
# ...h}     cells=${ul_cell_list}
#      ...    target_throughput=${Expected_ul_Tput}    actCarrierAggregation=${True}
#      run keyword unless     ${state}    save Snapshot Log
#      run keyword unless    ${state}    Fail
#      [Teardown]    power ue stop traffic and detach
# 
# *** Keywords ***
# Suite setup details
#     change 4G configuration
# #    Commission configuration
# 
# change 4G configuration
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    connection=4G_admin
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${4G_BTS_ID}/LNBTS-${4G_BTS_ID}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=6
#     ...    operation=update
#     ...    skip_parameter_relation_errors=${True}
#     ...    should_activate=${True}
#     ...    connection=4G_admin
#     [Teardown]  coam.teardown     connection=4G_admin
# 
# save Snapshot Log
#     [Arguments]    ${connection}=default    ${timeout}=600s
#     Log To Console    Save Snapshot Log
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=DU
#     ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#     ${snapshot_file_path}    set variable    ${CURDIR}/../snapshot/${timestamp}_snapshot.zip
#     coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=DU    timeout=${timeout}
#     sleep    10s
#     [Teardown]    coam.teardown     connection=DU
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
# power ue attach
#     [Arguments]    ${ue_index}
#     power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
#     power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# power ue stop traffic and detach
#     power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=samsung   iperf_type=via_command    protocol=udp
#     power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=samsung   iperf_type=via_command    protocol=udp
#     power_ue.UE Detach    ue_index=${0}    ue_type=samsung
#     CI_interface.Common Case Teardown
# 
# remove ignore fault from faultlist
#     [Arguments]     ${fault_list}    ${ignore_list}
#     FOR    ${item}    IN    @{ignore_list}
#         ${if_contain}    Run Keyword and Return Status    list should contain value    ${fault_list}    ${item}
#         run keyword if    ${if_contain}    remove values from list     ${fault_list}    ${item}
#     END
#     [Return]      ${fault_list}
# 
# get AMID info from web
#     [Arguments]     ${conn}=DU_conn    ${timeout}=15 min
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}   username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${conn}
#     ${AMID_distname}    set variable    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1
#     ${AMID_info}    coam.get_parameters    dist_name=${AMID_distname}    pattern=serialNumber     connection=${conn}
#     log    ${AMID_info}
#     ${AMID_SN}     get from dictionary    ${AMID_info}    serialNumber
#     [Teardown]    coam.teardown     connection=${conn}
#     [Return]      ${AMID_SN}
# 
# get AMID SN from bts log
#     [Arguments]  ${btslog_name}    ${connection}=ute
#     csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#     csn.Send Command   command=cat ${OUTPUT_DIR}/${btslog_name} |grep AMID |grep 475773A    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     ${data}     split string    ${data}    serialNumber:
#     ${data}     split string    ${data[1]}    ,
#     ${SN}    strip_string    ${data[0]}
#     [Return]  ${SN}
#     [Teardown]  csn.disconnect   connection=${connection}
# 
# 
# reset configuration
#     Du login page via webUI
#     Reset Configuration
#     [Teardown]    DU COAM selenium logout
# 
# Commission configuration
#     [Arguments]     ${conn}=DU_conn    ${timeout}=15 min
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${conn}
#     COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
#     wait until keyword succeeds    ${timeout}    30sec   Connect to gnb coam via ssl    connection=${conn}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
#     [Teardown]    coam.teardown     connection=${conn}
# 
# check BTS on air
#     [Arguments]     ${conn}=DU_conn    ${timeout}=15 min
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${conn}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
#     [Teardown]    coam.teardown     connection=${conn}
# 
# Get Active Alarm List
#     [Arguments]    ${connection}=default
#     Log To Console    Get Active Alarm List
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${connection}
#     ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
#     ${faultid_list}    create list
#     FOR    ${item}    IN    @{alarm_info}
#         ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
#         append to list    ${faultid_list}    ${fault_id_dic}
#     END
#     ${faultid_list}    remove ignore fault from faultlist    fault_list=${faultid_list}    ignore_list=${ignore_fault}
#     sort list    ${faultid_list}
#     [Return]    ${faultid_list}
#     [Teardown]    coam.teardown     connection=${connection}
# 
# Get history Alarm List
#     [Arguments]    ${connection}=default
#     Log To Console    Get history Alarm List
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${connection}
#     ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
#     ${faultid_list}    create list
#     FOR    ${item}    IN    @{alarm_info}
#         ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
#         append to list    ${faultid_list}    ${fault_id_dic}
#     END
#     ${faultid_list}    remove ignore fault from faultlist    fault_list=${faultid_list}    ignore_list=${ignore_fault}
#     sort list    ${faultid_list}
#     [Return]    ${faultid_list}
#     [Teardown]    coam.teardown     connection=${connection}
# 
# reset bts
#     [Arguments]     ${conn}=DU_conn
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${conn}
#     coam.reset_site    connection=${conn}
#     wait until keyword succeeds    15min    30sec   COAM Check GNB cell on air    connection=${conn}
#     [Teardown]    coam.teardown     connection=${conn}
# 
# change AES_SNOW_ZUC
#     [Arguments]   ${nea1_128}=0    ${nea3_128}=0    ${nia1_128}=0    ${nia3_128}=0    ${conn}=DU_conn
#     Connect to gnb coam via ssl    bts_host=${LMP_IP}     username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#     ...   connection=${conn}
#     ${distname}    set variable    MRBTS-${instance_id}/NRBTS-${bts_id}
#     ${info}    coam.get_managed_objects    class_name=NRBTS_A    connection=${conn}
#     ${parameter}    get from dictionary    ${info[0]}   parameters
#     ${cipherPrefL}    get from dictionary    ${parameter}    cipherPrefL
#     ${integrityProtPrefL}    get from dictionary    ${parameter}    integrityProtPrefL
#     set to dictionary     ${cipherPrefL}     nea1_128=${nea1_128}    nea3_128=${nea3_128}
#     set to dictionary     ${integrityProtPrefL}      nia1_128=${nia1_128}    nia3_128=${nia3_128}
#     ${cipherPrefL_list}    create list    ${cipherPrefL}
#     ${integrityProtPrefL_list}    create list    ${integrityProtPrefL}
#     coam.perform_parameter_recommissioning    dist_name=${distname}
#     ...    parameter=cipherPrefL    value=${cipherPrefL_list}    operation=update    skip_parameter_relation_errors=${False}
#     ...    should_activate=${True}    connection=${conn}
#     coam.perform_parameter_recommissioning    dist_name=${distname}
#     ...    parameter=integrityProtPrefL    value=${integrityProtPrefL_list}    operation=update    skip_parameter_relation_errors=${False}
#     ...    should_activate=${True}    connection=${conn}
#     [Teardown]    coam.teardown     connection=${conn}
# 
# 08_case_teardown
#     power ue stop traffic and detach
#     change AES_SNOW_ZUC    nea1_128=3    nea3_128=2    nia1_128=3     nia3_128=2
# 
# get and check fan speed
#     [Arguments]  ${fan_num}=${2}    ${connection}=ute
#     csn.Connect to     hostname=${LMP_IP}     username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}  alias=${connection}
#     FOR    ${index}    IN RANGE    ${fan_num}
#         csn.Send Command   command=tail /dev/ddal/fan/${index}/rpm    connection=${connection}
#         ${data}    csn.Read Output    connection=${connection}
#         log    ${data}
#         ${fan_speed}    strip_string    ${data}
#         should be true    ${fan_speed}>0
#     END
#     [Teardown]  csn.disconnect   connection=${connection}
# 
# stop fan and check speed alarm
#     [Arguments]     ${timeout}=240s    ${alias_gnb}=gnb_connect    ${connection_bbmod}=bbmod_connect
#     ...    ${connection}=ute
#     csn.Connect to     hostname=${LMP_IP}     username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}  alias=fan1
#     csn.Send Command   command=systemctl stop temp_ctrl.service    connection=fan1
#     csn.Send Command   command=for i in {1..1500}; do echo 0 > /dev/ddal/fan/0/pwm; sleep 1; done    connection=fan1
#     sleep    5s
#     csn.Send Command   command=tail /dev/ddal/fan/0/rpm    connection=fan1
#     ${data1}    csn.Read Output    connection=fan1
#     log    ${data1}
#     ${fan1_speed}    strip_string    ${data1}
#     csn.Connect to    hostname=${LMP_IP}    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    alias=${alias_gnb}    timeout=${timeout}
#     csn.Connect to    hostname=fct4s0icom.local    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    proxy=${alias_gnb}    alias=${connection_bbmod}    timeout=${timeout}
#     csn.Send Command   command=systemctl stop temp_ctrl.service    connection=${connection_bbmod}
#     csn.Send Command   command=for i in {1..1500}; do echo 1 > /dev/ddal/fan/1/pwm; sleep 1; done    connection=${connection_bbmod}
#     sleep    5s
#     csn.Send Command   command=tail /dev/ddal/fan/1/rpm    connection=${alias_gnb}
#     ${data2}    csn.Read Output    connection=${alias_gnb}
#     log    ${data2}
#     ${fan2_speed}    strip_string    ${data2}
#     should be true   ${fan1_speed}==0
#     should be true  ${fan2_speed}==0
#     log to console    sleep 30min wait.........
#     wait until keyword succeeds    30min    1min    wait alarm
# #    wait until keyword succeeds    5min    5s    wait until fan speed    con1=fan1
#     [Teardown]  Run Keywords    csn.disconnect   connection=${alias_gnb}    AND    csn.disconnect   connection=fan1
#     
# wait alarm
#     ${fault_id}    Get Active Alarm List
#     list should contain value    ${fault_id}    ${4077}
#     list should contain value    ${fault_id}    ${4078}
# 
# wait no alarm
#     ${fault_id}    Get Active Alarm List
#     list should not contain value    ${fault_id}    ${4077}
#     list should not contain value    ${fault_id}    ${4078}
#     [Return]  ${fault_id}
# 
# wait until fan speed
#     [Arguments]   ${con1}     ${timeout}=240s    ${alias_gnb}=gnb_connect    
#     ...    ${connection}=ute        ${connection_bbmod}=bbmod_connect
#     csn.Send Command   command=tail /dev/ddal/fan/0/rpm    connection=${con1}
#     ${data1}    csn.Read Output    connection=fan1
#     ${fan1_speed}    strip_string    ${data1}
#  
#     csn.Connect to    hostname=${LMP_IP}    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    alias=${alias_gnb}    timeout=${timeout}
#     csn.Connect to    hostname=fct4s0icom.local    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    proxy=${alias_gnb}    alias=${connection_bbmod}    timeout=${timeout}
#     csn.Send Command   command=tail /dev/ddal/fan/1/rpm    connection=${connection_bbmod}
#     ${data2}    csn.Read Output    connection=${connection_bbmod}
#     ${fan2_speed}    strip_string    ${data2}
#     should not be true   ${fan1_speed}==0
#     should not be true  ${fan2_speed}==0
# 
# recovery fan and service and check fan speed
#     [Arguments]    ${connection}=ute    ${timeout}=240s    ${alias_gnb}=gnb_connect
#     ...       ${connection_bbmod}=bbmod_connect
#     csn.Connect to     hostname=${LMP_IP}     username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}  alias=${connection}
#     csn.Send Command   command=systemctl start temp_ctrl     connection=${connection}
#     sleep    180s
#     csn.Send Command   command=tail /dev/ddal/fan/0/rpm    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     log    ${data}
#     ${fan_speed}    strip_string    ${data}
#     should be true    ${fan_speed}>0
# 
#     csn.Connect to    hostname=${LMP_IP}    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    alias=${alias_gnb}    timeout=${timeout}
#     csn.Connect to    hostname=fct4s0icom.local    username=${ssh_bts_USER}    password=${ssh_bts_PASSWORD}
#     ...    proxy=${alias_gnb}    alias=${connection_bbmod}    timeout=${timeout}
#     csn.Send Command   command=systemctl start temp_ctrl    connection=${connection_bbmod}
#     sleep    180s
#     csn.Send Command   command=tail /dev/ddal/fan/1/rpm    connection=${connection}
#     ${data}    csn.Read Output    connection=${connection}
#     log    ${data}
#     ${fan_speed}    strip_string    ${data}
#     should be true    ${fan_speed}>0
#     CI_interface.Common Case Teardown
#     [Teardown]  csn.disconnect   connection=${connection}
# 
# 
