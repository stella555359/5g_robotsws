# *** Settings ***
# Force Tags    PY36     RAN_5G_FDD    SBTS00     CRT_TRUNK      CRT_22R3
# Documentation    Suite description
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords    Download MCShark file To UTE
# ...    AND    android_ue.Kill ADB application
# ...    AND     robot_common_operations.Common Suite Setup
# 
# 
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# 
# Library         ute_ue
# Library            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
# Resource           resources/keywords_545.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# *** Variables ***
# ${tput_DL_bandwith}     35Mbits/sec
# ${tput_UL_bandwith}     15MBits/sec
# ${tput_deviation}       10%
# ${tput_duration}        450s
# ${Packet_Size}          1200
# ${start_cnt}            1
# ${stop_cnt}             20
# ${resource_path_545-B}        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007271_C/5GC000545/resources
# ${ue_index}     0
# ${ul_port}     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
# ${SCF_545_B_01}     TL1910_10M.xml
# ${10M_DCI00_size}     39
# ${10M_DCI01_size}     38
# ${545_10M_DCI01_size}     36
# ${SCF_545_B_02}     TL1910_5M.xml
# ${545_5M_DCI01_size}    34
# ${5M_DCI01_size}    36
# ${5M_DCI00_size}    37
# ${SCF_545_B_03}     TL1910_20M.xml
# ${545_20M_DCI01_size}    38
# ${20M_DCI01_size}    40
# ${20M_DCI00_size}    39
# ${SCF_545_B_04}     TL1910_5M.xml
# @{End_Value}    ${127}    ${127}
# @{Original_Value}    ${0}    ${0}
# ${ue_type}                  samsung
# ${PATH_Storage}    /home/ute/tmp/5GC000545
# 
# 
# #*** Test Cases ***
# #[1]CB007271_5G_C_5GC000545_001_Transform_Precoder_activation_64QAM_SA_UE
# #    [Tags]    C01    CRT_22R4
# #    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
# #    ...  which supports Transform Precoding, is re-configured between use of Transform Precoder
# #    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions. UE starts connection with CP OFDM,
# #    ...  send data in UL using 64QAM modulation. It means that MCS index must be from range 17-27 -
# #    ...  only 64QAM MCS table (38.214 Table 6.1.4.1-1) is supported with DFT-S-OFDM. Test is performed in SA mode
# #    ...  and 10MHz cell bandwidth..
# #    [Setup]     Test Case Setup    Transform_Precoder_activation_64QAM_SA_UE
# #    [Teardown]  Test Case Teardown
# #    Transform_Precoder_activation_64QAM_SA_UE
#     
# #[1]CB007271_5G_C_5GC000545_002_Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
# #    [Tags]    C02 
# #    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
# #    ...  which supports Transform Precoding, is successfully re-configured between use of Transform Precoder
# #    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions.
# #	  ...  When being handover from cell where feature is not supported to cell where the feature is active.
# #    [Setup]     Test Case Setup    Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
# #    [Teardown]  Test Case Teardown
# #    Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
#    
# #[1]CB007271_5G_C_5GC000545_003_Dynamic Transform Precoder Switching_NSA_UE_DCI_0_1_ 20MHz_SRB3_TCP_Open_Loop_MIMO
# #    [Tags]    C03    CRT_22R4
# #    [Documentation]  This user scenario describes gNB behavior when a RRC Connected UE,
# #    ...  which supports Transform Precoding, is re-configured between use of Transform Precoder
# #    ...  (DFT-S-OFDM) and CP-OFDM for DCI 0_1 transmissions. UE starts connection with CP OFDM,
# #    ...  send data in UL using 64QAM modulation. It means that MCS index must be from range 17-27 -
# #    ...  only 64QAM MCS table (38.214 Table 6.1.4.1-1) is supported with DFT-S-OFDM. Test is performed in NSA mode
# #    ...  and 20MHz cell bandwidth..
# #    [Setup]     Test Case Setup    Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO
# #    [Teardown]  Test Case Teardown
# #    Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO
#     
# #[1]CB007271_5G_C_5GC000545_004_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
# #    [Tags]    C04    CRT_22R4
# #    [Setup]     Test Case Setup    Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
# #    [Teardown]  Test Case Teardown
# #    Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP    
# 
#     
# 
# 
# 
#   
# 
#     
#     
#     
#     
# 
#   
# 
