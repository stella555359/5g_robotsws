*** Settings ***
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  13.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-222 - add KW "Verify OAM KPI"
...  12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-529 - OAM KPI fix
...  20.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-619 - Retrun KPI times from KW: Calculate KPI7 KPI8 KPI9 KPI10
...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-11759 - New KW: Calculate KPI54a KPI54b
...  xx.xx.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Keywords ***
####################
###   OAM KPI    ###
####################
Verify OAM KPI
    [Documentation]  Deprecated. Use below keywords instead.
    ...  Keyword calculate OAM KPI for defined KPI ID using oam_kpi_calculations library.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  **Example of simple usage:**
    ...  Verify OAM KPI  kpi=kpi51a kpi51b
    ...
    [Arguments]  ${kpi}
    ${file_name}=  Evaluate  '${kpi}'.replace(' ','_')
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}=  Set Variable  ${RESULTS}/${timestamp}_ims_${file_name}.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    @{kpis}=  Split String  ${kpi}  ${SPACE}
    FOR  ${item}  IN  @{kpis}
        oam_kpi_calculations.calculate_kpis  kpi_names=${item}   ims_file_path=${ims_file_path}
        ${all_kpi_deltas}=  oam_kpi_calculations.get all deltas  ${item}
        ${all_kpi_deltas}=  Convert To String  ${all_kpi_deltas}
        Set Suite Variable  ${all_kpi_deltas_${item}}  ${all_kpi_deltas}
        ${max_delta}=  oam_kpi_calculations.get max delta  ${item}
        ${max_delta}=  Convert To String  ${max_delta}
        Set Suite Variable  ${max_kpi_delta_${item}}  ${max_delta}
    END
    ${kpi_average_results}=  oam_kpi_calculations.get_average_results
    ${json}=  Set Variable  ${RESULTS}/${timestamp}_results_${file_name}.json
    ${verdict}  ${msg}  Run Keyword And Ignore Error  oam_kpi_calculations.save_results_to_file  file_path=${json}
    ${kpi_file_results}=  Set Variable If  '${verdict}'=='PASS'  ${RESULTS}/${timestamp}_results_${file_name}.json
    oam_kpi_calculations.clear_results

Calculate KPI1a KPI1b KPI1c
    [Documentation]
    ...    +---------------------------+-----------------+---------------+
    ...    | KPI                       | Start Point     | End Point     |
    ...    +---------------------------+-----------------+---------------+
    ...    | KPI1a - Manual Site Reset | First Cell Down | Last Cell Up  |
    ...    +---------------------------+-----------------+---------------+
    ...    | KPI1b - Manual Site Reset | Last Cell Down  | First Cell Up |
    ...    +---------------------------+-----------------+---------------+
    ...    | KPI1c - Manual Site Reset | Reset Request   | First Cell Up |
    ...    +---------------------------+-----------------+---------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi1a_kpi1b_kpi1c.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi1a_kpi1b_kpi1c.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi1}  oam_kpi_calculations.calculate_kpis  kpi_names=kpi1a kpi1b kpi1c  ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi1}[kpi1a][-1][delta]  kpi1a
    Log Delta In Seconds  ${kpi1}[kpi1b][-1][delta]  kpi1b
    Log Delta In Seconds  ${kpi1}[kpi1c][-1][delta]  kpi1c

Calculate KPI3
    [Documentation]
    ...    +-----------------------------+--------------+---------------+
    ...    | KPI                         | Start Point  | End Point     |
    ...    +-----------------------------+--------------+---------------+
    ...    | KPI3 - Power-On BTS Startup | BTS Power ON | First Cell Up |
    ...    +-----------------------------+--------------+---------------+
    ...
    [Arguments]    ${start_point_timestamp}    ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi3.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi3.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi3}  oam_kpi_calculations.calculate_kpi3  ims_file_path=${ims_file_path}  start_point_timestamp=${start_point_timestamp}
    Log Delta In Seconds  ${kpi3}[kpi3][-1][delta]  kpi3

Calculate KPI5
    [Documentation]
    ...    +-------------------------------------+-----------------+--------------+
    ...    | KPI                                 | Start Point     | End Point    |
    ...    +-------------------------------------+-----------------+--------------+
    ...    | KPI5 - Manual Capacity Module Reset | First Cell Down | Last Cell Up |
    ...    +-------------------------------------+-----------------+--------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi5.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi5.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi5}  oam_kpi_calculations.calculate_kpi5    ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi5}[kpi5][-1][delta]  kpi5

