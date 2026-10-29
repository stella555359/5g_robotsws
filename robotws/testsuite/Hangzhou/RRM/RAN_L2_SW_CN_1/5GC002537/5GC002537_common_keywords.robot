*** Keywords ***
Attach Multiple UEs
    FOR    ${index}    IN    @{UE_ID}
         Log To Console    =============[INFO]UE: ${index}==========
         NSA LTE Attach    ${index}    ${PROFILE_ID}
         NSA 5G Attach    ${index}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
         NSA Start DL Traffic    ${index}    ${BEARER_ID}    50
         NSA Start UL Traffic    ${index}    ${BEARER_ID}    10

    END
Verify 5GC002537 PM Counters
    [Arguments]    ${COUNTER}    ${threshold_value}
    ${counter_value}    Get Max PM Counter Value With Admin     ${COUNTER}
    Should Be True     ${counter_value} > ${threshold_value}