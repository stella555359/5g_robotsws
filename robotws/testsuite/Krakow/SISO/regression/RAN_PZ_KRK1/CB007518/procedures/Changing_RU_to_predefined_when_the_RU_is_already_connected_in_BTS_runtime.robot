*** Settings ***
Documentation
...    Test CB007518 - Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime
    Change RU to predefined
    Check predefined statuses

Changing_RU_to_predefined_when_the_RU_is_already_connected_in_BTS_runtime_ASiR
    [Arguments]    ${is_asir}=True      ${bts_ru_id}=${3}
    Change RU to predefined             is_asir=${is_asir}
    Check predefined statuses           is_asir=${is_asir}
    ...                                 ru_id=${bts_ru_id}
