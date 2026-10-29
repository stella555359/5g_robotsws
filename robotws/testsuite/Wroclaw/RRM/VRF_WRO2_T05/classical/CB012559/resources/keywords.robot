*** Settings ***
Documentation
...   author: VRF_WRO2_T05

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012559/resources/keywords.py

*** Keywords ***

Read counters value 12559-QC
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list  M55138C00048  M55138C00049  M55139C00023  M55139C00024  M55118C02015  M55118C02014
    ...                        M55118C06501  M55118C06502
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 12559-QC
    log to console              Waiting for BTS Counters update 240s
    sleep   240s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 12559-QC
    ${GNB_SCELL_4_ADMI_REQ_SA}           get_counter_value_from_single_cell   ${counters}  1    M55138C00048
    ${GNB_SCELL_4_ADMI_SUCC_SA}          get_counter_value_from_single_cell   ${counters}  1    M55138C00049
    ${GNB_DU_SCELL_4_ADMI_REQ_SA}        get_counter_value_from_single_cell   ${counters}  1    M55139C00023
    ${GNB_DU_SCELL_4_ADMI_SUCC_SA}       get_counter_value_from_single_cell   ${counters}  1    M55139C00024
    ${RRC_RECONF_ADD4DLSCELL_ATT_SA}     get_counter_value_from_single_cell   ${counters}  1    M55118C02015
    ${RRC_RECONF_ADD4DLSCELL_SUCC_SA}    get_counter_value_from_single_cell   ${counters}  1    M55118C02014
    ${A2MEAS_REL1DLSCELL_ATT_SA}         Get Counter Value From Single Cell   ${counters}  1    M55118C06501
    ${A2MEAS_REL1DLSCELL_SUCC_SA}        Get Counter Value From Single Cell   ${counters}  1    M55118C06502
    Should Be True      1<=${GNB_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_4_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_4_ADMI_SUCC_SA}
    Should Be True      1<=${RRC_RECONF_ADD4DLSCELL_ATT_SA}
    Should Be True      1<=${RRC_RECONF_ADD4DLSCELL_SUCC_SA}
    Should Be True      2<=${A2MEAS_REL1DLSCELL_ATT_SA}
    Should Be True      2<=${A2MEAS_REL1DLSCELL_SUCC_SA}

Release 2 Cells
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=15
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=20
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=25
    Sleep  5s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=30
    Sleep  5s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=40
    Sleep  5s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=50
    Log to Console    >SCells should be released by now.<
