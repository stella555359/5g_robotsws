# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CB005906    CRT
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_mmimo.robot
# 
# *** Variables ***
# ${actPdcchMultiplexing}    text|true|//*[@name\="actPdcchMultiplexing"]
# ${pdcchBfGainThd}    text|1|//*[@name\="pdcchBfGainThd"]
# ${pdcchBfCqiThd}    text|1|//*[@name\="pdcchBfCqiThd"]
# @{modify_list}              ${actPdcchMultiplexing}    ${pdcchBfGainThd}    ${pdcchBfCqiThd}
# ${target_ip}                10.69.67.202
# ${scfc_configuration1}      ${CURDIR}/../../resources/KISS/configuration_file/SCFC_ABIO_1cell_TM8_for_bts2317_SBTS00.xml
# @{COUNTER_LIST_1}    M8010C197    M8010C198    M8010C200    M8010C201    M8010C203    M8010C204    M8010C207
# @{COUNTER_LIST_2}    M8010C199    M8010C202    M8010C206    M8010C209    M8010C205    M8010C208
# 
# *** Test Cases ***
# CB007577_SR_A_07_PM_counter_check_and_robotness_testing
#     [Tags]    QC_324686
#     Step1:Set parameter and wait for onair
#     Step3:UEs attach to cell and traffic
#     Step4:modify CQI from 6 to 9
#     Step5:Waiting for at least 15min and get PM counter
#     Step6:Detach all UE
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start enb syslog'1-1'
#     Establish cell with bandwidth 15M and frameconfigure 2 7
#     Stop and collect enb syslog
#     Start enb syslog'1-2'
#     Run Keyword And Ignore Error    Reboot ENB And Wait Disconnection
#     Wait ENB Connection
#     ${bts_onair}    bts_should_be_onair    timeout=1500
#     ${cell_onair}   cell_should_be_onair    timeout=600
#     Should Be True    ${bts_onair}
#     Should Be True    ${cell_onair}
#     Stop and collect enb syslog
#     Start enb syslog'1-3'
#     # set rad parameter     setlog       ALL     ALL     FID_ECPRI      DEBUG
#     # set rad parameter     setlog       ALL     ALL     FID_PDCCH      DEBUG
#     # set rad parameter     setlog       ALL     ALL     FID_PDCCH_Multiplexing      DEBUG
#     set rad parameter    setrd    ALL    ALL    ERadSwDomainLteMac_TRdPdcchFlag    0x7f9
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue1_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue2_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue3_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue4_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue5_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue6_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue7_id}
#     should_be_true    ${status}
#     ${status}=    cpe_reboot_and_wait_status_is_disconnect    ${ue8_id}
#     should_be_true    ${status}
#     Stop and collect enb syslog
#     Wait Throughput Timer     60
# 
# Establish cell with bandwidth 15M and frameconfigure 2 7
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIR}/SCFC_1.xml
#     copy_file          ${scfc_configuration1}     ${scfc_path}
#     # Modify SCFC into 3cc CA             ${scfc_path}
#     # Add UL_CA_with_smartSched extend parameter             ${scfc_path}
#     initialize_scfc_via_env_variable    ${scfc_path}    ${scfc_path}
#     modify_scfc_and_full_commission    ${scfc_path}    ${modify_list}
# 
# Step3:UEs attach to cell and traffic
#     Start enb syslog'3'
#     # set rad parameter    setrd    ALL    ALL    ERadSwDomainLteMac_TRdPdcchFlag    0x7f9
#     cpe_ue_attach    ${ue1_id}
#     cpe_ue_attach    ${ue2_id}
#     cpe_ue_attach    ${ue3_id}
#     cpe_ue_attach    ${ue4_id}
#     cpe_ue_attach    ${ue5_id}
#     cpe_ue_attach    ${ue6_id}
#     cpe_ue_attach    ${ue7_id}
#     cpe_ue_attach    ${ue8_id}
#     Wait Throughput Timer    30
#     cpe_send_dl_throughput    host_ip=${ue1_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue2_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue3_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue4_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue5_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue6_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue7_id}    throughput_size=100M
#     cpe_send_dl_throughput    host_ip=${ue8_id}    throughput_size=100M
#     cpe_send_ul_throughput    host_ip=${ue1_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue2_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue3_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue4_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue5_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue6_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue7_id}    send_target_ip=${target_ip}    throughput_size=10M
#     cpe_send_ul_throughput    host_ip=${ue8_id}    send_target_ip=${target_ip}    throughput_size=10M
#     # start_capture_ttitrace'3'
#     Wait Throughput Timer    15    
#     # Save_and_Decode_ttitrace_'3'
#     Stop and collect enb syslog
# 
# Step4:modify CQI from 6 to 9
#     Start enb syslog'4_1'
#     # start_capture_ttitrace'4_1'
#     : FOR    ${i}    IN RANGE    9    5    -1
#     \    override_cqi     ${ue1_id}    ${i}
#     \    override_cqi     ${ue2_id}    ${i}
#     \    override_cqi     ${ue3_id}    ${i}
#     \    override_cqi     ${ue4_id}    ${i}
#     \    override_cqi     ${ue5_id}    ${i}
#     \    override_cqi     ${ue6_id}    ${i}
#     \    override_cqi     ${ue7_id}    ${i}
#     \    override_cqi     ${ue8_id}    ${i}
#     \    Wait Throughput Timer    2
#     # Save_and_Decode_ttitrace_'4_1'
#     Stop and collect enb syslog
#     Start enb syslog'4_2'
#     # start_capture_ttitrace'4_2'
#     : FOR    ${j}    IN RANGE    6    10
#     \    override_cqi     ${ue1_id}    ${j}
#     \    override_cqi     ${ue2_id}    ${j}
#     \    override_cqi     ${ue3_id}    ${j}
#     \    override_cqi     ${ue4_id}    ${j}
#     \    override_cqi     ${ue5_id}    ${j}
#     \    override_cqi     ${ue6_id}    ${j}
#     \    override_cqi     ${ue7_id}    ${j}
#     \    override_cqi     ${ue8_id}    ${j}
#     \    Wait Throughput Timer    2
#     # Save_and_Decode_ttitrace_'4_2'
#     Stop and collect enb syslog
# 
# Step5:Waiting for at least 15min and get PM counter
#     ${remain_time}=    get_counter_file_remaining_time
#     set test variable    ${remain_time}
#     Wait Throughput Timer    ${remain_time}
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    
#    ...    source_path=/tmp/    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
#     ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     : FOR    ${PM_counter}    IN    @{COUNTER_LIST_1}
#     \    ${Count_serving}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    ${PM_counter}    1
#     \    Wait Throughput Timer    1s
#     \    should_be_true    ${Count_serving}>0
# 
# Step6:Detach all UE
#     Start enb syslog'6'
#     # run_keyword_and_ignore_error    collect_snapshot_and_im_via_admin          ${TEST_LOG_DIR}
#     cpe_ue_detach    host_ip=${ue1_id}
#     cpe_ue_detach    host_ip=${ue2_id}
#     cpe_ue_detach    host_ip=${ue3_id}
#     cpe_ue_detach    host_ip=${ue4_id}
#     cpe_ue_detach    host_ip=${ue5_id}
#     cpe_ue_detach    host_ip=${ue6_id}
#     cpe_ue_detach    host_ip=${ue7_id}
#     cpe_ue_detach    host_ip=${ue8_id}
#     Stop and collect enb syslog
# 
# Wait Throughput Timer
#     [Arguments]    ${time}
#     Sleep    ${time}
