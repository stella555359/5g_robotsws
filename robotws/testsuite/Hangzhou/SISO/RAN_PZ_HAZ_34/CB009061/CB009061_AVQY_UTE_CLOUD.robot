*** Settings ***
Suite Setup       Run Keywords    CI_interface.Common Suite Setup   AND  robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords
...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    AND
...    Run Keyword And Ignore Error    coam_gnb_classical.COAM Commission with scf file
...        scf_file_path=${scf_file_template_path}/SCF_${stream}.xml    AND
...    robot_common_operations.Common Suite Teardown
Test Setup        robot_common_operations.Common Case Setup    allowed_faults_ids=49    fail_with_alarms=${False}
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009061/Resource/CB009061_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009061/Resource/CB009061.py


Documentation
...    Author:yingying Li
...    contact:yuanyuan.liu@nokia-sbell.com
...    squad group:HAZ3_SG3
...    Feature CB009061  AVQY in trunk program

Force Tags        5G_RAN   PY310

*** Variables ***
${gnb_index}    0
${du_index}     0
${common_unit_index}  0
${scf_file_template_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T2071
${REFERENCE_CONFIGURATION_ID}    CNF_5G_3
${dl_throughput_4CC_50M}     850M
${Expect_DOWNLINK_4CC_50M}    748
${ul_throughput_4CC_50M}    100M
${Expect_UPLINK_4CC_50M}    90
${dl_throughput_2CC}     1600M
${Expect_DOWNLINK_2CC}    1000
${ul_throughput_2CC}    230M
${Expect_UPLINK_2CC}    160
${dl_throughput_3CC_80M}     1300M
${Expect_DOWNLINK_3CC_80M}    900
${ul_throughput_3CC_80M}    170M
${Expect_UPLINK_3CC_80M}    100
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%
${bts_host}     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}
@{list_of_cell}      33931267

