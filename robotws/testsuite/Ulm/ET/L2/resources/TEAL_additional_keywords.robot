*** Settings ***
Documentation  This is a collection of additional keywords meant to be used together with TEAL Framework.


Resource  ../../../resources/Common/wts_ue.robot
Library   ../libraries/bearer_stats.py  WITH NAME  bearer_stats_helpers


*** Keywords ***

Collect Bearer Stats and save to Json and DF
    [Arguments]  ${collection_iterations}  ${sample_interval}  ${mode}=legacy  ${write_to_pickle}=${TRUE}
    ...    ${filename}=${EMPTY}
    ${bearer_stats_attribs_nsa}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    ${all_beaerer_stats}=  create list
    FOR  ${counter}  IN RANGE  ${0}  ${collection_iterations}
        ${kw_start}=  DateTime.Get Current Date
        ${status}  ${output_nsa}=  run keyword and ignore error  wts_ue.Get Bearer Stats From Egate
        ...  ue_id=${bearer_stats_attribs_nsa["ues"]}  trf_id=${bearer_stats_attribs_nsa["trf_ids"]}
        ...  mode=${mode}  id=${bearer_stats_attribs_nsa["bearers"]}  dir=bi
        IF    '${status}'=='FAIL'
        ...  Log    'Bearer Stats not collected for NSA'  console=yes
        ...  ELSE
        ...    Append To List  ${all_beaerer_stats}  ${output_nsa}
        ${status}  ${output_sa}=  Run Keyword And Ignore Error    wts_ue.Get Bearer Stats From Egate
        ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  mode=${mode}
        ...  pdu=${bearer_stats_attribs_sa["pdus"]}  qfi=${bearer_stats_attribs_sa["qfis"]}  dir=bi
        IF    '${status}'=='FAIL'
        ...  Log    'Bearer Stats not collected for SA'  console=yes
        ...  ELSE
        ...    Append To List  ${all_beaerer_stats}  ${output_sa}
        Sleep remaining time    ${kw_start}    ${sample_interval}
    END

    bearer_stats_helpers.Write To Json File  ${ts_log_dir}/${scenario_name}_bearer_stats${filename}.json  ${all_beaerer_stats}
    ${df} =    bearer_stats_helpers.Convert Bearer Stats to DF    json_file=${ts_log_dir}/${scenario_name}_bearer_stats${filename}.json
    ...                                                           write_to_pickle=${write_to_pickle}
    ...                                                           target_path=${ts_log_dir}/${scenario_name}_bearer_stats${filename}.pkl

    IF   '${mode}'=='legacy'    bearer_stats_helpers.Write Csv    ${ts_log_dir}/${scenario_name}_bearer_stats.csv    ${all_beaerer_stats}
    RETURN    ${df}


Sleep remaining time
    [Arguments]  ${start_time}  ${wait_time}
    ${required_end}=  DateTime.Add Time To Date  ${start_time}  ${wait_time}
    ${current_time}=  DateTime.Get Current Date
    ${sleep_time}=  DateTime.Subtract Date From Date    ${required_end}    ${current_time}
    Sleep  ${sleep_time}  reason=wait until the end of the loop
