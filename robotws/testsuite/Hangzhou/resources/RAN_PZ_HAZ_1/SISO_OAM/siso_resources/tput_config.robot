*** Settings ***
Documentation     Author: len.lin@nokia-sbell.com
...               Maintainer: Author

Library    ./utils/others.py

*** Variables ***

@{UL_MIMO_THROUGHPUT_CONF}    20.2    9.99    20.2    9.99    20.2    9.99    20.2
...               9.99    20.2    9.99    20.2    9.99    20.2    9.99
...               20.2    9.99    15    9.5    15    7    15
...               9.5    15    7    9.99    9.99    9.99    19.6
...               8.7    20.2    9.99
@{DL_MIMO_THROUGHPUT_CONF}    40.72    55.86    29.62    44.78    40.79    55.84    29.62
...               44.78    81.66    111.81    59.50    89.65    81.66    107.5
...               59.50    89.05    34    47    26    38    66
...               90.5    51    75.5    107.85    105.45    89.48    78.57
...               95    118.08    70.43
@{UL_MIMO_THROUGHPUT_FDD_CONF}    30    30    30
@{DL_MIMO_THROUGHPUT_FDD_CONF}    60    150    150

*** Keywords ***
Set Mimo Ul Transfer Config
    [Arguments]    ${case_no}
    ${out_ul_mimo_transfer}=    Get From List    ${UL_MIMO_THROUGHPUT_CONF}    ${case_no}
    [Return]    ${out_ul_mimo_transfer}

Set Mimo Dl Transfer Config
    [Arguments]    ${case_no}
    ${out_dl_mimo_transfer}=    Get From List    ${DL_MIMO_THROUGHPUT_CONF}    ${case_no}
    [Return]    ${out_dl_mimo_transfer}

Set Mimo Ul Transfer FDD Config
    [Arguments]    ${case_no}
    ${out_ul_mimo_transfer}=    Get From List    ${UL_MIMO_THROUGHPUT_FDD_CONF}    ${case_no}
    [Return]    ${out_ul_mimo_transfer}

Set Mimo Dl Transfer FDD Config
    [Arguments]    ${case_no}
    ${out_dl_mimo_transfer}=    Get From List    ${DL_MIMO_THROUGHPUT_FDD_CONF}    ${case_no}
    [Return]    ${out_dl_mimo_transfer}

