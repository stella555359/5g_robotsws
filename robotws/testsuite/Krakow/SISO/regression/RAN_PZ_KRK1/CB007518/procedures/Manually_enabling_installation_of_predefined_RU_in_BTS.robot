*** Settings ***
Documentation
...    Test CB007518 - Manually_enabling_installation_of_predefined_RU_in_BTS
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Manually_enabling_installation_of_predefined_RU_in_BTS
    [Arguments]    ${is_asir}=False     ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined
    Check predefined statuses
    gnb_alarm.Allow Alarm                       Unit power reset
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    ...                                         timeout=1200
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Wait Until Keyword Succeeds     3min        30sec
    ...                                         gnbru.Wait for radio unit to be online      ru_id=${bts_ru_id}
    ...                                         radio_type=rmod
    Change RU to not predefined                 is_asir=${is_asir}
    Check not predefined statuses
    gnb_alarm.Disallow Alarm                    Unit power reset

Manually_enabling_installation_of_predefined_RU_in_BTS_ASIR
    [Arguments]    ${is_asir}=True      ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined                     is_asir=${is_asir}
    Check predefined statuses                   is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnb_alarm.Allow Alarm                       Unit power reset
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Wait Until Keyword Succeeds     3min        30sec
    ...                                         gnbru.Wait for radio unit to be online      ru_id=${bts_ru_id}
    ...                                         radio_type=asirmod
    Change RU to not predefined                 is_asir=${is_asir}
    Check not predefined statuses               is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnb_alarm.Disallow Alarm                    Unit power reset
