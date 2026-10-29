*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Izabela Prosniak
...             :contact: izabela.prosniak@nokia.com

Library      ta5g_ue_measurements


*** Keywords ***
Verify Measurements Are Configured At UE
    [Arguments]    ${ue_id}    ${event_type}    ${event_params}    ${frequencies}
    Get UE Measurement Configuration    ue_id=${ue_id}    alias=UE${ue_id}
    Verify That Specified Events Are Active On Given Frequencies And Have Specified Thresholds
    ...  event_type=${event_type}
    ...  event_params=${event_params}
    ...  frequencies=${frequencies}
    ...  alias=UE${ue_id}

Verify Measurements Are Not Configured At UE
    [Arguments]    ${ue_id}    ${event_type}    ${event_params}    ${frequencies}
    Run Keyword And Expect Error    '${event_type}' is not active on at least one frequency or does not have specified thresholds
    ...    Verify Measurements Are Configured At UE
    ...    ue_id=${ue_id}
    ...    event_type=${event_type}
    ...    event_params=${event_params}
    ...    frequencies=${frequencies}
