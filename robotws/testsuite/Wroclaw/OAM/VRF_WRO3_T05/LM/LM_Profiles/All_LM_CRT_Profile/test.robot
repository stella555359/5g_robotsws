*** Settings ***
Documentation    Running LM CRT in one go
...              Hardcoded solution for manual run from VM

Library          DateTime
Library          OperatingSystem
Library          String
Library          BuiltIn

*** Variables ***
${NMS_LAB}              srnclab2009

*** Test Cases ***
[Tool] OAM_Changer_LM
    Run Test For Given Path    OAM_Changer_LM_v2
    ...    ${CURDIR}/../../LM_tools/LM_Clab_Setup.robot

[Tool] OAM_LM_IP_Traffic_Guard_Changer
    Run Test For Given Path    OAM_IpTrafficGuard_checker
    ...    ${CURDIR}/../../LM_tools/LM_IP_Traffic_Guard_Checker_5G_2liner.robot

[Tool] LM_Counters_Upload
    Run Test For Given Path    LM_Counters_Upload
    ...    ${CURDIR}/../../LM_tools/LM_Counters_Upload.robot

[100755] OAM_LM_CB006894_014_limitation_action_multiple_verification_Power_RM_Rel.5
    Run Test For Given Path   OAM_LM_CB006894_014_limitation_action_multiple_verification_Power_RM_Rel5
    ...    ${CURDIR}/../../100755_CRT/LM_CB006894_014_limitation_action_multiple_verification_Power_RM_Rel5.robot

[100755] OAM_LM_CB006894_015_limitation_action_multiple_BB_card_configuration
    Run Test For Given Path   OAM_LM_CB006894_015_limitation_action_multiple_BB_card_configuration
    ...    ${CURDIR}/../../100755_CRT/LM_CB006894_015_limitation_action_multiple_BB_card_configuration.robot

[100755] OAM_LM_CNI_55294_NB-IoT_License_control
    Run Test For Given Path   OAM_LM_CNI55294_NB-IoT_License_Control
    ...    ${CURDIR}/../../100755_CRT/LM_CNI55294_NB-IoT_License_Control.robot

[100755] OAM_LM_CB005983_004_Verification_alarms_of_ limitation_action_in_SRAN
    Run Test For Given Path   OAM_LM_RP001033_004_Verification_alarms_of_limitation_action_in_SRAN
    ...    ${CURDIR}/../../100755_CRT/LM_RP001033_004_Verification_alarms_of_limitation_action_in_SRAN.robot

[100755] OAM_LM_CB009753_041_5G_PM_Module_Licenses_Grant
    Run Test For Given Path   OAM_LM_CB009753_041_5G_PM_Module_Licenses_Grant
    ...    ${CURDIR}/../../100755_CRT/LM_CB009753_041_5G_PM_Module_Licenses_Grant.robot

[100755] LM_CB007425_003_LTE4759_011_012_Verification
    Run Test For Given Path   LM_CB007425_003_LTE4759_011_012_Verification
    ...    ${CURDIR}/../../100755_CRT/LM_CB007425_003_LTE4759_011_012_Verification.robot

[100755] WRO5_LM_CB006584_29_Reset_during_limitation
    Run Test For Given Path   WRO5_LM_CB006584_29_Reset_during_limitation
    ...    ${CURDIR}/../../100755_CRT/LM_CB006584_29_Reset_during_limitation.robot

[54013] OAM_LM_CB008369_001_eCPRI_7-2e_cells_counting
    Run Test For Given Path   WRO5_LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after_doing_controlled_switchover
    ...    ${CURDIR}/../../54013-8958_CRT/LM_CB008369_001_eCPRI_7-2e_cells_counting.robot

[100702] WRO5_LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after_doing_controlled_switchover
    Run Test For Given Path   WRO5_LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after_doing_controlled_switchover
    ...    ${CURDIR}/../../100702-100790_CRT/LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after.robot

[100722] OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    Run Test For Given Path   OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    ...    ${CURDIR}/../../100722_CRT/OAM_LM_CB010957_003_ASOG_FDD_5G_0-20MHz_2T2R.robot

[100729] OAM_LM_CB012512-A_001_Verification_of_SR000972_usage_and_limitation_mechanism_for_SBTS_with_NRFDD_NRTDD_1_concurrent_mode_on_ABIP
    Run Test For Given Path
    ...    OAM_LM_CB012512-A_001_Verification_of_SR000972_usage_and_limitation_mechanism_for_SBTS_with_NRFDD_NRTDD_1_concurrent_mode_on_ABIP
    ...    ${CURDIR}/../../100729_CRT/LM_CB012512-A_001_Verification_of_SR000972.robot

[100792] OAM_LM_CB006894_013_limitation_action_multiple_verification_RM_Rel.5
    Run Test For Given Path   OAM_LM_CB006894_013_limitation_action_multiple_verification_RM_Rel.5
    ...    ${CURDIR}/../../100792_CRT/LM_CB006894_013_limitation_action_multiple_verification_RM_Rel5.robot

[100797] OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    Run Test For Given Path   OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    ...    ${CURDIR}/../../100797_CRT/OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R.robot

[100855] OAM_LM_CB009753_041_5G_PM_Module_Licenses_Grant
    Run Test For Given Path   OAM_LM_CB009753_041_5G_PM_Module_Licenses_Grant
    ...    ${CURDIR}/../../100855_CRT/LM_CB009753_041_5G_PM_Module_Licenses_Grant.robot

[100855] WRO5_LM_CB008993_CB006584_006_SW_upgrade_during_limitation
    Run Test For Given Path   WRO5_LM_CB008993_CB006584_006_SW_upgrade_during_limitation
    ...    ${CURDIR}/../../100855_CRT/LM_CB008993_CB006584_006_SW_upgrade_during_limitation.robot

*** Keywords ***
Run Test For Given Path
    [Documentation]    Running test for given path
    [Arguments]    ${test_name}    ${path_to_test}
    ${current_date}=    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S    exclude_millis=True
    ${robot_command_parts}=    Set Variable    robot --variable NMS_LAB:${NMS_LAB} --variable ENB_MPLANE_IP:192.168.255.129 \
    ...    --variable RESULTS:${OUTPUT_DIR}/${current_date}_${test_name} -L TRACE -b ${OUTPUT_DIR}/${current_date}_${test_name}/debug.log \
    ...    -d ${OUTPUT_DIR}/${current_date}_${test_name}/ ${path_to_test}
    ${robot_command}=    Evaluate    ''.join(${robot_command_parts})
    ${rc}    ${output}=      Run and Return RC and Output     ${robot_command}
    Log    ${output}    console=true
    Log    ${rc}    console=true
    Should Be Equal As Integers    ${rc}    0
