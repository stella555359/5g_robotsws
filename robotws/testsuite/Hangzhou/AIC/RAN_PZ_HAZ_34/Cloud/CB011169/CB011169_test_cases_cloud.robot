*** Settings ***
Force Tags         PY36
Documentation      Author: xiaoxia.hao@nokia-sbell.com
Suite Setup       Suite Setup For Cloud
Suite Teardown    Teardown Suite For Cloud
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Cloud/common_keywords_cloud.robot


*** Variables ***

*** Test Cases ***

[1.0] CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt
    [Timeout]    120m
    [Tags]
    [Setup]  Case Setup For Cloud
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=10
    Start L3 Call And Verify Throughput on Cloud    ul_data_transfer=140M
    ...                                             dl_data_transfer=1500M
    ...                                             expect_ul_tput=130
    ...                                             expect_dl_tput=1400
    [Teardown]   Case Teardown For Cloud
