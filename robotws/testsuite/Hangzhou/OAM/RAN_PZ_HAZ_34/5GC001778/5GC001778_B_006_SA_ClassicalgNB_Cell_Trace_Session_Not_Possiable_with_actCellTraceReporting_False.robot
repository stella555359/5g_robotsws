*** Settings ***
Documentation
...  author: Heng Liangliang
...  contact: jingmin.he@nokia-sbell.com   liangliang.heng@nokia-sbell.com

# Resource   Resource/emil.robot
# Resource   Resource/collect_log.robot
# Resource   Resource/common.robot
# Library    ./libraries/emil_messages.py

# Force Tags   SG_07   CA_5G_OAM     CIT_21B    CIT_20B   CIT_21A   CIT_TRUNK
# ...    PY36
# *** Variables ***

# *** Test Cases ***
# [1]5GC001778_B_006_SA_ClassicalgNB_Cell_Trace_Session_Not_Possiable_with_actCellTraceReporting_False
#     [Documentation]  If actCellTraceReport is set to false, there will be no cell trace session created.
#     [Setup]    Case Common Setup
#     Close Web Startup View Window
#     log to console   Add Cell Trace Object
#     Add Cell Trace Object Without Activate
#     Modify Parameter actCellTraceReport to True
#     Validate and Activate Plan
#     Close Web Startup View Window
#     log to console   Modify actCellTraceReport to false
#     Modify Parameter actCellTraceReport to False
#     Validate and Activate Plan
#     Close Web Startup View Window
#     log to console   Get latest trace file name
#     ${trace_file_before}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Sleep   15 min
#     ${trace_file_after}   Get Latest Trace File Name   bts_id=${MRBTS_ID}
#     Should Be Equal    ${trace_file_before}    ${trace_file_after}
# #    Remove Cell Trace Object
#     [Teardown]    Case Common Teardown