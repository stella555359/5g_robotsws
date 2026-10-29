*** Setting ***
Documentation
...    VRF HAZ 1 Common Resources.

Library           OperatingSystem
Library           String
Library           python/pcmd/find_pcmd_record.py
Library           python/pcmd/save_pcmd_log.py
Library           python/pcmd/pcmd_compare_check.py
Variables         python/pcmd/global_config.py






*** Keyword ***
Save Pcmd Log from MNI
    [Arguments]     ${local_log_dir}=${TEST_LOG_DIRECTORY}    ${t_detach}=none    ${cell_id}=${1233409}
	...             ${record_type}=${1}    &{check_filter}
	[Documentation]    Author: Xiang Liangliang
    ...                 Contact: liang.xiang@nokia-sbell.com
    ...                 This keyword is used to download and analyze the pcmd log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_log_dir} | yes  | log path to save pcdm log, if not provided, use ${TEST_LOG_DIRECTORY}  |
    ...    | ${t_detach}      | yes  | system time of ue detach |
    ...    | ${cell_id}       | yes  | target cell id for pcmd record |
    ...    | ${record_type}   | yes  | 1:normal record   2:abnormal record |
    ...    | &{check_filter}  | yes  |  pcmd fields to filter pcmd record |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Example of all arguments provided:  |    |
    ...    |  Save Pcmd Log from MNI  |  ${local_log_dir}=${TEST_LOG_DIRECTORY}  |
    ...    |  ...                        |  ${t_detach}=time  |
    ...    |  ...                        |  ${cell_id}=1233409   |
    ...    |  ...                        |  ${record_type}=1 |
    ...    |  ...                        |  &{check_filter}=&{check_filter}  |
	Run_Keyword_And_Ignore_Error    save pcmd log    ${local_log_dir}    ${t_detach}
	...                                              ${cell_id}    ${record_type}    &{check_filter}


Check Pcmd Record from MNI
    [Arguments]    ${filepath}=${TEST_LOG_DIRECTORY}   ${input_pcmd_array}=none
    [Documentation]    Author: Xiang Liangliang
    ...                 Contact: liang.xiang@nokia-sbell.com
    ...                 This keyword is used to download and analyze the pcmd log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${filepath} | no  | log path to check pcdm log, if not provided, use ${TEST_LOG_DIRECTORY}  |
    ...    | ${input_pcmd_array}  | yes  |  pcmd fields to be checked |
    ...
    ...    | Return Value | Description |
    ...    | ${check_result} | True when keyword execution succeed |
    ...
    ...    Example
    ...    |  Example of all arguments provided:  |    |
    ...    |  Check Pcmd Record from MNI  |  ${filepath}=${TEST_LOG_DIRECTORY}  |
    ...    |  ...                        |  ${input_pcmd_array}=time  |
    ${check_result}=    check pcmd record    ${filepath}    ${input_pcmd_array}
    [Return]    ${check_result}




