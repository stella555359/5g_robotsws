# *** Settings ***
# Documentation
# ...               author: wang zhouqun
# ...               contact: zhouqun.wang@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE
# ...    PY36
# Suite Setup       Case Suite Setup
# Suite Teardown    Suite Teardown
# 
# Library           ./Resources/CB008004_keyword.py
# Resource          ./Resources/CB008004_common_keyword.robot
# Resource          taf/rfrl/common_resources/robot/coam.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           OperatingSystem
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# 
# *** Test Cases ***
# [1]CB008004-SR-CE_001_time_offset_parameter_shif_feature_activate_and_deactivate_in_runtime
#     [Tags]    CRT_TRUNK
#     [Setup]    CB008004-SR-CE_001_Case_Setup
#     ${cell_list}    create list    ${cell_1}    ${cell_2}
#     Start Btslog Collect
#     Set parameter Value    parameter=actCellTimingOffset    dist_name=${dist_actCellTimingOffset}    parameter_value=${true}
#     Set parameter Value    parameter=actEcpriRuPtpOnlySync    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter_value=${true}
#     Change Multiple Parameter by selenium    frameStartOffset_value=${3000}     sfnOffset_value=${100}
#     Stop Btslog Collect
#     Check alpha and beta in BTSlog    DL_alpha=${3686400}    DL_beta=${100}    UL_alpha=${3677780}    UL_beta=${100}
#     Start Traffic and check peak    cell_list=${cell_list}   ue_index=${2}   ul_peak=10   dl_peak=20
#     ...    ul_throughput=50M    dl_throughput=100M
#     Change Offset value and attach UE     frameStartOffset_value=1948.9585     sfnOffset_value=${360}
#     ...    DL_alpha=${2394880}    DL_beta=${360}    UL_alpha=${2386260}    UL_beta=${360}
#     Change Offset value and attach UE     frameStartOffset_value=9999.9995     sfnOffset_value=${32767}
#     ...    DL_alpha=${12287999}    DL_beta=${32767}    UL_alpha=${12279379}    UL_beta=${32767}
#     Change Offset value and attach UE     frameStartOffset_value=${0}     sfnOffset_value=${-32768}
#     ...    DL_alpha=${0}    DL_beta=${-32768}    UL_alpha=${12279380}    UL_beta=${32767}
#     [Teardown]    Run keyword and ignore error    Case Teardown
