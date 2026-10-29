*** Settings ***
Documentation
...              author: Przemyslaw Herian, Agata Sidlo
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB014023 - FR2 SA RAN Sharing
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource    resources/CB014023_resources.robot


Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB014023_03_5GC001630-B#B1_Successful_multi-PLMN_SA_Sharing_with_multiple_PLMN_SETs_per_cell
    [Setup]    Test Setup
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    _val.Verify All Amf Are Active
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts_cfg.Register Multiple Ues And Handle Traffic    trf_duration=${None}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _val.Check PLMN in SIB
    ${pm_counters_filepath}    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    _wts_cfg.Stop Traffic    number_of_ues=${6}
    _val.Validate Scells State In Egate    cells_to_validate_map=${cells_to_validate_map_all_ues}    messages_occurrences=${1}
    _val.Validate Pm Counters


CB014023_07_5GC001630-G#B1_RAN_Sharing_activation_flag_on-line_update
    [Setup]    Test Setup
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    Perform recomissioning With Delta    path_to_delta=${CURDIR}${/}resources${/}disable_delta.json
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts_cfg.Attach Sa Ue And Run Traffic    trf_dir=dl    dl_mbps=${525}
    _wts_cfg.Attach Multiple Ues And Expect Error
    wait_for_traffic_running    duration=${20}
    _wts_cfg.Stop Traffic    number_of_ues=${1}
    common_wts.Ue Deregister    ue_id=${1}

    Perform Recomissioning With Delta    path_to_delta=${CURDIR}${/}resources${/}enable_delta.json
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts_cfg.Register Multiple Ues And Handle Traffic    trf_duration=${None}
    ta5g_pm_counters.Wait For Next Full PM Interval
    ${pm_counters_filepath}    _logs.Download Counters Reports
    ...    counters_type=PM
    ...    wait_for_next_interval=${True}
    _wts_cfg.Stop Traffic    number_of_ues=${6}

    _val.Validate Scells State In Egate    cells_to_validate_map=${cells_to_validate_map_ue_1}    messages_occurrences=${2}
    _val.Validate Scells State In Egate    cells_to_validate_map=${cells_to_validate_map_ues_2_to_6}    messages_occurrences=${1}
    _val.Validate Pm Counters
