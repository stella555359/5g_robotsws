# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   .${/}..${/}resources${/}common.robot
# Resource   ..${/}..${/}common${/}L3_Call.robot
# Resource   ..${/}..${/}common${/}collect_log.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CIT_20B
# ...    PY36
# 
# *** Variables ***
# #${ue_type}    huawei
# &{ue_0}   cell_index=2   abil_index=1
# &{ue_1}   cell_index=5   abil_index=3
# ${Send_Tput_DL}      200M
# ${Expect_Tput_DL}      50
# ${traffic_duration}        90
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB008325_CB007105_ABIP_TDD_and_FDD_reduced_config
#     [Timeout]    2h
#     [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup
#     Import SCF by Custom
#     ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_T2_F2_SA_${scfname}.xml
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_T2_F2_Both_${scfname}.xml
# #    Data Transfer Conducted
# #    Data Transfer Conducted for 8325
#     [Teardown]   Case Teardown for ABIP
# 
# [1]CB008325_CB007105_ABIP_TDD_add_delete_cell_online_reduced_config
#     [Timeout]    3h
#     [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup
#     Import SCF by Custom
#     ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_T2_F2_SA_${scfname}.xml
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_T2_F2_Both_${scfname}.xml
#     Remove Cell 2
#     Recovery Cell for multiBB   index=${2}
#     [Teardown]   Case Teardown for ABIP
# 
# #[1]CB008325_CB007105_ABIP_TDD_and_FDD_mix_config
# #    [Timeout]    2h
# #    [Setup]     Run Keywords
# #     ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
# #     ...    Case Setup
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_Mix_${scfname}.xml
# #    Data Transfer Conducted
# ##    Data Transfer Conducted for 8325
# #    [Teardown]   Case Teardown for ABIP
# #
# #[1]CB008325_CB007105_ABIP_TDD_and_FDD_mix_config2
# #    [Timeout]    2h
# #    [Setup]     Run Keywords
# #     ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
# #     ...    Case Setup
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_Mix2_${scfname}.xml
# #    Data Transfer Conducted
# ##    Data Transfer Conducted for 8325
# #    [Teardown]   Case Teardown for ABIP
# #
# #[1]CB008325_CB007105_ABIP_TDD_add_delete_cell_online
# #    [Timeout]    3h
# #    [Setup]     Run Keywords
# #     ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
# #     ...    Case Setup
# #    Import SCF by Custom
# #    ...   local_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL846_TD3S1CC_${scfname}.xml
# #    Remove Cell 3
# #    Recovery Cell   index=${3}
# #    [Teardown]   Case Teardown for ABIP
# 
# [1]CB008325_CB007105_ABIP_TDD_and_FDD_CRT
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
