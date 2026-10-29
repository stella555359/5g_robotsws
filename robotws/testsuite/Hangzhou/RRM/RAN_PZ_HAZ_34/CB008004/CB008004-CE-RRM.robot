*** Settings ***
Documentation
...               author: Liu Xiaojing
...               contact: xiaojing.2.liu@nokia-sbell.com
...               squad group: MMW_SG_04

Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE
...    PY36
Suite Setup       Case Suite Setup
Suite Teardown    Suite Teardown

Library           ./Resources/CB008004_keyword.py
Resource          ./Resources/CB008004_common_keyword.robot
Variables         ./Resources/CB008004_modify_para.py
Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           OperatingSystem
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

*** Test Cases ***
[1]CB008004-CE-RRM-01_timing_offset_parameters_change_feature_activate_deactive_in_runtime_intra_CA
    [Tags]    CRT_TRUNK
    [Setup]    Case Setup
    ${cell_list}    create list    ${cell_1}    ${cell_2}
    Start Btslog Collect
    Set parameter Value    parameter=actEcpriRuPtpOnlySync    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter_value=${False}
    Start Traffic and check peak    cell_list=${cell_list}   ue_index=${2}   ul_peak=50   dl_peak=50
    ...    ul_throughput=100M    dl_throughput=100M
    Set parameter Value    parameter=actEcpriRuPtpOnlySync    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter_value=${true}
    ${frameStartOffset_value_1}    Generate_random   start=${0}     stop=${10000}    step=${0.0005}
    ${sfnOffset_value_1}    Generate_random   start=${-32768}     stop=${0}   step=${1}
    Change Multiple Parameter by selenium    frameStartOffset_value=${frameStartOffset_value_1}
    ...     sfnOffset_value=${sfnOffset_value_1}
    Stop btslog and check UE attach
    Compare alpha and beta    frameStartOffset_value=${frameStartOffset_value_1}    sfnOffset_value=${sfnOffset_value_1}
    Start Btslog Collect
    ${frameStartOffset_value_2}    Generate_random   start=${0}     stop=${10000}    step=${0.0005}
    ${sfnOffset_value_2}    Generate_random   start=${1}     stop=${32768}   step=${1}
    Change Multiple Parameter by selenium    frameStartOffset_value=${frameStartOffset_value_2}
    ...     sfnOffset_value=${sfnOffset_value_2}
    Start Traffic and stop btslog and check peak    cell_list=${cell_list}   ue_index=${2}   ul_peak=50   dl_peak=50
    ...    ul_throughput=100M    dl_throughput=100M
    Compare alpha and beta    frameStartOffset_value=${frameStartOffset_value_2}    sfnOffset_value=${sfnOffset_value_2}
    [Teardown]    Run keyword and ignore error    Case Teardown

[1]CB008004-SR-CE_002-time_offset_parameter_reconfiguration_in_runtime
    [Tags]    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run keyword and ignore error    Case Teardown
