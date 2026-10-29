# *** Settings ***
# Force Tags    PY36
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./Resources/common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         ./Resources/5G000313_modify_para.py
# Library           ute_syslog
# 
# *** Variables ***
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${LOG_PATH}               ${output_dir}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${Test_Case_Name}         5GC000313_01
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${TOP_DN}                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-1/CLOCK_CONF_M-1/TOP_CONF_M-1
# ${gnb_id}                 ${tl.gnbs[0].global_bts_id}
# ${list}                   51000
# 
# 
# *** Test Cases ***
# [1]5GC002236_5GC000313_01_ToP_Phase_Sync_Unicast
#      [Documentation]  ToP Phase Sync Unicast
#      [Tags]      CRT_21B   CRT_22R2
#      [Setup]    Setup Commission SCF
#      COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list1}
#      log to console    setup1_over
#      Capture Wireshark Log And Download     filename=testcase1.pcap    time=8s    listen_port=Ethernet
#      Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase1.pcap    txt_filename=testcase1.txt
#      ...    except_sync_number=128    except_announce_number=2    except_dscp_number=46
#      log to console    setup2_over
#      Enable Test Clock    time=1min
#      Run Keyword And Continue On Failure     Start btslog on ute and Check btslog for 313
#      log to console    setup3_over
#      Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_MessageRate}
#      ...     except_topp_list=${except_topp_list1}     time=3min
#      log to console    setup4_over
#      Capture Wireshark Log And Download     filename=testcase2.pcap    time=8s    listen_port=Ethernet
#      Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase2.pcap    txt_filename=testcase2.txt
#      ...    except_sync_number=64    except_announce_number=2    except_dscp_number=46
#      Capture Wireshark Log And Download     filename=testcase3.pcap    time=5min    listen_port=Ethernet
#      Check Signalling Message In txt    pacp_filename=testcase3.pcap    txt_filename=testcase3.txt
#      log to console    setup5_over
#      Run Keyword And Continue On Failure    Start btslog on ute and Check btslog for 313
#      log to console    setup6_over
#      Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}
#      ...     except_topp_list=${except_topp_list2}     time=5min
#      Check Alarm Number Is Right    alarm_number=4298    except_value=True
#      log to console    setup7_over
#      Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}
#      ...     except_topp_list=${except_topp_list1}    time=5min
#      Check Alarm Number Is Right    alarm_number=4298    except_value=False
#      log to console    setup8_over
#      Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DSCPvalue}
#      ...     except_topp_list=${except_topp_list1}      time=1s
#      Capture Wireshark Log And Download     filename=testcase4.pcap    time=8s    listen_port=Ethernet
#      Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase4.pcap    txt_filename=testcase4.txt
#      ...    except_sync_number=64    except_announce_number=2    except_dscp_number=63
#      [Teardown]    CI_interface.Common Case Teardown
# 
# #[1]5GC002236_5GC000313_03_ToP_Phase_Sync_TOP_Detailed_Info
# #    [Documentation]  ToP Phase Sync TOP Detailed Info
# #    [Tags]    5GC002236_313    CRT_20B
# #    [Setup]   Setup Commission SCF
# #    Run Keyword And Continue On Failure     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}
# #    ...    except_topp_list=${except_topp_list1}
# #    log to console  setp——1
# #    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}    time=4min
# #    ${status}      Run keyword And Return Status     Check BTS TOP Synchronization Detail info On WebUi
# #    ...     expect_detail_list=${GM_expect_list1}    except_topp_list=${except_topp_list2}
# #    Run Keyword And Continue On Failure    Run keyword if   ${status}==${False}      Check BTS TOP Synchronization Detail info On WebUi
# #    ...     expect_detail_list=${GM_expect_list2}    except_topp_list=${except_topp_list2}
# #    log to console  setp——2
# #    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}    time=4min
# #    Run Keyword And Continue On Failure     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}
# #    ...    except_topp_list=${except_topp_list1}
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #[1]5GC002236_5GC000313_05_ToP_Phase_Sync_Unicast_Counters
# #    [Documentation]  ToP Phase Sync Unicast Counters
# #    [Tags]    5GC002236_313    CRT_20B
# #    [Setup]   Setup Commission SCF
# #    Get BTS Counters List via Api    connection=GNB_OAm
# #    Get BTS Counter Change List2    connection=GNB_OAM    except_list=${except_number_list0}
# #    Check BTS Counters Value Scope    flag=0    except_number_list=${except_number_list0}    connection=GNB_OAM
# #    log to console  steup——1
# #    Get BTS Counter Change List    connection=GNB_OAM   PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY_DomainNumber1}   time1=1min
# #    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY_DomainNumber2}    time2=30s
# #    Check BTS Counters Value Scope    flag=1    except_number_list=${except_number_list0}    connection=GNB_OAM
# #    log to console  steup——2
# #    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_PMMNL}    time=1min
# #    Get BTS Counter Change List2    connection=GNB_OAM    except_list=${except_number_list1}
# #    Check BTS Counters Value Scope    flag=0    except_number_list=${except_number_list1}    connection=GNB_OAM
# #    log to console  steup——3
# #    Get BTS Counter Change List    connection=GNB_OAM   PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY_DomainNumber1}   time1=2min
# #    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY_DomainNumber2}    time2=30s
# #    Check BTS Counters Value Scope    flag=1    except_number_list=${except_number_list1}    connection=GNB_OAM
# #    [Teardown]    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Setup Commission SCF
#      ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
#      Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#      COAM Commission with scf file    scf_file_path=${default_scf}
#      Wait Until Keyword Succeeds   16min   2min   Check cell on air
# 
# Convert pcap to text And Get txt Content
#     [Arguments]      ${pacp_filename}    ${txt_filename}     ${except_sync_number}    ${except_announce_number}
#     ...    ${except_dscp_number}
#     ${connection}    common_keyword.Connect to TestPc
#     Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
#     ...  target=${LOG_PATH}/${txt_filename}   filter=" "  connection=${connection}
#     ${sync_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}    message=control: Sync Message (0)
#     ${announce_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=messageId: Announce Message
#     ${dscp_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=DSCP
#     Should Be Equal As Numbers    ${sync_number}    ${except_sync_number}
#     Should Be Equal As Numbers    ${announce_number}     ${except_announce_number}
#     Should Be Equal As Numbers    ${dscp_number}   ${except_dscp_number}
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=${connection}
# 
# Check Signalling Message In txt
#     [Arguments]    ${pacp_filename}  ${txt_filename}
#     ${connection}    common_keyword.Connect to TestPc
#     Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
#     ...  target=${LOG_PATH}/${txt_filename}   filter="ptp.v2.messageid == 0xc"  connection=${connection}
#     ${TextFileContent}    Get File    ${LOG_PATH}/${txt_filename}
#     should not be empty   ${TextFileContent}
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=${connection}
# 
# Start btslog on ute and Check btslog
#     [Arguments]    ${time}
#     Start Syslog    log_dir=${OUTPUT_DIR}
#     ...    log_name=bts_log.log    host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}   ssh_password=${TEST_PC_PASSWORD}
#     ...    ports=${list}    alias=ute
#     sleep    ${time}
#     Stop syslog    alias=ute
#     Check logfile if message is right
# 
# Check logfile if message is right
#     common_keyword.Connect to TestPc
#     ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/bts_log.log    Estimator output
#     ${ppb_result}   check_parameter_ppb_in_btslog_file    input_content=${message}    keyword=frequency_deviation
#     ${ns_result}    check_parameter_ns_in_btslog_file    input_content=${message}
#     should be equal as strings    ${ppb_result}    True
#     should be equal as strings    ${ns_result}    True
#     [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=TESTPC
# 
# Get Active Alarm number
#     [Arguments]    ${keywords}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     ${alarm_list}    coam.get_active_alarms     connection=GNB_OAM
#     ${fault_id_list}  get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
#     Teardown gNB cOAM SSL Connection
#     [Return]  ${fault_id_list}
# 
# Capture Wireshark Log And Download
#     [Arguments]    ${filename}    ${time}    ${listen_port}
#     Connect to control pc via cygwin
#     Start to Capture DU_TOP Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
#     Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}
# 
# Modify parameters And Check TOP Source Info
#     [Arguments]    ${PARAMS_TO_MODIFY}    ${time}    ${except_topp_list}
#     Modify parameters online and Active Plan     PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY}    time=${time}
#     COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
#     [Teardown]  Run keyword and ignore error    selenium_coam.logout
# 
# Check Alarm Number Is Right
#     [Arguments]    ${alarm_number}    ${except_value}
#     ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    check_active_alarms_faultId    faultId_list=${FaultID_list}    faultId=${alarm_number}
#     should be equal as strings    ${return_value}    ${except_value}
# 
# Enable Test Clock
#     [Arguments]   ${time}
#     Du login page via webUI
#     selenium_coam.enable_test_clock_for_rap_and_return_outcome
#     sleep   ${time}
#     [Teardown]  Run keyword and ignore error    selenium_coam.logout
# 
# Check BTS Counters Value Scope
#     [Arguments]    ${flag}    ${except_number_list}    ${connection}
#     ${counter_list}    Get BTS Counters List via Api    connection=${connection}
#     log to console    ${counter_list}
#     ${return_value}    check_value_scope  flag=${flag}  number_list=${counter_list}  except_number_list=${except_number_list}
#     should be equal as strings    ${return_value}    True
# 
# Check BTS TOP Synchronization Detail info On WebUi
#     [Arguments]    ${expect_detail_list}    ${except_topp_list}
#     Run Keyword And Continue On Failure    COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list}
#     ${connection}   coam.Connect To  bts_host=${gNB_ip}  bts_port=443   username=${gNB_username}  password=${gNB_password}
#     ${topmasterlistinfo}   coam.get_parameters    dist_name=${TOP_DN}/TOPP_CONF_M-1/TOPP_R-1    pattern=topMasterList
#     ${topGMasterClockIdentity}    get from dictionary      ${expect_detail_list}     Grandmaster clock ID
#     ${topGMasterClockAccuracy}    get from dictionary      ${expect_detail_list}     Grandmaster clock accuracy
#     ${topGMasterOffsetScaledLogVariance}    get from dictionary      ${expect_detail_list}     Grandmaster offset scaled log variance
#     ${receivedPriority_1}    get from dictionary      ${expect_detail_list}     Grandmaster priority 1
#     ${receivedPriority_2}    get from dictionary      ${expect_detail_list}     Grandmaster priority 2
#     ${topStepsRemoved}    get from dictionary      ${expect_detail_list}     Steps removed
#     ${twoStepFlag}    get from dictionary      ${expect_detail_list}     Two step flag
#     ${topMasterClockIdentity}    get from dictionary      ${expect_detail_list}     Master clock ID
#     ${topMasterPortNumber}    get from dictionary      ${expect_detail_list}     Master port number
#     ${timeTraceable}    get from dictionary      ${expect_detail_list}     Time traceable flag
#     ${ptpTimescale}    get from dictionary      ${expect_detail_list}     PTP time scale
#     ${currentUtcOffsetValid}    get from dictionary      ${expect_detail_list}     UTC offset validity flag
#     ${leap59}    get from dictionary      ${expect_detail_list}     Negative leap second flag
#     ${leap61}    get from dictionary      ${expect_detail_list}     Positive leap second flag
#     should be equal as strings    ${topGMasterClockIdentity}     ${topmasterlistinfo['topMasterList'][0]['topGMasterClockIdentity']}
#     should be equal as strings    ${topGMasterClockAccuracy}      ${topmasterlistinfo['topMasterList'][0]['topGMasterClockAccuracy']}
#     should be equal as strings    ${topGMasterOffsetScaledLogVariance}
#     ...     ${topmasterlistinfo['topMasterList'][0]['topGMasterOffsetScaledLogVariance']}
#     should be equal as strings    ${receivedPriority_1}     ${topmasterlistinfo['topMasterList'][0]['receivedPriority_1']}
#     should be equal as strings    ${receivedPriority_2}      ${topmasterlistinfo['topMasterList'][0]['receivedPriority_2']}
#     should be equal as strings    ${topStepsRemoved}     ${topmasterlistinfo['topMasterList'][0]['topStepsRemoved']}
#     should be equal as strings    ${twoStepFlag}      ${topmasterlistinfo['topMasterList'][0]['twoStepFlag']}
#     should be equal as strings    ${topMasterClockIdentity}     ${topmasterlistinfo['topMasterList'][0]['topMasterClockIdentity']}
#     should be equal as strings    ${topMasterPortNumber}      ${topmasterlistinfo['topMasterList'][0]['topMasterPortNumber']}
#     should be equal as strings    ${timeTraceable}     ${topmasterlistinfo['topMasterList'][0]['timeTraceable']}
#     should be equal as strings    ${ptpTimescale}      ${topmasterlistinfo['topMasterList'][0]['ptpTimescale']}
#     should be equal as strings    ${currentUtcOffsetValid}      ${topmasterlistinfo['topMasterList'][0]['currentUtcOffsetValid']}
#     should be equal as strings    ${leap59}      ${topmasterlistinfo['topMasterList'][0]['leap59']}
#     should be equal as strings    ${leap61}      ${topmasterlistinfo['topMasterList'][0]['leap61']}
#     [Teardown]  Run keyword and ignore error    coam.Teardown  connection=${connection}
