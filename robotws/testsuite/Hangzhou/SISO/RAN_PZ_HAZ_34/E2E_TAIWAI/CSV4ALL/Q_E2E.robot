*** Settings ***
Suite Setup       Run Keywords  SISO Coam Suite Setup  AND   Run Keyword And Ignore Error   Get Mapping Info With ScoutName And TestLine
Suite Teardown        SISO Coam Suite Teardown
Test Timeout         1200 min


Variables   ../TestData/E2E_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ../Resource/e2e_common_cases.robot
Resource    ../Resource/e2e_step_keywords.robot
Resource    ../Resource/e2e_oam_kpi_keywords.robot
Resource    ./csv4all_common_keywords.robot

Documentation
...    Author: shifu lan
...    Contact: shifu.lan@nokia-sbell.com
...    squad group: VRF_HAZ4_T04
...    Feature E2E TWM

*** Variables ***
${if_commissioning}           True
@{customers}                  Generic

${rf_reset_total_times}       ${10}
${rf_reset_pass_times}        ${10}
${runs_of_cell_lock}          ${3}
${runs_of_cell_block}         ${3}
${runs_of_delt_commision}     ${3}
${runs_of_bbmd_reset}         ${10}
${runs_of_rf_reset}           ${10}
${l3_call_method}             ${None}
${qc_domain}=                 MN_RAN
${qc_id}=                     ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${qc_project}=                RAN_VRF
@{critical_faults}            10    16    1806    1868    4341    4352    4383
@{custom_alarms}              4293   62003   61074   7509    8150
${rp_ca}                      VRF_SiSo
${rp_location}                VRF_HAZ4
${rp_organization}            VRF_HAZ4_T04
${source_sw}                  ${EMPTY}
${target_sw}                  ${EMPTY}
&{e2e_gnb}                    node_alias=e2e_gnb    testline_object=${tl.gnbs[0]}    source_sw=${source_sw}    target_sw=${target_sw}
...    critical_alarms=${critical_faults}    custom_allowed_alarms=${custom_alarms}
@{e2e_gnb_nodes}                  ${e2e_gnb}

*** Test Cases ***
# [1]E2E_01_SiSo_Delta_Commissioning_With_Online_Parameter_Modification_and_L3Call
#     [Setup]  E2E COAM TEST SETUP
#     Delta_Commissioning_With_Given_Parameter    with_peak=${False}
#     [Teardown]  E2E COAM TEST TEARDOWN

[1]E2E_SiSo_RU_lock_and_unlock_gNB
    [Setup]    E2E COAM TEST SETUP
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}    with_peak=${False}  call_duration=${300}
    [Teardown]  E2E COAM TEST TEARDOWN

[1]E2E_SiSo_Cell_lock_and_unlock_gNB
    [Setup]    UUF4ALL NR Test Setup
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_cell_lock_unlock_nr_with_oam_kpi    report=${False}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_SiSo_Cell_block_and_unblock_gNB
    [Setup]    UUF4ALL NR Test Setup
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_cell_block_unblock_nr_with_oam_kpi    report=${False}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_SiSo_BBMOD_module_reset_from_GUI_L3call
    [Setup]    UUF4ALL NR Test Setup
    ${bbmd_list}    Get All BB Configured
    Set Test Variable    ${e2e_gnb['modules_for_test']}    ${bbmd_list}
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_capacity_module_reset_with_oam_kpi    report=${False}
    [Teardown]    Run Keywords    Clear E2E GNB Modules For Test Variable    AND    UUF4ALL NR Test Teardown

[1]E2E_11_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_webem_with_L3Call
    [Setup]    UUF4ALL NR Test Setup
    ${rmod_list}    Get All Ru Configured
    Set Test Variable    ${e2e_gnb['modules_for_test']}    ${rmod_list}
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_ru_reset_with_oam_kpi    report=${False}
    [Teardown]    Run Keywords    Clear E2E GNB Modules For Test Variable    AND    UUF4ALL NR Test Teardown

[1]E2E_14_SiSo_Delta_Commissioning_With_Rat_Reset_and_L3Call
    [Setup]  E2E COAM TEST SETUP
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_delta_commissioning_with_nr_rat_reset    report=${False}
    [Teardown]  E2E COAM TEST TEARDOWN

[1]E2E_15_SiSo_Delta_Commissioning_With_Site_Reset_and_L3Call
    [Setup]  E2E COAM TEST SETUP
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_delta_commissioning_with_site_reset_required   report=${False}
    [Teardown]  E2E COAM TEST TEARDOWN


[1]E2E_Monitor_BTS_Stability_2Hours_With_L3Call
    [Setup]  E2E COAM TEST SETUP
    Monitor_BTS_Status_For_2_Hours
    # Make Call With All UE
    [Teardown]  E2E COAM TEST TEARDOWN




*** Keywords ***
Get All Ru Configured
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    create list
    FOR  ${ru}  IN  @{rmod_info}
        append to list    ${ru_index_list}    ${ru.id.configuration}
    END
    [Return]  ${ru_index_list}


Get All BB Configured
    [Arguments]  ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${fbb_info}    set variable    ${hw_info.basebandModules}
    ${fbb_id_list}  create list
    FOR  ${fbb}  IN  @{fbb_info}
        append to list    ${fbb_id_list}    ${fbb.id.configuration}
    END
    [Return]  ${fbb_id_list}



Clear E2E GNB Modules For Test Variable
    Set Test Variable    ${e2e_gnb['modules_for_test']}    ${None}