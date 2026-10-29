# *** Settings ***
# Documentation
# ...  author: Zhang Jin 2
# ...  contact: jin.2.zhang@nokia-sbell.com
# 
# Force Tags                             5G_RAN    5G_RAN_TDD    CRT_TRUNK    CRT_22R4
# Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008196/Resource/CB008196_A_keyword.robot
# Resource   ${CURDIR}/Resource/keywords_8196.robot
# Resource   Resource/8196_10_11_keywords.robot
# 
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Suite Setup    Run Keywords    Suite Case Setup
# ...    AND     robot_common_operations.Common Suite Setup
# 
# 
# Suite Teardown   Run Keywords     robot_common_operations.Common Suite Teardown
# ...    AND    CI_interface.Common Suite Setup
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# *** Variables ***
# 
# 
# 
# 
# *** Test Cases ***
# #CB008196_A_001_SA_ClassicalgNB_PCMD_and_cell_trace_Configuration_And_Activation_From_NetAct
# #    [Documentation]   use WEBEM for PCMD and cell trace Configuration And Activation instead of NetAct, provides better performance
# #    Common 8196_A Setup
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291    p_name=actCellTraceReport   new_value=false
# #    sleep    20s
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291    p_name=actPCMDReport   new_value=false
# #    sleep    60s
# #
# #    Start to collect wireshark log for ASIK     name=SCTP1
# #    The first UE make the first SA call
# #    sleep   30s
# #    Stop collecting wireshark log      name=SCTP1    target_dir=${target_dir}
# #
# #    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to False
# #    ...   bip_file=${target_dir}/SCTP1/SCTP1.pcap    csv_file=${target_dir}/SCTP1/before.csv
# #
# #    #Activated And Configured PCMD By NetAct For CB008196
# #    #sleep   200s
# #    #Check the PCMD and cell trace Related parameters via WEBUI For CB008196
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actCellTraceReport   new_value=true
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actPCMDReport   new_value=true
# #
# #    sleep   10s
# #
# #    Start to collect wireshark log for ASIK    name=SCTP2
# #    The second UE perform the second SA Call
# #    sleep  60s
# #    UEs detach
# #    Stop collecting wireshark log      name=SCTP2    target_dir=${target_dir}
# #
# #    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True
# #    ...  bip_file=${target_dir}/SCTP2/SCTP2.pcap    csv_file1=${target_dir}/SCTP2/after_nrrrc.csv
# #    ...  csv_file2=${target_dir}/SCTP2/after_PCMD.csv     csv_file3=${target_dir}/SCTP2/after_celltrace.csv
# #
# #
# #
# #
# #CB008196_A_004_SA_ClassicalgNB_cell_trace_and_PCMD_Deactivation_via_flags_From_NetAct
# #    [Documentation]   use WEBEM for PCMD and cell trace Configuration And Activation instead of NetAct, provides better performance
# #    Common 8196_A Setup
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actCellTraceReport   new_value=true
# #    sleep    20s
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actPCMDReport   new_value=true
# #    sleep    60s
# #
# #    Start to collect wireshark log for ASIK     name=SCTP3
# #    The second UE perform the second SA Call
# #    sleep   30s
# #    Stop collecting wireshark log      name=SCTP3    target_dir=${target_dir}
# #
# #    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True
# #    ...  bip_file=${target_dir}/SCTP3/SCTP3.pcap    csv_file1=${target_dir}/SCTP3/before_nrrrc.csv
# #    ...  csv_file2=${target_dir}/SCTP3/before_PCMD.csv     csv_file3=${target_dir}/SCTP3/before_celltrace.csv
# #
# #
# #    #Deactivated And Configured PCMD By NetAct For CB008196
# #    #sleep   200s
# #    #Check the PCMD and cell trace Related parameters via WEBUI For CB008196_2
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actCellTraceReport   new_value=false
# #    gNB Set Attribute Value      dist_name=MRBTS-1997/NRBTS-10291   p_name=actPCMDReport   new_value=false
# #
# #
# #    sleep   10s
# #    Start to collect wireshark log for ASIK    name=SCTP4
# #
# #    The first UE make the first SA call
# #    sleep  60s
# #    UEs detach
# #
# #    Stop collecting wireshark log      name=SCTP4    target_dir=${target_dir}
# #
# #    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to False
# #    ...   bip_file=${target_dir}/SCTP4/SCTP4.pcap    csv_file=${target_dir}/SCTP4/after.csv
# #    
# #[1]CB008196_A_005_SA_ClassicalgNB_PCMD_and_cell_trace_cellActivePeriodicUETraced_exceed_the_maximum_simultaneous_number_of_active_UEs_per_cell
# #    [Documentation]  Due to limited resources, use two UEs instead of three UEs for testing  
# #    ...  author: Yang Liqin 
# #    ...  contact: liqin.yang@nokia-sbell.com
# #    Test Case Setup    PCMD_and_cell_trace_cellActivePeriodicUETraced_exceed_cellMaxPeriodicUEsTraced
# #    [Teardown]  Test Case Teardown
# #    PCMD and cell trace cellActivePeriodicUETraced exceed cellMaxPeriodicUEsTraced
# #    
# #[1]CB008196_A_007_SA_ClassicalgNB_PCMD_cellMaxPeriodicUEsTraced_is_less_than_cellMaxActiveUEsTraced_during_intra_gnb_HO
# #    [Documentation]  author: Yang Liqin 
# #    ...  contact: liqin.yang@nokia-sbell.com
# #    Test Case Setup    PCMD_cellMaxPeriodicUEsTraced_is_less_than_cellMaxActiveUEsTraced_during_intra_gnb_HO
# #    [Teardown]  Test Case Teardown
# #    PCMD cellMaxPeriodicUEsTraced is less than cellMaxActiveUEsTraced during intra gnb HO
# #
# #[1]CB008196_A_008_SA_ClassicalgNB_cell_trace_cellMaxPeriodicUEsTraced_is_less_than_cellMaxActiveUEsTraced_during_intra_gnb_HO
# #    [Documentation]  author: Yang Liqin 
# #    ...  contact: liqin.yang@nokia-sbell.com
# #    Test Case Setup    cell_trace_cellMaxPeriodicUEsTraced_is_less_than_cellMaxActiveUEsTraced_during_intra_gnb_HO
# #    [Teardown]  Test Case Teardown
# #    cell trace cellMaxPeriodicUEsTraced is less than cellMaxActiveUEsTraced during intra gnb HO
# #    
# #[1]CB008196_A_009_SA_ClassicalgNB_PCMD_and_cell_trace_UEs_Handover_between_enabled_trace_and_disabled_trace_cells
# #    [Documentation]  author: Yang Liqin 
# #    ...  contact: liqin.yang@nokia-sbell.com
# #    Test Case Setup    PCMD_and_cell_trace_UEs_Handover_between_enabled_trace_and_disabled_trace_cells
# #    [Teardown]  Test Case Teardown
# #    PCMD and cell trace UEs Handover between enabled trace and disabled trace cells  
# #
# #[1]CB008196_A_010_SA_ClassicalgNB_PCMD_and_cell_trace_gNB_reset_with_infinity_reportamount_after_intra_gnb_HO
# #    [Documentation]  author: Ding Lili 
# #    ...  contact: lili.ding@nokia-sbell.com
# #    case_setup a1011
# #    CB008196_A_010
# #    [Teardown]    UE teardown
# #
# #[1]CB008196_A_011_SA_ClassicalgNB_PCMD_and_cell_trace_UE_release_when_reportAmount_is_not_infinity_after_intra_gnb_HO
# #    [Documentation]  author: Ding Lili
# #    ...  contact: lili.ding@nokia-sbell.com
# #    case_setup a1011
# #
# #    CB008196_A_011
# #    [Teardown]    UE teardown
# 
# 
# 
# 
