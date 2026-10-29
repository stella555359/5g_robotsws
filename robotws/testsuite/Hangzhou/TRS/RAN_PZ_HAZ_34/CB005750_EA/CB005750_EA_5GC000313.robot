# *** Settings ***
# Force Tags    PY36
# Suite Setup        Run keywords    Setup Commission SCF    AND    robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./Resources/common_keyword.robot
# Library           ./Resources/5G000313_common_keywords.py
# Library           ute_syslog
# Variables         ./Resources/5G000313_modify_para.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variables ***
# ${LOG_PATH}               ${output_dir}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${Test_Case_Name}         5GC000313_01
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${gnb_id}                 ${tl.gnbs[0].global_bts_id}
# ${list}                   51000
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAE_5GC000313_01_ToP_Phase_Sync_Unicast
#      [Documentation]  ToP Phase Sync Unicast
#      [Tags]    CRT_TRUNK     CRT_22R4   CRT_22R2
#      Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#      COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list1}
#      log to console    setup1_over
#      Capture Wireshark Log And Download     filename=testcase1.pcap    time=6s    listen_port=NOKLAB
#      Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase1.pcap    txt_filename=testcase1.txt
#      ...    except_sync_number=128    except_announce_number=2    except_dscp_number=46
#      log to console    setup2_over
#      Enable Test Clock    time=1min
#      Run Keyword And Continue On Failure     Start btslog on ute and Check btslog for 313
#      log to console    setup3_over
#      Modify parameters via Coam And Check Top Source Info    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_MessageRate}
#      ...    except_topp_list=${except_topp_list1}
#      log to console    setup4_over
#      Capture Wireshark Log And Download     filename=testcase2.pcap    time=6s    listen_port=NOKLAB
#      Run Keyword And Continue On Failure     Convert pcap to text And Get txt Content   pacp_filename=testcase2.pcap    txt_filename=testcase2.txt
#      ...    except_sync_number=64    except_announce_number=2    except_dscp_number=46
#      Capture Wireshark Log And Download     filename=testcase3.pcap    time=5min    listen_port=NOKLAB
#      Check Signalling Message In txt    pacp_filename=testcase3.pcap    txt_filename=testcase3.txt
#      log to console    setup5_over
#      Run Keyword And Continue On Failure     Start btslog on ute and Check btslog for 313
#      log to console    setup6_over
#      Modify parameters via Coam And Check Top Source Info    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}
#      ...    except_topp_list=${except_topp_list2}
#      Check Alarm Number Is Right    alarm_number=4298    except_value=True
#      log to console    setup7_over
#      Modify parameters via Coam And Check Top Source Info    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}
#      ...    except_topp_list=${except_topp_list1}
#      Check Alarm Number Is Right    alarm_number=4298    except_value=False
#      log to console    setup8_over
#      Modify parameters via Coam And Check Top Source Info    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DSCPvalue}
#      ...    except_topp_list=${except_topp_list1}
#      Capture Wireshark Log And Download     filename=testcase4.pcap    time=6s    listen_port=NOKLAB
#      Convert pcap to text And Get txt Content   pacp_filename=testcase4.pcap    txt_filename=testcase4.txt
#      ...    except_sync_number=64    except_announce_number=2    except_dscp_number=63
#      [Teardown]    Clear Log And Dir
# 
# [1]CB005750-5G-EAAE_5GC000313_03_ToP_Phase_Sync_TOP_Detailed_Info
#     [Documentation]  ToP Phase Sync TOP Detailed Info
#     [Tags]       CRT_TRUNK       CRT_22R2
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}    except_topp_list=${except_topp_list1}
#     log to console  setp——1
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber1}    connection=GNB_connection
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list1}    except_topp_list=${except_topp_list2}
#     log to console  setp——2
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}    connection=GNB_connection
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}    except_topp_list=${except_topp_list1}
#     [Teardown]    Clear Log And Dir
# 
# #[1]CB005750-5G-EAAE_5GC000313_05_ToP_Phase_Sync_Unicast_Counters
# #    [Documentation]  ToP Phase Sync Unicast Counters
# #    [Tags]    CB005750-5G-EAAE_5GC000313    CRT_21A
# #    Get BTS Counters List via Api    connection=GNB_OAm
# #    Get BTS Counter Change List2    connection=GNB_OAM    except_list=${except_number_list0}
# #    Check BTS Counters Value Scope    flag=0    except_number_list=${except_number_list0}    connection=GNB_OAM
# #    log to console  steup——1
# #    Get BTS Counter Change List    connection=GNB_OAM   PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY_DomainNumber1}   time1=1min
# #    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY_DomainNumber2}    time2=30s
# #    Check BTS Counters Value Scope    flag=1    except_number_list=${except_number_list0}    connection=GNB_OAM
# #    log to console  steup——2
# #    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_PMMNL}    connection=GNB_connection
# #    Get BTS Counter Change List2    connection=GNB_OAM    except_list=${except_number_list1}
# #    Check BTS Counters Value Scope    flag=0    except_number_list=${except_number_list1}    connection=GNB_OAM
# #    log to console  steup——3
# #    Get BTS Counter Change List    connection=GNB_OAM   PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY_DomainNumber1}   time1=2min
# #    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY_DomainNumber2}    time2=30s
# #    Check BTS Counters Value Scope    flag=1    except_number_list=${except_number_list1}    connection=GNB_OAM
# #    [Teardown]    Clear Log And Dir
# 
# 
# *** Keywords ***
# Convert pcap to text And Get txt Content
#     [Arguments]      ${pacp_filename}  ${txt_filename}    ${except_sync_number}    ${except_announce_number}    ${except_dscp_number}
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
# Capture Wireshark Log And Download
#     [Arguments]    ${filename}    ${time}    ${listen_port}
#     Connect to control pc via cygwin
#     Start to Capture DU_TOP Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
#     Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}
# 
# Modify parameters via Coam And Check Top Source Info
#     [Arguments]  ${PARAMS_TO_MODIFY}    ${except_topp_list}    ${connection}=GNB_connection
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY}    connection=${connection}
#     Sleep    5min
#     COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
# 
# Check Alarm Number Is Right
#     [Arguments]    ${alarm_number}    ${except_value}
#     ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
#     ${return_value}    check_active_alarms_faultId    faultId_list=${FaultID_list}    faultId=${alarm_number}
#     should be equal as strings    ${return_value}    ${except_value}
# 
# Enable Test Clock
#     [Arguments]   ${time}
#     Du login page via webUI for 313
#     selenium_coam.enable_test_clock_for_rap_and_return_outcome
#     sleep   ${time}
#     [Teardown]  Run keyword and ignore error    selenium_coam.logout
# 
# Du login page via webUI for 313
#     [Arguments]  ${download_dir}=/home/ute
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     ...                    download_dir=${download_dir}
#     selenium_coam.disable_message_box
# 
# Check BTS Counters Value Scope
#     [Arguments]    ${flag}    ${except_number_list}    ${connection}
#     ${counter_list}    Get BTS Counters List via Api    connection=${connection}
#     log to console    ${counter_list}
#     ${return_value}    check_value_scope  flag=${flag}  number_list=${counter_list}  except_number_list=${except_number_list}
#     should be equal as strings    ${return_value}    True
# 
# Check BTS TOP Synchronization Detail info On WebUi
#     [Arguments]    ${expect_detail_list}    ${except_topp_list}    ${connection}=GNB_OAM
#     COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
#     ${get_managed_objects}     coam.get_managed_objects     class_name=TOPP_R    connection=${connection}
#     ${dist_name}    Get_Dist_Name    input_list=${get_managed_objects}
#     ${topmasterlistinfo}   coam.get_parameters    dist_name=${dist_name}   pattern=topMasterList    connection=${connection}
#     log to console  ${topmasterlistinfo}
#     ${Webui_detail_list}    Create List
#     Append To List    ${Webui_detail_list}   ${topmasterlistinfo['topMasterList'][0]['receivedPriority_2']}
#     Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockClass']}
#     Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockAccuracy']}
#     Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockIdentity']}
#     ${len}    get length    ${Webui_detail_list}
#     FOR    ${i}    IN RANGE    ${len}
#          should be equal as strings    @{expect_detail_list}[${i}]    @{Webui_detail_list}[${i}]
#     END
#     [Teardown]  Run keyword and ignore error    coam.Teardown  connection=${connection}
# 