Check LcrId Max TP Config
    [Arguments]    ${cell_info}
    Set Test Variable    ${out_tmp_lcrid_mimo}    ${cell_info['dlMimoMode']}
    Set Test Variable    ${out_tmp_lcrid_subf}    ${cell_info['tddSpecSubfConf']}
    Set Test Variable    ${out_tmp_lcrid_frame}    ${cell_info['tddFrameConf']}
    ${TM_mode}=    Set Variable if    '${out_tmp_lcrid_mimo}' == 'SingleTX'    TM1
    ...    '${out_tmp_lcrid_mimo}' == 'TXDiv'    TM2
    ...    '${out_tmp_lcrid_mimo}' == '4-way TXDiv'    TM2
    ...    '${out_tmp_lcrid_mimo}' == 'Dynamic Open Loop MIMO'    TM3
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop Mimo'    TM4
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop MIMO (4x2)'    TM4
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop MIMO (4x4)'    TM4
    ...    '${out_tmp_lcrid_mimo}' == 'Single Stream Beamforming'    TM7
    ...    '${out_tmp_lcrid_mimo}' == 'Dual Stream Beamforming'    TM8
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop MIMO (8x4)'    TM9
    Set Test variable    ${out_tmp_lcrid_conf}    ${TM_mode}_${out_tmp_lcrid_frame}_${out_tmp_lcrid_subf}
    @{out_expected_throughput}=    Create List
    ${out_expected_throughput_tmp}=    Run Keyword If
    ...   '${out_tmp_lcrid_conf}'=='TM1_1_7'    Set Mimo Ul Transfer Config    0
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_2_7'    Set Mimo Ul Transfer Config    1
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_1_5'    Set Mimo Ul Transfer Config    2
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_2_5'    Set Mimo Ul Transfer Config    3
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_1_7'    Set Mimo Ul Transfer Config    4
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_7'    Set Mimo Ul Transfer Config    5
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_1_5'    Set Mimo Ul Transfer Config    6
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_5'    Set Mimo Ul Transfer Config    7
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_7'    Set Mimo Ul Transfer Config    8
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_7'    Set Mimo Ul Transfer Config    9
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_5'    Set Mimo Ul Transfer Config    10
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_5'    Set Mimo Ul Transfer Config    11
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_1_7'    Set Mimo Ul Transfer Config    12
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_7'    Set Mimo Ul Transfer Config    13
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_1_5'    Set Mimo Ul Transfer Config    14
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_5'    Set Mimo Ul Transfer Config    15
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_1_7'    Set Mimo Ul Transfer Config    16
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_2_7'    Set Mimo Ul Transfer Config    17
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_1_5'    Set Mimo Ul Transfer Config    18
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_2_5'    Set Mimo Ul Transfer Config    19
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_1_7'    Set Mimo Ul Transfer Config    20
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_7'    Set Mimo Ul Transfer Config    21
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_1_5'    Set Mimo Ul Transfer Config    22
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_5'    Set Mimo Ul Transfer Config    23
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_6'    Set Mimo Ul Transfer Config    24
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_6'    Set Mimo Ul Transfer Config    25
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_6'    Set Mimo Ul Transfer Config    26
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_4'    Set Mimo Ul Transfer Config    27
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM9_2_7'    Set Mimo Ul Transfer Config    28
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM9_1_7'    Set Mimo Ul Transfer Config    29
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_6'    Set Mimo Ul Transfer Config    30
    Append To List    ${out_expected_throughput}    ${out_expected_throughput_tmp}
    ${out_expected_throughput_tmp}=    Run Keyword If
    ...    '${out_tmp_lcrid_conf}'=='TM1_1_7'    Set Mimo Dl Transfer Config    0
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_2_7'    Set Mimo Dl Transfer Config    1
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_1_5'    Set Mimo Dl Transfer Config    2
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM1_2_5'    Set Mimo Dl Transfer Config    3
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_1_7'    Set Mimo Dl Transfer Config    4
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_7'    Set Mimo Dl Transfer Config    5
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_1_5'    Set Mimo Dl Transfer Config    6
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_5'    Set Mimo Dl Transfer Config    7
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_7'    Set Mimo Dl Transfer Config    8
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_7'    Set Mimo Dl Transfer Config    9
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_5'    Set Mimo Dl Transfer Config    10
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_5'    Set Mimo Dl Transfer Config    11
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_1_7'    Set Mimo Dl Transfer Config    12
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_7'    Set Mimo Dl Transfer Config    13
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_1_5'    Set Mimo Dl Transfer Config    14
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_5'    Set Mimo Dl Transfer Config    15
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_1_7'    Set Mimo Dl Transfer Config    16
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_2_7'    Set Mimo Dl Transfer Config    17
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_1_5'    Set Mimo Dl Transfer Config    18
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM7_2_5'    Set Mimo Dl Transfer Config    19
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_1_7'    Set Mimo Dl Transfer Config    20
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_7'    Set Mimo Dl Transfer Config    21
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_1_5'    Set Mimo Dl Transfer Config    22
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_5'    Set Mimo Dl Transfer Config    23
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_2_6'    Set Mimo Dl Transfer Config    24
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4_2_6'    Set Mimo Dl Transfer Config    25
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM8_2_6'    Set Mimo Dl Transfer Config    26
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3_1_4'    Set Mimo Dl Transfer Config    27
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM9_2_7'    Set Mimo Dl Transfer Config    28
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM9_1_7'    Set Mimo Dl Transfer Config    29
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM2_2_6'    Set Mimo Dl Transfer Config    30
    Append To List    ${out_expected_throughput}    ${out_expected_throughput_tmp}
    Set Test Variable    ${out_tmp_lcrid_chbw}    ${cell_info['chBw']}
    ${out_expected_tp_ul}    Evaluate    ${out_expected_throughput[0]}
    ${out_expected_tp_ul_15m}    Evaluate    ${out_expected_throughput[0]}*0.73
    ${out_expected_tp_ul_10m}    Evaluate    ${out_expected_throughput[0]}*0.49
    ${out_expected_tp_ul_5m}    Evaluate    ${out_expected_throughput[0]}*0.25
    ${out_expected_tp_dl}    Evaluate    ${out_expected_throughput[1]}
    ${out_expected_tp_dl_15m}    Evaluate    ${out_expected_throughput[1]}*0.73
    ${out_expected_tp_dl_10m}    Evaluate    ${out_expected_throughput[1]}*0.49
    ${out_expected_tp_dl_5m}    Evaluate    ${out_expected_throughput[1]}*0.25
    ${out_cell_id_ul_th}=    Set Variable if    '${out_tmp_lcrid_chbw}' == '20 MHz'    ${out_expected_tp_ul}
    ...    '${out_tmp_lcrid_chbw}' == '15 MHz'    ${out_expected_tp_ul_15m}
    ...    '${out_tmp_lcrid_chbw}' == '10 MHz'    ${out_expected_tp_ul_10m}
    ...    '${out_tmp_lcrid_chbw}' == '5 MHz'     ${out_expected_tp_ul_5m}
    ${out_cell_id_dl_th}=    Set Variable if    '${out_tmp_lcrid_chbw}' == '20 MHz'    ${out_expected_tp_dl}
    ...    '${out_tmp_lcrid_chbw}' == '15 MHz'    ${out_expected_tp_dl_15m}
    ...    '${out_tmp_lcrid_chbw}' == '10 MHz'    ${out_expected_tp_dl_10m}
    ...    '${out_tmp_lcrid_chbw}' == '5 MHz'    ${out_expected_tp_dl_5m}
    @{out_tp_list}=    Create List
    Append To List    ${out_tp_list}    ${out_cell_id_dl_th}     ${out_cell_id_ul_th}
    [Return]    @{out_tp_list}

