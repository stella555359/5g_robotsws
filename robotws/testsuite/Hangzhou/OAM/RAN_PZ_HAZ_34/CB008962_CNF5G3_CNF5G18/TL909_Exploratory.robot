*** Settings ***
Documentation    author:Liu Yuanyuan
...              contact: yuanyuan.liu@nokia-sbell.com
Suite Teardown    KW.TestSuilt.Stop
Force Tags        MRT
Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
...       Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
...       do_commission=${True}

Resource    ../CB006443/Resources/All_KW_Interface.robot
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${UTE_syslogs_path}     /home/ute/BTS_logs
${Expect_DOWNLINK}      100
${UE_TYPE}    ${tl.ues[-1].capabilities[1]}
${ue_index}     0
${MRBTS_ID}            MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}            NRBTS-${tl.gnbs[0].global_bts_id}
${REFERENCE_CONFIGURATION_ID}    CNF_5G_3

*** Test Cases ***
[1]ST_OAM_Exploratory_troubleshooting_BBMOD_reset
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    AlarmWatchdog.add_allow_alarms    fault_id=6134
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    Log To Console    \n ### will remove fault16 after PR796727 fixed ###
    AlarmWatchdog.add_allow_alarms    fault_id=16
    Case Preparation
    Run Keyword And Continue On Failure      TC.reset_all_BBMOD_loop
    ...    KPI5_MAX=${400}
    ...    repeat_times=${80}
    ...    fail_loop_max=${10}
    ...    reset_type=Warm
	Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
    #...    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
	#Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #run keyword and continue on failure      UE check throughput
    #UE stop traffic
    #run keyword and continue on failure      Detach UE       ue_index=${ue_index}
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
    [Teardown]    run keyword and ignore error  Teardown case

[1]ST_OAM_Exploratory_troubleshooting_RAT_reset
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    AlarmWatchdog.add_allow_alarms    fault_id=6134
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    Log To Console    \n ### will remove fault16 after PR796727 fixed ###
    AlarmWatchdog.add_allow_alarms    fault_id=16
    Case Preparation
    Run Keyword And Continue On Failure      TC.OAM_KPI_HA_01_OAM_RAT_reset
    ...    WebUI_reset_times=${80}
    ...    KPI10_MAX=${400}
    ...    KPI10_AVG=${400}
    ...    rat_type=NR    reset_typ=Hard
	Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
    #...    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
	#Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #run keyword and continue on failure      UE check throughput
    #UE stop traffic
    #run keyword and continue on failure      Detach UE       ue_index=${ue_index}
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
    [Teardown]    run keyword and ignore error  Teardown case

[1]ST_OAM_Exploratory_troubleshooting_Cell_Block_Unblock
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    Case Preparation
    Run Keyword And Continue On Failure      TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
	...    repeat_times=${200}
    ...    KPI17a=${50}
    ...    KPI17b=${50}
	Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
    #...    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
	#Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #run keyword and continue on failure      UE check throughput
    #UE stop traffic
    #run keyword and continue on failure      Detach UE       ue_index=${ue_index}
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
    [Teardown]    run keyword and ignore error  Teardown case

[1]ST_OAM_Exploratory_troubleshooting_RU_Reset
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    Case Preparation
    Run Keyword And Continue On Failure      TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
    ...    RF_reset_times=${80}
    ...    KPI51_MAX=${400}
    ...    KPI51_AVG=${400}
	Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
    #...    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
	#Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #run keyword and continue on failure      UE check throughput
    #UE stop traffic
    #run keyword and continue on failure      Detach UE       ue_index=${ue_index}
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
    [Teardown]    run keyword and ignore error  Teardown case

[1]ST_OAM_Exploratory_troubleshooting_Site_Reset
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    AlarmWatchdog.add_allow_alarms    fault_id=7513
    Case Preparation
    Run Keyword And Continue On Failure      TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    ...    WebUI_reset_times=${80}
    ...    KPI1a_MAX=${550}
    ...    KPI1a_AVG=${550}
	Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
    #...    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
    #Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #UE check throughput
    #UE stop traffic
    #Detach UE       ue_index=${ue_index}
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
    [Teardown]    run keyword and ignore error  Teardown case

[1]ST_OAM_Exploratory_troubleshooting_ERR_WRN_check
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    Case Preparation
    Connect to gnb coam via ssl
    Log To Console    \n ### reset rat ###
    DU_Rest.reset_rat    rat_type=NR    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    Log To Console    \n ### reset cells ###
	coam.reset_all_cells    NR    timeout=600      connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    Log To Console    \n ### reset sites ###
	coam.reset_site    timeout=360    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
	Log To Console    \n ### reset BBMOD ###
    reset all BBMOD
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
	Log To Console    \n ### reset RMOD ###
    reset all RMOD
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
	Log To Console    \n ### block and unblock cells ###
    block and unblock cells
    Wait Until Keyword Succeeds    5min    20s    Verify all cells should be onair    connection=GNB_OAM
    #Wait until cluster is on cell on air status    list_cell_group_index=0
    #...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    #UE Prepare    ue_index=${ue_index}
    #Attach UE     ue_index=${ue_index}
    #UE start traffic    tp_direction=dl    dl_tp=500M   iperf_port_dl=50228   ue_index=${ue_index}
    #UE check throughput
    #UE stop traffic
    #Detach UE       ue_index=${ue_index}
    COAM Save Snapshot Via Rest Api    log_path=${LOG_PATH}    timeout=600s
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    #[Teardown]    Run Keywords      run keyword and ignore error  Teardown case
	#		   ...    AND     Detach UE       ue_index=${ue_index}
   [Teardown]    run keyword and ignore error  Teardown case


*** Keywords ***
Case Preparation
    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    #COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
	#...    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

UE check throughput
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}

UE Prepare
    Log To Console    \n ### Prepare UE ###
	Run keyword if    '${UE_TYPE}'!='xiaomi'     power_ue.Prepare UE    ue_type=${UE_TYPE}
#	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi

Attach UE
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### UE Attach for UE_${ue_index} ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}    ${dl_tp}    ${iperf_port_dl}      ${ue_index}=${0}
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    ...     iperf_port=${iperf_port_dl}
    sleep    3s

Detach UE
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

UE stop traffic
    log to console    UE stop traffic
    power_ue.Stop traffic      direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    sleep    3s

reset all BBMOD
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get BBMOD distname and id
    FOR    ${BBMOD}    IN    @{BBMOD_id_list}
        ${random_num}=    Evaluate    random.randint(2, 6)    random
        Run Keyword And Ignore error
        ...    DU_Rest.reset_unit
        ...    dist_name=${BBMOD['internal']}    reset_type=Warm
        ...    timeout=${random_num}   connection=${connection}
    END

reset all RMOD
    log to console    reset all RMOD
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get RMOD ID
    FOR    ${RMOD}    IN    @{RMOD_id_list}
        ${random_num}=    Evaluate    random.randint(5, 15)    random
        Run Keyword And Ignore error     DU_Rest.reset_unit
        ...    dist_name=${RMOD['internal']}    timeout= ${random_num}    connection=${connection}
    END

block and unblock cells
	Run Keyword And Ignore error     DU_Rest.block     timeout=600    connection=${connection}
    sleep     60s
    Run Keyword And Ignore error      DU_Rest.unblock     timeout=600    connection=${connection}
