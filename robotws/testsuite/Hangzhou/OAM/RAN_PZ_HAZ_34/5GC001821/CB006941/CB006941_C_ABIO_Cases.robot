# *** Settings ***
# Documentation    CB006941-C Cases Pool
# Resource   ../Resource/702.robot
# Resource   ../Resource/6941.robot
# Resource   ../Resource/coam.robot
# Resource   ../Resource/common.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource   ../Resource/1098.robot
# Resource   ../Resource/cell_block_common.robot
# Library   taf.transport.ssh   WITH NAME   csn
# Library   Collections
# Library     XML
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Force Tags   SG_07   CA_5G_Siso         CRT   AUTHOR_zhe.1.lin@nokia-sbell.com
# ...    PY36
# Suite Setup   6941 Suite Setup
# Suite Teardown   6941 Suite Teardown
# 
# *** Variables ***
# ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
# ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
# ${cell_index}   1
# ${cell_id}    1
# ${L3CALL_cellid}    1
# 
# *** Test Cases ***
# 
# [1]CB006941_5G_C_03_Fault_4606_in_ABIO
#     [Documentation]  Author: Lin Zhe
#     ...              Description: check fault 4606 in ABIO
#     [Setup]    robot_common_operations.Common Case Setup
#     Trigger and Check ABIO Fault4606
# #    Wait Until Keyword Succeeds    120 sec    5 sec    Cell Should Be Disabled    cell_idx=2    cell_group_idx=1
# #    ...    connection=COAM
#     Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
#     Data Transfer Conducted    cell_index=${cell_index}
#     [Teardown]   robot_common_operations.Common Case Teardown
# 
# 
# #CB006941_5G_C_01_SOAP_Message_ECPRI_Timing_Capability
# #    [Documentation]  Author: Lin Zhe
# #    ...              Description: check if soap message including ECPRI_TIMING_CAPABILITY-CB006941-C basic function
# #    General SiSo RU Module Reset From GUI   connection=${coam_alias}
# #    Perform RU Reset
# #    COAM WEBUI Login
# #    Wait for Cell Onair    wait_timer=10m    cell_index=${cell_index}
# #    6941.Connect to RU
# #    Collect SOAP and Check    distName_value=supportedFeature20    expected_value=ECPRI_TIMING_CAPABILITY
# #    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Case Teardown    AND    Disconnect to RU
# 
# 