Check LcrId Max TP FDD Config
    [Arguments]    ${cell_info}
    Set Test Variable    ${out_tmp_lcrid_mimo}    ${cell_info['dlMimoMode']}
    ${TM_mode}=    Set Variable if    '${out_tmp_lcrid_mimo}' == 'TXDiv'    TM2
    ...    '${out_tmp_lcrid_mimo}' =='Dynamic Open Loop MIMO'    TM3
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop Mimo'    TM4
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop MIMO (4x2)'    TM4
    ...    '${out_tmp_lcrid_mimo}' == 'Closed Loop MIMO (4x4)'    TM4
    Set Test variable    ${out_tmp_lcrid_conf}    ${TM_mode}
    @{out_expected_throughput}=    Create List
    ${out_expected_throughput_tmp}=    Run Keyword If
    ...    '${out_tmp_lcrid_conf}'=='TM2'    Set Mimo Ul Transfer FDD Config    0
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3'    Set Mimo Ul Transfer FDD Config    1
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4'    Set Mimo Ul Transfer FDD Config    2
    Append To List    ${out_expected_throughput}    ${out_expected_throughput_tmp}
    ${out_expected_throughput_tmp}=
    ...    Run Keyword If     '${out_tmp_lcrid_conf}'=='TM2'    Set Mimo Dl Transfer FDD Config    0
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM3'    Set Mimo Dl Transfer FDD Config    1
    ...    ELSE IF    '${out_tmp_lcrid_conf}'=='TM4'    Set Mimo Dl Transfer FDD Config    2
    Append To List    ${out_expected_throughput}    ${out_expected_throughput_tmp}
    Set Test Variable    ${out_tmp_lcrid_chbw}    ${cell_info['chBwDl']}
    ${out_expected_tp_ul}    Evaluate    ${out_expected_throughput[0]}
    ${out_expected_tp_ul_15m}    Evaluate    ${out_expected_throughput[0]}*0.73
    ${out_expected_tp_ul_10m}    Evaluate    ${out_expected_throughput[0]}*0.49
    ${out_expected_tp_ul_5m}    Evaluate    ${out_expected_throughput[0]}*0.25
    ${out_expected_tp_dl}    Evaluate    ${out_expected_throughput[1]}
    ${out_expected_tp_dl_15m}    Evaluate    ${out_expected_throughput[1]}*0.73
    ${out_expected_tp_dl_10m}    Evaluate    ${out_expected_throughput[1]}*0.49
    ${out_expected_tp_dl_5m}    Evaluate    ${out_expected_throughput[1]}*0.25
    ${out_cell_id_ul_th}=    Set Variable if    '${out_tmp_lcrid_chbw}' == '20 MHz'    ${out_expected_tp_ul}
    ...     '${out_tmp_lcrid_chbw}' == '15 MHz'    ${out_expected_tp_ul_15m}
    ...     '${out_tmp_lcrid_chbw}' == '10 MHz'    ${out_expected_tp_ul_10m}
    ...     '${out_tmp_lcrid_chbw}' == '5 MHz'    ${out_expected_tp_ul_5m}
    ${out_cell_id_dl_th}=    Set Variable if    '${out_tmp_lcrid_chbw}' == '20 MHz'    ${out_expected_tp_dl}
    ...    '${out_tmp_lcrid_chbw}' == '15 MHz'    ${out_expected_tp_dl_15m}
    ...    '${out_tmp_lcrid_chbw}' == '10 MHz'    ${out_expected_tp_dl_10m}
    ...    '${out_tmp_lcrid_chbw}' == '5 MHz'     ${out_expected_tp_dl_5m}
    @{out_tp_list}=    Create List
    Append To List    ${out_tp_list}    ${out_cell_id_dl_th}    ${out_cell_id_ul_th}
    [Return]    @{out_tp_list}

