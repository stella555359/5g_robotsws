# *** Settings ***
# Documentation
# ...    author: y63li
# ...    contact: ying.15.li@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG
# ...    feature : 5GC001349-AA
# 
# Force Tags    CRT_TRUNK    CRT_21A    CRT_21B     CRT_22R1    CRT_22R2
# ...    PY36
# 
# Suite Setup       CB007859_Common Suite Setup for COAM
# Suite Teardown    CB007859_Common Suite Teardown for COAM
# 
# Resource       Resources/CB007859_Common_Keywords.robot
# *** Variables ***
# ${TS_CASE_LOG_PATH}   /home/ute/log
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB006667-E_032_DSS_DL_UL_scheduling_4UE_with_full_buff_10MHz_NSA
#    log to console    pass
# 
# [1]CB006667-E_033_DSS_DL_UL_scheduling_4UE_with_full_buff_15MHz_NSA
#    log to console    pass
# 
# [1]CB006667-E_034_DSS_DL_UL_scheduling_4UE_with_full_buff_20MHz_NSA
#     [Setup]    Case Setup for DSS 6667    chbw=${20}
#     Run CB006667_SA_Case
#     [Teardown]    Case Teardown
# 
# [1]CB006667-E_035_DSS_DL_UL_scheduling_4UE_with_scheduling_weights_20MHz_NSA
#    log to console    pass
# 
# [1]CB006667-B_001_Increased_FDM_scheduling_function_enable_disable
#    log to console    pass
# 
# [1]CB006667-B_003_DL_UL_scheduling_4UE_with_low_buff_5MHz_NSA_conf1
#    log to console    pass
# 
# [1]CB006667-B_004_DL_UL_scheduling_8UE_with_low_buff_10MHz_NSA_conf1
#    log to console    pass
# 
# [1]CB006667-B_005_UL_scheduling_10UE_with_low_buff_15MHz_NSA_conf1
#    log to console    pass
# 
# [1]CB006667-B_006_DL_scheduling_12UE_with_low_buff_20MHz_NSA_conf1
#     [Setup]    Case Setup 6667    chbw=${20}
#     Run CB006667_SA_Case
#     [Teardown]    Case Teardown
# 
# 
