# *** Settings ***
# Documentation
# ...    author: Wang Xiaocui
# ...    contact: xiaocui.wang@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG
# ...    Feature 5GC001358-DA
# Force Tags
# ...    PY36
# Resource    ./Resources/5GC001358_DA_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_U-plane_Fast_C-plane_counters.robot
# Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
# Resource    ./Resources/5GC001358_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# ${data_amount}    2M
# ${seg_size}    1300
# ${process_num}    5
# ${protocol}  udp
# ${deviation}    1%
# @{PrachIdex_list_for_A2}    87    88    92    93    94    98    100    101    104
# ${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}
# ${sleep_time}    3min
# &{all_tp_0}     average=0.00    peak=0.00   minimum=0.00
# *** Test Cases ***
# 
# [1]5GC001358-DA_01_chBW_100M_PRACH_A2_Loop_frame_structure_1116_with_3ms_shift
#     [Documentation]
#     ...    The purpose of this test case is to verify that:
#     ...    Prach A2 configuration index works when eCPRI in AZQG
#     [Tags]    CRT_TRUNK      CDRT_22R2      CRT_22R2
#     [Setup]    robot_common_operations.Common Case Setup
#     ${stream}    Get Stream
#     Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_1}
#     Prepare UE for ${ue_type}
#     FOR    ${prachIndex}    IN    @{PrachIdex_list_for_A2}
#         Change prachConfigurationIndex value    target_value=${prachIndex}
#         Start to Capture X2 Log    filename=prachindex${prachIndex}.pcap
#         UE Attach for ${ue_type}
#         Stop and Download Log    filename=prachindex${prachIndex}.pcap
#         Check prachConfigurationIndex value on X2 log    filename=prachindex${prachIndex}.pcap    exp_value=${prachIndex}
#         UE Detach for ${ue_type}
#     END
#     [Teardown]    robot_common_operations.Common Case Teardown
# [1]5GC001358-DA_02_chBW_90M_PRACH_A2_89_frame_structure_1208_2x2_CL_64QAM_ULDL
#     [Documentation]
#     ...    The purpose of test case is verify Peak tp can be reached when chbw is 90Mz
#     [Tags]    CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common Case Setup
#     ${stream}    Get Stream
#     Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_90M}
# 	Set Suite Variable   @{all_tp_DL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp_UL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp}    ${all_tp_DL}  ${all_tp_UL}
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_90M_01}
#     Prepare UE for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    dltp_expected=${dltp_2DL_64QAM_90MHz}    data_send_dl=${dldata_2DL_64QAM_90MHz}    tp_direction=dl
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    ultp_expected=${ultp_90MHz}    data_send_ul=${uldata_90MHz}    tp_direction=ul
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
# #    UE Attach for ${ue_type}
# #    Start traffic and check result    dltp_expected=${dltp_2DL_64QAM_90MHz}    data_send_dl=${dldata_2DL_64QAM_90MHz}    tp_direction=both
# #    UE Detach for ${ue_type}
#     [Teardown]    robot_common_operations.Common Case Teardown
# [1]5GC001358-DA_03_chBW_70M_PRACH_A2_102_frame_structure_1116_0ms_shift_2x2_OL_256QAM_ULDL
#     [Documentation]
#     ...    The purpose of test case is verify Peak tp can be reached when chbw is 70Mz
#     [Tags]    CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common Case Setup   
# 	Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_SBTS00.xml    scf_parameters=${MODIFY_SCF_70M}
# 	Set Suite Variable   @{all_tp_DL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp_UL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp}    ${all_tp_DL}  ${all_tp_UL}
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_70M_01}
#     Prepare UE for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    dltp_expected=${dltp_4DL_256QAM_70MHz}    data_send_dl=${dldata_4DL_256QAM_70MHz}    tp_direction=dl
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    ultp_expected=${ultp_70MHz}    data_send_ul=${uldata_70MHz}    tp_direction=ul
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
# #    UE Attach for ${ue_type}
# #    Start traffic and check result    dltp_expected=${dltp_4DL_256QAM_70MHz}    data_send_dl=${dldata_4DL_256QAM_70MHz}    tp_direction=both
# #    UE Detach for ${ue_type}
#     [Teardown]    robot_common_operations.Common Case Teardown
# [1]5GC001358-DA_04_chBW_50M_frame_structure_1116_3ms_shift_4x4_CL_256QAM_ULDL
#     [Documentation]
#     ...    The purpose of test case is verify Peak tp can be reached when chbw is 50Mz
#     [Tags]    CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common Case Setup
#     ${stream}    Get Stream
#     Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_8T8R_${stream}.xml    scf_parameters=${MODIFY_SCF_50M}
# 	Set Suite Variable   @{all_tp_DL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp_UL}    ${all_tp_0}
#     Set Suite Variable   @{all_tp}    ${all_tp_DL}  ${all_tp_UL}
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_50M_01}
#     Prepare UE for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    dltp_expected=${dltp_4DL_256QAM_50MHz}    data_send_dl=${dldata_4DL_256QAM_50MHz}    tp_direction=dl
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
#     UE Attach for ${ue_type}
#     Start traffic and check result    ultp_expected=${ultp_50MHz}    data_send_ul=${uldata_50MHz}    tp_direction=ul
# 	...    sleep_time=${sleep_time}
#     UE Detach for ${ue_type}
# #    UE Attach for ${ue_type}
# #    Start traffic and check result    dltp_expected=${dltp_4DL_256QAM_50MHz}    data_send_dl=${dldata_4DL_256QAM_50MHz}    tp_direction=both
# #    UE Detach for ${ue_type}
#     [Teardown]    robot_common_operations.Common Case Teardown
# [1]5GC000399_eCPRI_U-plane_Fast_C-plane_counters
#     [Documentation]    M55318 Related counter are checked in test case
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup	
#     COAM Create log directory
# 	Connect to gnb coam via ssl
# 	General_SiSo_U-plane_Fast_C-plane_counters
#     [Teardown]    robot_common_operations.Common Case Teardown
# *** Keywords ***
