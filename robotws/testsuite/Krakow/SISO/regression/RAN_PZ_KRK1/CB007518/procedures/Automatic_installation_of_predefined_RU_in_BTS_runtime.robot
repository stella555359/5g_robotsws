*** Settings ***
Documentation
...    Test CB007518 - Automatic_installation_of_predefined_RU_in_BTS_runtime
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Automatic_installation_of_predefined_RU_in_BTS_runtime
    [Arguments]     ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined
    Check predefined statuses
    gnbalarm.Allow Alarm                        Unit power reset
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       30s
    Turn on automated activation
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    gnbru.Wait for radio unit to be online      ru_id=${bts_ru_id}
    ...                                         radio_type=rmod
    Check not predefined statuses
    Turn off automated activation
    gnbalarm.Disallow Alarm                     Unit power reset
