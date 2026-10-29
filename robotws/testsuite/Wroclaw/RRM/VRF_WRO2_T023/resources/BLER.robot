*** Settings ***
Documentation
...   contact: Igor Kleschenok

Resource     ../../resources/pm_counters/pm_counters.robot
Library      ../../VRF_WRO2_T04/resources/kpi.py
Variables    ../../VRF_WRO2_T04/resources/kpi_counters.py


*** Keywords ***
Check BLER And Average MCS
    [Documentation]
    ...  This keyword returns two dictionaries, for BLER and average MCS values for requested cell(s) and tput direction
    ...  with the structure given below.
    ...
    ...  | **Author:** pawel.k.zabawczuk@nokia.com
    ...  | **Maintainer:** magdalena.swierbutowicz@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  BLER dict:
    ...     {cell_id : { 'dl_bler': <value>, 'ul_bler': <value>}}
    ...  Average MCS dict:
    ...     {cell_id : {'dl_mcs64'/'dl_mcs256': <value>, 'ul_mcs64'/'ul_mcs256': <value>}}
    ...     cell_id    ->  global cell id, typically  1, 2 and so on
    ...     dl_bler, ul_bler -> values in percent for downlink and/or uplink; 'no tput' means no traffic on requested cell
    ...     dl_mcs64, dl_mcs256, ul_mcs64, ul_mcs256 - avergae mcs for downlink and/or uplink for 64QAM or 256QAM,
    ...     depends on cell settings (actDl256Qam, actUl256Qam);'no tput' means no traffic on requested cell
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------+------+----------------------------------------------------------------------------------+
    ...  | Parameter           | Man. | Description                                                                      |
    ...  +=====================+======+==================================================================================+
    ...  | cells_ids           | No   | Cells Ids, witten after space e.g. cells_ids=1 2 3. Default: ALL                 |
    ...  +---------------------+------+----------------------------------------------------------------------------------+
    ...  | tput_direction      | No   | dl for downlink or ul for uplink direction. Default: BOTH                        |
    ...  +---------------------+------+----------------------------------------------------------------------------------+
    ...  | interval_pm_number  | No   | n last pm time intervals to check. Default: 1                                    |
    ...  |                     |      | Default value for 'reportingIntervalPm', 'miNrDlHarq' and 'miNrUlHarq' is 15min  |
    ...  |                     |      | Please set them to correctly in scf/webui                                        |
    ...  +---------------------+------+----------------------------------------------------------------------------------+
    ...  | show_on_console     | No   | True or False - display KPIs values on console. Default: False                   |
    ...  +---------------------+------+----------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check BLER And Average MCS   cells_ids=7  tput_direction=both  interval_pm_number=3  show_on_console=True
    ...


    [Arguments]      ${cells_ids}=ALL   ${tput_direction}=BOTH  ${interval_pm_number}=1  ${show_on_console}=False
    Validate PM Counters Setting   ${interval_pm_number}
    ${counters_ids}      Prepare Counters Ids   ${tput_direction}
    ${interval_pm_number}    Convert To Integer   ${interval_pm_number}
    Collect Counters     ${interval_pm_number}
    ${counters_values}   Get Sum Of N Last Counter Values   ${interval_pm_number}  @{counters_ids}
    ${show_on_console}   Convert to boolean   ${show_on_console}

    ${bler}  ${avg_mcs}   Calculate KPI
    ...    counters_values=${counters_values}
    ...    cells_ids=${cells_ids}
    ...    tput_direction=${tput_direction}
    ...    show_on_console=${show_on_console}
    ${cell_values}    Get Dictionary Values    ${bler}
    FOR    ${cell_value}    IN    ${cell_values}
        ${download_bler}    Get From Dictionary    ${cell_value[0]}    dl_bler
        ${upload_bler}    Get From Dictionary    ${cell_value[0]}    ul_bler
        Should Be True    ${download_bler} < 10    msg=DL BLER should be less than 10%
        Should Be True    ${upload_bler} < 10      msg=UL BLER should be less than 10%
    END
    [Teardown]   Cleanup All Downloaded Counter Files
    [Return]   ${bler}  ${avg_mcs}
