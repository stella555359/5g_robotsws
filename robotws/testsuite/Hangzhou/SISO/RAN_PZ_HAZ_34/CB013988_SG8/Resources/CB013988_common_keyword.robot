*** Settings ***
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    ../lib/CB013988.py
Variables   ../TestData/CB013988_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Keywords ***
CB013988_A_01_RU_power_reset_and_mplane_reestablished
    [Arguments]    ${interval}
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_AVQC_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    log to console    step1: enable CB013988 by RD flag, then reset RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    csn.execute   command=sudo -i ccsShell.sh rad -mpw 0xc001d 0    connection=RU
    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    reset_type=Soft    timeout=400    connection=GNB_OAM
    sleep    10s
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/swconfig.txt|grep '0xc001d = 0'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    log to console    step2: rm files in RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/RecovPorLogs  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/por_executed  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/preventerResetCounter.txt  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/sw2por_counter*  connection=RU
    log to console    step3: record the counter (POOR Reset Counter/BTS POOR Reset Counter/reset Counter)in BBOX5
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset Counter:'   connection=RU
    ${output}    Split String    string=${output}    separator=\r\n
    ${POOR_Reset_Counter}    ${BTS POOR Reset Counter}    ${Reset Counter}    get_counter_value    counter_list=${output}
    log to console    step4: make RU Mplane disconnect, and wait for 2h
    Selenium Login And Disable Screen Lock
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Locked
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-3/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Locked
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Locked
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    sleep    120min
    Expect Fault Should Present With Absolute Source    faultId=10    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    log to console    step5: recover the RU mplane
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Unlocked
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-3/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Unlocked
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=Unlocked
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    sleep    2min
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=10
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    sleep    30s
    log to console    step6: check BBOX5 log
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5    connection=RU
    log to console    ${output}
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Reset Reason: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Reset Cause: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Failed Service: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Reset Reason: 24 - POR'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Reset Cause: 24 - UnitEscalated'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Failed Service: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[2\\] Reset Reason: 41 - SOFT_RESET_SW_RESET_N_REQ'|wc -l
    ...    connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[2\\] Reset Cause: 3 - Unit'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[2\\] Failed Service: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset Counter:'   connection=RU
    ${output}    Split String    string=${output}    separator=\r\n
    ${POOR_Reset_Counter_after}    ${BTS POOR Reset Counter_after}    ${Reset Counter_after}    get_counter_value    counter_list=${output}
    should be true    ${POOR_Reset_Counter_after}==${POOR_Reset_Counter}+1
    should be true    ${BTS POOR Reset Counter_after}==${BTS POOR Reset Counter}
    should be true    ${Reset Counter_after}==${Reset Counter}+4
    log to console    step7: collect snapshot
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

