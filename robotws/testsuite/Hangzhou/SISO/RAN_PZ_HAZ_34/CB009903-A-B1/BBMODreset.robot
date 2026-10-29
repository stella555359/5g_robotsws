# *** Settings ***
# Documentation
# ...    author: Kaijia Chen
# ...    contact: kaijia.chen@nokia-sbell.com
# ...    squad group: VRF3_SG04
# ...    feature : CB009183
# 
# 
# Resource    ./Resources/CB009903_A_B1_common_keywords.robot
# Library     ./Resources/CB009903_A_B1_common_keywords.py
# 
# 
# #Suite Setup       CB009183 Suite Setup
# #Suite Teardown
# 
# *** Test Cases ***
# [1]BBMOD_reset
#     [Documentation]
#     ...    The purpose of this test case is to perform SA FR2 8cc peak test, for 8cc DL
#     [Tags]     CIT_TRUNK    CB009467
#     ABC
#     [Setup]
# 
# 
# 
# 
# *** Keywords ***
# ABC
#     FOR    ${ID}    IN RANGE    0    100
#         Check onair and alarm
#     END
# 
# Check onair and alarm
#     [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     Reset BBMOD
#     Check GNB on air_debug    bts_host=${bts_host}
#     Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Reset BBMOD
#     [Arguments]      ${connection}=GNB_OAM    ${bts_host}=${gnb_ip}
# #    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     Log To Console    Reset BBMOD
#     coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    reset_type=Warm    force_radio_reset=${True}
#     ...    timeout=600s    connection=${connection}
#     sleep    3s
# 
# 
# 
# 
# 
