*** Settings ***
Documentation
...    Test CB007518 - Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime
    [Arguments]     ${radio_unit_power_id}=${2}
    Change RU to predefined
    Check predefined statuses
    gnbalarm.Allow Alarm                        Unit power reset
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    Change RU to not predefined
    gnbalarm.Wait for Alarm activation          fault_id=10
    ...                                         awaiting_time=1200
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Wait Until Keyword Succeeds    600s   10s    gnbcell.verify_all_cells_are_onair
    gnbalarm.Disallow Alarm                     Unit power reset

Changing_RU_to_non_predefined_when_the_RU_is_not_connected_in_BTS_runtime_ASIR
    [Arguments]    ${is_asir}=True      ${radio_unit_power_id}=${2}     ${bts_ru_id}=${3}
    Change RU to predefined                     is_asir=${is_asir}
    Check predefined statuses                   is_asir=${is_asir}
    ...                                         ru_id=${bts_ru_id}
    gnbalarm.Allow Alarm                        Unit power reset
    gnbru.radio_unit_power_off                  radio_unit_id=${radio_unit_power_id}
    Sleep                                       1200s
    gnbalarm.Verify Alarm is not active         fault_name=No Connection To Unit
    ...                                         fault_id=10
    Change RU to not predefined                 is_asir=${is_asir}
    gnbalarm.Wait for Alarm activation          fault_id=10
    ...                                         awaiting_time=1200
    gnbru.radio_unit_power_on                   radio_unit_id=${radio_unit_power_id}
    Wait Until Keyword Succeeds    600s   10s    gnbcell.verify_all_cells_are_onair
    gnbalarm.Disallow Alarm                     Unit power reset
