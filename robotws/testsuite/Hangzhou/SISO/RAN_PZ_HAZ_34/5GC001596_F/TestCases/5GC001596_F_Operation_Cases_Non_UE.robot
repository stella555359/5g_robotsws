# *** Settings ***
# Resource    ../Resources/5GC001596_F_Keywords.robot
# 
# Documentation
# ...   author: Cui Lingxue
# ...   contact: lingxue.cui@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags      5G_SISO         7.1816  0.816  1596
# ...    PY36
# 
# Suite Setup     Suite preparation
# 
# Suite Teardown  Run Keyword And Ignore Error    Suite env recovery
# 
# *** Test Cases ***
# [1]5GC001596_F_004_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Tags]    CRT_19B    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    author: Liu Zheng
#     [Setup]    Case preparation with btslog collection    if_create_ru_alias_needed=${True}
#     1596_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for bts reset
# 
# #[1]5GC001596_F_003_BTS_Commissioning_several_times
# #    [Tags]    CRT_19B    CRT_20B
# #    [Documentation]    author: Liu Zheng
# #    [Setup]    Case preparation with btslog collection
# #    1596_BTS_Commissioning_several_times
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection
# 
# [1]5GC001596_F_005_General_SiSo_RF_module_reset_from_GUI
#     [Tags]    CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_TRUNK    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    author: Liu Zheng
#     [Setup]    Case preparation with btslog collection
#     1596_General_SiSo_RF_module_reset_from_GUI
#     [Teardown]     Run Keyword And Ignore Error    Case env recovery with btslog collection
# 
# [1]5GC001596_F_006_General_SiSo_RF_module_power_reset
#     [Tags]    CRT_19B    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Liu Zheng
#     [Setup]    Case preparation with btslog collection
#     1596_General_SiSo_RF_module_power_reset
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection    operation=ru_power_on
# 
# [1]5GC001596_F_002_OAM_report_alarm_while_configuration_error
#     [Tags]    CIT_19B    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1
#     [Documentation]    Author: Liu Zheng
#     [Setup]    Case preparation with btslog collection
#     1596_OAM_report_alarm_while_configuration_error
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery for update nidd parameters
# 
# [1]5GC001596_F_014_Stability_Start-up_time_measurement_for_cell_onair
#     [Tags]    CRT_19B    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Liu Zheng
#     [Setup]    Case preparation with btslog collection
#     1596_Stability_Start-up_time_measurement_for_cell_onair
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]  Author: Liu Zheng
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     set suite variable     ${PARAMS_TO_DELETE}    ${ABIL_8CC_ABIO_0CC_DEL}
#     set suite variable     ${PARAMS_TO_MODIFY}    ${ABIL_UL2CC_MODIFY}
#     Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#     Get the ru index list and cell index list and cell group index list and set to suite variable
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${program}
#     [Teardown]    Run keyword and ignore error    Tear down all SISO connections
# 
# Case env recovery with btslog collection for bts reset
#     [Documentation]    Author: Liu Zheng
#     Wait Until Keyword Succeeds     ${RECOVERY_TIMEOUT}    20 sec    Connect to gnb coam via ssl    connection=${GNB_COAM_ALIAS}
#     Collect logs in teardown    is_btslog_required=${True}
#     Case env recovery common
# 
