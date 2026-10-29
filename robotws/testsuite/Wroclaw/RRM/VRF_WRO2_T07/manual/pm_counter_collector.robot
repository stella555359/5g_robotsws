*** Settings ***
Documentation   PM counter collector was designed to help collect massive amount of counters.
...             It was created for CB008021 feature, but it can be used with any custom counters.
...
...             Usage:
...               1. Set parameters in "Variables".
...               2. (Optional) Install pandas if you want to save output to .xlsx file: pip install pandas
...               3. Run: robot -V <path to TL init> -d <log_path> testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/pm_counter_collector.robot

Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    ./pm_counter_collector.py   WITH NAME   pm_counter_collector


*** Variables ***
# Default parameters
@{dates}=               2022-05-26_12:45:00   2022-05-26_12:30:00
${counter_type}=        NRRIP
${output_file_type}=    json
${cb008021_feature}=    ${True}

# Set this parameters when you want to get general counters from BTS (not CELLS)
${bts_counter}=         ${False}
${bts_counter_group}=   NRDU-1

# Set below parameters only when using custom counter set and CB008021 feature flag is set to False
${first_counter}=       M55117C00001
${last_counter}=        M55117C00003


*** Test Cases ***
Get Counters From WebEM

    ${counters}=    pm_counter_collector.generate_names_of_counters
    ...    first_counter=${first_counter}
    ...    last_counter=${last_counter}
    ...    cb008021_feature=${cb008021_feature}

    ${cell_list}=    gnbcell.get_all_cells_id
    ${bts_id}=       gnbcell.get_global_bts_id

    ${counter_dict}=    pm_counter_collector.get_counters
    ...    counter_ids=${counters}

    pm_counter_collector.find_pm_counters_by_timestamp
    ...   ${dates}
    ...   ${counter_dict}
    ...   ${cell_list}
    ...   ${bts_id}
    ...   ${bts_counter_group}
    ...   ${output_file_type}
    ...   ${counter_type}
    ...   ${bts_counter}
    ...   ${False}

