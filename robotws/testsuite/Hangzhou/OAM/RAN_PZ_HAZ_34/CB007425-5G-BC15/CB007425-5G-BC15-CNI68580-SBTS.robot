# *** Settings ***
# Documentation
# ...         author: lixia.tang
# ...         contact: lixia.tang@nokia-sbell.com
# ...         squad group: 5G_PZ_MMW_HZ_3_SG
# ...         CB007425-5G-BC15 test
# 
# Force Tags
# 
# Suite Setup    Suite setup
# Suite Teardown    Suite teardown
# 
# Resource    ../CNI-68580/resources/common_keyword_A.robot
# 
# *** Variables ***
# &{SBTS}    alias=sbts_239    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}  username=Nemuadmin    password=nemuuser    port=443
#     ...    bts_id=239
# ${DCAP_host}    10.57.150.41
# 
# *** Test Cases ***
# [1]CB007425_BC_CNI68580_A_002_trace_can_be_activated_and_deactived_via_Emil_by_using_full_messages_from_4G_and_5G_in_SBTS
#     [Tags]    
#     [Timeout]    15min
#     [Setup]    Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     Create Bts On DCAP    bts_mr_id=${SBTS['bts_id']}    bts=${SBTS}
#     Start DCAP log    bts=${SBTS}
#     Get BTSId
#     Lock cell
#     Unlock cell
# 	Wait until keyword succeeds    15 min    10 sec    COAM Check All Cells Onair    connection=default
# 	Stop DCAP log
#     ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${TS_CASE_LOG_PATH}
#     Get the exact emil log and filter ZMQ/SCTP and convert to txt for SBTS     DCAP_log_path=${downloaded_emil_file_path}
#     Check ZMQ/SCTP message    emil_txt_log=${emil_txt_log}
#     Get the exact emil log and filter SYSCOM and convert to txt for SBTS    DCAP_log_path=${downloaded_emil_file_path}
#     Check SYSCOM message    emil_txt_log=${emil_txt_log}
#    [Teardown]    Case teardown
# 
# *** Keywords ***
# Case teardown
#     log to console    Case teardown
#     Run Keyword and Ignore Error    Dcap delete bts
#     csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
#     log to console    delete txt file
#     csn.Execute   command=sudo rm -rf ${TS_CASE_LOG_PATH}*    connection=ute
#     log to console    delete dcap_tmp
#     csn.Execute   command=sudo rm -rf ${TS_CASE_LOG_PATH}dcap_tmp/*    connection=ute
#     csn.Disconnect     connection=ute
