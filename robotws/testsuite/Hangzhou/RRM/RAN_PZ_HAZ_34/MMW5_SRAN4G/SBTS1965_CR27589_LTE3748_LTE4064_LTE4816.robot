# *** Settings ***
# Documentation     author: Li Xudong
# ...               contact: xudong.1.li@nokia-sbell.com
# ...               squad group: mmW_05
# ...               feature : CR27589_LTE3748_LTE4064_LTE4816
# 
# 
# Library     ute_syslog
# Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
# #Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Globe_Lab_LTE/Resources/Globe_Lab_LTE_Keywords.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup 
# ...    AND     Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${ENB_HOST}
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND     Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# 
# Force Tags        CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
# 
# *** Variables ***
# ${CR27589_scf}         ${CURDIR}/scf/CR27589_20C.xml
# ${LTE3748_scf}         ${CURDIR}/scf/LTE3748_20C.xml
# ${gnb_index}           ${0}
# ${local_syslog_path_CR27589}      /home/ute/log/syslog_CR27589.log
# ${local_syslog_path_LTE3748A}      /home/ute/log/syslog_LTE3748A.log
# ${local_syslog_path_LTE3748_TC06}      /home/ute/log/syslog_LTE3748_TC06.log
# ${local_syslog_path}      /home/ute/log/
# ${MRBTS_ID}    ${tl.enbs[0].instance_id}
# ${LNBTS_ID}    ${tl.enbs[0].global_bts_id}
# ${ENB_HOST}=    ${tl.enbs[0].oam_ip.v4}
# 
# ${LTE4064_couter_path}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Radio_Bearer
# ${LTE4816_couter_path}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Resource
# ${LTE3748_couter_path1}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Resource
# ${LTE3748_couter_path2}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_UE_Quantity
# 
# ${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
# 
# *** Test Cases ***
# [1.0] CR27589_Parameter_ifLBRetryTimer_range_extension_Test_Case_1
#     [Tags]    CR27589
#     [Documentation]    [1][1.0] CR27589_Parameter_ifLBRetryTimer_range_extension_Test_Case_1
#     Log    \nsubmit CB27589 SCF\n   console=yes
#     Globe Commission With Scf File    gnb_index=${gnb_index}    scf_file_path=${CR27589_scf}
#     Log    \n start syslog \n   console=yes
#     ute_syslog.start_syslog    ${local_syslog_path}    syslog_CR27589.log    ip=192.168.255.126
#     ...   ssh_password=${ute_password}     virtualenv_dir=/home/ute/CIENV/7_5_UTE4G402T1965    alias=default
#     Step1: Ue Attached UE
#     sleep    10s
#     Log    \n stop syslog \n   console=yes
#     ute_syslog.collect_syslog_results    destination=${local_syslog_path}    alias=default
#     ${ret}    Grep File    ${local_syslog_path_CR27589}    MobilityTriggerTimer started, time= 3500 ms
#     ...    encoding_errors=ignore
#     Should Not Be Empty    ${ret}
#     Log    \nRecove SCF\n   console=yes
#     Globe Commission With Scf File    gnb_index=${gnb_index}    scf_file_path=${LTE3748_scf}
# ######################Optimazation FB2219###############################
# #[1.0] LTE3748-A-a_TC01 configure UL CA for normal cal
# #    [Tags]    CDRT_TRUNK    TC01
# #    [Documentation]    configure UL CA for normal call
# #    ...
# #    ...    Pre-condition:
# #    ...
# #    ...    1. UL CA is enabled (LNBTS/actULCAggr = True)
# #    ...
# #    ...    2. eVTT is disabled in all serving cells with the PCell ( roleLNBTS/LNCEL/actQci1eVTT = False)
# #    ...
# #    ...    3. LTE3748 is enabled (LNBTS/actUlInDevCoexGNSS = True)
# #    ...
# #    ...    4. IMS Emergency Sessions is enabled in the eNB (LNBTS/actIMSEmerSessR9 = True)
# #    ...
# #    ...    5. PCell(Cell0) has one candidate SCell(Cell1)
# #    ...
# #    ...    6. UE with DL/UL 2CC CA supported
# #    ...
# #    ...    7. system is reach on air
# #    ...
# #    ...    8. UE attach with default bearer
# #    ...
# #    ...    Description:
# #    ...
# #    ...    1. Adding of SCell is triggered and Cell1 is selected as SCell with DL&UL CA for the UE
# #    ...
# #    ...    2. eNodeB configures SCell for both DL&UL CA
# #    ...
# #    ...    Post-condition:
# #    ...
# #    ...    1. The UE is configured with DL&UL CA
# #    Log    \n start syslog \n   console=yes
# #    ute_syslog.start_syslog    ${local_syslog_path}    syslog_LTE3748A.log    ip=192.168.255.126
# #    ...   ssh_password=iW_K#8.ute%A10h0m0ra     alias=default
# #    Step1: Ue Attached UE
# #    sleep    10s
# #    UE Start UL Traffic    throughput=60M    ue_index=0    ul_time=60    ul_port=45001
# #    Sleep 	  60s
# #    UE UE Detach
# #    Log    \n stop syslog \n   console=yes
# #    ute_syslog.collect_syslog_results    destination=${local_syslog_path}    alias=default
# #    Log    \n check counter \n   console=yes
# #    Check LTE3748-A PM counter
# #    Log    \n check syslog \n   console=yes
# #    ${ret}    Grep File    ${local_syslog_path_LTE3748A}    Processing Scell ID: 1235458
# #    Should Not Be Empty    ${ret}
# #
# #
# #[1.0] LTE3748-A-b_TC04 emergency bearer setup for the call with UL CA
# #    [Documentation]    emergency bearer setup for the call with UL CA
# #    ...
# #    ...    Pre-condition:
# #    ...
# #    ...    1. LNBTS/actULCAggr = True
# #    ...
# #    ...    2. roleLNBTS/LNCEL/actQci1eVTT = False
# #    ...
# #    ...    3. LNBTS/actUlInDevCoexGNSS = True
# #    ...
# #    ...    4. LNBTS/actIMSEmerSessR9 = True
# #    ...
# #    ...    5. Check and set “emerSessArpPrioLev” properly during test
# #    ...
# #    ...    6. PCell(Cell0) has one candidate SCell(Cell1)
# #    ...
# #    ...    7. UE with DL/UL 2CC CA supported
# #    ...
# #    ...    8. system is reach on air
# #    ...
# #    ...    9. UE attach with default bearer and configure UL&DL CA \ \ \ \ Description:
# #    ...
# #    ...    1. eNodeB creates an IMS emergency bearer for the UE
# #    ...
# #    ...    2. eNodeB configures resource for the emergency bearer
# #    ...
# #    ...    3. At the end of RB setup, UL scheduling on the SCell is suspended for the UE.
# #    ...
# #    ...    Post-condition:
# #    ...
# #    ...    1. The UE is only scheduled on the PCell for UL traffic
# #    [Tags]    CDRT_TRUNK    TC04   
# #    Log    \n start syslog \n   console=yes
# #    ute_syslog.start_syslog    ${local_syslog_path}    syslog_LTE3748_TC06.log    ip=192.168.255.126
# #    ...   ssh_password=iW_K#8.ute%A10h0m0ra     alias=default
# #    Step1: Ue Attached UE
# #    Sleep    20s
# #    UE Start UL Traffic   throughput=50M    ue_index=0    ul_time=30    ul_port=45001
# #    UE Start DL Traffic   throughput=50M    ue_index=0    dl_time=30    dl_port=45001
# #    Sleep 	  10s
# #    Log  \nStart Voice Call  console=yes
# #    UE Make VoNR Call bk   ue_index=0    phone_number=911
# #    Log  \nStop Voice Call  console=yes
# #    UE Hang Up VoNR Call bk    ue_index=0
# #    Log  \nCheck LTE3748  console=yes
# #    Check LTE3748-A-a1.3
# #    Log    \n stop syslog \n   console=yes
# #    ute_syslog.collect_syslog_results    destination=${local_syslog_path}    alias=default
# #    #Log    \n   Check_Emergencycall   \n  console=yes
# #    ${ret1}    Grep File    ${local_syslog_path_LTE3748_TC06}    EMEBearerSetup
# #    Should Not Be Empty    ${ret1}
# #    #Log    \n  Check_UL_SCELL_Suspend   \n  console=yes
# #    ${ret2}    Grep File    ${local_syslog_path_LTE3748_TC06}    UEC_CA_IDC_UL_SCHEDULING_IND
# #    Should Not Be Empty    ${ret2}
# #    ${ret3}    Grep File    ${local_syslog_path_LTE3748_TC06}    UEC_IN_DEVICE_COEXIST@SuspendByEME
# #    Should Not Be Empty    ${ret3}
# 
# 
# [2.0] LTE4064_counter_UPGRADE_256QAM_ATT
#     [Tags]    CDRT_TRUNK
#     [Documentation]
#     Step1: Ue Attached UE
#     Modify Parameter On BTS LTE4064_2
#     Step2: Start DL UDP-traffic UE
#     Step3: LTE4604 Check PM counter
# 
# [2.0] LTE4064_Feature_Activation_Deactivation
#     [Tags]   CDRT_TRUNK
#     [Documentation]
#     Step1: Ue Attached UE
#     Modify Parameter On BTS LTE4064_2
#     Step2: Start DL UDP-traffic UE
#     Step3: LTE4604 Check PM counter
# 
# [2.0] LTE4816_TC01_M8068 counters update in normal intra-eNB FDD CA scenario
#     [Tags]   CDRT_TRUNK    LTE4816
#     [Documentation]
#     Modify Parameter On BTS LTE4816
#     Sleep    60s
#     Step1: Ue Attached UE
#     Log  \nStart DL data transfer  console=yes
#     UE Start DL Traffic   throughput=500M    ue_index=0    dl_time=20    dl_port=45001
#     Log  \nStart UL data transfer  console=yes
#     UE Start UL Traffic   throughput=50M    ue_index=0    ul_time=20    ul_port=45001
#     sleep    30s
#     Step2: LTE4816 Check PM counter
#     UE Detach
#     Sleep    300s
#     check counter twice
#     Log  \nRestore Parameters\n  console=yes
# 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}
# 	...    parameter=actUlInDevCoexGNSS
# 	...    value=true
# 	...    connection=GNB_OAM
# 
# *** Keywords ***
# UE Make VoNR Call bk
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
#     ...    ${connection}=cygwin
#     ${ue_type}    translate power ue type from testline    ${ue_index}
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     Sleep    5s
# #    #####Press the Home button to open the screen#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
# #    ...    connection=${connection}
# #    Sleep    2s
# #    #####Swipe up to unlock the phone#####
# #    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
# #    ...    connection=${connection}
# #    Sleep    2s
#     #####Make VoNR Call#####
#     csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
#     ...    connection=${connection}
#     Sleep    2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb shell input tap 1000 3400
#     ...    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}
# 
# UE Hang Up VoNR Call bk
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${ue_index}=0    ${connection}=cygwin
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     Sleep    30s
#     #####Hang Up VoNR Call#####
#     csn.send_command    command=adb shell input tap 1000 3400    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}
# 
# UE UE Detach
#     [Arguments]    ${ue_index}=0
#     ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
#     power_ue.UE Detach    ${ue_type}    ${ue_index}
# 
# Check LTE3748-A-a1.3
#     Get PM counter_LTE3748-A-a1.3
#     Run keyword if    ${countervalue_M8005C364} == 0    Get PM counter_LTE3748-A-a1.3 again
#     should be true      ${countervalue_M8005C364} > 0
# 
# Get PM counter_LTE3748-A-a1.3
#     BuiltIn.Log    \n Get PM counter \n    console=yes
#     ${countervalue_M8005C364}    get PM counter latest value    counter_id=M8005C364
#     ...    couter_path=BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Pwr_and_Qual_UL
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_M8005C364}
# 
# Get PM counter_LTE3748-A-a1.3 again
#     sleep  300s
#     Get PM counter_LTE3748-A-a1.3
# 
# get PM counter latest value
#     [Documentation]    get PM counter latest value
#     [Arguments]    ${counter_id}    ${couter_path}    ${connection}
#     BuiltIn.Log    \n get PM counter latest value \n    console=yes
#     ${pm_list}    get_pm_counter_values    counter_id=${counter_id}
#     ...    dic_path=${couter_path}
#     ...    connection=${connection}
#     BuiltIn.Log    \n pm_list is ${pm_list} \n    console=yes
#     ${countervalue}    Set Variable    ${pm_list[0]}
# #    BuiltIn.set_test_variable    ${countervalue}
#     BuiltIn.Log    \n pm_value is ${countervalue} \n    console=yes
#     [Return]    ${countervalue}
# 
# Globe Commission With Scf File
#     [Arguments]    ${gnb_index}    ${scf_file_path}
#     Connect to gnb coam via ssl    gnb_index=${gnb_index}
#     COAM Commission with scf file    scf_file_path=${scf_file_path}    is_pdl_checking_needed=False
#     Wait Until Keyword Succeeds    10min    30s    COAM Check GNB cell on air
#     [Teardown]    COAM Teardown gnb connections
# 
# UE Detach
#     [Arguments]    ${ue_index}=0
#     ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
#     power_ue.UE Detach    ${ue_type}    ${ue_index}
# 
# Reset UE
#     [Arguments]     ${ue_index}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
#     csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
#     sleep     60s
#     csn.disconnect     connection=cygwin
# 
# Step1: Ue Attached UE
#     BuiltIn.Log    \n Step1: Ue attached UE \n    console=yes
#     UE Attach And Verify 4G bk    ue_index=0
# 
# Recover the test ENV
#     COAM Teardown gnb connections
# 
# Modify Parameter On BTS LTE4064_2
#     Log    \nModify parameter\n   console=yes
#     Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-1
# 	...    parameter=actModulationSchemeDl
# 	...    value=256QAM
# 	...    connection=GNB_OAM
# 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-1
# 	...    parameter=actDl256QamChQualEst
# 	...    value=true
# 	...    connection=GNB_OAM
# 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-1
# 	...    parameter=iniDl256QamChQualEst
# 	...    value=1s
# 	...    connection=GNB_OAM
# 
# Step2: Start DL UDP-traffic UE
#     BuiltIn.Log    \n Step2: Start UDP-traffic UE \n    console=yes
#     UE Start DL Traffic   throughput=20M    ue_index=0    dl_time=20    dl_port=45001
#     Sleep    25s
#     UE Start DL Traffic   throughput=20M    ue_index=0    dl_time=20    dl_port=45001
#     Sleep    25s
#     UE Start DL Traffic   throughput=20M    ue_index=0    dl_time=10    dl_port=45001
#     Sleep    35s
# 
# Step3: LTE4604 Check PM counter
#     Get PM counter    couter_path=${LTE4064_couter_path}    counter_id=M8007C22
#     Run keyword if    ${countervalue} == 0    Get PM Counter Again
#     ...    couter_path=${LTE4064_couter_path}    counter_id=M8007C22
#     should be true      ${countervalue} >= 1
# 
# Get PM counter
#     [Arguments]    ${couter_path}    ${counter_id}
#     BuiltIn.Log    \n Get PM counter \n    console=yes
#     ${countervalue}    get PM counter latest value    counter_id=${counter_id}
#     ...    couter_path=${couter_path}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue}
# 
# Get PM Counter Again
#     [Arguments]    ${couter_path}    ${counter_id}
#     Sleep    300s
#     Get PM counter    couter_path=${couter_path}    counter_id=${counter_id}
# 
# Modify Parameter On BTS LTE4816
#     Log    \nModify parameter\n   console=yes
#     Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-1
# 	...    parameter=actCarelCounters
# 	...    value=true
# 	...    connection=GNB_OAM
# 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1
# 	...    parameter=mtCarel
# 	...    value=15min
# 	...    connection=GNB_OAM
# 	Modify Parameter On BTS With Activate       dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}
# 	...    parameter=actUlInDevCoexGNSS
# 	...    value=false
# 	...    connection=GNB_OAM
# 
# Step2: LTE4816 Check PM counter
#     Get LTE4816 PM counter    couter_path=${LTE4816_couter_path}
#     Run keyword if    ${countervalue_M8011C346} == 0    Get LTE4816 PM Counter Again
#     check counter once
# 
# check counter once
#     Should be True      ${countervalue_M8011C346} > 0
#     Should be True      ${countervalue_M8011C347} > 0
#     Should be True      ${countervalue_M8011C348} == 0
#     Should be True      ${countervalue_M8011C349} == 0
# 
# check counter twice
#     Get LTE4816 PM counter    couter_path=${LTE4816_couter_path}
#     Should be True      ${countervalue_M8011C346} == 0
#     Should be True      ${countervalue_M8011C347} == 0
#     Should be True      ${countervalue_M8011C348} == 0
#     Should be True      ${countervalue_M8011C349} == 0
# 
# 
# Get LTE4816 PM Counter Again
#     Sleep    300s
#     Get LTE4816 PM counter    couter_path=${LTE4816_couter_path}
# 
# Get LTE4816 PM counter
#     [Arguments]    ${couter_path}
#     BuiltIn.Log    \n Get PM counter \n    console=yes
#     ${countervalue_M8011C346}    get PM counter latest value    counter_id=M8011C346
#     ...    couter_path=${LTE4816_couter_path}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_M8011C346}
#     ${countervalue_M8011C347}    get PM counter latest value    counter_id=M8011C347
#     ...    couter_path=${LTE4816_couter_path}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_M8011C347}
#     ${countervalue_M8011C348}    get PM counter latest value    counter_id=M8011C348
#     ...    couter_path=${LTE4816_couter_path}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_M8011C348}
#     ${countervalue_M8011C349}    get PM counter latest value    counter_id=M8011C349
#     ...    couter_path=${LTE4816_couter_path}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_M8011C349}
# 
# UE Attach And Verify 4G bk
#     [Arguments]    ${ue_index}=0
#     ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
#     power_ue.Prepare UE    ${ue_type}    ${ue_index}
#     ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
#     run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
# #    ${attach_output}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
#     Connect to control pc enhanced    ${ue_index}
#     csn.send command    command=adb -s ${tl.ues[${ue_index}].serial_number} shell getprop gsm.network.type
#     ...    connection=cpc_${ue_index}    timeout=15
#     Wait Until Keyword Succeeds    1min    10s    Verify 4G Attach by ADB Command    ${ue_index}
#     [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}
# 
# Check LTE3748-A PM counter
#     Get two PM Counter    couter_path1=${LTE3748_couter_path1}    counter_id1=M8011C172
#     ...    couter_path2=${LTE3748_couter_path2}    counter_id2=M8051C118
#     Run keyword if    '${countervalue_1}'=='0' or '${countervalue_2}'=='0'   Get two PM Counter Again
#     ...    couter_path1=${LTE3748_couter_path1}    counter_id1=M8011C172
#     ...    couter_path2=${LTE3748_couter_path2}    counter_id2=M8051C118
#     should be true      ${countervalue_1} > 0
#     should be true      ${countervalue_2} > 0
# 
# Get two PM counter
#     [Arguments]    ${couter_path1}     ${couter_path2}    ${counter_id1}    ${counter_id2}
#     BuiltIn.Log    \n Get PM counter \n    console=yes
#     ${countervalue_1}    get PM counter latest value    counter_id=${counter_id1}
#     ...    couter_path=${couter_path1}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_1}
#     ${countervalue_2}    get PM counter latest value    counter_id=${counter_id2}
#     ...    couter_path=${couter_path2}
#     ...    connection=GNB_OAM
#     Set Test Variable    ${countervalue_2}
# 
# Get two PM Counter Again
#     [Arguments]    ${couter_path1}    ${counter_id1}     ${couter_path2}    ${counter_id2}
#     Sleep    300s
#     Get two PM counter    couter_path1=${couter_path1}    couter_path2=${couter_path2}
#     ...    counter_id1=${counter_id1}    counter_id2=${counter_id2}
