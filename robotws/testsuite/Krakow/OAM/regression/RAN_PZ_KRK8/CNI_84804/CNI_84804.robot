*** Settings ***
Documentation
...   author: Bartosz Odziomek
...   contact: bartosz.odziomek@nokia.com

Resource    CNI_84804_Resources.robot

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASOD_AEUD_ENB

Suite Setup       Suite Setup for CNI 84804
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions with watching alarms
Test Teardown     Test Teardown for 2 UEs

*** Test Cases ***
[1][1.0] CNI-84804_02_Full_bi-directional_tcp_tput_with_two_UEs
    ${dl_tput_60Mhz_per_UE} =   Convert To Integer   ${${dl_tput_60Mhz}/${number_of_UEs}}
    ${ul_tput_60Mhz_per_UE} =   Convert To Integer   ${${ul_tput_60Mhz}/${number_of_UEs}}
    ${dl_tput_20Mhz_per_UE} =   Convert To Integer   ${${dl_tput_20Mhz}/${number_of_UEs}}
    ${ul_tput_20Mhz_per_UE} =   Convert To Integer   ${${ul_tput_20Mhz}/${number_of_UEs}}

    ue.Require Ue    ${UE_1_alias}    capabilities=REAL_UE_1
    ue.Require Ue    ${UE_2_alias}    capabilities=REAL_UE_2

    gnbcell.Block Cell    cell_id=1
    Sleep  5s
    Run keyword And Continue On Failure  Run and verify data transfer for two UEs   ${dl_tput_60Mhz_per_UE}   ${ul_tput_60Mhz_per_UE}
    gnbcell.Unblock Cell    cell_id=1
    gnbcell.Block Cell    cell_id=0
    Sleep   30s
    gnb_cell.Verify Cell Status   cell_id=1
    Run keyword And Continue On Failure  Run and verify data transfer for two UEs   ${dl_tput_20Mhz_per_UE}   ${ul_tput_20Mhz_per_UE}
