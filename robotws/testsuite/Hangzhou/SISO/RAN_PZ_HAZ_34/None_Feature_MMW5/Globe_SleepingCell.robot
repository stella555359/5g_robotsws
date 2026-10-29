*** Settings ***
Documentation     author:              Li Xudong
...               contact:             xudong.1.li@nokia-sbell.com
...               squad group:         mmW_05
...               feature :            Globe Sleeping Cell
...               UE:                  samsung S21+
...               DATE:                2023/2/9


Suite Setup          SISO Coam Suite Setup
Suite Teardown       MMW5 Common Suite Teardown
Test Setup           MMW5 Common Case Setup
Test Teardown        MMW5 Common Case Teardown

Force Tags      CRT_TRUNK

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/None_Feature_MMW5/SleepCells_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB007042_CB007045_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/None_Feature_MMW5/Resources/Globe_keywords_common.robot

*** Variables ***
${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
${if_commissioning}             False
${LTE_CELL212_DISTNAME}         MRBTS-${MRBTS_ID}/LNBTS-${ENB_LNBTS_ID2}/LNCEL-212
${NR_CELL402_DISTNAME}           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-402
${ru_index}                     2
${BB_index}                     2
@{OK_FaultId_LIST}              ${4654}    ${4655}    ${61524}    ${61652}    ${61649}
@{OK_FaultId_LIST_Block}        ${49}    ${4654}    ${4655}    ${61524}    ${61652}    ${61649}
@{hwf_disabled_FaultID_List}    ${4230}    ${4330}    ${4329}
${UL_TP}                       30M
${UL_TP_THRESHOLD}              1
${DL_TP}                       300M
${DL_TP_THRESHOLD}              1
${nr_cell_id}                  402
${Repeat_Times}                 3
${downTime_duration}           30
${lte_lock_or_unlock_time}          3
${nr_lock_or_unlock_time}           8
${lte_block_or_unblock_time}        3
${nr_block_or_unblock_time}         8
@{time_zone}                       (GMT+8) Asia/Taipei    (GMT+9) Asia/Tokyo    (GMT+8) Asia/Shanghai
${t_1_DELTA}                       ${CURDIR}/json/time1.json
${t_2_DELTA}                       ${CURDIR}/json/time2.json
${t_3_DELTA}                       ${CURDIR}/json/time3.json
&{dict_flags}                      0x190030=0
...                                0x4F0214=0

${Local_SW_build_path}             /home/ute/Downloads
${ENB_BUILD}
${package_link_on_web}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
${TS_CASE_LOG_PATH}       ${OUTPUT_DIR}

*** Test Cases ***
E2E_TL_RU_Reset_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    Verify Gnb Ready And All Cell On Air
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        _Reset And Check Success RF Coam    MRBTS_ID=${MRBTS_ID}    ru_index=${ru_index}    connection=GNB_OAM
        Verify Gnb Ready And All Cell On Air
        ${endTime}    Get Time    epoch
        ${RU_REST_DOWNTIME}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${RU_REST_DOWNTIME} < ${downTime_duration}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END

E2E_TL_Capacity_Module_Reset_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        _Reset And Check Success BaseBand Coam    MRBTS_ID=${MRBTS_ID}    baseband_index=${BB_index}    connection=GNB_OAM
        Verify Gnb Ready And All Cell On Air
        ${endTime}    Get Time    epoch
        ${BB_REST_DOWNTIME}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${BB_REST_DOWNTIME} < ${downTime_duration}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END

E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    @{time_list}    create list    ${t_1_DELTA}    ${t_2_DELTA}    ${t_3_DELTA}
    @{real_timeZone}    create list
    FOR    ${time_json}    IN    @{time_list}
        AlarmWatchdog.add_allow_alarms    fault_id=6327
        AlarmWatchdog.add_allow_alarms    fault_id=7319
        AlarmWatchdog.add_allow_alarms    fault_id=7300
        Delta Commission And PDL Verification Passed    delta_file=${time_json}
        ...    timeout=${1200}    connection=GNB_OAM
        ${startTime}    Get Time    epoch
        Verify Gnb Ready And All Cell On Air
        ${endTime}    Get Time    epoch
        ${result}    Collect Real Timezone    connection=GNB_OAM
        Append To List    ${real_timeZone}    ${result}
        ${REST_DOWNTIME}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${REST_DOWNTIME} < ${downTime_duration}
        AlarmWatchdog.remove_allow_alarms    fault_id=6327
        AlarmWatchdog.remove_allow_alarms    fault_id=7319
        AlarmWatchdog.remove_allow_alarms    fault_id=7300
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END
    Lists Should Be Equal    ${real_timeZone}    ${time_zone}

E2E_TL_Cell_Lock_Unlock_LTE_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        Modify Parameter On BTS With Activate
        ...    dist_name=${LTE_CELL212_DISTNAME}    parameter=administrativeState    value=locked
        ...    connection=GNB_OAM
        wait until keyword succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State bk
        ...    dist_name=${LTE_CELL212_DISTNAME}  administrative_state=Locked  operational_state=Disabled  cell_type=lte
        ${endTime}    Get Time    epoch
        ${lock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${lock_duration} < ${lte_lock_or_unlock_time}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${startTime}    Get Time    epoch
        Modify Parameter On BTS With Activate
        ...    dist_name=${LTE_CELL212_DISTNAME}    parameter=administrativeState    value=unlocked
        ...    connection=GNB_OAM
        wait until keyword succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State bk
        ...    dist_name=${LTE_CELL212_DISTNAME}    operational_state=Enabled    cell_type=lte
        ${endTime}    Get Time    epoch
        ${unlock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${unlock_duration} < ${lte_lock_or_unlock_time}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
   END
   [Teardown]  Run Keywords    Run Keyword And Ignore Error    Modify Parameter On BTS With Activate
               ...    dist_name=${LTE_CELL212_DISTNAME}    parameter=administrativeState    value=unlocked
               ...    connection=GNB_OAM
               ...    AND    robot_common_operations.Common Case Teardown
               ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        Modify Parameter On BTS With Activate
        ...    dist_name=${NR_CELL402_DISTNAME}    parameter=administrativeState    value=Locked
        ...    connection=GNB_OAM
        wait until keyword succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State bk
        ...    dist_name=${NR_CELL402_DISTNAME}   administrative_state=Locked   operational_state=Disabled   cell_type=nr
        ${endTime}    Get Time    epoch
        ${lock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${lock_duration} < ${nr_lock_or_unlock_time}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${startTime}    Get Time    epoch
        Modify Parameter On BTS With Activate
        ...    dist_name=${NR_CELL402_DISTNAME}    parameter=administrativeState    value=Unlocked
        ...    connection=GNB_OAM
        wait until keyword succeeds    5min    10s   Verify BTS Single Cell Status Is Normal State bk
        ...    dist_name=${NR_CELL402_DISTNAME}    operational_state=Enabled    cell_type=nr
        ${endTime}    Get Time    epoch
        ${unlock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${unlock_duration} < ${nr_lock_or_unlock_time}
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
   END
   [Teardown]    Run Keywords    Run Keyword And Ignore Error    Modify Parameter On BTS With Activate
                 ...    dist_name=${NR_CELL402_DISTNAME}    parameter=administrativeState    value=Unlocked
                 ...    connection=GNB_OAM
                 ...    AND    robot_common_operations.Common Case Teardown
                 ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

E2E_TL_Cell_Block_Unblock_LTE_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        AlarmWatchdog.add_allow_alarms    fault_id=49
        ${result}    coam.block_cell    dist_name=${LTE_CELL212_DISTNAME}    connection=GNB_OAM
        wait until keyword succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State bk    cell_type=lte
        ...  dist_name=${LTE_CELL212_DISTNAME}  blocking_state=Blocked  operational_state=Disabled
        wait until keyword succeeds    3x    5s    Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST_Block}     connection=GNB_OAM
        ${endTime}    Get Time    epoch
        ${block_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${block_duration} < ${lte_block_or_unblock_time}
        ${startTime}    Get Time    epoch
        ${result}    coam.unblock_cell    dist_name=${LTE_CELL212_DISTNAME}    connection=GNB_OAM
        wait until keyword succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State bk    cell_type=lte
        ...  dist_name=${LTE_CELL212_DISTNAME}  operational_state=Enabled
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${endTime}    Get Time    epoch
        ${unblock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${unblock_duration} < ${lte_block_or_unblock_time}
        AlarmWatchdog.remove_allow_alarms    fault_id=49
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    coam.unblock_cell
                  ...    dist_name=${LTE_CELL212_DISTNAME}    connection=GNB_OAM
                  ...    AND    robot_common_operations.Common Case Teardown
                  ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${startTime}    Get Time    epoch
        AlarmWatchdog.add_allow_alarms    fault_id=49
        ${result}    coam.block_cell    dist_name=${NR_CELL402_DISTNAME}    connection=GNB_OAM
        wait until keyword succeeds    10min    10s    Verify BTS Single Cell Status Is Normal State bk    cell_type=nr
        ...  dist_name=${NR_CELL402_DISTNAME}  blocking_state=Blocked  operational_state=Disabled
        wait until keyword succeeds    3x    5s    Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST_Block}     connection=GNB_OAM
        ${endTime}    Get Time    epoch
        ${block_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${block_duration} < ${nr_block_or_unblock_time}
        ${startTime}    Get Time    epoch
        ${result}    coam.unblock_cell    dist_name=${NR_CELL402_DISTNAME}    connection=GNB_OAM
        wait until keyword succeeds    10min    10s    Verify BTS Single Cell Status Is Normal State bk   cell_type=nr
        ...  dist_name=${NR_CELL402_DISTNAME}  operational_state=Enabled
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${endTime}    Get Time    epoch
        ${unblock_duration}    Evaluate    (${endTime}-${startTime})/60
        Should Be True  ${unblock_duration} < ${nr_block_or_unblock_time}
        AlarmWatchdog.remove_allow_alarms    fault_id=49
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    coam.unblock_cell
                  ...      dist_name=${NR_CELL402_DISTNAME}    connection=GNB_OAM
                  ...    AND    robot_common_operations.Common Case Teardown
                  ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

E2E_TL_Reset_with_HWF_deletion_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        Update SWCONFIG FILE On Smod    para_update=${dict_flags}
        Check Flags On Smod SWCONFIG FILE    except_dict=${dict_flags}
        ${startTime}    Get Time    epoch
        AlarmWatchdog.add_allow_alarms    fault_id=6327
        AlarmWatchdog.add_allow_alarms    fault_id=7319
        AlarmWatchdog.add_allow_alarms    fault_id=7300
        AlarmWatchdog.add_allow_alarms    fault_id=10
        Connect to gnb coam via ssl
        ${result}    coam.reset_site    wait_for_reconnection=False   connection=GNB_OAM
        sleep    5min
        Verify Gnb Ready And All Cell On Air
        ${endTime}    Get Time    epoch
        ${siteReset_duration}    Evaluate    (${endTime}-${startTime})/60
        should be true    ${siteReset_duration} < ${downTime_duration}
        Check_gNB_Startup_log
        Connect to gnb coam via ssl
        Check should not contain alarm    alarm_id=${hwf_disabled_FaultID_List}
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
    END

E2E_TL_SW_upgrade_rollback_with_sleeping_cell_check
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    FOR    ${i}    IN RANGE    ${Repeat_Times}
        ${sw_version_org}    Get Current SITE SoftWare Version
        ${SW_path}    _DownLoad Target SW to UTE    package_link=${package_link_on_web}
        ...   target_version=${ENB_BUILD}    local_path=${Local_SW_build_path}
        ${startTime}    Get Time    epoch
        AlarmWatchdog.add_allow_alarms    fault_id=6327
        AlarmWatchdog.add_allow_alarms    fault_id=7319
        AlarmWatchdog.add_allow_alarms    fault_id=7300
        AlarmWatchdog.add_allow_alarms    fault_id=62003
        ${sw_upgrade_result}    _Update SW SBTS    sw_path=${SW_path}    timeout=7200
        sleep    13min
        wait until keyword succeeds   30min  30s   _Verify Appoint CellType Cells Status Are Normal State   cell_type=nr
        wait until keyword succeeds   30min  30s   _Verify Appoint CellType Cells Status Are Normal State   cell_type=lte
        ${endTime}    Get Time    epoch
        ${siteUpdate_duration}    Evaluate    (${endTime}-${startTime})/60
        should be true    ${siteUpdate_duration} < 90
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${sw_version}    Get Active SW Version
        ${current_SW_Version}    ${steam}    Convert software version to WFT build version    ${sw_version}
        should be equal  ${current_SW_Version}    ${ENB_BUILD}
        Wait until keyword succeeds   30min  30s   COAM Check X2 link status from GNB    connection=GNB_OAM
        UE Attach And Check Throughput With Detach Bk    global_cell_id=${nr_cell_id}
        ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=NSA
        ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}
        ${sw_rollback_result}    _Rollback SW SBTS    timeout=7200
        sleep    13min
        wait until keyword succeeds   30min  30s   _Verify Appoint CellType Cells Status Are Normal State   cell_type=nr
        wait until keyword succeeds   30min  30s   _Verify Appoint CellType Cells Status Are Normal State   cell_type=lte
        Check Unexpect Alarm On Webem    OK_Alarm=${OK_FaultId_LIST}     connection=GNB_OAM
        ${sw_version}    Get Active SW Version
        ${current_SW_Version}    ${steam}    Convert software version to WFT build version    ${sw_version}
        should be equal  ${current_SW_Version}    ${sw_version_org}
    END
