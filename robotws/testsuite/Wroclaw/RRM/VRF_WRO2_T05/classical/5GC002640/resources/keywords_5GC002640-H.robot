*** Settings ***
Documentation    Suite description

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/test_specific_keywords_2640_H.py
Library         testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot




*** Keywords ***

Set PCell start attenuation
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0


Set SCells start attenuation H32
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}   value=0
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=0
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0


Set SCells start attenuation H30
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0


Conditions on SCell2 deteriorate H30
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=13
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=16
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=20
    Sleep  5s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=30


Conditions on SCell2 deteriorate H32
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=20
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=20
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=23
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=23
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=26
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=26
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=30
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=30
    Sleep  5s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=40
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=40


Attenuate SCell2 H30
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=90


Attenuate SCell2
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}    value=90
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}    value=90


Read counters value 2640-H
    ${counters_values}=   Create List
    Collect Counters   n_last=4
    @{counters}   Create list    M55138C02501    M55138C02502    M55139C01501    M55139C01502
    ...    M55118C10503    M55118C10504
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 2640-H
    Sleep                       300s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 2640-H
    ${GNB_SCELL_2_ADMI_REQ_SA}        Get Counter Value From Single Cell   ${counters}  1    M55138C02501
    ${GNB_SCELL_2_ADMI_SUCC_SA}       Get Counter Value From Single Cell   ${counters}  1    M55138C02502
    ${GNB_DU_SCELL_2_ADMI_REQ_SA}     Get Counter Value From Single Cell   ${counters}  1    M55139C01501
    ${GNB_DU_SCELL_2_ADMI_SUCC_SA}    Get Counter Value From Single Cell   ${counters}  1    M55139C01502
    ${DL_RRC_1SCELL_REL_ATT_SA}       Get Counter Value From Single Cell   ${counters}  1    M55118C10503
    ${DL_RRC_1SCELL_REL_SUC_SA}       Get Counter Value From Single Cell   ${counters}  1    M55118C10504
    Should Be True      1<=${GNB_SCELL_2_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_2_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_2_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_2_ADMI_SUCC_SA}
    Should Be True      1<=${DL_RRC_1SCELL_REL_ATT_SA}
    Should Be True      1<=${DL_RRC_1SCELL_REL_SUC_SA}
