# *** Settings ***
# Documentation
# ...    author: jack.zeng
# ...    contact: jack.zeng@nokia-sbell.com
# ...    squal group: SG03
# ...    feature: CB010764-C
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
# ${gnb_logs_install_path}     /home/ute/gnb_logs
# ${CB010764_gnb1_C_4001_1}    CB010764_gnb1_C_4001_1.pcap
# ${CB010764_gnb1_C_4001_2}    CB010764_gnb1_C_4001_2.pcap
# ${CB010764_gnb1_C_4001_3}    CB010764_gnb1_C_4001_3.pcap
# ${CB010764_gnb1_C_5002_1}    CB010764_gnb1_C_5002_1.pcap
# ${CB010764_gnb1_C_5002_2}    CB010764_gnb1_C_5002_2.pcap
# ${CB010764_gnb1_C_5002_3}    CB010764_gnb1_C_5002_3.pcap
# ${CB010764_gnb1_C_7001_1}    CB010764_gnb1_C_7001_1.pcap
# ${CB010764_gnb1_C_7001_2}    CB010764_gnb1_C_7001_2.pcap
# ${CB010764_gnb1_C_7001_3}    CB010764_gnb1_C_7001_3.pcap
# ${CB010764_gnb1_C_10001_1}    CB010764_gnb1_C_10001_1.pcap
# ${CB010764_gnb1_C_10001_2}    CB010764_gnb1_C_10001_2.pcap
# ${CB010764_gnb1_C_10001_3}    CB010764_gnb1_C_10001_3.pcap
# ${dl_expect}    1
# ${ul_expect}    1
# ${dl_throughput}    10M
# ${ul_throughput}    2M
# ${duration}    600
# 
# *** Test Cases ***
# ##norun
# #[1]CB010764-C#5_002_PUSCH_A-CSI_CSI_Part2_with_PUSCH_Open_loop_power_control_for_FDD_SA_CPRI_20M_high_CQI_Jitter_with_4Rx
# #    [Documentation]    CB010764-C
# #    [Tags]    CB010764-C    CRT_TRUNK
# #    [Timeout]    2 hour
# #    [Setup]
# #
# #    robot_common_operations.Common Case Setup
# #    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
# #    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_5001_2_Cell3}    skip_parameter_relation_errors=True
# #    Comment    step1.start to capture btslog/bip/wireshark logs
# #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# #    Start capture gNB log on master    filename=${CB010764_gnb1_C_5002_1}   gNB_index=${0}
# #    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
# #    Comment    Start bursty UL data transmission change the data rate frequently for 10min
# #    Start bursty UL data transmission on Commercial with first UE
# #    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${24}
# #    ${CB010764_gnb1_C_5002_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
# #    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# #    Stop and download the Logs    filename=${CB010764_gnb1_C_5002_1}   gNB_index=${0}
# #    ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_5002_1_bip_01}
# #    Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
# #    Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_5002_2_Cell3}    skip_parameter_relation_errors=True
# #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# #    Start capture gNB log on master    filename=${CB010764_gnb1_C_5002_2}   gNB_index=${0}
# #    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
# #    Comment    Start bursty UL data transmission change the data rate frequently for 10min
# #    Start bursty UL data transmission on Commercial with first UE
# #    ${CB010764_gnb1_C_5002_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
# #    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# #    Stop and download the Logs    filename=${CB010764_gnb1_C_5002_2}   gNB_index=${0}
# #    ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_5002_1_bip_02}
# #    Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
# #    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
# #    sleep    2s
# #    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
# #    Start capture gNB log on master    filename=${CB010764_gnb1_C_5002_3}   gNB_index=${0}
# #    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
# #    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
# #    Comment    Start bursty UL data transmission change the data rate frequently for 10min
# #    Start bursty UL data transmission on Commercial with first UE
# #    Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${27}
# #    ${CB010764_gnb1_C_5002_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
# #    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# #    Stop and download the Logs    filename=${CB010764_gnb1_C_5002_3}   gNB_index=${0}
# #    ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_5002_1_bip_03}
# #    Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
# #    Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
# #    [Teardown]    Run Keywords
# #    ...    robot_common_operations.Common Case Teardown
# ##    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
# #    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-C#7_001_PUSCH_A-CSI_CSI_Part2_handling_with_bursty_UL_data_with_2RX_for_TDD_IWK_with_adaptive_reTX
#     [Documentation]    CB010764-C
#     [Tags]    CB010764-C    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_1_Cell3}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${24}
#     ${CB010764_gnb1_C_7001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_7001_1}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_01}
#     Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_7001_2_Cell3}    skip_parameter_relation_errors=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     ${CB010764_gnb1_C_7001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_7001_2}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_02}
#     Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     sleep    2s
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#     Comment    Start bursty UL data transmission change the data rate frequently for 10min
#     Start bursty UL data transmission on Commercial with first UE
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${27}
#     ${CB010764_gnb1_C_7001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=300
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_7001_3}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_7001_1_bip_03}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
# #    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CB010764-C#10_001_PUSCH_A-CSI_CSI_Part2_handling_with_low_UL_data_profile_with_4RX_for_TDD_WK_with_adaptive_reTX_and_DFT-OFDM
#     [Documentation]    CB010764-C
#     [Tags]    CB010764-C    CRT_TRUNK
#     [Timeout]    2 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_1_Cell3}    skip_parameter_relation_errors=True
#     Comment    step1.start to capture btslog/bip/wireshark logs
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     start UL    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${24}
#     ${CB010764_gnb1_C_10001_1_bip_01}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_10001_1}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio1}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_01}
#     Comment    change the parameter actPuschACSIPart2ThrAdj from false to true, then repeat step1~step4
#     Online modify parmeters     parameters_to_update=${PARAM_CB010764_gnb1_C_10001_2_Cell3}    skip_parameter_relation_errors=True
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     start UL    ue_index=${0}    gnb_index=${0}
#     ${CB010764_gnb1_C_10001_1_bip_02}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_10001_2}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio2}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_02}
#     Comment    Adjust the PA, to make a little worse radio condition, then repeat step1-step4
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${15}
#     sleep    2s
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#     Start capture gNB log on master    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${20}
#     start UL    ue_index=${0}    gnb_index=${0}
#     Adjust the TL Topyoung attenuation value    gnb1_cell3_value=${27}
#     ${CB010764_gnb1_C_10001_1_bip_03}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=3    duration=350
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#     Stop and download the Logs    filename=${CB010764_gnb1_C_10001_3}   gNB_index=${0}
#     ${dtxCsiPart2_DTX_Ratio3}=    Check csi2 dtx rate in BIP Log with mcshark    file_path=${CB010764_gnb1_C_10001_1_bip_03}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio1}
#     Should Be True     ${dtxCsiPart2_DTX_Ratio2} < ${dtxCsiPart2_DTX_Ratio3}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown
# #    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
#     ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
