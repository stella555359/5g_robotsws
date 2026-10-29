*** Settings ***
Documentation
...    Test CB007518 - Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR_error_case
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR_error_case
    [Arguments]    ${is_asir}=True      ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined                     is_asir=${is_asir}
    Check predefined statuses                   is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Change RU to not predefined                 is_asir=False
    Change RU to not predefined                 is_asir=${is_asir}
    Check not predefined statuses               is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    Change RU to predefined                     is_asir=False
    Check predefined statuses                   is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
