# *** Settings ***
# Documentation
# ...   Author: y63li
# ...   Contact: ying.15.li@nokia-sbell.com
# ...   Description: This scenario addresses fault and alarm reporting when cell can provide only SA or only NSA service
# ...   basing on link status for SA+NSA cell.
# 
# Suite Setup
# Suite Teardown
# Test Timeout    50 minutes
# 
# Resource    ./Resources/CB007582_Common_Keywords_Cloud.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007582-D_5_Cell_activation_for_unavailable_X2_before_available_Ng
#     [Setup]    Case Setup
#     Configure cell activation parameters
#     Lock cell on GNB-CU
#     Lock NG link
#     Lock X2 link
#     Check No Other Fault Raise
#     Unlock cell1 on GNB-CU
#     Sleep    20
#     Check Fault and cell State    severity=major    operational=disabled
#     Sleep    140
#     Check Fault and cell State    severity=critical    operational=disabled
#     Unlock NG link
#     Check Fault and cell State    severity=major    operational=enabled
#     Unlock X2 link
#     Recover testline
#     Check Cell Should Be Onair
#     [Teardown]    case teardown
# 
# *** Keywords ***
# 
# 
# 
