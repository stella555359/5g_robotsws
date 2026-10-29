*** Settings ***
Force Tags    PY36
Documentation      Author: lei.jia@nokia-sbell.com
Suite Setup        8360 Suite Setup
Suite Teardown    8360 Suite TearDown
Resource     ../Resources/CB008360_keywords.robot
Resource     ../Resources/CB008360_case_steps.robot

*** Test Cases ***
[1]CB008360-5G-A_B1_05_Two_UEs_blindly_paired_Controled_by_Different_Cell_load
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Two UEs, NSA UL 1layer, Non-CA
    ...                  UE1: SDX60, chbw:40M
    ...                  MCS PORT: 5/6/7/8
    ...                  UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]     CRT_23R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B1_05_Two_UEs_blindly_paired_Controled_by_Different_Cell_load
    [Teardown]    8360 Case TearDown

[1]CB008360-5G-A_B1_09_Two_UEs_Not_paired_when_rescaled_SINR_less_than_ulMuMimoSinrThd
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Two UEs, NSA UL 1layer, Non-CA
    ...                  UE1: SDX60, chbw:40M
    ...                  MCS PORT: 5/6/7/8
    ...                  UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]     CRT_23R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B1_09_Two_UEs_Not_paired_when_rescaled_SINR_less_than_ulMuMimoSinrThd
    [Teardown]    8360 Case TearDown

[1]CB008360-5G-A_B2_12_Two_UEs_paired_when_correlation_lower_than_ulMuMimoCorrThd_and_UL_SINR_Difference_less_than_rdPairedUEsDeltaSINR
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Two UEs, NSA UL 1layer, Non-CA
    ...                  UE1: SDX60, chbw:40M
    ...                  MCS PORT: 5/6/7/8
    ...                  UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]    CRT_23R1    CRT_23R4    CRT_24R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B2_12_Two_UEs_paired_when_correlation_lower_than_ulMuMimoCorrThd_and_UL_SINR_Difference_less_than_rdPairedUEsDeltaSINR
    [Teardown]    8360 Case TearDown

[1]CB008360-5G-A_B3_16_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MU-SINR_Estimation
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                Two UEs, NSA UL 1layer, Non-CA
    ...                UE1: SDX60, chbw:40M, MCS PORT: 5/6/7/8
    ...                UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]    CRT_23R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B3_16_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MU-SINR_Estimation
    [Teardown]    8360 Case TearDown

[1]CB008360-5G-A_B3_17_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MCS_compensation
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Two UEs, NSA UL 1layer, Non-CA
    ...                  UE1: SDX60, chbw:40M
    ...                  MCS PORT: 5/6/7/8
    ...                  UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]     CRT_23R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B3_17_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MCS_compensation
    [Teardown]    8360 Case TearDown

[1]CB008360-5G-A_B1_07_Two_UEs_paired_Control_Verify_for_Root_UE_Req_PRB_less_than_ulMinPrbThreshold
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                Two UEs, NSA UL 1layer, Non-CA
    ...                UE1: SDX60, chbw:40M, MCS PORT: 5/6/7/8
    ...                UE2: MTK, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]     CRT_23R1
    [Timeout]    120m
    [Setup]    8360 Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-A_B1_07_Two_UEs_paired_Control_Verify_for_Root_UE_Req_PRB_less_than_ulMinPrbThreshold
    [Teardown]    8360 Case TearDown
