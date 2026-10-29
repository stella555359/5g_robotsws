*** Settings ***
Documentation
...    Author: Sheng Haoyun
...    Contact: haoyun-lyle.sheng@nokia-sbell.com
...    Common KWs related to RU Operation.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/12.+Module+of+RU+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource    ./library/_RU_Operation.robot


*** Keywords ***
RU Operation
    [Arguments]    ${operation}
    ...    ${product_type}
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${ru_index}=${0}
    ...    ${ru_sn}=${None}
    ...    ${ru_user_password}=${None}
    ...    ${ru_commands}=${None}
    ...    ${fault_id}=${None}
    ...    ${file_path_dict}=${None}
    ...    ${ru_sw_storage}=${None}
    ...    ${ru_log_info}=${None}
    ...    ${check_point}=${None}
    ...    ${fiber_switch_map}=${None}
    ...    ${timeout}=60
    ...    &{kwargs}
    [Documentation]     This module contain RU Operations.
    ...   Supports the following types of operations:
    ...   RU Fault: trigger_ru_fault, clear_ru_fault;
    ...   RU Command interaction: send_commands_to_ru, upload_files_to_ru, download_files_from_ru;
    ...   RU Calibration: get_calibration_data, check_calibration_result;
    ...   RU Upgrade: upgrade_ru;
    ...   Ru Log: get_ru_log, check_ru_log;
    ...   Fiber Swtich: remove_link, create_link, set_link, reset_all_links.
    ...   Ru Info: get_ru_ip, get_ru_measuments
    ...   Author: Sheng Haoyun,
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com.
    ...   | Input Parameters | Man. | Type | Description |
    ...   | operation        | yes  | str  | Supported parameters for operation: trigger_ru_fault, clear_ru_fault; |
    ...   |                  |      |      | send_commands_to_ru, upload_file_to_ru, download_file_from_ru; |
    ...   |                  |      |      | get_calibration_data, check_calibration_result; upgrade_ru, |
    ...   |                  |      |      | check_ru_upgrade; get_ru_log, check_ru_log; break_link, connect_link, |
    ...   |                  |      |      | set_link, reset_all_links |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts, ${tl.enbs[bts_index]} |
    ...   | cudu_index       | no   | int  | The index of the du, ${tl.gnbs[bts_index].dus[cudu_index]} |
    ...   | ru_index         | no   | int  | The index of the ru, ${tl.gnbs[bts_index].dus[cudu_index].rus[ru_index]} |
    ...   | ru_sn            | no   | str  | The serial number of ru, not needed if bts_index, cudu_index and ru_index exist. |
    ...   | ru_user_password | no   | dict | The username and password of ru, not needed if ru doesn't have special username and password. |
    ...   |                  |      |      | e.g. {"username":"root","passowrd:"xxxxx""} |
    ...   | ru_commands      | no   | dict | Mandatory for send_commands_to_ru, the commands need be sent to ru. |
    ...   |                  |      |      | e.g. {"connect_type":"ssh","connect_port":22,"commands":[]} |
    ...   | fault_id         | no   | str  | Mandatory for trigger_ru_fault, the id of fault that needs to be triggered on RU. e.g. 1911 |
    ...   | file_path_dict   | no   | dict | Mandatory for upload_files_to_ru, download_files_from_ru, download or upload file path |
    ...   |                  |      |      | e.g. {"file_name":"","source_path":"","target_path":""} |
    ...   | ru_sw_storage    | no   | dict | Mandatory for upgrade_ru, the ru package storage info |
    ...   | ru_log_info      | no   | dict | Mandatory for get_ru_log, check_ru_log, the ru log type and name that needs to be obtained or checked |
    ...   |                  |      |      | e.g. {"log_type": "aashell", "log_name": "", "target_path": ""} |
    ...   | check_point      | no   | dict | The required parameters of the keywords |
    ...   | fiber_switch_map | no   | dict | Mandatory for break_link, connect_link, set_link, reset_all_links, the variables for fiber switch |

    ${product_type}    Convert To Lowercase    ${product_type}
    Run Keyword And Return    _RU_Operation.${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    ru_index=${ru_index}
    ...    ru_sn=${ru_sn}
    ...    ru_user_password=${ru_user_password}
    ...    ru_commands=${ru_commands}
    ...    fault_id=${fault_id}
    ...    file_path_dict=${file_path_dict}
    ...    ru_sw_storage=${ru_sw_storage}
    ...    ru_log_info=${ru_log_info}
    ...    check_point=${check_point}
    ...    fiber_switch_map=${fiber_switch_map}
    ...    timeout=${timeout}
    ...    kwargs=${kwargs}
