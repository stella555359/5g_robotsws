# # 
# # *** Settings ***
# # Documentation   author: Jing Chen
# # 
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
# # Resource    ../Resources/5GC002324_Variables.robot
# # Library     ../Resources/check_msg.py
# # 
# # Force Tags     5G_OAM
# # ...    PY36
# # 
# # 
# # Suite Setup     Case Suite Setup
# # 
# # Suite Teardown  run keyword and ignore error    Common suite recovery
# # 
# # 
# # *** Variables ***
# # ${zmq_session}      d=DataCollector\@${trace_host}:9999 m=[f5c:@ext/config/5gfilter.txt][su:GIVAXI-0][gnb:gNB5G]
# # ${syscom_session}   d=DataCollector\@${trace_host}:9999 m=[f5s:@ext/config/TraceFilter.txt][sh:CPUE20,CPRT00,CPNRT00,C
# ...PNB00,CPIF00,CPCL00][gnb:gNB5
# # G]
# # ${emil_host}        10.101.47.109
# # ${trace_host}       10.57.167.47
# # ${emil_user}        nokia5G
# # ${emil_password}    noki@123
# # ${trace_user}       dcapuser
# # ${trace_password}   dcapuser123
# # ${emil_protocol}    5G
# # 
# # *** Test Cases ***
# # [1]5GC002324-MA_MA 5GC001808_001_ F1 interface message tracing from CPRT
# #     [Tags]    CRT_20B    CRT_TRUNK    CRT_21B    CRT_22R2
# #     [Documentation]    author: chen.1.jing@nokia-sbell.com
# #     ...    The purpose of the UC is to check if F1 messages could be captured by DCAP
# #     [Timeout]    60min
# #     [Setup]   Flowtracer Trace Setup Preparation    session_param1=${zmq_session}    session_flag=zmq
# #     check_emil_msg    msg_file=${CURDIR}/../Resources/f1_msg.txt    emil_file=${txt_file}
# #     [Teardown]    run keyword and ignore error    Flowtracer Trace Teardown
# # 
# # [1]5GC002324-MA_MB_5GC001808_004_CPRT module Syscom messages can be activated and deactivated via Emil for gNB_DU
# #     [Tags]    CRT_20B    CRT_TRUNK    CRT_21B    CRT_22R2
# #     [Documentation]    author: chen.1.jing@nokia-sbell.com
# #     ...    The purpose of the UC is to check if messages between CPRF and L1/L2/OAM could be captured by DCAP
# #     [Timeout]    60min
# #     [Setup]   Flowtracer Trace Setup Preparation    session_param1=${syscom_session}    session_flag=syscom
# #     check_emil_msg    msg_file=${CURDIR}/../Resources/cprt_msg.txt    emil_file=${txt_file}
# #     [Teardown]    run keyword and ignore error    Flowtracer Trace Teardown
# # 
# # *** Keywords ***
# # Case Suite Setup
# #     [Documentation]    author: Jing Chen
# #     ${SCF_DEFAULT_FILE_PATH_CU}    Get SCF template path for CU
# #     Set suite variable    ${SCF_DEFAULT_FILE_PATH_CU}
# #     Common suite setup preparation    cu_scf_parameters_list=${None}
# #     ...    cu_scf_template_path=${SCF_DEFAULT_FILE_PATH_CU}    cu_timeout=8min
# # 
# # Flowtracer Trace Setup Preparation
# #     [Arguments]    ${session_param1}   ${session_flag}
# #     Common case setup
# #     log to console   \n Flowtracer Trace Setup
# #     run keyword and ignore error    wait until keyword succeeds  3x   20s  Stop Flowtracer
# #     ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     Remove Emil logs on DCAP
# #     ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     Start Flowtracer    session_param1=${session_param1}
# #     ...    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     Start tcpdump log on CU
# #     sleep    10s
# #     Perform Cloud DU reboot
# #     COAM GNB Wait CU and DU cells are on air status    timeout=12 min
# #     Stop Flowtracer    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     ${file_list}   Download FlowTracer logs to local    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     ...    local_dir=${TS_CASE_LOG_PATH}
# #     Upload file to remote host    emil_host=${emil_host}    emil_user=${emil_user}    emil_password=${emil_password}
# #     ...    local_filepath=${CURDIR}/../Resources/${session_flag}_SourceProfileUser.ini
# #     ...    remote_filepath=${emil_path}/profiles/${emil_protocol}/SourceProfileUser.ini
# #     ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${TS_CASE_LOG_PATH}
# #     ...    emil_host=${emil_host}    emil_user=${emil_user}    emil_password=${emil_password}    emil_protocol=${emil_protocol}
# #     set test variable    ${txt_file}
# # 
# # Flowtracer Trace Teardown
# #     log to console   \n Flowtracer Trace Teardown
# #     Stop Flowtracer    trace_host=${trace_host}   trace_user=${trace_user}   trace_password=${trace_password}
# #     Stop tcpdump log collection
# #     Common case teardown
