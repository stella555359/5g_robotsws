*** Settings ***
Documentation
...    Test CB007518 - BTS_start-up_with_configured_predefined_RU_delta_commissioning
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
BTS_start-up_with_configured_predefined_RU_delta_commissioning
    [Arguments]     ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined
    Check predefined statuses
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    Verify not predefined RUs statuses          ru_id=${bts_ru_id}
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Sleep                                       90s

BTS_start-up_with_configured_predefined_RU_delta_commissioning_ASIR
    [Arguments]    ${is_asir}=True      ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined                     is_asir=${is_asir}
    Check predefined statuses                   is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    Verify not predefined RUs statuses          is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Sleep                                       90s
