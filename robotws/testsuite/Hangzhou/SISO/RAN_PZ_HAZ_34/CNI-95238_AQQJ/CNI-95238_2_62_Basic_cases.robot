# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# #Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
# 
# Force Tags
# 
# *** Variables ***
# #${if_commissioning}    False
# ${loop_times}    1
# ${reset_number}    1
# ${reset_timeout}    ${reset_number}h
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_2_5G_RAT_Reset
#     [Documentation]    To check Cell on air after reset NR without any unexpected faults
#     [Tags]
#     [Timeout]    ${reset_timeout}
#     FOR    ${index}    IN RANGE    0    ${reset_number}
#         5G_RAT_Reset
#     END
# 
# #[1]Rjio_E2E_02_Power_Reset_Site
# 	#[Documentation]
#     #[Tags]
#     #[Timeout]    ${reset_timeout}
# 	#FOR   ${index}   IN RANGE    0    ${reset_number}
#         #General_BTS_startup_management
#     #END
# 
# #[1]Rjio_E2E_04_Site_Reset
#     #[Documentation]    To check Cell on air after site reset without any unexpected faults
#     #[Tags]
#     #[Timeout]    ${reset_timeout}
#     #FOR   ${index}   IN RANGE    0    ${reset_number}
#         #5G_Site_Reset
#    # END
# 
# [1]Rjio_E2E_06_Cell_Block_Unblock
#     [Documentation]
#     ...    Rjio_E2E_06_Cell_Block_Unblock.
#     [Tags]
#     [Timeout]    2h
#     FOR   ${index}   IN RANGE   ${loop_times}
#         Rjjo_Cell_block_and_unblock_gNB
#     END
# 
# [1]Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
#     [Documentation]
#     ...    Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock.
#     [Tags]
#     [Timeout]    2h
#     FOR   ${index}   IN RANGE   ${loop_times}
#         Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
#     END
# 
# 
# #[1]Rjio_AQQJ_13_Activation_of_5G_Energy_Saving_Features
#     #[Documentation]
#     #...    Rjio_AQQJ_13_Activation_of_5G_Energy_Saving_Features.
#     #[Tags]
#     #[Timeout]    1h
#     #[Setup]    SISO Coam Test Setup
#        # @{split_version}    string.split string    ${Active_SW_version}    separator=_
#        # ${stream}    set variable     @{split_version}[0]
#        # Selenium Login And Disable Screen Lock    version=${stream}
#        # Close Start Up View    timeout=60
# 
#        # log to console   ***Modify parameter true***
#        # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
#        # ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
#        # sleep  300s
# 
#         #${rf_power_with_ture}    create list
#         #${rf_power_with_false}    create list
#         #Set Test Variable     ${rf_power_with_ture}
#        # Set Test Variable     ${rf_power_with_false}
# 
#        # log to console   ***Get RMOD power measurement***
#         #FOR    ${ru_index}    IN RANGE   1    4
#                #${rf_power_with_ture}    Get_RF_Power_True    ru_index=${ru_index}
#               # Set Test Variable     ${rf_power_with_ture}
#               # sleep    3s
#         #END
# 
#         #log to console   ***Modify parameter false***
#         #Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
#        # ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=false
#        # sleep  300s
# 
#         #log to console   ***Get RMOD power measurement***
#        # FOR    ${ru_index}    IN RANGE   1    4
#               # ${rf_power_with_false}    Get_RF_Power_False    ru_index=${ru_index}
#               # Set Test Variable     ${rf_power_with_false}
#              #  sleep    3s
#         #END
# 
#        # log to console   ***Check power saving***
#        # FOR    ${ru_index}    IN RANGE   1    4
#               # Check_5G_Energy_Saving_Features    ru_index=${ru_index}
#         #END
# 
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# *** Keywords ***
# 5G_RAT_Reset
#     sleep    5s
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.reset_nr
#     sleep    180s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]    Selenium Logout And Close Browser
# 
# 5G_Site_Reset
#     sleep    5s
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Perform BTS Site Reset On WebUI
#     sleep    60s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]    Selenium Logout And Close Browser
# 
# Rjio_E2E_62_Parallel_Operation_Cell_Block_And_RU_Lock_Unlock
#     [Arguments]    ${RU_idx}=${1}
#     log to console    ++++ start block cells ++++
#     Get X2 link shutdown waiting time
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     ${cell_id_list}  Get All Cell Id
#     ${cell_num}    get length  ${cell_id_list}
#     Block cells and check status    block_list=${cell_id_list}    gnb_type='${gNb_CuType}'
#     Selenium Logout And Close Browser
#     log to console    ++++ start lock RU ++++
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.lock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     log to console    ++++ start unlock RU ++++
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.unlock_ru    ru_index=${RU_idx}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     log to console    ++++ start unblock cells ++++
#     UnBlock Cells and check status    block_list=${cell_id_list}    gnb_type='${gNb_CuType}'
#     Wait until keyword succeeds    10min    30s    verify all cells should be onair
# 
# Rjjo_Cell_block_and_unblock_gNB
#     Get X2 link shutdown waiting time
#     Selenium Login And Disable Screen Lock
#     ${cell_id_list}  Get All Cell Id
#     ${cell_num}    get length  ${cell_id_list}
#     ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
#     FOR  ${block_id}  IN  @{cell_id_list}
#         ${operate_list}    create list    ${block_id}
#         Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#         UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#     END
#     run keyword if  ${cell_num}>1    Block and UnBlock Cells    block_list=${cell_id_list}
#     [Teardown]   Selenium Logout And Close Browser
# 
# #Check_5G_Energy_Saving_Features
#     #[Arguments]    ${ru_index}=1
#     #${p_value}    Evaluate
#     #...    "%.3f" % ((${rf_power_with_false[${ru_index}-1]}-${rf_power_with_ture[${ru_index}-1]})/${rf_power_with_false[${ru_index}-1]})
#     #${per_value}    Evaluate    ${p_value}*100
#     #log to console   \n Power Saving Percent:${per_value}%
#     #Run Keyword And Continue On Failure    should be true      ${per_value} > 0.1
#     #sleep    3s
# 
# #Get_RF_Power_True
#     #[Arguments]    ${ru_index}=1
#      #${rf_power}    get_ru_info    ru_index=${ru_index}
#      #${rf_power['Power']}    Get Regexp Matches    ${rf_power['Power']}    ((\\d+))    1
#     # ${rf_power}    Set Variable    ${rf_power['Power']}
#     # ${rf_power}    Catenate    SEPARATOR=${EMPTY}    @{rf_power}
#     # ${rf_power}    Convert To String    ${rf_power}
#      #${rf_power}    Convert To Number    ${rf_power}
#     # Append to list    ${rf_power_with_ture}    ${rf_power}
#      #log    ${rf_power_with_ture}
#      #[Return]    ${rf_power_with_ture}
# 
# #Get_RF_Power_False
#     #[Arguments]    ${ru_index}=1
#      #${rf_power}    get_ru_info    ru_index=${ru_index}
#      #${rf_power['Power']}    Get Regexp Matches    ${rf_power['Power']}    ((\\d+))    1
#      #${rf_power}    Set Variable    ${rf_power['Power']}
#      #${rf_power}    Catenate    SEPARATOR=${EMPTY}    @{rf_power}
#      #${rf_power}    Convert To String    ${rf_power}
#      #${rf_power}    Convert To Number    ${rf_power}
#      #Append to list    ${rf_power_with_false}    ${rf_power}
#      #log    ${rf_power_with_false}
#      #[Return]    ${rf_power_with_false}