Calculate KPI7 KPI8 KPI9 KPI10
    [Documentation]
    ...    +----------------------------------------+-----------------------+--------------------+
    ...    | KPI                                    | Start Point           | End Point          |
    ...    +----------------------------------------+-----------------------+--------------------+
    ...    | KPI7 - Manual LTE RAT reset downtime   | First LTE Cell Down   | Last LTE Cell Up   |
    ...    +----------------------------------------+-----------------------+--------------------+
    ...    | KPI8 - Manual WCDMA RAT reset downtime | First WCDMA Cell Down | Last WCDMA Cell Up |
    ...    +----------------------------------------+-----------------------+--------------------+
    ...    | KPI9 - Manual GSM RAT reset downtime   | First GSM Cell Down   | Last GSM Cell Up   |
    ...    +----------------------------------------+-----------------------+--------------------+
    ...    | KPI10 - Manual 5G RAT reset downtime   | First 5G Cell Down    | Last 5G Cell Up    |
    ...    +----------------------------------------+-----------------------+--------------------+
    ...
    [Arguments]  ${iteration}=none
    &{kpi_times}=    Create Dictionary
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi7_kpi8_kpi9_kpi10.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi7_kpi8_kpi9_kpi10.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi7}   Run Keyword If  'lte' in $rats     oam_kpi_calculations.calculate_kpi7    ims_file_path=${ims_file_path}
    ${kpi8}   Run Keyword If  'wcdma' in $rats   oam_kpi_calculations.calculate_kpi8    ims_file_path=${ims_file_path}
    ${kpi9}   Run Keyword If  'gsm' in $rats     oam_kpi_calculations.calculate_kpi9    ims_file_path=${ims_file_path}
    ${kpi10}  Run Keyword If  'nr' in $rats      oam_kpi_calculations.calculate_kpi10   ims_file_path=${ims_file_path}
    ${delta_lte}    Run Keyword If  'lte' in $rats    oam_kpi_calculations.get all deltas  kpi7    skip_none=True
    ${delta_wcdma}    Run Keyword If  'wcdma' in $rats  oam_kpi_calculations.get all deltas  kpi8  skip_none=True
    ${delta_gsm}    Run Keyword If  'gsm' in $rats    oam_kpi_calculations.get all deltas  kpi9    skip_none=True
    ${delta_nr}    Run Keyword If  'nr' in $rats     oam_kpi_calculations.get all deltas  kpi10    skip_none=True
    Run Keyword If  'lte' in $rats    Set To Dictionary    ${kpi_times}    lte    ${delta_lte}[-1]
    Run Keyword If  'wcdma' in $rats    Set To Dictionary    ${kpi_times}    wcdma    ${delta_wcdma}[-1]
    Run Keyword If  'gsm' in $rats    Set To Dictionary    ${kpi_times}    gsm    ${delta_gsm}[-1]
    Run Keyword If  'nr' in $rats    Set To Dictionary    ${kpi_times}    nr    ${delta_nr}[-1]
    [Return]    ${kpi_times}

Calculate KPI11
    [Documentation]
    ...    +--------------------------------------------+-----------------+--------------+
    ...    | KPI                                        | Start Point     | End Point    |
    ...    +--------------------------------------------+-----------------+--------------+
    ...    | KPI11 - Manual remote power reset downtime | First Cell Down | Last Cell Up |
    ...    +--------------------------------------------+-----------------+--------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi11.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi11.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi11}  oam_kpi_calculations.calculate_kpi11    ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi11}[kpi11][-1][delta]  kpi11

Calculate KPI14
    [Documentation]
    ...    +-----------------------------------------------------+-----------------+--------------+
    ...    | KPI                                                 | Start Point     | End Point    |
    ...    +-----------------------------------------------------+-----------------+--------------+
    ...    | KPI14 - Manual capacity module power reset downtime | First Cell Down | Last Cell Up |
    ...    +-----------------------------------------------------+-----------------+--------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi14.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi14.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi14}  oam_kpi_calculations.calculate_kpi14    ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi14}[kpi14][-1][delta]  kpi14

