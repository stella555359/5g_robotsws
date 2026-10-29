# *** Settings ***
# Documentation
# ...    author: jack.zeng
# ...    contact: jack.zeng@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB010764-A
# 
# Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
# ...    PY36
# ...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_2xAWHHF_ENB    SBTS00
# 
# Suite Setup    Run Keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    CI_interface.Common Suite Setup    AND
# ...    Run Keyword And Ignore Error    Prepare gnb_logs and mcshark setup    AND
# ...    Run Keyword And Ignore Error    Common Suite Setup for COAM
# 
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown
# ...    AND        Run Keyword And Ignore Error    Common Suite Teardown for COAM
# ...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010764/Resources/CB010764_common_keywords.robot
# 
# *** Variables ***
# ${CB010764_gnb1_A_1001_1}    CB010764_gnb1_A_1001_1.pcap
# ${CB010764_gnb1_A_1001_2}    CB010764_gnb1_A_1001_2.pcap
# ${CB010764_gnb1_A_3006_1}    CB010764_gnb1_A_3006_1.pcap
# ${CB010764_gnb1_A_3006_2}    CB010764_gnb1_A_3006_2.pcap
# ${dl_expect}    1
# ${ul_expect}    1
# ${dl_throughput}    10M
# ${ul_throughput}    2M
# ${duration}    1200
# ${enb_instance}    38421
# ${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# ${enb_def_cell_para}     defaultLnRelGnbCellId
# 
# 
# *** Test Cases ***
# [1]CB010764-A#1_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_qpsk_modulation_and_UCI_3Bits_at_same_SNR_point
#     [Documentation]    CB010764-A
#     [Tags]    CB010764-A    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#     #Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_1_cloud}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${25}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${30}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${32}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_A_1001_1}   gNB_index=${0}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_A_1001_bip_01}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_A_1001}
#     Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_3}    skip_parameter_relation_errors=True
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=1    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${25}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${30}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${32}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_A_1001_2}   gNB_index=${0}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_A_1001_bip_02}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_A_1001}
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#     ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_1001_2}
#     ...           skip_parameter_relation_errors=True
#    ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-A#3_006_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Open_Loop_Power_Control_and_UCI_17Bits_at_same_SNR_point
#     [Documentation]    CB010764-A
#     [Tags]    CB010764-A    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${5}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_3006_1_cloud}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=3    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${28}
#     sleep    300s
#     ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#     Stop and download the Logs    filename=${CB010764_gnb1_A_3006_1}   gNB_index=${0}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_A_3006_bip_01}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_A_3006}
#     Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_A_3006_3_cloud}    skip_parameter_relation_errors=True
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${5}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=3    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${28}
#     sleep    300s
#     ##Run Keyword And Continue On Failure    Check DLUL tput    gnb_index=${0}    lcrid=${2}
#     Stop and download the Logs    filename=${CB010764_gnb1_A_3006_2}   gNB_index=${0}
#     Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_A_3006_bip_02}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=    Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_A_3006}
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} > 0
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false} > 0
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
# ##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***