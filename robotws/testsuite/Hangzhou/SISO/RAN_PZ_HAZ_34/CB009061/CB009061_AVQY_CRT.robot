*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        robot_common_operations.Common Case Setup    allowed_faults_ids=7300    fail_with_alarms=${False}
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009061/Resource/CB009061_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009061/Resource/CB009061.py
#Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009061/Resource/TLConfigration.py

Documentation
...    Author:yuanyuan Liu
...    contact:yuanyuan.liu@nokia-sbell.com
...    squad group:HAZ3_SG3
...    Feature CB009061  AVQY in trunk program

Force Tags        5G_RAN   PY310

*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${REFERENCE_CONFIGURATION_ID}    CNF_5G_3

*** Test Cases ***
[1]CB009061_classical_07_12759_I_B1_4CC_Basic_l3call_with_data_transfer
    [Tags]    CRT_TRUNK
    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    ${commission_status}    Run Keyword And Return Status
    ...    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}_4CC.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
    Run Keyword If    '${commission_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Should Be True    ${commission_status}    msg=SCF commissioning failed
    ${onair_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword If    '${onair_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Should Be True    ${onair_status}    msg=Cells failed to come onair after commissioning
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
    [Teardown]    robot_common_operations.Common Case Teardown



[1]CB009061_classical_37_SISO_SM_KPI51a_RU_reset_downtime_KPI54_power-on_RU_startup_availability
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${prepare_status}    Run Keyword And Return Status    Case Preparation
    Run Keyword If    '${prepare_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Should Be True    ${prepare_status}    msg=Case preparation failed
    Connect to gnb coam via ssl
    ${reset_status}    Run Keyword And Return Status
    ...    Run Keyword And Continue On Failure      TC.reset_RMOD_loop
    ...    repeat_times=${30}
    ...    KPI51A_MAX=${500}
    ...    fail_loop_max=${3}
    Run Keyword If    '${reset_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    ${power_reset_status}    Run Keyword And Return Status
    ...    Run Keyword And Continue On Failure      TC.power_reset_RMOD_loop
    ...    repeat_times=${30}
    ...    KPI54A_MAX=${500}
    ...    fail_loop_max=${3}
    Run Keyword If    '${power_reset_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    [Teardown]    robot_common_operations.Common Case Teardown

[1]CB009061_classical_38_SISO_SM_KPI17_cell_block_unblock_duration
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${prepare_status}    Run Keyword And Return Status    Case Preparation
    Run Keyword If    '${prepare_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Should Be True    ${prepare_status}    msg=Case preparation failed
    Connect to gnb coam via ssl
    ${block_unblock_status}    Run Keyword And Return Status
    ...    Run Keyword And Continue On Failure      TC.block_unblock_cell_loop
	...    repeat_times=${50}
    ...    KPI17A_MAX=${50}
    ...    KPI17B_MAX=${50}
    ...    fail_loop_max=${3}
    Run Keyword If    '${block_unblock_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    [Teardown]    robot_common_operations.Common Case Teardown


[1]CB009061_classical_39_SISO_SM_KPI5_capacity_module_reset_KPI1a_manual_site_reset_downtime
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    AlarmWatchdog.add_allow_alarms    fault_id=6134
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    ${prepare_status}    Run Keyword And Return Status    Case Preparation
    Run Keyword If    '${prepare_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Should Be True    ${prepare_status}    msg=Case preparation failed
    ${bbmod_reset_status}    Run Keyword And Return Status
    ...    Run Keyword And Continue On Failure      TC.reset_all_BBMOD_loop
    ...    KPI5_MAX=${400}
    ...    repeat_times=${30}
    ...    fail_loop_max=${3}
    ...    reset_type=Warm
    Run Keyword If    '${bbmod_reset_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    Connect to gnb coam via ssl
    ${site_reset_status}    Run Keyword And Return Status
    ...    Run Keyword And Continue On Failure      TC.reset_site_loop
    ...    repeat_times=${30}
    ...    KPI1a_MAX=${550}
    ...    fail_loop_max=${3}
    Run Keyword If    '${site_reset_status}'=='False'
    ...    Run Keyword And Ignore Error    WEBUI.Collect snapshot
    [Teardown]    robot_common_operations.Common Case Teardown