Calculate KPI17a KPI17b
    [Documentation]
    ...    +--------------------------------------+-----------------+-----------+
    ...    | KPI                                  | Start Point     | End Point |
    ...    +--------------------------------------+-----------------+-----------+
    ...    | KPI17a - duration of blocking cell   | Block Request   | Cell Down |
    ...    +--------------------------------------+-----------------+-----------+
    ...    | KPI17b - duration of unblocking cell | Unblock Request | Cell Up   |
    ...    +--------------------------------------+-----------------+-----------+
    ...
    [Arguments]  ${cell_dn}    ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi17a_kpi17b.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi17a_kpi17b.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi17a}  oam_kpi_calculations.calculate_kpi17a  ims_file_path=${ims_file_path}  dist_name=${cell_dn}
    ${kpi17b}  oam_kpi_calculations.calculate_kpi17b  ims_file_path=${ims_file_path}  dist_name=${cell_dn}
    Log Delta In Seconds  ${kpi17a}[kpi17a][-1][delta]  kpi17a
    Log Delta In Seconds  ${kpi17b}[kpi17b][-1][delta]  kpi17b

Calculate KPI18
    [Documentation]
    ...    +---------------------------------------------+-----------------+--------------+
    ...    | KPI                                         | Start Point     | End Point    |
    ...    +---------------------------------------------+-----------------+--------------+
    ...    | KPI18 - Manual baseband pool reset downtime | First Cell Down | Last Cell Up |
    ...    +---------------------------------------------+-----------------+--------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi18.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi18.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi18}  oam_kpi_calculations.calculate_kpi18  ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi18}[kpi18][-1][delta]  kpi18

Calculate KPI51a KPI51b
    [Documentation]
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI                      | Start Point         | End Point     |
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI51a - Manual RU Reset | First Cell Down     | Last Cell Up  |
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI51b - Manual RU Reset | Last Cell Down      | First Cell Up |
    ...    +--------------------------+---------------------+---------------+
    ...
    [Arguments]  ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi51a_kpi51b.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi51a_kpi51b.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi51}  oam_kpi_calculations.calculate_kpis  kpi_names=kpi51a kpi51b  ims_file_path=${ims_file_path}
    Log Delta In Seconds  ${kpi51}[kpi51a][-1][delta]  kpi51a
    Log Delta In Seconds  ${kpi51}[kpi51b][-1][delta]  kpi51b

Calculate KPI54a KPI54b
    [Documentation]
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI                      | Start Point         | End Point     |
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI54a - RU Power Reset  | Power RU ON         | Last Cell Up  |
    ...    +--------------------------+---------------------+---------------+
    ...    | KPI54b - RU Power Reset  | Power RU ON         | First Cell Up |
    ...    +--------------------------+---------------------+---------------+
    ...
    [Arguments]  ${start_timestamp}    ${iteration}=none
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${ims_file_path}  Run Keyword If  '${iteration}'!='none'  Set Variable  ${RESULTS}/${iteration}/${timestamp}_ims_kpi54a_kpi54b.ims2
    ...                                               ELSE    Set Variable  ${RESULTS}/${timestamp}_ims_kpi54a_kpi54b.ims2
    admin.collect infomodel log from current session  target_file_name=${ims_file_path}
    ${kpi54a}    oam_kpi_calculations.calculate_kpi54a  ims_file_path=${ims_file_path}  start_point_timestamp=${start_timestamp}
    ${kpi54b}    oam_kpi_calculations.calculate_kpi54b  ims_file_path=${ims_file_path}  start_point_timestamp=${start_timestamp}
    ${deltasA}   oam_kpi_calculations.get all deltas  kpi54a  skip_none=True
    ${deltasB}   oam_kpi_calculations.get all deltas  kpi54b  skip_none=True
    Log To Console    kpi54a time converted to seconds is: ${deltasA}[-1]
    Log To Console    kpi54b time converted to seconds is: ${deltasB}[-1]

Log Delta In Seconds
    [Arguments]  ${time}  ${kpi_name}
    ${deltas}  oam_kpi_calculations.get all deltas  ${kpi_name}  skip_none=True
    Log To Console  ${kpi_name} delta is: ${time} and converted in seconds: ${deltas}[-1].
