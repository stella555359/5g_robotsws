*** Settings ***
Documentation
...    author: Ding Binmei developped for 19A, Wu Fangmin Modified for 19B
...    contact: fangmin.wu@nokia-sbell.com
...    squad group: MMW_SG_03
...    Description: When import this common checkpoints file, you will have to define a global variable for ${PROGRAM}
...                 Available values: 19B. column index may changes in different program,
...                                   if need to support for other versions, please contact with me
Library     ../../../../resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Library    ./5GC002040_TTI_Trace_Analysis_dl.py
Library    ./5GC002040_TTI_Trace_Analysis_ul.py
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    5GC002040_common_keyword.robot


*** Variables ***
${ULLADELTASINRSTEPDOWN}    ${0.5}
${ULLABLERTARGET}    ${0.1}
${DLLADELTACQISTEPDOWN}    ${0.25}
${DLLABLERTARGET}          ${0.1}
${bler_exp}               0.05
*** Keywords ***
Verify_ul_data_transmission_is_done_with_highest_mcs
    [Arguments]  ${file_path}    ${mcs_mapping_table}
    Log to console    Verify ul data transmission is done with highest mcs
    tti_ul.verify_ul_data_transmission_is_done_with_highest_mcs    file_path=${file_path}    mcs_mapping_table=${mcs_mapping_table}

Verify_calculation_of_corrected_average_CQI_for_dl
    [Arguments]    ${file_path}    ${rdAvgCqi}
    [Documentation]  ${file_path}: Event trace log file path with CSV format
    ...              ${rdAvgCqi}: R&D parameter defined in swconfig file
    Log to console    Verify_calculation_of_corrected_average_CQI_for_dl
    tti_dl.verify_calculation_of_corrected_average_CQI    file_path=${file_path}    rdAvgCqi=${rdAvgCqi}

Varify MCS varied when radio conditions changed
    Log    \n Varify MCS varied when radio conditions changed    console=yes
    Start TTI trace log capturing
    Adjust Radiorack Attenuation    attenuation_values_of_all_ports=${ATTENUATION_VALUE_DL_BAD_${TestCaseId}}
    sleep    1s
    Adjust Radiorack Attenuation    attenuation_values_of_all_ports=${ATTENUATION_VALUE_DL_MID_${TestCaseId}}
    sleep    1s
    Adjust Radiorack Attenuation    attenuation_values_of_all_ports=${ATTENUATION_VALUE_DL_GOOD_${TestCaseId}}
    sleep    1s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${TS_CASE_LOG_PATH}
    Set suite variable    ${CSV_PATH_UL}       ${dict_csv_file_path['UL']}
    Set suite variable    ${CSV_PATH_DL}       ${dict_csv_file_path['DL']}
    ${mcs_list}    get_mcs_list    file_path=${CSV_PATH_DL}
    ${number_of_mcs}    get length    ${mcs_list}
    should be true    condition=${number_of_mcs} > 3    msg=mcs is not changed


