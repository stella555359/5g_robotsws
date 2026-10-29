*** Settings ***
Documentation
...   author: PZ_2_WRO_5


*** Keywords ***

Read counters value 130245
    ${counters_values}=   Create List
    Collect Counters   n_last=6
    @{counters}   Create list  M55182C00003  M55182C00004
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 130245
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    log to console              Verify PM counters values
    ${counters}                 Read counters value 130245
    ${A4_IEF_IADU_HO_EX_ATT_NSA}      get_counter_value_from_single_cell   ${counters}    1    M55182C00003
    ${A4_IEF_IADU_HO_EX_SUC_NSA}      get_counter_value_from_single_cell   ${counters}    1    M55182C00004
    Should Be True      1<=${A4_IEF_IADU_HO_EX_ATT_NSA}
    Should Be True      1<=${A4_IEF_IADU_HO_EX_SUC_NSA}
