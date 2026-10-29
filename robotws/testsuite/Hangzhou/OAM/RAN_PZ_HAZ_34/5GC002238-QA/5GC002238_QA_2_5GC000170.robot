# # #*** Settings ***
# # #Force Tags    PY36
# # #Suite Setup
# # #Suite Teardown
# # #Documentation
# # #...   author: xiaofeng.1.zhu@nokia-sbell.com
# # #...   contact: xiaofeng.1.zhu@nokia-sbell.com
# # #
# # #Resource          Resources/common_keyword.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Library           Resources/common_keyword.py
# # #
# # #*** Variables ***
# # #${filename}         FRIps.txt
# # #${epc_log_path}     /tmp
# # #${epc_log_path_1}     /ffs/run/config/
# # #${TS_CASE_LOG_PATH}    ${output_dir}
# # #${asik_alias}   ASIK Master
# # #${container_alias}   Container
# # #${ru_alias}   RU
# # #${startup_BTSOM}   startup_BTSOM.log
# # #${alarm_4383}    FaultId: 4383
# # #${alarm_7101}    larmNumber: 7101
# # #
# # #*** Test Cases ***
# # #[1]5GC002238_QA_1_5GC000170_ASOD_recovery_scenarios_for_SMOD_failure
# # #    [Documentation]    this case is to verify asod recovery function after smod failure
# # #    [Tags]     5GC002238-QA    CRT_20B
# # #    [Setup]   Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# # #    Reboot DU and Check cell onAir
# # #    Connection to Du making alarm
# # #    Connection to web and check cell onAir
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
# # #[1]5GC002238_QA_2_5GC000170_RMOD_unit_recovery
# # #    [Documentation]    this case is to verify Rmod recovery function
# # #    [Tags]     5GC002238-QA    CRT_20B
# # #    [Setup]   Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# # #    RMOD_unit_recovery
# # #    [Teardown]    CI_interface.Common Case Teardown
# # 
# # 
