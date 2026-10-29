*** Settings ***
Documentation    CB012544 TA cases common steps
...              Author: jun.8.chen@nokia-sbell.com

Resource    CB012544_common.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
@{SWCONFIG_l2ps_syslog}    0x58057a=3    0x58057c=1610612736

*** Keywords ***
CB012544-C_14_Verify_CN_Paging_Successful_Rate_for_eDRX_UE_with_different_eDRX_Cycle
#    Update R&D Debug Parameter
    Update Related Parameters For Paging    cell_idex=351
    Wait Gnb Ready And Cell On Air
    # Start to attach
    Enable Required PA Port
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=351    connection=GNB_OAM    timeout=300
    CB012544_case_steps.UE Reboot With ADB
    Sleep    10sec
    M60_RedCap.Prepare UE    ue_index=${ue_index}
    M60_RedCap.UE Detach    ue_index=${ue_index}
    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
    Log To Console    ${\n}INFO:--- start to attach ---
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_attach
    ...                                                                             cprt_collector_name=cprt_attach
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${status}    Run Keyword And Return Status    CB012544 UE Attach For Paging
    Sleep    10sec
    Run Keyword If    '${status}'=='False'    Run Keywords    Log To Console    --- start attach for second time ---
    ...                                                       AND    CB012544 UE Attach For Paging
    Sleep    30sec
    ${attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=cpif_attach
    ...                                                                        cprt_collector_name=cprt_attach
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
    ${ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_log_on_testPC}
    Check UE Enter Into RRC Idle State    wireshark_log=${attach_log_on_testPC}    cell_index=351
    Log To Console    ${\n}INFO:--- start to paging ---
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    cpif_paging_${timestamp}
    ${cprt_log_name}    Set Variable    cprt_paging_${timestamp}
    Get Syslog Start Time
#    OperatingSystem.Run    command=cd /tmp/btslog2; rm -rf *
#    ${parameters}    Create Dictionary    MaxSysLogFileSize=1100    SysLogFileTemplate=/tmp/btslog2/btslog/SYSLOG_%1.LOG
#    ${btslog_configuration}    Create Dictionary    LOG_CONFIGURATION=${parameters}
    Recover Collect Syslog For Gnb
    Get Syslog Start Time
#    Run Keyword And Continue On Failure    Start To Collect Btslog    btslog_collector_name=btslog_${timestamp}
#    ...                                                               btslog_configuration=${btslog_configuration}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...                                                                             cprt_collector_name=${cprt_log_name}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${timestamp_for_paging_start}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_for_paging_start}    epoch
    Sleep    10sec
    FOR    ${i}    IN RANGE    ${5}
        Log To Console    ${\n}INFO:-- start to paging for ${i} time --
        Run Keyword And Continue On Failure    M60_RedCap.Start DL traffic    ue_addr=${ue_ip}
        ...                                                                   dl_throughput=2MKbits/sec
        ...                                                                   ue_index=${ue_index}
        Sleep    15sec
        Run Keyword And Continue On Failure    M60_RedCap.Stop Traffic    ue_index=${ue_index}    ul_traffic=${False}
        Sleep    25sec
        Log To Console    ${\n}INFO:-- end of paging for ${i} time --
    END
    Sleep    10sec
    ${paging_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=${wireshark_log_name}
    ...                                                                        cprt_collector_name=${cprt_log_name}
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
#    Run Keyword And Continue On Failure    Stop Btslog Collection    btslog_collector_name=btslog_${timestamp}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${btslog_path}    Join path    ${TS_CASE_LOG_PATH}    btslog_${timestamp}
    Create Directory    ${btslog_path}
    OperatingSystem.Copy File    ${syslog_file}    ${btslog_path}/syslog_files.tgz
    Log To Console    ${\n}INFO:--- start to check the case logs ---
    ${test_value}    Check UE Enter Into RRC Idle State    wireshark_log=${paging_log_on_testPC}    cell_index=351
    ${paging_length}    Get Length    ${test_value}
    Run Keyword And Continue On Failure    Should Be True    ${paging_length}==5    msg=paging times is not 5 times.
    ${count_of_CNPagingCNT}    ${nR_paging_eDRX_Cycle_value}    ${CNRePagingCNT_count}    The Count Of CNPagingCNT
    ...    file_path=${paging_log_on_testPC}
    ...    send_dl_data_times=${5}
    ${count_of_PagingOutOfPTWCNT}    Run Keyword If    ${nR_paging_eDRX_Cycle_value}>=3    The Count Of PagingOutOfPTWCNT
    ...                                                    syslog_file_path=btslog_${timestamp}
    ...    ELSE    Set Variable    ${0}

    Log To Console    ${\n}INFO:--- start to check the PM counters ---
    Sleep    6min
    ${counter_info_dict_list}    BTS Counters List
    ${status}    ${counter_id_mapping_values}    Run Keyword And Ignore Error
    ...    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                         counter_info_dict_list=${counter_info_dict_list}
    Sleep    10sec
    Run Keyword If    '${status}'=='FAIL'    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                                                           counter_info_dict_list=${counter_info_dict_list}
    Verify PM Counter Values    count_of_CNPagingCNT=${count_of_CNPagingCNT}
    ...                         count_of_PagingOutOfPTWCNT=${count_of_PagingOutOfPTWCNT}
    ...                         count_of_CNRePagingCNT=${CNRePagingCNT_count}
    ...                         counter_id_mapping_values=${counter_id_mapping_values}

    Log To Console    ${\n}INFO:--- start to check HashedUEID and SFN related logs ---
    ${HashedId}    ${tmsi_value}    Run Keyword And Continue On Failure    Verify The Hashed ID Value    file_path=${paging_log_on_testPC}

    ${nrpaging_Time_Window_value}    Run Keyword If    ${nR_paging_eDRX_Cycle_value}>=3    Run Keyword And Continue On Failure
    ...    Verify The NRPagingeDRXInformation Message    file_path=${paging_log_on_testPC}
    Run Keyword If   ${nR_paging_eDRX_Cycle_value}>=3   Run Keyword And Continue On Failure
    ...    Verify The SFN In Syslog   syslog_file_path=btslog_${timestamp}
    ...                               HashedId=${HashedId}
    ...                               nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                               nrpaging_Time_Window_value=${nrpaging_Time_Window_value}
    Verify The UEID And TConfigToUse In Syslog For Idle    file_path=${paging_log_on_testPC}
    ...                                                    syslog_file_path=btslog_${timestamp}
    ...                                                    nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}
    ...    AND    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/T283_gNB_${stream_version}.xml
    ...                                                                 gnb_index=${0}
    ...                                                                 timeout_for_commission=900
    ...                                                                 wait_gnb_up_timeout=30 min
    ...                                                                is_pdl_checking_needed=${True}
    ...    AND   Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api


CB012544-D_16_Verify_RAN_Paging_Successful_Rate_for_eDRX_UE
#    Update R&D Debug Parameter
    12544_D Update Related Parameters For Paging    cell_idex=351
    Wait Gnb Ready And Cell On Air
    # Start to attach
    Enable Required PA Port
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=351    connection=GNB_OAM    timeout=300
    CB012544_case_steps.UE Reboot With ADB
    Sleep    10sec
    M60_RedCap.Prepare UE    ue_index=${ue_index}
    M60_RedCap.UE Detach    ue_index=${ue_index}
    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
    Log To Console    ${\n}INFO:--- start to attach ---
#    OperatingSystem.Run    command=cd /tmp/btslog2; rm -rf *
#    ${parameters}    Create Dictionary    MaxSysLogFileSize=1000    SysLogFileTemplate=/tmp/btslog2/btslog/SYSLOG_%1.LOG
#    ${btslog_configuration}    Create Dictionary    LOG_CONFIGURATION=${parameters}
    Recover Collect Syslog For Gnb
#    Run Keyword And Continue On Failure    Start To Collect Btslog    btslog_collector_name=syslog_attach
#    ...                                                               btslog_configuration=${btslog_configuration}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_attach
    ...                                                                             cprt_collector_name=cprt_attach
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${status}    Run Keyword And Return Status    CB012544 UE Attach For Paging
    Sleep    10sec
    Run Keyword If    '${status}'=='False'    Run Keywords    Log To Console    --- start attach for second time ---
    ...                                                       AND    CB012544 UE Attach For Paging
    Sleep    30sec
    ${attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=cpif_attach
    ...                                                                        cprt_collector_name=cprt_attach
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
#    Run Keyword And Continue On Failure    Stop Btslog Collection    btslog_collector_name=syslog_attach
    ${ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_log_on_testPC}
    Check UE Enter Into RRC Release State    wireshark_log=${attach_log_on_testPC}
    Log To Console    ${\n}INFO:--- start to paging ---
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    cpif_paging_${timestamp}
    ${cprt_log_name}    Set Variable    cprt_paging_${timestamp}
#    OperatingSystem.Run    command=cd /tmp/btslog2; rm -rf *
#    ${parameters}    Create Dictionary    MaxSysLogFileSize=1100    SysLogFileTemplate=/tmp/btslog2/btslog/SYSLOG_%1.LOG
#    ${btslog_configuration}    Create Dictionary    LOG_CONFIGURATION=${parameters}
    Recover Collect Syslog For Gnb
    Log To Console    second syslog collection start
    Get Syslog Start Time
#    Run Keyword And Continue On Failure    Start To Collect Btslog    btslog_collector_name=btslog_${timestamp}
#    ...                                                               btslog_configuration=${btslog_configuration}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...                                                                             cprt_collector_name=${cprt_log_name}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=${0}
    ${timestamp_for_paging_start}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_for_paging_start}    epoch
    Sleep    10sec
    FOR    ${i}    IN RANGE    ${5}
        Log To Console    ${\n}INFO:-- start to paging for ${i} time --
        Run Keyword And Continue On Failure    M60_RedCap.Start DL traffic    ue_addr=${ue_ip}
        ...                                                                   dl_throughput=2MKbits/sec
        ...                                                                   ue_index=${ue_index}
        Sleep    15sec
        Run Keyword And Continue On Failure    M60_RedCap.Stop Traffic    ue_index=${ue_index}    ul_traffic=${False}
        Sleep    25sec
        Log To Console    ${\n}INFO:-- end of paging for ${i} time --
    END
    Sleep    10sec
    ${paging_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                                        tcpdump_collector_name=${wireshark_log_name}
    ...                                                                        cprt_collector_name=${cprt_log_name}
    ...                                                                        gnb_index=${0}
    ...                                                                        asik_connection_alias=ASIK Master
#    Run Keyword And Continue On Failure    Stop Btslog Collection    btslog_collector_name=btslog_${timestamp}
    Log To Console    second syslog collection end
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${btslog_path}    Join path    ${TS_CASE_LOG_PATH}    btslog_${timestamp}
    Create Directory    ${btslog_path}
    OperatingSystem.Copy File    ${syslog_file}    ${btslog_path}/syslog_files.tgz
    Log To Console    ${\n}INFO:--- start to check the case logs ---
    ${test_value}    Check UE Enter Into RRC Release State    wireshark_log=${paging_log_on_testPC}
    ${paging_length}    Get Length    ${test_value}
    Should Be True    ${paging_length}==5    msg=RRC Release times is not 5 times.
    ${count_of_CNPagingCNT}    ${nR_paging_eDRX_Cycle_value}    The Count Of CNPagingCNT For Inactive    file_path=${paging_log_on_testPC}
    ...                                                                                                  send_dl_data_times=${5}
    ${count_of_RrcResumeRequest}    The Count Of RRC Resume Request In Syslog    syslog_file_path=btslog_${timestamp}
    Run Keyword And Ignore Error    Should Be True    ${count_of_RrcResumeRequest}==5    msg=RRC Resume Request times is not 5 times.
    Log To Console    ${\n}INFO:--- start to check the PM counters ---
    Sleep    6min
    ${counter_info_dict_list}    BTS Counters List For Inactive
    ${status}    ${counter_id_mapping_values}    Run Keyword And Ignore Error
    ...    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                         counter_info_dict_list=${counter_info_dict_list}
    Run Keyword If    '${status}'=='FAIL'    Get PM Counter Values Information    counter_generatd_time=${counter_generatd_time}
    ...                                                                           counter_info_dict_list=${counter_info_dict_list}
    Sleep    10sec
    Verify PM Counter Values For Inactive    count_of_CNPagingCNT=${count_of_CNPagingCNT}
    ...                                      counter_id_mapping_values=${counter_id_mapping_values}

    Log To Console    ${\n}INFO:--- start to check HashedUEID and SFN related logs ---
    ${HashedId}    Get The HashedUEIdentityIndexValue In Pcap    file_path=${paging_log_on_testPC}
    ${nrpaging_Time_Window_value}    Run Keyword If    ${nR_paging_eDRX_Cycle_value}>=3    Verify The NRPagingeDRXInformation Message
    ...    file_path=${paging_log_on_testPC}
    ${drxDefaultPaging_value}    ${ranEdrxPagingCycle_value}    ${ranPagingCycle_value}    Save Current SCF And Get value Of Parameters
    ${extendedDRX_CycleInactive_r17_value}    Get The extendedDRX_CycleInactive_r17 Capacity    file_path=${attach_log_on_testPC}
    ${eDrx_RAN}    ${eDRX_Cycle_number}    Verify The NRPagingeDRXInformationforRRCINACTIVE Message
    ...                                        file_path=${paging_log_on_testPC}
    ...                                        nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                                        ranEdrxPagingCycle_value=${ranEdrxPagingCycle_value}
    ...                                        extendedDRX_CycleInactive_r17_value=${extendedDRX_CycleInactive_r17_value}
    Run Keyword If   ${nR_paging_eDRX_Cycle_value}>=3   Verify The SFN In Syslog   syslog_file_path=btslog_${timestamp}
    ...                                                                            HashedId=${HashedId}
    ...                                                                            nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                                                                            nrpaging_Time_Window_value=${nrpaging_Time_Window_value}
    Verify The UEID And TConfigToUse In Syslog For Inactive    file_path=${paging_log_on_testPC}
    ...                                                        syslog_file_path=btslog_${timestamp}
    ...                                                        nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                                                        eDrx_RAN=${eDrx_RAN}
    ...                                                        eDRX_Cycle_number=${eDRX_Cycle_number}
    ...                                                        drxDefaultPaging_value=${drxDefaultPaging_value}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
#    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
#    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=btslog_${timestamp}    AND
#    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=btslog_${timestamp}    AND
#    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=syslog_attach    AND
#    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=syslog_attach
    ...    AND    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/T283_gNB_${stream_version}.xml
    ...                                                                 gnb_index=${0}
    ...                                                                 timeout_for_commission=900
    ...                                                                 wait_gnb_up_timeout=30 min
    ...                                                                is_pdl_checking_needed=${True}
    ...    AND   Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api

12544_Suite_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    csn.reset_cache
    Suite Log Path Create
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    Set Suite Variable    ${ue_index}    ${8}

12544_Case_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${commission_flag}=${None}
    Log    ${commission_flag}
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
    ${BASIC_SCF_PATH}   Set Variable    /home/ute/SCF/GNB0_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    Backup and Modify swconfig file    swconfig_modify=@{SWCONFIG_l2ps_syslog}
    Perform Commission    scf_file_path=${BASIC_SCF_PATH}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    Initial PA Value Setting For All Attenuators

12544_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${8}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach    ue_index=${ue_index}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Run Keyword And Ignore Error    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

12544_B_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Run Keyword And Ignore Error    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

12544_Suite_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

UE Reboot With ADB
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${8}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}
