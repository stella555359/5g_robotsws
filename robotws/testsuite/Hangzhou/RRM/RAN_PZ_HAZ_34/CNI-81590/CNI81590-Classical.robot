*** Settings ***
Suite Setup   Run keyword and continue on failure    Suite Setup
Suite Teardown    Suite Teardown

Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEQN_ENB
...      SBTS00   SBTS23R1   CRT_UTE

Library     taf.sw.dcap.rd		WITH NAME	DCAP
Resource    ./Resources/common_keyword.robot

*** Test Cases ***
[1]CNI81590_7_Remove_scrambling_of_ parameter_GUAMI_PLMN_ NSSAI_S-TMSI_ in_SCTP_messages_Classical_GNB
    [Tags]    HAZ3_T03
    [Setup]     Run Keyword And Ignore Error    robot_common_operations.Common case setup
    [Teardown]    run keywords    CNI81590.Teardown
    ...    AND     Run Keyword And Ignore Error    Tests Recover for SA
    CNI81590_CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_60MHz