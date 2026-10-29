*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This resources contains keywords related to measurements

Library    ute_wtssim

*** Keywords ***
Trigger A1 Measurement
    [Documentation]
    ...    Triggers A1 measurement and waits for rrcReconfigurationComplete
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | ue_id                  | Yes   | Specified UE ID.                                                     |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | meas_id                | Yes   | A1 Measurement ID.                                                   |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | srsrp_nr               | No    | RSRP value for serving cell in NR.                                   |
    ...    |                        |       | Default value: 90.                                                   |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | timeout                | No    | Waiting time for rrcReconfigurationComplete message.                 |
    ...    |                        |       | Default value: 60s.                                                  |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=90    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}
