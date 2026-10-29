*** Settings ***
Suite Setup           Run Keywords  UUF4ALL Suite Setup  AND   Run Keyword And Ignore Error   Get Mapping Info With ScoutName And TestLine
Suite Teardown        UUF4ALL Suite Teardown
Test Timeout         48 H


Variables   ../TestData/E2E_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../Resource/e2e_common_cases.robot
Resource    ../Resource/e2e_step_keywords.robot
Resource    ../Resource/e2e_oam_kpi_keywords.robot
Resource    ./csv4all_common_keywords.robot

Documentation
...    Author: shifu lan
...    Contact: shifu.lan@nokia-sbell.com
...    squad group: VRF_HAZ4_T04
...    Feature E2E TWM UUF

*** Variables ***
${if_commissioning}           False
@{customers}                  Generic

${runs_of_uuf_upgrade}        ${3}
${runs_of_uuf_reset}          ${20}
${l3_call_method}             ${None}
${qc_domain}=                 MN_RAN
${qc_id}=                     ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${qc_project}=                RAN_VRF
@{critical_faults}            10    16    1806    1868    4341    4352    4383
@{custom_alarms}              4293   62003   61074   7509    8150   6327    61030
${rp_ca}                      VRF_SiSo
${rp_location}                VRF_HAZ
${rp_organization}            VRF_HAZ_T04
${source_sw}                  ${EMPTY}
${target_sw}                  ${EMPTY}
&{e2e_gnb}                    node_alias=e2e_gnb    testline_object=${tl.gnbs[0]}    source_sw=${source_sw}    target_sw=${target_sw}
...    critical_alarms=${critical_faults}    custom_allowed_alarms=${custom_alarms}
@{e2e_gnb_nodes}                  ${e2e_gnb}

&{e2e_enb}                    node_alias=e2e_enb    testline_object=${tl.enbs[0]}    source_sw=${source_sw}    target_sw=${target_sw}
...    critical_alarms=${critical_faults}    custom_allowed_alarms=${custom_alarms}
@{e2e_enb_nodes}                  ${e2e_enb}

*** Test Cases ***
[1]E2E_92_eNB_Reset_with_HWF_deletion
    [Setup]    UUF4ALL LTE Test Setup
    ${fault_list}    Create List    4293   62003   61074   7509    8150   6327
    ${current_version}    E2E_Get_Current_Version    bts_host=${tl.enbs[0].oam_ip.v4}    username=Nemuadmin    password=nemuuser
    Set Test Variable    ${Active_SW_version}    ${current_version}
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Set Testline Scout Name    node=${e2e_enb}    nodes=${e2e_enb_nodes}
    csv4all_common_keywords.e2e_tl_site_reset_without_hwf_with_oam_kpi    report=${False}
    [Teardown]    UUF4ALL LTE Test Teardown

[1]E2E_91_eNB_SW_Upgrade_loops_with_WebUI
    [Setup]    UUF4ALL LTE Test Setup
    ${fault_list}    Create List    4293   62003   61074   7509    8150   6327
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Set Testline Scout Name    node=${e2e_enb}    nodes=${e2e_enb_nodes}
    ${current_version}    E2E_Get_Current_Version    bts_host=${tl.enbs[0].oam_ip.v4}    username=Nemuadmin    password=nemuuser
    csv4all_common_keywords.e2e_tl_sw_upgrade_rollback_with_oam_kpi    current_version=${current_version}    report=${False}
    [Teardown]    UUF4ALL LTE Test Teardown

[1]E2E_gNB_Site_Reset_without_HWF_with_L3Call
    [Setup]    UUF4ALL NR Test Setup
    ${fault_list}    Create List    4293   62003   61074   7509    8150
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_site_reset_without_hwf_with_oam_kpi    call_method=${l3_call_method}    report=${False}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_gNB_SW_Upgrade_loops_with_WebUI_and_L3Call
    [Setup]    UUF4ALL NR Test Setup
    ${fault_list}    Create List    4293   62003   61074   7509    8150
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Set Testline Scout Name    node=${e2e_gnb}    nodes=${e2e_gnb_nodes}
    csv4all_common_keywords.e2e_tl_sw_upgrade_rollback_with_oam_kpi    call_method=${l3_call_method}   report=${False}
    [Teardown]    UUF4ALL NR Test Teardown
