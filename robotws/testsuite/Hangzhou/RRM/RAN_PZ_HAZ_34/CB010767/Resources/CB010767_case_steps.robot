*** Settings ***
Documentation    CB009363 TA cases common steps
...              Author: Stella.lin@nokia-sbell.com

Resource    CB010767_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/For_feature/Keywords_for_9915_10249.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
CB009568-A_51_RedCap_UE_handover_from_TDD_cell_to_FDD_cell
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Enable Required PA Port
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=351    connection=GNB_OAM    timeout=300
    M60_RedCap.Prepare UE    ue_index=${ue_index}
    M60_RedCap.UE Detach    ue_index=${ue_index}
    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
    ${status}    ${attach_info_first}    Run Keyword And Ignore Error     M60_RedCap.UE Attach    expect_attach_cell_index=351
    ...                                                                                           ue_index=${ue_index}
    Sleep    30sec
    Run Keyword If    '${status}'=='FAIL'    log to console    start attach for second time
    ${attach_info_second}    Run Keyword If    '${status}'=='FAIL'    Run Keywords    UE Reboot With ADB    AND
    ...    M60_RedCap.UE Attach    expect_attach_cell_index=351    ue_index=${ue_index}
    ${attach_info}    Set Variable If    '${status}'=='FAIL'    ${attach_info_second}    ${attach_info_first}
    ${ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_info['cpif_log_path']}
    M60_RedCap.Start DL traffic    ue_addr=${ue_ip}    ue_index=${ue_index}
    Sleep    20sec
    M60_RedCap.Prepare for UL traffic    ue_ip_addr=${ue_ip}    ue_index=${ue_index}
    M60_RedCap.Start UL traffic    ue_ip=${ue_ip}    ue_index=${ue_index}
    log to console   ---start to check tput for source cell---
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=351
    ...                                                             expect_dl_tput=65
    ...                                                             expect_ul_tput=12
    ...                                                             target_avg_percent=0.95
    ...                                                             min_percent=0.85
    Comment    \n****** start capture bip logs  ******\n
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=351
    Sleep    6sec
    ${bip_log_path}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector

    log to console   ---start to trigger handover---
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Start Container Capture Wireshark Log     tcpdump_collector_name=A5_intragnb_interfre_handover_${timestamp}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=${0}
    Run Keyword And Continue On Failure    Enable Required PA Port   value=35
    sleep  5sec
    ${timestamp_for_paging_start}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Enable Required PA Port   attenuator_index=${0}    pa_port_index=${${15},${16}}   value=15
    sleep  15sec
    Run Keyword And Continue On Failure    Enable Required PA Port   value=127
    sleep  10sec
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=A5_intragnb_interfre_handover_${timestamp}
    log to console   ---start to check tput for target cell---
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=1
    ...                                                             expect_dl_tput=60
    ...                                                             expect_ul_tput=85
    ...                                                             target_avg_percent=0.9
    ...                                                             min_percent=0.8
    #checkpoint for HO
    log to console   ---start to check message flow---
    Run Keyword And Continue On Failure    CB010767_common.Check A2 Measurement Report    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                                                   pci=351
    Run Keyword And Continue On Failure    CB010767_common.Check A5A3 Measurement Report    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                                                     exp_source_pci=351
    ...                                                                                     exp_target_pci=101
    Run Keyword And Continue On Failure    CB010767_common.Check RRC Reestablishment    cpif_log_path=${cpif_attach_log_on_testPC}
    Run Keyword And Continue On Failure    CB010767_common.Check RRC Reconfigure And RRC Reconfigure Complete
    ...    cpif_log_path=${cpif_attach_log_on_testPC}
    #check PM counter for HO
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_for_paging_start}    epoch
    Sleep    6min
    ${counter_info_dict_list}    BTS Counters List For 9568
    ${counter_id_mapping_values}    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                                                  counter_info_dict_list=${counter_info_dict_list}
    Verify PM Counter Values For 9568    counter_id_mapping_values=${counter_id_mapping_values}    handover_type=intra
    Checkpoint For 9915_Trunk_9568_A51    bip_log=${bip_log_path[-1]}    pci=351
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=A5_intragnb_interfre_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    core.teardown_collectors    names=A5_intragnb_interfre_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/T283_gNB_${stream_version}.xml
    ...                                                                 gnb_index=${0}
    ...                                                                 timeout_for_commission=900
    ...                                                                 wait_gnb_up_timeout=30 min
    ...                                                                is_pdl_checking_needed=${True}
    ...    AND   Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api


