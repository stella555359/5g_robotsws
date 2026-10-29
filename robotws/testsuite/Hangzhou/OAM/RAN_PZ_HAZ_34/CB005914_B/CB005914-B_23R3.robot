# *** Settings ***
# Documentation
# ...  author: Han Ruiyu
# ...  contact: ruiyu.han@nokia-sbell.com
# 
# Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005914_B/Resource/common.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...   SBTS00
# ...   AUTHOR_ruiyu.han@nokia-sbell.com
# 
# Test Timeout   10h
# 
# Suite Setup   Suite Setup CB005914-B
# Suite Teardown   Suite Teardown CB005914-B
# 
# *** Variables ***
# ${cell_index}   2
# ${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}
# ${DEBUG}   false
# 
# 
# *** Test Cases ***
# [1]full_commissionings_to_normal_cells
#     [Timeout]   2h
#     [Setup]     Case Setup for 5914
#     wait until keyword succeeds   3x   30s    Import SCF by Custom for 5914
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_T099_5914.xml
#     [Teardown]   Case Teardown for 5914
# 
# [1]CB005914-B_001_IQ_Data_Manually_Collect_by_L1high_Uplink_Suspicious_Event_from_MADE2_mMIMO
#      [Documentation]   ruiyu.han@nokia-sbell.com
#      [Timeout]    1h
#      [Setup]    Case Setup CB005914-B
#      Wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=1
#      ADMIN Check NR Cell Status    cell_index=2
#      Webem Config RU iq Capture    cellid=2
#      run keyword and ignore error   Data Transfer Conducted
#      wait until keyword succeeds   10min    30s    Fault With Alarm Should Be Present
#      ...   FaultID=8101    AlarmID=7115
#      Catch Snapshot COAM    local_file_path=${OUTPUT_DIR}/snapshot_AQQK.zip
#      decode snapshot and check iq data file    snapshot_path=${OUTPUT_DIR}/snapshot_AQQK.zip
#      23R3 decode snapshot and check bin file    snapshot_path=${OUTPUT_DIR}/snapshot_AQQK.zip   runame=AQQK    cellid=2
#      Wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status    cell_index=1
#      Wait Until Keyword Succeeds   2min   20s    ADMIN check NR cell status    cell_index=1
#      Wait Until Keyword Succeeds   2min   20s    ADMIN check NR cell status    cell_index=2
#      [Teardown]      Case Teardown CB005914-B
# 
# [1]CB005914-B_008_IQ_Data_Manually_Collect_by_L1high_Uplink_Suspicious_Event_from_MADE2_8TRX
#      [Documentation]   ruiyu.han@nokia-sbell.com
#      [Timeout]    1h    
#      [Setup]    Case Setup CB005914-B
#      Wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=2
#      ADMIN Check NR Cell Status    cell_index=1
# #     ADMIN Config RU iq Capture    cellid=1
#      Webem Config RU iq Capture    cellid=1
#      Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted    direction=UL
#      wait until keyword succeeds   10min    30s    Fault With Alarm Should Be Present
#      ...   FaultID=8101    AlarmID=7115
#      Catch Snapshot COAM    local_file_path=${OUTPUT_DIR}/snapshot_AKQJ.zip
#      decode snapshot and check iq data file    snapshot_path=${OUTPUT_DIR}/snapshot_AKQJ.zip
#      23R3 decode snapshot and check bin file    snapshot_path=${OUTPUT_DIR}/snapshot_AKQJ.zip    cellid=2
#      Wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status   cell_index=2
#      Wait Until Keyword Succeeds   2min   20s    ADMIN check NR cell status    cell_index=1
#      Wait Until Keyword Succeeds   2min   20s    ADMIN check NR cell status    cell_index=2
#      [Teardown]      Case Teardown CB005914-B
# 
