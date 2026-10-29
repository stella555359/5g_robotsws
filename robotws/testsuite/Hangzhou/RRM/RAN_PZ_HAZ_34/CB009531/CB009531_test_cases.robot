*** Settings ***
Force Tags         PY36
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup        8015 Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007737/Resources/CB007737_Case_Step.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008015/Resources/CB008015_keywords.robot

*** Variables ***
${tdd_pcell_index}             ${3}

*** Test Cases ***

[1]CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt
    [Timeout]    120m
    [Tags]     CRT_24R1    CRT_24R2    CRT_24R3
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=SCF_${stream}
    CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt    pcell_index=${tdd_pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB009531_A2_09_DRX_Retransmission_timer_support_in_DL_and_UL_for_VoNR_TDD
    [Timeout]    120m
    [Tags]     CRT_24R1    CRT_24R2    CRT_24R3
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_VONR_${stream}
    CB009531_A2_09_DRX_Retransmission_timer_support_in_DL_and_UL_for_VoNR_TDD    pcell_index=${tdd_pcell_index}
    [Teardown]   Case TearDown For CB007737

[1]CB009531_PDL_Removel_csiReportPeriodicity_Out_of_OndurationTime
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_9531_CSIREPORT_${stream}
    CB009531_PDL_Removel_csiReportPeriodicity_Out_of_OndurationTime    pcell_index=${tdd_pcell_index}
    [Teardown]   Case TearDown For CB007737
