*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com


*** Keywords ***
Get Sum Of ${counter} Counter Values From ${no_of_cells} Cells From ${PM_COUNTERS}
    ${counter_sum}    Set Variable    ${0}
    FOR  ${cell}  IN RANGE  ${1}  ${no_of_cells}
        ${counter_value}=    Get Latest Pm Counter Value
    ...    counter_id=${counter}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...    filepath=${PM_COUNTERS}
        ${counter_sum}=    Evaluate    ${counter_sum} + ${counter_value}
    END
    RETURN  ${counter_sum}
