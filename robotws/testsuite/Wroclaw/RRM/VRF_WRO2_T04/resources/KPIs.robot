*** Settings ***
Documentation
...    Keyword returns KPIs (NR_5054a, NR_5056b, NR_5068a, NR_5067a, NR_5105a, NR_5076b) during the measurement period

Resource     testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Library      ./kpi.py
Variables    ./kpi_counters.py


*** Keywords ***
Check BLER And Average MCS
    [Documentation]  This keyword returns two dictionaries, for BLER and average MCS values for requested cell(s) and tput direction
    ...              with the structure given below:
    ...              BLER dict:
    ...                 {cell_id : { 'dl_bler': <value>, 'ul_bler': <value>}}
    ...              Average MCS dict:
    ...                 {cell_id : {'dl_mcs64'/'dl_mcs256': <value>, 'ul_mcs64'/'ul_mcs256': <value>}}
    ...               cell_id    ->  global cell id, typically  1, 2 and so on
    ...               dl_bler, ul_bler -> values in percent for downlink and/or uplink; 'no tput' means no traffic on requested cell
    ...               dl_mcs64, dl_mcs256, ul_mcs64, ul_mcs256 - average mcs for downlink and/or uplink for 64QAM or 256QAM,
    ...                 depends on cell settings (actDl256Qam, actUl256Qam);'no tput' means no traffic on requested cell
    ...              Arguments description:
    ...              cells_ids - default ALL, are witten after space e.g. cells_ids=1 2 3
    ...              tput_direction - default BOTH, dl for downlink or ul for uplink direction
    ...              interval_pm_number - default 1, n last pm time intervals to check.
    ...                 default value for 'reportingIntervalPm', 'miNrDlHarq' and 'miNrUlHarq' is 15min - please set them to correctly in scf/webui
    ...              show_on_console - default False, True or False - display KPIs values on console

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
    [Teardown]   Cleanup All Downloaded Counter Files
    [Return]   ${bler}  ${avg_mcs}
