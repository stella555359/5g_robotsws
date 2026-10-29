# *** Settings ***
# Documentation
# ...   author: Han Ruiyu
# ...   contact: ruiyu.han@nokia-sbell.com
# 
# Resource   .${/}Resource${/}common.robot
# Resource   .${/}Resource${/}702.robot
# #Suite Setup   Suite Setup Steps
# #Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CRT
# ...    PY36
# 
# 
# *** Test Cases ***
# siso testline load default scf
#     [Timeout]    1h
#     [Setup]     Case Setup for 842
#     ${scf_load}   Set SCF Path
#     Import SCF by Custom for 842   local_path=${scf_load}
#     [Teardown]   Case Teardown for 842
# 
# 
# 
# 
