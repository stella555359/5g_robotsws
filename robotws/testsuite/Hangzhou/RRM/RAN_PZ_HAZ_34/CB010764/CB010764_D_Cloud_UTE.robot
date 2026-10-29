# *** Settings ***
# Documentation
# ...    author: jack.zeng
# ...    contact: jack.zeng@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB010764-D
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
# ${CB010764_gnb1_D_2001_1}    CB010764_gnb1_D_2001_1.pcap
# ${CB010764_gnb1_D_2001_2}    CB010764_gnb1_D_2001_2.pcap
# ${CB010764_gnb1_D_3001_1}    CB010764_gnb1_D_3001_1.pcap
# ${CB010764_gnb1_D_3001_2}    CB010764_gnb1_D_3001_2.pcap
# ${CB010764_gnb1_D_4001_1}    CB010764_gnb1_D_4001_1.pcap
# ${CB010764_gnb1_D_4001_2}    CB010764_gnb1_D_4001_2.pcap
# ${CB010764_gnb1_D_14001_1}    CB010764_gnb1_D_14001_1.pcap
# ${CB010764_gnb1_D_14001_2}    CB010764_gnb1_D_14001_2.pcap
# ${CB010764_gnb1_D_14001_3}    CB010764_gnb1_D_14001_3.pcap
# ${CB010764_gnb1_D_18001_1}    CB010764_gnb1_D_18001_1.pcap
# ${CB010764_gnb1_D_18001_2}    CB010764_gnb1_D_18001_2.pcap
# ${CB010764_gnb1_D_18001_3}    CB010764_gnb1_D_18001_3.pcap
# ${dl_expect}    1
# ${ul_expect}    1
# ${dl_throughput}    10M
# ${ul_throughput}    2M
# ${duration}    1200
# 
# 
# *** Test Cases ***
# ##[1]CB010764-D#2_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_pi2bpsk_modulation_and_UCI_19Bits_at_same_SNR_point_ABIP_or_ABIQ
# ##    [Documentation]    CB010764-D
# ##    [Tags]    CB010764-D    CRT_TRUNK
# ##    [Timeout]    2 hour
# ##    [Setup]
# ##    robot_common_operations.Common Case Setup
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
# ##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_1_cloud}    skip_parameter_relation_errors=True
# ##    Comment    step1.start to capture btslog/bip/wireshark logs
# ##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# ##    Start capture gNB log on master    filename=${CB010764_gnb1_D_2001_1}   gNB_index=${0}
# ##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
# ##    sleep    10s
# ##    start DL UL    ue_index=${0}    gnb_index=${0}
# ##    Prepare with PM counter time to caculate    period=end
# ##    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
# ##    sleep    10s
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
# ##    sleep    10s
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}    enb1_cell1_value=${10}
# ##    sleep    300s
# ##    Stop and download the Logs    filename=${CB010764_gnb1_D_2001_1}   gNB_index=${0}
# ##    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
# ##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# ##    ###check counters
# ##    ${CB010764_gnb1_D_2001_bip_01}=    Download gnb_logs after log collection finsished
# ##    Prepare with PM counter time to caculate    period=end
# ##    sleep    90s
# ##    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
# ##    ...    dic_path=${counter_dic_path_D_2001}
# ##    Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
# ##    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
# ##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# ##    Start capture gNB log on master    filename=${CB010764_gnb1_D_2001_2}   gNB_index=${0}
# ##    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
# ##    sleep    10s
# ##    start DL UL    ue_index=${0}    gnb_index=${0}
# ##    Prepare with PM counter time to caculate    period=end
# ##    Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
# ##    sleep    10s
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
# ##    sleep    10s
# ##    Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}    enb1_cell1_value=${10}
# ##    sleep    300s
# ##    Stop and download the Logs    filename=${CB010764_gnb1_D_2001_2}   gNB_index=${0}
# ##    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
# ##    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# ##    ###check counters
# ##    ${CB010764_gnb1_D_2001_bip_02}=    Download gnb_logs after log collection finsished
# ##    Prepare with PM counter time to caculate    period=end
# ##    sleep    90s
# ##    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
# ##    ...    dic_path=${counter_dic_path_D_2001}
# ##    Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
# ##    [Teardown]    Run Keywords
# ##    ...    robot_common_operations.Common Case Teardown
# ##    ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
# ##    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
# ##    ...           skip_parameter_relation_errors=True
# ##   ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
# ##    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# ##
# [1]CB010764-D#3_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_Closed_Loop_Power_Control_pucch_and_UCI_7Bits_at_same_SNR_point_ABIP_or_ABIQ
#     [Documentation]    CB010764-D
#     [Tags]    CB010764-D    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_3001_1_cloud}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_D_3001_1}   gNB_index=${0}
#     Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_D_3001_bip_01}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_D_2001}
#     Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${45}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_D_3001_2}   gNB_index=${0}
#     Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_D_3001_bip_02}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_D_2001}
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#     ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#     ...           skip_parameter_relation_errors=True
#    ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-D#4_001_PUCCH_F3_DTX_Decoding_Based_Method_on_and_off_with_additional_DMRS_in_not_high_speed_cell_ABIP_or_ABIQ
#     [Documentation]    CB010764-D
#     [Tags]    CB010764-D    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_4001_1_cloud}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${46}    enb1_cell1_value=${10}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_D_4001_1}   gNB_index=${0}
#     Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_D_4001_bip_01}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_D_2001}
#     Comment    Online modify NIDD parameter:actPucchF3MethodDTX=false
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_3}    skip_parameter_relation_errors=True
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     sleep    10s
#     start DL UL    ue_index=${0}    gnb_index=${0}
#     Prepare with PM counter time to caculate    period=end
#     Run Keyword And Ignore Error    Capture Logs With gNB_logs_exe File without wait_to_finish    bbmod_slots=2    duration=100
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${42}    enb1_cell1_value=${10}
#     sleep    10s
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${46}    enb1_cell1_value=${10}
#     sleep    300s
#     Stop and download the Logs    filename=${CB010764_gnb1_D_4001_2}   gNB_index=${0}
#     Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     ###check counters
#     ${CB010764_gnb1_D_4001_bip_02}=    Download gnb_logs after log collection finsished
#     Prepare with PM counter time to caculate    period=end
#     sleep    90s
#     ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}=     Check counter for CB010764_gnb1_A    counter_id=${counter_id_A_1001}
#     ...    dic_path=${counter_dic_path_D_2001}
#     Should Be True    ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_true} < ${PUCCH_Format3_DTX_Ratio_actPucchF3MethodDTX_false}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#     ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#     ...           skip_parameter_relation_errors=True
#    ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-D#14_001_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Transform_Precoding_for_FDD_NSA_CPRI_15M_high_CQI_Jitter_with_2Rx_ABIP_or_ABIQ
#     [Documentation]    CB010764-D
#     [Tags]    CB010764-D    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_1_Cell2}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     start UL    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_14001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_14001_1}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_01}
#     Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_14001_2_Cell2}    skip_parameter_relation_errors=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     start UL    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_14001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_14001_2}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_02}
#     Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     sleep    2s
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${34}    enb1_cell1_value=${10}
#     start UL    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${37}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_14001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_14001_3}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_14001_1_bip_03}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#     ...    AND    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_2001_2}
#     ...           skip_parameter_relation_errors=True
#    ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-D#18_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_4RX_for_TDD_IWK_with_adaptive_reTX_and_DFT-OFDM_ABIP_or_ABIQ
#     [Documentation]    CB010764-D
#     [Tags]    CB010764-D    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_1_Cell2}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${37}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_18001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_18001_1}    gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_01}
#     Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_D_18001_2_Cell2}    skip_parameter_relation_errors=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${37}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_18001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_18001_2}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_02}
#     Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${30}    enb1_cell1_value=${10}
#     sleep    2s
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${36}    enb1_cell1_value=${10}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     Adjust the TL Topyoung attenuation value    gnb1_cell2_value=${38}    enb1_cell1_value=${10}
#     ${CB010764_gnb1_D_18001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=2    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_D_18001_3}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_D_18001_1_bip_03}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
#     ...    AND    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
#    ## ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***