Get LcrId Max TP From Config
    [Arguments]    ${cell_info}    ${extra_peak_rate_config}=${Empty}
    ${out_arg_is_a_dict}=    Evaluate   type($extra_peak_rate_config).__name__!="dict"
    Run Keyword If    ${out_arg_is_a_dict}    Fail
    ${pci}    Set Variable    ${cell_info["phyCellId"]}

    ${is_defined}    Dictionary Should Contain Key   ${extra_peak_rate_config}    ${pci}

    Run Keyword If    ${is_defined}    Fail

    @{out_tp_list}=    Create List
    Append To List    ${out_tp_list}    ${extra_peak_rate_config['${pci}'][0]}
    ...     ${extra_peak_rate_config['${pci}'][1]}
    [Return]    @{out_tp_list}

Get LcrId Max TP
    [Arguments]    ${cell_info}    ${extra_peak_rate_config}=${Empty}
    ${status}    ${out_tp_list}    Run Keyword And Ignore Error    Get LcrId Max TP From Config
    ...    ${cell_info}    ${extra_peak_rate_config}

    Return From Keyword If    '${status}'=='PASS'   ${out_tp_list}
    ${out_tp_list}    Run Keyword If    '${cell_info['cellTechnology']}'=='TDD'
    ...    Check LcrId Max TP Config    ${cell_info}
    ...    ELSE IF    '${cell_info['cellTechnology']}'=='FDD'
    ...    Check LcrId Max TP FDD Config   ${cell_info}

    [Return]    ${out_tp_list}






