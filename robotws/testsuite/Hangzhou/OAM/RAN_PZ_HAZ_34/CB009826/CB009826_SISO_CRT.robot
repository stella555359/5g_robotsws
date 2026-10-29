*** Settings ***
Documentation
    ...    Author: casbo.xing@nokia-sbell.com
    ...    to define SG07 COMMON SISO Cased

#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/COAM.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource     Resource/9826_fallback_common.robot

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown

*** Variables ***
${ue_index}   0
${dl_tp_ratio}   0.1
${ul_tp_ratio}  0.1
${peak_tp_dl}   400
${peak_tp_ul}   220.8
${duration}     180
@{L3CALL_CELLID_LIST}    506   403

*** Test Cases ***
CB009826_A_SISO_CRT
    [Setup]    Case Setup: CB009826_SISO_CRT
    run keyword and continue on failure   CB009826_siso_1_common_bbmod_Lock_Unlock
    run keyword and continue on failure   CB009826_siso_2_common_rat_reset
    run keyword and continue on failure   CB009826_siso_4_common_bbmod_reset
#    run keyword and continue on failure    CB009826_siso_5_common_l3call
    [Teardown]  Case Teardown: CB009826_SISO_CRT


*** Keywords ***
CB009826_siso_1_common_bbmod_Lock_Unlock
   [Timeout]  4h
   Case Setup:siso_common_bbmod_Lock_Unlock
   FOR   ${index}    IN RANGE    ${3}
       log to console     //this is index：${index} time do All BBMODs Lock UnLock...
       Run Keyword And Ignore Error   COAM Login
       All BBMODs Lock UnLock
    END
    [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:siso_common_bbmod_Lock_Unlock

CB009826_siso_2_common_rat_reset
   [Timeout]  4h
   Case Setup:siso_common_rat_reset
   AlarmWatchdog.add_allow_alarms    fault_id=7107
   FOR   ${index}    IN RANGE    ${3}
       log to console     //this is index：${index} time do All RAT Reset...
       All RAT Reset
    END
    [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:siso_common_rat_reset

CB009826_siso_3_common_site_reset_without_hwf
   [Timeout]  24h
   Case Setup:siso_common_site_reset_without_hwf
   FOR   ${index}    IN RANGE    ${10}
       Log To Console   //TODO: COAM Reset Site index：${index} time
       Single Site Reset
   END
   [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:siso_common_site_reset_without_hwf

CB009826_siso_4_common_bbmod_reset
   [Timeout]  4h
   Case Setup:siso_common_bbmod_reset
   FOR   ${index}    IN RANGE    ${3}
       log to console     //this is index：${index} time do All BBMODs Reset...
       Run Keyword And Ignore Error   COAM Login
       All BBMODs Reset
    END
    [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:siso_common_bbmod_reset

CB009826_siso_5_common_l3call
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing l3call on AVQL(NSA)
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.08.2024 - Case Draft
    ...    Author: casbo.xing@nokia-sbell.com
    [Timeout]  2h
    Case Setup:L3call     x2_enb_mrbtsId=293    gnbmode=NSA
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    Start Capture Wireshark at gNB    nglogname=axis_0
    Wait Until Keyword Succeeds   2x   15mins   L3 CALL Process     L3CALL_CELLID_list=${L3CALL_CELLID_list}
    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_0
    [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:L3call

Case Setup:siso_common_rat_reset
    wait until keyword succeeds   3x   10s   COAM Login
    ${btsinfo}     COAM Get BTS Info
#    ${cells_info}     Get Dictionary Values    ${btsinfo['cells']}
    ${rat_list}     Create List
    FOR    ${rat}    IN    @{btsinfo['cells']}
        ${isempty}     run keyword and return status     should be empty    ${btsinfo['cells']['${rat}']}
        continue for loop if     ${isempty}
        Append to list     ${rat_list}     ${rat}
     END
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     Set test variable     ${rat_list}
     Set test variable     ${nr_cell_list}
     Set test variable     ${lte_cell_list}
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Setup:siso_common_bbmod_reset
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair

Case Teardown:siso_common_bbmod_reset
    return from keyword if    len(${bbmod_cell_mapping})==${0}
#    Siso Common Save Logs
    Run Keyword And Ignore Error    COAM Login
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
    Run Keyword And Ignore Error   COAM Logout

Case Teardown:siso_common_rat_reset
#    Siso Common Save Logs
    Run Keyword And Ignore Error    COAM Login
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    Run Keyword And Ignore Error    COAM Logout

Case Setup:siso_common_bbmod_Lock_Unlock
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${siso_scf_xml}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${siso_scf_xml}
    coam login
    ${bbmods_info}     Get BBMODs info
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
    run keyword and ignore error  coam logout

Case Teardown:siso_common_bbmod_Lock_Unlock
    return from keyword if    len(${bbmod_cell_mapping})==${0}
#    Siso Common Save Logs
    FOR     ${bbmod}     IN     @{bbmods_info}
        run keyword and ignore error    COAM Unlock BBMOD      dist_name=${bbmod['internal']}
    END
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
    Run Keyword And Ignore Error   COAM Logout

Case Setup:siso_common_site_reset_without_hwf
    Add HWF Flag at swconfig
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    Run Keyword And Ignore Error   COAM Logout

Case Teardown:siso_common_site_reset_without_hwf
#    Siso Common Save Logs
#    run keyword if test failed    sleep    10min
#    run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
    Remove HWF Flag at swconfig
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    Run Keyword And Ignore Error   COAM Logout

Single Site Reset
    Start Syslog Collection
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    [Teardown]     Run Keywords    Siso Common Each Time Teardown
    ...   AND   Run Keyword And Ignore Error   COAM Log

Case Setup: CB009826_SISO_CRT
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    run keyword and ignore error    check Faults for siso common    allowedfault_list=${final_FAULT_allowed}

Case Teardown: CB009826_SISO_CRT
    Run Keyword If Test Failed    Run Keyword And Ignore Error   Save Logs If Case Failed
    robot_common_operations.Common Case Teardown

Case Setup:L3call
    [Arguments]    ${x2_enb_mrbtsId}=default   ${gnbmode}=NSA
    Wait Until Keyword Succeeds    5min    20s      COAM WEBUI Login
    wait until keyword succeeds    15min    1min   Check onair and x2 meantime    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}

Case Teardown:L3call
    run keyword and ignore error    COAM WEBUI Logout
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_0
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_1

L3 CALL Process
    [Arguments]     ${L3CALL_CELLID_list}
    Block other cells except L3CALL   l3call_cell_list=${L3CALL_CELLID_list}
    ${dl_expect_custom}    evaluate    ${peak_tp_dl}*${dl_tp_ratio}
    ${ul_expect_custom}    evaluate    ${peak_tp_ul}*${ul_tp_ratio}
    ${dl_expect}    ${ul_expect}   set variable   ${dl_expect_custom}  ${ul_expect_custom}
    ${Send_Tput_DL}   set variable   ${peak_tp_dl}
    ${send_tp_ul}     evaluate    ${peak_tp_ul}*5
    ${Send_Tput_UL}   set variable   ${send_tp_ul}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    wait until keyword succeeds   3x    20s  Call Setup and check tput  method=PEAK
    ...   tput=${Send_Tput_DL}   tput_expect=${dl_expect}
    ...   peak_ul=${Send_Tput_UL}   ul_expect=${ul_expect}
    ...   duration=${duration}
    [Teardown]    UnBlock other cells except L3CALL     l3call_cell_list=${L3CALL_CELLID_list}
