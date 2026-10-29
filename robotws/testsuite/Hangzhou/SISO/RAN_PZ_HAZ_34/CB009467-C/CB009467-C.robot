# *** Settings ***
# Documentation
# ...    author: Na Li
# ...    contact: na.li@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009467
# 
# 
# Suite Setup       CB009467 Suite Setup
# Suite Teardown    Run keyword and ignore error    CB009467 Suite Teardown
# 
# 
# Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009467-C/Resources/CB009467_common_keyword.robot
# 
# 
# *** Test Cases ***
# [1]CB009467_C_002_1A_FR2_with_24R1_N_CB009467_1a_configuration_Site_Reset
#     [Tags]  CRT_24R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     ATTACH SAM 2UE3RU AND CHECK THROUGHT
#     Repeat Site_Reset And Attach
#     ATTACH SAM 2UE3RU AND CHECK THROUGHT
#     [Teardown]    Run Keyword And Ignore Error    Case Teardown
# 
# [1]CB009467_C_004_1B_FR2_with_24R1_N_CB009467_1b_configuration_RF_Lock_Unlock
#     [Tags]  CRT_24R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Repeat lock_unlock_RF And Attach
#     ATTACH SAM 2UE3RU AND CHECK THROUGHT
#     [Teardown]  Run Keyword And Ignore Error    Case Teardown
# 
# [1]CB009467_C_006_1C_FR2_with_24R1_N_CB009467_1c_configuration_RF_Reset
#     [Tags]  CRT_24R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Repeat Site_RF And UE Attach
#     ATTACH SAM 2UE3RU AND CHECK THROUGHT
#     [Teardown]  Run Keyword And Ignore Error    Case Teardown
# 
# [1]CB009467_C_001_1A_FR2_with_24R1_N_CB009467_1a_configuration
#     [Tags]    CRT_24R1    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Should Be Equal As Strings  ${PREV_TEST_STATUS}  PASS
#     [Teardown]    Run Keyword And Ignore Error    Case Teardown
# 
# 
# 
# 
# *** Keywords ***
# Repeat Site_Reset And Attach
#     [Arguments]    ${times}=${3}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     FOR    ${item}  IN RANGE    0    ${times}
#         Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#         coam.reset_site    connection=${connection}
#         COAM Teardown gnb connections    connection=${connection}
#         Check GNB on air
#         Check Alarm List on BTS    allowed_list=${allowed_list}
#     END
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Repeat lock_unlock_RF And Attach
#     [Arguments]    ${times}=${3}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     FOR    ${item}  IN RANGE    0    ${times}
#         Lock or Unlock RU And Check Status    lock_RU_id_list=${RU_Id_list[0:3]}    lock_flag=${True}
#         Lock or Unlock RU And Check Status    unlock_RU_id_list=${RU_Id_list[0:3]}    lock_flag=${false}
#         Check GNB on air
#         Check Alarm List on BTS    allowed_list=${allowed_list}
#     END
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# 
# Repeat Site_RF And UE Attach
#     [Arguments]    ${times}=${3}
#     FOR    ${item}  IN RANGE    0    ${times}
#         Reset MUtiRF
#         Check GNB on air
#         Append To List   ${allowed_list}  ${10}
#         Check Alarm List on BTS    allowed_list=${allowed_list}
#     END
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Reset MUtiRF
#     [Arguments]    ${times}=${3}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     FOR    ${ru_index }  IN    @{RU_Id_list}
#         coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}   force_radio_reset=${True}
#         ...    timeout=${300}    connection=${connection}
#     END
#     COAM Teardown gnb connections    connection=${connection}
