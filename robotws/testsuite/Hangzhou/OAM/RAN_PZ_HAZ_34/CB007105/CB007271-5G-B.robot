# *** Settings ***
# Documentation
# ...   author: fred li
# ...   contact: fred.li@nokia-sbell.com
# 
# Resource   .${/}resources${/}common.robot
# Resource   ..${/}common${/}L3_Call.robot
# Resource   ..${/}common${/}collect_log.robot
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_RRM         CRT_22R3
# ...    PY36
# 
# Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# #${ue_type}    huawei
# &{ue_0}   cell_index=2   abil_index=1
# &{ue_1}   cell_index=5   abil_index=3
# ${Send_Tput_DL}      100M
# ${Expect_Tput_DL}      10
# ${traffic_duration}        60
# 
# *** Test Cases ***
# [1]CB007105_008_Enable_Cellslot_pooling_with_FDD_3S_1CC_30MHz_configuration_ABIN
#     [Timeout]    2h
#     Case Setup
# #    Import SCF by Custom   local_path=${CURDIR}/resources/SCF/7271-B/FDD_3S1CC.xml
#     Import SCF by Custom
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL873_3S1CC_${scfname}.xml
#     Data Transfer Conducted
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007105_010_Enable_Cellslot_pooling_with_FDD_3S_2CC_configuration_ABIN
#     [Timeout]    2h
#     Case Setup
# #    Import SCF by Custom   local_path=${CURDIR}/resources/SCF/7271-B/FDD_3S2CC.xml
#     Import SCF by Custom
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL873_3S2CC_${scfname}.xml
#     Data Transfer Conducted
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007105_032_Enable_Cellslot_pooling_with_cell_lock_unlock_in_FDDconfiguration_ABIN
#     [Timeout]    2h
#     Case Setup
#     log to console   PASS
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007105_036_Enable_Cellslot_pooling_for_flexible_cell_addition_in_FDDconfiguration_ABIN
#     [Timeout]    3h
#     Case Setup
# #    Import SCF by Custom   local_path=${CURDIR}/resources/SCF/7271-B/FDD_3S1CC.xml
#     Import SCF by Custom
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL873_3S1CC_${scfname}.xml
#     Remove Cell 3
#     Recovery Cell   index=${3}
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007105_037_Enable_Cellslot_pooling_for_flexible_cell_deletion_in_FDDconfiguration_ABIN
#     [Timeout]    2h
#     Case Setup
#     log to console    Pass
#     [Teardown]   Case Teardown
# 
# 
# [1]CB007105_038_Enable_Cellslot_pooling_for_flexible_cell_addition_with_different_instance_type_ABIN
#     [Timeout]    3h
#     Case Setup
#     log to console    Pass
# ##    Import SCF by Custom   local_path=${CURDIR}/resources/SCF/7271-B/FDD_3S1CC.xml
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL873_3S1CC_${scfname}.xml
# #    Remove Cell 3
# #    Recovery Cell   index=${3}
# #    selenium_coam.set_parameter_value     dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
# #    ...   filter_param=Channel bandwidth    new_value=20MHz
# #    Run Keyword And Ignore Error   selenium_coam.validate_plan
# #    sleep  5s
# #    Run Keyword And Ignore Error   selenium_coam.activate_plan   activate_plan_despite_errors=True
# #    sleep  5m
#     [Teardown]   Case Teardown
# 
# CB007105_Enable_Cellslot_pooling_ABIN
#     List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