*** Test Cases ***
[1]CB009061_classical_07_12759_I_B1_4CC_Basic_l3call_with_data_transfer
    [Tags]    CRT_TRUNK
    COAM Create log directory
	Connect to gnb coam via ssl
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}_4CC.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    Log To Console    attch in cell3
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    @{nr_cell_list}    Get NRCELL ID List Via Admin CLI
    Set Test Variable    @{nr_cell_list}
    Log To Console    block cell 31 32 33
    Block Cells Except One      @{nr_cell_list}      exception_cell_id=3
    sleep    10s
    Log To Console    prepare ue
    Prepare UE for ${ue_type}
    Log To Console    attach ue in cell3
    sleep    10s
    UE Attach for ${ue_type}
    Log To Console    start traffic and check TP
    Run keyword and continue on failure    Start traffic and check result    dltp_expected=${Expect_DOWNLINK_4CC_50M}
    ...     data_send_dl=${dl_throughput_4CC_50M}    ultp_expected=${Expect_UPLINK_4CC_50M}    data_send_ul=${ul_throughput_4CC_50M}
    ...     tp_direction=both    sleep_time=1m     call_duration=5m    target_avg_percent=0.98    min_percent=0.80
    sleep    5s
    Log To Console    unblock cell 31 32 33
    Unblock Cells Except One      @{nr_cell_list}      exception_cell_id=3
    #Log To Console    attch in cell33
    #Log To Console    block cell 3 31 32
    #Block Cells Except One      @{nr_cell_list}      exception_cell_id=33
    #sleep    100s
    #Set Test Variable   ${cell_identify}    33931297
    #${cell_identify}   convert to string   ${cell_identify}
    #@{list_of_cell}     Create List         ${cell_identify}
    #Set Suite Variable     @{list_of_cell}
    #Run keyword and continue on failure    Check throughput according to direction and protocol
    #...    dltp_expected=${Expect_DOWNLINK_4CC_50M}    ultp_expected=${Expect_UPLINK_4CC_50M}      tp_direction=both
    #...    call_duration=5m      target_avg_percent=0.98    min_percent=0.80
    #sleep    5s
    #Stop traffic according to direction and protocol
    #UE Detach for ${ue_type}
    #Log To Console    unblock cell 3 31 32
    #Unblock Cells Except One     @{nr_cell_list}    exception_cell_id=33
    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]    Run Keywords     robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_09_Hard_RAT_Reset_and_RAT_Reset
    [Tags]      CRT_TRUNK
    Case Preparation
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    log to console    reset BBMOD
    Connect to gnb coam via ssl
    BB reset and check status via coam
    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8

    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_11_nr_Cell_block_and_unblock_SM_RF_Module_lock_unlock
    [Tags]      CRT_TRUNK
    COAM Create log directory
	Connect to gnb coam via ssl
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}_2CC.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    RU_lock_and_unlock
    @{nr_cell_list}    Get NRCELL ID List Via Admin CLI
    Set Test Variable    @{nr_cell_list}
    Log To Console    block cell 31
    Block Cells Except One      @{nr_cell_list}    exception_cell_id=3
    sleep    10
    Log To Console    attch in cell3
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    Log To Console    prepare ue
    Prepare UE for ${ue_type}
    sleep    10s
    UE Attach for ${ue_type}
    Set Test Variable   ${cell_identify}    33931267
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
    Log To Console    start traffic and check TP
    Run keyword and continue on failure    Start traffic and check result    dltp_expected=${Expect_DOWNLINK_2CC}
    ...     data_send_dl=${dl_throughput_2CC}    ultp_expected=${Expect_UPLINK_2CC}    data_send_ul=${ul_throughput_2CC}
    ...     tp_direction=both     sleep_time=1m     call_duration=5m    target_avg_percent=0.98    min_percent=0.80
    sleep    10
    Stop traffic according to direction and protocol
    UE Detach for ${ue_type}
    Log To Console    Unblock Cell 31
    Unblock Cells Except One      @{nr_cell_list}      exception_cell_id=3
    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8

    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_12_nr_CM_Recommissioning
    [Tags]      CRT_TRUNK
    COAM Create log directory
	Connect to gnb coam via ssl
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    modify_parameter_recommissioning
    @{nr_cell_list}    Get NRCELL ID List Via Admin CLI
    Set Test Variable    @{nr_cell_list}
    Log To Console    block cell 31 32
    Block Cells Except One      @{nr_cell_list}    exception_cell_id=3
    sleep    10
    Log To Console    attch in cell3
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update3CC}
    Log To Console    prepare ue
    Prepare UE for ${ue_type}
    sleep    10s
    UE Attach for ${ue_type}
    Log To Console    start traffic and check TP
    Set Test Variable   ${cell_identify}    33931267
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
    Run keyword and continue on failure    Start traffic and check result    dltp_expected=${Expect_DOWNLINK_3CC_80M}
    ...     data_send_dl=${dl_throughput_3CC_80M}    ultp_expected=${Expect_UPLINK_3CC_80M}    data_send_ul=${ul_throughput_3CC_80M}
    ...     tp_direction=both    sleep_time=1m     call_duration=5m    target_avg_percent=0.98    min_percent=0.80
    sleep    10
    Stop traffic according to direction and protocol
    UE Detach for ${ue_type}
    Log To Console    Unblock Cell 31 32
    Unblock Cells Except One      @{nr_cell_list}      exception_cell_id=3

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_16_nr_General_SiSo_fault_4598_trigger_with_tiltOffset
    [Tags]      CRT_TRUNK
    Case Preparation
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    ${fault_list}    Create List    4598    1900
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Connect to gnb coam via ssl
     Log To Console     update tiltOffset to trigger FID4598
    update parameter          parameters_list=${parameters_for_4598}
    reset RU
    BuiltIn.sleep     60s
    coam_siso_common.Expect Fault Should Present      faultId=4598
     Log To Console     update tiltOffset to clear FID4598
    update parameter          parameters_list=${parameters_for_4598_clear}
    BuiltIn.sleep     180s
    coam_siso_common.Expect Fault Should Absent      faultId=4598

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_18_nr_NR-ARFCN_check
    [Tags]      CRT_TRUNK
    Case Preparation
    ${fault_list}    Create List    1900    1807
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Connect to gnb coam via ssl
    Log To Console     Modify nrarfcn to be out of RF supported range(below DL range) to trigger FID1900/1807
    update parameter      parameters_list=${parameters_for_1900_1}
    BuiltIn.sleep     10
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=1
    ...    operationalState=disabled     usageState=idle      proStatus=not initialized
    Log To Console     wait for FID1900 or FID1807 appear
    BuiltIn.sleep     600s
    ${status}    Run Keyword And Return Status    coam_siso_common.Expect Fault Should Present      faultId=1900
    Run Keyword Unless    ${status}    coam_siso_common.Expect Fault Should Present      faultId=1807
    Log To Console     Modify nrarfcn to normal to clear FID1900/1807
    update parameter      parameters_list=${parameters_clear_1900}
    BuiltIn.sleep     10
    coam_siso_common.Expect Fault Should Absent      faultId=1900
    coam_siso_common.Expect Fault Should Absent      faultId=1807
    Wait Until Keyword Succeeds    8min    60s    Check all the Cell status
    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]    Run Keywords    Run Keyword And Ignore error    Case Preparation
    ...   AND    Run Keyword And Ignore error    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_23_nr_REC_Radio_Module_power_reset
    [Tags]      CRT_TRUNK
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Case Preparation
    Connect to gnb coam via ssl
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    power reset RMOD1
    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_24_nr_RU_module_reset_from_GUI_SM_BTS_Site_Reset
    [Tags]      CRT_TRUNK
    Case Preparation
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    Connect to gnb coam via ssl
    Log To Console     reset RU
    reset RU
    Log To Console     reset Site
    reset site
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown

[1]CB009061_classical_37_SISO_SM_KPI51a_RU_reset_downtime_KPI54_power-on_RU_startup_availability
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Case Preparation
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure      TC.reset_RMOD_loop
    ...    repeat_times=${2}
    ...    KPI51A_MAX=${500}
    ...    fail_loop_max=${1}
    Run Keyword And Continue On Failure      TC.power_reset_RMOD_loop
    ...    repeat_times=${2}
    ...    KPI54A_MAX=${500}
    ...    fail_loop_max=${1}

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown

[1]CB009061_classical_38_SISO_SM_KPI17_cell_block_unblock_duration
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    #Case Preparation
    Connect to gnb coam via ssl
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    Run Keyword And Continue On Failure      TC.block_unblock_cell_loop
	...    repeat_times=${50}
    ...    KPI17A_MAX=${50}
    ...    KPI17B_MAX=${50}
    ...    fail_loop_max=${1}

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown

[1]CB009061_classical_39_SISO_SM_KPI5_capacity_module_reset_KPI1a_manual_site_reset_downtime
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    AlarmWatchdog.add_allow_alarms    fault_id=6134
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Case Preparation
    #Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog

    Run Keyword And Continue On Failure      TC.reset_all_BBMOD_loop
    ...    KPI5_MAX=${400}
    ...    repeat_times=${1}
    ...    fail_loop_max=${10}
    ...    reset_type=Warm
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure      TC.reset_site_loop
    ...    repeat_times=${1}
    ...    KPI1a_MAX=${550}
    ...    fail_loop_max=${1}

    #Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    #...      Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.8
    [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown