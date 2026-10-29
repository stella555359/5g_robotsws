# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Variables         Resources/5GC006857_modify_para.py
# Library           Resources/5GC006857_AIAE.py
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           ./Resources/common_keyword.py
# *** Variables ***
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${connection}                GNB_OAM
#
# ${throughput}                100M
# ${direction1}                 ul
# ${direction2}                 dl
#
# *** Test Cases ***
# [1]CB006857-AG_006_L3 Call after System Upgrade Classical BTS
#     [Documentation]    L3 Call after System Upgrade Classical BTS
#     [Tags]     CRT_21B
#     [Setup]
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber0}    bts_ip=${DU_OAM_IP_TL}
#     Log and attach
#     [Teardown]    CI_interface.Common Case Teardown
#
# *** Keywords ***
# Get Content From Input Dict
#     [Arguments]    ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
#
# Log and attach
#     log to console    Prepare UE
#     power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${1}
#     log to console    UE Attach
#     power_ue.UE Attach    ue_type=askey_sigspark    ue_index=${1}
#     sleep    5s
#     power_ue.Verify attach    ue_type=askey_sigspark    ue_index=${1}
#     log to console    Verify Attach successful
#     log to console    Start traffic
#     power_ue.Start traffic    ue_type=askey_sigspark
#     ...    direction=${direction1}    throughput=100MKbits/sec    duration=120    ue_index=${1}    ue_mode=NSA
#     power_ue.Start traffic    ue_type=askey_sigspark
#     ...    direction=${direction2}    throughput=100MKbits/sec    duration=120    ue_index=${1}    ue_mode=NSA
#     log to console    Start DL and UL traffic successful,sleep 30s
#     sleep    30s
#     power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction1}    ue_index=${1}    throughput=20
#     power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction2}    ue_index=${1}    throughput=20
#     [Teardown]    Stop traffic and detach
#
# Stop traffic and detach
#     sleep    10s
#     power_ue.Stop traffic    ue_type=askey_sigspark    direction=${direction1}    ue_index=${1}    ue_mode=NSA
#     power_ue.Stop traffic    ue_type=askey_sigspark    direction=${direction2}    ue_index=${1}    ue_mode=NSA
#     power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${1}
#
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${DU_OAM_IP_TL}
#     log to console  Modify parameter
#     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#     FOR    ${item}  IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     log to console    sleep 30s
#     sleep    30s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
