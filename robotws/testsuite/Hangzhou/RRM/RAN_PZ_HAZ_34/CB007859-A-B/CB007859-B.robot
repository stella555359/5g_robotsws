# *** Settings ***
# Documentation     author: y63li
# ...               contact: ying.15.li@nokia-sbell.com
# ...               squad group: MMW_SG3
# 
# Force Tags        CRT_TRUNK    CRT_21B    CRT_22R1   CRT_22R2
# ...    PY36
# 
# Suite Setup       CB007859_Common Suite Setup for COAM
# Suite Teardown    CB007859_Common Suite Teardown for COAM
# 
# Resource       Resources/CB007859_Common_Keywords.robot
# *** Variables ***
# ${TS_CASE_LOG_PATH}   /home/ute/log
# 
# *** Test Cases ***
# [1]CB007859-B_034_DL_UL_scheduling_10MHz_NSA_below_3cells
#     [Setup]    Case Setup for DSS    chbw=${10}
#     Run CB007859_NSA_Case
#     [Teardown]    Case Teardown
# 
# [1]CB007859-B_036_DL_UL_scheduling_20MHz_NSA_below_3cells
#     [Setup]    Case Setup for DSS    chbw=${20}
#     Run CB007859_NSA_Case
#     [Teardown]    Case Teardown
# 
# [1]CB007859-B_037_DL_UL_scheduling_10MHz_SA_above_3cells
#     [Setup]    Case Setup for max cell DSS    chbw=${10}
#     Run CB007859_SA_Case
#     [Teardown]    Case Teardown
# 
# [1]CB007859-B_038_DL_UL_scheduling_15MHz_SA_above_3cells
#     [Setup]    Case Setup for max cell DSS    chbw=${15}
#     Run CB007859_SA_Case
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
