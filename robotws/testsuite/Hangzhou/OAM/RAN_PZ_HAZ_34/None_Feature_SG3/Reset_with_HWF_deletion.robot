*** Settings ***
Documentation    Author: jack.zeng@nokia-sbell.com
Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
...            SG3_TMO_common_keywords.TMO_Common_Suite_Setup
#Suite Setup       cOAM Common Suite Setup
Suite Teardown     Run Keywords    robot_common_operations.Common Suite Teardown    AND
...            Run Keyword If Any Tests Failed     Common Suite Teardown for UUF
##...            CI_interface.Common Case Teardown
##Test Teardown   Run Keywords    robot_common_operations.Common Case Teardown     AND
##...         Common Case Teardown    is_save_snapshot=True
Force Tags    5G_UUF    SG_03
Test Timeout      10000 minutes
Resource          ../common/coam_resource.robot
Resource          Resource/common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot

*** Variables ***
@{allow_fault_list}    62003    7311    7307    7107    8000     7331    4589    6261
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/SCF_file/

*** Test Cases ***
[1][1.0] E2E_Reset_with_HWF_deletion
    [Documentation]    author: jack.zeng@nokia-sbell.com
    [Timeout]    10000min
    [Setup]    test_case_setup    allowed_faults_ids=62003,7311,7307,7107,8000,7331
    [Tags]    OWNER_jack.zeng@nokia-sbell.com   CRT_23R2    CRT_TRUNK    CRT_23R3   CRT_22R3   CRT_22R4   SBTS00
#    Set Test Variable    ${test_round}    5
#    FOR    ${count}    IN RANGE    ${test_round}
#          Run Keyword And Continue On Failure    Reset_with_HWF_deletion
#    END
#    SWM supports provision SW build package via WebUI
#    step7:logout webui
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Set Test Variable    ${test_round2}    1
    FOR    ${count}    IN RANGE    ${test_round2}
          Run Keyword And Continue On Failure    Reset_with_HWF_deletion
    END
#    Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
#    step7:logout webui
    [Teardown]     Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword If Test Failed     Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}

[1]E2E_Reset_with_HWF_deletion_TL357
    [Documentation]    author: jack.zeng@nokia-sbell.com
    [Timeout]    10000min
    [Setup]    test_case_setup    allowed_faults_ids=62003,7311,7307,7107,8000,7331
    [Tags]    OWNER_jack.zeng@nokia-sbell.com   CRT_23R2    CRT_TRUNK    CRT_23R3   CRT_22R3   CRT_22R4   SBTS00
#    Set Test Variable    ${test_round}    5
#    FOR    ${count}    IN RANGE    ${test_round}
#          Run Keyword And Continue On Failure    Reset_with_HWF_deletion
#    END
#    SWM supports provision SW build package via WebUI
#    step7:logout webui
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Set Test Variable    ${test_round2}    1
    FOR    ${count}    IN RANGE    ${test_round2}
          Run Keyword And Continue On Failure    Reset_with_HWF_deletion
    END
#    Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
#    step7:logout webui
    [Teardown]     Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword If Test Failed     Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}

*** Keywords ***
Reset_with_HWF_deletion
#        ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
        Set Test Variable    ${test_result}    ${False}
#        Modify UUF Swconfig File   para_update=${swconfig_list}
#        run keyword and ignore error    COAM Teardown gnb connections
        Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
#       start btslog capture  name=btslog
        coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM    graceful_cell_shutdown=${False}
        sleep   5min
        Verify TMO Gnb Ready And All Cell On Air
#       stop btslog and collect logs   status=FAIL
#       ${bts_log_path}=   set variable   ${TS_CASE_LOG_PATH}/btslog/syslog_files.tgz
#       Check_btslog_After_Reset   log_path=${bts_log_path}
        Check_UUF_gNB_Startup_log
        Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_UUF}
        #Wait Until Keyword Succeeds    20 min    60 sec   Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_UUF}
#        Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
#        Run Keyword If   '${enb_length}'!='${0}'  coam.reset_site    connection=enblte_0
#        Run Keyword If   '${enb_length}'!='${0}'  sleep   5min
#        Run Keyword If   '${enb_length}'!='${0}'  Wait until keyword succeeds    10 min    60 sec
#                            ...             Verify Enb All Cell On Air    enb_index=${0}
#        Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
#        Run Keyword If   '${enb_length}'!='${0}'  Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_UUF}  connection=enblte_0
#        Run Keyword If   '${enb_length}'!='${0}'  Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_UUF}  connection=enblte_0
#        Run Keyword If   '${enb_length}'!='${1}'  Connect to eNB via ssl   enb_index=${1}  connection=enblte_1
#        Run Keyword If   '${enb_length}'!='${1}'  coam.reset_site    connection=enblte_1
#        Run Keyword If   '${enb_length}'!='${1}'  sleep   5min
#        Run Keyword If   '${enb_length}'!='${1}'  Wait until keyword succeeds    10 min    60 sec
#                            ...             Verify Enb All Cell On Air    enb_index=${1}
#        Run Keyword If   '${enb_length}'!='${1}'  Connect to eNB via ssl   enb_index=${1}  connection=enblte_1
#        Run Keyword If   '${enb_length}'!='${1}'  Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_UUF}  connection=enblte_1
#        Run Keyword If   '${enb_length}'!='${1}'  Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_UUF}  connection=enblte_1
#        UUF_Sleep_cell_check.Adjust gNB_RU Attenuation for L3_call
#        UUF_Sleep_cell_check.Start_L3_call_and_check_Tput
        Set Test Variable    ${test_result}    ${True}
        #[Teardown]     Run Keyword Unless    ${test_result}     Common Suite Teardown for UUF