CB013988_A_03_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT1
    [Arguments]    ${interval}
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_AVQC_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    log to console    step1: enable CB013988 by RD flag, then reset RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    csn.execute   command=sudo -i ccsShell.sh rad -mpw 0xc001d 0    connection=RU
    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    reset_type=Soft    timeout=400    connection=GNB_OAM
    sleep    10s
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/swconfig.txt|grep '0xc001d = 0'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    log to console    step2: rm files in RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/RecovPorLogs  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/por_executed  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/preventerResetCounter.txt  connection=RU
    csn.execute   command=sudo -i rm -rf /mnt/runtime/sw2por_counter*  connection=RU
    log to console    step3: record the counter (POOR Reset Counter/BTS POOR Reset Counter/reset Counter)in BBOX5
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset Counter:'   connection=RU
    ${output}    Split String    string=${output}    separator=\r\n
    ${POOR_Reset_Counter}    ${BTS POOR Reset Counter}    ${Reset Counter}    get_counter_value    counter_list=${output}
    log to console    step4: kill service to make RU reset
    ${PID}    csn.execute   command=sudo -i ps -ef | grep uoam::instance|grep -v grep|awk '{print $2}'    connection=RU
    csn.execute   command=sudo -i kill -9 ${PID}    connection=RU
    sleep    10s
    Wait until keyword succeeds    10min    5 sec    Expect Fault Should Present With Absolute Source    faultId=10
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Wait until keyword succeeds    10min    5 sec    Expect Fault Should Present With Absolute Source    faultId=4590
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    FOR    ${alarm}    IN    @{active_alarms_list}
        ${faultId}    set variable    ${alarm['additionalFaultID']}
        continue for loop if    ${faultId}!=4590
        ${faultSignature_info}    set variable    ${alarm['alarmText']['alarmAdditionalInfo']['faultSignature']['info']}
        run keyword if   ${faultId}==4590    should be equal   ${faultSignature_info}
        ...    resetCause=RecoveryReset(13),resetSignal=SOFT_RESET_SW_RESET_N_REQ(41)
    END
    Wait until keyword succeeds    20min    10 sec    Expect Fault Should Absent    faultId=10
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Wait until keyword succeeds    20min    10 sec    Expect Fault Should Absent    faultId=4590
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    log to console    step5: kill service to make RU reset again
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    ${PID}    csn.execute   command=sudo -i ps -ef | grep uoam::instance|grep -v grep|awk '{print $2}'    connection=RU
    csn.execute   command=sudo -i kill -9 ${PID}    connection=RU
    sleep    10s
    Wait until keyword succeeds    10min    5 sec    Expect Fault Should Present With Absolute Source    faultId=10
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Wait until keyword succeeds    10min    5 sec    Expect Fault Should Present With Absolute Source    faultId=4590
    ...    source=[${btsName}] MRBTS-${mrbtsID}/EQM_R-4/APEQM_R-1/RMOD_R-1
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM
    FOR    ${alarm}    IN    @{active_alarms_list}
        ${faultId}    set variable    ${alarm['additionalFaultID']}
        continue for loop if    ${faultId}!=4590
        ${faultSignature_info}    set variable    ${alarm['alarmText']['alarmAdditionalInfo']['faultSignature']['info']}
        run keyword if   ${faultId}==4590    should be equal   ${faultSignature_info}    resetCause=RecoveryReset(13),resetSignal=POR(24)
    END
    log to console    step6: check BBOX5 log
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5    connection=RU
    log to console    ${output}
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] ISTI: '|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Reset Reason: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Reset Cause: N/A'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[0\\] Failed Service: ruoam::instance1'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] ISTI: '|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Reset Reason: 41 - SOFT_RESET_SW_RESET_N_REQ'|wc -l
    ...    connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Reset Cause: 13 - RecoveryReset'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset\\[1\\] Failed Service: ruoam::instance1'|wc -l   connection=RU
    ${output}    convert to integer    ${output}
    should be true    ${output}==1
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5    connection=RU
    ${output}    Split String    string=${output}    separator=\r\n
    ${ISTI_poor_reset}    get_poor_reset_last_write_ISTI    counter_list=${output}
    ${reset_0_ISTI}    get_reset_0_ISTI    counter_list=${output}
    should be true    ${reset_0_ISTI}==${ISTI_poor_reset}
    ${output}    csn.execute   command=sudo -i cat /mnt/runtime/BBOX5|grep 'Reset Counter:'   connection=RU
    ${output}    Split String    string=${output}    separator=\r\n
    ${POOR_Reset_Counter_after}    ${BTS POOR Reset Counter_after}    ${Reset Counter_after}    get_counter_value    counter_list=${output}
    should be true    ${POOR_Reset_Counter_after}==${POOR_Reset_Counter}+1
    should be true    ${BTS POOR Reset Counter_after}==${BTS POOR Reset Counter}
    should be true    ${Reset Counter_after}==${Reset Counter}+2
    log to console    step7: collect snapshot
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Get btsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Suite Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}


Case Preparation
    log to console   \n*** set precondition: throughput counter activate ***
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_AVQC_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
    ${wait_time}    Get wait value minutes    interval=15min
    sleep    ${wait_time}min

