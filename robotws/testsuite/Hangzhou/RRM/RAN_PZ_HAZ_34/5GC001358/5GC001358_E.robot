# *** Settings ***
# Documentation
# ...    author: tluo
# ...    contact: tina.luo@nokia-sbell.com
# ...    squad group: RAN_PZ_MMW_CN_2_SG03
# ...    Feature :  5GC001358
# 
# Resource    ./Resources/5GC001358_DA_common_keywords.robot
# Resource    ./Resources/5GC001358_common_keyword.robot
# Variables    ./Resources/5GC001358_variables.py
# 
# Suite Setup    Run Keywords    Adapt SCF Name By Release    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# 
# Force Tags      CRT_TRUNK
# ...    PY36
# 
# *** Variables ***
# ${if_commissioning}   False
# ${tp_direction}    both
# ${ul_tp}     70M
# ${dl_tp}     1500M
# ${ul_tp_Stability}     30M
# ${dl_tp_Stability}     300M
# ${UE_TYPE}    qct_dx50
# ${seg_size}    1300
# ${dltp_expected}   1300
# ${ultp_expected}   55
# ${dltp_expected_Stability}   280
# ${ultp_expected_Stability}   25
# ${process_num}    5
# ${protocol}  udp
# ${deviation}    1%
# ${total_times}  6
# ${time}   80000
# *** Test Cases ***
# [1]5GC001358_E_01_CNI-58218_DL_data_traffic_is_normal_With_new_IQ_Data_Format_and_Scaling_for_NSA
#     [Documentation]
#     ...     the purpose of the test case is verify gNB with new IQ data format and scaling,
#     ...     the data traffic peak throughput and RSRP is in same level compare with old IQ data format and scaling be used,
#     ...     and also make sure data traffic is stable and no unexpected error happen.
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
#     Check ReferenceLevel and gainCorrection in RU SOAP log
#     Prepare UE for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic according to direction and protocol   data_send_dl=${dl_tp}    data_send_ul=${ul_tp}    tp_direction=${tp_direction}
#     AAsys log captrue    sleep_time=15s
#     Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
#     ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
#     Stop traffic according to direction and protocol   tp_direction=${tp_direction}
#     [Teardown]    Run Keywords      UE Detach for ${ue_type}  AND    CI_interface.Common Case Teardown
#     ...       AND   robot_common_operations.Common Case Teardown
# 
# [1]5GC001358_E_03_CNI-55626_Stability_Test
#     [Documentation]
#     ...     the purpose of the test case is verify gNB with new IQ data format and scaling,
#     ...     the data traffic peak throughput and RSRP is in same level compare with old IQ data format and scaling be used,
#     ...     and also make sure data traffic is stable and no unexpected error happen.
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
#     Prepare UE for ${ue_type}
#     UE Attach for ${ue_type}
#     log to console    /n****check PEAK TPUT Stability****
#     Start traffic according to direction and protocol   data_send_dl=${dl_tp}    data_send_ul=${ul_tp}    tp_direction=${tp_direction}
#     sleep    20m
#     AAsys log captrue    sleep_time=15s
#     Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
#     ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
#     Stop traffic according to direction and protocol   tp_direction=${tp_direction}
#     log to console    /n****check DL UL Stability****
#     Start traffic according to direction and protocol for Stability
#     ...     data_send_dl=${dl_tp_Stability}   duration_time=${time}    data_send_ul=${ul_tp_Stability}    tp_direction=${tp_direction}
#     FOR    ${num}    IN RANGE    ${total_times}
#         log to console    check for ${num}*20min
#         sleep    20m
#         AAsys log captrue    sleep_time=15s
#         Check throughput according to direction and protocol    dltp_expected=${dltp_expected_Stability}
#         ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected_Stability}
#     END
#     Stop traffic according to direction and protocol   tp_direction=${tp_direction}
#     [teardown]      Run Keywords      UE Detach for ${ue_type}  AND    CI_interface.Common Case Teardown   
#     ...       AND   robot_common_operations.Common Case Teardown
# 
