# *** Settings ***
# Documentation     Author: WangLixia
# ...               contact: Lixia.wang@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : 5GC001575_QAA. This case requires gnb is SA or both mode.
# Suite Setup       SetupSuite
# Suite Teardown    TearDownSuite
# Force Tags        RAN_5G  RAN_5G_TDD  CLOUD_5G_CLASSICAL_ASIML_ABIPB1_2xAWHQE_ENB  STATE_SW_UPLOADED  SBTS00  SBTS21B
# ...    PY36
# ...               SBTS22R1
# Resource          Resources/5GC001575_QA_Resources.robot
# Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
# 
# *** Variables ***
# ${PdcchMonOccsnPo}    First PDCCH monitoring occasion of paging occasion
# ${pdcch_wrong}     200
# ${gscn}              synchronization channel number
# ${gscn_wrong}        10000
# 
# 
# 
# *** Test Cases ***
# [1][1.0] 5GC001575_QAA_01_Cell_Recovery_from_Fault_7516_with_Manual_Locking_Unlocking_in_Classical_gNB_in_Both_Mode
#     [Documentation]  There are two scenarios. Verify fault 7516 with degrade severity and Critical.Main test Steps:
#     ...   1) Check cell is on air
#     ...   2) Online change parameter PdcchMonOccsnPo to incorrect value then check fault 7516 is raised and the severity is major
#     ...   3) Change parameter to correct value to check fault 7516 should be cancelled
#     ...   4) Change parameter gscn to incorrect value to check fault 7516 is raised and the severity is Critical
#     ...   6) Lock cell to check fault 7516 is cancelled
#     ...   7) Unlock cell to recovery cell
# 
#     [Tags]    CRT_TRUNK    CRT_20B    CRT_21A   CRT_21B    CRT_UTE    CRT_22R1
#     [Setup]    TestSetup
#     COAM_WebEM.Login
#     ${pdcch_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=${PdcchMonOccsnPo}
#      ...     node_index=${0}
#      set test variable      ${pdcch_org}
#     Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_wrong}
#     Process.Check fault 7516 is raised with expected severity    target_severity=major
#     COAM_Admin.Login
#     Cell Should Be Degraded    cell_idx=1
#     Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_org}
#     Alarm.check alarm is not in active alarms    alarm_filter=7114
#     wait until keyword succeeds   30s   10s    Cell Should Be Online    cell_idx=1
# 
# # following to test critical fault 7516
#      ${gscn_org}    COAM_WebEM.GetParameterValue      distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    abbr=${gscn}
#      set test variable      ${gscn_org}
#     Process.ChangeCellParameterToTestFault   filter_param=${gscn}    newvalue=${gscn_wrong}
#     Process.Check fault 7516 is raised with expected severity    target_severity=critical
#     Cell Should Be Failed    cell_idx=1
#     Lock Cell   cell_idx=1
#     Alarm.check alarm is not in active alarms    alarm_filter=7114
#     Process.ChangeCellParameterToTestFault   filter_param=${gscn}    newvalue=${gscn_org}
#     Unlock Cell   cell_idx=1
#     [Teardown]  Testteardown
# 
# 
# *** Keywords ***
# TestSetup
#      #Recovery Cells if locked
#      #Shorter cell activtion alarm time
#      TestCase.Start
# 
#      BtsLog.StartBTSlogCollection
# 
# 
# Testteardown
#      run keyword if test failed    Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_org}
#      run keyword if test failed    Process.ChangeCellParameterToTestFault   filter_param=${gscn}    newvalue=${gscn_org}
#      run keyword and ignore error     COAM_WebEM.Logout
#      run keyword and ignore error     COAM_Admin.Logout
#      run keyword and ignore error     BtsLog.StopBTSlogCollectionandGetlog
#      TestCase.Stop
# 
# Process.ChangeCellParameterToTestFault
#      [Arguments]    ${filter_param}   ${newvalue}
#     CM_WebEM.ModifyAndActiveListParameters    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1
#     ...   filter_param=${filter_param}   node_index=${0}    new_value=${newvalue}
# 
# Process.Check fault 7516 is raised with expected severity
#      [Arguments]   ${target_severity}=major
#     wait until keyword succeeds   2min   30s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
#     ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=${target_severity}
# 
# SetupSuite
#     log to console   SetupSuite
#     TestSuite.Start
#     run keyword and ignore error    Import Variables    ${CFGFILE_PATH}/5GC001575/Delta_SCF.py
#     GNB.FormatBTSID
#     ${stream}    Basic.GetSBTSStreamPrefix
#     ${gscn}    set variable if     '${stream}'=='SBTS21B'    Global synchronization channel number    ${gscn}
#     set suite variable     ${gscn}    ${gscn}
# TearDownSuite
#     TestSuilt.Stop