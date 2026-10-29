*** Settings ***
Documentation
...   author: Lukasz Klimowicz
...   contact: lukasz.klimowicz@nokia.com


*** Keywords ***

Enable ARP And Increase Schedule Weights
    [Arguments]    ${delta_activation}
    Find Scfc And Send Delta Commissioning    scfc_filename=${delta_activation}

Wait For Traffic to Stabilize And Fill UEs Buffers
    BuiltIn.Sleep    30

Enable Legacy WRR And Increase Schedule Weights
    [Arguments]    ${delta_activation}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_activation}

Enable Enhanced WRR And Increase Schedule Weights
    [Arguments]    ${delta_activation}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_activation}

Disable CB013438 FAF And Rollback Schedule Weights
    [Arguments]    ${delta_activation}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_activation}

Get Counters Values For Enhanced Algo Verification
    [Arguments]    ${counter_id_list}    ${local_moid}    ${pm_counter_file}
    @{counters_values} =	Create List
    ${counters_amount}=    Get length    ${counter_id_list}
    FOR    ${index}    IN RANGE    0    ${counters_amount}
        ${obtained_counter_val}=    Get Latest Pm Counter Value
        ...    counter_id=${counter_id_list}[${index}]
        ...    local_moid=${local_moid}[${index}]
        ...    filepath=${pm_counter_file}
        Log to console    ${counter_id_list}[${index}] is equal to ${obtained_counter_val}
        Append To List    ${counters_values}    ${obtained_counter_val}
    END
    Return From Keyword    ${counters_values}

Create List With Local Moids For NRCELL
    [Arguments]    ${counter_id_list}    ${cell_id}
    @{local_moids} =	Create List
    ${elements_amount}=    Get length    ${counter_id_list}
    FOR    ${index}    IN RANGE    0    ${elements_amount}
        Append To List	${local_moids}	PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    END
    Return From Keyword    ${local_moids}