CB009568-A_40_2RX_Successful_Inter_gNB_NG_based_Handover_based_on_A3_measurements_XnHoNotAllowed_different_AMF_longSN
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
#    Update Related Parameters For AMF HO
    Enable Required PA Port
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=351    connection=GNB_OAM    timeout=300
    M60_RedCap.Prepare UE    ue_index=${ue_index}
    M60_RedCap.UE Detach    ue_index=${ue_index}
    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
    ${status}    ${attach_info_first}    Run Keyword And Ignore Error     M60_RedCap.UE Attach    expect_attach_cell_index=351
    ...                                                                                           ue_index=${ue_index}
    Sleep    30sec
    Run Keyword If    '${status}'=='FAIL'    log to console    start attach for second time
    ${attach_info_second}    Run Keyword If    '${status}'=='FAIL'    Run Keywords    UE Reboot With ADB    AND
    ...    M60_RedCap.UE Attach    expect_attach_cell_index=351    ue_index=${ue_index}
    ${attach_info}    Set Variable If    '${status}'=='FAIL'    ${attach_info_second}    ${attach_info_first}
    ${ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_info['cpif_log_path']}
    M60_RedCap.Start DL traffic    ue_addr=${ue_ip}    ue_index=${ue_index}
    Sleep    20sec
    M60_RedCap.Prepare for UL traffic    ue_ip_addr=${ue_ip}    ue_index=${ue_index}
    M60_RedCap.Start UL traffic    ue_ip=${ue_ip}    ue_index=${ue_index}
    log to console   ---start to check tput for source cell---
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=351
    ...                                                             expect_dl_tput=65
    ...                                                             expect_ul_tput=12
    ...                                                             target_avg_percent=0.95
    ...                                                             min_percent=0.85
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Start Container Capture Wireshark Log     tcpdump_collector_name=A5_intergnb_source_handover_${timestamp}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=${0}
    Start Container Capture Wireshark Log     tcpdump_collector_name=A5_intergnb_target_handover_${timestamp}
    ...    asik_connection_alias=ASIK Master1
    ...    gnb_index=${1}
    log to console   ---start to trigger handover---
    Run Keyword And Continue On Failure    Enable Required PA Port   value=35
    sleep  5sec
    ${timestamp_for_paging_start}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Enable Required PA Port    attenuator_index=${4}    value=0
    sleep  15sec
    Run Keyword And Continue On Failure    Enable Required PA Port   value=127
    Run Keyword And Continue On Failure    Enable Required PA Port    attenuator_index=${4}    value=10
    sleep  10sec
    ${cpif_ho_source_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=A5_intergnb_source_handover_${timestamp}    asik_connection_alias=ASIK Master    gnb_index=${0}
    ${cpif_ho_target_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=A5_intergnb_target_handover_${timestamp}    asik_connection_alias=ASIK Master1    gnb_index=${1}
    log to console   ---start to check tput for target cell---
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=1
    ...                                                             expect_dl_tput=30
    ...                                                             expect_ul_tput=18
    ...                                                             target_avg_percent=0.95
    ...                                                             min_percent=0.85
    ...                                                             connection=GNB_OAM1
    ...                                                             gnb_index=1
    #checkpoint for HO
    log to console   ---start to check message flow---
    Run Keyword And Continue On Failure    CB010767_common.Check A2 Measurement Report    cpif_log_path=${cpif_ho_source_log_on_testPC}
    ...                                                                                   pci=351
    Run Keyword And Continue On Failure    CB010767_common.Check A5A3 Measurement Report    cpif_log_path=${cpif_ho_source_log_on_testPC}
    ...                                                                                     exp_source_pci=351
    ...                                                                                     exp_target_pci=253
    Run Keyword And Continue On Failure    CB010767_common.Check RRC Reestablishment    cpif_log_path=${cpif_ho_source_log_on_testPC}
    Run Keyword And Continue On Failure    Check RRC Reconfigure And RRC Reconfigure Complete For InterGNB
    ...    source_ho_log_path=${cpif_ho_source_log_on_testPC}
    ...    target_ho_log_path=${cpif_ho_target_log_on_testPC}
    #check PM counter for HO
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_for_paging_start}    epoch
    Sleep    6min
    ${counter_info_dict_list}    BTS Counters List For 9568
    ${counter_id_mapping_values}    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                                                  counter_info_dict_list=${counter_info_dict_list}
    Verify PM Counter Values For 9568    counter_id_mapping_values=${counter_id_mapping_values}    handover_type=inter
#    [Teardown]    Run Keywords    Recover Related Parameters For AMF HO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=A5_intergnb_source_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    core.teardown_collectors    names=A5_intergnb_source_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    core.stop_collectors    names=A5_intergnb_target_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    core.teardown_collectors    names=A5_intergnb_target_handover_${timestamp}
    ...    AND    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/T283_gNB_${stream_version}.xml
    ...                                                                 gnb_index=${0}
    ...                                                                 timeout_for_commission=900
    ...                                                                 wait_gnb_up_timeout=30 min
    ...                                                                is_pdl_checking_needed=${True}
    ...    AND   Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api


10767_Suite_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    csn.reset_cache
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    Set Suite Variable    ${ue_index}    ${8}

10767_Case_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${second_gnb_commission}=${False}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    Run Keyword And Ignore Error    Run    cp /home/ute/SCF/btslog.ini /home/ute/btslog2/
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}
    ${BASIC_SCF_PATH}    Set Variable    /home/ute/SCF/GNB0_BASIC_GOLDEN_SCF_${stream_version}.xml
    Perform Commission    scf_file_path=${BASIC_SCF_PATH}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    ${BASIC_SCF_PATH_1}    Set Variable    /home/ute/SCF/GNB1_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    Run Keyword If    ${second_gnb_commission}     Perform Commission    scf_file_path=${BASIC_SCF_PATH_1}
    ...                                                                  gnb_index=${1}
    ...                                                                  timeout_for_commission=900
    ...                                                                  wait_gnb_up_timeout=30 min
    ...                                                                  is_pdl_checking_needed=${True}
    Initial PA Value Setting For All Attenuators
    Sleep   10s
    UE Reboot With ADB

10767_Case_Teardown
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${8}    ${second_gnb_commission}=${False}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${ue_index}    ul_traffic=${False}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach    ue_index=${ue_index}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Run Keyword If    ${second_gnb_commission}    Run Keyword And Ignore Error    Capture Snapshot For Target Gnb
    Run Keyword And Ignore Error    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

10767_Suite_Teardown
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

UE Reboot With ADB
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${8}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

